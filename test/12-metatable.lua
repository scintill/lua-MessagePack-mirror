#! /usr/bin/lua

require 'Test.Assertion'

plan(6)

local mp = require 'MessagePack'

local EXT_METATABLE = 42

mp.packers['table'] = function (buffer, t)
    local mt = getmetatable(t)
    if mt then
        local buf = {}
        mp.packers['_table'](buf, t)
        mp.packers['table'](buf, mt)
        mp.packers['ext'](buffer, EXT_METATABLE, table.concat(buf))
    else
        mp.packers['_table'](buffer, t)
    end
end

mp.build_ext = function (tag, data)
    if tag == EXT_METATABLE then
        local f = mp.unpacker(data)
        local _, t = f()
        local _, mt = f()
        return setmetatable(t, mt)
    end
end

local t = setmetatable( { 'a', 'b', 'c' }, { __index = { [4] = 'd' } } )
equals( t[4], 'd' )
t = mp.unpack(mp.pack(t))
equals( t[2], 'b' )
equals( t[4], 'd', "follow metatable"  )

t = setmetatable( { a = 1, b = 2, c = 3 }, { __index = { d = 4 } } )
equals( t.d, 4 )
t = mp.unpack(mp.pack(t))
equals( t.b, 2 )
equals( t.d, 4, "follow metatable" )

