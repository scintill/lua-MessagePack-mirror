#! /usr/bin/lua

require 'Test.Assertion'

plan(8)

if not require_ok 'MessagePack' then
    BAIL_OUT "no lib"
end

local m = require 'MessagePack'
is_table( m )
matches( m._COPYRIGHT, 'Perrad', "_COPYRIGHT" )
matches( m._DESCRIPTION, 'MessagePack', "_DESCRIPTION" )
matches( m._VERSION, '^%d%.%d%.%d$', "_VERSION" )

is_table( m.packers, "table packers" )
is_function( m.unpack_cursor, "function unpack_cursor" )
is_function( m.build_ext, "function build_ext" )

if m.full64bits then
    diag "full 64bits with Lua 5.3"
end
