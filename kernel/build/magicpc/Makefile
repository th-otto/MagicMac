CROSS = m68k-atari-mint-
AS = $(CROSS)as
LD = $(CROSS)ld

all: magic_pc.os

magic_pc.os: magic_pc.o Makefile
	$(LD) --oformat binary -Ttext 0xe00000 -o $@ $<

magic_pc.o: magic_pc.s
	$(AS) --mri -o $@ $<

clean:
	rm -f *.o magic_pc.os
