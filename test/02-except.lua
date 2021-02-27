#! /usr/bin/lua

require 'Test.Assertion'

plan(24)

local mp = require 'MessagePack'

error_matches( function ()
                mp.pack( print )
        end,
        "pack 'function' is unimplemented" )

error_matches( function ()
                mp.pack( coroutine.create(plan) )
        end,
        "pack 'thread' is unimplemented" )

error_matches( function ()
                mp.pack( io.stdin )
        end,
        "pack 'userdata' is unimplemented" )

error_matches( function ()
                local a = {}
                a.foo = a
                mp.pack( a )
        end,
        "stack overflow",   -- from Lua interpreter
        "direct cycle" )

error_matches( function ()
                local a = {}
                local b = {}
                a.foo = b
                b.foo = a
                mp.pack( a )
        end,
        "stack overflow",   -- from Lua interpreter
        "indirect cycle" )

error_matches( function ()
                mp.unpack(string.char(0xC1))
        end,
        "unpack '0xc1' is unimplemented" )

equals( mp.unpack(mp.pack("text")), "text" )

error_matches( function ()
                mp.unpack(mp.pack("text"):sub(1, -2))
        end,
        "missing bytes" )

error_matches( function ()
                mp.unpack(mp.pack("text") .. "more")
        end,
        "extra bytes" )

error_matches( function ()
                mp.unpack(mp.pack("text") .. "1")
        end,
        "extra bytes" )

error_matches( function ()
                mp.unpack( {} )
        end,
        "bad argument #1 to unpack %(string expected, got table%)" )

error_matches( function ()
                mp.unpacker( false )
        end,
        "bad argument #1 to unpacker %(string or function expected, got boolean%)" )

error_matches( function ()
                mp.unpacker( {} )
        end,
        "bad argument #1 to unpacker %(string or function expected, got table%)" )

for _, val in mp.unpacker(string.rep(mp.pack("text"), 2)) do
    equals( val, "text" )
end

error_matches( function ()
                for _, val in mp.unpacker(string.rep(mp.pack("text"), 2):sub(1, -2)) do
                    equals( val, "text" )
                end
        end,
        "missing bytes" )

error_matches( function ()
                mp.set_string'bad'
        end,
        "bad argument #1 to set_string %(invalid option 'bad'%)" )

error_matches( function ()
                mp.set_number'bad'
        end,
        "bad argument #1 to set_number %(invalid option 'bad'%)" )

error_matches( function ()
                mp.set_integer'bad'
        end,
        "bad argument #1 to set_integer %(invalid option 'bad'%)" )

error_matches( function ()
                mp.set_array'bad'
        end,
        "bad argument #1 to set_array %(invalid option 'bad'%)" )

error_matches( function ()
                mp.packers['fixext4'](nil, 1, '123')
        end,
        "bad length for fixext4" )

not_errors( function ()
                mp.packers['fixext4']({}, 1, '1234')
        end,
        "fixext4" )

not_errors( function ()
                for _ in ipairs(mp.packers) do end
        end,
        "cannot iterate packers" )
