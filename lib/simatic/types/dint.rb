require 'simatic/types/simatic_type'

module Simatic
  module Types
    class Dint < SimaticSimpleType
      LENGTH = 4
      PATTERN = 'l>'
    end
  end
end