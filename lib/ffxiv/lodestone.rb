$:.unshift File.dirname(__FILE__)

require "pp"
require "nokogiri"
require "uri"
require "open-uri"

require "lodestone/model"
require "lodestone/character"
require "lodestone/free-company"
require "lodestone/linkshell"

module FFXIV
  module Lodestone

    @@debug = false

    class << self

      def debug
        @@debug
      end

      def debug=(flag)
        @@debug = flag
      end

      def d(str)
        puts "\033[35m[Debug]\033[0m #{str}" if @@debug
      end

      def fetch(endpoint)
        uri = "http://na.finalfantasyxiv.com/lodestone/" + endpoint
        d("Fetching #{uri} ......")
        html, charset = open(uri) do |page|
          [page.read, page.charset]
        end
        d("    done (size=#{html.size}, charset=#{charset})")
        Nokogiri::HTML.parse(html, nil, charset)
      end

    end
  end
end