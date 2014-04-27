bin_PROGRAMS=asasm

SVN_ROOT := $(shell svn info ${srcdir} | grep "^Repository Root: " | sed -e "s/^Repository Root: //")
SVN_BRANCH := $(shell svn info ${srcdir} | grep "^URL: " | sed -e "s/^URL: //")
SVN_REV := r$(shell svnversion -n ${srcdir}) at $(subst $(SVN_ROOT),,$(SVN_BRANCH))

# We want to define the AsAsm version number as PVtbbbb with
# P = major version, V = minor version, t = patch release, bbbb = build number
# P, V and t are derived from the PACKAGE_VERSION in config.h (which is derived
# from AC_INIT in configure.ac) and bbbb is our SVN revision number.
ASASM_VERSION := $(shell echo -n "@VERSION@" | sed -e "s/\([0-9]\)\.\([0-9][0-9]\)/\1\2/")$(shell echo -n "0000"`svnversion -n ${srcdir}` | sed -e "s/[0-9]*://" -e "s/\([0-9]*\).*/\1/" | egrep -o "....$$")

# Add -DDEBUG if you want to enable the debug routines.
asasm_CFLAGS = -std=c99 \
	-D_LARGEFILE_SOURCE -D__STDC_FORMAT_MACROS \
	-fstrict-aliasing -Wstrict-aliasing \
	-W -Wall -Wbad-function-cast -Wcast-align \
	-Wchar-subscripts -Winline \
	-Wmissing-prototypes -Wnested-externs -Wpointer-arith \
	-Wredundant-decls -Wshadow -Wstrict-prototypes -Wwrite-strings \
	-Wno-switch \
	-DGCCSDK_REVISION="\"$(SVN_REV)\"" \
	-DASASM_VERSION=$(ASASM_VERSION) \
	-I${top_srcdir}/elftoolchain/common \
	-I${top_srcdir}/elftoolchain/libelftc \
	-I${top_srcdir}/elftoolchain/libelf \
	-I${top_srcdir}/elftoolchain/libdwarf
# -static because we don't install the elftoolchain libraries.
asasm_LDFLAGS = -static -lm
asasm_LDADD = ../elftoolchain/libelftc/libelftc.la \
	../elftoolchain/libelf/libelf.la \
	../elftoolchain/libdwarf/libdwarf.la

# re2c generates expr-scanner.c from expr-scanner.re
# lemon generates expr-parser-part2.c and expr-parser-part2.h from expr-parser-part2.y
asasm_SOURCES=area.c asm.c code.c common.c debug_dwarf.c decode.c depend.c \
	directive_data.c directive_file.c directive_misc.c \
	directive_storagemap.c directive_symbol.c error.c \
	eval.c expr.c expr-parser.c \
	filename.c filestack.c fix.c frame.c get.c help_cop.c \
	help_cpu.c include.c input.c it.c lex.c lit.c \
	local.c macros.c main.c m_coprocessor.c m_cpu.c m_cpuctrl.c \
	m_cpumem.c m_fpe.c opt.c option.c os.c output.c phase.c \
	predef_reg.c put.c reloc.c state.c \
	symbol.c targetcpu.c \
	value.c variables.c whileif.c
nodist_asasm_SOURCES=expr-scanner.c expr-parser-part2.h

# We don't mention expr-parser-part2.c in BUILT_SOURCES as otherwise it will be
# built on its own.  We're building it as part of expr-parser.c.
BUILT_SOURCES = expr-scanner.c expr-parser-part2.h
# FIXME: EXTRA_DIST

AM_V_LEMON = $(am__v_LEMON_@AM_V@)
am__v_LEMON_ = $(am__v_LEMON_@AM_DEFAULT_V@)
am__v_LEMON_0 = @echo "  LEMON   " $@;

AM_V_RE2C = $(am__v_RE2C_@AM_V@)
am__v_RE2C_ = $(am__v_RE2C_@AM_DEFAULT_V@)
am__v_RE2C_0 = @echo "  RE2C    " $@;

expr-scanner.c: $(srcdir)/expr-scanner.re
	$(AM_V_RE2C)@RE2C@ -o $(srcdir)/expr-scanner.c $(srcdir)/expr-scanner.re || \
		(rm -f $(srcdir)/expr-scanner.c ; false)

# expr-parser-part2.h's date doesn't seem to get updated after using lemon on an
# updated expr-parser-part2.y, hence we need to touch expr-parser-part2.h.
expr-parser-part2.h: $(srcdir)/lempar.c.template $(srcdir)/expr-parser-part2.y
	$(AM_V_LEMON)@LEMON@ -q T=$(srcdir)/lempar.c.template $(srcdir)/expr-parser-part2.y && touch $(srcdir)/expr-parser-part2.h || \
		(rm -f $(srcdir)/expr-parser-part2.{c,h,out} ; false)
