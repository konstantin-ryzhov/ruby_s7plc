require 'simatic/types/simatic_type'

module Simatic
  module Types
    class S5time < SimaticType
      LENGTH = 2
      def self.parse_one raw_value
        super
        hex_string = raw_value.unpack('h*').first
        time_base = hex_string[0].to_i
        time_value = hex_string[1,3].to_i
        case time_base
        when 0 # 10 ms
          time_value * 100.0
        when 1 # 100 ms
          time_value * 10.0
        when 2 # 1 s
          time_value * 1.0
        when 3 # 10 s
          time_value / 10.0
        end
      end

      def self.serialize value
        raise "Value must be numeric in seconds" unless value.kind_of? Numeric

        params = case value.round(2)
        when 0.00...9.99
          [0, 100.0]
        when 9.99...99.9
          [1, 10.0]
        when 99.9...999.0
          [2, 1.0]
        when 999.0..9990.0
          [3, 0.1]
        else
          raise "Value is to large"
        end

        time_base = params.first.to_s
        time_value = (value*params.last).to_i.to_s

        [time_base+time_value].pack('h*')
      end
    end
  end
end