require 'time'
require 'simatic/types/simatic_type'

module Simatic
  module Types
    class DateAndTime < SimaticType
      LENGTH = 8
      def self.parse_one raw_value
        super
        array = raw_value.unpack('H*').first

        year = array[0,2].to_i + (array[0,2].to_i <= 89 ? 2000 : 1900)
        month = array[2,2].to_i
        day = array[4,2].to_i
        hour = array[6,2].to_i
        min = array[8,2].to_i
        sec = array[10,2].to_i

        microsecond = array[12,3].to_i * 1000

        Time.utc(year, month, day, hour, min, sec, microsecond)
      end

      def self.serialize value
        raise "Value must be Time class" unless value.kind_of? Time

        hex_string = 
          '%02d' % (value.year - ((value.year >= 2000) ? 2000 : 1900)) +
          '%02d' % value.month +
          '%02d' % value.day +
          '%02d' % value.hour +
          '%02d' % value.min +
          '%02d' % value.sec +
          '%03d' % (value.usec/1000.0).to_i +
          '%01d' % (value.wday+1)

          # puts hex_string
          
          [hex_string].pack('H*')
      end
    end
  end
end