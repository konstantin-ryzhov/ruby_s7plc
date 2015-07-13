require 'simatic/types/bool'
require 'simatic/types/byte'
require 'simatic/types/char'
require 'simatic/types/date_and_time'
require 'simatic/types/dint'
require 'simatic/types/dword'
require 'simatic/types/iec_date'
require 'simatic/types/iec_time'
require 'simatic/types/int'
require 'simatic/types/real'
require 'simatic/types/s5_time'
require 'simatic/types/s7_string'
require 'simatic/types/time_of_day'
require 'simatic/types/word'

module Simatic
  module Types
    def self.avaliable
      [:bool,
      :byte,
      :char,
      :date_and_time,
      :dint,
      :dword,
      :iec_date,
      :iec_time,
      :int,
      :real,
      :s5_time,
      :s7_string,
      :time_of_day,
      :word]
    end

    def self.parse raw, type
      parser = case type.to_sym
      when :bool
        Bool
      when :byte
        Byte
      when :char
        Char
      when :date_and_time
        DateAndTime
      when :dint
        Dint
      when :dword
        Dword
      when :iec_date
        IECDate
      when :iec_time
        IECTime
      when :int
        Int
      when :real
        Real
      when :s5_time
        S5Time
      when :s7_string
        S7String
      when :time_of_day
        TimeOfDay
      when :word 
        Word
      else
        nil
      end
      
      raise "Unknown type #{type}" if parser.nil?
      parser.parse raw if parser
    end

    def self.get value, type
      raw = nil
      parser = case type.to_sym
      when :bool
        if value.kind_of? String
          if value == '0'
            raw = false
          elsif value.downcase == 'false'
            raw = false
          else
            raw = value.to_i rescue value
          end
        end
        Bool
      when :byte
        raw = value.to_i if value.kind_of? String
        Byte
      when :char
        Char
      when :date_and_time
        raw = Time.parse value if value.kind_of? String
        DateAndTime
      when :dint
        raw = value.to_i if value.kind_of? String
        Dint
      when :dword
        raw = value.to_i if value.kind_of? String
        Dword
      when :iec_date
        raw = Date.parse value if value.kind_of? String
        IECDate
      when :iec_time
        raw = value.to_f if value.kind_of? String
        IECTime
      when :int
        raw = value.to_i if value.kind_of? String
        Int
      when :real
        raw = value.to_f if value.kind_of? String
        Real
      when :s5_time
        raw = value.to_f if value.kind_of? String
        S5Time
      when :s7_string
        S7String
      when :time_of_day
        raw = value.to_f if value.kind_of? String
        TimeOfDay
      when :word
        raw = value.to_i if value.kind_of? String 
        Word
      when :auto
        return value
      else
        nil
      end
      
      raise "Unknown type #{type}" if parser.nil?
      parser.new(raw) if parser
    end
  end
end