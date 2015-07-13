require 'simatic/types/simatic_simple_type'

module Simatic
  module Types
    class Byte < SimaticSimpleType
      LENGTH = 1
      PATTERN = 'C'
    end
  end
end