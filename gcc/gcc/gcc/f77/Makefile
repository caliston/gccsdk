# Makefile for the GNU Fortran 77 compiler for ARM/RISC OS
# Copyright (c) 1997, 1998, 1999, 2000 Nick Burrett
# Written by Nick Burrett <nick@dsvr.net>

# Defs for GCC
LINK = $(CC) -o $@
INCLUDES = -I./ -I../ -I../../../include -I../config
LIBS = -L$(objdir)/libiberty/$(STAGE) -liberty

$(gccobjdir)/f77/%.o: %.c
	$(CC) $(CFLAGS) -o $@ -c $< $(INCLUDES)

all: fortran77 docs

.PHONY: fortran77
.PHONY: docs

ifeq (${STAGE},stage1)
docs:
else
docs:	$(info_dir)/g77
endif

fortran77: $(gccobjdir)/f77/fini $(bin_dir)/g77$(gexesfx) \
  $(gcc_bin_dir)/f771$(gexesfx)

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


F77_OBJS = $(gccobjdir)/f77/stb.o \
	$(gccobjdir)/f77/target.o \
	$(gccobjdir)/f77/symbol.o \
	$(gccobjdir)/f77/stu.o \
	$(gccobjdir)/f77/stt.o \
	$(gccobjdir)/f77/ste.o \
	$(gccobjdir)/f77/stc.o \
	$(gccobjdir)/f77/intrin.o \
	$(gccobjdir)/f77/implic.o \
	$(gccobjdir)/f77/expr.o \
	$(gccobjdir)/f77/data.o \
	$(gccobjdir)/f77/com.o \
	$(gccobjdir)/f77/bld.o \
	$(gccobjdir)/f77/bad.o \
	$(gccobjdir)/f77/bit.o \
	$(gccobjdir)/f77/equiv.o \
	$(gccobjdir)/f77/global.o \
	$(gccobjdir)/f77/info.o \
	$(gccobjdir)/f77/lab.o \
	$(gccobjdir)/f77/lex.o \
	$(gccobjdir)/f77/malloc.o \
	$(gccobjdir)/f77/name.o \
	$(gccobjdir)/f77/parse.o \
	$(gccobjdir)/f77/proj.o \
	$(gccobjdir)/f77/src.o \
	$(gccobjdir)/f77/st.o \
	$(gccobjdir)/f77/sta.o \
	$(gccobjdir)/f77/std.o \
	$(gccobjdir)/f77/storag.o \
	$(gccobjdir)/f77/stp.o \
	$(gccobjdir)/f77/str.o \
	$(gccobjdir)/f77/sts.o \
	$(gccobjdir)/f77/stv.o \
	$(gccobjdir)/f77/stw.o \
	$(gccobjdir)/f77/top.o \
	$(gccobjdir)/f77/type.o \
	$(gccobjdir)/f77/where.o \
	$(gccobjdir)/f77/version.o

STR_HEADERS = str-1t.h str-2t.h str-fo.h str-io.h str-nq.h str-op.h str-ot.h \
	str-1t.j str-2t.j str-fo.j str-io.j str-nq.j str-op.j str-ot.j


# The real targets
$(bin_dir)/g77$(gexesfx): $(gccobjdir)/f77/g77.o $(gccobjdir)/f77/g77spec.o \
	$(gccobjdir)/version.o \
	$(gccobjdir)/f77/version.o $(gccobjdir)/config/arm/rname.o \
	$(RISC_OBJS) $(LIBDEPS)
	$(LINK) $(gccobjdir)/f77/g77.o $(gccobjdir)/f77/g77spec.o \
	$(gccobjdir)/version.o \
	$(gccobjdir)/f77/version.o $(gccobjdir)/config/arm/rname.o \
	$(RISC_OBJS) $(LIBDEPS) $(LIBS)

$(gccobjdir)/f77/fini:	$(gccobjdir)/f77/fini.o $(gccobjdir)/f77/proj.o $(LIBDEPS)
	$(LINK) $(gccobjdir)/f77/fini.o $(gccobjdir)/f77/proj.o \
	$(LIBDEPS) $(LIBS)

$(gcc_bin_dir)/f771$(gexesfx): $(F77_OBJS) $(OBJS) $(OBJS1) $(BC_OBJS) $(RISCOS_OBJS) $(STR_HEADERS)
	$(LINK) $(F77_OBJS) $(OBJS) $(OBJS1) $(BC_OBJS) $(RISCOS_OBJS) $(LIBDEPS) $(LIBS)

ifeq (${STAGE},stage2)
$(info_dir)/g77:	bugs.texi bugs0.texi ffe.texi g77.texi \
	g77install.texi install0.texi intdoc.texi news.texi news0.texi \
	root.texi
	-makeinfo --no-split --number-sections --force g77.texi -o $@
endif

##############################################################################

# Fortran 77 make sources

ifeq (${STAGE},stage1)
# the j.str-1t.j equivalents are automatically updated with the fini program

str-1t.h str-1t.j:	fin/str-1t $(gccobjdir)/f77/fini
		$(gccobjdir)/f77/fini fin/str-1t str-1t.j str-1t.h

str-2t.h str-2t.j:	fin/str-2t $(gccobjdir)/f77/fini
		$(gccobjdir)/f77/fini fin/str-2t str-2t.j str-2t.h

str-fo.h str-fo.j:	fin/str-fo $(gccobjdir)/f77/fini
		$(gccobjdir)/f77/fini fin/str-fo str-fo.j str-fo.h

str-io.h str-io.j:	fin/str-io $(gccobjdir)/f77/fini
		$(gccobjdir)/f77/fini fin/str-io str-io.j str-io.h

str-nq.h str-nq.j:	fin/str-nq $(gccobjdir)/f77/fini
		$(gccobjdir)/f77/fini fin/str-nq str-nq.j str-nq.h

str-op.h str-op.j:	fin/str-op $(gccobjdir)/f77/fini
		$(gccobjdir)/f77/fini fin/str-op str-op.j str-op.h

str-ot.h str-ot.j:	fin/str-ot $(gccobjdir)/f77/fini
		$(gccobjdir)/f77/fini fin/str-ot str-ot.j str-ot.h
endif

##############################################################################

$(gccobjdir)/f77/g77.o: ../gcc.c
	$(CC) $(CFLAGS) $(INCLUDES) -o $@ -c ../gcc.c \
	-DDEFAULT_TARGET_VERSION=\"$(VERSION)\" \
	-DDEFAULT_TARGET_MACHINE=\"$(TARGET_NAME)\" -DLANG_SPECIFIC_DRIVER \
	-DSTANDARD_STARTFILE_PREFIX=\"$(prefix)$(gn_standard_startfile_prefix)\" \
	-DSTANDARD_EXEC_PREFIX=\"$(prefix)$(gn_standard_exec_prefix)\"

# Dependencies
$(gccobjdir)/f77/ansify.o: ansify.c
$(gccobjdir)/f77/bad.o: bad.c
$(gccobjdir)/f77/bit.o: bit.c
$(gccobjdir)/f77/bld.o: bld.c
$(gccobjdir)/f77/com.o: com.c
$(gccobjdir)/f77/data.o: data.c
$(gccobjdir)/f77/equiv.o: equiv.c
$(gccobjdir)/f77/expr.o: expr.c
$(gccobjdir)/f77/fini.o: fini.c
$(gccobjdir)/f77/g77spec.o: g77spec.c
$(gccobjdir)/f77/global.o: global.c
$(gccobjdir)/f77/implic.o: implic.c
$(gccobjdir)/f77/info.o: info.c
$(gccobjdir)/f77/intdoc.o: intdoc.c
$(gccobjdir)/f77/intrin.o: intrin.c
$(gccobjdir)/f77/lab.o: lab.c
$(gccobjdir)/f77/lex.o: lex.c
$(gccobjdir)/f77/malloc.o: malloc.c
$(gccobjdir)/f77/name.o: name.c
$(gccobjdir)/f77/parse.o: parse.c
$(gccobjdir)/f77/proj.o: proj.c
$(gccobjdir)/f77/src.o: src.c
$(gccobjdir)/f77/st.o: st.c
$(gccobjdir)/f77/sta.o: sta.c
$(gccobjdir)/f77/stb.o: stb.c str.h str-1t.h str-fo.h \
	str-io.h str-nq.h str-ot.h str-op.h str-2t.h
$(gccobjdir)/f77/stc.o: stc.c
$(gccobjdir)/f77/std.o: std.c
$(gccobjdir)/f77/ste.o: ste.c
$(gccobjdir)/f77/storag.o: storag.c
$(gccobjdir)/f77/stp.o: stp.c
$(gccobjdir)/f77/str.o: str.c
$(gccobjdir)/f77/sts.o: sts.c
$(gccobjdir)/f77/stt.o: stt.c
$(gccobjdir)/f77/stu.o: stu.c
$(gccobjdir)/f77/stv.o: stv.c
$(gccobjdir)/f77/stw.o: stw.c
$(gccobjdir)/f77/symbol.o: symbol.c
$(gccobjdir)/f77/target.o: target.c
$(gccobjdir)/f77/top.o: top.c
$(gccobjdir)/f77/type.o: type.c
$(gccobjdir)/f77/version.o: version.c
$(gccobjdir)/f77/where.o: where.c


$(gccobjdir)/f77/bad.o:  \
 bad.c proj.h config.j ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def system.j ../system.h \
  ../../../include/libiberty.h assert.j /usr/include/assert.h bad.h \
  bad.def where.h glimits.j ../glimits.h top.h malloc.h flags.j \
  ../flags.h com.h com-rt.def tree.j ../tree.h ../tree.def \
  ../tree-check.h ../real.h bld.h bld-op.def bit.h info.h info-b.def \
  info-k.def info-w.def target.h lex.h type.h intrin.h intrin.def lab.h \
  symbol.h symbol.def equiv.h storag.h global.h name.h toplev.j \
  ../toplev.h
$(gccobjdir)/f77/bit.o:  \
 bit.c proj.h config.j ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def system.j ../system.h \
  ../../../include/libiberty.h assert.j /usr/include/assert.h glimits.j \
  ../glimits.h bit.h malloc.h
$(gccobjdir)/f77/bld.o:  \
 bld.c proj.h config.j ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def system.j ../system.h \
  ../../../include/libiberty.h assert.j /usr/include/assert.h bld.h \
  bld-op.def bit.h malloc.h com.h com-rt.def tree.j ../tree.h ../tree.def \
  ../tree-check.h ../real.h info.h info-b.def info-k.def info-w.def \
  target.h bad.h bad.def where.h glimits.j ../glimits.h top.h lex.h \
  type.h lab.h storag.h symbol.h symbol.def equiv.h global.h name.h \
  intrin.h intrin.def
$(gccobjdir)/f77/com.o:  \
 com.c proj.h config.j ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def system.j ../system.h \
  ../../../include/libiberty.h assert.j /usr/include/assert.h flags.j \
  ../flags.h rtl.j ../rtl.h ../rtl.def ../genrtl.h toplev.j ../toplev.h \
  tree.j ../tree.h ../tree.def ../tree-check.h ../real.h output.j \
  ../output.h convert.j ../convert.h com.h com-rt.def bld.h bld-op.def \
  bit.h malloc.h info.h info-b.def info-k.def info-w.def target.h bad.h \
  bad.def where.h glimits.j ../glimits.h top.h lex.h type.h intrin.h \
  intrin.def lab.h symbol.h symbol.def equiv.h storag.h global.h name.h \
  expr.h implic.h src.h st.h
$(gccobjdir)/f77/data.o:  \
 data.c proj.h config.j ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def system.j ../system.h \
  ../../../include/libiberty.h assert.j /usr/include/assert.h data.h \
  bld.h bld-op.def bit.h malloc.h com.h com-rt.def tree.j ../tree.h \
  ../tree.def ../tree-check.h ../real.h info.h info-b.def info-k.def \
  info-w.def target.h bad.h bad.def where.h glimits.j ../glimits.h top.h \
  lex.h type.h lab.h storag.h symbol.h symbol.def equiv.h global.h name.h \
  intrin.h intrin.def expr.h st.h
$(gccobjdir)/f77/equiv.o:  \
 equiv.c proj.h config.j ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def system.j ../system.h \
  ../../../include/libiberty.h assert.j /usr/include/assert.h equiv.h \
  bld.h bld-op.def bit.h malloc.h com.h com-rt.def tree.j ../tree.h \
  ../tree.def ../tree-check.h ../real.h info.h info-b.def info-k.def \
  info-w.def target.h bad.h bad.def where.h glimits.j ../glimits.h top.h \
  lex.h type.h lab.h storag.h symbol.h symbol.def global.h name.h \
  intrin.h intrin.def data.h
$(gccobjdir)/f77/expr.o:  \
 expr.c proj.h config.j ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def system.j ../system.h \
  ../../../include/libiberty.h assert.j /usr/include/assert.h expr.h \
  bld.h bld-op.def bit.h malloc.h com.h com-rt.def tree.j ../tree.h \
  ../tree.def ../tree-check.h ../real.h info.h info-b.def info-k.def \
  info-w.def target.h bad.h bad.def where.h glimits.j ../glimits.h top.h \
  lex.h type.h lab.h storag.h symbol.h symbol.def equiv.h global.h name.h \
  intrin.h intrin.def implic.h src.h st.h str.h str-1t.h str-fo.h \
  str-io.h str-nq.h str-ot.h str-op.h str-2t.h
$(gccobjdir)/f77/fini.o:  \
 fini.c proj.h hconfig.j ../hconfig.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def system.j ../system.h \
  ../../../include/libiberty.h assert.j /usr/include/assert.h malloc.h
$(gccobjdir)/f77/g77.o:  \
 ../gcc.c ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def ../system.h \
  ../../../include/libiberty.h ../../../include/obstack.h ../intl.h \
  ../prefix.h ../multilib.h ../specs.h ../cp/lang-specs.h \
  ../objc/lang-specs.h ../f77/lang-specs.h ../java/lang-specs.h \
  ../gpc/lang-specs.h ../gpc/version.h
$(gccobjdir)/f77/g77spec.o:  \
 g77spec.c ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def ../system.h \
  ../../../include/libiberty.h
$(gccobjdir)/f77/global.o:  \
 global.c proj.h config.j ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def system.j ../system.h \
  ../../../include/libiberty.h assert.j /usr/include/assert.h global.h \
  info.h info-b.def info-k.def info-w.def target.h tree.j ../tree.h \
  ../tree.def ../tree-check.h ../real.h bad.h bad.def where.h glimits.j \
  ../glimits.h top.h malloc.h lex.h type.h name.h symbol.h symbol.def \
  bld.h bld-op.def bit.h com.h com-rt.def lab.h storag.h intrin.h \
  intrin.def equiv.h
$(gccobjdir)/f77/implic.o:  \
 implic.c proj.h config.j ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def system.j ../system.h \
  ../../../include/libiberty.h assert.j /usr/include/assert.h implic.h \
  info.h info-b.def info-k.def info-w.def target.h tree.j ../tree.h \
  ../tree.def ../tree-check.h ../real.h bad.h bad.def where.h glimits.j \
  ../glimits.h top.h malloc.h lex.h type.h symbol.h symbol.def bld.h \
  bld-op.def bit.h com.h com-rt.def lab.h storag.h intrin.h intrin.def \
  equiv.h global.h name.h src.h
$(gccobjdir)/f77/info.o:  \
 info.c proj.h config.j ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def system.j ../system.h \
  ../../../include/libiberty.h assert.j /usr/include/assert.h info.h \
  info-b.def info-k.def info-w.def target.h tree.j ../tree.h ../tree.def \
  ../tree-check.h ../real.h bad.h bad.def where.h glimits.j ../glimits.h \
  top.h malloc.h lex.h type.h
$(gccobjdir)/f77/intrin.o:  \
 intrin.c proj.h config.j ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def system.j ../system.h \
  ../../../include/libiberty.h assert.j /usr/include/assert.h intrin.h \
  intrin.def bld.h bld-op.def bit.h malloc.h com.h com-rt.def tree.j \
  ../tree.h ../tree.def ../tree-check.h ../real.h info.h info-b.def \
  info-k.def info-w.def target.h bad.h bad.def where.h glimits.j \
  ../glimits.h top.h lex.h type.h lab.h storag.h symbol.h symbol.def \
  equiv.h global.h name.h expr.h src.h
$(gccobjdir)/f77/lab.o:  \
 lab.c proj.h config.j ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def system.j ../system.h \
  ../../../include/libiberty.h assert.j /usr/include/assert.h lab.h com.h \
  com-rt.def tree.j ../tree.h ../tree.def ../tree-check.h ../real.h bld.h \
  bld-op.def bit.h malloc.h info.h info-b.def info-k.def info-w.def \
  target.h bad.h bad.def where.h glimits.j ../glimits.h top.h lex.h \
  type.h intrin.h intrin.def symbol.h symbol.def equiv.h storag.h \
  global.h name.h
$(gccobjdir)/f77/lex.o:  \
 lex.c proj.h config.j ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def system.j ../system.h \
  ../../../include/libiberty.h assert.j /usr/include/assert.h top.h \
  malloc.h where.h glimits.j ../glimits.h bad.h bad.def com.h com-rt.def \
  tree.j ../tree.h ../tree.def ../tree-check.h ../real.h bld.h bld-op.def \
  bit.h info.h info-b.def info-k.def info-w.def target.h lex.h type.h \
  intrin.h intrin.def lab.h symbol.h symbol.def equiv.h storag.h global.h \
  name.h src.h flags.j ../flags.h input.j ../input.h toplev.j ../toplev.h \
  output.j ../output.h
$(gccobjdir)/f77/malloc.o:  \
 malloc.c proj.h config.j ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def system.j ../system.h \
  ../../../include/libiberty.h assert.j /usr/include/assert.h malloc.h
$(gccobjdir)/f77/name.o:  \
 name.c proj.h config.j ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def system.j ../system.h \
  ../../../include/libiberty.h assert.j /usr/include/assert.h bad.h \
  bad.def where.h glimits.j ../glimits.h top.h malloc.h name.h global.h \
  info.h info-b.def info-k.def info-w.def target.h tree.j ../tree.h \
  ../tree.def ../tree-check.h ../real.h lex.h type.h symbol.h symbol.def \
  bld.h bld-op.def bit.h com.h com-rt.def lab.h storag.h intrin.h \
  intrin.def equiv.h src.h
$(gccobjdir)/f77/parse.o:  \
 parse.c proj.h config.j ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def system.j ../system.h \
  ../../../include/libiberty.h assert.j /usr/include/assert.h top.h \
  malloc.h where.h glimits.j ../glimits.h com.h com-rt.def tree.j \
  ../tree.h ../tree.def ../tree-check.h ../real.h bld.h bld-op.def bit.h \
  info.h info-b.def info-k.def info-w.def target.h bad.h bad.def lex.h \
  type.h intrin.h intrin.def lab.h symbol.h symbol.def equiv.h storag.h \
  global.h name.h version.h flags.j ../flags.h
$(gccobjdir)/f77/proj.o:  \
 proj.c proj.h config.j ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def system.j ../system.h \
  ../../../include/libiberty.h assert.j /usr/include/assert.h glimits.j \
  ../glimits.h
$(gccobjdir)/f77/src.o:  \
 src.c proj.h config.j ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def system.j ../system.h \
  ../../../include/libiberty.h assert.j /usr/include/assert.h src.h bad.h \
  bad.def where.h glimits.j ../glimits.h top.h malloc.h
$(gccobjdir)/f77/st.o:  \
 st.c proj.h config.j ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def system.j ../system.h \
  ../../../include/libiberty.h assert.j /usr/include/assert.h st.h bad.h \
  bad.def where.h glimits.j ../glimits.h top.h malloc.h lex.h symbol.h \
  symbol.def bld.h bld-op.def bit.h com.h com-rt.def tree.j ../tree.h \
  ../tree.def ../tree-check.h ../real.h info.h info-b.def info-k.def \
  info-w.def target.h type.h lab.h storag.h intrin.h intrin.def equiv.h \
  global.h name.h sta.h str.h str-1t.h str-fo.h str-io.h str-nq.h \
  str-ot.h str-op.h str-2t.h stb.h expr.h stp.h stt.h stc.h std.h stv.h \
  stw.h ste.h sts.h stu.h
$(gccobjdir)/f77/sta.o:  \
 sta.c proj.h config.j ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def system.j ../system.h \
  ../../../include/libiberty.h assert.j /usr/include/assert.h sta.h bad.h \
  bad.def where.h glimits.j ../glimits.h top.h malloc.h lex.h str.h \
  str-1t.h str-fo.h str-io.h str-nq.h str-ot.h str-op.h str-2t.h symbol.h \
  symbol.def bld.h bld-op.def bit.h com.h com-rt.def tree.j ../tree.h \
  ../tree.def ../tree-check.h ../real.h info.h info-b.def info-k.def \
  info-w.def target.h type.h lab.h storag.h intrin.h intrin.def equiv.h \
  global.h name.h implic.h stb.h expr.h stp.h stt.h stc.h std.h stv.h \
  stw.h
$(gccobjdir)/f77/stb.o:  \
 stb.c proj.h config.j ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def system.j ../system.h \
  ../../../include/libiberty.h assert.j /usr/include/assert.h stb.h bad.h \
  bad.def where.h glimits.j ../glimits.h top.h malloc.h expr.h bld.h \
  bld-op.def bit.h com.h com-rt.def tree.j ../tree.h ../tree.def \
  ../tree-check.h ../real.h info.h info-b.def info-k.def info-w.def \
  target.h lex.h type.h lab.h storag.h symbol.h symbol.def equiv.h \
  global.h name.h intrin.h intrin.def stp.h stt.h str.h str-1t.h str-fo.h \
  str-io.h str-nq.h str-ot.h str-op.h str-2t.h src.h sta.h stc.h
$(gccobjdir)/f77/stc.o:  \
 stc.c proj.h config.j ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def system.j ../system.h \
  ../../../include/libiberty.h assert.j /usr/include/assert.h stc.h bad.h \
  bad.def where.h glimits.j ../glimits.h top.h malloc.h bld.h bld-op.def \
  bit.h com.h com-rt.def tree.j ../tree.h ../tree.def ../tree-check.h \
  ../real.h info.h info-b.def info-k.def info-w.def target.h lex.h type.h \
  lab.h storag.h symbol.h symbol.def equiv.h global.h name.h intrin.h \
  intrin.def expr.h stp.h stt.h str.h str-1t.h str-fo.h str-io.h str-nq.h \
  str-ot.h str-op.h str-2t.h data.h implic.h src.h sta.h std.h stv.h \
  stw.h
$(gccobjdir)/f77/std.o:  \
 std.c proj.h config.j ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def system.j ../system.h \
  ../../../include/libiberty.h assert.j /usr/include/assert.h std.h bld.h \
  bld-op.def bit.h malloc.h com.h com-rt.def tree.j ../tree.h ../tree.def \
  ../tree-check.h ../real.h info.h info-b.def info-k.def info-w.def \
  target.h bad.h bad.def where.h glimits.j ../glimits.h top.h lex.h \
  type.h lab.h storag.h symbol.h symbol.def equiv.h global.h name.h \
  intrin.h intrin.def stp.h stt.h str.h str-1t.h str-fo.h str-io.h \
  str-nq.h str-ot.h str-op.h str-2t.h stv.h stw.h sta.h ste.h sts.h
$(gccobjdir)/f77/ste.o:  \
 ste.c proj.h config.j ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def system.j ../system.h \
  ../../../include/libiberty.h assert.j /usr/include/assert.h rtl.j \
  ../rtl.h ../rtl.def ../genrtl.h toplev.j ../toplev.h ste.h bld.h \
  bld-op.def bit.h malloc.h com.h com-rt.def tree.j ../tree.h ../tree.def \
  ../tree-check.h ../real.h info.h info-b.def info-k.def info-w.def \
  target.h bad.h bad.def where.h glimits.j ../glimits.h top.h lex.h \
  type.h lab.h storag.h symbol.h symbol.def equiv.h global.h name.h \
  intrin.h intrin.def stp.h stt.h str.h str-1t.h str-fo.h str-io.h \
  str-nq.h str-ot.h str-op.h str-2t.h sts.h stv.h stw.h expr.h sta.h
$(gccobjdir)/f77/storag.o:  \
 storag.c proj.h config.j ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def system.j ../system.h \
  ../../../include/libiberty.h assert.j /usr/include/assert.h storag.h \
  bld.h bld-op.def bit.h malloc.h com.h com-rt.def tree.j ../tree.h \
  ../tree.def ../tree-check.h ../real.h info.h info-b.def info-k.def \
  info-w.def target.h bad.h bad.def where.h glimits.j ../glimits.h top.h \
  lex.h type.h lab.h symbol.h symbol.def equiv.h global.h name.h intrin.h \
  intrin.def data.h
$(gccobjdir)/f77/stp.o:  \
 stp.c proj.h config.j ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def system.j ../system.h \
  ../../../include/libiberty.h assert.j /usr/include/assert.h stp.h bld.h \
  bld-op.def bit.h malloc.h com.h com-rt.def tree.j ../tree.h ../tree.def \
  ../tree-check.h ../real.h info.h info-b.def info-k.def info-w.def \
  target.h bad.h bad.def where.h glimits.j ../glimits.h top.h lex.h \
  type.h lab.h storag.h symbol.h symbol.def equiv.h global.h name.h \
  intrin.h intrin.def stt.h
$(gccobjdir)/f77/str.o:  \
 str.c proj.h config.j ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def system.j ../system.h \
  ../../../include/libiberty.h assert.j /usr/include/assert.h src.h bad.h \
  bad.def where.h glimits.j ../glimits.h top.h malloc.h str.h lex.h \
  str-1t.h str-fo.h str-io.h str-nq.h str-ot.h str-op.h str-2t.h str-1t.j \
  str-fo.j str-io.j str-nq.j str-op.j str-ot.j str-2t.j
$(gccobjdir)/f77/sts.o:  \
 sts.c proj.h config.j ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def system.j ../system.h \
  ../../../include/libiberty.h assert.j /usr/include/assert.h sts.h \
  malloc.h com.h com-rt.def tree.j ../tree.h ../tree.def ../tree-check.h \
  ../real.h bld.h bld-op.def bit.h info.h info-b.def info-k.def \
  info-w.def target.h bad.h bad.def where.h glimits.j ../glimits.h top.h \
  lex.h type.h intrin.h intrin.def lab.h symbol.h symbol.def equiv.h \
  storag.h global.h name.h
$(gccobjdir)/f77/stt.o:  \
 stt.c proj.h config.j ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def system.j ../system.h \
  ../../../include/libiberty.h assert.j /usr/include/assert.h stt.h top.h \
  malloc.h where.h glimits.j ../glimits.h bld.h bld-op.def bit.h com.h \
  com-rt.def tree.j ../tree.h ../tree.def ../tree-check.h ../real.h \
  info.h info-b.def info-k.def info-w.def target.h bad.h bad.def lex.h \
  type.h lab.h storag.h symbol.h symbol.def equiv.h global.h name.h \
  intrin.h intrin.def stp.h expr.h sta.h str.h str-1t.h str-fo.h str-io.h \
  str-nq.h str-ot.h str-op.h str-2t.h
$(gccobjdir)/f77/stu.o:  \
 stu.c proj.h config.j ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def system.j ../system.h \
  ../../../include/libiberty.h assert.j /usr/include/assert.h bld.h \
  bld-op.def bit.h malloc.h com.h com-rt.def tree.j ../tree.h ../tree.def \
  ../tree-check.h ../real.h info.h info-b.def info-k.def info-w.def \
  target.h bad.h bad.def where.h glimits.j ../glimits.h top.h lex.h \
  type.h lab.h storag.h symbol.h symbol.def equiv.h global.h name.h \
  intrin.h intrin.def implic.h stu.h sta.h str.h str-1t.h str-fo.h \
  str-io.h str-nq.h str-ot.h str-op.h str-2t.h
$(gccobjdir)/f77/stv.o:  \
 stv.c proj.h config.j ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def system.j ../system.h \
  ../../../include/libiberty.h assert.j /usr/include/assert.h stv.h lab.h \
  com.h com-rt.def tree.j ../tree.h ../tree.def ../tree-check.h ../real.h \
  bld.h bld-op.def bit.h malloc.h info.h info-b.def info-k.def info-w.def \
  target.h bad.h bad.def where.h glimits.j ../glimits.h top.h lex.h \
  type.h intrin.h intrin.def symbol.h symbol.def equiv.h storag.h \
  global.h name.h
$(gccobjdir)/f77/stw.o:  \
 stw.c proj.h config.j ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def system.j ../system.h \
  ../../../include/libiberty.h assert.j /usr/include/assert.h stw.h bld.h \
  bld-op.def bit.h malloc.h com.h com-rt.def tree.j ../tree.h ../tree.def \
  ../tree-check.h ../real.h info.h info-b.def info-k.def info-w.def \
  target.h bad.h bad.def where.h glimits.j ../glimits.h top.h lex.h \
  type.h lab.h storag.h symbol.h symbol.def equiv.h global.h name.h \
  intrin.h intrin.def stv.h sta.h str.h str-1t.h str-fo.h str-io.h \
  str-nq.h str-ot.h str-op.h str-2t.h
$(gccobjdir)/f77/symbol.o:  \
 symbol.c proj.h config.j ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def system.j ../system.h \
  ../../../include/libiberty.h assert.j /usr/include/assert.h symbol.h \
  symbol.def bld.h bld-op.def bit.h malloc.h com.h com-rt.def tree.j \
  ../tree.h ../tree.def ../tree-check.h ../real.h info.h info-b.def \
  info-k.def info-w.def target.h bad.h bad.def where.h glimits.j \
  ../glimits.h top.h lex.h type.h lab.h storag.h intrin.h intrin.def \
  equiv.h global.h name.h src.h st.h
$(gccobjdir)/f77/target.o:  \
 target.c proj.h config.j ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def system.j ../system.h \
  ../../../include/libiberty.h assert.j /usr/include/assert.h glimits.j \
  ../glimits.h target.h tree.j ../tree.h ../tree.def ../tree-check.h \
  ../real.h bad.h bad.def where.h top.h malloc.h info.h info-b.def \
  info-k.def info-w.def type.h lex.h
$(gccobjdir)/f77/top.o:  \
 top.c proj.h config.j ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def system.j ../system.h \
  ../../../include/libiberty.h assert.j /usr/include/assert.h top.h \
  malloc.h where.h glimits.j ../glimits.h bad.h bad.def bit.h bld.h \
  bld-op.def com.h com-rt.def tree.j ../tree.h ../tree.def \
  ../tree-check.h ../real.h info.h info-b.def info-k.def info-w.def \
  target.h lex.h type.h lab.h storag.h symbol.h symbol.def equiv.h \
  global.h name.h intrin.h intrin.def data.h expr.h implic.h src.h st.h \
  flags.j ../flags.h toplev.j ../toplev.h
$(gccobjdir)/f77/type.o:  \
 type.c proj.h config.j ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def system.j ../system.h \
  ../../../include/libiberty.h assert.j /usr/include/assert.h type.h \
  malloc.h
$(gccobjdir)/f77/version.o:  \
 version.c
$(gccobjdir)/f77/where.o:  \
 where.c proj.h config.j ../config.h ../auto-host.h ../gansidecl.h \
  ../../../include/ansidecl.h ../config/i386/xm-linux.h \
  ../config/arm/riscos-aof.h ../config/arm/aof.h ../config/arm/arm.h \
  ../hwint.h ../machmode.h ../machmode.def system.j ../system.h \
  ../../../include/libiberty.h assert.j /usr/include/assert.h where.h \
  glimits.j ../glimits.h top.h malloc.h lex.h
