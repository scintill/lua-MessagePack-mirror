#! /usr/bin/lua

require 'Test.Assertion'

if not pcall(require, 'bc') then
    skip_all 'no bc'
end

plan(3)

local mp = require 'MessagePack'
local bc = require 'bc'
local EXT_BC = 42
bc.digits(65)
local number = bc.number or bc.new

mp.packers['userdata'] = function (buffer, u)
    if getmetatable(u) == bc then
        mp.packers['ext'](buffer, EXT_BC, tostring(u))
    else
        error("pack 'userdata' is unimplemented")
    end
end

mp.build_ext = function (tag, data)
    if tag == EXT_BC then
        return number(data)
    end
end

local orig = bc.sqrt(2)
local dest = mp.unpack(mp.pack(orig))
equals( dest, orig, "bc" )
falsy( rawequal(orig, dest) )

error_matches( function ()
                mp.pack( io.stdin )
        end,
        "pack 'userdata' is unimplemented" )

