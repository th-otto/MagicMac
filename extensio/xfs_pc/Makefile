BIN = $(HOME)/atari/tos_src/bin/linux/

CPPFLAGS = -I../../kernel/inc
CFLAGS = -f

ASFLAGS = -u

all: xfs_pc.ldr

.c.o:
	$(BIN)cp68 -P $(CPPFLAGS) $< $*.i
	$(BIN)c068 $*.i $*.1 $*.2 $*.3 $(CFLAGS)
	$(BIN)c168 $*.1 $*.2 $*.s
	$(BIN)as68 $(ASFLAGS) $*.s
	@$(RM) $*.i $*.1 $*.2 $*.3 $*.s

.s.o:
	$(BIN)cp68 -P $(CPPFLAGS) $< $*.i
	$(BIN)as68 $(ASFLAGS) $*.i
	@$(RM) $*.i

OBJS = xfs1alc.o xfs2.o vars.o cio2con.o tos.o \
	fpadd.o fpcmp.o fpdiv.o ltof.o ftol.o \
	fpmul.o fpneg.o fpsub.o ffpcmp.o \
	ffpabs.o ffpadd.o ffpdiv.o ffpmul2.o ffpcpyrt.o \
	lmul.o ldiv.o lrem.o

COMMA=,
SPACE := $(subst ,, )

xfs_pc.ldr: $(OBJS) Makefile
	$(BIN)link68 xfs_pc.tmp=$(subst $(SPACE),$(COMMA),$(OBJS))
	$(BIN)relmod xfs_pc.tmp $@
	@$(RM) xfs_pc.tmp

xfs1alc.o: xfs1alc.s

tos.o: tos.s

xfs2.o: xfs2.c

cio2con.o: cio2con.c

ltof.o: ltof.c

cio2.o: cio2.s

ldiv.o: ldiv.s

lrem.o: lrem.s


clean::
	$(RM) *.o xfs_pc.ldr
