# Public parameters: BUILDDIR, INSTALLDIR (= prefix) and CONFIGPARAM (typically
# contain --host).
# Use RONATIVE=yes to build RISC OS native application.

RE2CROOT := $(CURDIR)/upstream

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

all: re2c

install: re2c-install

re2c: $(BUILDDIR)/re2c/Makefile $(RE2CROOT)/configure
	make -C $(BUILDDIR)/re2c

re2c-install: re2c $(INSTALLDIR)
	make -C $(BUILDDIR)/re2c install

check:
	make -C $(BUILDDIR)/re2c check

clean:
	make -C $(BUILDDIR)/re2c clean

distclean:
	-rm -rf $(BUILDDIR) $(INSTALLDIR)
	-cd $(RE2CROOT) && rm -rf `svn status --no-ignore | grep "^I" | cut -c 9-`

.PHONY: all install re2c re2c-install check clean distclean

# --------------------

# Autoconfiguring etc:
$(BUILDDIR)/re2c/Makefile: $(RE2CROOT)/Makefile.in $(RE2CROOT)/configure
	-mkdir -p $(BUILDDIR)/re2c
	cd $(BUILDDIR)/re2c && sh $(RE2CROOT)/configure --prefix=$(INSTALLDIR) $(CONFIGPARAM) CFLAGS=$(CFLAGS)

$(RE2CROOT)/Makefile.in: $(RE2CROOT)/Makefile.am
	cd $(RE2CROOT) && ./autogen.sh
 
$(RE2CROOT)/configure: $(RE2CROOT)/configure.in
	cd $(RE2CROOT) && ./autogen.sh

# --------------------

$(INSTALLDIR):
	mkdir -p $(INSTALLDIR)

