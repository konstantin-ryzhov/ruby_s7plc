require 'simatic/types/simatic_type'

module Simatic
  module Types
    class Bool < SimaticType
      LENGTH = 1

      def self.parse_one raw_data
        super
        raw_data.unpack('b*').first.index('1') ? true : false
      end

      def self.serialize value
        [value ? 1 : 0].pack('c')
      end
    end
  end
end