#! /usr/bin/lua

require 'Test.Assertion'

local mp = require 'MessagePack'

local nb = tonumber(os.getenv('FUZZ_NB')) or 1000
local len = tonumber(os.getenv('FUZZ_LEN')) or 128

if nb <= 0 then
    skip_all('coverage')
else
    plan 'no_plan'
    passes()
end

local unpack = table.unpack or unpack
math.randomseed(os.time())
for _ = 1, nb do
    local t = {}
    for i = 1, len do
        t[i] = math.random(0, 255)
    end
    local data = string.char(unpack(t))
    local r, msg = pcall(mp.unpack, data)
    if r == true then
        passes()
    else
        if     not msg:match'extra bytes$'
           and not msg:match'missing bytes$'
           and not msg:match'is unimplemented$' then
            diag(table.concat(t, ' '))
            diag(msg)
            fails()
        end
    end
end

done_testing()
