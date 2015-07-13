require 'simatic/types/simatic_simple_type'

module Simatic
  module Types
    class Int < SimaticSimpleType
      LENGTH = 2
      PATTERN = 's>'
    end
  end
end