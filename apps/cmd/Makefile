top_srcdir = ../..
include $(top_srcdir)/Makefile.common

INCLUDES = -I$(top_srcdir)/pc/include
ASMINCLUDES = -I$(top_srcdir)/inc_as
DEFINES = -DCOUNTRY=$(COUNTRY)
CFLAGS = -A- -P -G -L64 $(INCLUDES) $(DEFINES)
LDFLAGS =
LIBS =

PROGRAMS = mcmd.tos kcmd.tos

all:: $(PROGRAMS)

mcmd.tos: mcmd.o
	$(LD) -O=$@ $(LDFLAGS) mcmd.o

kcmd.tos: kcmd.o
	$(LD) -O=$@ $(LDFLAGS) kcmd.o

clean::
	$(RM) *.o *.pdb $(PROGRAMS)
