module Simatic

  BUFFER_SIZE = 1000

  FuncOpenS7Connection = 0xF0
  FuncRead = 0x04
  FuncWrite = 0x05

  AreaP = 0x80
  AreaI = 0x81
  AreaQ = 0x82
  AreaM = 0x83
  AreaDB = 0x84
  AreaC = 28
  AreaT = 29

# Parent of all communication sessions
  class Session
    @@pdu_num = 0
    @@max_pdu_length = 0x3c0

    def packet_number
      @@pdu_num = 0 if @@pdu_num >= 0xffff
      @@pdu_num += 1
    end

    def make_request payload
      [0x03, 0x00, payload.length + 4].pack('CCn') + payload
    end

    def parse_response raw_data
      # print "raw "; raw_data.bytes.each{|byte| printf "%02X ", byte}; puts ''

      @real_length = raw_data.length
      raise "empty response" if @real_length < 2

      @protocol_version = raw_data[0,2].unpack('n').first
      raise "unknown response 0x#{@protocol_version.to_s(16)}" if @protocol_version != 0x0300
      
      @lenght = raw_data[2,2].unpack('n').first
      raise "too short response" if @real_length < 4
      raise "broken response length #{@real_length}, must be #{@lenght}" if @real_length != @lenght
    end
  end

# Setup communication sessions class going to plc first of all
  class SetupSession < Session
    def initialize rack, slot, communication_type = 1
      @rack = rack
      @slot = slot
      @communication_type = communication_type
    end

    def make_request
      super [0x11, 0xe0, 0x00, 0x00,
                  0x00, 0x01, 0x00, 0xc1,
                  0x02, 0x01, 0x00, 0xc2,
                  0x02,
                  @communication_type, # 1 = PG Communication,
                                      # 2 = OP Communication,
                                      # 3 = Step7Basic Communication.
                  @rack<<4 | @slot,
                  0xc0, 0x01, 0x09].pack('C*')
    end

    def parse_response raw_data
      super
      pdu_start = raw_data[4,3].unpack('C*')
      unless [[0x11, 0xE0, 0x00], [0x11, 0xD0, 0x00]].include? pdu_start
        raise "unknown response recived on setup session with pdu start by #{pdu_start}"
      end
    end
  end

# Parent of all exchange sessions classes
  class ExchangeSession < Session
    def make_request param, data = '', udata = ''
      super [0x02, 0xf0, 0x80, # 24bit pdu_start
                  0x32, # 8bit header_start
                  0x01, # 8bit header_type
                  0x00, # 16bit
                  packet_number,    # 16bit pdu_number
                  param.length, # 16bit param_length
                  data.length,   # 16bit data_length
                  ].pack('CCCCCnnnn') + param + data
    end

    def parse_response raw_data
      super

      pdu_start = raw_data[4,3].unpack('C*')
      unless [0x02, 0xF0, 0x80] == pdu_start
        raise "unknown response recived on #{self.class} with pdu start by #{pdu_start}"
      end

      header_type  = raw_data[8,  1].unpack('C').first
      @pdu_number   = raw_data[11, 2].unpack('n').first
      param_length = raw_data[13, 2].unpack('n').first
      data_length  = raw_data[15, 2].unpack('n').first

      if (2..3).member? header_type
        udata_length = raw_data[17,2].unpack('n').first
        data_start = 19
      else
        data_start = 17
      end

      @params = raw_data[data_start,  param_length]
      @data   = raw_data[data_start + param_length,  data_length]
      @udata  = raw_data[data_start + param_length + data_length,  udata_length] if (2..3).member? header_type

      @function = @params[0,1].unpack('C').first
      @block_count = @params[1,1].unpack('C').first unless @function == FuncOpenS7Connection

      # print "params "; @params.bytes.each{|byte| printf "%02X ", byte}; puts '' if DEBUG
      # print "data "; @data.bytes.each{|byte| printf "%02X ", byte}; puts '' if DEBUG
    end
  end

# Open Communication Request->Response session class going second
  class OpenSession < ExchangeSession
    def initialize max_pdu_length = nil
      @@max_pdu_length = max_pdu_length if max_pdu_length
    end

    def make_request
      param = [FuncOpenS7Connection, 0x00, 0x00, 0x01, 0x00, 0x01, @@max_pdu_length].pack('C6n')
      super param
    end

    def parse_response raw_data
      super

      unless FuncOpenS7Connection == @function
        raise "unknown function 0x#{@function.to_s(16)} in #{self.class} response"
      end

      @@max_pdu_length = @params[6,2].unpack('n').first
    end
  end

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