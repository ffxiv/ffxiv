module FFXIV
  module Lodestone
    class Linkshell < Model

      attr_accessor :id, :name, :server, :members, :num_members

      class << self

        def search(keyword, server: nil, page: 1, verbose: false)
          dom = Lodestone.fetch("linkshell/?q=#{URI.escape(keyword)}&worldname=#{URI.escape(server)}&page=#{URI.escape(page.to_s)}")
          linkshells = dom.search("table.table_elements_com_ls tr").map do |tr|
            h4 = tr.at("th h4")
            a = h4.at("a")
            id = a.attr("href").split("/")[-1].to_i
            if verbose
              self.find_by_id(id)
            else
              self.new({
                id: id,
                name: a.content,
                server: h4.at("span").content.strip[1...-1],
                num_members: tr.at("td span").content.split(": ")[1].to_i
              })
            end
          end
          pagination = dom.at("div.current_list")
          if pagination
            total = pagination.at("span.total").content.to_i
            results = {
              show_start: pagination.at("span.show_start").content.to_i,
              show_end: pagination.at("span.show_end").content.to_i,
              total: total,
              num_pages: (total / 50.0).ceil,
              linkshells: linkshells
            }
          end
        end

        def name_to_id(name, server)
          search_results = self.search(name, server: server)
          if search_results
            search_results[:linkshells].each do |ls|
              return ls.id if name == ls.name
            end
          end
        end

        def find_by_id(id)
          begin
            dom = Lodestone.fetch("linkshell/#{id}")
            props = {}
            props[:id] = id
            buff = dom.at("div.contents_header h2").content.match(/^(.+)\s\((.+)\)$/)
            props[:name] = buff[1]
            props[:server] = buff[2]
            props[:num_members] = dom.at("h3.ic_silver").content.match(/\s\((\d+)\s/)[1].to_i
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
            dom = Lodestone.fetch("linkshell/#{@id}?page=#{page_no}")
            dom.search("div.player_name_area").each do |node|
              cid = node.at("div.name_box a").attr("href").split("/")[-1]
              if node.at("span.ic_master")
                lsrank = :master
              elsif node.at("span.ic_leader")
                lsrank = :leader
              else
                lsrank = :member
              end
              members[cid] = lsrank
            end
          end
          characters = []
          members.each do |cid, lsrank|
            character = Character.find_by_id(cid)
            character.linkshell_rank = lsrank
            characters << character
          end
          @members = characters
        end
        @members
      end

    end
  end
end