# ruby_s7plc
Ruby library for Siemens Simatic S7-300 PLC data exchange.

## Quick start
```ruby
  require './simatic_plc'
  require './simatic_types'
  Simatic::Plc.exchange('192.168.0.1') do |plc|
    plc.write('db1.dbw2'=> 0xffff)
    res = plc.read('db1.dbw2')
    puts "#{res.verbal} = #{SimaticTypes::Word.parse(res.value)}"
  end
```

## Reference
### Requires
```ruby
  require './simatic_plc' # exchange classes and functions
  require './simatic_types' # convertation classes and functions
```

### Client creation
```ruby
  plc = Simatic::Plc.new('192.168.0.1')
  plc.connect
  # Add you code here
  plc.disconnect
```

Or with block:
```ruby
  Simatic::Plc.exchange('192.168.0.1') do |plc|
    # Add you code here
  end
```

You can specify rack and slot parametrs by adding a hash args to functions <new> or <exchange>, defaults rack: 0, slot: 2
```ruby
Simatic::Plc.new('192.168.0.1', rack: 0, slot: 2) ...
Simatic::Plc.exchange('192.168.0.1', rack: 0, slot: 2) do |plc| ...
```

### Exchange functions
```ruby
plc.read('db1.dbx0.0')
```
This function can understand verbal adressing in Simatic Step 7 notation, like M0.0, DB1.DBB23, C0, T1 and so on.
Result of this funtion is a MemoryMapper object that can give you ```raw_data``` and ```value``` of plc response.
After this function you should use SymaticTypes module to convert data into ruby undestandable types.
```ruby
plc.write('db1.dbw2' => 0xffff)
```
This function take a hash with verbal addresses and values to write pairs. Values can be simple types like Integer, Float, one char String, Date, Time or it can be special types of SimaticTypes Module.
```ruby
plc.write('db1.dbb18[2]'  => SimaticTypes::S5time.new(711.3))
```

### Convertation functions
```ruby
SimaticTypes::Bool   # use TrueClass, FalseClass
SimaticTypes::Byte   # use Numeric
SimaticTypes::Word   # use Numeric
SimaticTypes::Dword  # use Numeric
SimaticTypes::Int    # use Numeric
SimaticTypes::Dint   # use Numeric
SimaticTypes::Real   # use Numeric
SimaticTypes::S5time # use Numeric as a time in seconds
SimaticTypes::IECTime     # use Numeric as a time in seconds
SimaticTypes::IECDate     # use Numeric as a days
SimaticTypes::TimeOfDay   # use Numeric as a seconds from start of day 0:00 a.m.
SimaticTypes::DateAndTime # use Time
SimaticTypes::S7String    # use String with length of buffer param
```
Each of this objects take Ruby types with ```new``` method and gives you with ```parse``` method:
```ruby
SimaticTypes::S5time.new(10.2)
SimaticTypes::S5time.parse(res.raw_data)
SimaticTypes::S7String.new("hello world", 15) # 15 is a length of buffer (address for this string to read or write must be [17])
```
For special types like S5time, IECTime, IECDate, TimeOfDay, DateAndTime, S7String you should use ```raw_data``` method instead of `value`, because if you write an adress with [] notation of bytes ```value``` will return a array of chars.

## Waring
This is beta code! Do not use it in danger manufactory!

## See also
Father and oldest of all open Simatic communication libraries is Libnodave project:
  * http://libnodave.sourceforge.net/

Another interesting projects:
  * https://github.com/kprovost/libs7comm
  * https://github.com/kirilk/simatic
  * https://github.com/killnine/s7netplus
  * https://github.com/plcpeople/nodeS7