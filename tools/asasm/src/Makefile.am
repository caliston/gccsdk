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
asasm_SOURCES=area.c asm.c code.c common.c debug_dwarf.c decode.c depend.c \
	directive_data.c directive_file.c directive_misc.c \
	directive_storagemap.c directive_symbol.c error.c \
	eval.c expr.c filename.c filestack.c fix.c frame.c get.c help_cop.c \
	help_cpu.c include.c input.c it.c lex.c lit.c \
	local.c macros.c main.c m_coprocessor.c m_cpu.c m_cpuctrl.c \
	m_cpumem.c m_fpe.c opt.c option.c os.c output.c phase.c \
	predef_reg.c put.c reloc.c state.c \
	symbol.c targetcpu.c \
	value.c variables.c whileif.c
