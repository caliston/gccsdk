# Makefile building llvm world:

TARGET := arm-unknown-eabi

ROOT := $(shell pwd)
PREFIX := $(ROOT)/install

SRCDIR := $(ROOT)/src
SRCDIR_BINUTILS := $(SRCDIR)/binutils
SRCDIR_LLVM := $(SRCDIR)/svn-llvm
SRCDIR_LLVMCLANG := $(SRCDIR)/svn-llvm-clang
SRCDIR_LLVMGCC := $(SRCDIR)/svn-llvm-gcc-4.2
SRCORIGDIR := $(ROOT)/src.orig

BUILDDIR := $(ROOT)/build
BUILDDIR_LLVM := $(BUILDDIR)/llvm
BUILDDIR_LLVMCLANG := $(BUILDDIR)/llvm-clang
BUILDDIR_LLVMGCC := $(BUILDDIR)/llvm-gcc
BUILDSTEPSDIR := $(ROOT)/buildsteps

BINUTILS_VERSION := binutils-2.19.1

BINUTILS_CONFIGURE_ARGS := --enable-interwork --disable-multilib --disable-shared --disable-werror --with-gcc --disable-nls
GCC_CONFIGURE_ARGS := --disable-threads --with-newlib --enable-interwork --disable-multilib --disable-shared --disable-nls

.PHONY: all clean distclean llvm-gcc clang
# Either "llvm-gcc" or "clang":
all: clang

clean:
	-rm -rf $(BUILDDIR) $(SRCDIR_BINUTILS) $(BUILDSTEPSDIR)

distclean:
	-rm -rf $(BUILDDIR) $(SRCDIR_BINUTILS) $(BUILDSTEPSDIR) $(PREFIX)

llvm-gcc: $(BUILDSTEPSDIR)/buildstep-llvm-gcc-buildit

clang: $(BUILDSTEPSDIR)/buildstep-clang-buildit

# --- llvm (for llvmgcc):

# svn checkout/update llvm:
$(SRCDIR_LLVM):
	mkdir -p $(SRCDIR_LLVM)
	cd `dirname $(SRCDIR_LLVM)` && svn co http://llvm.org/svn/llvm-project/llvm/trunk `basename $(SRCDIR_LLVM)`
	mkdir -p $(BUILDSTEPSDIR) && touch $(BUILDSTEPSDIR)/buildstep-llvm-fetchsrc

# Configure llvm:
# FIXME: current no opt:  --enable-optimized
$(BUILDSTEPSDIR)/buildstep-llvm-configure: $(SRCDIR_LLVM)
	-rm -rf $(BUILDDIR_LLVM)
	mkdir -p $(BUILDDIR_LLVM)
	cd $(BUILDDIR_LLVM) && $(SRCDIR_LLVM)/configure --prefix=$(PREFIX) --enable-assertions --enable-targets=arm --with-llvmgccdir=$(PREFIX)/bin
	mkdir -p $(BUILDSTEPSDIR) && touch $(BUILDSTEPSDIR)/buildstep-llvm-configure

# Build llvm:
$(BUILDSTEPSDIR)/buildstep-llvm-buildit: $(BUILDSTEPSDIR)/buildstep-llvm-configure
	cd $(BUILDDIR_LLVM) && make
	cd $(BUILDDIR_LLVM) && make install
	mkdir -p $(BUILDSTEPSDIR) && touch $(BUILDSTEPSDIR)/buildstep-llvm-buildit

# --- clang:

# Configure clang:
$(BUILDSTEPSDIR)/buildstep-clang-configure: $(BUILDSTEPSDIR)/buildstep-binutils-cross-buildit
	-rm -rf $(BUILDDIR_LLVMCLANG)
	mkdir -p $(BUILDDIR_LLVMCLANG)
	cd $(BUILDDIR_LLVMCLANG) && $(SRCDIR_LLVMCLANG)/configure --prefix=$(PREFIX) --target=$(TARGET) --enable-assertions --enable-targets=arm
	mkdir -p $(BUILDSTEPSDIR) && touch $(BUILDSTEPSDIR)/buildstep-clang-configure

# Build clang:
$(BUILDSTEPSDIR)/buildstep-clang-buildit: $(BUILDSTEPSDIR)/buildstep-clang-configure
	cd $(BUILDDIR_LLVMCLANG) && make
	mkdir -p $(BUILDSTEPSDIR) && touch $(BUILDSTEPSDIR)/buildstep-clang-buildit

# --- llvm-gcc:

# svn checkout/update llvm-gcc
$(SRCDIR_LLVMGCC):
	mkdir -p $(SRCDIR_LLVMGCC)
	cd `dirname $(SRCDIR_LLVMGCC)` && svn co http://llvm.org/svn/llvm-project/llvm-gcc-4.2/trunk `basename $(SRCDIR_LLVMGCC)`
	mkdir -p $(BUILDSTEPSDIR) && touch $(BUILDSTEPSDIR)/buildstep-llvm-gcc-fetchsrc

# Configure gcc without run-time library support:
$(BUILDSTEPSDIR)/buildstep-llvm-gcc-configure: $(SRCDIR_LLVMGCC) $(BUILDSTEPSDIR)/buildstep-binutils-cross-buildit
	-rm -rf $(BUILDDIR_LLVMGCC)
	mkdir -p $(BUILDDIR_LLVMGCC)
	cd $(BUILDDIR_LLVMGCC) && PATH="$(PREFIX)/bin:$(PATH)" && $(SRCDIR_LLVMGCC)/configure --target=$(TARGET) --prefix=$(PREFIX) --program-prefix=llvm- --enable-languages=c --without-headers --enable-checking --enable-llvm=$(BUILDDIR_LLVM) --disable-bootstrap
	mkdir -p $(BUILDSTEPSDIR) && touch $(BUILDSTEPSDIR)/buildstep-llvm-gcc-configure

# Build gcc without run-time library support:
$(BUILDSTEPSDIR)/buildstep-llvm-gcc-buildit: $(BUILDSTEPSDIR)/buildstep-llvm-buildit $(BUILDSTEPSDIR)/buildstep-llvm-gcc-configure
	cd $(BUILDDIR_LLVMGCC) && make all-gcc
	cd $(BUILDDIR_LLVMGCC) && make install-gcc
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
	cp -r $(SRCORIGDIR)/$(BINUTILS_VERSION) $(SRCDIR_BINUTILS)
	mkdir -p $(BUILDSTEPSDIR) && touch $(BUILDSTEPSDIR)/buildstep-binutils-src

# Configure binutils cross:
$(BUILDSTEPSDIR)/buildstep-binutils-cross-configure: $(BUILDSTEPSDIR)/buildstep-binutils-src
	-rm -rf $(BUILDDIR)/binutils-cross
	mkdir -p $(BUILDDIR)/binutils-cross
	cd $(BUILDDIR)/binutils-cross && $(SRCDIR)/binutils/configure --target=$(TARGET) --prefix=$(PREFIX) $(BINUTILS_CONFIGURE_ARGS)
	touch $(BUILDSTEPSDIR)/buildstep-binutils-cross-configure

# Build binutils cross:
$(BUILDSTEPSDIR)/buildstep-binutils-cross-buildit: $(BUILDSTEPSDIR)/buildstep-binutils-cross-configure
	cd $(BUILDDIR)/binutils-cross && make
	cd $(BUILDDIR)/binutils-cross && make install
	touch $(BUILDSTEPSDIR)/buildstep-binutils-cross-buildit

