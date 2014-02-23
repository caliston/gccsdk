# Public parameters: BUILDDIR, INSTALLDIR (= prefix) and CONFIGPARAM (typically
# contain --host).
# Use RONATIVE=yes to build RISC OS native application.

RONATIVE := no
ifeq ($(RONATIVE),yes)
BUILDDIR := $(CURDIR)/builddir-ro
INSTALLDIR := $(CURDIR)/installdir-ro
CONFIGPARAM := --host=arm-unknown-riscos --disable-building-tools
CFLAGS := "-O3 -mlibscl"
else
BUILDDIR := $(CURDIR)/builddir
INSTALLDIR := $(CURDIR)/installdir
CONFIGPARAM := --disable-building-tools
CFLAGS :=
endif

# TOOLSDIR contains binaries which are use to build on the host. They will
# not be cross-compiled.
TOOLSDIR := $(CURDIR)/toolsdir

ASASMROOT := $(CURDIR)/asasm

all: asasm

install: asasm-install

asasm: $(BUILDDIR)/asasm/Makefile $(ASASMROOT)/configure $(TOOLSDIR)/bin/lemon $(TOOLSDIR)/bin/re2c
	PATH=$(TOOLSDIR)/bin:$(PATH) && make -C $(BUILDDIR)/asasm BUILDDIR=$(BUILDDIR)/asasm INSTALLDIR=$(INSTALLDIR) CONFIGPARAM='$(CONFIGPARAM)' RONATIVE=$(RONATIVE)

asasm-install: asasm $(INSTALLDIR)
	PATH=$(TOOLSDIR)/bin:$(PATH) && make -C $(BUILDDIR)/asasm install BUILDDIR=$(BUILDDIR)/asasm INSTALLDIR=$(INSTALLDIR) CONFIGPARAM='$(CONFIGPARAM)' RONATIVE=$(RONATIVE)

check:
	make -C $(BUILDDIR)/asasm check BUILDDIR=$(BUILDDIR)/asasm INSTALLDIR=$(INSTALLDIR) CONFIGPARAM='$(CONFIGPARAM)' RONATIVE=$(RONATIVE)

clean:
	make -C $(BUILDDIR)/asasm clean BUILDDIR=$(BUILDDIR)/asasm INSTALLDIR=$(INSTALLDIR) CONFIGPARAM='$(CONFIGPARAM)' RONATIVE=$(RONATIVE)

distclean:
	-rm -rf $(BUILDDIR) $(INSTALLDIR) $(TOOLSDIR)
	make -C lemon distclean
	make -C re2c distclean
	-cd $(ASASMROOT) && rm -rf `svn status --no-ignore | grep "^I" | cut -c 9-`
	-cd $(ASASMROOT)/decaof && rm -rf `svn status --no-ignore | grep "^I" | cut -c 9-`
	-cd $(ASASMROOT)/elftoolchain && rm -rf `svn status --no-ignore | grep "^I" | cut -c 9-`

.PHONY: all install asasm asasm-install check clean distclean

# --------------------

$(TOOLSDIR)/bin/lemon:
	make -C lemon install BUILDDIR=$(BUILDDIR) INSTALLDIR=$(TOOLSDIR) CONFIGPARAM= RONATIVE=no

$(TOOLSDIR)/bin/re2c:
	make -C re2c install BUILDDIR=$(BUILDDIR) INSTALLDIR=$(TOOLSDIR) CONFIGPARAM= RONATIVE=no

# --------------------

# Autoconfiguring etc:
$(BUILDDIR)/asasm/Makefile: $(ASASMROOT)/Makefile.in $(ASASMROOT)/configure
	-mkdir -p $(BUILDDIR)/asasm
	cd $(BUILDDIR)/asasm && sh $(ASASMROOT)/configure --prefix=$(INSTALLDIR) $(CONFIGPARAM) CFLAGS=$(CFLAGS)

$(ASASMROOT)/Makefile.in: $(ASASMROOT)/Makefile.am
	cd $(ASASMROOT) && autoreconf --install
 
$(ASASMROOT)/configure: $(ASASMROOT)/configure.ac
	cd $(ASASMROOT) && autoreconf --install

# --------------------

$(INSTALLDIR):
	mkdir -p $(INSTALLDIR)

