require 'simatic/types/simatic_simple_type'

module Simatic
  module Types
    class Real < SimaticSimpleType
      LENGTH = 4
      PATTERN = 'g'
    end
  end
end