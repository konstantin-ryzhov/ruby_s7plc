module Simatic
  AreaP = 0x80
  AreaI = 0x81
  AreaQ = 0x82
  AreaM = 0x83
  AreaDB = 0x84
  AreaC = 28
  AreaT = 29
        
  module Sessions
    FuncOpenS7Connection = 0xF0
    FuncRead = 0x04
    FuncWrite = 0x05

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
  end
end