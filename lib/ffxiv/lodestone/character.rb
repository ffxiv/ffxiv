module FFXIV
  module Lodestone
    class Character < Model

      attr_accessor :id, :name, :server, :thumbnail_uri, :image_uri, :race, :subrace, :gender,
                    :nameday, :guardian, :city_state, :grand_company, :grand_company_rank,
                    :free_company, :minions, :mounts, :end_contents, :self_introduction, :classes,
                    :num_blogs, :first_blogged, :latest_blogged, :bpd, :free_company_rank
      alias :end_contents? :end_contents

      class << self

        def name_to_id(name, server)
          dom = Lodestone.fetch("character/?q=#{URI.escape(name)}&worldname=#{URI.escape(server)}")
          dom.at("h4.player_name_gold a").attr("href").split("/")[-1].to_i
        end

        def find_by_id(id)
          begin
            dom = Lodestone.fetch("character/#{id}")

            props = {}
            props[:id] = id
            props[:name] = dom.css("div.player_name_txt h2 a").inner_text
            props[:server] = dom.css("div.player_name_txt h2 span").inner_text[2...-1]
            props[:thumbnail_uri] = drop_uts(dom.css("div.player_name_thumb img").attr("src").inner_text)
            props[:image_uri] = drop_uts(dom.css("img[width='264']").attr("src").inner_text)
            props[:race], props[:subrace], props[:gender] = dom.css("div.chara_profile_title").inner_text.strip.split(" / ")
            dom.css("ul.chara_profile_list li").to_a.each do |n|
              t = n.inner_text
              if t.include?("Nameday")
                props[:nameday], props[:guardian] = n.css(".txt_yellow").to_a.map(&:inner_text)
              elsif t.include?("City-state")
                props[:city_state] = n.css(".txt_yellow").inner_text
              elsif t.include?("Grand Company")
                props[:grand_company], props[:grand_company_rank] = n.css(".txt_yellow").inner_text.split("/")
              elsif t.include?("Free Company")
                props[:free_company] = n.css(".txt_yellow").inner_text
              end
            end
            dom.css("div.area_header_w358_inner").to_a.each do |n|
              aname = n.css("h4.ic_silver").inner_text.downcase
              items = n.css("a.ic_reflection_box").to_a.map{|m| m.attr("title")}.map{|i| i.capitalize.gsub(/[\s][a-z]/) {|s| s.upcase}}.sort
              props[:"#{aname}"] = items
            end
            props[:end_contents] = props[:mounts].include?("Magitek Armor")
            props[:self_introduction] = dom.css("div.txt_selfintroduction").inner_html.strip
            props[:classes] = {}
            %w{fighter sorcerer crafter gatherer}.each do |discipline|
              dom.css("h4.class_#{discipline} + div.table_black_w626 td.ic_class_wh24_box").to_a.each do |td|
                txt = td.inner_text
                if !txt.empty?
                  lvl = td.next_sibling().next_sibling().inner_text.to_i
                  props[:classes][txt] = lvl == 0 ? nil : lvl
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
          @num_blogs = total_node.nil? ? 0 : total_node.inner_text.to_i
          if @num_blogs > 0
            dom2 = Lodestone.fetch("character/#{@id}/blog?order=2")
            {latest_blogged: dom1, first_blogged: dom2}.each do |prop, dom|
              txt = dom.at("h3.header_title").inner_text
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