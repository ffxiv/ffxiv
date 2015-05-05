module FFXIV
  module Lodestone
    class Model

      class << self
        def find_by_name(name, server)
          self.find_by_id(self.name_to_id(name, server))
        end
      end

      def initialize(props = {})
        props.each do |name, value|
          self.send("#{name}=", value) if self.respond_to?(name)
        end
      end

      def attributes
        instance_variables.inject({}) do |attrs, aname|
          attrs[aname] = instance_variable_get(aname)
          attrs
        end
      end

      private
      def self.drop_uts(str)
        str[0...(str.size - 11)] # ?1234567890
      end

    end
  end
end