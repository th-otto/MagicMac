#!/bin/sh

LANGUAGES="de fr en"

set -e

for lang in $LANGUAGES; do
	mkdir -p "$BUILDROOT/$lang/AUTO/ACCS/CPX"
	mkdir -p "$BUILDROOT/$lang/AUTO/ACCS/CPZ"
	mkdir -p "$BUILDROOT/$lang/GEMSYS/HOME"
	mkdir -p "$BUILDROOT/$lang/GEMSYS/MAGIC/START"
	mkdir -p "$BUILDROOT/$lang/GEMSYS/MAGIC/STOP"
	mkdir -p "$BUILDROOT/$lang/GEMSYS/MAGIC/UTILITY"
	mkdir -p "$BUILDROOT/$lang/GEMSYS/MAGIC/XTENSION"
	mkdir -p "$BUILDROOT/$lang/GEMSYS/MAGIC/XTENSION/HIDE"
	mkdir -p "$BUILDROOT/$lang/GEMSYS/MAGIC/XTENSION/HIDE2"
	mkdir -p "$BUILDROOT/$lang/GEMSYS/MAGIC/XTENSION/THEMES"
	mkdir -p "$BUILDROOT/$lang/GEMSYS/GEMSCRAP"
	mkdir -p "$BUILDROOT/$lang/GEMSYS/GEMDESK"
	mkdir -p "$BUILDROOT/$lang/GEMSYS/GEMDESK/PAT"
	mkdir -p "$BUILDROOT/$lang/GEMSYS/GEMDESK/RSC"
	mkdir -p "$BUILDROOT/$lang/BIN"
	mkdir -p "$BUILDROOT/$lang/EXTRAS"
	mkdir -p "$BUILDROOT/$lang/EXTRAS/BIN"
	mkdir -p "$BUILDROOT/$lang/EXTRAS/FLOCK_OK"
	mkdir -p "$BUILDROOT/$lang/EXTRAS/CLOCK"
	mkdir -p "$BUILDROOT/$lang/EXTRAS/AES_LUPE"
	mkdir -p "$BUILDROOT/$lang/EXTRAS/MAGICCFG"
	mkdir -p "$BUILDROOT/$lang/EXTRAS/APPLINE"
done


#
# German localizations
#
lang=de

mcopy -b "$SRCDIR/apps/applicat/applicat.inf" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/applicat/applicat.rsc" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/chgres/chgres.rsc" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/magxdesk.5/magxdesk.rsc" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/cmd/mcmd.tos" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/mgcopy/mgcopy.rsc" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/mgedit/mgedit.rsc" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/mgformat/mgformat.rsc" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/mgnotice.2/mgnotice.rsc" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/mgnotice.2/mgnotice.txt" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/mgsearch/mgsearch.rsc" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/mod_app/mod_app.txt" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/shutdown/$lang/shutdown.prg" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/vfatconf/vfatconf.rsc" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/vt52/$lang/vt52.rsc" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/magiccfg/rsc/$lang/magiccfg.rsc" "$BUILDROOT/$lang/EXTRAS/MAGICCFG/"
mcopy -b "$SRCDIR/apps/magiccfg/rsc/$lang/magiccfg.bgh" "$BUILDROOT/$lang/EXTRAS/MAGICCFG/"
cp "apps/magiccfg/doc/magiccfg_${lang}.txt" "$BUILDROOT/$lang/EXTRAS/MAGICCFG/magiccfg.txt"
cp "apps/magiccfg/doc/magiccfg_${lang}.hyp" "$BUILDROOT/$lang/EXTRAS/MAGICCFG/magiccfg.hyp"
mcopy -b "$SRCDIR/apps/appline/appline.rsc" "$BUILDROOT/$lang/EXTRAS/APPLINE/"
mcopy -b "$SRCDIR/doc/usage/magx_${lang}.inf" "$BUILDROOT/$lang/EXTRAS/magx.inf"

mcopy -b "$SRCDIR/extensio/pdlg_slb/$lang/pdlg.slb" "$BUILDROOT/$lang/GEMSYS/MAGIC/XTENSION/"

mcopy -b "$SRCDIR/auto/accs/$lang/cops.app" "$BUILDROOT/$lang/AUTO/ACCS/COPS.ACC"
mcopy -b "$SRCDIR/auto/accs/cpx/$lang/*.CPX" "$BUILDROOT/$lang/AUTO/ACCS/CPX/"

mcopy -b "$SRCDIR/kernel/build/$lang/magic.ram" "$BUILDROOT/$lang"
mcopy -b "$SRCDIR/kernel/build/$lang/mmilan.ram" "$BUILDROOT/$lang"
mcopy -b "$SRCDIR/kernel/build/$lang/mhades.ram" "$BUILDROOT/$lang"
mcopy -b "$SRCDIR/kernel/build/$lang/magcmacx.os" "$BUILDROOT/$lang"
mcopy -b "$SRCDIR/kernel/build/$lang/magic_pc.os" "$BUILDROOT/$lang"


#
# English localizations
#
lang=en

mcopy -b "$SRCDIR/apps/applicat/us/applicat.inf" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/applicat/us/applicat.rsc" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/chgres/$lang/chgres.rsc" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/magxdesk.5/us/magxdesk.rsc" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/cmd/mcmd.tos" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/mgcopy/us/mgcopy.rsc" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/mgedit/us/mgedit.rsc" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/mgformat/us/mgformat.rsc" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/mgnotice.2/us/mgnotice.rsc" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/mgnotice.2/us/mgnotice.txt" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/mgsearch/us/mgsearch.rsc" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/mod_app/$lang/mod_app.txt" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/shutdown/$lang/shutdown.prg" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/vfatconf/$lang/vfatconf.rsc" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/vt52/$lang/vt52.rsc" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/magiccfg/rsc/$lang/magiccfg.rsc" "$BUILDROOT/$lang/EXTRAS/MAGICCFG/"
mcopy -b "$SRCDIR/apps/magiccfg/rsc/$lang/magiccfg.bgh" "$BUILDROOT/$lang/EXTRAS/MAGICCFG/"
cp "apps/magiccfg/doc/magiccfg_${lang}.txt" "$BUILDROOT/$lang/EXTRAS/MAGICCFG/magiccfg.txt"
cp "apps/magiccfg/doc/magiccfg_${lang}.hyp" "$BUILDROOT/$lang/EXTRAS/MAGICCFG/magiccfg.hyp"
mcopy -b "$SRCDIR/apps/appline/$lang/appline.rsc" "$BUILDROOT/$lang/EXTRAS/APPLINE/"
mcopy -b "$SRCDIR/doc/usage/magx_${lang}.inf" "$BUILDROOT/$lang/EXTRAS/magx.inf"

mcopy -b "$SRCDIR/extensio/pdlg_slb/$lang/pdlg.slb" "$BUILDROOT/$lang/GEMSYS/MAGIC/XTENSION/"

mcopy -b "$SRCDIR/auto/accs/$lang/cops.app" "$BUILDROOT/$lang/AUTO/ACCS/COPS.ACC"
mcopy -b "$SRCDIR/auto/accs/cpx/$lang/*.CPX" "$BUILDROOT/$lang/AUTO/ACCS/CPX/"

mcopy -b "$SRCDIR/kernel/build/$lang/magic.ram" "$BUILDROOT/$lang"
mcopy -b "$SRCDIR/kernel/build/$lang/mmilan.ram" "$BUILDROOT/$lang"
mcopy -b "$SRCDIR/kernel/build/$lang/mhades.ram" "$BUILDROOT/$lang"
mcopy -b "$SRCDIR/kernel/build/$lang/magcmacx.os" "$BUILDROOT/$lang"
mcopy -b "$SRCDIR/kernel/build/$lang/magic_pc.os" "$BUILDROOT/$lang"


#
# French localizations
#
lang=fr

mcopy -b "$SRCDIR/apps/applicat/$lang/applicat.inf" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/applicat/$lang/applicat.rsc" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/chgres/$lang/chgres.rsc" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/magxdesk.5/$lang/magxdesk.rsc" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/cmd/mcmd.tos" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/mgcopy/$lang/mgcopy.rsc" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/mgedit/$lang/mgedit.rsc" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/mgformat/$lang/mgformat.rsc" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/mgnotice.2/$lang/mgnotice.rsc" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/mgnotice.2/$lang/mgnotice.txt" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/mgsearch/$lang/mgsearch.rsc" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
# TODO: french translation
mcopy -b "$SRCDIR/apps/mod_app/en/mod_app.txt" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/shutdown/$lang/shutdown.prg" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/vfatconf/$lang/vfatconf.rsc" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/vt52/$lang/vt52.rsc" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/magiccfg/rsc/$lang/magiccfg.rsc" "$BUILDROOT/$lang/EXTRAS/MAGICCFG/"
mcopy -b "$SRCDIR/apps/magiccfg/rsc/$lang/magiccfg.bgh" "$BUILDROOT/$lang/EXTRAS/MAGICCFG/"
# TODO: french translation
cp "apps/magiccfg/doc/magiccfg_en.txt" "$BUILDROOT/$lang/EXTRAS/MAGICCFG/magiccfg.txt"
cp "apps/magiccfg/doc/magiccfg_en.hyp" "$BUILDROOT/$lang/EXTRAS/MAGICCFG/magiccfg.hyp"
mcopy -b "$SRCDIR/apps/appline/$lang/appline.rsc" "$BUILDROOT/$lang/EXTRAS/APPLINE/"
mcopy -b "$SRCDIR/doc/usage/magx_${lang}.inf" "$BUILDROOT/$lang/EXTRAS/magx.inf"

mcopy -b "$SRCDIR/extensio/pdlg_slb/$lang/pdlg.slb" "$BUILDROOT/$lang/GEMSYS/MAGIC/XTENSION/"

mcopy -b "$SRCDIR/auto/accs/$lang/cops.app" "$BUILDROOT/$lang/AUTO/ACCS/COPS.ACC"
mcopy -b "$SRCDIR/auto/accs/cpx/$lang/*.CPX" "$BUILDROOT/$lang/AUTO/ACCS/CPX/"

mcopy -b "$SRCDIR/kernel/build/$lang/magic.ram" "$BUILDROOT/$lang"
mcopy -b "$SRCDIR/kernel/build/$lang/mmilan.ram" "$BUILDROOT/$lang"
mcopy -b "$SRCDIR/kernel/build/$lang/mhades.ram" "$BUILDROOT/$lang"
mcopy -b "$SRCDIR/kernel/build/$lang/magcmacx.os" "$BUILDROOT/$lang"
mcopy -b "$SRCDIR/kernel/build/$lang/magic_pc.os" "$BUILDROOT/$lang"

#
# Common files
#
for lang in $LANGUAGES; do
	mcopy -b "$SRCDIR/auto/accs/cops.inf" "$BUILDROOT/$lang/GEMSYS/HOME/"
	mcopy -b "$SRCDIR/auto/accs/*.PAL" "$BUILDROOT/$lang/AUTO/ACCS/"
	mcopy -b "$SRCDIR/auto/accs/cpx/*.CPX" "$BUILDROOT/$lang/AUTO/ACCS/CPX/"
	mcopy -b "$SRCDIR/auto/accs/cpz/*.CPZ" "$BUILDROOT/$lang/AUTO/ACCS/CPZ/"
	
	mtype "$SRCDIR/apps/cpx/magxconf.hdr" > "$BUILDROOT/$lang/AUTO/ACCS/CPX/MAGXCONF.CPX"
	mtype "$SRCDIR/apps/cpx/magxconf.cp" >> "$BUILDROOT/$lang/AUTO/ACCS/CPX/MAGXCONF.CPX"
	mtype "$SRCDIR/apps/cpx/tslice.hdr" > "$BUILDROOT/$lang/AUTO/ACCS/CPX/TSLICE.CPX"
	mtype "$SRCDIR/apps/cpx/tslice.cp" >> "$BUILDROOT/$lang/AUTO/ACCS/CPX/TSLICE.CPX"

	mcopy -b "$SRCDIR/tools/crashdmp/crashdmp.tos" "$BUILDROOT/$lang/BIN/"
	mcopy -b "$SRCDIR/tools/fc/fc.ttp" "$BUILDROOT/$lang/BIN/"
	mcopy -b "$SRCDIR/apps/limitmem/limitmem.ttp" "$BUILDROOT/$lang/BIN/"
	mcopy -b "$SRCDIR/tools/memexamn/memexamn.ttp" "$BUILDROOT/$lang/BIN/"

	mcopy -b "$SRCDIR/apps/applicat/applicat.app" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	# mcopy -b "$SRCDIR/apps/applicat/rsc/*.RSC" "$BUILDROOT/$lang/GEMSYS/GEMDESK/RSC/"
	
	mcopy -b "$SRCDIR/apps/chgres/chgres.prg" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy -b "$SRCDIR/apps/magxdesk.5/magxdesk.app" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy -b "$SRCDIR/apps/magxdesk.5/rsc/*" "$BUILDROOT/$lang/GEMSYS/GEMDESK/RSC/"
	
	mcopy -bs "$SRCDIR/apps/magxdesk.5/pat/*"  "$BUILDROOT/$lang/GEMSYS/GEMDESK/PAT/"
	mcopy -b "$SRCDIR/apps/mgclock/mgclock.prg" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy -b "$SRCDIR/apps/mgcopy/mgcopy.app" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy -b "$SRCDIR/apps/mgedit/mgedit.app" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy -b "$SRCDIR/apps/mgformat/mgformat.prg" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy -b "$SRCDIR/apps/mgnotice.2/mgnotice.app" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy -b "$SRCDIR/apps/mgsearch/mgsearch.app" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy -b "$SRCDIR/apps/mgview/mgview.app" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy -b "$SRCDIR/apps/mgxclock/mgxclock.prg" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy -b "$SRCDIR/apps/mod_app/mod_app.ttp" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy -b "$SRCDIR/apps/showfile/showfile.ttp" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy -b "$SRCDIR/tools/showfree/showfree.tos" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy -b "$SRCDIR/apps/shutdown/shutdown.inf" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy -b "$SRCDIR/apps/vfatconf/vfatconf.prg" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy -b "$SRCDIR/apps/vt52/vt52.prg" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy -b "$SRCDIR/apps/magiccfg/magiccfg.app" "$BUILDROOT/$lang/EXTRAS/MAGICCFG/"
	mcopy -b "$SRCDIR/apps/magiccfg/history.txt" "$BUILDROOT/$lang/EXTRAS/MAGICCFG/"
	mcopy -b "$SRCDIR/apps/appline/appline.app" "$BUILDROOT/$lang/EXTRAS/APPLINE/"
	mcopy -b "$SRCDIR/apps/wbdaemon/wbdaemon.prg" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy -b "$SRCDIR/apps/mmxdaemn/mmxdaemn.prg" "$BUILDROOT/$lang/GEMSYS/MAGIC/START/MMXDAEMN.PRX"
	mcopy -b "$SRCDIR/tools/dev_ser/dev_ser.dev" "$BUILDROOT/$lang/GEMSYS/MAGIC/XTENSION/"
	mcopy -b "$SRCDIR/extensio/ramdisk/ramdisk.xfs" "$BUILDROOT/$lang/GEMSYS/MAGIC/XTENSION/RAMDISK.XFX"
	mcopy -b "$SRCDIR/extensio/cd-mxfs/spinmagc.xfs" "$BUILDROOT/$lang/GEMSYS/MAGIC/XTENSION/SPINMAGC.XFX"
	mcopy -b "$SRCDIR/extensio/edit_slb/editobjc.slb" "$BUILDROOT/$lang/GEMSYS/MAGIC/XTENSION/"
	mcopy -b "$SRCDIR/extensio/load_img/load_img.slb" "$BUILDROOT/$lang/GEMSYS/MAGIC/XTENSION/"
	mcopy -b "$SRCDIR/kernel/winframe/winframe.slb" "$BUILDROOT/$lang/GEMSYS/MAGIC/XTENSION/"
	mcopy -b "$SRCDIR/kernel/winframe/winframe.rsc" "$BUILDROOT/$lang/GEMSYS/MAGIC/XTENSION/"
	mcopy -b "$SRCDIR/kernel/winframe/winframe.inf" "$BUILDROOT/$lang/GEMSYS/MAGIC/XTENSION/"
	mcopy -bs "$SRCDIR/kernel/winframe/themes/*" "$BUILDROOT/$lang/GEMSYS/MAGIC/XTENSION/THEMES/"
	mcopy -b "$SRCDIR/tools/addmem/addmem.prg" "$BUILDROOT/$lang/EXTRAS/"
	mcopy -b "$SRCDIR/tools/misc_tst/adr.prg" "$BUILDROOT/$lang/EXTRAS/BIN/"
	mcopy -b "$SRCDIR/tools/misc_tst/il0008.prg" "$BUILDROOT/$lang/EXTRAS/BIN/"
	mcopy -b "$SRCDIR/tools/misc_tst/il4afc.prg" "$BUILDROOT/$lang/EXTRAS/BIN/"
	mcopy -b "$SRCDIR/tools/misc_tst/ilf000.prg" "$BUILDROOT/$lang/EXTRAS/BIN/"
	mcopy -b "$SRCDIR/tools/misc_tst/priv_rte.prg" "$BUILDROOT/$lang/EXTRAS/BIN/"
	mcopy -b "$SRCDIR/tools/misc_tst/priv_sr.prg" "$BUILDROOT/$lang/EXTRAS/BIN/"
	mcopy -b "$SRCDIR/tools/misc_tst/trap7.prg" "$BUILDROOT/$lang/EXTRAS/BIN/"
	mcopy -b "$SRCDIR/extensio/romdrvr/romdrvr.prg" "$BUILDROOT/$lang/EXTRAS/"
	mcopy -b "$SRCDIR/kernel/bios/atari/boot/magxboot.prg" "$BUILDROOT/$lang/EXTRAS/"
	mcopy -b "$SRCDIR/kernel/bios/atari/boot/magxbo32.prg" "$BUILDROOT/$lang/EXTRAS/"
	mcopy -b "$SRCDIR/kernel/bios/atari/boot/ct60new.tos" "$BUILDROOT/$lang/EXTRAS/ct60boot.prg"
	mcopy -b "$SRCDIR/kernel/bios/atari/boot/magic_p.tos" "$BUILDROOT/$lang/EXTRAS/"
	mcopy -b "$SRCDIR/kernel/bios/atari/boot/ct60.txt" "$BUILDROOT/$lang/EXTRAS/"
	mcopy -b "$SRCDIR/kernel/bios/atari/boot/magxmila.prg" "$BUILDROOT/$lang/EXTRAS/"
	mcopy -b "$SRCDIR/kernel/bios/atari/boot/magxboot.prg" "$BUILDROOT/$lang/AUTO/"
	mcopy -b "$SRCDIR/tools/hardcopy/hardcopy.prg" "$BUILDROOT/$lang/EXTRAS/"
	mcopy -b "$SRCDIR/tools/flock_ok/flock_ok.prg" "$BUILDROOT/$lang/EXTRAS/FLOCK_OK/"
	mcopy -b "$SRCDIR/tools/flock_ok/flock_ok.eng" "$BUILDROOT/$lang/EXTRAS/FLOCK_OK/"
	mcopy -b "$SRCDIR/tools/flock_ok/flock_ok.txt" "$BUILDROOT/$lang/EXTRAS/FLOCK_OK/"
	mcopy -b "$SRCDIR/tools/aes_lupe/aes_lupe.app" "$BUILDROOT/$lang/EXTRAS/AES_LUPE/"
	mcopy -b "$SRCDIR/tools/aes_lupe/aes_lupe.img" "$BUILDROOT/$lang/EXTRAS/AES_LUPE/"
	mcopy -b "$SRCDIR/tools/aes_lupe/aes_lupe.txt" "$BUILDROOT/$lang/EXTRAS/AES_LUPE/"
	mcopy -b "$SRCDIR/tools/clock/clock.app" "$BUILDROOT/$lang/EXTRAS/CLOCK/"
	mcopy -b "$SRCDIR/tools/clock/clock.gen" "$BUILDROOT/$lang/EXTRAS/CLOCK/"
	mcopy -b "$SRCDIR/tools/clock/clock.inf" "$BUILDROOT/$lang/EXTRAS/CLOCK/"
	mcopy -b "$SRCDIR/tools/clock/clock.man" "$BUILDROOT/$lang/EXTRAS/CLOCK/"
	mcopy -b "$SRCDIR/tools/clock/clock.mup" "$BUILDROOT/$lang/EXTRAS/CLOCK/"
	mcopy -b "$SRCDIR/tools/clock/clockcol.cpx" "$BUILDROOT/$lang/EXTRAS/CLOCK/"
	mcopy -b "$SRCDIR/tools/clock/maus.ruf" "$BUILDROOT/$lang/EXTRAS/CLOCK/"
	mcopy -b "$SRCDIR/tools/clock/readme.cat" "$BUILDROOT/$lang/EXTRAS/CLOCK/"
	# mcopy -b "$SRCDIR/apps/instmagc/magx.inf" "$BUILDROOT/$lang/"

	mcopy -b "$SRCDIR/kernel/vdi/drivers/*.SYS" "$BUILDROOT/$lang/GEMSYS/"
	mcopy -b "$SRCDIR/kernel/vdi/drivers/*.OSD" "$BUILDROOT/$lang/GEMSYS/"
	
	# strip ROM header for magic_pc.os kernels
	if test -f "$BUILDROOT/$lang/magic_pc.os"; then
		if test `dd if="$BUILDROOT/$lang/magic_pc.os" bs=1 count=2` = '`$'; then  # magic 0x6024
			dd if="$BUILDROOT/$lang/magic_pc.os" of="$BUILDROOT/$lang/magic_pc.tmp" bs=1 skip=38
			mv "$BUILDROOT/$lang/magic_pc.tmp" "$BUILDROOT/$lang/magic_pc.os"
		fi
	fi
done

set +e
