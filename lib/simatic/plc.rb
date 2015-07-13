require 'socket'
require 'simatic/sessions'
require 'simatic/memory_mapper'

module Simatic
  BUFFER_SIZE = 1000

  class Plc
    def initialize address, args = {}
      @address = address
      @rack = args[:rack] || 0
      @slot = args[:slot] || 2 
    end

    def self.exchange address, args = {}, timeout = 500
      plc = self.new address, args

      plc.connect timeout
      yield plc
      plc.disconnect
    end

    def read *args
      if @socket.nil?
        raise "Plc #{@address} is not connected"
      end

      read = Sessions::ReadSession.new
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

      write = Sessions::WriteSession.new
      request = write.make_request memory_mappers
      @socket.send request, 0

      # debug_print request

      response =  @socket.recv BUFFER_SIZE

      # debug_print response

      result = write.parse_response response
    end
    
    def connect timeout = 500
      @socket = Socket.tcp @address, 102, connect_timeout: timeout / 1000.0

      setup = Sessions::SetupSession.new @rack, @slot
      @socket.send setup.make_request, 0
      setup.parse_response @socket.recv BUFFER_SIZE

      open = Sessions::OpenSession.new
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