
ifeq ($(wildcard bed),bed)
LUA     := $(CURDIR)/bed/bin/lua
else
LUA     := lua
endif
VERSION := $(shell LUA_PATH=";;src/?.lua" $(LUA) -e "m = require [[MessagePack]]; print(m._VERSION)")
TARBALL := lua-messagepack-$(VERSION).tar.gz
REV     := 1

LUAVER  := 5.2
PREFIX  := /usr/local
DPREFIX := $(DESTDIR)$(PREFIX)
LIBDIR  := $(DPREFIX)/share/lua/$(LUAVER)
INSTALL := install

ifeq ($(LUAVER),5.3)
SRC     := src5.3
else ifeq ($(LUAVER),5.4)
SRC     := src5.3
else
SRC     := src
endif

BED_OPTS:= --lua latest

all:
	@echo "Nothing to build here, you can just make install"

install:
	$(INSTALL) -m 644 -D $(SRC)/MessagePack.lua         $(LIBDIR)/MessagePack.lua

uninstall:
	rm -f $(LIBDIR)/MessagePack.lua

manifest_pl := \
use strict; \
use warnings; \
my @files = qw{MANIFEST}; \
while (<>) { \
    chomp; \
    next if m{^\.}; \
    next if m{^rockspec/}; \
    push @files, $$_; \
} \
print join qq{\n}, sort @files;

rockspec_pl := \
use strict; \
use warnings; \
use Digest::MD5; \
open my $$FH, q{<}, q{$(TARBALL)} \
    or die qq{Cannot open $(TARBALL) ($$!)}; \
binmode $$FH; \
my %config = ( \
    version => q{$(VERSION)}, \
    rev     => q{$(REV)}, \
    md5     => Digest::MD5->new->addfile($$FH)->hexdigest(), \
); \
close $$FH; \
while (<>) { \
    s{@(\w+)@}{$$config{$$1}}g; \
    print; \
}

version:
	@echo $(VERSION)

CHANGES:
	perl -i.bak -pe "s{^$(VERSION).*}{q{$(VERSION)  }.localtime()}e" CHANGES

tag:
	git tag -a -m 'tag release $(VERSION)' $(VERSION)

MANIFEST:
	git ls-files | perl -e '$(manifest_pl)' > MANIFEST

$(TARBALL): MANIFEST
	[ -d lua-MessagePack-$(VERSION) ] || ln -s . lua-MessagePack-$(VERSION)
	perl -ne 'print qq{lua-MessagePack-$(VERSION)/$$_};' MANIFEST | \
	    tar -zc -T - -f $(TARBALL)
	rm lua-MessagePack-$(VERSION)

dist: $(TARBALL)

rockspec: $(TARBALL)
	perl -e '$(rockspec_pl)' rockspec.in > rockspec/lua-messagepack-$(VERSION)-$(REV).rockspec
	perl -e '$(rockspec_pl)' rockspec.lua53.in > rockspec/lua-messagepack-lua53-$(VERSION)-$(REV).rockspec

rock:
	luarocks pack rockspec/lua-messagepack-$(VERSION)-$(REV).rockspec
	luarocks pack rockspec/lua-messagepack-lua53-$(VERSION)-$(REV).rockspec

bed:
	hererocks bed $(BED_OPTS) --no-readline --luarocks latest --verbose
	bed/bin/luarocks install lua-testassertion
	bed/bin/luarocks install lua-coat
	bed/bin/luarocks install lbc
	bed/bin/luarocks install luacov
	hererocks bed --show
	bed/bin/luarocks list

check: test

test:
	LUA_PATH="$(CURDIR)/$(SRC)/?.lua;;" \
		prove --exec=$(LUA) test/*.lua

luacheck:
	luacheck --std=max --codes src --ignore 211/_ENV 212 213 311/j 631
	luacheck --std=max --codes src5.3 --ignore 211/_ENV 212 213 311/j
	luacheck --std=max --config .test.luacheckrc test

coverage:
	rm -f luacov.*
	-LUA_PATH="$(CURDIR)/$(SRC)/?.lua;;" \
		prove --exec="$(LUA) -lluacov" test/*.lua
	luacov-console $(CURDIR)/src
	luacov-console -s $(CURDIR)/src
	luacov-console test
	luacov-console -s test

README.html: README.md
	Markdown.pl README.md > README.html

pages:
	mkdocs build -d public

clean:
	rm -f MANIFEST *.bak luacov.* README.html

realclean: clean
	rm -rf bed

.PHONY: test rockspec CHANGES

