# Makefile for the GNU C++ compiler for ARM/RISC OS
# Copyright (c) 1997, 1998, 1999, 2000, 2001 Nick Burrett
# Written by Nick Burrett <nick@dsvr.net>

# Defs for GCC
LINK = $(CC) -o $@
INCLUDES = -I./ -I../ -I../../../include -I../config
LIBS = -L$(objdir)/libiberty/$(STAGE) -liberty

$(gccobjdir)/cp/%.o: %.c
	$(CC) $(CFLAGS) -o $@ -c $< $(INCLUDES)

all: cpp

.PHONY: cpp

cpp: $(gcc_bin_dir)/cc1plus$(gexesfx) $(bin_dir)/g++$(gexesfx)

LIBDEPS = $(gccobjdir)/prefix.o

ifeq (${STAGE},stage1)
RISC_OBJS=
RISCOS_OBJS=
else
RISC_OBJS = $(gccobjdir)/config/arm/riscos_fix.o
RISCOS_OBJS = $(RISC_OBJS) $(gccobjdir)/config/arm/riscos.o
endif


# Language-independent object files
OBJS =	$(gccobjdir)/print-tree.o \
	$(gccobjdir)/genrtl.o \
	$(gccobjdir)/stmt.o \
	$(gccobjdir)/except.o \
	$(gccobjdir)/calls.o \
	$(gccobjdir)/expmed.o \
	$(gccobjdir)/explow.o \
	$(gccobjdir)/varasm.o \
	$(gccobjdir)/rtl.o \
	$(gccobjdir)/print-rtl.o \
	$(gccobjdir)/rtlanal.o \
	$(gccobjdir)/emit-rtl.o \
	$(gccobjdir)/real.o \
	$(gccobjdir)/regmove.o \
	$(gccobjdir)/bitmap.o \
	$(gccobjdir)/alias.o \
	$(gccobjdir)/integrate.o \
	$(gccobjdir)/dyn-string.o \
	$(gccobjdir)/dwarf2out.o \
	$(gccobjdir)/jump.o \
	$(gccobjdir)/cse.o \
	$(gccobjdir)/loop.o \
	$(gccobjdir)/unroll.o \
	$(gccobjdir)/flow.o \
	$(gccobjdir)/stupid.o \
	$(gccobjdir)/combine.o \
	$(gccobjdir)/regclass.o \
	$(gccobjdir)/local-alloc.o \
	$(gccobjdir)/global.o \
	$(gccobjdir)/reload.o \
	$(gccobjdir)/reload1.o \
	$(gccobjdir)/caller-save.o \
	$(gccobjdir)/insn-peep.o \
	$(gccobjdir)/reorg.o \
	$(gccobjdir)/sched.o \
	$(gccobjdir)/final.o \
	$(gccobjdir)/recog.o \
	$(gccobjdir)/reg-stack.o \
	$(gccobjdir)/insn-opinit.o \
	$(gccobjdir)/insn-recog.o \
	$(gccobjdir)/insn-extract.o \
	$(gccobjdir)/insn-output.o \
	$(gccobjdir)/insn-emit.o \
	$(gccobjdir)/profile.o \
	$(gccobjdir)/insn-attrtab.o \
	$(gccobjdir)/aux-output.o \
	$(gccobjdir)/getpwd.o \
	$(gccobjdir)/lcm.o \
	$(gccobjdir)/gcse.o \
	$(gccobjdir)/sbitmap.o \
	$(gccobjdir)/varray.o \
	$(gccobjdir)/graph.o \
	$(gccobjdir)/hash.o

OBJS1 = $(gccobjdir)/convert.o \
	$(gccobjdir)/expr.o \
	$(gccobjdir)/fold-const.o \
	$(gccobjdir)/function.o \
	$(gccobjdir)/dbxout.o \
	$(gccobjdir)/optabs.o \
	$(gccobjdir)/stor-layout.o \
	$(gccobjdir)/toplev.o \
	$(gccobjdir)/tree.o \
	$(gccobjdir)/version.o

# C++ specific files
C++OBJS = $(gccobjdir)/cp/call.o \
	$(gccobjdir)/cp/class.o \
	$(gccobjdir)/cp/cvt.o \
	$(gccobjdir)/cp/decl.o \
	$(gccobjdir)/cp/decl2.o \
	$(gccobjdir)/cp/errfn.o \
	$(gccobjdir)/cp/error.o \
	$(gccobjdir)/cp/except.o \
	$(gccobjdir)/cp/expr.o \
	$(gccobjdir)/cp/friend.o \
	$(gccobjdir)/cp/init.o \
	$(gccobjdir)/cp/lex.o \
	$(gccobjdir)/cp/method.o \
	$(gccobjdir)/cp/parse.o \
	$(gccobjdir)/cp/pt.o \
	$(gccobjdir)/cp/ptree.o \
	$(gccobjdir)/cp/repo.o \
	$(gccobjdir)/cp/rtti.o \
	$(gccobjdir)/cp/search.o \
	$(gccobjdir)/cp/semantics.o \
	$(gccobjdir)/cp/sig.o \
	$(gccobjdir)/cp/spew.o \
	$(gccobjdir)/cp/tree.o \
	$(gccobjdir)/cp/typeck.o \
	$(gccobjdir)/cp/typeck2.o \
	$(gccobjdir)/cp/xref.o


$(gcc_bin_dir)/cc1plus$(gexesfx): $(C++OBJS) $(OBJS) $(OBJS1) \
        $(gccobjdir)/c-common.o $(gccobjdir)/c-pragma.o $(RISCOS_OBJS) $(LIBDEPS)
	$(LINK) $(C++OBJS) $(OBJS) $(OBJS1) $(gccobjdir)/c-common.o \
	$(gccobjdir)/c-pragma.o $(RISCOS_OBJS) $(LIBDEPS) $(LIBS)

$(bin_dir)/g++$(gexesfx): $(gccobjdir)/cp/g++.o $(gccobjdir)/cp/g++spec.o \
	$(gccobjdir)/version.o \
	$(gccobjdir)/config/arm/rname.o $(RISC_OBJS) $(LIBDEPS)
	$(LINK) $(gccobjdir)/cp/g++.o $(gccobjdir)/cp/g++spec.o \
	$(gccobjdir)/version.o \
	$(gccobjdir)/config/arm/rname.o $(RISC_OBJS) $(LIBDEPS) $(LIBS)


##############################################################################


# Make Bison sources
# Bison sources
# There's no point having a suffix thing for these becuase
# they're all built differently.

parse.c: parse.y
	bison -d parse.y -o parse.c
	grep "^#define[ 	]*YYEMPTY" parse.c >>parse.h


hash.h: gxx.gperf
	gperf -p -j1 -g -o -t -N is_reserved_word -k1,4,$$,7 <gxx.gperf >$@

$(gccobjdir)/cp/parse.o:	parse.c parse.y

$(gccobjdir)/cp/g++.o: ../gcc.c
	$(CC) $(CFLAGS) $(INCLUDES) -o $@ -c ../gcc.c \
	-DDEFAULT_TARGET_VERSION=\"$(VERSION)\" \
	-DDEFAULT_TARGET_MACHINE=\"$(TARGET_NAME)\" -DLANG_SPECIFIC_DRIVER \
	-DSTANDARD_STARTFILE_PREFIX=\"$(prefix)$(gn_standard_startfile_prefix)\" \
	-DSTANDARD_EXEC_PREFIX=\"$(prefix)$(gn_standard_exec_prefix)\"


# Dependencies
$(gccobjdir)/cp/call.o: call.c
$(gccobjdir)/cp/class.o: class.c
$(gccobjdir)/cp/cvt.o: cvt.c
$(gccobjdir)/cp/decl.o: decl.c
$(gccobjdir)/cp/decl2.o: decl2.c
$(gccobjdir)/cp/errfn.o: errfn.c
$(gccobjdir)/cp/error.o: error.c
$(gccobjdir)/cp/except.o: except.c
$(gccobjdir)/cp/expr.o: expr.c
$(gccobjdir)/cp/friend.o: friend.c
$(gccobjdir)/cp/g++spec.o: g++spec.c
$(gccobjdir)/cp/init.o: init.c
$(gccobjdir)/cp/input.o: input.c
$(gccobjdir)/cp/lex.o: lex.c
$(gccobjdir)/cp/method.o: method.c
$(gccobjdir)/cp/parse.o: parse.c
$(gccobjdir)/cp/pt.o: pt.c
$(gccobjdir)/cp/ptree.o: ptree.c
$(gccobjdir)/cp/repo.o: repo.c
$(gccobjdir)/cp/rtti.o: rtti.c
$(gccobjdir)/cp/search.o: search.c
$(gccobjdir)/cp/semantics.o: semantics.c
$(gccobjdir)/cp/sig.o: sig.c
$(gccobjdir)/cp/spew.o: spew.c
$(gccobjdir)/cp/tree.o: tree.c
$(gccobjdir)/cp/typeck.o: typeck.c
$(gccobjdir)/cp/typeck2.o: typeck2.c
$(gccobjdir)/cp/xref.o: xref.c 

$(gccobjdir)/cp/call.o:  \
 call.c ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def ../system.h \
  ../../../include/libiberty.h ../tree.h ../tree.def ../tree-check.h \
  ../real.h cp-tree.h ../cp-tree.def ../output.h ../flags.h ../rtl.h \
  ../rtl.def ../genrtl.h ../toplev.h ../../../include/obstack.h
$(gccobjdir)/cp/class.o:  \
 class.c ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def ../system.h \
  ../../../include/libiberty.h ../tree.h ../tree.def ../tree-check.h \
  ../real.h cp-tree.h ../cp-tree.def ../flags.h ../rtl.h ../rtl.def \
  ../genrtl.h ../output.h ../toplev.h ../../../include/splay-tree.h \
  ../../../include/obstack.h
$(gccobjdir)/cp/cvt.o:  \
 cvt.c ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def ../system.h \
  ../../../include/libiberty.h ../tree.h ../tree.def ../tree-check.h \
  ../real.h ../flags.h cp-tree.h ../cp-tree.def ../convert.h ../toplev.h \
  decl.h
$(gccobjdir)/cp/decl.o:  \
 decl.c ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def ../system.h \
  ../../../include/libiberty.h ../tree.h ../tree.def ../tree-check.h \
  ../real.h ../rtl.h ../rtl.def ../genrtl.h ../flags.h cp-tree.h \
  ../cp-tree.def decl.h lex.h ../../../include/obstack.h ../defaults.h \
  ../output.h ../except.h ../toplev.h ../hash.h ../stack.h
$(gccobjdir)/cp/decl2.o:  \
 decl2.c ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def ../system.h \
  ../../../include/libiberty.h ../tree.h ../tree.def ../tree-check.h \
  ../real.h ../rtl.h ../rtl.def ../genrtl.h ../flags.h cp-tree.h \
  ../cp-tree.def decl.h lex.h ../output.h ../except.h ../expr.h \
  ../insn-codes.h ../defaults.h ../toplev.h ../dwarf2out.h ../dwarfout.h \
  ../../../include/splay-tree.h ../varray.h
$(gccobjdir)/cp/errfn.o:  \
 errfn.c ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def ../system.h \
  ../../../include/libiberty.h ../tree.h ../tree.def ../tree-check.h \
  ../real.h cp-tree.h ../cp-tree.def ../toplev.h
$(gccobjdir)/cp/error.o:  \
 error.c ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def ../system.h \
  ../../../include/libiberty.h ../tree.h ../tree.def ../tree-check.h \
  ../real.h cp-tree.h ../cp-tree.def ../../../include/obstack.h \
  ../toplev.h
$(gccobjdir)/cp/except.o:  \
 except.c ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def ../system.h \
  ../../../include/libiberty.h ../tree.h ../tree.def ../tree-check.h \
  ../real.h ../rtl.h ../rtl.def ../genrtl.h cp-tree.h ../cp-tree.def \
  ../flags.h ../../../include/obstack.h ../expr.h ../insn-codes.h \
  ../output.h ../except.h ../function.h ../defaults.h ../toplev.h \
  ../eh-common.h decl.h ../insn-flags.h
$(gccobjdir)/cp/expr.o:  \
 expr.c ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def ../system.h \
  ../../../include/libiberty.h ../rtl.h ../rtl.def ../genrtl.h ../tree.h \
  ../tree.def ../tree-check.h ../real.h ../flags.h ../expr.h \
  ../insn-codes.h cp-tree.h ../cp-tree.def ../toplev.h
$(gccobjdir)/cp/friend.o:  \
 friend.c ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def ../system.h \
  ../../../include/libiberty.h ../tree.h ../tree.def ../tree-check.h \
  ../real.h ../rtl.h ../rtl.def ../genrtl.h cp-tree.h ../cp-tree.def \
  ../flags.h ../output.h ../toplev.h
$(gccobjdir)/cp/g++.o:  \
 ../gcc.c ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def ../system.h \
  ../../../include/libiberty.h ../../../include/obstack.h ../intl.h \
  ../prefix.h ../multilib.h ../specs.h ../cp/lang-specs.h \
  ../objc/lang-specs.h ../f77/lang-specs.h ../java/lang-specs.h \
  ../gpc/lang-specs.h ../gpc/version.h
$(gccobjdir)/cp/g++spec.o:  \
 g++spec.c ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def ../system.h \
  ../../../include/libiberty.h
$(gccobjdir)/cp/init.o:  \
 init.c ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def ../system.h \
  ../../../include/libiberty.h ../tree.h ../tree.def ../tree-check.h \
  ../real.h ../rtl.h ../rtl.def ../genrtl.h cp-tree.h ../cp-tree.def \
  ../flags.h ../output.h ../except.h ../expr.h ../insn-codes.h \
  ../toplev.h
$(gccobjdir)/cp/lex.o:  \
 lex.c ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def ../system.h \
  ../../../include/libiberty.h ../input.h ../tree.h ../tree.def \
  ../tree-check.h ../real.h lex.h cp-tree.h ../cp-tree.def parse.h \
  ../flags.h ../../../include/obstack.h ../c-pragma.h ../toplev.h \
  ../output.h input.c hash.h
$(gccobjdir)/cp/method.o:  \
 method.c ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def ../system.h \
  ../../../include/libiberty.h ../tree.h ../tree.def ../tree-check.h \
  ../real.h cp-tree.h ../cp-tree.def ../../../include/obstack.h ../rtl.h \
  ../rtl.def ../genrtl.h ../expr.h ../insn-codes.h ../output.h \
  ../hard-reg-set.h ../flags.h ../toplev.h
$(gccobjdir)/cp/parse.o:  \
 parse.c ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def ../system.h \
  ../../../include/libiberty.h ../tree.h ../tree.def ../tree-check.h \
  ../real.h ../input.h ../flags.h lex.h cp-tree.h ../cp-tree.def \
  ../output.h ../except.h ../toplev.h
$(gccobjdir)/cp/pt.o:  \
 pt.c ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def ../system.h \
  ../../../include/libiberty.h ../../../include/obstack.h ../tree.h \
  ../tree.def ../tree-check.h ../real.h ../flags.h cp-tree.h \
  ../cp-tree.def decl.h parse.h lex.h ../output.h ../defaults.h \
  ../except.h ../toplev.h ../rtl.h ../rtl.def ../genrtl.h ../varray.h
$(gccobjdir)/cp/ptree.o:  \
 ptree.c ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def ../system.h \
  ../../../include/libiberty.h ../tree.h ../tree.def ../tree-check.h \
  ../real.h cp-tree.h ../cp-tree.def
$(gccobjdir)/cp/repo.o:  \
 repo.c ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def ../system.h \
  ../../../include/libiberty.h ../tree.h ../tree.def ../tree-check.h \
  ../real.h cp-tree.h ../cp-tree.def ../input.h \
  ../../../include/obstack.h ../toplev.h
$(gccobjdir)/cp/rtti.o:  \
 rtti.c ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def ../system.h \
  ../../../include/libiberty.h ../tree.h ../tree.def ../tree-check.h \
  ../real.h cp-tree.h ../cp-tree.def ../flags.h ../output.h \
  /usr/include/assert.h ../toplev.h
$(gccobjdir)/cp/search.o:  \
 search.c ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def ../system.h \
  ../../../include/libiberty.h ../tree.h ../tree.def ../tree-check.h \
  ../real.h cp-tree.h ../cp-tree.def ../../../include/obstack.h \
  ../flags.h ../rtl.h ../rtl.def ../genrtl.h ../output.h ../toplev.h \
  ../varray.h ../stack.h
$(gccobjdir)/cp/semantics.o:  \
 semantics.c ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def ../system.h \
  ../../../include/libiberty.h ../tree.h ../tree.def ../tree-check.h \
  ../real.h cp-tree.h ../cp-tree.def ../except.h lex.h ../toplev.h
$(gccobjdir)/cp/sig.o:  \
 sig.c ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def ../system.h \
  ../../../include/libiberty.h ../../../include/obstack.h ../tree.h \
  ../tree.def ../tree-check.h ../real.h cp-tree.h ../cp-tree.def \
  ../flags.h /usr/include/assert.h ../toplev.h
$(gccobjdir)/cp/spew.o:  \
 spew.c ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def ../system.h \
  ../../../include/libiberty.h ../input.h ../tree.h ../tree.def \
  ../tree-check.h ../real.h lex.h cp-tree.h ../cp-tree.def parse.h \
  ../flags.h ../../../include/obstack.h ../toplev.h
$(gccobjdir)/cp/tree.o:  \
 tree.c ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def ../system.h \
  ../../../include/libiberty.h ../../../include/obstack.h ../tree.h \
  ../tree.def ../tree-check.h ../real.h cp-tree.h ../cp-tree.def \
  ../flags.h ../rtl.h ../rtl.def ../genrtl.h ../toplev.h
$(gccobjdir)/cp/typeck.o:  \
 typeck.c ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def ../system.h \
  ../../../include/libiberty.h ../tree.h ../tree.def ../tree-check.h \
  ../real.h ../rtl.h ../rtl.def ../genrtl.h cp-tree.h ../cp-tree.def \
  ../flags.h ../output.h ../expr.h ../insn-codes.h ../toplev.h
$(gccobjdir)/cp/typeck2.o:  \
 typeck2.c ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def ../system.h \
  ../../../include/libiberty.h ../tree.h ../tree.def ../tree-check.h \
  ../real.h cp-tree.h ../cp-tree.def ../flags.h ../toplev.h
$(gccobjdir)/cp/xref.o:  \
 xref.c ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def ../system.h \
  ../../../include/libiberty.h ../tree.h ../tree.def ../tree-check.h \
  ../real.h cp-tree.h ../cp-tree.def ../input.h ../toplev.h
