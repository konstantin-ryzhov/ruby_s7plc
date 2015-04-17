require 'date'
require './simatic_plc'
require './simatic_types'

# avaleable types 
#   :int8
#   :bool
#   :uint8
#   :int16
#   :uint16
#   :int32
#   :uint32
#   :float32
#   :float64
#   :text8
#   :text16

# visit2 '10.170.1.144'
# Simatic::Plc.exchange('192.168.0.1') do |plc|
  # result = plc.read('db60.DBX30.6', 'MB1').each do |result|
  #   puts '-'*80
  #   puts "#{result.verbal} value #{result.value(:uint8).to_s(2)} #{result.value(:bool)}"
  # end
  # plc.write 'DB1.DBD2' => 6.5
# end

plc = Simatic::Plc.new('192.168.0.1')
plc.connect

# plc.write('db1.dbx0.0'    => true ) # bool
# plc.write('db1.dbb1'      => 5) # byte (usigned int 8)
# plc.write('db1.dbw2'      => 0xffff) # word (usigned int 16)
# plc.write('db1.dbd4'      => 0xffffffff) # dword (usigned dint 32)
# plc.write('db1.dbw8'      => -958) # int
# plc.write('db1.dbd10'     => rand(568652)) # dint
# plc.write('db1.dbd14'     => 458.586) # real
# plc.write('db1.dbb18[2]'  => SimaticTypes::S5time.new(711.3)) # s5time
# plc.write('db1.dbb20[4]'  => SimaticTypes::IECTime.new(3600)) # time
# plc.write('db1.dbb24[2]'  => Date.today) # date
# plc.write('db1.dbb26[4]'  => SimaticTypes::TimeOfDay.new(17*3600)) # time_of_day
# plc.write('db1.dbb30[1]'  => 'g') # char
# plc.write('db1.dbb32[8]'  => Time.now) # date_and_time
# plc.write('db1.dbb40[17]' => SimaticTypes::S7String.new('-5585654685465261683165123', 15)) # string

plc.write('db1.dbb72[30]' => [
  SimaticTypes::S7String.new('34', 3),
  SimaticTypes::S7String.new('90', 3),
  SimaticTypes::S7String.new('91', 3),
  SimaticTypes::S7String.new('92', 3),
  SimaticTypes::S7String.new('93', 3)
]) # array

# res = plc.read('db1.dbx0.0');    puts "#{res.verbal} = #{SimaticTypes::Bool.parse(res.value)}"
# res = plc.read('db1.dbb1');      puts "#{res.verbal} = #{SimaticTypes::Byte.parse(res.value)}"
# res = plc.read('db1.dbw2');      puts "#{res.verbal} = #{SimaticTypes::Word.parse(res.value)}"
# res = plc.read('db1.dbd4');      puts "#{res.verbal} = #{SimaticTypes::Dword.parse(res.value)}"
# res = plc.read('db1.dbw8');      puts "#{res.verbal} = #{SimaticTypes::Int.parse(res.value)}"
# res = plc.read('db1.dbd10');     puts "#{res.verbal} = #{SimaticTypes::Dint.parse(res.value)}"
# res = plc.read('db1.dbd14');     puts "#{res.verbal} = #{SimaticTypes::Real.parse(res.value)}"
# res = plc.read('db1.dbb18[2]');     puts "#{res.verbal} = #{SimaticTypes::S5time.parse(res.raw_data)}"
# res = plc.read('db1.dbb20[4]');     puts "#{res.verbal} = #{SimaticTypes::IECTime.parse(res.raw_data)}"
# res = plc.read('db1.dbb24[2]');     puts "#{res.verbal} = #{SimaticTypes::IECDate.parse(res.raw_data)}"
# res = plc.read('db1.dbb26[4]');     puts "#{res.verbal} = #{SimaticTypes::TimeOfDay.parse(res.raw_data)}"
# res = plc.read('db1.dbb30[1]');     puts "#{res.verbal} = #{SimaticTypes::Char.parse(res.raw_data)}"
# res = plc.read('db1.dbb32[8]');  puts "#{res.verbal} = #{SimaticTypes::DateAndTime.parse(res.raw_data)}"
# res = plc.read('db1.dbb40[17]'); puts "#{res.verbal} = #{SimaticTypes::S7String.parse(res.raw_data)}"

res = plc.read('db1.dbb72[5]'); puts "#{res.verbal} = #{SimaticTypes::S7String.parse(res.raw_data)}" # array
res = plc.read('db1.dbb78[5]'); puts "#{res.verbal} = #{SimaticTypes::S7String.parse(res.raw_data)}"
res = plc.read('db1.dbb84[5]'); puts "#{res.verbal} = #{SimaticTypes::S7String.parse(res.raw_data)}"
res = plc.read('db1.dbb90[5]'); puts "#{res.verbal} = #{SimaticTypes::S7String.parse(res.raw_data)}"
res = plc.read('db1.dbb96[5]'); puts "#{res.verbal} = #{SimaticTypes::S7String.parse(res.raw_data)}"