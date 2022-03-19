CROSS=m68k-atari-mint-
CC = $(CROSS)gcc

CFLAGS = -O2 -Wall -Wstrict-prototypes -Wmissing-prototypes -W

OBJS = \
	chgres.o \
	popup.o \
	inf.o \
	$(empty)

all: chgres.prg

chgres.prg: $(OBJS) Makefile
	$(CC) $(CFLAGS) -o $@ $(OBJS) -lgem

clean:
	$(RM) *.o chgres.prg
