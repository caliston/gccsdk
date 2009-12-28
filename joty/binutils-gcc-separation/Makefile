# Experiment to build GCCSDK based on a Makefile and having binutils and gcc built separately.
# Written by John Tytgat / BASS
# Status: not finished.
#
# Needed:
#   - apt-get install flex bison libgmp3-dev libmpfr-dev autoconf texinfo build-essential automake1.9 autoconf2.59
#   - gdb requires libncurses5-dev

# TARGET can have following values: arm-unknown-riscos, arm-unknown-eabi
TARGET=arm-unknown-riscos
GCC_LANGUAGES="c,c++"
PARALLEL=

##BINUTILS_VERSION=2.19.1
##GCC_VERSION=4.4.0
BINUTILS_VERSION=2.17
GCC_VERSION=4.1.1
NEWLIB_VERSION=1.17.0
GDB_VERSION=6.8

ifeq ($(TARGET),arm-unknown-riscos)
# Case GCCSDK arm-unknown-riscos target:
GCC_CONFIG_ARGS := \
	--enable-threads=posix \
	--enable-sjlj-exceptions=no \
	--enable-c99 \
	--enable-cmath \
	--enable-maintainer-mode \
	--enable-shared=libunixlib,libgcc,libstdc++ \
	--enable-multilib \
	--disable-c-mbchar \
	--disable-libstdcxx-pch \
	--disable-tls \
	--without-pic \
	--with-cross-host \
	--with-pkgversion=GCCSDK-$(GCC_VERSION)-Release1-Alpha1 \
	--with-bugurl=http://gccsdk.riscos.info/
# FIXME: for Java support: --without-x --enable-libgcj
BINUTILS_CONFIG_ARGS =
else
# Case arm-unknown-eabi target (use newlib):
GCC_CONFIG_ARGS := --disable-threads --disable-multilib --disable-shared --with-newlib
BINUTILS_CONFIG_ARGS := --disable-multilib --disable-shared
endif
# When debugging/testing/validating the compiler add "-enable-checking=all",
# otherwise add "--enable-checking=release" or even "--enable-checking=no"
GCC_CONFIG_ARGS += --enable-checking=no
# Configure args shared between different targets:
BINUTILS_CONFIG_ARGS += --enable-interwork --disable-werror --with-gcc --disable-nls
GCC_CONFIG_ARGS += --enable-interwork --disable-nls
NEWLIB_CONFIG_ARGS += --enable-interwork --disable-multilib --disable-shared --disable-nls
GDB_CONFIG_ARGS += --enable-interwork --disable-multilib --disable-werror --disable-nls
# For debugging:
# FIXME: add to GCC_BUILD_FLAGS for optimized ARM libraries: CFLAGS_FOR_TARGET="-O3 -march=armv5" CXXFLAGS_FOR_TARGET="-O3 -march=armv5"
GCC_BUILD_FLAGS = CFLAGS="-O0 -g" LIBCFLAGS="-O0 -g" LIBCXXFLAGS="-O0 -g"

# Environment variable needed during building:
export LTCONFIG_VERSION=1.4a-GCC3.0

ROOT := $(shell pwd)
PREFIX_CROSS := $(ROOT)/cross
PREFIX_RONATIVE := $(ROOT)/release-area/full/\!GCC
BUILDDIR := $(ROOT)/builddir
SRCDIR := $(ROOT)/srcdir
ORIGSRCDIR := $(ROOT)/srcdir.orig
BUILDSTEPSDIR := $(ROOT)/buildsteps
SCRIPTSDIR := $(ROOT)/scripts
RECIPEDIR := $(ROOT)/recipe

# Configure args unique for cross-compiling & unique to building for RISC OS native
CROSS_CONFIG_ARGS := --target=$(TARGET) --prefix=$(PREFIX_CROSS)
# Note: --build argument can only be determined when SRCDIR is populated.
RONATIVE_CONFIG_ARGS = --build=`$(SRCDIR)/gcc/config.guess` --host=$(TARGET) --target=$(TARGET) --prefix=$(PREFIX_RONATIVE)

.PHONY: all cross ronative

all: cross

cross: $(BUILDSTEPSDIR)/buildstep-cross-gcc-full
# Steps:
# $(BUILDSTEPSDIR)/buildstep-src-binutils
# $(BUILDSTEPSDIR)/buildstep-cross-binutils
# $(BUILDSTEPSDIR)/buildstep-src-gcc
# $(BUILDSTEPSDIR)/buildstep-cross-gcc-bootstrap
# $(BUILDSTEPSDIR)/buildstep-cross-gcc-full
# $(BUILDSTEPSDIR)/buildstep-cross-gdb

ronative: $(BUILDSTEPSDIR)/buildstep-ronative-gcc-full
# Steps:
# $(BUILDSTEPSDIR)/buildstep-ronative-binutils

clean:
	-rm -rf $(BUILDDIR)
	-rm -rf $(SRCDIR)
	-rm -rf $(BUILDSTEPSDIR)

distclean:
	-rm -rf $(BUILDDIR)
	-rm -rf $(SRCDIR)
	-rm -rf $(BUILDSTEPSDIR)
	-rm -rf $(ORIGSRCDIR) $(PREFIX_CROSS) $(PREFIX_RONATIVE)

# -- Building

# Build binutils cross:
$(BUILDSTEPSDIR)/buildstep-cross-binutils: $(BUILDSTEPSDIR)/buildstep-src-binutils
	-rm -rf $(BUILDDIR)/cross-binutils
	mkdir -p $(BUILDDIR)/cross-binutils
	cd $(BUILDDIR)/cross-binutils && $(SRCDIR)/binutils/configure $(CROSS_CONFIG_ARGS) $(BINUTILS_CONFIG_ARGS) && make $(PARALLEL) && make install
	touch $(BUILDSTEPSDIR)/buildstep-cross-binutils

# Build binutils ronative:
$(BUILDSTEPSDIR)/buildstep-ronative-binutils: $(BUILDSTEPSDIR)/buildstep-src-binutils cross
	-rm -rf $(BUILDDIR)/ronative-binutils
	mkdir -p $(BUILDDIR)/ronative-binutils
	cd $(BUILDDIR)/ronative-binutils && PATH="$(PREFIX_CROSS)/bin:$(PATH)" && $(SRCDIR)/binutils/configure $(RONATIVE_CONFIG_ARGS) $(BINUTILS_CONFIG_ARGS) && make $(PARALLEL) && make install
	touch $(BUILDSTEPSDIR)/buildstep-ronative-binutils

# Build minimal gcc cross (without target runtime support):
ifneq ($(TARGET),arm-unknown-riscos)
$(BUILDSTEPSDIR)/buildstep-cross-gcc-bootstrap: $(BUILDSTEPSDIR)/buildstep-src-gcc $(BUILDSTEPSDIR)/buildstep-cross-binutils
	-rm -rf $(BUILDDIR)/cross-gcc-bootstrap
	mkdir -p $(BUILDDIR)/cross-gcc-bootstrap
	cd $(BUILDDIR)/cross-gcc-bootstrap && PATH="$(PREFIX_CROSS)/bin:$(PATH)" && $(SRCDIR)/gcc/configure $(CROSS_CONFIG_ARGS) $(GCC_CONFIG_ARGS) --enable-languages="c" --without-headers && make $(PARALLEL) all-gcc && make install-gcc
	touch $(BUILDSTEPSDIR)/buildstep-cross-gcc-bootstrap
else
$(BUILDSTEPSDIR)/buildstep-cross-gcc-bootstrap: $(BUILDSTEPSDIR)/buildstep-src-gcc $(BUILDSTEPSDIR)/buildstep-cross-binutils
	-rm -rf $(BUILDDIR)/cross-gcc-bootstrap
	touch $(BUILDSTEPSDIR)/buildstep-cross-gcc-bootstrap
endif

# Build full gcc cross (we need target runtime support by now):
ifneq ($(TARGET),arm-unknown-riscos)
$(BUILDSTEPSDIR)/buildstep-cross-gcc-full: $(BUILDSTEPSDIR)/buildstep-cross-newlib
endif
$(BUILDSTEPSDIR)/buildstep-cross-gcc-full: $(BUILDSTEPSDIR)/buildstep-src-gcc $(BUILDSTEPSDIR)/buildstep-cross-binutils
	-rm -rf $(BUILDDIR)/cross-gcc-full
	mkdir -p $(BUILDDIR)/cross-gcc-full
	cd $(BUILDDIR)/cross-gcc-full && PATH="$(PREFIX_CROSS)/bin:$(PATH)" && $(SRCDIR)/gcc/configure $(CROSS_CONFIG_ARGS) $(GCC_CONFIG_ARGS) --enable-languages=$(GCC_LANGUAGES) && make $(PARALLEL) $(GCC_BUILD_FLAGS) && make install
	touch $(BUILDSTEPSDIR)/buildstep-cross-gcc-full

# Build full gcc ronative (we need target runtime support by now):
ifneq ($(TARGET),arm-unknown-riscos)
$(BUILDSTEPSDIR)/buildstep-ronative-gcc-full: $(BUILDSTEPSDIR)/buildstep-ronative-newlib
endif
$(BUILDSTEPSDIR)/buildstep-ronative-gcc-full: $(BUILDSTEPSDIR)/buildstep-src-gcc cross
	-rm -rf $(BUILDDIR)/ronative-gcc-full
	mkdir -p $(BUILDDIR)/ronative-gcc-full
	cd $(BUILDDIR)/ronative-gcc-full && PATH="$(PREFIX_CROSS)/bin:$(PATH)" && $(SRCDIR)/gcc/configure $(RONATIVE_CONFIG_ARGS) $(GCC_CONFIG_ARGS) --enable-languages=$(GCC_LANGUAGES) && make $(PARALLEL) $(GCC_BUILD_FLAGS) && make install
	touch $(BUILDSTEPSDIR)/buildstep-ronative-gcc-full

# Build newlib with minimal gcc:
$(BUILDSTEPSDIR)/buildstep-cross-newlib: $(BUILDSTEPSDIR)/buildstep-src-newlib $(BUILDSTEPSDIR)/buildstep-cross-gcc-bootstrap
	-rm -rf $(BUILDDIR)/cross-newlib
	mkdir -p $(BUILDDIR)/cross-newlib
	cd $(BUILDDIR)/cross-newlib && PATH="$(PREFIX_CROSS)/bin:$(PATH)" && $(SRCDIR)/newlib/configure $(CROSS_CONFIG_ARGS) $(NEWLIB_CONFIG_ARGS) --enable-languages=$(GCC_LANGUAGES) && make $(PARALLEL) $(GCC_BUILD_FLAGS) && make install
	touch $(BUILDSTEPSDIR)/buildstep-cross-newlib

# Build gdb:
$(BUILDSTEPSDIR)/buildstep-cross-gdb: $(BUILDSTEPSDIR)/buildstep-src-gdb $(BUILDSTEPSDIR)/buildstep-cross-gcc-full
	-rm -rf $(BUILDDIR)/cross-gdb
	mkdir -p $(BUILDDIR)/cross-gdb
	cd $(BUILDDIR)/cross-gdb && PATH="$(PREFIX_CROSS)/bin:$(PATH)" && $(ORIGSRCDIR)/gdb/configure $(CROSS_CONFIG_ARGS) $(GDB_CONFIG_ARGS) && make $(PARALLEL) && make install
	touch $(BUILDSTEPSDIR)/buildstep-cross-gdb

# -- Source unpacking.

# Unpack binutils source:
$(BUILDSTEPSDIR)/buildstep-src-binutils: $(ORIGSRCDIR)/binutils-$(BINUTILS_VERSION).tar.bz2
	-rm -rf $(ORIGSRCDIR)/binutils-$(BINUTILS_VERSION) $(SRCDIR)/binutils
	cd $(ORIGSRCDIR) && tar xfj binutils-$(BINUTILS_VERSION).tar.bz2
	-mkdir -p $(SRCDIR)/binutils
	cp -T -r $(ORIGSRCDIR)/binutils-$(BINUTILS_VERSION) $(SRCDIR)/binutils
	cd $(SRCDIR)/binutils && $(SCRIPTSDIR)/do-patch-and-copy $(RECIPEDIR)
	-mkdir -p $(BUILDSTEPSDIR)
	touch $(BUILDSTEPSDIR)/buildstep-src-binutils

# Unpack gcc source:
$(BUILDSTEPSDIR)/buildstep-src-gcc: $(ORIGSRCDIR)/gcc-$(GCC_VERSION).tar.bz2
	-rm -rf $(ORIGSRCDIR)/gcc-$(GCC_VERSION) $(SRCDIR)/gcc
	cd $(ORIGSRCDIR) && tar xfj gcc-$(GCC_VERSION).tar.bz2
	-mkdir -p $(SRCDIR)/gcc
	cp -T -r $(ORIGSRCDIR)/gcc-$(GCC_VERSION) $(SRCDIR)/gcc
	cd $(SRCDIR)/gcc && $(SCRIPTSDIR)/do-patch-and-copy $(RECIPEDIR)
	-mkdir -p $(BUILDSTEPSDIR)
	touch $(BUILDSTEPSDIR)/buildstep-src-gcc

# Unpack newlib source:
$(BUILDSTEPSDIR)/buildstep-src-newlib: $(ORIGSRCDIR)/newlib-$(NEWLIB_VERSION).tar.gz
	-rm -rf $(ORIGSRCDIR)/newlib-$(NEWLIB_VERSION) $(SRCDIR)/newlib
	cd $(ORIGSRCDIR) && tar xfz newlib-$(NEWLIB_VERSION).tar.gz
	# FIXME: add stuff
	-mkdir -p $(BUILDSTEPSDIR)
	touch $(BUILDSTEPSDIR)/buildstep-src-newlib

# Unpack gdb source:
$(BUILDSTEPSDIR)/buildstep-src-gdb: $(ORIGSRCDIR)/gdb-$(GDB_VERSION).tar.bz2
	-rm -rf $(ORIGSRCDIR)/gdb-$(GDB_VERSION) $(SRCDIR)/gdb
	cd $(ORIGSRCDIR) && tar xfj gdb-$(GDB_VERSION).tar.bz2
	# FIXME: add stuff
	-mkdir -p $(BUILDSTEPSDIR)
	touch $(BUILDSTEPSDIR)/buildstep-src-gdb

# -- Source downloading.

# Download binutils source:
$(ORIGSRCDIR)/binutils-$(BINUTILS_VERSION).tar.bz2:
	-rm $(ORIGSRCDIR)/binutils-$(BINUTILS_VERSION).tar.bz2
	-mkdir -p $(ORIGSRCDIR)
	cd $(ORIGSRCDIR) && wget -c http://ftp.gnu.org/gnu/binutils/binutils-$(BINUTILS_VERSION).tar.bz2

# Download gcc source:
$(ORIGSRCDIR)/gcc-$(GCC_VERSION).tar.bz2:
	-rm $(ORIGSRCDIR)/gcc-$(GCC_VERSION).tar.bz2
	-mkdir -p $(ORIGSRCDIR)
	cd $(ORIGSRCDIR) && wget -c ftp://ftp.gnu.org/gnu/gcc/gcc-$(GCC_VERSION)/gcc-$(GCC_VERSION).tar.bz2

# Download newlib source:
$(ORIGSRCDIR)/newlib-$(NEWLIB_VERSION).tar.gz:
	-rm $(ORIGSRCDIR)/newlib-$(NEWLIB_VERSION).tar.gz
	-mkdir -p $(ORIGSRCDIR)
	cd $(ORIGSRCDIR) && wget -c ftp://sources.redhat.com/pub/newlib/newlib-$(NEWLIB_VERSION).tar.gz

# Download gdb source:
$(ORIGSRCDIR)/gdb-$(GDB_VERSION).tar.bz2:
	-rm $(ORIGSRCDIR)/gdb-$(GDB_VERSION).tar.bz2
	-mkdir -p $(ORIGSRCDIR)
	cd $(ORIGSRCDIR) && wget -c ftp://ftp.gnu.org/gnu/gdb/gdb-$(GDB_VERSION).tar.bz2

