module Simatic
  module Types
    class SimaticType
      def initialize value
        @value = value
      end

      def self.parse raw_data
        if raw_data.kind_of? Array
          # puts "raw_data #{raw_data}"
          raw_data.map { |raw_value| self.parse_one raw_value } 
        else
          parse_one raw_data
        end
      end

      def self.parse_one raw_value
          raw_value_length = raw_value.length
          if raw_value_length != self::LENGTH
            raise "Cant parse, cause raw data length #{raw_value_length} (must be #{self::LENGTH})."
          end
          raw_value
      end

      def serialize
        if @value.kind_of? Array
          @value.map { |single_val| self.class.serialize single_val }
        else
          self.class.serialize @value
        end
      end
    end
  end
end