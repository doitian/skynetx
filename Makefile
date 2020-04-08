LUACLIB_CFLAGS := -I$(PWD)/include -I/usr/local/opt/openssl/include -I/usr/local/include
LUACLIB_LDFLAGS := -L/usr/local/opt/openssl/lib -L/usr/local/lib
JEMALLOC_STATICLIB := $(PWD)/vendor/jemalloc/lib/libjemalloc_pic.a
MALLOC_STATICLIB := $(JEMALLOC_STATICLIB)
LUACLIB := cjson luaossl
VERSION := $(shell sed -n 's/:major: //p' .semver).$(shell sed -n 's/:minor: //p' .semver)
FULL_VERSION := $(VERSION).$(shell sed -n 's/:patch: //p' .semver)
PREFIX := /usr/local

UNAME := $(shell uname)
ifeq ($(UNAME),Darwin)
		LUACLIB_LDFLAGS +=  -bundle -undefined dynamic_lookup -all_load
		PLAT := macosx
		MALLOC_STATICLIB :=
else ifeq ($(UNAME),Linux)
		LUACLIB_CFLAGS += -O2 -fPIC
		LUACLIB_LDFLAGS += -shared
		PLAT := linux
else ifeq ($(NAME),FreeBSD)
		LUACLIB_CFLAGS += -O2 -fPIC
		LUACLIB_LDFLAGS += -shared
		PLAT := freebsd
else
		PLAT := none
endif

LUA_PATH := $(PWD)/vendor/skynet/3rd/lua/lua
LUA_MODULE_DIR := $(PWD)/src
LUA_CMODULE_DIR := $(PWD)/csrc
LUA_BIN_DIR := $(PWD)/bin
LUA_INCLUDE_DIR := $(PWD)/vendor/skynet/3rd/lua

LUACLIB_MAKE := $(MAKE) CFLAGS="$(LUACLIB_CFLAGS)" \
		LDFLAGS="$(LUACLIB_LDFLAGS)" \
		LUA_PATH="$(LUA_PATH)" \
		LUA_MODULE_DIR="$(LUA_MODULE_DIR)" \
		LUA_CMODULE_DIR="$(LUA_CMODULE_DIR)" \
		LUA_BIN_DIR="$(LUA_BIN_DIR)" \
		LUA_INCLUDE_DIR="$(LUA_INCLUDE_DIR)"

default: skynet bin/sx-version src csrc cservice $(LUACLIB)
all: default

bin/sx-version: .semver
	(  echo '#!/usr/bin/env bash' \
	&& echo '# Summary: Show sx version' \
	&& echo 'echo "v$(FULL_VERSION) for $(PLAT) with skynet master(b00b006)"' \
	) > $@
	chmod +x bin/sx-version

$(LUACLIB): skynet

SKYNET_LUALIB_SOURCE := $(wildcard vendor/skynet/lualib/*.lua vendor/skynet/lualib/*/*.lua)
SKYNET_LUALIB := $(patsubst vendor/skynet/lualib/%.lua,src/%.lua,$(SKYNET_LUALIB_SOURCE))
SKYNET_SERVICE_SOURCE := $(wildcard vendor/skynet/service/*.lua vendor/skynet/service/*/*.lua)
SKYNET_SERVICE := $(patsubst vendor/skynet/service/%.lua,service/%.lua,$(SKYNET_SERVICE_SOURCE))
SKYNET_HEADERS_SOURCE := $(wildcard vendor/skynet/skynet-src/*.h)
SKYNET_HEADERS := $(patsubst vendor/skynet/skynet-src/%.h,include/%.h,$(SKYNET_HEADERS_SOURCE))
LUA_HEADERS := $(patsubst %,include/%,lauxlib.h lua.h lua.hpp luaconf.h lualib.h)

skynet: $(SKYNET_LUALIB) $(SKYNET_SERVICE) $(MALLOC_STATICLIB) $(SKYNET_HEADERS) $(LUA_HEADERS)
	cd vendor/skynet && $(MAKE) MALLOC_STATICLIB=$(MALLOC_STATICLIB) JEMALLOC_INC=$(PWD)/vendor/jemalloc/include/jemalloc $(PLAT)
	install vendor/skynet/cservice/*.so cservice/
	install vendor/skynet/luaclib/*.so csrc/
	install vendor/skynet/skynet vendor/skynet/3rd/lua/lua vendor/skynet/3rd/lua/luac bin

$(SKYNET_LUALIB): src/%.lua: vendor/skynet/lualib/%.lua
	mkdir -p "$$(dirname "$@")"
	cp -f $< $@

$(SKYNET_SERVICE): service/%.lua: vendor/skynet/service/%.lua
	mkdir -p "$$(dirname "$@")"
	cp -f $< $@

$(SKYNET_HEADERS): include/%.h: vendor/skynet/skynet-src/%.h
	cp -f $< $@

$(LUA_HEADERS): include/%: vendor/skynet/3rd/lua/%
	cp -f $< $@

skynet-clean:
	rm -f bin/skynet bin/lua bin/luac
	cd vendor/skynet && $(MAKE) MALLOC_STATICLIB=$(MALLOC_STATICLIB) cleanall
	rm -f $(SKYNET_LUALIB) $(SKYNET_SERVICE)

jemalloc: $(JEMALLOC_STATICLIB)

jemalloc-clean:
	test -f vendor/jemalloc/Makefile && cd vendor/jemalloc && $(MAKE) relclean || true

$(JEMALLOC_STATICLIB): vendor/jemalloc/Makefile
	cd vendor/jemalloc && $(MAKE)

vendor/jemalloc/Makefile: vendor/jemalloc/autogen.sh
	cd vendor/jemalloc && ./autogen.sh --with-jemalloc-prefix=je_ --disable-valgrind

cjson:
	cd vendor/lua-cjson && $(LUACLIB_MAKE) CJSON_LDFLAGS= all install

cjson-clean:
	cd vendor/lua-cjson && $(LUACLIB_MAKE) clean
	rm -rf csrc/cjson.so

luaossl:
	cd vendor/luaossl && $(LUACLIB_MAKE) includedir=$(LUA_INCLUDE_DIR) lua53path=$(LUA_MODULE_DIR) lua53cpath=$(LUA_CMODULE_DIR) all5.3 install5.3
	rm -rf vendor/luaossl/src/5.3

luaossl-clean:
	cd vendor/luaossl && $(LUACLIB_MAKE) clean
	rm -rf csrc/_openssl.so src/openssl/ src/openssl.lua vendor/luaossl/config.h vendor/luaossl/src/config.h

LUA_STDLIB_LUA := $(wildcard vendor/lua-stdlib/lib/std/*.lua vendor/lua-stdlib/lib/std/*/*.lua)
LUA_STDLIB_LUA_INIT := $(patsubst vendor/lua-stdlib/lib/%/init.lua,src/%.lua,$(filter %/init.lua,$(LUA_STDLIB_LUA)))
LUA_STDLIB_LUA_COMMON := $(patsubst vendor/lua-stdlib/lib/%,src/%,$(filter-out %/init.lua,$(LUA_STDLIB_LUA)))

$(LUA_STDLIB_LUA_INIT): src/%.lua: vendor/lua-stdlib/lib/%/init.lua
	mkdir -p "$$(dirname $@)"
	cp -f $< $@

$(LUA_STDLIB_LUA_COMMON): src/%.lua: vendor/lua-stdlib/lib/%.lua
	mkdir -p "$$(dirname $@)"
	cp -f $< $@

LUA_XI_SOURCE := $(wildcard vendor/lua-xi/src/xi/*.lua vendor/lua-xi/src/xi/*/*.lua)
LUA_XI_FILES := $(patsubst vendor/lua-xi/%.lua,%.lua,$(LUA_XI_SOURCE))

$(LUA_XI_FILES): %.lua: vendor/lua-xi/%.lua
	mkdir -p "$$(dirname $@)"
	cp -f $< $@

src: $(LUA_STDLIB_LUA_INIT) $(LUA_STDLIB_LUA_COMMON) $(LUA_XI_FILES) $(SKYNET_LUALIB) $(SKYNET_SERVICE)

src-clean:
	rm -f $(LUA_STDLIB_LUA_INIT) $(LUA_STDLIB_LUA_COMMON)

LUA_CSRC := $(wildcard csrc/*.c)
LUA_CSRC_SO := $(patsubst %.c,%.so,$(LUA_CSRC))

csrc: $(LUA_CSRC_SO)

$(LUA_CSRC_SO): %.so: %.c
	$(CC) $(LUACLIB_CFLAGS) $(LUACLIB_LDFLAGS) -o $@ $<

csrc-clean:
	rm -f $(LUA_CSRC_SO)

LUA_CSERVICE := $(wildcard cservice/*.c)
LUA_CSERVICE_SO := $(patsubst %.c,%.so,$(LUA_CSERVICE))

cservice: $(LUA_CSERVICE_SO)

$(LUA_CSERVICE_SO): %.so: %.c
	$(CC) $(LUACLIB_CFLAGS) $(LUACLIB_LDFLAGS) -o $@ $<

cservice-clean:
	rm -f $(LUA_CSERVICE_SO)

less: csrc cservice

check:
	@type luacheck &>/dev/null || echo "未安装 luacheck, 请查看 README.md"
	luacheck .

test:
	@type busted &>/dev/null || echo "未安装 busted, 请查看 README.md"
	busted .

integration:
	SX_DB_TEST_URL=1 bin/sx integration

doc: src
	@type ldoc &>/dev/null || echo "未安装 ldoc, 请查看 README.md"
	cd doc/ && ldoc .

doc-clean:
	rm -rf doc/html

clean: jemalloc-clean doc-clean luaossl-clean cjson-clean skynet-clean src-clean csrc-clean cservice-clean
	rm -f bin/sx-version
	rm -f cservice/*.so
	rm -f csrc/*.so
	git clean -fdX src vendor

relclean:
	git clean -idX

download:
	curl -o src/inspect.lua -L https://raw.githubusercontent.com/kikito/inspect.lua/master/inspect.lua
	curl -o src/MessagePack.lua -L https://github.com/fperrad/lua-MessagePack/raw/master/src5.3/MessagePack.lua

install:
	mkdir -p $(PREFIX)/bin
	mkdir -p $(PREFIX)/lib/skynetx/sx$(VERSION)/bin
	mkdir -p $(PREFIX)/lib/skynetx/sx$(VERSION)/cservice
	mkdir -p $(PREFIX)/lib/skynetx/sx$(VERSION)/csrc
	cp -r src include service snax template completions $(PREFIX)/lib/skynetx/sx$(VERSION)/
	install cservice/*.so $(PREFIX)/lib/skynetx/sx$(VERSION)/cservice/
	install csrc/*.so $(PREFIX)/lib/skynetx/sx$(VERSION)/csrc/
	install bin/* $(PREFIX)/lib/skynetx/sx$(VERSION)/bin/
	ln -snf ../lib/skynetx/sx$(VERSION)/bin/sx $(PREFIX)/bin/sx$(VERSION)
	test -f $(PREFIX)/bin/sx || ln -snf sx$(VERSION) $(PREFIX)/bin/sx

uninstall:
	rm -rf $(PREFIX)/lib/skynetx/sx$(VERSION)
	rm -f $(PREFIX)/bin/sx$(VERSION)

uninstall-all:
	rm -rf $(PREFIX)/lib/skynetx
	rm -f $(PREFIX)/bin/sx
	ls $(PREFIX)/bin/sx* | grep 'sx\d\+\.\d\+' | xargs -L 1 rm -f

release:
	test -f bin/sx-version && sed -i.bak -e 's/v[0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{1,\}/v'$(FULL_VERSION)'/' bin/sx-version && rm -f bin/sx-version.bak
	sed -i.bak -e 's/v[0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{1,\}/v'$(FULL_VERSION)'/g' README.md && rm -f README.md.bak
	sed -i.bak -e '1,5s/v[0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{1,\}/v'$(FULL_VERSION)'/' doc/config.ld && rm -f doc//config.ld.bak
	git add README.md doc/config.ld .semver
	git commit -m "Bump to v$(FULL_VERSION)"
	git tag -a v$(FULL_VERSION) -m "tagging v$(FULL_VERSION)"

.PHONY: all less default skynet skynet-clean jemalloc jemalloc-clean
.PHONY: cjson cjson-clean luaossl luaossl-clean src csrc doc doc-clean clean download
.PHONY: src src-clean csrc csrc-clean cservice cservice-clean relclean
.PHONY: test check integration
.PHONY: install uninstall uninstall-all release
