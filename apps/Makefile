top_srcdir = ..
include $(top_srcdir)/Makefile.common

SUBDIRS = \
	applicat \
	appline \
	chgres \
	cmd \
	cpx \
	instmagc \
	limitmem \
	magiccfg \
	magxdesk.5 \
	matrix \
	mgclock \
	mgcopy \
	mgedit \
	mgformat \
	mgnotice.2 \
	mgsearch \
	mgview \
	mgxclock \
	mmxdaemn \
	mod_app \
	print \
	showfile \
	shutdown \
	vfatconf \
	vt52 \
	wbdaemon \
	$(empty)

all clean::
	@for i in $(SUBDIRS); do $(MAKE) -C $$i $@ || exit 1; done
