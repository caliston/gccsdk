# Testsuite automake-style infrastructure

AUTOMAKE_OPTIONS = no-dependencies
AM_CPPFLAGS = -isystem $(top_srcdir)/include -I $(top_srcdir)/test -D_GNU_SOURCE=1 -std=c99
LDADD = -L$(top_builddir)

check_PROGRAMS = bug-strspn1 tst-strlen bug-strpbrk1 testcopy tst-strtok \
	bug-strncat1 tst-bswap strlen test-memchr tester 

TESTS = $(check_PROGRAMS)
