require 'simatic/types/simatic_simple_type'

module Simatic
  module Types
    class Char < SimaticSimpleType
      LENGTH = 1
      PATTERN = 'a'

      def self.serialize value
        raise "Value must be String class (value: #{value})" unless value.kind_of? String
        [value].pack(self::PATTERN)
      end
    end
  end
end