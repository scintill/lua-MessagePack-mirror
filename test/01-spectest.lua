#! /usr/bin/lua

local unpack = table.unpack or unpack

require 'Test.Assertion'

local mp = require 'MessagePack'

local data = {
    false,              "false",
    true,               "true",
    nil,                "nil",
    0,                  "0 Positive FixNum",
    0,                  "0 uint8",
    0,                  "0 uint16",
    0,                  "0 uint32",
    0,                  "0 int8",
    0,                  "0 int16",
    0,                  "0 int32",
    -1,                 "-1 Negative FixNum",
    -1,                 "-1 int8",
    -1,                 "-1 int16",
    -1,                 "-1 int32",
    127,                "127 Positive FixNum",
    127,                "127 uint8",
    255,                "255 uint16",
    65535,              "65535 uint32",
    -32,                "-32 Negative FixNum",
    -32,                "-32 int8",
    -128,               "-128 int16",
    -32768,             "-32768 int32",
    0.0,                "0.0 float",
    -0.0,               "-0.0 float",
    "a",                "\"a\" FixStr",
    "a",                "\"a\" str 8",
    "a",                "\"a\" str 16",
    "a",                "\"a\" str 32",
    "",                 "\"\" FixStr",
    "",                 "\"\" str 8",
    "",                 "\"\" str 16",
    "",                 "\"\" str 32",
    "a",                "\"a\" bin 8",
    "a",                "\"a\" bin 16",
    "a",                "\"a\" bin 32",
    "",                 "\"\" bin 8",
    "",                 "\"\" bin 16",
    "",                 "\"\" bin 32",
    { 0 },              "[0] FixArray",
    { 0 },              "[0] array 16",
    { 0 },              "[0] array 32",
    {},                 "[] FixArray",
    {},                 "[] array 16",
    {},                 "[] array 32",
    {},                 "{} FixMap",
    {},                 "{} map 16",
    {},                 "{} map 32",
    { a=97 },           "{\"a\"=>97} FixMap",
    { a=97},            "{\"a\"=>97} map 16",
    { a=97 },           "{\"a\"=>97} map 32",
    { {} },             "[[]]",
    { {"a"} },          "[[\"a\"]]",

    nil,                "fixext 1",
    nil,                "fixext 2",
    nil,                "fixext 4",
    nil,                "fixext 8",
    nil,                "fixext 16",
    nil,                "ext 8",
    nil,                "ext 16",
    nil,                "ext 32",
}
if not mp.small_lua then
    for i, v in ipairs({
    0,                  "0 uint64",
    0,                  "0 int64",
    -1,                 "-1 int64",
    4294967295,         "4294967295 uint64",
    -2147483648,        "-2147483648 int64",
    0.0,                "0.0 double",
    -0.0,               "-0.0 double",
    1.0,                "1.0 double",
    -1.0,               "-1.0 double",
}) do
        data[60*2+i] = v
    end
end

plan(9 * (mp.small_lua and 60 or 69))

-- see https://github.com/msgpack/msgpack/blob/master/test/cases_gen.rb
local source = [===[
c2                              # false
c3                              # true
c0                              # nil
00                              # 0 Positive FixNum
cc 00                           # 0 uint8
cd 00 00                        # 0 uint16
ce 00 00 00 00                  # 0 uint32
d0 00                           # 0 int8
d1 00 00                        # 0 int16
d2 00 00 00 00                  # 0 int32
ff                              # -1 Negative FixNum
d0 ff                           # -1 int8
d1 ff ff                        # -1 int16
d2 ff ff ff ff                  # -1 int32
7f                              # 127 Positive FixNum
cc 7f                           # 127 uint8
cd 00 ff                        # 255 uint16
ce 00 00 ff ff                  # 65535 uint32
e0                              # -32 Negative FixNum
d0 e0                           # -32 int8
d1 ff 80                        # -128 int16
d2 ff ff 80 00                  # -32768 int32
ca 00 00 00 00                  # 0.0 float
ca 80 00 00 00                  # -0.0 float
a1 61                           # "a" FixStr
d9 01 61                        # "a" str 8
da 00 01 61                     # "a" str 16
db 00 00 00 01 61               # "a" str 32
a0                              # "" FixStr
d9 00                           # "" str 8
da 00 00                        # "" str 16
db 00 00 00 00                  # "" str 32
c4 01 61                        # "a" bin 8
c5 00 01 61                     # "a" bin 16
c6 00 00 00 01 61               # "a" bin 32
c4 00                           # "" bin 8
c5 00 00                        # "" bin 16
c6 00 00 00 00                  # "" bin 32
91 00                           # [0] FixArray
dc 00 01 00                     # [0] array 16
dd 00 00 00 01 00               # [0] array 32
90                              # [] FixArray
dc 00 00                        # [] array 16
dd 00 00 00 00                  # [] array 32
80                              # {} FixMap
de 00 00                        # {} map 16
df 00 00 00 00                  # {} map 32
81 a1 61 61                     # {"a"=>97} FixMap
de 00 01 a1 61 61               # {"a"=>97} map 16
df 00 00 00 01 a1 61 61         # {"a"=>97} map 32
91 90                           # [[]]
91 91 a1 61                     # [["a"]]

d4 01 01                        # fixext 1
d5 02 02 01                     # fixext 2
d6 04 04 03 02 01               # fixext 4
d7 08 08 07 06 05 04 03 02 01   # fixext 8
d8 16 10 0f 0e 0d 0c 0b 0a 09 08 07 06 05 04 03 02 01   # fixext 16
c7 01 08 61                     # ext 8
c8 00 01 16 61                  # ext 16
c9 00 00 00 01 32 61            # ext 32
]===]
if not mp.small_lua then
    source = source .. [===[
cf 00 00 00 00 00 00 00 00      # 0 uint64
d3 00 00 00 00 00 00 00 00      # 0 int64
d3 ff ff ff ff ff ff ff ff      # -1 int64
cf 00 00 00 00 ff ff ff ff      # 4294967295 uint64
d3 ff ff ff ff 80 00 00 00      # -2147483648 int64
cb 00 00 00 00 00 00 00 00      # 0.0 double
cb 80 00 00 00 00 00 00 00      # -0.0 double
cb 3f f0 00 00 00 00 00 00      # 1.0 double
cb bf f0 00 00 00 00 00 00      # -1.0 double
]===]
end

source = source:gsub('#[^\n]+', '')
local t = {}
for v in source:gmatch'%x%x' do
    t[#t+1] = tonumber(v, 16)
end
local mpac = string.char(unpack(t))


local i = 1
for _, val in mp.unpacker(mpac) do
    if type(val) == 'table' then
        same(val, data[i], "reference   " .. data[i+1])
        same(mp.unpack(mp.pack(data[i])), data[i], "unpack/pack " .. data[i+1])
    else
        equals(val, data[i], "reference   " .. data[i+1])
        equals(mp.unpack(mp.pack(data[i])), data[i], "unpack/pack " .. data[i+1])
    end
    i = i + 2
end

local f = io.open('cases.mpac', 'w')
f:write(mpac)
f:close()
local r, ltn12 = pcall(require, 'ltn12')        -- from LuaSocket
if not r then
    diag "ltn12.source.file emulated"
    ltn12 = { source = {} }

    function ltn12.source.file (handle)
        if handle then
            return function ()
                local chunk = handle:read(1)
                if not chunk then
                    handle:close()
                end
                return chunk
            end
        else return function ()
                return nil, "unable to open file"
            end
        end
    end
end
i = 1
f = io.open('cases.mpac', 'r')
local s = ltn12.source.file(f)
for _, val in mp.unpacker(s) do
    if type(val) == 'table' then
        same(val, data[i], "reference   " .. data[i+1])
    else
        equals(val, data[i], "reference   " .. data[i+1])
    end
    i = i + 2
end
os.remove 'cases.mpac'  -- clean up

diag("set_string'string'")
mp.set_string'string'
i = 1
for _, val in mp.unpacker(mpac) do
    if type(val) == 'table' then
        same(mp.unpack(mp.pack(data[i])), data[i], "unpack/pack " .. data[i+1])
    else
        equals(mp.unpack(mp.pack(data[i])), data[i], "unpack/pack " .. data[i+1])
    end
    i = i + 2
end

diag("set_string'binary'")
mp.set_string'binary'
i = 1
for _, val in mp.unpacker(mpac) do
    if type(val) == 'table' then
        same(mp.unpack(mp.pack(data[i])), data[i], "unpack/pack " .. data[i+1])
    else
        equals(mp.unpack(mp.pack(data[i])), data[i], "unpack/pack " .. data[i+1])
    end
    i = i + 2
end
mp.set_string'string_compat'

diag("set_integer'signed'")
mp.set_integer'signed'
i = 1
for _, val in mp.unpacker(mpac) do
    if type(val) == 'table' then
        same(mp.unpack(mp.pack(data[i])), data[i], "unpack/pack " .. data[i+1])
    else
        equals(mp.unpack(mp.pack(data[i])), data[i], "unpack/pack " .. data[i+1])
    end
    i = i + 2
end
mp.set_integer'unsigned'

diag("set_array'with_hole'")
mp.set_array'with_hole'
i = 1
for _, val in mp.unpacker(mpac) do
    if type(val) == 'table' then
        same(mp.unpack(mp.pack(data[i])), data[i], "unpack/pack " .. data[i+1])
    else
        equals(mp.unpack(mp.pack(data[i])), data[i], "unpack/pack " .. data[i+1])
    end
    i = i + 2
end

diag("set_array'always_as_map'")
mp.set_array'always_as_map'
i = 1
for _, val in mp.unpacker(mpac) do
    if type(val) == 'table' then
        same(mp.unpack(mp.pack(data[i])), data[i], "unpack/pack " .. data[i+1])
    else
        equals(mp.unpack(mp.pack(data[i])), data[i], "unpack/pack " .. data[i+1])
    end
    i = i + 2
end
mp.set_array'without_hole'

diag("set_number'float'")
mp.set_number'float'
i = 1
for _, val in mp.unpacker(mpac) do
    if type(val) == 'table' then
        same(mp.unpack(mp.pack(data[i])), data[i], "unpack/pack " .. data[i+1])
    else
        equals(mp.unpack(mp.pack(data[i])), data[i], "unpack/pack " .. data[i+1])
    end
    i = i + 2
end
