require 'simatic/sessions/exchange_session'

module Simatic
  module Sessions
    # Write communication session
    class WriteSession < ExchangeSession

      def make_request memory_mappers
        @memory_mappers = memory_mappers

        param = [ FuncWrite, # 8bit function
                  @memory_mappers.count, # count of read-requests
                ].pack('C2')

        data = ''

        @memory_mappers.each do |memory_mapper|
          param += write_request_param memory_mapper
          data += write_request_data memory_mapper
        end


        super param, data
      end

      def parse_response raw_data
        super raw_data

        unless FuncWrite == @function
          raise "unknown function 0x#{@function.to_s(16)} in #{self.class} response"
        end

        result_code = @data[0,1].unpack('C').first

        case result_code
        when 0xff
          result_code
        when 0x0A
          raise "Item not available, code #{result_code}" # for s7 300
        when 0x03
          raise "Item not available, code #{result_code}" # for s7 200
        when 0x05
          raise "Address out of range, code #{result_code}"
        when 0x07
          raise "Write data size mismatch, code #{result_code}"
        else
          raise "Unknown error, code #{result_code}"
        end
      end

      private

      def write_request_param memory_mapper
        read_size = memory_mapper.bit ? 0x01 : 0x02 #memory_mapper.bit ? 0x01 : 0x02 # 8bit read size:
                                       #   1 = single bit,
                                       #   2 = byte,
                                       #   4 = word.
        read_size = memory_mapper.area if [AreaT, AreaC].include? memory_mapper.area

        [0x12, 0x0a, 0x10, #read-request start
                 read_size, 
                 memory_mapper.length * memory_mapper.count, # 16bit lenght in bits, bytes, words
                 memory_mapper.db, # 16bit db number
                 memory_mapper.area, # 8bit # area 
                 ].pack('C4nnC') + [ memory_mapper.address * 8 + (memory_mapper.bit || 0) # 24bit start adress in bits
                 ].pack('N')[1,3]
      end

      def write_request_data memory_mapper
        [ 0x09,
          memory_mapper.bit ? 0x03 : 0x04,  # 4 - bits,
                                            # 9 - bytes,
                                            # 3 - bits + byte
          memory_mapper.raw_data.length*(memory_mapper.bit ? memory_mapper.count : 8),

        ].pack('CCn') + memory_mapper.raw_data
      end
    end
  end
end