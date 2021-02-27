#! /usr/bin/lua

require 'Test.Assertion'

plan(5)

local mp1 = require 'MessagePack'
package.loaded['MessagePack'] = nil     -- hack here
local mp2 = require 'MessagePack'

not_equals( mp1, mp2 )

mp1.set_array'without_hole'
mp2.set_array'always_as_map'

local t = { 10, 20, nil, 40 }
equals( mp1.pack(t):byte(), 0x80 + 3, "array with hole as map" )
same( mp1.unpack(mp1.pack(t)), t )

equals( mp2.pack(t):byte(), 0x80 + 3, "always_as_map" )
same( mp2.unpack(mp2.pack(t)), t )

