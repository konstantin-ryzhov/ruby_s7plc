require 'simatic/sessions/session'

module Simatic
  module Sessions
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
  end
end