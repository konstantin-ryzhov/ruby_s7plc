require 'simatic/sessions/exchange_session'

module Simatic
  module Sessions
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
  end
end