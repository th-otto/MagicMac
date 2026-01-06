top_srcdir = ../..
include $(top_srcdir)/Makefile.common

INCLUDES = -I$(top_srcdir)/pc/include
CFLAGS = -A- -P- -L64 $(INCLUDES) $(DEFINES)
LDFLAGS = -S=16000

OBJS = \
	$(STARTUP) \
	chgres.o \
	popup.o \
	inf.o \
	$(empty)

LIBS = $(LIBDIR)/pcstdlib.lib $(LIBDIR)/pctoslib.lib $(LIBDIR)/pcgemlib.lib

PROGRAMS = chgres.prg

all:: $(PROGRAMS)

chgres.prg: $(OBJS)
	$(LD) -O=$@ $(LDFLAGS) $(OBJS) $(LIBS)

$(OBJS): $(MAKEFILE_LIST)

clean::
	$(RM) *.o *.pdb $(PROGRAMS)
