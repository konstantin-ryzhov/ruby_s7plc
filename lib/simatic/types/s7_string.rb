require 'simatic/types/simatic_type'

module Simatic
  module Types
    class S7String < SimaticType
      def initialize value, size = nil
        @size = size
        @value = value
      end

      def self.serialize value, size
        raise "Value must be String class" unless value.kind_of? String
        size = size || value.length
        [size, value.length, value].pack("CCa#{size}x")
      end
      
      def serialize
        if @value.kind_of? Array
          @value.map { |single_val| self.class.serialize single_val, @size }
        else
          self.class.serialize @value, @size
        end
      end

      def self.parse_one raw_value
        res = raw_value.unpack('CCa*')

        buf_size = res[0]
        string_size = res[1]
        string = res[2]

        raise "S7String is broken, cant parse" if buf_size.nil? || string_size.nil? || string.nil? || buf_size < string_size

        string[0, string_size]
      end
    end
  end
end