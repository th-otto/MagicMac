CC = cc.ttp
AS = jas.ttp
LD = ld.ttp

CFLAGS = -O
ASFLAGS=

all: appline.app

.c.o:
	$(CC) $(CFLAGS) -c $<

.s.o:
	$(AS) $(ASFLAGS) $<


OBJS = startup.o appline.o \
	aes.o aes2.o itoa.o \
	strlen.o strcmp.o strncmp.o strcpy.o strcat.o \
	stksize.o

appline.app: $(OBJS)
	$(LD) -o $@ $(OBJS)

$(OBJS): applin.h appline.h

appline.o: appline.c
	$(CC) $(CFLAGS) -S $<
	head -n 200 appline.s >1.s
	tail -n +201 appline.s >2.s
	sed -e '/ext.l/d' 2.s >>1.s
	mv 1.s appline.s
	jas appline.s
	rm -f 2.s appline.s appline.tmp

clean::
	rm -f *.o appline.app
