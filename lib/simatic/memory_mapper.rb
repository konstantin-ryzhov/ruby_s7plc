module Simatic
  class MemoryMapper
    attr_reader :verbal
    attr_reader :raw_values
    attr_accessor :raw_data

    attr_reader :length
    attr_reader :count

    attr_reader :area
    attr_reader :db
    attr_reader :address
    attr_reader :bit

    def initialize verbal, args={}
      @verbal = verbal

      parse_address @verbal
      # puts args[:value]
      self.value = args[:value] unless args[:value].nil?
    end

    def parse_address verbal = @verbal
      /^(DB\s*(?<db>\d+)(\.|\s*))?(?<area>PI|PQ|I|Q|M|DB|T|C)(?<type>X|B|W|D)?\s*?(?<adr>\d+)(\.(?<bit>\d+))?\s*?(\[(?<count>\d+)\])?$/i =~ verbal
      
      @db      = db    ? db.to_i    : 0
      @count   = count ? count.to_i : 1 
      @address = adr   ? adr.to_i   : nil
      @bit     = bit   ? bit.to_i   : nil

      unless @address
        raise "Adressing by #{verbal} is impossible. Cant parse it."
      end

      case area.upcase
      when 'PI','PQ'
        @area = AreaP
      when 'I'
        @area = AreaI
      when 'Q'
        @area = AreaQ
      when 'M'
        @area = AreaM
      when 'DB'
        @area = AreaDB
      when 'T'
        @area = AreaT
      when 'C'
        @area = AreaC
      end

      case type ? type.upcase : 'X'
      when 'B'
        @length = 1
      when 'W'
        @length = 2
      when 'D'
        @length = 4
      else
        @length = 1
        unless @bit
          raise "Adressing by #{verbal} is impossible. Cant parse it. Is bit expected?"
        end
      end
    end

    def value= new_value
      val_array = (new_value.kind_of? Array) ? new_value : [new_value]

      @raw_values = []
      val_array.each do |v|

        val = case v
          when Simatic::Types::SimaticType
            v
          when Integer
            case @length
            when 1
              Simatic::Types::Byte.new(v)
            when 2
              Simatic::Types::Int.new(v)
            when 4
              Simatic::Types::Dint.new(v)
            else
              raise "Cannot convert #{v.class} to SimaticType class"
            end
          when Float
            Simatic::Types::Real.new(v)
          when TrueClass, FalseClass
            Simatic::Types::Bool.new(v)
          when String
            raise "Cannot write string to plc use SimaticType::S7String class" if length > 1
            Simatic::Types::Char.new(v) if v.length == 1
          when Date
            Simatic::Types::IECDate.new(v)
          when Time
            Simatic::Types::DateAndTime.new(v)
          else
            raise "Unknoun type of write value <#{v.class}> #{v}"
        end

        @raw_values << val.serialize
      end

      @raw_data = @raw_values.inject { |sum, v| sum+v }

      if @raw_data.length != @length*@count
        raise "This values #{val_array} can not be writed because adress #{verbal} mean #{@length*@count} byte(s) instead #{@raw_data.length}"
      end
    end

    def value
      @raw_values = []

      byte = 0
      while byte < @count*@length
        @raw_values << @raw_data[byte, @length]
        byte += @length
      end

      result = @raw_values

      # .map do |raw|

      #   case type
      #   when :bool

      #     bit = @bit ? 0 : (args[:bit] || nil)

      #     binary_string = raw.unpack('b*').first

      #     if bit
      #       binary_string[bit] == '1' ? true : false
      #     else
      #       binary_string.index('1') ? true : false
      #     end

      #   when :int8
      #     raw.unpack('c').first
      #   when :uint8
      #     raw.unpack('C').first
      #   when :int16
      #     raw.unpack('s>').first
      #   when :uint16
      #     raw.unpack('S>').first # try n
      #   when :int32
      #     raw.unpack('l>').first
      #   when :uint32
      #     raw.unpack('L>').first # try N
      #   when :float32
      #     raw.unpack('g').first
      #   when :float64
      #     raw.unpack('G').first
      #   when :text8
      #     raw.unpack('A*').first
      #   when :text16
      #     raw.unpack('u*').first
      #   else
      #     raw
      #   end
      # end

      result = result.first if result.count == 1
      result
    end

    def as_bool raw
    end

    def as_int raw
    end

    def as_uint raw
    end

    def as_real raw_data
    end

    def as_s5time raw_data
    end

    def as_time raw_data
    end

    def as_date raw_data
    end

    def as_string raw_data
    end
  end
end