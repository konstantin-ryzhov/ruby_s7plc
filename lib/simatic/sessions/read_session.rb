require 'simatic/sessions/exchange_session'

module Simatic
  module Sessions
    # Read communication session
    class ReadSession < ExchangeSession
      def initialize
        @read_memory = []
      end

      # def add memory
      #   @read_memory << memory if memory.instance_of? MemoryMapper
      # end

      def make_request memory_mappers
        @memory_mappers = memory_mappers
        param = [ FuncRead, # 8bit function
                  @memory_mappers.count, # count of read-requests
                ].pack('C2')

        @memory_mappers.each do |memory_mapper|
          param += read_request memory_mapper
        end

        super param
      end

      def parse_response raw_data
        super raw_data

        unless FuncRead == @function
          raise "unknown function 0x#{@function.to_s(16)} in #{self.class} response"
        end

        start_byte = 0
        data_block_number = 0
        while start_byte < @data.length

          unless @data[start_byte, 1].unpack('C').first == 0xff || @data[start_byte+=1, 1].unpack('C').first == 0xff  
            raise "one of data block is broken in #{self.class} response"
          end

          data_lenght_type = @data[start_byte+1,1].unpack('C').first # 4 - bits,
                                                                     # 9 - bytes,
                                                                     # 3 - bits + byte
          data_lenght_raw = @data[start_byte+2,2].unpack('n').first

          data_lenght = data_lenght_raw
          data_lenght = data_lenght_raw / 8 if data_lenght_type == 4

          @memory_mappers[data_block_number].raw_data = @data[start_byte + 4, data_lenght]

          start_byte += 4 + data_lenght
          data_block_number += 1
        end

        @memory_mappers = @memory_mappers.first if @memory_mappers.count == 1
        @memory_mappers
      end

      private

      def read_request memory_mapper
        # puts "@area #{@area}, @length #{@length}, @db #{@db}, @address #{@address}"

        read_size = memory_mapper.bit ? 0x01 : 0x02 # 8bit read size:
                                       #   1 = single bit,
                                       #   2 = byte,
                                       #   4 = word.

        read_size = memory_mapper.area if [AreaT, AreaC].include? memory_mapper.area

        [0x12, 0x0a, 0x10, #read-request start
                 read_size, 
                 memory_mapper.length * memory_mapper.count, # 16bit lenght in bits, bytes, words
                 memory_mapper.db || 0, # 16bit db number
                 memory_mapper.area, # 8bit # area 
                 ].pack('C4nnC') + [ memory_mapper.address * 8 + (memory_mapper.bit || 0) # 24bit start adress in bits
                 ].pack('N')[1,3]
      end
    end
  end
end