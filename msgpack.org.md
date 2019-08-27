MessagePack for Lua (spec v5)
=============================

[![Licence](http://img.shields.io/badge/Licence-MIT-brightgreen.svg)](COPYRIGHT)
[![Dependencies](http://img.shields.io/badge/Dependencies-none-brightgreen.svg)](COPYRIGHT)

``` lua
local mp = require 'MessagePack'
mpac = mp.pack(data)
data = mp.unpack(mpac)
```

Install
-------

You can use LuaRocks to install lua-MessagePack:

```
$ luarocks install lua-messagepack
```

or from the source, with:

```
$ make install
```

It is a pure Lua implementation, without any dependency.

Links
-----

* [Framagit](https://framagit.org/fperrad/lua-MessagePack/)
* [API reference](https://fperrad.frama.io/lua-MessagePack/messagepack/)

Copyright and License
---------------------

Copyright (c) 2012-2019 Francois Perrad

This library is licensed under the terms of the MIT/X11 license, like Lua itself.
