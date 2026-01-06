top_srcdir = ../..
include $(top_srcdir)/Makefile.common

INCLUDES = -I$(top_srcdir)/inc_c -I$(top_srcdir)/lib/mylibs -I$(top_srcdir)/pc/include
DEFINES = -DCOUNTRY=$(COUNTRY)
CFLAGS = -A- -P -G -L64 $(INCLUDES) $(DEFINES)
LDFLAGS = -S=8192

LIBS = $(LIBDIR)/pcstdlib.lib $(LIBDIR)/pctoslib.lib $(LIBDIR)/pcgemlib.lib

PROGRAMS = 

all:: $(PROGRAMS)

clean::
	$(RM) *.o *.pdb $(PROGRAMS)
