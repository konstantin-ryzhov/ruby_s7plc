require 'simatic/types/simatic_simple_type'

module Simatic
  module Types
    class Dword < SimaticSimpleType
      LENGTH = 4
      PATTERN = 'L>'
    end
  end
end