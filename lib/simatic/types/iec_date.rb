require 'date'
require 'simatic/types/word'

module Simatic
  module Types
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
  end
end