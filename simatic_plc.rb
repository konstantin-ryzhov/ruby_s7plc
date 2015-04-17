require 'socket'
require './simatic_protocol'
require './simatic_memory'

module Simatic
  class Plc
    def initialize address, args = {}
      @address = address
      @rack = args[:rack] || 0
      @slot = args[:slot] || 2 
    end

    def self.exchange address, args = {}
      plc = self.new address, args

      plc.connect
      yield plc
      plc.disconnect
    end

    def read *args
      if @socket.nil?
        raise "Plc #{@address} is not connected"
      end

      read = ReadSession.new
      memory_mappers = []
      args.each do |verbal|
        memory_mappers << MemoryMapper.new(verbal)
      end

      request = read.make_request memory_mappers
      @socket.send request, 0

      # debug_print request

      response =  @socket.recv BUFFER_SIZE

      # debug_print response

      result = read.parse_response response

      # Hash[result.map { |memory_mapper| [memory.verbal, memory.value] }]
    end

    def write args
      if @socket.nil?
        raise "Plc #{@address} is not connected"
      end

      memory_mappers = []
      args.each do |verbal, value|
        memory_mappers << MemoryMapper.new(verbal, value: value)
      end

      write = WriteSession.new
      request = write.make_request memory_mappers
      @socket.send request, 0

      # debug_print request

      response =  @socket.recv BUFFER_SIZE

      # debug_print response

      result = write.parse_response response
    end
    
    def connect
      @socket = TCPSocket.new @address, 102

      setup = SetupSession.new @rack, @slot
      @socket.send setup.make_request, 0
      setup.parse_response @socket.recv BUFFER_SIZE

      open = OpenSession.new
      @socket.send open.make_request, 0
      open.parse_response @socket.recv BUFFER_SIZE

    end

    def disconnect
      @socket.close
    end

    private

    def debug_print raw
      puts '-'*80
      raw.bytes.each_with_index do |byte, i|
        ends = (i+1)%16 == 0 ? "\n" : ' '
        printf '%02X '+ ends, byte
      end
      puts ''
      puts '-'*80
    end
  end
end