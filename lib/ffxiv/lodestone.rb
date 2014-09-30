$:.unshift File.dirname(__FILE__)

require "pp"
require "nokogiri"
require "uri"
require "open-uri"

require "lodestone/model"
require "lodestone/character"
require "lodestone/free-company"

module FFXIV
  module Lodestone
    class << self
      def fetch(endpoint)
        uri = "http://na.finalfantasyxiv.com/lodestone/" + endpoint
        html, charset = open(uri) do |page|
          [page.read, page.charset]
        end
        Nokogiri::HTML.parse(html, nil, charset)
      end
    end
  end
end