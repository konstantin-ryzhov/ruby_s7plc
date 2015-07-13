module Simatic
  module Sessions
    # Setup communication sessions class going to plc first of all
    class SetupSession < Session
      def initialize rack, slot, communication_type = 1
        @rack = rack.to_i
        @slot = slot.to_i
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
  end
end