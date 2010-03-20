# Testsuite automake-style infrastructure

AUTOMAKE_OPTIONS = no-dependencies
AM_CPPFLAGS = -isystem $(top_srcdir)/include -I $(top_srcdir)/test -D_GNU_SOURCE=1 -std=c99
LDADD = -L$(top_builddir)

check_PROGRAMS = test3-fpe test2-seg test1-swi link 

TESTS = $(check_PROGRAMS)
