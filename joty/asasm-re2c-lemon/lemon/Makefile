# Public parameters: BUILDDIR, INSTALLDIR (= prefix) and CONFIGPARAM (typically
# contain --host).
# Use RONATIVE=yes to build RISC OS native application.

LEMONROOT := $(CURDIR)/current

RONATIVE := no
ifeq ($(RONATIVE),yes)
BUILDDIR := $(CURDIR)/builddir-ro
INSTALLDIR := $(CURDIR)/installdir-ro
CONFIGPARAM := --host=arm-unknown-riscos
CFLAGS := "-O3 -mlibscl"
else
BUILDDIR := $(CURDIR)/builddir
INSTALLDIR := $(CURDIR)/installdir
CONFIGPARAM :=
CFLAGS :=
endif

all: lemon

install: lemon-install

lemon: $(BUILDDIR)/lemon/Makefile $(LEMONROOT)/configure
	make -C $(BUILDDIR)/lemon

lemon-install: lemon $(INSTALLDIR)
	make -C $(BUILDDIR)/lemon install

check:
	make -C $(BUILDDIR)/lemon check

clean:
	make -C $(BUILDDIR)/lemon clean

distclean:
	-rm -rf $(BUILDDIR) $(INSTALLDIR)
	-cd $(LEMONROOT) && rm -rf `svn status --no-ignore | grep "^I" | cut -c 9-`

.PHONY: all install lemon lemon-install check clean distclean

# --------------------

# Autoconfiguring etc:
$(BUILDDIR)/lemon/Makefile: $(LEMONROOT)/Makefile.in $(LEMONROOT)/configure
	-mkdir -p $(BUILDDIR)/lemon
	cd $(BUILDDIR)/lemon && sh $(LEMONROOT)/configure --prefix=$(INSTALLDIR) $(CONFIGPARAM) CFLAGS=$(CFLAGS)

$(LEMONROOT)/Makefile.in: $(LEMONROOT)/Makefile.am
	cd $(LEMONROOT) && autoreconf --install
 
$(LEMONROOT)/configure: $(LEMONROOT)/configure.ac
	cd $(LEMONROOT) && autoreconf --install

# --------------------

$(INSTALLDIR):
	mkdir -p $(INSTALLDIR)

