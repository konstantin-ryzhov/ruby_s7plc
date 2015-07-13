require 'simatic/types/dword'

module Simatic
  module Types
    class IECTime < Dword
      def self.parse_one raw_value
        super / 1000.0 # seconds
      end

      def self.serialize value
        raise "Value must be numeric in seconds" unless value.kind_of? Numeric
        super (value * 1000.0).to_i # convert to milliseconds and write
      end
    end
  end
end