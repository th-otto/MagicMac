#
# Makefile for MagicMac kernels,
# using crosstos binaries
#
top_srcdir = ../..
include $(top_srcdir)/Makefile.common

INCLUDES = -I$(top_srcdir)/inc_c -I../inc -I$(top_srcdir)/pc/include
ASMINCLUDES = -I../inc
DEFINES = -DCOUNTRY=$(COUNTRY) -DHADES=0 -DRAVEN=0 -DMAGICPC=0
CFLAGS = -A- -P -G -L64 $(INCLUDES) $(DEFINES)
LDFLAGS = -S=0

MXVDI_OBJS = \
	../vdi/mxvdiknl.o \
	../vdi/setup.o \
	../vdi/drivers.o \
	../vdi/filediv.o \
	../vdi/init_res.o \
	$(empty)

COMMON_OBJS = \
	../allg/read_inf.o \
	../vdi/math.o \
	../allg/std.o \
	../dos/magidos.o \
	../dos/malloc.o \
	../dos/xfs_vdos.o \
	../dos/vfat_s.o \
	../dos/vfat.o \
	../dos/dfs_u.o \
	../dos/dev_bios.o \
	../dos/dev_pipe.o \
	../dos/dev_mem.o \
	../dos/dfs_fat.o \
	../vdi/string.o \
	$(MXVDI_OBJS) \
	../vdi/tos.o \
	../aes/aesmain.o \
	../aes/aesevt.o \
	../aes/aesfrm.o \
	../aes/aesobj.o \
	../aes/aeswin.o \
	../aes/aesmen.o \
	../aes/aesgraf.o \
	../aes/aesrsc.o \
	../aes/farbic.o \
	../aes/wdialog/wdialog.o \
	../aes/wdialog/listbox.o \
	../aes/wdialog/fnt_menu.o \
	../aes/wdialog/shelsort.o \
	../aes/wdialog/wdintrfc.o \
	../aes/fsel/fsel.o \
	../aes/xmen_mgr/mtsmn.o \
	../ende.o \
	$(empty)

MAGICLIN_OBJS = \
	../bios/magiclin/macxbios.o \
	../bios/magiclin/hostxfs.o \
	$(COMMON_OBJS) \
	$(empty)
	
MAGCMACX_OBJS = \
	../bios/magcmacx/macxbios.o \
	../bios/magcmacx/macxfs.o \
	$(COMMON_OBJS) \
	$(empty)

MAGICMAC_OBJS = \
	../bios/magicmac/mac_bios.o \
	../bios/magicmac/macxfs.o \
	$(COMMON_OBJS) \
	$(empty)

ATARI_OBJS = \
	../bios/atari/magibios.o \
	../bios/atari/xfs95/xfs95ini.o \
	../bios/atari/modules/ide.o \
	../bios/magicmac/macxfs.o \
	$(COMMON_OBJS) \
	$(empty)
	
HADES_OBJS = $(ATARI_OBJS)
	
RAVEN_OBJS = $(ATARI_OBJS)
	
MILAN_OBJS = \
	../bios/milan/milnbios.o \
	../bios/milan/milan.o \
	$(filter-out $(MXVDI_OBJS), $(COMMON_OBJS)) \
	$(empty)
	
PROGRAMS = magcmacx.os magiclin.os magic.ram mag_mac.ram mmilan.ram mhades.ram mraven.ram

all:: $(PROGRAMS)

../dos/vfat.o: ../dos/vfat.c
	$(CC) -O=$@ $(CFLAGS) -G- $<
../aes/farbic.o: ../aes/farbic.c
	$(CC) -O=$@ $(CFLAGS) -G- $<

magcmacx.os: $(MAGCMACX_OBJS)
	$(LD) -O=$@ $(LDFLAGS) $(MAGCMACX_OBJS)

magiclin.os: $(MAGICLIN_OBJS)
	$(LD) -O=$@ $(LDFLAGS) $(MAGICLIN_OBJS)

magic.ram: $(ATARI_OBJS)
	$(LD) -O=$@ $(LDFLAGS) $(ATARI_OBJS)

mag_mac.ram: $(MAGICMAC_OBJS)
	$(LD) -O=$@ $(LDFLAGS) $(MAGICMAC_OBJS)

mmilan.ram: $(MILAN_OBJS)
	$(LD) -O=$@ $(LDFLAGS) $(MILAN_OBJS)

mhades.ram: $(HADES_OBJS)
	$(LD) -O=$@ $(LDFLAGS) $(HADES_OBJS)

mraven.ram: $(RAVEN_OBJS)
	$(LD) -O=$@ $(LDFLAGS) $(RAVEN_OBJS)

clean::
	$(RM) *.o *.pdb ../*/*.o ../*/*/*.o $(PROGRAMS)
