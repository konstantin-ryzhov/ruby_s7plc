require 'simatic/types/simatic_simple_type'

module Simatic
  module Types
    class Word < SimaticSimpleType
      LENGTH = 2
      PATTERN = 'S>'
    end
  end
end