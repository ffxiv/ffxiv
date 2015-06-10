module FFXIV
  module Lodestone
    class Character < Model

      attr_accessor :id, :name, :server, :thumbnail_uri, :image_uri, :race, :subrace, :gender, :nameday,
                    :birthday, :guardian, :city_state, :grand_company, :grand_company_rank, :free_company,
                    :minions, :mounts, :end_contents, :eternal_bonding, :self_introduction, :classes,
                    :num_blogs, :first_blogged, :latest_blogged, :bpd, :free_company_rank, :linkshell_rank
      alias :end_contents? :end_contents
      alias :eternal_bonding? :eternal_bonding

      class << self

        def search(keyword, server: nil, page: 1, verbose: false)
          dom = Lodestone.fetch("character/?q=#{URI.escape(keyword)}&worldname=#{server ? URI.escape(server) : ""}&page=#{URI.escape(page.to_s)}")
          # Couldn't find a way to get this node with CSS...
          characters = dom.xpath("//comment()[.=' result ']/following::table[1]/tr").map do |tr|
            h4 = tr.at("td h4")
            a = h4.at("a")
            id = a.attr("href").split("/")[-1].to_i
            if verbose
              self.find_by_id(id)
            else
              self.new({
                id: id,
                name: a.content,
                server: h4.at("span").content.strip[1...-1],
                thumbnail_uri: drop_uts(tr.at("th img").attr("src"))
              })
            end
          end
          pagination = dom.at("div.current_list")
          if pagination
            span_total = pagination.at("span.total")
            raise "Character not found" unless span_total
            total = span_total.content.to_i
            results = {
              show_start: pagination.at("span.show_start").content.to_i,
              show_end: pagination.at("span.show_end").content.to_i,
              total: total,
              num_pages: (total / 50.0).ceil,
              characters: characters
            }
          end
        end

        def name_to_id(name, server)
          search_result = self.search(name, server: server)
          if search_result
            search_result[:characters].each do |ch|
              return ch.id if name.downcase == ch.name.downcase
            end
          end
          nil
        end

        def find_by_id(id)
          begin
            dom = Lodestone.fetch("character/#{id}")

            props = {}
            props[:id] = id
            ch_name = dom.at("div.player_name_txt h2 a")
            props[:name] = ch_name.content
            props[:server] = ch_name.next_element.content.strip[1...-1]
            props[:thumbnail_uri] = drop_uts(dom.at("div.player_name_thumb img").attr("src"))
            props[:image_uri] = drop_uts(dom.at("div.bg_chara_264 img").attr("src"))
            props[:race], props[:subrace], gender = dom.at("div.chara_profile_title").content.strip.split(" / ")
            props[:gender] = case gender
              when "♀" then :female
              when "♂" then :male
              else raise "Unrecognized gender symbol: #{gender}"
            end

            months = {
              "1st Astral Moon" => 1,
              "1st Umbral Moon" => 2,
              "2nd Astral Moon" => 3,
              "2nd Umbral Moon" => 4,
              "3rd Astral Moon" => 5,
              "3rd Umbral Moon" => 6,
              "4th Astral Moon" => 7,
              "4th Umbral Moon" => 8,
              "5th Astral Moon" => 9,
              "5th Umbral Moon" => 10,
              "6th Astral Moon" => 11,
              "6th Umbral Moon" => 12
            }

            dom.search("dl.chara_profile_box_info").each do |n|
              n.search("dd.txt").each do |dd|
                dd_txt_name = dd.next_element
                t = dd_txt_name.content
                case dd.content
                  when "Nameday"
                    props[:nameday] = t
                    match = t.match /^(\d+).+?the\s(.*)$/
                    pp match
                    props[:birthday] = Date.new(2013, months[match[2]], match[1].to_i)
                  when "Guardian"
                    props[:guardian] = t
                  when "City-state"
                    props[:city_state] = t
                  when "Grand Company"
                    props[:grand_company], props[:grand_company_rank] = t.split("/")
                  when "Free Company"
                    props[:free_company] = FreeCompany.new(id: dd_txt_name.at("a").attr("href").split("/")[-1].to_i, name: t, server: props[:server])
                end
              end
            end

            # The first "minion_box" contains mounts, and they need capitalization unlike minions.
            minion_boxes = dom.search("div.minion_box")
            props[:mounts] = minion_boxes[0].search("a").map{|a| a.attr("title").split.map(&:capitalize).join(' ')}
            props[:minions] = minion_boxes[1].search("a").map{|a| a.attr("title")}

            # Let's assume that whoever has this mount has slained Ultima Weapon and watched the ending movie, hence is qualified for the endgame contents.
            props[:end_contents] = props[:mounts].include?("Magitek Armor")

            # Likewise, assume that whoever has this mount has purchased Gold or Platinum eternal bonding.
            # Note that Standard version doesn't come with the mount, so use nil instead of false to indicate "unknown".
            props[:eternal_bonding] = props[:mounts].include?("Ceremony Chocobo") ? true : nil

            self_introduction = dom.at("div.txt_selfintroduction").inner_html.strip
            props[:self_introduction] = self_introduction == "" ? nil : self_introduction

            props[:classes] = {}
            %w{Fighter Sorcerer Crafter Gatherer}.each do |discipline|
              props[:classes][discipline] = {}
              dom.search("h4.class_#{discipline.downcase} + div.table_black_w626 td.ic_class_wh24_box").each do |td|
                txt = td.content
                unless txt.empty?
                  lvl = td.next_sibling().next_sibling().content.to_i
                  props[:classes][discipline][txt] = lvl == 0 ? nil : lvl
                end
              end
            end

            self.new(props)
          rescue => e
            pp e
            nil
          end
        end

      end

      def free_company(fetch = false)
        if fetch
          @free_company = FreeCompany.find_by_name(@free_company, @server)
        end
        @free_company
      end

      def birthday
        Utils.ed2gd(@nameday)
      end

      def data_center
        Utils.data_center(@server)
      end

      def num_blogs
        init_blog; @num_blogs
      end

      def bpd
        init_blog; @bpd
      end

      def latest_blogged
        init_blog; @latest_blogged
      end

      def first_blogged
        init_blog; @first_blogged
      end

      def blogs(load_details = false)
        unless @blogs
          @blogs = []
          if num_blogs > 0
            num_blog_pages = (num_blogs / 10.0).ceil
            1.upto(num_blog_pages) do |page|
              dom = Lodestone.fetch("character/#{@id}/blog?order=2&page=#{page}")
              dom.search("section.base_body").each do |section_blog|
                a_title = section_blog.at("a.blog_title")
                blog = {
                  id: a_title.attr("href").split("/")[-1],
                  title: a_title.content,
                  date: Time.at(section_blog.at("script").content[/ldst_strftime\((\d{10}),/, 1].to_i),
                  num_comments: section_blog.at("span.ic_comment").content.to_i
                }
                if load_details
                  dom_blog = Lodestone.fetch("character/#{@id}/blog/#{blog[:id]}")
                  blog[:body] = dom_blog.at(".txt_selfintroduction").inner_html.strip

                  blog[:comments] = []
                  if blog[:num_comments] > 0
                    dom_blog.search("div.comment").each do |dom_comment|
                      unless dom_comment.at("div.comment_delete_box")
                        div_by = dom_comment.at("div.player_id")
                        by = nil
                        if div_by
                          a_by = div_by.at("a")
                          by = self.class.new({
                            id: a_by.attr("href").split("/")[-1],
                            name: a_by.content,
                            server: div_by.at("span").content.strip[1...-1]
                          })
                        end
                        blog[:comments] << {
                          id: dom_comment.previous_element.attr("name").split("_")[1].to_i,
                          by: by,
                          date: Time.at(dom_comment.at("script").content[/ldst_strftime\((\d{10}),/, 1].to_i),
                          body: dom_comment.at("div.balloon_body_inner").inner_html.strip
                        }
                      end
                    end
                  end

                  blog[:tags] = []
                  a_tags = dom_blog.search("div.diary_tag a")
                  if a_tags
                    a_tags.each do |a_tag|
                      blog[:tags] << a_tag.content[1...-1]
                    end
                  end

                  blog[:images] = []
                  img_thumbs = dom_blog.search("ul.thumb_list li img")
                  if img_thumbs
                    img_thumbs.each do |img_thumb|
                      unless img_thumb.attr("class") == "img_delete"
                        blog[:images] << {
                          thumbnail: img_thumb.attr("src"),
                          original: img_thumb.attr("data-origin_src")
                        }
                      end
                    end
                  end
                end
                @blogs << blog
              end
            end
          end
        end
        @blogs
      end

      def thumbnail_uri
        @thumbnail_uri + "?#{Time.now.to_i}"
      end

      def image_uri
        @image_uri + "?#{Time.now.to_i}"
      end

      private
      def init_blog
        if @num_blogs.nil?
          dom1 = Lodestone.fetch("character/#{@id}/blog?order=1")
          total_node = dom1.at("div.current_list span.total")
          @num_blogs = total_node.nil? ? 0 : total_node.content.to_i
          if @num_blogs > 0
            dom2 = Lodestone.fetch("character/#{@id}/blog?order=2")
            {latest_blogged: dom1, first_blogged: dom2}.each do |prop, dom|
              txt = dom.at("h3.header_title").content
              uts = txt.match(/ldst_strftime\((\d{10}), 'YMDHM'\)/)[1].to_i
              send("#{prop}=", Time.at(uts).utc)
            end
            @bpd = (@num_blogs / ((Time.now - @first_blogged) / 86400.0)).round(2)
          end
        end
      end

    end
  end
end