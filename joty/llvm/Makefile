# Makefile building llvm world (llvm, clang, llvm-gcc)
# Status: Experimental
# Written by John Tytgat <John.Tytgat@aaug.net>
#
# To build (llvm-gcc is default):
#   $ make llvm-gcc
# or
#   $ make clang
#
# Currently building clang involved building llvm-gcc as well as the latter
# is used for linking.
#
# Possibly with argument: "RTLIB=newlib" (unixlib is default).
#
# To clean:
#   $ make clean
# or
#   $ make distclean

# Define runtime lib (either "unixlib" or "newlib"):
RTLIB := unixlib

# ------------------------------------------------------------------

ROOT := $(shell pwd)

SRCDIR := $(ROOT)/src
SRCDIR_BINUTILS := $(SRCDIR)/binutils
SRCDIR_LLVMBASE := $(SRCDIR)/svn-llvm-base
SRCDIR_LLVMCLANG := $(SRCDIR)/svn-llvm-clang
SRCDIR_LLVMGCC := $(SRCDIR)/svn-llvm-gcc
SRCDIR_UNIXLIB := $(SRCDIR)/libunixlib
SRCDIR_NEWLIB := $(SRCDIR)/newlib
SRCORIGDIR := $(ROOT)/src.orig

BUILDDIR := $(ROOT)/builddir
BUILDDIR_CROSS_LLVM := $(BUILDDIR)/cross-llvm
BUILDDIR_CROSS_LLVMCLANG := $(BUILDDIR)/cross-llvm-clang
BUILDDIR_CROSS_LLVMGCC := $(BUILDDIR)/cross-llvm-gcc
PREFIX_BUILDTOOLS_GCC := $(BUILDDIR)/installed-buildtools-for-gcc

BUILDSTEPSDIR := $(ROOT)/buildsteps
SCRIPTSDIR := $(ROOT)/scripts
RECIPEDIR := $(ROOT)/recipe

PREFIX_CROSS := $(ROOT)/install

AUTOCONF_FOR_GCC_VERSION := 2.59
AUTOMAKE_FOR_GCC_VERSION := 1.9.6
BINUTILS_VERSION := 2.20.1
NEWLIB_VERSION := 1.18.0

TARGET := arm-unknown-eabi

# For some wierd reason, libtool used in GCC needs the environment variable LTCONFIG_VERSION defined.
GCC_ENV := LTCONFIG_VERSION=1.4a-GCC3.0
# When building UnixLib we don't want to have dl related library to be found during its configure.
ifeq ($(RTLIB),unixlib)
GCC_ENV += ac_cv_func_shl_load=no ac_cv_lib_dld_shl_load=no ac_cv_func_dlopen=no ac_cv_lib_dl_dlopen=no ac_cv_lib_svld_dlopen=no ac_cv_lib_dld_dld_link=no
endif

# Configure args unique for cross-compiling & unique to building for RISC OS native
CROSS_CONFIG_ARGS := --target=$(TARGET) --prefix=$(PREFIX_CROSS)
BINUTILS_CONFIGURE_ARGS := --enable-interwork --disable-multilib --disable-shared --disable-werror --with-gcc --disable-nls
GCC_CONFIGURE_ARGS := --disable-threads --enable-interwork --disable-multilib --disable-shared --disable-nls --with-arch=armv4
# --with-tune=strongarm --with-float=softfp --with-mode=arm
# FIXME: GCC_CONFIG_ARGS += --with-pkgversion='GCCSDK GCC $(GCC_VERSION) Release 3 Development' --with-bugurl=http://gccsdk.riscos.info/
ifeq ($(RTLIB),newlib)
GCC_CONFIGURE_ARGS += --with-newlib
else
# --with-cross-host is needed to correctly find the target libraries in
#   $GCCSDK_{CROSS|RISCOS}_PREFIX/arm-unknown-riscos/lib instead of $GCCSDK_{CROSS|RISCOS}_PREFIX/lib
# See UnixLib's configure.ac (FIXME: why is this not needed for newlib ?).
GCC_CONFIGURE_ARGS += --with-cross-host
endif

GCC_BUILD_FLAGS := CFLAGS="-O0 -g" LIBCFLAGS="-O0 -g" LIBCXXFLAGS="-O0 -g" CFLAGS_FOR_TARGET="-O3" CXXFLAGS_FOR_TARGET="-O3"

.PHONY: all clean distclean clang llvm-gcc
all: llvm-gcc

clean:
	-rm -rf $(BUILDDIR) $(SRCDIR_BINUTILS) buildstepsdir

distclean:
	-rm -rf $(BUILDDIR) $(SRCDIR_BINUTILS) buildstepsdir $(PREFIX_CROSS)

clang: buildstepsdir/cross-clang-builddone

llvm-gcc: buildstepsdir/cross-llvm-gcc-builddone

# -- Configure & building:

# --- autoconf / automake:

# Configure & build autoconf-for-gcc tool:
buildstepsdir/buildtool-autoconf-for-gcc: buildstepsdir/src-autoconf-for-gcc
	-rm -rf $(BUILDDIR)/buildtool-autoconf-for-gcc
	mkdir -p $(BUILDDIR)/buildtool-autoconf-for-gcc
	cd $(BUILDDIR)/buildtool-autoconf-for-gcc && $(SRCDIR)/autoconf-for-gcc/configure --prefix=$(PREFIX_BUILDTOOLS_GCC) && $(MAKE) && $(MAKE) install
	touch buildstepsdir/buildtool-autoconf-for-gcc

# Configure & build automake-for-gcc tool:
buildstepsdir/buildtool-automake-for-gcc: buildstepsdir/src-automake-for-gcc buildstepsdir/buildtool-autoconf-for-gcc
	-rm -rf $(BUILDDIR)/buildtool-automake-for-gcc
	mkdir -p $(BUILDDIR)/buildtool-automake-for-gcc
	cd $(BUILDDIR)/buildtool-automake-for-gcc && $(SRCDIR)/automake-for-gcc/configure --prefix=$(PREFIX_BUILDTOOLS_GCC) && $(MAKE) && $(MAKE) install
	touch buildstepsdir/buildtool-automake-for-gcc

# --- binutils:

# Configure binutils cross:
buildstepsdir/cross-binutils-configure: buildstepsdir/src-binutils
	-rm -rf $(BUILDDIR)/cross-binutils
	mkdir -p $(BUILDDIR)/cross-binutils
	cd $(BUILDDIR)/cross-binutils && $(SRCDIR)/binutils/configure $(CROSS_CONFIG_ARGS) $(BINUTILS_CONFIGURE_ARGS)
	touch buildstepsdir/cross-binutils-configure

# Build binutils cross:
buildstepsdir/cross-binutils-builddone: buildstepsdir/cross-binutils-configure
	cd $(BUILDDIR)/cross-binutils && make
	cd $(BUILDDIR)/cross-binutils && make install
	touch buildstepsdir/cross-binutils-builddone

# --- clang (including building llvm):

# Configure clang:
# Currently we require llvm-gcc as there the runtime library is built + a 'gcc' which can be used
# for linking.
# FIXME: current no opt:  --enable-optimized
buildstepsdir/cross-clang-configure: buildstepsdir/cross-binutils-builddone buildstepsdir/cross-llvm-gcc-builddone
	-rm -rf $(BUILDDIR_CROSS_LLVMCLANG)
	mkdir -p $(BUILDDIR_CROSS_LLVMCLANG)
	svn revert -R $(SRCDIR_LLVMCLANG)
	cd $(SRCDIR_LLVMCLANG) && $(SCRIPTSDIR)/do-patch $(RECIPEDIR)
	cd $(BUILDDIR_CROSS_LLVMCLANG) && $(SRCDIR_LLVMCLANG)/configure $(CROSS_CONFIG_ARGS) --enable-assertions --enable-targets=arm --with-c-include-dirs=$(PREFIX_CROSS)/$(TARGET)/include
	mkdir -p buildstepsdir && touch buildstepsdir/cross-clang-configure

# Build clang:
buildstepsdir/cross-clang-builddone: buildstepsdir/cross-clang-configure
	mkdir -p $(PREFIX_CROSS)/bin
	if [ ! -f $(PREFIX_CROSS)/bin/gcc ] ; then ln -s $(PREFIX_CROSS)/bin/$(TARGET)-gcc $(PREFIX_CROSS)/bin/gcc ; fi
	cd $(BUILDDIR_CROSS_LLVMCLANG) && make
	cd $(BUILDDIR_CROSS_LLVMCLANG) && make install
	mkdir -p buildstepsdir && touch buildstepsdir/cross-clang-builddone

# --- llvm base (only for llvm-gcc usage):

# Configure llvm:
# FIXME: current no opt:  --enable-optimized
buildstepsdir/cross-llvm-configure:
	-rm -rf $(BUILDDIR_CROSS_LLVM)
	mkdir -p $(BUILDDIR_CROSS_LLVM)
	cd $(BUILDDIR_CROSS_LLVM) && $(SRCDIR_LLVMBASE)/configure $(CROSS_CONFIG_ARGS) --enable-assertions --enable-targets=arm --with-llvmgccdir=$(PREFIX_CROSS)/bin
	mkdir -p buildstepsdir && touch buildstepsdir/cross-llvm-configure

# Build llvm:
buildstepsdir/cross-llvm-builddone: buildstepsdir/cross-llvm-configure
	cd $(BUILDDIR_CROSS_LLVM) && make
	cd $(BUILDDIR_CROSS_LLVM) && make install
	mkdir -p buildstepsdir && touch buildstepsdir/cross-llvm-builddone

# --- llvm-gcc:

# Configure gcc:
ifeq ($(RTLIB),newlib)
buildstepsdir/cross-llvm-gcc-configure: buildstepsdir/src-newlib-in-gcc
else ifeq ($(RTLIB),unixlib)
# Integrating UnixLib in gcc requires regenerating some of the autotools files so build the
# required versions of autoconf and automake.
buildstepsdir/cross-llvm-gcc-configure: buildstepsdir/src-unixlib-in-gcc buildstepsdir/buildtool-autoconf-for-gcc buildstepsdir/buildtool-automake-for-gcc
endif
buildstepsdir/cross-llvm-gcc-configure: buildstepsdir/cross-binutils-builddone buildstepsdir/cross-llvm-builddone
	-rm -rf $(BUILDDIR_CROSS_LLVMGCC)
	mkdir -p $(BUILDDIR_CROSS_LLVMGCC)
ifeq ($(RTLIB),unixlib)
	svn revert -R $(SRCDIR_LLVMGCC)
	cd $(SRCDIR_LLVMGCC) && $(SCRIPTSDIR)/do-patch $(RECIPEDIR)
	cd $(SRCDIR_LLVMGCC)/libunixlib && PATH="$(PREFIX_BUILDTOOLS_GCC)/bin:$(PATH)" && aclocal -I .. -I ../config && autoheader && automake -a && autoconf
	cd $(SRCDIR_LLVMGCC)/libstdc++-v3 && PATH="$(PREFIX_BUILDTOOLS_GCC)/bin:$(PATH)" && aclocal -I . -I .. -I ../config && autoheader && automake -a && autoconf
	cd $(SRCDIR_LLVMGCC) && PATH="$(PREFIX_BUILDTOOLS_GCC)/bin:$(PATH)" && autogen Makefile.def && autoconf
endif
	cd $(BUILDDIR_CROSS_LLVMGCC) && PATH="$(PREFIX_BUILDTOOLS_GCC)/bin:$(PREFIX_CROSS)/bin:$(PATH)" && $(GCC_ENV) $(SRCDIR_LLVMGCC)/configure $(GCC_CONFIGURE_ARGS) $(CROSS_CONFIG_ARGS) --enable-languages=c,c++ --without-headers --enable-checking --enable-llvm=$(BUILDDIR_CROSS_LLVM)
	mkdir -p buildstepsdir && touch buildstepsdir/cross-llvm-gcc-configure

# Build gcc:
buildstepsdir/cross-llvm-gcc-builddone: buildstepsdir/cross-llvm-gcc-configure
	cd $(BUILDDIR_CROSS_LLVMGCC) && PATH="$(PREFIX_BUILDTOOLS_GCC)/bin:$(PREFIX_CROSS)/bin:$(PATH)" && $(GCC_ENV) make $(GCC_BUILD_FLAGS) && make install
	mkdir -p buildstepsdir && touch buildstepsdir/cross-llvm-gcc-builddone

# -- Source unpacking.

# Unpack autoconf-for-gcc source:
buildstepsdir/src-autoconf-for-gcc: $(SRCORIGDIR)/autoconf-$(AUTOCONF_FOR_GCC_VERSION).tar.bz2
	-rm -rf $(SRCORIGDIR)/autoconf-$(AUTOCONF_FOR_GCC_VERSION) $(SRCDIR)/autoconf-for-gcc
	cd $(SRCORIGDIR) && tar xfj autoconf-$(AUTOCONF_FOR_GCC_VERSION).tar.bz2
	-mkdir -p $(SRCDIR)/autoconf-for-gcc
	cp -T -p -r $(SRCORIGDIR)/autoconf-$(AUTOCONF_FOR_GCC_VERSION) $(SRCDIR)/autoconf-for-gcc
	-mkdir -p buildstepsdir
	touch buildstepsdir/src-autoconf-for-gcc

# Unpack automake-for-gcc source:
buildstepsdir/src-automake-for-gcc: $(SRCORIGDIR)/automake-$(AUTOMAKE_FOR_GCC_VERSION).tar.bz2
	-rm -rf $(SRCORIGDIR)/automake-$(AUTOMAKE_FOR_GCC_VERSION) $(SRCDIR)/automake-for-gcc
	cd $(SRCORIGDIR) && tar xfj automake-$(AUTOMAKE_FOR_GCC_VERSION).tar.bz2
	-mkdir -p $(SRCDIR)/automake-for-gcc
	cp -T -p -r $(SRCORIGDIR)/automake-$(AUTOMAKE_FOR_GCC_VERSION) $(SRCDIR)/automake-for-gcc
	-mkdir -p buildstepsdir
	touch buildstepsdir/src-automake-for-gcc

# Unpack binutils source:
buildstepsdir/src-binutils: $(SRCORIGDIR)/binutils-$(BINUTILS_VERSION).tar.bz2
	-rm -rf $(SRCORIGDIR)/binutils-$(BINUTILS_VERSION) $(SRCDIR_BINUTILS)
	cd $(SRCORIGDIR) && tar xfj binutils-$(BINUTILS_VERSION).tar.bz2
	cp -r -p $(SRCORIGDIR)/binutils-$(BINUTILS_VERSION) $(SRCDIR_BINUTILS)
	mkdir -p buildstepsdir && touch buildstepsdir/src-binutils

# Link in newlib in gcc (no patching is necessary):
buildstepsdir/src-newlib-in-gcc: buildstepsdir/src-newlib
	if [ -d $(SRCDIR_LLVMGCC)/libunixlib ] ; then rm -rf $(SRCDIR_LLVMGCC)/libunixlib ; fi
	$(SCRIPTSDIR)/do-softlink-dir $(SRCDIR_NEWLIB)/newlib $(SRCDIR_LLVMGCC)/newlib
	$(SCRIPTSDIR)/do-softlink-dir $(SRCDIR_NEWLIB)/libgloss $(SRCDIR_LLVMGCC)/libgloss
	mkdir -p buildstepsdir && touch buildstepsdir/src-newlib-in-gcc

# Patch UnixLib, link in unixlib in gcc and generate the autotool files:
buildstepsdir/src-unixlib-in-gcc:
	if [ -d $(SRCDIR_LLVMGCC)/newlib ] ; then rm -rf $(SRCDIR_LLVMGCC)/newlib ; fi
	if [ -d $(SRCDIR_LLVMGCC)/libgloss ] ; then rm -rf $(SRCDIR_LLVMGCC)/libgloss ; fi
	svn revert -R $(SRCDIR_UNIXLIB)
	cd $(SRCDIR_UNIXLIB) && $(SCRIPTSDIR)/do-patch $(RECIPEDIR)
	$(SCRIPTSDIR)/do-softlink-dir $(SRCDIR_UNIXLIB) $(SRCDIR_LLVMGCC)/libunixlib
	$(SRCDIR_LLVMGCC)/libunixlib/gen-auto.pl
	# Not needed and will even break the build: cd $(SRCDIR_LLVMGCC)/libunixlib && cp libtool-org.m4 libtool.m4 && patch -p0 < libtool.m4.p
	mkdir -p buildstepsdir && touch buildstepsdir/src-unixlib-in-gcc

# Unpack newlib source in $(SRCDIR_NEWLIB) :
buildstepsdir/src-newlib: $(SRCORIGDIR)/newlib-$(NEWLIB_VERSION).tar.gz
	-rm -rf $(SRCORIGDIR)/newlib-$(NEWLIB_VERSION) $(SRCDIR_NEWLIB)
	cd $(SRCORIGDIR) && tar xzf newlib-$(NEWLIB_VERSION).tar.gz
	cp -r -p $(SRCORIGDIR)/newlib-$(NEWLIB_VERSION) $(SRCDIR_NEWLIB)
	mkdir -p buildstepsdir && touch buildstepsdir/src-newlib

# -- Source downloading.

# Download autoconf source to be used to build gcc:
$(SRCORIGDIR)/autoconf-$(AUTOCONF_FOR_GCC_VERSION).tar.bz2:
	-rm $(SRCORIGDIR)/autoconf-$(AUTOCONF_FOR_GCC_VERSION).tar.bz2
	-mkdir -p $(SRCORIGDIR)
	cd $(SRCORIGDIR) && wget -c http://ftp.gnu.org/gnu/autoconf/autoconf-$(AUTOCONF_FOR_GCC_VERSION).tar.bz2

# Download automake source to be used to build gcc:
$(SRCORIGDIR)/automake-$(AUTOMAKE_FOR_GCC_VERSION).tar.bz2:
	-rm $(SRCORIGDIR)/automake-$(AUTOMAKE_FOR_GCC_VERSION).tar.bz2
	-mkdir -p $(SRCORIGDIR)
	cd $(SRCORIGDIR) && wget -c http://ftp.gnu.org/gnu/automake/automake-$(AUTOMAKE_FOR_GCC_VERSION).tar.bz2

# Download binutils source:
$(SRCORIGDIR)/binutils-$(BINUTILS_VERSION).tar.bz2:
	-rm $(SRCORIGDIR)/binutils-$(BINUTILS_VERSION).tar.bz2
	-mkdir -p $(SRCORIGDIR)
	cd $(SRCORIGDIR) && wget -c http://ftp.gnu.org/gnu/binutils/binutils-$(BINUTILS_VERSION).tar.bz2

# Download newlib source:
$(SRCORIGDIR)/newlib-$(NEWLIB_VERSION).tar.gz:
	-rm $(SRCORIGDIR)/newlib-$(NEWLIB_VERSION).tar.gz
	-mkdir -p $(SRCORIGDIR)
	cd $(SRCORIGDIR) && wget -c ftp://sourceware.org/pub/newlib/newlib-$(NEWLIB_VERSION).tar.gz

