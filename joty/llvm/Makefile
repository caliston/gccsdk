# Makefile building llvm world (experimental)
# Written by John Tytgat <John.Tytgat@aaug.net>

# Define compiler frontend, either "llvm-gcc" or "clang":
COMPILERFE := llvm-gcc
# Target to use:
TARGET := arm-unknown-eabi

ROOT := $(shell pwd)

# In order to get access to gcc (for assembling & linking) and libunixlib (runtime headers/lib):
# FIXME: this is a gross hack (currently only used for clang):
GCCSDK_PREFIX := $(GCCSDK_INSTALL_CROSSBIN)/..
TARGET_RT_INCLUDE := $(GCCSDK_PREFIX)/arm-unknown-riscos/include/libunixlib/
TARGET_GCC := $(GCCSDK_PREFIX)/bin/arm-unknown-riscos-gcc

SRCDIR := $(ROOT)/src
SRCDIR_BINUTILS := $(SRCDIR)/binutils
SRCDIR_LLVMBASE := $(SRCDIR)/svn-llvm-base
SRCDIR_LLVMCLANG := $(SRCDIR)/svn-llvm-clang
SRCDIR_LLVMGCC := $(SRCDIR)/svn-llvm-gcc
SRCDIR_NEWLIB := $(SRCDIR)/newlib
SRCORIGDIR := $(ROOT)/src.orig

BUILDDIR := $(ROOT)/build-$(COMPILERFE)
BUILDDIR_LLVM := $(BUILDDIR)/llvm
BUILDDIR_LLVMCLANG := $(BUILDDIR)/llvm-clang
BUILDDIR_LLVMGCC := $(BUILDDIR)/llvm-gcc
BUILDSTEPSDIR := $(ROOT)/buildsteps

PREFIX_CROSS := $(ROOT)/install-$(COMPILERFE)

BINUTILS_VERSION := binutils-2.20
NEWLIB_VERSION := newlib-1.18.0

# Configure args unique for cross-compiling & unique to building for RISC OS native
CROSS_CONFIG_ARGS := --target=$(TARGET) --prefix=$(PREFIX_CROSS)
BINUTILS_CONFIGURE_ARGS := --enable-interwork --disable-multilib --disable-shared --disable-werror --with-gcc --disable-nls
GCC_CONFIGURE_ARGS := --disable-threads --with-newlib --enable-interwork --disable-multilib --disable-shared --disable-nls --with-arch=armv4
# --with-tune=strongarm --with-float=softfp --with-mode=arm

GCC_BUILD_FLAGS := CFLAGS="-O0 -g" LIBCFLAGS="-O0 -g" LIBCXXFLAGS="-O0 -g" CFLAGS_FOR_TARGET="-O3" CXXFLAGS_FOR_TARGET="-O3"

.PHONY: all clean distclean clang llvm-gcc
all: $(COMPILERFE)

clean:
	-rm -rf $(BUILDDIR) $(SRCDIR_BINUTILS) $(BUILDSTEPSDIR)

distclean:
	-rm -rf $(BUILDDIR) $(SRCDIR_BINUTILS) $(BUILDSTEPSDIR) $(PREFIX_CROSS)

clang: $(BUILDSTEPSDIR)/buildstep-clang-buildit

llvm-gcc: $(BUILDSTEPSDIR)/buildstep-llvm-gcc-buildit

# --- clang (including building llvm):

# Configure clang:
# FIXME: current no opt:  --enable-optimized
$(BUILDSTEPSDIR)/buildstep-clang-configure: $(BUILDSTEPSDIR)/buildstep-binutils-cross-buildit
	-rm -rf $(BUILDDIR_LLVMCLANG)
	mkdir -p $(BUILDDIR_LLVMCLANG)
	cd $(BUILDDIR_LLVMCLANG) && $(SRCDIR_LLVMCLANG)/configure $(CROSS_CONFIG_ARGS) --enable-assertions --enable-targets=arm --with-c-include-dirs=$(TARGET_RT_INCLUDE)
	mkdir -p $(BUILDSTEPSDIR) && touch $(BUILDSTEPSDIR)/buildstep-clang-configure

# Build clang:
$(BUILDSTEPSDIR)/buildstep-clang-buildit: $(BUILDSTEPSDIR)/buildstep-clang-configure
	mkdir -p $(PREFIX_CROSS)/bin
	if [ ! -f $(PREFIX_CROSS)/bin/gcc ] ; then ln -s $(TARGET_GCC) $(PREFIX_CROSS)/bin/gcc ; fi
	cd $(BUILDDIR_LLVMCLANG) && make
	cd $(BUILDDIR_LLVMCLANG) && make install
	mkdir -p $(BUILDSTEPSDIR) && touch $(BUILDSTEPSDIR)/buildstep-clang-buildit

# --- llvm base (for llvm-gcc usage):

# Configure llvm:
# FIXME: current no opt:  --enable-optimized
$(BUILDSTEPSDIR)/buildstep-llvm-configure:
	-rm -rf $(BUILDDIR_LLVM)
	mkdir -p $(BUILDDIR_LLVM)
	cd $(BUILDDIR_LLVM) && $(SRCDIR_LLVMBASE)/configure $(CROSS_CONFIG_ARGS) --enable-assertions --enable-targets=arm --with-llvmgccdir=$(PREFIX_CROSS)/bin
	mkdir -p $(BUILDSTEPSDIR) && touch $(BUILDSTEPSDIR)/buildstep-llvm-configure

# Build llvm:
$(BUILDSTEPSDIR)/buildstep-llvm-buildit: $(BUILDSTEPSDIR)/buildstep-llvm-configure
	cd $(BUILDDIR_LLVM) && make
	cd $(BUILDDIR_LLVM) && make install
	mkdir -p $(BUILDSTEPSDIR) && touch $(BUILDSTEPSDIR)/buildstep-llvm-buildit

# --- llvm-gcc:

# Configure gcc:
$(BUILDSTEPSDIR)/buildstep-llvm-gcc-configure: $(BUILDSTEPSDIR)/buildstep-binutils-cross-buildit $(BUILDSTEPSDIR)/buildstep-newlib-src
	-rm -rf $(BUILDDIR_LLVMGCC)
	mkdir -p $(BUILDDIR_LLVMGCC)
	if [ ! -h $(SRCDIR_LLVMGCC)/newlib ] ; then ln -s $(SRCDIR_NEWLIB)/newlib $(SRCDIR_LLVMGCC)/newlib ; fi
	if [ ! -h $(SRCDIR_LLVMGCC)/libgloss ] ; then ln -s $(SRCDIR_NEWLIB)/libgloss $(SRCDIR_LLVMGCC)/libgloss ; fi
	cd $(BUILDDIR_LLVMGCC) && PATH="$(PREFIX_CROSS)/bin:$(PATH)" && $(SRCDIR_LLVMGCC)/configure $(GCC_CONFIGURE_ARGS) $(CROSS_CONFIG_ARGS) --program-prefix=llvm- --enable-languages=c,c++ --without-headers --enable-checking --enable-llvm=$(BUILDDIR_LLVM)
	mkdir -p $(BUILDSTEPSDIR) && touch $(BUILDSTEPSDIR)/buildstep-llvm-gcc-configure

# Build gcc:
$(BUILDSTEPSDIR)/buildstep-llvm-gcc-buildit: $(BUILDSTEPSDIR)/buildstep-llvm-buildit $(BUILDSTEPSDIR)/buildstep-llvm-gcc-configure
	cd $(BUILDDIR_LLVMGCC) && make $(GCC_BUILD_FLAGS)
	cd $(BUILDDIR_LLVMGCC) && make install
	mkdir -p $(BUILDSTEPSDIR) && touch $(BUILDSTEPSDIR)/buildstep-llvm-gcc-buildit

# --- binutils:

# Download binutils source:
$(SRCORIGDIR)/$(BINUTILS_VERSION).tar.bz2:
	-rm $(SRCORIGDIR)/$(BINUTILS_VERSION).tar.bz2
	-mkdir -p $(SRCORIGDIR)
	cd $(SRCORIGDIR) && wget -c http://ftp.gnu.org/gnu/binutils/$(BINUTILS_VERSION).tar.bz2

# Unpack binutils source:
$(BUILDSTEPSDIR)/buildstep-binutils-src: $(SRCORIGDIR)/$(BINUTILS_VERSION).tar.bz2
	-rm -rf $(SRCORIGDIR)/$(BINUTILS_VERSION) $(SRCDIR_BINUTILS)
	cd $(SRCORIGDIR) && tar xfj $(BINUTILS_VERSION).tar.bz2
	cp -r -p $(SRCORIGDIR)/$(BINUTILS_VERSION) $(SRCDIR_BINUTILS)
	mkdir -p $(BUILDSTEPSDIR) && touch $(BUILDSTEPSDIR)/buildstep-binutils-src

# Configure binutils cross:
$(BUILDSTEPSDIR)/buildstep-binutils-cross-configure: $(BUILDSTEPSDIR)/buildstep-binutils-src
	-rm -rf $(BUILDDIR)/binutils-cross
	mkdir -p $(BUILDDIR)/binutils-cross
	cd $(BUILDDIR)/binutils-cross && $(SRCDIR)/binutils/configure $(CROSS_CONFIG_ARGS) $(BINUTILS_CONFIGURE_ARGS)
	touch $(BUILDSTEPSDIR)/buildstep-binutils-cross-configure

# Build binutils cross:
$(BUILDSTEPSDIR)/buildstep-binutils-cross-buildit: $(BUILDSTEPSDIR)/buildstep-binutils-cross-configure
	cd $(BUILDDIR)/binutils-cross && make
	cd $(BUILDDIR)/binutils-cross && make install
	touch $(BUILDSTEPSDIR)/buildstep-binutils-cross-buildit

# --- newlib:

# Download newlib source:
$(SRCORIGDIR)/$(NEWLIB_VERSION).tar.gz:
	-rm $(SRCORIGDIR)/$(NEWLIB_VERSION).tar.gz
	-mkdir -p $(SRCORIGDIR)
	cd $(SRCORIGDIR) && wget -c ftp://sourceware.org/pub/newlib/$(NEWLIB_VERSION).tar.gz

# Unpack newlib source in $(SRCDIR_NEWLIB) :
$(BUILDSTEPSDIR)/buildstep-newlib-src: $(SRCORIGDIR)/$(NEWLIB_VERSION).tar.gz
	-rm -rf $(SRCORIGDIR)/$(NEWLIB_VERSION) $(SRCDIR_NEWLIB)
	cd $(SRCORIGDIR) && tar xzf $(NEWLIB_VERSION).tar.gz
	cp -r -p $(SRCORIGDIR)/$(NEWLIB_VERSION) $(SRCDIR_NEWLIB)
	mkdir -p $(BUILDSTEPSDIR) && touch $(BUILDSTEPSDIR)/buildstep-newlib-src

