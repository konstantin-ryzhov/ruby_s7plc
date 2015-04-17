require 'date'

module SimaticTypes

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

  class Bool < SimaticType
    LENGTH = 1

    def self.parse_one raw_data
      super
      raw_data.unpack('b*').first.index('1') ? true : false
    end

    def self.serialize value
      [value ? 1 : 0].pack('c')
    end
  end

  class SimaticSimpleType < SimaticType
    def self.parse_one raw_value
      super
      raw_value.unpack(self::PATTERN).first
    end

    def self.serialize value
      raise "Value must be numeric (value: #{value})" unless value.kind_of? Numeric

      # puts "class #{self::PATTERN}"
      # puts " PATTERN #{self::PATTERN} LENGTH #{self::LENGTH}"
      [value].pack(self::PATTERN)
    end
  end

  class Byte < SimaticSimpleType
    LENGTH = 1
    PATTERN = 'C'
  end

  class Word < SimaticSimpleType
    LENGTH = 2
    PATTERN = 'S>'
  end

  class Dword < SimaticSimpleType
    LENGTH = 4
    PATTERN = 'L>'
  end

  class Int < SimaticSimpleType
    LENGTH = 2
    PATTERN = 's>'
  end

  class Dint < SimaticSimpleType
    LENGTH = 4
    PATTERN = 'l>'
  end

  class Real < SimaticSimpleType
    LENGTH = 4
    PATTERN = 'g'
  end

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

  class IECTime < Dword
    def self.parse_one raw_value
      super / 1000.0 # seconds
    end

    def self.serialize value
      raise "Value must be numeric in seconds" unless value.kind_of? Numeric
      super (value * 1000.0).to_i # convert to milliseconds and write
    end
  end

  class IECDate < Word
    LENGTH = 2
    def self.parse_one raw_value
      days = super # days since 1990-01-01
      Date.new(1990,1,1)+days
    end

    def self.serialize value
      raise "Value #{value} must be Date class instead of #{value.class}" unless value.kind_of? Date
      days = value - Date.new(1990,01,01)
      super days
    end
  end

  class TimeOfDay < IECTime    
  end

  class Char < SimaticSimpleType
    LENGTH = 1
    PATTERN = 'a'

    def self.serialize value
      raise "Value must be String class (value: #{value})" unless value.kind_of? String
      [value].pack(self::PATTERN)
    end
  end

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