top_srcdir = ../..
include $(top_srcdir)/Makefile.common

INCLUDES = -I$(top_srcdir)/inc_c -I$(top_srcdir)/lib/mylibs -I$(top_srcdir)/pc/include
DEFINES = -DCOUNTRY=$(COUNTRY)
CFLAGS = -A- -P -G -L64 $(INCLUDES) $(DEFINES)
LDFLAGS = -S=8192

OBJS = \
	$(STARTUP) \
	applicat.o \
	iconsel.o \
	ica_dial.o \
	anw_dial.o \
	typ_dial.o \
	icp_dial.o \
	pth_dial.o \
	spc_dial.o \
	inf.o \
	windows.o \
	$(top_srcdir)/lib/mylibs/gemut_mt.o \
	$(empty)

LIBS = $(LIBDIR)/pcstdlib.lib $(LIBDIR)/pctoslib.lib $(LIBDIR)/pcgemlib.lib

PROGRAMS = applicat.app

all:: $(PROGRAMS)

applicat.app: $(OBJS)
	$(LD) -O=$@ $(LDFLAGS) $(OBJS) $(LIBS)

clean::
	$(RM) *.o *.pdb $(PROGRAMS)
