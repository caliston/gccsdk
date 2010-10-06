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
SRCDIR_AUTOCONF_BINUTILS := $(SRCDIR)/autoconf-for-binutils
SRCDIR_AUTOCONF_GCC := $(SRCDIR)/autoconf-for-gcc
SRCDIR_AUTOMAKE_BINUTILS := $(SRCDIR)/automake-for-binutils
SRCDIR_AUTOMAKE_GCC := $(SRCDIR)/automake-for-gcc
SRCDIR_BINUTILS := $(SRCDIR)/binutils
SRCDIR_NEWLIB := $(SRCDIR)/newlib
##SRCDIR_COMPILER_RT := $(SRCDIR)/svn-compiler-rt
##SRCDIR_LIBCXX := $(SRCDIR)/svn-libcxx
SRCDIR_LLVMBASE := $(SRCDIR)/svn-llvm-base
SRCDIR_LLVMCLANG := $(SRCDIR)/svn-llvm-clang
SRCDIR_LLVMGCC := $(SRCDIR)/svn-llvm-gcc
SRCDIR_UNIXLIB := $(SRCDIR)/svn-libunixlib
SRCORIGDIR := $(ROOT)/src.orig

BUILDDIR := $(ROOT)/builddir
BUILDDIR_CROSS_LLVM := $(BUILDDIR)/cross-llvm
BUILDDIR_CROSS_LLVMCLANG := $(BUILDDIR)/cross-llvm-clang
BUILDDIR_CROSS_LLVMGCC := $(BUILDDIR)/cross-llvm-gcc
PREFIX_BUILDTOOLS_BINUTILS := $(BUILDDIR)/installed-buildtools-for-binutils
PREFIX_BUILDTOOLS_GCC := $(BUILDDIR)/installed-buildtools-for-gcc

BUILDSTEPSDIR := $(ROOT)/buildstepsdir
SCRIPTSDIR := $(ROOT)/scripts
RECIPEDIR := $(ROOT)/recipe

PREFIX_CROSS := $(ROOT)/install

# autoconf/automake versions for binutils 2.20.1, 2.21:
AUTOCONF_FOR_BINUTILS_VERSION := 2.64
AUTOMAKE_FOR_BINUTILS_VERSION := 1.11.1
BINUTILS_USE_SCM := yes
ifneq "$(BINUTILS_USE_SCM)" "yes"
BINUTILS_VERSION := 2.20.1
endif
# autoconf/automake versions for gcc 4.2:
AUTOCONF_FOR_GCC_VERSION := 2.59
AUTOMAKE_FOR_GCC_VERSION := 1.9.6
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
BINUTILS_CONFIGURE_ARGS := --enable-interwork --disable-multilib --disable-shared --disable-nls --disable-werror --enable-maintainer-mode
BINUTILS_CONFIGURE_ARGS += --with-pkgversion='GCCSDK LLVM/Clang Development' --with-bugurl=http://gccsdk.riscos.info/
# FIXME: --enable-gold --enable-plugins
GCC_CONFIGURE_ARGS := --enable-interwork --disable-multilib --disable-shared --disable-nls --disable-threads --with-arch=armv4
# --with-tune=strongarm --with-float=softfp --with-mode=arm
# FIXME: GCC_CONFIGURE_ARGS += --with-pkgversion='GCCSDK GCC $(GCC_VERSION) Release 3 Development' --with-bugurl=http://gccsdk.riscos.info/
ifeq ($(RTLIB),newlib)
GCC_CONFIGURE_ARGS += --with-newlib
else
# --with-cross-host is needed to correctly find the target libraries in
#   $GCCSDK_{CROSS|RISCOS}_PREFIX/arm-unknown-riscos/lib instead of $GCCSDK_{CROSS|RISCOS}_PREFIX/lib
# See UnixLib's configure.ac (FIXME: why is this not needed for newlib ?).
GCC_CONFIGURE_ARGS += --with-cross-host
endif

GCC_BUILD_FLAGS := CFLAGS="-O0 -g" LIBCFLAGS="-O0 -g" LIBCXXFLAGS="-O0 -g" CFLAGS_FOR_TARGET="-O3" CXXFLAGS_FOR_TARGET="-O3"

.NOTPARALLEL:
.PHONY: all clean distclean clang llvm-gcc
VPATH = $(BUILDSTEPSDIR)

all: llvm-gcc

clean:
	-rm -rf $(BUILDDIR) $(SRCDIR_AUTOCONF_BINUTILS) $(SRCDIR_AUTOCONF_GCC) $(SRCDIR_AUTOMAKE_BINUTILS) $(SRCDIR_AUTOMAKE_GCC) $(SRCDIR_BINUTILS) $(SRCDIR_NEWLIB) $(BUILDSTEPSDIR)

distclean: clean
	-rm -rf $(PREFIX_CROSS)

clang: cross-clang-built

llvm-gcc: cross-llvm-gcc-built

# -- Configure & building:

# --- autoconf / automake:

# Configure & build autoconf-for-binutils tool:
buildtool-autoconf-for-binutils-built: src-autoconf-for-binutils-copied
	-rm -rf $(BUILDDIR)/buildtool-autoconf-for-binutils-built
	mkdir -p $(BUILDDIR)/buildtool-autoconf-for-binutils-built
	cd $(BUILDDIR)/buildtool-autoconf-for-binutils-built && $(SRCDIR_AUTOCONF_BINUTILS)/configure --prefix=$(PREFIX_BUILDTOOLS_BINUTILS) && $(MAKE) && $(MAKE) install
	mkdir -p $(BUILDSTEPSDIR) && touch $(BUILDSTEPSDIR)/buildtool-autoconf-for-binutils-built

# Configure & build autoconf-for-gcc tool:
buildtool-autoconf-for-gcc-built: src-autoconf-for-gcc-copied
	-rm -rf $(BUILDDIR)/buildtool-autoconf-for-gcc-built
	mkdir -p $(BUILDDIR)/buildtool-autoconf-for-gcc-built
	cd $(BUILDDIR)/buildtool-autoconf-for-gcc-built && $(SRCDIR_AUTOCONF_GCC)/configure --prefix=$(PREFIX_BUILDTOOLS_GCC) && $(MAKE) && $(MAKE) install
	mkdir -p $(BUILDSTEPSDIR) && touch $(BUILDSTEPSDIR)/buildtool-autoconf-for-gcc-built

# Configure & build automake-for-binutils tool:
buildtool-automake-for-binutils-built: src-automake-for-binutils-copied buildtool-autoconf-for-binutils-built
	-rm -rf $(BUILDDIR)/buildtool-automake-for-binutils-built
	mkdir -p $(BUILDDIR)/buildtool-automake-for-binutils-built
	cd $(BUILDDIR)/buildtool-automake-for-binutils-built && $(SRCDIR_AUTOMAKE_BINUTILS)/configure --prefix=$(PREFIX_BUILDTOOLS_BINUTILS) && $(MAKE) && $(MAKE) install
	mkdir -p $(BUILDSTEPSDIR) && touch $(BUILDSTEPSDIR)/buildtool-automake-for-binutils-built

# Configure & build automake-for-gcc tool:
buildtool-automake-for-gcc-built: src-automake-for-gcc-copied buildtool-autoconf-for-gcc-built
	-rm -rf $(BUILDDIR)/buildtool-automake-for-gcc-built
	mkdir -p $(BUILDDIR)/buildtool-automake-for-gcc-built
	cd $(BUILDDIR)/buildtool-automake-for-gcc-built && $(SRCDIR_AUTOMAKE_GCC)/configure --prefix=$(PREFIX_BUILDTOOLS_GCC) && $(MAKE) && $(MAKE) install
	mkdir -p $(BUILDSTEPSDIR) && touch $(BUILDSTEPSDIR)/buildtool-automake-for-gcc-built

# --- binutils:

# Configure binutils cross:
cross-binutils-configured: src-binutils-copied buildtool-autoconf-for-binutils-built buildtool-automake-for-binutils-built
	-rm -rf $(BUILDDIR)/cross-binutils
	mkdir -p $(BUILDDIR)/cross-binutils
	cd $(BUILDDIR)/cross-binutils && PATH="$(PREFIX_BUILDTOOLS_BINUTILS)/bin:$(PATH)" && $(SRCDIR_BINUTILS)/configure $(CROSS_CONFIG_ARGS) $(BINUTILS_CONFIGURE_ARGS)
	mkdir -p $(BUILDSTEPSDIR) && touch $(BUILDSTEPSDIR)/cross-binutils-configured

# Build binutils cross:
cross-binutils-built: cross-binutils-configured
	cd $(BUILDDIR)/cross-binutils && PATH="$(PREFIX_BUILDTOOLS_BINUTILS)/bin:$(PATH)" && make && make install
	mkdir -p $(BUILDSTEPSDIR) && touch $(BUILDSTEPSDIR)/cross-binutils-built

# --- clang (including building llvm):

# Configure clang:
# Currently we require llvm-gcc as there the runtime library is built + a 'gcc' which can be used
# for linking.
# FIXME: current no opt:  --enable-optimized
cross-clang-configured: cross-binutils-built cross-llvm-gcc-built
	-rm -rf $(BUILDDIR_CROSS_LLVMCLANG)
	mkdir -p $(BUILDDIR_CROSS_LLVMCLANG)
	svn revert -R $(SRCDIR_LLVMCLANG)
	cd $(SRCDIR_LLVMCLANG) && $(SCRIPTSDIR)/do-patch $(RECIPEDIR)
	cd $(BUILDDIR_CROSS_LLVMCLANG) && $(SRCDIR_LLVMCLANG)/configure $(CROSS_CONFIG_ARGS) --enable-assertions --enable-targets=arm --with-c-include-dirs=$(PREFIX_CROSS)/$(TARGET)/include
	mkdir -p $(BUILDSTEPSDIR) && touch $(BUILDSTEPSDIR)/cross-clang-configured

# Build clang:
cross-clang-built: cross-clang-configured
	mkdir -p $(PREFIX_CROSS)/bin
	if [ ! -f $(PREFIX_CROSS)/bin/gcc ] ; then ln -s $(PREFIX_CROSS)/bin/$(TARGET)-gcc $(PREFIX_CROSS)/bin/gcc ; fi
	cd $(BUILDDIR_CROSS_LLVMCLANG) && make 
	cd $(BUILDDIR_CROSS_LLVMCLANG) && make install
	mkdir -p $(BUILDSTEPSDIR) && touch $(BUILDSTEPSDIR)/cross-clang-built

# --- llvm base (only for llvm-gcc usage):

# Configure llvm:
# FIXME: current no opt:  --enable-optimized
cross-llvm-configured:
	-rm -rf $(BUILDDIR_CROSS_LLVM)
	mkdir -p $(BUILDDIR_CROSS_LLVM)
	cd $(BUILDDIR_CROSS_LLVM) && $(SRCDIR_LLVMBASE)/configure $(CROSS_CONFIG_ARGS) --enable-assertions --enable-targets=arm --with-llvmgccdir=$(PREFIX_CROSS)/bin
	mkdir -p $(BUILDSTEPSDIR) && touch $(BUILDSTEPSDIR)/cross-llvm-configured

# Build llvm:
cross-llvm-built: cross-llvm-configured
	cd $(BUILDDIR_CROSS_LLVM) && make
	cd $(BUILDDIR_CROSS_LLVM) && make install
	mkdir -p $(BUILDSTEPSDIR) && touch $(BUILDSTEPSDIR)/cross-llvm-built

# --- llvm-gcc:

# Configure gcc:
ifeq ($(RTLIB),newlib)
cross-llvm-gcc-configured: src-newlib-copied-in-gcc-copied
else ifeq ($(RTLIB),unixlib)
# Integrating UnixLib in gcc requires regenerating some of the autotools files so build the
# required versions of autoconf and automake.
cross-llvm-gcc-configured: src-unixlib-in-gcc-copied buildtool-autoconf-for-gcc-built buildtool-automake-for-gcc-built
endif
cross-llvm-gcc-configured: cross-binutils-built cross-llvm-built
	-rm -rf $(BUILDDIR_CROSS_LLVMGCC)
	mkdir -p $(BUILDDIR_CROSS_LLVMGCC)
	# The $(PREFIX_CROSS)/bin/gcc link is a hack for llvm/clang but when rebuilding it is deadly for our configure step.
	-rm $(PREFIX_CROSS)/bin/gcc
ifeq ($(RTLIB),unixlib)
	svn revert -R $(SRCDIR_LLVMGCC)
	cd $(SRCDIR_LLVMGCC) && $(SCRIPTSDIR)/do-patch $(RECIPEDIR)
	cd $(SRCDIR_LLVMGCC)/libunixlib && PATH="$(PREFIX_BUILDTOOLS_GCC)/bin:$(PATH)" && aclocal -I .. -I ../config && autoheader && automake -a && autoconf
	cd $(SRCDIR_LLVMGCC)/libstdc++-v3 && PATH="$(PREFIX_BUILDTOOLS_GCC)/bin:$(PATH)" && aclocal -I . -I .. -I ../config && autoheader && automake -a && autoconf
	cd $(SRCDIR_LLVMGCC) && PATH="$(PREFIX_BUILDTOOLS_GCC)/bin:$(PATH)" && autogen Makefile.def && autoconf
endif
	cd $(BUILDDIR_CROSS_LLVMGCC) && PATH="$(PREFIX_BUILDTOOLS_GCC)/bin:$(PREFIX_CROSS)/bin:$(PATH)" && $(GCC_ENV) $(SRCDIR_LLVMGCC)/configure $(GCC_CONFIGURE_ARGS) $(CROSS_CONFIG_ARGS) --enable-languages=c,c++ --without-headers --enable-checking --enable-llvm=$(BUILDDIR_CROSS_LLVM)
	mkdir -p $(BUILDSTEPSDIR) && touch $(BUILDSTEPSDIR)/cross-llvm-gcc-configured

# Build gcc:
cross-llvm-gcc-built: cross-llvm-gcc-configured
	cd $(BUILDDIR_CROSS_LLVMGCC) && PATH="$(PREFIX_BUILDTOOLS_GCC)/bin:$(PREFIX_CROSS)/bin:$(PATH)" && $(GCC_ENV) make $(GCC_BUILD_FLAGS) && make install
	mkdir -p $(BUILDSTEPSDIR) && touch $(BUILDSTEPSDIR)/cross-llvm-gcc-built

# -- Source unpacking.

# Unpack autoconf-for-binutils source:
src-autoconf-for-binutils-copied: $(SRCORIGDIR)/autoconf-$(AUTOCONF_FOR_BINUTILS_VERSION).tar.bz2
	-rm -rf $(SRCORIGDIR)/autoconf-$(AUTOCONF_FOR_BINUTILS_VERSION) $(SRCDIR_AUTOCONF_BINUTILS)
	cd $(SRCORIGDIR) && tar xfj autoconf-$(AUTOCONF_FOR_BINUTILS_VERSION).tar.bz2
	-mkdir -p $(SRCDIR_AUTOCONF_BINUTILS)
	cp -T -p -r $(SRCORIGDIR)/autoconf-$(AUTOCONF_FOR_BINUTILS_VERSION) $(SRCDIR_AUTOCONF_BINUTILS)
	-mkdir -p $(BUILDSTEPSDIR)
	mkdir -p $(BUILDSTEPSDIR) && touch $(BUILDSTEPSDIR)/src-autoconf-for-binutils-copied

# Unpack autoconf-for-gcc source:
src-autoconf-for-gcc-copied: $(SRCORIGDIR)/autoconf-$(AUTOCONF_FOR_GCC_VERSION).tar.bz2
	-rm -rf $(SRCORIGDIR)/autoconf-$(AUTOCONF_FOR_GCC_VERSION) $(SRCDIR_AUTOCONF_GCC)
	cd $(SRCORIGDIR) && tar xfj autoconf-$(AUTOCONF_FOR_GCC_VERSION).tar.bz2
	-mkdir -p $(SRCDIR_AUTOCONF_GCC)
	cp -T -p -r $(SRCORIGDIR)/autoconf-$(AUTOCONF_FOR_GCC_VERSION) $(SRCDIR_AUTOCONF_GCC)
	-mkdir -p $(BUILDSTEPSDIR)
	mkdir -p $(BUILDSTEPSDIR) && touch $(BUILDSTEPSDIR)/src-autoconf-for-gcc-copied

# Unpack automake-for-binutils source:
src-automake-for-binutils-copied: $(SRCORIGDIR)/automake-$(AUTOMAKE_FOR_BINUTILS_VERSION).tar.bz2
	-rm -rf $(SRCORIGDIR)/automake-$(AUTOMAKE_FOR_BINUTILS_VERSION) $(SRCDIR_AUTOMAKE_BINUTILS)
	cd $(SRCORIGDIR) && tar xfj automake-$(AUTOMAKE_FOR_BINUTILS_VERSION).tar.bz2
	-mkdir -p $(SRCDIR_AUTOMAKE_BINUTILS)
	cp -T -p -r $(SRCORIGDIR)/automake-$(AUTOMAKE_FOR_BINUTILS_VERSION) $(SRCDIR_AUTOMAKE_BINUTILS)
	-mkdir -p $(BUILDSTEPSDIR)
	mkdir -p $(BUILDSTEPSDIR) && touch $(BUILDSTEPSDIR)/src-automake-for-binutils-copied

# Unpack automake-for-gcc source:
src-automake-for-gcc-copied: $(SRCORIGDIR)/automake-$(AUTOMAKE_FOR_GCC_VERSION).tar.bz2
	-rm -rf $(SRCORIGDIR)/automake-$(AUTOMAKE_FOR_GCC_VERSION) $(SRCDIR_AUTOMAKE_GCC)
	cd $(SRCORIGDIR) && tar xfj automake-$(AUTOMAKE_FOR_GCC_VERSION).tar.bz2
	-mkdir -p $(SRCDIR_AUTOMAKE_GCC)
	cp -T -p -r $(SRCORIGDIR)/automake-$(AUTOMAKE_FOR_GCC_VERSION) $(SRCDIR_AUTOMAKE_GCC)
	-mkdir -p $(BUILDSTEPSDIR)
	mkdir -p $(BUILDSTEPSDIR) && touch $(BUILDSTEPSDIR)/src-automake-for-gcc-copied

# Unpack binutils source:
ifeq "$(BINUTILS_USE_SCM)" "yes"
src-binutils-copied: $(SRCDIR)/cvs-binutils/src
	-rm -rf $(SRCDIR_BINUTILS)
	$(SCRIPTSDIR)/do-softlink-dir $(SRCDIR)/cvs-binutils/src $(SRCDIR_BINUTILS)
else
src-binutils-copied: $(SRCORIGDIR)/binutils-$(BINUTILS_VERSION).tar.bz2
	-rm -rf $(SRCORIGDIR)/binutils-$(BINUTILS_VERSION) $(SRCDIR_BINUTILS)
	cd $(SRCORIGDIR) && tar xfj binutils-$(BINUTILS_VERSION).tar.bz2
	cp -r -p $(SRCORIGDIR)/binutils-$(BINUTILS_VERSION) $(SRCDIR_BINUTILS)
endif
	mkdir -p $(BUILDSTEPSDIR) && touch $(BUILDSTEPSDIR)/src-binutils-copied

# Link in newlib in gcc (no patching is necessary):
src-newlib-copied-in-gcc-copied: src-newlib-copied
	-rm -rf $(SRCDIR_LLVMGCC)/libunixlib
	$(SCRIPTSDIR)/do-softlink-dir $(SRCDIR_NEWLIB)/newlib $(SRCDIR_LLVMGCC)/newlib
	$(SCRIPTSDIR)/do-softlink-dir $(SRCDIR_NEWLIB)/libgloss $(SRCDIR_LLVMGCC)/libgloss
	mkdir -p $(BUILDSTEPSDIR) && touch $(BUILDSTEPSDIR)/src-newlib-copied-in-gcc-copied

# Patch UnixLib, link in unixlib in gcc and generate the autotool files:
src-unixlib-in-gcc-copied:
	-rm -rf $(SRCDIR_LLVMGCC)/newlib $(SRCDIR_LLVMGCC)/libgloss
	svn revert -R $(SRCDIR_UNIXLIB)
	cd $(SRCDIR_UNIXLIB) && $(SCRIPTSDIR)/do-patch $(RECIPEDIR)
	$(SCRIPTSDIR)/do-softlink-dir $(SRCDIR_UNIXLIB) $(SRCDIR_LLVMGCC)/libunixlib
	$(SRCDIR_LLVMGCC)/libunixlib/gen-auto.pl
	# Not needed and will even break the build: cd $(SRCDIR_LLVMGCC)/libunixlib && cp libtool-org.m4 libtool.m4 && patch -p0 < libtool.m4.p
	mkdir -p $(BUILDSTEPSDIR) && touch $(BUILDSTEPSDIR)/src-unixlib-in-gcc-copied

# Unpack newlib source in $(SRCDIR_NEWLIB) :
src-newlib-copied: $(SRCORIGDIR)/newlib-$(NEWLIB_VERSION).tar.gz
	-rm -rf $(SRCORIGDIR)/newlib-$(NEWLIB_VERSION) $(SRCDIR_NEWLIB)
	cd $(SRCORIGDIR) && tar xzf newlib-$(NEWLIB_VERSION).tar.gz
	cp -r -p $(SRCORIGDIR)/newlib-$(NEWLIB_VERSION) $(SRCDIR_NEWLIB)
	mkdir -p $(BUILDSTEPSDIR) && touch $(BUILDSTEPSDIR)/src-newlib-copied

# -- Source downloading.

# Download autoconf source to be used to build binutils:
$(SRCORIGDIR)/autoconf-$(AUTOCONF_FOR_BINUTILS_VERSION).tar.bz2:
	-rm $(SRCORIGDIR)/autoconf-$(AUTOCONF_FOR_BINUTILS_VERSION).tar.bz2
	-mkdir -p $(SRCORIGDIR)
	cd $(SRCORIGDIR) && wget -c http://ftp.gnu.org/gnu/autoconf/autoconf-$(AUTOCONF_FOR_BINUTILS_VERSION).tar.bz2

# Download autoconf source to be used to build gcc:
$(SRCORIGDIR)/autoconf-$(AUTOCONF_FOR_GCC_VERSION).tar.bz2:
	-rm $(SRCORIGDIR)/autoconf-$(AUTOCONF_FOR_GCC_VERSION).tar.bz2
	-mkdir -p $(SRCORIGDIR)
	cd $(SRCORIGDIR) && wget -c http://ftp.gnu.org/gnu/autoconf/autoconf-$(AUTOCONF_FOR_GCC_VERSION).tar.bz2

# Download automake source to be used to build binutils:
$(SRCORIGDIR)/automake-$(AUTOMAKE_FOR_BINUTILS_VERSION).tar.bz2:
	-rm $(SRCORIGDIR)/automake-$(AUTOMAKE_FOR_BINUTILS_VERSION).tar.bz2
	-mkdir -p $(SRCORIGDIR)
	cd $(SRCORIGDIR) && wget -c http://ftp.gnu.org/gnu/automake/automake-$(AUTOMAKE_FOR_BINUTILS_VERSION).tar.bz2

# Download automake source to be used to build gcc:
$(SRCORIGDIR)/automake-$(AUTOMAKE_FOR_GCC_VERSION).tar.bz2:
	-rm $(SRCORIGDIR)/automake-$(AUTOMAKE_FOR_GCC_VERSION).tar.bz2
	-mkdir -p $(SRCORIGDIR)
	cd $(SRCORIGDIR) && wget -c http://ftp.gnu.org/gnu/automake/automake-$(AUTOMAKE_FOR_GCC_VERSION).tar.bz2

# Download binutils source:
$(SRCDIR)/cvs-binutils/src:
ifeq "$(BINUTILS_USE_SCM)" "yes"
	-mkdir -p $(SRCDIR)/cvs-binutils
	cd $(SRCDIR)/cvs-binutils && cvs -z 9 -d :pserver:anoncvs@sourceware.org:/cvs/src co binutils
else
$(SRCORIGDIR)/binutils-$(BINUTILS_VERSION).tar.bz2:
	-rm $(SRCORIGDIR)/binutils-$(BINUTILS_VERSION).tar.bz2
	-mkdir -p $(SRCORIGDIR)
	cd $(SRCORIGDIR) && wget -c http://ftp.gnu.org/gnu/binutils/binutils-$(BINUTILS_VERSION).tar.bz2
endif

# Download newlib source:
$(SRCORIGDIR)/newlib-$(NEWLIB_VERSION).tar.gz:
	-rm $(SRCORIGDIR)/newlib-$(NEWLIB_VERSION).tar.gz
	-mkdir -p $(SRCORIGDIR)
	cd $(SRCORIGDIR) && wget -c ftp://sourceware.org/pub/newlib/newlib-$(NEWLIB_VERSION).tar.gz

