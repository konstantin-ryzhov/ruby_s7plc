require 'simatic/types/simatic_type'

module Simatic
  module Types
    class SimaticSimpleType < SimaticType
      def self.parse_one raw_value
        super
        raw_value.unpack(self::PATTERN).first
      end

      def self.serialize value
        raise "Value must be numeric (value: #{value} type: #{value.class})" unless value.kind_of? Numeric

        # puts "class #{self::PATTERN}"
        # puts " PATTERN #{self::PATTERN} LENGTH #{self::LENGTH}"
        [value].pack(self::PATTERN)
      end
    end
  end
end