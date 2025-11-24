top_srcdir = ../..
include $(top_srcdir)/Makefile.common

INCLUDES = -I$(top_srcdir)/pc/include
DEFINES = -DCOUNTRY=$(COUNTRY)
CFLAGS = -A- -P- -L64 $(INCLUDES) $(DEFINES)
LDFLAGS = -S=4096

OBJS = \
	startup.o \
	appline.o \
	$(empty)

LIBS = $(LIBDIR)/pcstdlib.lib $(LIBDIR)/pctoslib.lib $(LIBDIR)/pcgemlib.lib

PROGRAMS = appline.app

all:: $(PROGRAMS)

appline.app: $(OBJS)
	$(LD) -O=$@ $(LDFLAGS) $(OBJS) $(LIBS)

clean::
	$(RM) *.o *.pdb $(PROGRAMS)
