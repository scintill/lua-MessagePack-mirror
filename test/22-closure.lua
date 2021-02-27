#! /usr/bin/lua

require 'Test.Assertion'

plan(5)

local mp = require 'MessagePack'
mp.packers['function'] = function (buffer, fct)
    fct(buffer)
end

local function BINARY (str)
    return function (buffer)
        mp.packers['binary'](buffer, str)
    end
end

local function FLOAT (n)
    return function (buffer)
        mp.packers['float'](buffer, n)
    end
end

equals( mp.pack('STR'):byte(), 0xA0 + 3, "fixstr" )
equals( mp.pack(BINARY'STR'):byte(), 0xC4, "bin8" )

equals( mp.pack(42):byte(), 42, "fixnum" )
equals( mp.pack(FLOAT(42)):byte(), 0xCA, "float" )

local t = { 'encoded_with_global_settings', BINARY'encoded_as_binary', 42, FLOAT(42) }
local mpac = mp.pack(t)
array_equals( mp.unpack(mpac), { 'encoded_with_global_settings', 'encoded_as_binary', 42, 42 }, "in a table" )
