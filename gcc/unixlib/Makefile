# Second-level Makefile for UnixLib for RISC OS GCC
# Written by Nick Burrett <nick@dsvr.net>

export TRG CFL1

all:	unixlib

.PHONY: unixlib

upath=$(objdir)/$@/$(TRG)

install_headers:
	$(MAKE) -C source install_headers

install_source:
	$(MAKE) -C source install_source

unixlib:
	mkdir -p $(upath)/o $(upath)/complex/o $(upath)/grp/o
	mkdir -p $(upath)/math/o $(upath)/math-asm/o $(upath)/signal/o
	mkdir -p $(upath)/common/o $(upath)/gcccompat/o $(upath)/locale/o
	mkdir -p $(upath)/netlib/o $(upath)/pwd/o $(upath)/resource/o
	mkdir -p $(upath)/stdio/o $(upath)/stdlib/o $(upath)/scl/o
	mkdir -p $(upath)/string/o $(upath)/sys/o $(upath)/time/o
	mkdir -p $(upath)/termios/o $(upath)/unistd/o $(upath)/unix/o
	mkdir -p $(upath)/wchar/o $(upath)/module/o
	$(MAKE) -C source

