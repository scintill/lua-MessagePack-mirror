#! /usr/bin/lua

require 'Test.Assertion'

plan(42)

local mp = require 'MessagePack'

equals( mp.unpack(mp.pack(1.0/0.0)), 1.0/0.0, "inf" )

equals( mp.unpack(mp.pack(-1.0/0.0)), -1.0/0.0, "-inf" )

local nan = mp.unpack(mp.pack(0.0/0.0))
is_number( nan, "nan" )
truthy( nan ~= nan )

equals( mp.pack{}:byte(), 0x90, "empty table as array" )

local t = setmetatable( { 'a', 'b', 'c' }, { __index = { [4] = 'd' } } )
equals( t[4], 'd' )
t = mp.unpack(mp.pack(t))
equals( t[2], 'b' )
equals( t[4], nil, "don't follow metatable" )

t = setmetatable( { a = 1, b = 2, c = 3 }, { __index = { d = 4 } } )
equals( t.d, 4 )
t = mp.unpack(mp.pack(t))
equals( t.b, 2 )
equals( t.d, nil, "don't follow metatable" )

t = { 10, 20, nil, 40 }
mp.set_array'without_hole'
equals( mp.pack(t):byte(), 0x80 + 3, "array with hole as map" )
same( mp.unpack(mp.pack(t)), t )
mp.set_array'with_hole'
equals( mp.pack(t):byte(), 0x90 + 4, "array with hole as array" )
same( mp.unpack(mp.pack(t)), t )
mp.set_array'always_as_map'
equals( mp.pack(t):byte(), 0x80 + 3, "always_as_map" )
same( mp.unpack(mp.pack(t)), t )

t = {}
mp.set_array'without_hole'
equals( mp.pack(t):byte(), 0x90, "empty table as array" )
mp.set_array'with_hole'
equals( mp.pack(t):byte(), 0x90, "empty table as array" )
mp.set_array'always_as_map'
equals( mp.pack(t):byte(), 0x80, "empty table as map" )

mp.set_number'float'
not_errors( function ()
              mp.pack(1.5000001)
        end,
        "float 1.5000001" )
equals( mp.pack(3.402824e+38), mp.pack(1.0/0.0), "float 3.402824e+38")
equals( mp.pack(7e42), mp.pack(1.0/0.0), "inf (downcast double -> float)")
equals( mp.pack(-7e42), mp.pack(-1.0/0.0), "-inf (downcast double -> float)")
equals( mp.unpack(mp.pack(7e42)), 1.0/0.0, "inf (downcast double -> float)")
equals( mp.unpack(mp.pack(-7e42)), -1.0/0.0, "-inf (downcast double -> float)")
equals( mp.unpack(mp.pack(7e-46)), 0.0, "epsilon (downcast double -> float)")
equals( mp.unpack(mp.pack(-7e-46)), -0.0, "-epsilon (downcast double -> float)")

if mp.long_double then
    mp.set_number'double'
    equals( mp.pack(7e400), mp.pack(1.0/0.0), "inf (downcast long double -> double)")
    equals( mp.pack(-7e400), mp.pack(-1.0/0.0), "-inf (downcast long double -> double)")
    equals( mp.unpack(mp.pack(7e400)), 1.0/0.0, "inf (downcast long double -> double)")
    equals( mp.unpack(mp.pack(-7e400)), -1.0/0.0, "-inf (downcast long double -> double)")
    equals( mp.unpack(mp.pack(7e-400)), 0.0, "epsilon (downcast long double -> double)")
    equals( mp.unpack(mp.pack(-7e-400)), -0.0, "-epsilon (downcast long double -> double)")
else
    skip("no long double", 6)
end

mp.set_integer'unsigned'
equals( mp.unpack(mp.pack(0xF0)), 0xF0, "packint 0xF0")
equals( mp.unpack(mp.pack(0xF000)), 0xF000, "packint 0xF000")
equals( mp.unpack(mp.pack(0xF0000000)), 0xF0000000, "packint 0xF0000000")

local buffer = {}
mp.packers.float(buffer, 0)
equals( mp.unpack(table.concat(buffer)), 0)
if mp.small_lua then
    skip("Small Lua (32 bits)", 1)
else
    buffer = {}
    mp.packers.double(buffer, 0)
    equals( mp.unpack(table.concat(buffer)), 0)
end

local mpac = string.char(0x82, 0xC0, 0x01, 0xA2, 0x69, 0x64, 0x02)
t = mp.unpack(mpac)
equals( t.id, 2, "unpack map with nil as table index" )

mp.sentinel = {}
t = mp.unpack(mpac)
equals( t[mp.sentinel], 1, "unpack using a sentinel for nil as table index" )
equals( t.id, 2 )
