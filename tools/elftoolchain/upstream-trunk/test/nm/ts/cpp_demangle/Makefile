# $Id: Makefile 2085 2011-10-27 05:06:47Z jkoshy $

TET_ROOT?=	/usr/tet
LIBDIR=		$(TET_ROOT)/lib/tet3
INCDIR=		$(TET_ROOT)/inc/tet3
CSTD=		-std=iso9899:1999
CFLAGS=		-I$(INCDIR)
TC=		cpp_demangle-tc

vector_str.o:	../../../vector_str.c
	$(CC) $(CSTD) -o vector_str.o -c ../../../vector_str.c

cpp_demangle.o: ../../../cpp_demangle.c vector_str.o
	$(CC) $(CSTD) -o cpp_demangle.o -c ../../../cpp_demangle.c

$(TC): $(TC).c cpp_demangle.o $(INCDIR)/tet_api.h
	$(CC) $(CFLAGS) $(CSTD) -o $(TC) $(TC).c vector_str.o \
		cpp_demangle.o $(LIBDIR)/tcm.o \
		$(LIBDIR)/libapi.a

clean:
	rm -f *.o $(TC)

lint:
	lint $(CFLAGS) $(TC) -ltcm
