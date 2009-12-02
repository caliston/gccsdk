# Experiment to build GCCSDK based on a Makefile and having binutils and gcc built separately.
# Written by John Tytgat / BASS
# Status: not finished.
#
# Needed:
#   - apt-get install flex bison libgmp3-dev libmpfr-dev autoconf texinfo build-essential automake1.9 autoconf2.59
#   - gdb requires libncurses5-dev

# TARGET can have following values: arm-unknown-riscos, arm-non-eabi, arm-elf
TARGET=arm-unknown-riscos
GCC_LANGUAGES="c"
PARALLEL=

##BINUTILS_VERSION=2.19.1
##GCC_VERSION=4.4.0
BINUTILS_VERSION=2.17
GCC_VERSION=4.1.1
NEWLIB_VERSION=1.17.0
GDB_VERSION=6.8

ifeq ($(TARGET),arm-unknown-riscos)
# Case GCCSDK arm-unknown-riscos target:
GCC_CONFIGURE_ARGS := --enable-threads=posix \
	--enable-sjlj-exceptions=yes \
	--disable-c-mbchar \
	--disable-libstdcxx-pch \
	--disable-tls \
	--enable-c99 --enable-cmath \
	--with-cross-host \
	--with-pkgversion=GCCSDK-$(GCC_VERSION)-Release1-Alpha1 \
	--with-bugurl=http://gccsdk.riscos.info/

# When debugging/testing/validating GCCSDK cross-compiler add "-enable-checking=all",
# otherwise add "--enable-checking=release"
GCC_CONFIGURE_ARGS += --enable-checking=all

# For debugging:
GCC_BUILD_FLAGS = CFLAGS="-O0 -g" LIBCFLAGS="-O0 -g" LIBCXXFLAGS="-O0 -g"

# For shared lib support: --enable-shared=libunixlib,libgcc,libstdc++
# For Java --without-x  --enable-libgcj

else
# Case arm-elf, arm-non-eabi target (use newlib):
GCC_CONFIGURE_ARGS = --disable-threads --with-newlib
endif
# Common configure args:
BINUTILS_CONFIGURE_ARGS += --enable-interwork --disable-multilib --disable-shared --disable-werror --with-gcc --disable-nls
GCC_CONFIGURE_ARGS += --enable-interwork --disable-multilib --disable-shared --disable-nls
NEWLIB_CONFIGURE_ARGS += --enable-interwork --disable-multilib --disable-shared --disable-nls
GDB_CONFIGURE_ARGS += --enable-interwork --disable-multilib --disable-werror --disable-nls

# Environment variable needed during building:
export LTCONFIG_VERSION=1.4a-GCC3.0

ROOT := $(shell pwd)
PREFIX := $(ROOT)/cross
BUILDDIR := $(ROOT)/builddir
SRCDIR := $(ROOT)/srcdir
ORIGSRCDIR := $(ROOT)/srcdir.orig
BUILDSTEPSDIR := $(ROOT)/buildsteps
SCRIPTSDIR := $(ROOT)/scripts
RECIPEDIR := $(ROOT)/recipe

.PHONY: all cross

all: cross

cross: $(BUILDSTEPSDIR)/buildstep-gcc-full-cross
# Steps:
# $(BUILDSTEPSDIR)/buildstep-binutils-src
# $(BUILDSTEPSDIR)/buildstep-binutils-cross
# $(BUILDSTEPSDIR)/buildstep-gcc-src
# $(BUILDSTEPSDIR)/buildstep-gcc-bootstrap-cross
# $(BUILDSTEPSDIR)/buildstep-gcc-full-cross
# $(BUILDSTEPSDIR)/buildstep-gdb-cross

clean:
	-rm -rf $(BUILDDIR)
	-rm -rf $(SRCDIR)
	-rm -rf $(BUILDSTEPSDIR)

distclean:
	-rm -rf $(BUILDDIR)
	-rm -rf $(SRCDIR)
	-rm -rf $(BUILDSTEPSDIR)
	-rm -rf $(ORIGSRCDIR)

# -- Source building

# Build binutils cross:
$(BUILDSTEPSDIR)/buildstep-binutils-cross: $(BUILDSTEPSDIR)/buildstep-binutils-src
	-rm -rf $(BUILDDIR)/binutils-cross
	mkdir -p $(BUILDDIR)/binutils-cross
	cd $(BUILDDIR)/binutils-cross && $(SRCDIR)/binutils/configure --target=$(TARGET) --prefix=$(PREFIX) $(BINUTILS_CONFIGURE_ARGS) && make $(PARALLEL) && make install
	touch $(BUILDSTEPSDIR)/buildstep-binutils-cross

# Build minimal gcc (without target runtime support):
$(BUILDSTEPSDIR)/buildstep-gcc-bootstrap-cross: $(BUILDSTEPSDIR)/buildstep-gcc-src $(BUILDSTEPSDIR)/buildstep-binutils-cross
	-rm -rf $(BUILDDIR)/gcc-bootstrap-cross
ifneq ($(TARGET),arm-unknown-riscos)
	mkdir -p $(BUILDDIR)/gcc-bootstrap-cross
	cd $(BUILDDIR)/gcc-bootstrap-cross && PATH="$(PREFIX)/bin:$(PATH)" && $(SRCDIR)/gcc/configure --target=$(TARGET) --prefix=$(PREFIX) --enable-languages="c" --without-headers $(GCC_CONFIGURE_ARGS) && make $(PARALLEL) all-gcc && make install-gcc
endif
	touch $(BUILDSTEPSDIR)/buildstep-gcc-bootstrap-cross

# Build full gcc (we need target runtime support now):
ifneq ($(TARGET),arm-unknown-riscos)
$(BUILDSTEPSDIR)/buildstep-gcc-full-cross: $(BUILDSTEPSDIR)/buildstep-newlib-cross
endif
$(BUILDSTEPSDIR)/buildstep-gcc-full-cross: $(BUILDSTEPSDIR)/buildstep-gcc-src $(BUILDSTEPSDIR)/buildstep-binutils-cross
	-rm -rf $(BUILDDIR)/gcc-full-cross
	mkdir -p $(BUILDDIR)/gcc-full-cross
	cd $(BUILDDIR)/gcc-full-cross && PATH="$(PREFIX)/bin:$(PATH)" && $(SRCDIR)/gcc/configure --target=$(TARGET) --prefix=$(PREFIX) --enable-languages=$(GCC_LANGUAGES) $(GCC_CONFIGURE_ARGS) && make $(PARALLEL) $(GCC_BUILD_FLAGS) && make install
	touch $(BUILDSTEPSDIR)/buildstep-gcc-full-cross

# Build newlib with minimal gcc:
$(BUILDSTEPSDIR)/buildstep-newlib-cross: $(BUILDSTEPSDIR)/buildstep-newlib-src $(BUILDSTEPSDIR)/buildstep-gcc-bootstrap-cross
	-rm -rf $(BUILDDIR)/newlib-cross
ifneq ($(TARGET),arm-unknown-riscos)
	mkdir -p $(BUILDDIR)/newlib-cross
	cd $(BUILDDIR)/newlib-cross && PATH="$(PREFIX)/bin:$(PATH)" && $(SRCDIR)/newlib/configure --target=$(TARGET) --prefix=$(PREFIX) --enable-languages=$(GCC_LANGUAGES) $(NEWLIB_CONFIGURE_ARGS) && make $(PARALLEL) $(GCC_BUILD_FLAGS) && make install
endif
	touch $(BUILDSTEPSDIR)/buildstep-newlib-cross

# Build gdb:
$(BUILDSTEPSDIR)/buildstep-gdb-cross: $(BUILDSTEPSDIR)/buildstep-gdb-src $(BUILDSTEPSDIR)/buildstep-gcc-full-cross
	-rm -rf $(BUILDDIR)/gdb-cross
	mkdir -p $(BUILDDIR)/gdb-cross
	cd $(BUILDDIR)/gdb-cross && PATH="$(PREFIX)/bin:$(PATH)" && $(ORIGSRCDIR)/gdb/configure --target=$(TARGET) --prefix=$(PREFIX) && make $(PARALLEL) $(GDB_CONFIGURE_ARGS) && make install
	touch $(BUILDSTEPSDIR)/buildstep-gdb-cross

# -- Source unpacking.

# Unpack binutils source:
$(BUILDSTEPSDIR)/buildstep-binutils-src: $(ORIGSRCDIR)/binutils-$(BINUTILS_VERSION).tar.bz2
	-rm -rf $(ORIGSRCDIR)/binutils-$(BINUTILS_VERSION) $(SRCDIR)/binutils
	cd $(ORIGSRCDIR) && tar xfj binutils-$(BINUTILS_VERSION).tar.bz2
	-mkdir -p $(SRCDIR)/binutils
	cp -T -r $(ORIGSRCDIR)/binutils-$(BINUTILS_VERSION) $(SRCDIR)/binutils
	cd $(SRCDIR)/binutils && $(SCRIPTSDIR)/do-patch-and-copy $(RECIPEDIR)
	-mkdir -p $(BUILDSTEPSDIR)
	touch $(BUILDSTEPSDIR)/buildstep-binutils-src

# Unpack gcc source:
$(BUILDSTEPSDIR)/buildstep-gcc-src: $(ORIGSRCDIR)/gcc-$(GCC_VERSION).tar.bz2
	-rm -rf $(ORIGSRCDIR)/gcc-$(GCC_VERSION) $(SRCDIR)/gcc
	cd $(ORIGSRCDIR) && tar xfj gcc-$(GCC_VERSION).tar.bz2
	-mkdir -p $(SRCDIR)/gcc
	cp -T -r $(ORIGSRCDIR)/gcc-$(GCC_VERSION) $(SRCDIR)/gcc
	cd $(SRCDIR)/gcc && $(SCRIPTSDIR)/do-patch-and-copy $(RECIPEDIR)
	-mkdir -p $(BUILDSTEPSDIR)
	touch $(BUILDSTEPSDIR)/buildstep-gcc-src

# Unpack newlib source:
$(BUILDSTEPSDIR)/buildstep-newlib-src: $(ORIGSRCDIR)/newlib-$(NEWLIB_VERSION).tar.gz
	-rm -rf $(ORIGSRCDIR)/newlib-$(NEWLIB_VERSION) $(SRCDIR)/newlib
	cd $(ORIGSRCDIR) && tar xfz newlib-$(NEWLIB_VERSION).tar.gz
	# FIXME: add stuff
	-mkdir -p $(BUILDSTEPSDIR)
	touch $(BUILDSTEPSDIR)/buildstep-newlib-src

# Unpack gdb source:
$(BUILDSTEPSDIR)/buildstep-gdb-src: $(ORIGSRCDIR)/gdb-$(GDB_VERSION).tar.bz2
	-rm -rf $(ORIGSRCDIR)/gdb-$(GDB_VERSION) $(SRCDIR)/gdb
	cd $(ORIGSRCDIR) && tar xfj gdb-$(GDB_VERSION).tar.bz2
	# FIXME: add stuff
	-mkdir -p $(BUILDSTEPSDIR)
	touch $(BUILDSTEPSDIR)/buildstep-gdb-src

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

