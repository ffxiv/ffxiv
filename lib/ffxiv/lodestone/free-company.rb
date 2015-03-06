module FFXIV
  module Lodestone
    class FreeCompany < Model

      attr_accessor :id, :name, :server, :tag, :logo_uri, :formed, :members, :num_members, :rank,
                    :grand_company, :grand_company_standing, :slogan, :focus, :seeking, :active,
                    :recruiting, :housing, :weekly_rank, :monthly_rank
      alias :recruiting? :recruiting

      class << self

        def search(keyword, server: nil, page: 1, verbose: false)
          dom = Lodestone.fetch("freecompany/?q=#{URI.escape(keyword)}&worldname=#{URI.escape(server)}&page=#{URI.escape(page.to_s)}")
          free_companies = dom.search("table.table_elements_com_fc tr").map do |tr|
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
                grand_company: tr.at("div.groundcompany_name").content
              })
            end
          end
          pagination = dom.at("div.current_list")
          total = pagination.at("span.total").content.to_i
          results = {
            show_start: pagination.at("span.show_start").content.to_i,
            show_end: pagination.at("span.show_end").content.to_i,
            total: total,
            num_pages: (total / 50.0).ceil,
            free_companies: free_companies
          }
        end

        def name_to_id(name, server)
          dom = Lodestone.fetch("freecompany/?q=#{URI.escape(name)}&worldname=#{URI.escape(server)}")
          dom.at("div.ic_freecompany_box a").attr("href").split("/")[-1].to_i
        end

        def name_to_id(name, server)
          self.search(name, server: server)[:free_companies].each do |fc|
            return fc.id if name == fc.name
          end
          nil
        end

        def find_by_id(id)
          begin
            dom = Lodestone.fetch("freecompany/#{id}")

            props = {}
            props[:id] = id

            props[:logo_uri] = dom.search("div.ic_crest_64 img").map{|n| n.attr("src")}

            gcs_node = dom.at("span.friendship_color")
            props[:grand_company_standing] = gcs_node.inner_text[1...-1]

            gc_node = gcs_node.previous_sibling
            props[:grand_company] = gc_node.inner_text.strip

            name_node = gcs_node.next_sibling.next_sibling.next_sibling
            props[:name] = name_node.inner_text

            server_node = name_node.next_sibling.next_sibling
            props[:server] = server_node.inner_text[1...-1]

            props[:tag] = dom.at("td.vm").last_element_child.next_sibling.inner_text[1...-1]

            dom.search("table.table_style2 tr").each do |tr|
              td_node = tr.at("td")
              td_text = td_node.inner_text.strip
              case tr.at("th").inner_text
                when "Formed"
                  props[:formed] = Time.at(td_text.match(/ldst_strftime\((\d{10}), 'YMD'\)/)[1].to_i).utc
                when "Rank"
                  props[:rank] = td_text.to_i
                when "Active Members"
                  props[:num_members] = td_text.to_i
                when "Ranking"
                  weekly, monthly, __garbage = td_node.inner_html.split("<br>").map(&:strip)
                  props[:weekly_rank] = weekly.include?("--") ? nil : weekly.match(/\d+/)[0].to_i
                  props[:monthly_rank] = monthly.include?("--") ? nil : monthly.match(/\d+/)[0].to_i
                when "Company Slogan"
                  props[:slogan] = td_text == "" ? nil : td_text
                when "Active"
                  props[:active] = td_text == "Not specified" ? nil : td_text
                when "Recruitment"
                  props[:recruiting] = td_text == "Open"
                when "Focus"
                  props[:focus] = td_node.search("li:not(.icon_off) img").map{|n| n.attr("title")}
                when "Seeking"
                  props[:seeking] = td_node.search("li:not(.icon_off) img").map{|n| n.attr("title")}
                when "Estate Profile"
                  name_node = td_node.at("div.txt_yellow")
                  if name_node
                    address_size, greeting = td_node.search("p").map(&:inner_text)
                    address, size = address_size.split(" (")
                    props[:housing] = {
                      name: name_node.inner_text,
                      address: address,
                      size: size[0...-1],
                      greeting: greeting == "No greeting available." ? nil : greeting
                    }
                  else
                    props[:housing] = nil
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

      def members
        if @members.nil?
          members = {}
          num_pages = (@num_members / 50.0).ceil # 50 members / page
          1.upto(num_pages) do |page_no|
            dom = Lodestone.fetch("freecompany/#{@id}/member/?page=#{page_no}")
            dom.search("div.player_name_area").each do |node|
              cid = node.at("div.name_box a").attr("href").split("/")[-1]
              fcrank = node.at("div.fc_member_status").content.strip
              members[cid] = fcrank
            end
          end
          characters = []
          members.each do |cid, fcrank|
            character = Character.find_by_id(cid)
            character.free_company_rank = fcrank.strip
            characters << character
          end
          @members = characters
        end
        @members
      end

      private


    end
  end
end