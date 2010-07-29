# Build GCCSDK
# Written by John Tytgat / BASS
#
# Needed:
#   - apt-get install flex bison libgmp3-dev libmpfr-dev texinfo build-essential
#   - binutils 2.20.1 and gcc 4.6 needs automake 1.11.1 and autoconf 2.64.
#     Note the required automake/autoconf sources will be fetched & built automatically.
#   - gcc 4.6 needs at least GMP 4.3.2, MPFR 2.4.2 and MPC 0.8.1 (MPFR needs GMP, MPC needs GMP & MPFR)
#   - gdb requires libncurses5-dev

# TARGET can have following values: arm-unknown-riscos (stable), arm-unknown-eabi (work in progress)
TARGET=arm-unknown-riscos
# TARGET=arm-unknown-eabi
GCC_LANGUAGES="c,c++"

# *_SCM variables: when set to "yes", we'll fetch the source from source control
# system and it will always be the latest version.
AUTOCONF_FOR_BINUTILS_VERSION=2.64
AUTOMAKE_FOR_BINUTILS_VERSION=1.11.1
BINUTILS_VERSION=$(GCCSDK_SUPPORTED_BINUTILS_RELEASE)
AUTOCONF_FOR_GCC_VERSION=2.64
AUTOMAKE_FOR_GCC_VERSION=1.11.1
GCC_VERSION=$(GCCSDK_SUPPORTED_GCC_RELEASE)
GCC_USE_SCM=yes
NEWLIB_VERSION=1.18.1
NEWLIB_USE_SCM=yes
GDB_VERSION=7.1
GMP_VERSION=5.0.1
MPFR_VERSION=3.0.0
MPC_VERSION=0.8.2

# Notes:
#   1) --with-cross-host is needed to correctly find the target libraries in
#      $GCCSDK_{CROSS|RISCOS}_PREFIX/arm-unknown-riscos/lib instead of
#      $GCCSDK_{CROSS|RISCOS}_PREFIX/lib.
#   2) Configure options are explained at http://gcc.gnu.org/install/configure.html
#      but note that this explanation is for the latest gcc version released and
#      not necessary the gcc version we're building here.
ifeq ($(TARGET),arm-unknown-riscos)
# Case GCCSDK arm-unknown-riscos target:
# Variations: --disable-shared vs --enable-shared=libunixlib,libgcc,libstdc++
## FIXME: --disable-shared -> --enable-shared=libunixlib,libgcc,libstdc++
## FIXME: Consider --enable-__cxa_atexit (but this is require UnixLib changes).
GCC_CONFIG_ARGS := \
	--enable-threads=posix \
	--enable-sjlj-exceptions=no \
	--enable-c99 \
	--enable-cmath \
	--enable-multilib \
	--disable-shared \
	--disable-c-mbchar \
	--disable-libstdcxx-pch \
	--disable-tls \
	--without-pic \
	--with-cross-host
# FIXME: for Java support: --without-x --enable-libgcj
BINUTILS_CONFIG_ARGS =
else
# Case arm-unknown-eabi target (use newlib):
GCC_CONFIG_ARGS := --disable-threads --disable-multilib --disable-shared --with-newlib
BINUTILS_CONFIG_ARGS := --disable-multilib --disable-shared
endif
GCC_CONFIG_ARGS += --with-pkgversion='GCCSDK GCC $(GCC_VERSION) Release 1 Development' \
	--with-bugurl=http://gccsdk.riscos.info/
BINUTILS_CONFIG_ARGS += --with-pkgversion='GCCSDK GCC $(GCC_VERSION) Release 1 Development' \
	--with-bugurl=http://gccsdk.riscos.info/
BINUTILS_CONFIG_ARGS += --enable-maintainer-mode --enable-interwork --disable-werror --with-gcc --disable-nls
## FIXME: left out --enable-maintainer-mode because of http://gcc.gnu.org/bugzilla/show_bug.cgi?id=44902
## which turns compile warnings into errors.
##GCC_CONFIG_ARGS += --enable-maintainer-mode --enable-interwork --disable-nls
GCC_CONFIG_ARGS += --enable-interwork --disable-nls
GDB_CONFIG_ARGS += --enable-interwork --disable-multilib --disable-werror --disable-nls

# When debugging/testing/validating the compiler add "--enable-checking=all",
# otherwise add "--enable-checking=release" or even "--enable-checking=no"
GCC_CONFIG_ARGS += --enable-checking=release
# Configure args shared between different targets:
# For debugging:
# FIXME: add to GCC_BUILD_FLAGS for optimized ARM libraries: CFLAGS_FOR_TARGET="-O3 -march=armv5" CXXFLAGS_FOR_TARGET="-O3 -march=armv5"
# Or perhaps better, at GCC configure time something like --with-arch=armv6 --with-tune=cortex-a8 --with-float=softfp --with-fpu=vfp ?
GCC_BUILD_FLAGS := CFLAGS="-O0 -g" LIBCXXFLAGS="-O0 -g"
##BINUTILS_BUILD_FLAGS = CFLAGS="-O0 -g"

ROOT := $(shell pwd)
PREFIX_CROSS := $(GCCSDK_CROSS_PREFIX)
PREFIX_RONATIVE := $(GCCSDK_RISCOS_PREFIX)/\!GCC
BUILDDIR := $(GCCSDK_BUILDDIR)
PREFIX_BUILDTOOL_BINUTILS := $(BUILDDIR)/installed-buildtools-for-binutils
PREFIX_BUILDTOOL_GCC := $(BUILDDIR)/installed-buildtools-for-gcc
PREFIX_CROSSGCC_LIBS := $(BUILDDIR)/installed-libs-for-cross-gcc
PREFIX_RONATIVEGCC_LIBS := $(BUILDDIR)/installed-libs-for-ronative-gcc
SRCDIR := $(GCCSDK_SRCDIR)
SRCORIGDIR := $(GCCSDK_SRCDIR).orig
SCRIPTSDIR := $(ROOT)/scripts
RECIPEDIR := $(ROOT)/recipe
RISCOSTOOLSDIR := $(GCCSDK_RISCOS)

# GCC-only configure arguments which are dependant on cross vs ronative building:
## FIXME: Added --with-system-zlib as otherwise zlib as multilib build fails
## (which shouldn't so this is a hack).
CROSS_GCC_CONFIG_ARGS := --with-gmp=$(PREFIX_CROSSGCC_LIBS) --with-mpfr=$(PREFIX_CROSSGCC_LIBS) --with-mpc=$(PREFIX_CROSSGCC_LIBS) --with-system-zlib
RONATIVE_GCC_CONFIG_ARGS := --with-gmp=$(PREFIX_RONATIVEGCC_LIBS) --with-mpfr=$(PREFIX_RONATIVEGCC_LIBS) --with-mpc=$(PREFIX_RONATIVEGCC_LIBS)

# Binutils & GCC configure args unique for cross-compiling & unique to building for RISC OS native
CROSS_CONFIG_ARGS := --target=$(TARGET) --prefix=$(PREFIX_CROSS)
# Note: --build argument can only be determined when SRCDIR is populated.
RONATIVE_CONFIG_ARGS = --build=`$(SRCDIR)/gcc/config.guess` --host=$(TARGET) --target=$(TARGET) --prefix=$(PREFIX_RONATIVE)

# To respawn Makefile with setup-gccsdk-param environment loaded.
GCCSDK_INTERNAL_GETENV=getenv
ifeq ($(MAKECMDGOALS),)
MAKECMDGOALS=all
endif

.NOTPARALLEL:
.PHONY: all cross ronative clean distclean

# Default target is to build the cross-compiler (including the RISC OS tools):
all: $(GCCSDK_INTERNAL_GETENV)
buildstepsdir/all-done: buildstepsdir/cross-all-built

# Builds the cross compiler:
cross: $(GCCSDK_INTERNAL_GETENV)
buildstepsdir/cross-all-built: buildstepsdir/cross-gcc-built \
	buildstepsdir/cross-riscostools-built
	touch buildstepsdir/cross-all-built

# Builds the native RISC OS compiler (gcc and binutils):
ronative: $(GCCSDK_INTERNAL_GETENV)
buildstepsdir/ronative-done: buildstepsdir/ronative-gcc-built \
	buildstepsdir/ronative-binutils-built \
	buildstepsdir/ronative-riscostools-built
	touch buildstepsdir/ronative-done

clean: $(GCCSDK_INTERNAL_GETENV)
buildstepsdir/clean-done:
	-rm -rf $(BUILDDIR)
	-rm -rf $(SRCDIR)
	-svn revert -R $(SRCORIGDIR)/gcc-trunk
	-svn status $(SRCORIGDIR)/gcc-trunk | grep -E "\$$?" | cut -b 9- | xargs rm -rf
	-rm -rf buildstepsdir
	-rm -rf $(PREFIX_CROSS) $(PREFIX_RONATIVE)

distclean: $(GCCSDK_INTERNAL_GETENV)
buildstepsdir/distclean-done: buildstepsdir/clean-done
	-rm -rf release-area $(SRCORIGDIR)

# Respawn Makefile again after having loaded all our GCCSDK environment variables.
ifeq ($(GCCSDK_INTERNAL_GETENV),getenv)
getenv:
	@bash -c ". ./setup-gccsdk-params && $(MAKE) $(patsubst %,buildstepsdir/%-done,$(MAKECMDGOALS)) GCCSDK_INTERNAL_GETENV="
endif

# -- Configure & building:

# Configure & build autoconf-for-binutils tool:
buildstepsdir/buildtool-autoconf-for-binutils-built: buildstepsdir/src-autoconf-for-binutils-copied
	-rm -rf $(BUILDDIR)/buildtool-autoconf-for-binutils
	mkdir -p $(BUILDDIR)/buildtool-autoconf-for-binutils
	cd $(BUILDDIR)/buildtool-autoconf-for-binutils && $(SRCDIR)/autoconf-for-binutils/configure --prefix=$(PREFIX_BUILDTOOL_BINUTILS) && $(MAKE) && $(MAKE) install
	touch buildstepsdir/buildtool-autoconf-for-binutils-built

# Configure & build autoconf-for-gcc tool:
buildstepsdir/buildtool-autoconf-for-gcc-built: buildstepsdir/src-autoconf-for-gcc-copied
	-rm -rf $(BUILDDIR)/buildtool-autoconf-for-gcc
	mkdir -p $(BUILDDIR)/buildtool-autoconf-for-gcc
	cd $(BUILDDIR)/buildtool-autoconf-for-gcc && $(SRCDIR)/autoconf-for-gcc/configure --prefix=$(PREFIX_BUILDTOOL_GCC) && $(MAKE) && $(MAKE) install
	touch buildstepsdir/buildtool-autoconf-for-gcc-built

# Configure & build automake-for-binutils tool:
buildstepsdir/buildtool-automake-for-binutils-built: buildstepsdir/src-automake-for-binutils-copied
	-rm -rf $(BUILDDIR)/buildtool-automake-for-binutils
	mkdir -p $(BUILDDIR)/buildtool-automake-for-binutils
	cd $(BUILDDIR)/buildtool-automake-for-binutils && $(SRCDIR)/automake-for-binutils/configure --prefix=$(PREFIX_BUILDTOOL_BINUTILS) && $(MAKE) && $(MAKE) install
	touch buildstepsdir/buildtool-automake-for-binutils-built

# Configure & build automake-for-gcc tool:
buildstepsdir/buildtool-automake-for-gcc-built: buildstepsdir/src-automake-for-gcc-copied
	-rm -rf $(BUILDDIR)/buildtool-automake-for-gcc
	mkdir -p $(BUILDDIR)/buildtool-automake-for-gcc
	cd $(BUILDDIR)/buildtool-automake-for-gcc && $(SRCDIR)/automake-for-gcc/configure --prefix=$(PREFIX_BUILDTOOL_GCC) && $(MAKE) && $(MAKE) install
	touch buildstepsdir/buildtool-automake-for-gcc-built

# Configure binutils cross:
buildstepsdir/cross-binutils-configured: buildstepsdir/src-binutils-copied
	-rm -rf $(BUILDDIR)/cross-binutils
	mkdir -p $(BUILDDIR)/cross-binutils
	cd $(BUILDDIR)/cross-binutils && PATH="$(PREFIX_BUILDTOOL_BINUTILS)/bin:$(PATH)" && $(SRCDIR)/binutils/configure $(CROSS_CONFIG_ARGS) $(BINUTILS_CONFIG_ARGS)
	touch buildstepsdir/cross-binutils-configured

# Build binutils cross:
buildstepsdir/cross-binutils-built: buildstepsdir/cross-binutils-configured
	cd $(BUILDDIR)/cross-binutils && PATH="$(PREFIX_BUILDTOOL_BINUTILS)/bin:$(PATH)" && $(SRCDIR)/binutils/configure $(CROSS_CONFIG_ARGS) $(BINUTILS_CONFIG_ARGS) && $(MAKE) $(BINUTILS_BUILD_FLAGS) && $(MAKE) install
	touch buildstepsdir/cross-binutils-built

# Configure ronative:
buildstepsdir/ronative-binutils-configured: buildstepsdir/src-binutils-copied buildstepsdir/cross-all-built
	-rm -rf $(BUILDDIR)/ronative-binutils
	mkdir -p $(BUILDDIR)/ronative-binutils
	cd $(BUILDDIR)/ronative-binutils && PATH="$(PREFIX_BUILDTOOL_BINUTILS)/bin:$(PREFIX_CROSS)/bin:$(PATH)" && $(SRCDIR)/binutils/configure $(RONATIVE_CONFIG_ARGS) $(BINUTILS_CONFIG_ARGS)
	touch buildstepsdir/ronative-binutils-configured

# Build binutils ronative:
buildstepsdir/ronative-binutils-built: buildstepsdir/ronative-binutils-configured
	cd $(BUILDDIR)/ronative-binutils && PATH="$(PREFIX_BUILDTOOL_BINUTILS)/bin:$(PREFIX_CROSS)/bin:$(PATH)" && $(SRCDIR)/binutils/configure $(RONATIVE_CONFIG_ARGS) $(BINUTILS_CONFIG_ARGS) && $(MAKE) $(BINUTILS_BUILD_FLAGS) && $(MAKE) install
	touch buildstepsdir/ronative-binutils-built

# Configure gcc cross:
ifneq ($(TARGET),arm-unknown-riscos)
buildstepsdir/cross-gcc-configured: buildstepsdir/src-newlib-copied
endif
buildstepsdir/cross-gcc-configured: buildstepsdir/src-gcc-copied buildstepsdir/cross-binutils-built buildstepsdir/cross-gmp-built buildstepsdir/cross-mpc-built buildstepsdir/cross-mpfr-built
	-rm -rf $(SRCDIR)/gcc/newlib
	-rm -rf $(SRCDIR)/gcc/libgloss
ifneq ($(TARGET),arm-unknown-riscos)
	ln -s $(SRCDIR)/newlib/newlib $(SRCDIR)/gcc/newlib
	ln -s $(SRCDIR)/newlib/libgloss $(SRCDIR)/gcc/libgloss
	touch buildstepsdir/src-gcc-copied
endif
	-rm -rf $(BUILDDIR)/cross-gcc
	mkdir -p $(BUILDDIR)/cross-gcc
	cd $(BUILDDIR)/cross-gcc && PATH="$(PREFIX_BUILDTOOL_GCC)/bin:$(PREFIX_CROSS)/bin:$(PATH)" && $(SRCDIR)/gcc/configure $(CROSS_CONFIG_ARGS) $(CROSS_GCC_CONFIG_ARGS) $(GCC_CONFIG_ARGS) --enable-languages=$(GCC_LANGUAGES)
	touch buildstepsdir/cross-gcc-configured

# Build gcc cross:
buildstepsdir/cross-gcc-built: buildstepsdir/cross-gcc-configured
	cd $(BUILDDIR)/cross-gcc && PATH="$(PREFIX_BUILDTOOL_GCC)/bin:$(PREFIX_CROSS)/bin:$(PATH)" && $(MAKE) $(GCC_BUILD_FLAGS) && $(MAKE) install
	touch buildstepsdir/cross-gcc-built

# Configure gcc ronative:
buildstepsdir/ronative-gcc-configured: buildstepsdir/cross-all-built buildstepsdir/ronative-gmp-built buildstepsdir/ronative-mpc-built buildstepsdir/ronative-mpfr-built
	-rm -rf $(BUILDDIR)/ronative-gcc
	mkdir -p $(BUILDDIR)/ronative-gcc
	cd $(BUILDDIR)/ronative-gcc && PATH="$(PREFIX_BUILDTOOL_GCC)/bin:$(PREFIX_CROSS)/bin:$(PATH)" && $(SRCDIR)/gcc/configure $(RONATIVE_CONFIG_ARGS) $(RONATIVE_GCC_CONFIG_ARGS) $(GCC_CONFIG_ARGS) --enable-languages=$(GCC_LANGUAGES)
	touch buildstepsdir/ronative-gcc-configured

# Build gcc ronative:
buildstepsdir/ronative-gcc-built: buildstepsdir/ronative-gcc-configured
	cd $(BUILDDIR)/ronative-gcc && PATH="$(PREFIX_BUILDTOOL_GCC)/bin:$(PREFIX_CROSS)/bin:$(PATH)" && $(MAKE) $(GCC_BUILD_FLAGS) && $(MAKE) install
	touch buildstepsdir/ronative-gcc-built

# Configure & build gdb cross:
buildstepsdir/cross-gdb-built: buildstepsdir/src-gdb-copied buildstepsdir/cross-gcc-built
	-rm -rf $(BUILDDIR)/cross-gdb
	mkdir -p $(BUILDDIR)/cross-gdb
	cd $(BUILDDIR)/cross-gdb && PATH="$(PREFIX_CROSS)/bin:$(PATH)" && $(SRCDIR)/gdb/configure $(CROSS_CONFIG_ARGS) $(GDB_CONFIG_ARGS) && $(MAKE) && $(MAKE) install
	touch buildstepsdir/cross-gdb-built

# Configure & build gmp cross:
buildstepsdir/cross-gmp-built: buildstepsdir/src-gmp-copied
	-rm -rf $(BUILDDIR)/cross-gmp
	mkdir -p $(BUILDDIR)/cross-gmp
	cd $(BUILDDIR)/cross-gmp && PATH="$(PREFIX_BUILDTOOL_GCC)/bin:$(PATH)" && $(SRCDIR)/gmp/configure --disable-shared --prefix=$(PREFIX_CROSSGCC_LIBS) && $(MAKE) && $(MAKE) install
	touch buildstepsdir/cross-gmp-built

# Configure & build gmp ronative:
buildstepsdir/ronative-gmp-built: buildstepsdir/src-gmp-copied
	-rm -rf $(BUILDDIR)/ronative-gmp
	mkdir -p $(BUILDDIR)/ronative-gmp
	cd $(BUILDDIR)/ronative-gmp && PATH="$(PREFIX_BUILDTOOL_GCC)/bin:$(PREFIX_CROSS)/bin:$(PATH)" && $(SRCDIR)/gmp/configure --disable-shared --host=$(TARGET) --prefix=$(PREFIX_RONATIVEGCC_LIBS) && $(MAKE) && $(MAKE) install
	touch buildstepsdir/ronative-gmp-built

# Configure & build mpc cross:
buildstepsdir/cross-mpc-built: buildstepsdir/src-mpc-copied buildstepsdir/cross-gmp-built buildstepsdir/cross-mpfr-built
	-rm -rf $(BUILDDIR)/cross-mpc
	mkdir -p $(BUILDDIR)/cross-mpc
	cd $(BUILDDIR)/cross-mpc && PATH="$(PREFIX_BUILDTOOL_GCC)/bin:$(PATH)" && $(SRCDIR)/mpc/configure --disable-shared --prefix=$(PREFIX_CROSSGCC_LIBS) --with-gmp=$(PREFIX_CROSSGCC_LIBS) && $(MAKE) && $(MAKE) install
	touch buildstepsdir/cross-mpc-built

# Configure & build mpc ronative:
buildstepsdir/ronative-mpc-built: buildstepsdir/src-mpc-copied buildstepsdir/ronative-gmp-built buildstepsdir/ronative-mpfr-built
	-rm -rf $(BUILDDIR)/ronative-mpc
	mkdir -p $(BUILDDIR)/ronative-mpc
	cd $(BUILDDIR)/ronative-mpc && PATH="$(PREFIX_BUILDTOOL_GCC)/bin:$(PREFIX_CROSS)/bin:$(PATH)" && $(SRCDIR)/mpc/configure --disable-shared --host=$(TARGET) --prefix=$(PREFIX_RONATIVEGCC_LIBS) --with-gmp=$(PREFIX_RONATIVEGCC_LIBS) && $(MAKE) && $(MAKE) install
	touch buildstepsdir/ronative-mpc-built

# Configure & build mpfr cross:
buildstepsdir/cross-mpfr-built: buildstepsdir/src-mpfr-copied buildstepsdir/cross-gmp-built
	-rm -rf $(BUILDDIR)/cross-mpfr
	mkdir -p $(BUILDDIR)/cross-mpfr
	cd $(BUILDDIR)/cross-mpfr && PATH="$(PREFIX_BUILDTOOL_GCC)/bin:$(PATH)" && $(SRCDIR)/mpfr/configure --disable-shared --with-gmp=$(PREFIX_CROSSGCC_LIBS) --prefix=$(PREFIX_CROSSGCC_LIBS) && $(MAKE) && $(MAKE) install
	touch buildstepsdir/cross-mpfr-built

# Configure & build mpfr ronative:
buildstepsdir/ronative-mpfr-built: buildstepsdir/src-mpfr-copied buildstepsdir/ronative-gmp-built
	-rm -rf $(BUILDDIR)/ronative-mpfr
	mkdir -p $(BUILDDIR)/ronative-mpfr
	cd $(BUILDDIR)/ronative-mpfr && PATH="$(PREFIX_BUILDTOOL_GCC)/bin:$(PREFIX_CROSS)/bin:$(PATH)" && $(SRCDIR)/mpfr/configure --disable-shared --host=$(TARGET) --with-gmp=$(PREFIX_RONATIVEGCC_LIBS) --prefix=$(PREFIX_RONATIVEGCC_LIBS) && $(MAKE) && $(MAKE) install
	touch buildstepsdir/ronative-mpfr-built

# Build the RISC OS related tools (cmunge, elf2aif, asasm, etc) cross:
buildstepsdir/cross-riscostools-built: buildstepsdir/cross-gcc-built
	cd $(RISCOSTOOLSDIR) && ./build-it cross
	touch buildstepsdir/cross-riscostools-built

# Build the RISC OS related tools (cmunge, elf2aif, asasm, etc) ronative:
buildstepsdir/ronative-riscostools-built: buildstepsdir/ronative-gcc-built
	cd $(RISCOSTOOLSDIR) && ./build-it riscos
	touch buildstepsdir/ronative-riscostools-built

# -- Source unpacking.

# Unpack autoconf-for-binutils source:
buildstepsdir/src-autoconf-for-binutils-copied: $(SRCORIGDIR)/autoconf-$(AUTOCONF_FOR_BINUTILS_VERSION).tar.bz2
	-rm -rf $(SRCORIGDIR)/autoconf-$(AUTOCONF_FOR_BINUTILS_VERSION) $(SRCDIR)/autoconf-for-binutils
	cd $(SRCORIGDIR) && tar xfj autoconf-$(AUTOCONF_FOR_BINUTILS_VERSION).tar.bz2
	-mkdir -p $(SRCDIR)/autoconf-for-binutils
	cp -T -p -r $(SRCORIGDIR)/autoconf-$(AUTOCONF_FOR_BINUTILS_VERSION) $(SRCDIR)/autoconf-for-binutils
	## cd $(SRCDIR)/autoconf-for-binutils && $(SCRIPTSDIR)/do-patch-and-copy $(RECIPEDIR)
	-mkdir -p buildstepsdir
	touch buildstepsdir/src-autoconf-for-binutils-copied

# Unpack autoconf-for-gcc source:
buildstepsdir/src-autoconf-for-gcc-copied: $(SRCORIGDIR)/autoconf-$(AUTOCONF_FOR_GCC_VERSION).tar.bz2
	-rm -rf $(SRCORIGDIR)/autoconf-$(AUTOCONF_FOR_GCC_VERSION) $(SRCDIR)/autoconf-for-gcc
	cd $(SRCORIGDIR) && tar xfj autoconf-$(AUTOCONF_FOR_GCC_VERSION).tar.bz2
	-mkdir -p $(SRCDIR)/autoconf-for-gcc
	cp -T -p -r $(SRCORIGDIR)/autoconf-$(AUTOCONF_FOR_GCC_VERSION) $(SRCDIR)/autoconf-for-gcc
	## cd $(SRCDIR)/autoconf-for-gcc && $(SCRIPTSDIR)/do-patch-and-copy $(RECIPEDIR)
	-mkdir -p buildstepsdir
	touch buildstepsdir/src-autoconf-for-gcc-copied

# Unpack automake-for-binutils source:
buildstepsdir/src-automake-for-binutils-copied: $(SRCORIGDIR)/automake-$(AUTOMAKE_FOR_BINUTILS_VERSION).tar.bz2
	-rm -rf $(SRCORIGDIR)/automake-$(AUTOMAKE_FOR_BINUTILS_VERSION) $(SRCDIR)/automake-for-binutils
	cd $(SRCORIGDIR) && tar xfj automake-$(AUTOMAKE_FOR_BINUTILS_VERSION).tar.bz2
	-mkdir -p $(SRCDIR)/automake-for-binutils
	cp -T -p -r $(SRCORIGDIR)/automake-$(AUTOMAKE_FOR_BINUTILS_VERSION) $(SRCDIR)/automake-for-binutils
	## cd $(SRCDIR)/automake-for-binutils && $(SCRIPTSDIR)/do-patch-and-copy $(RECIPEDIR)
	-mkdir -p buildstepsdir
	touch buildstepsdir/src-automake-for-binutils-copied

# Unpack automake-for-gcc source:
buildstepsdir/src-automake-for-gcc-copied: $(SRCORIGDIR)/automake-$(AUTOMAKE_FOR_GCC_VERSION).tar.bz2
	-rm -rf $(SRCORIGDIR)/automake-$(AUTOMAKE_FOR_GCC_VERSION) $(SRCDIR)/automake-for-gcc
	cd $(SRCORIGDIR) && tar xfj automake-$(AUTOMAKE_FOR_GCC_VERSION).tar.bz2
	-mkdir -p $(SRCDIR)/automake-for-gcc
	cp -T -p -r $(SRCORIGDIR)/automake-$(AUTOMAKE_FOR_GCC_VERSION) $(SRCDIR)/automake-for-gcc
	## cd $(SRCDIR)/automake-for-gcc && $(SCRIPTSDIR)/do-patch-and-copy $(RECIPEDIR)
	-mkdir -p buildstepsdir
	touch buildstepsdir/src-automake-for-gcc-copied

# Unpack binutils source:
buildstepsdir/src-binutils-copied: $(SRCORIGDIR)/binutils-$(BINUTILS_VERSION).tar.bz2 buildstepsdir/buildtool-autoconf-for-binutils-built buildstepsdir/buildtool-automake-for-binutils-built
	-rm -rf $(SRCORIGDIR)/binutils-$(BINUTILS_VERSION) $(SRCDIR)/binutils
	cd $(SRCORIGDIR) && tar xfj binutils-$(BINUTILS_VERSION).tar.bz2
	-mkdir -p $(SRCDIR)/binutils
	cp -T -p -r $(SRCORIGDIR)/binutils-$(BINUTILS_VERSION) $(SRCDIR)/binutils
ifeq ($(TARGET),arm-unknown-riscos)
	cd $(SRCDIR)/binutils && PATH="$(PREFIX_BUILDTOOL_BINUTILS)/bin:$(PATH)" && $(SCRIPTSDIR)/do-patch-and-copy $(RECIPEDIR)
endif
	-mkdir -p buildstepsdir
	touch buildstepsdir/src-binutils-copied

# Unpack or checkout the gcc source:
buildstepsdir/src-gcc-copied: buildstepsdir/buildtool-autoconf-for-gcc-built buildstepsdir/buildtool-automake-for-gcc-built
ifeq "$(GCC_USE_SCM)" "yes"
buildstepsdir/src-gcc-copied: $(SRCORIGDIR)/gcc-trunk/LAST_UPDATED
	-rm -rf $(SRCDIR)/gcc
	-svn revert -R $(SRCORIGDIR)/gcc-trunk
	-svn status $(SRCORIGDIR)/gcc-trunk | grep -E "\$$?" | cut -b 9- | xargs rm -rf
	ln -s $(SRCORIGDIR)/gcc-trunk $(SRCDIR)/gcc
else
buildstepsdir/src-gcc-copied: $(SRCORIGDIR)/gcc-$(GCC_VERSION).tar.bz2
	-rm -rf $(SRCORIGDIR)/gcc-$(GCC_VERSION) $(SRCDIR)/gcc
	cd $(SRCORIGDIR) && tar xfj gcc-$(GCC_VERSION).tar.bz2
	-mkdir -p $(SRCDIR)/gcc
	cp -T -p -r $(SRCORIGDIR)/gcc-$(GCC_VERSION) $(SRCDIR)/gcc
endif
ifeq ($(TARGET),arm-unknown-riscos)
	cd $(SRCDIR)/gcc && PATH="$(PREFIX_BUILDTOOL_GCC)/bin:$(PATH)" && $(SCRIPTSDIR)/do-patch-and-copy $(RECIPEDIR)
endif
	-mkdir -p buildstepsdir
	touch buildstepsdir/src-gcc-copied

# Unpack gdb source:
buildstepsdir/src-gdb-copied: $(SRCORIGDIR)/gdb-$(GDB_VERSION).tar.bz2
	-rm -rf $(SRCORIGDIR)/gdb-$(GDB_VERSION) $(SRCDIR)/gdb
	cd $(SRCORIGDIR) && tar xfj gdb-$(GDB_VERSION).tar.bz2
	cp -T -p -r $(SRCORIGDIR)/gdb-$(GDB_VERSION) $(SRCDIR)/gdb
	-mkdir -p buildstepsdir
	touch buildstepsdir/src-gdb-copied

# Unpack gmp source:
buildstepsdir/src-gmp-copied: $(SRCORIGDIR)/gmp-$(GMP_VERSION).tar.gz
	-rm -rf $(SRCORIGDIR)/gmp-$(GMP_VERSION) $(SRCDIR)/gmp
	cd $(SRCORIGDIR) && tar xfz $(SRCORIGDIR)/gmp-$(GMP_VERSION).tar.gz
	cp -T -p -r $(SRCORIGDIR)/gmp-$(GMP_VERSION) $(SRCDIR)/gmp
	-mkdir -p buildstepsdir
	touch buildstepsdir/src-gmp-copied

# Unpack mpc source:
buildstepsdir/src-mpc-copied: $(SRCORIGDIR)/mpc-$(MPC_VERSION).tar.gz
	-rm -rf $(SRCORIGDIR)/mpc-$(MPC_VERSION) $(SRCDIR)/mpc
	cd $(SRCORIGDIR) && tar xfz $(SRCORIGDIR)/mpc-$(MPC_VERSION).tar.gz
	cp -T -p -r $(SRCORIGDIR)/mpc-$(MPC_VERSION) $(SRCDIR)/mpc
	-mkdir -p buildstepsdir
	touch buildstepsdir/src-mpc-copied

# Unpack mpfr source:
buildstepsdir/src-mpfr-copied: $(SRCORIGDIR)/mpfr-$(MPFR_VERSION).tar.gz
	-rm -rf $(SRCORIGDIR)/mpfr-$(MPFR_VERSION) $(SRCDIR)/mpfr
	cd $(SRCORIGDIR) && tar xfz $(SRCORIGDIR)/mpfr-$(MPFR_VERSION).tar.gz
	cp -T -p -r $(SRCORIGDIR)/mpfr-$(MPFR_VERSION) $(SRCDIR)/mpfr
	-mkdir -p buildstepsdir
	touch buildstepsdir/src-mpfr-copied

# Unpack newlib source:
ifeq "$(NEWLIB_USE_SCM)" "yes"
buildstepsdir/src-newlib-copied:
	-rm -rf $(SRCDIR)/newlib
	cd $(SRCORIGDIR) && cvs -z 9 -d :pserver:anoncvs@sources.redhat.com:/cvs/src co newlib
	mv $(SRCORIGDIR)/src $(SRCORIGDIR)/newlib-$(NEWLIB_VERSION)
	ln -s $(SRCORIGDIR)/newlib-$(NEWLIB_VERSION) $(SRCDIR)/newlib
	-mkdir -p buildstepsdir
	touch buildstepsdir/src-newlib-copied
else
buildstepsdir/src-newlib-copied: $(SRCORIGDIR)/newlib-$(NEWLIB_VERSION).tar.gz
	-rm -rf $(SRCORIGDIR)/newlib-$(NEWLIB_VERSION) $(SRCDIR)/newlib
	cd $(SRCORIGDIR) && tar xfz newlib-$(NEWLIB_VERSION).tar.gz
	cp -T -p -r $(SRCORIGDIR)/newlib-$(NEWLIB_VERSION) $(SRCDIR)/newlib
	-mkdir -p buildstepsdir
	touch buildstepsdir/src-newlib-copied
endif

# -- Source downloading.

# Download autoconf source to be used to build binutils:
$(SRCORIGDIR)/autoconf-$(AUTOCONF_FOR_BINUTILS_VERSION).tar.bz2:
	-mkdir -p $(SRCORIGDIR)
	cd $(SRCORIGDIR) && wget -c http://ftp.gnu.org/gnu/autoconf/autoconf-$(AUTOCONF_FOR_BINUTILS_VERSION).tar.bz2

# Download automake source to be used to build automake:
$(SRCORIGDIR)/automake-$(AUTOMAKE_FOR_BINUTILS_VERSION).tar.bz2:
	-mkdir -p $(SRCORIGDIR)
	cd $(SRCORIGDIR) && wget -c http://ftp.gnu.org/gnu/automake/automake-$(AUTOMAKE_FOR_BINUTILS_VERSION).tar.bz2

ifneq ($(AUTOCONF_FOR_BINUTILS_VERSION),$(AUTOCONF_FOR_GCC_VERSION))
# Download autoconf source to be used to build gcc:
$(SRCORIGDIR)/autoconf-$(AUTOCONF_FOR_GCC_VERSION).tar.bz2:
	-mkdir -p $(SRCORIGDIR)
	cd $(SRCORIGDIR) && wget -c http://ftp.gnu.org/gnu/autoconf/autoconf-$(AUTOCONF_FOR_GCC_VERSION).tar.bz2
endif

ifneq ($(AUTOMAKE_FOR_BINUTILS_VERSION),$(AUTOMAKE_FOR_GCC_VERSION))
# Download automake source to be used to build gcc:
$(SRCORIGDIR)/automake-$(AUTOMAKE_FOR_GCC_VERSION).tar.bz2:
	-mkdir -p $(SRCORIGDIR)
	cd $(SRCORIGDIR) && wget -c http://ftp.gnu.org/gnu/automake/automake-$(AUTOMAKE_FOR_GCC_VERSION).tar.bz2
endif

# Download binutils source:
$(SRCORIGDIR)/binutils-$(BINUTILS_VERSION).tar.bz2:
	-mkdir -p $(SRCORIGDIR)
	cd $(SRCORIGDIR) && wget -c http://ftp.gnu.org/gnu/binutils/binutils-$(BINUTILS_VERSION).tar.bz2

ifeq "$(GCC_USE_SCM)" "yes"
# Checkout gcc source:
$(SRCORIGDIR)/gcc-trunk/LAST_UPDATED:
	-mkdir -p $(SRCORIGDIR)
	cd $(SRCORIGDIR) && svn co svn://gcc.gnu.org/svn/gcc/trunk gcc-trunk
	cd $(SRCORIGDIR)/gcc-trunk && ./contrib/gcc_update
else
# Download gcc source:
$(SRCORIGDIR)/gcc-$(GCC_VERSION).tar.bz2:
	-mkdir -p $(SRCORIGDIR)
	cd $(SRCORIGDIR) && wget -c http://ftp.gnu.org/gnu/gcc/gcc-$(GCC_VERSION)/gcc-$(GCC_VERSION).tar.bz2
endif

# Download gdb source:
$(SRCORIGDIR)/gdb-$(GDB_VERSION).tar.bz2:
	-mkdir -p $(SRCORIGDIR)
	cd $(SRCORIGDIR) && wget -c http://ftp.gnu.org/gnu/gdb/gdb-$(GDB_VERSION).tar.bz2

# Download gmp source:
$(SRCORIGDIR)/gmp-$(GMP_VERSION).tar.gz:
	-mkdir -p $(SRCORIGDIR)
	cd $(SRCORIGDIR) && wget -c ftp://ftp.gmplib.org/pub/gmp-$(GMP_VERSION)/gmp-$(GMP_VERSION).tar.gz

# Download mpc source:
$(SRCORIGDIR)/mpc-$(MPC_VERSION).tar.gz:
	-mkdir -p $(SRCORIGDIR)
	cd $(SRCORIGDIR) && wget -c http://www.multiprecision.org/mpc/download/mpc-$(MPC_VERSION).tar.gz

# Download mpfr source:
$(SRCORIGDIR)/mpfr-$(MPFR_VERSION).tar.gz:
	-mkdir -p $(SRCORIGDIR)
	cd $(SRCORIGDIR) && wget -c http://www.mpfr.org/mpfr-current/mpfr-$(MPFR_VERSION).tar.gz

# Download newlib source:
$(SRCORIGDIR)/newlib-$(NEWLIB_VERSION).tar.gz:
	-mkdir -p $(SRCORIGDIR)
	cd $(SRCORIGDIR) && wget -c ftp://sources.redhat.com/pub/newlib/newlib-$(NEWLIB_VERSION).tar.gz

