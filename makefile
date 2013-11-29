PKGC ?= pkg-config

# lua's package config can be under various names
LUAPKGC := $(shell for pc in lua lua5.1; do \
		$(PKGC) --exists $$pc && echo $$pc && break; \
	done)

LUA_VERSION := $(shell $(PKGC) --variable=V $(LUAPKGC))
LUA_LIBDIR := $(shell $(PKGC) --variable=libdir $(LUAPKGC))
LUA_CFLAGS := $(shell $(PKGC) --cflags $(LUAPKGC))
LUA_LDFLAGS := $(shell $(PKGC) --libs-only-L $(LUAPKGC))

CMOD = mosquitto.so
OBJS = lua-mosquitto.o
LIBS = -lmosquitto
CSTD = -std=gnu99

OPT ?= -Os
WARN = -Wall -pedantic
CFLAGS += -fPIC $(CSTD) $(WARN) $(OPT) $(LUA_CFLAGS)
LDFLAGS += -shared $(CSTD) $(LIBS) $(LUA_LDFLAGS)

ifeq ($(OPENWRT_BUILD),1)
LUA_VERSION=
endif

$(CMOD): $(OBJS)
	$(CC) $(LDFLAGS) $(OBJS) $(LIBS) -o $@

.c.o:
	$(CC) -c $(CFLAGS) -o $@ $<

install:
	cp $(CMOD) $(LUA_LIBDIR)/lua/$(LUA_VERSION)

clean:
	$(RM) $(CMOD) $(OBJS)