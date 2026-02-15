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
	mkdir -p "$BUILDROOT/$lang/GEMSYS/GEMDESK/HELP"
	mkdir -p "$BUILDROOT/$lang/BIN"
	mkdir -p "$BUILDROOT/$lang/CLIPBRD"
	mkdir -p "$BUILDROOT/$lang/EXTRAS"
	mkdir -p "$BUILDROOT/$lang/EXTRAS/BIN"
	mkdir -p "$BUILDROOT/$lang/EXTRAS/FLOCK_OK"
	mkdir -p "$BUILDROOT/$lang/EXTRAS/CLOCK"
	mkdir -p "$BUILDROOT/$lang/EXTRAS/AES_LUPE"
	mkdir -p "$BUILDROOT/$lang/EXTRAS/MAGICCFG"
	mkdir -p "$BUILDROOT/$lang/EXTRAS/APPLINE"
	mkdir -p "$BUILDROOT/$lang/EXTRAS/WDIALOG"


	mcopy "$SRCDIR/kernel/build/$lang/magic.ram" "$BUILDROOT/$lang"
	mcopy "$SRCDIR/kernel/build/$lang/mmilan.ram" "$BUILDROOT/$lang"
	mcopy "$SRCDIR/kernel/build/$lang/mhades.ram" "$BUILDROOT/$lang"
	mcopy "$SRCDIR/kernel/build/$lang/mraven.ram" "$BUILDROOT/$lang"
	mcopy "$SRCDIR/kernel/build/$lang/magcmacx.os" "$BUILDROOT/$lang"
	mcopy "$SRCDIR/kernel/build/$lang/magic_pc.os" "$BUILDROOT/$lang"
	mcopy "$SRCDIR/kernel/build/$lang/magiclin.os" "$BUILDROOT/$lang"

# localizations

	mcopy "$SRCDIR/apps/applicat/$lang/applicat.inf" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy "$SRCDIR/apps/applicat/$lang/applicat.rsc" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy "$SRCDIR/apps/chgres/$lang/chgres.rsc" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy "$SRCDIR/apps/magxdesk.5/$lang/magxdesk.rsc" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy "$SRCDIR/apps/mgcopy/$lang/mgcopy.rsc" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy "$SRCDIR/apps/mgedit/$lang/mgedit.rsc" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy "$SRCDIR/apps/mgnotice.2/$lang/mgnotice.rsc" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy "$SRCDIR/apps/mgnotice.2/$lang/mgnotice.txt" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy "$SRCDIR/apps/mgformat/$lang/mgformat.rsc" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy "$SRCDIR/apps/mgsearch/$lang/mgsearch.rsc" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	# TODO: french translation
	mcopy "$SRCDIR/apps/mod_app/$lang/mod_app.txt" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	# TODO: english & french translation
	mcopy "$SRCDIR/apps/cmd/help/de/*.HLP" "$BUILDROOT/$lang/GEMSYS/GEMDESK/HELP/"
	mcopy "$SRCDIR/apps/vfatconf/$lang/vfatconf.rsc" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy "$SRCDIR/apps/vt52/$lang/vt52.rsc" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy "$SRCDIR/apps/magiccfg/rsc/$lang/magiccfg.rsc" "$BUILDROOT/$lang/EXTRAS/MAGICCFG/"
	mcopy "$SRCDIR/apps/magiccfg/rsc/$lang/magiccfg.bgh" "$BUILDROOT/$lang/EXTRAS/MAGICCFG/"
	# TODO: french translation
	if test "$lang" = "fr"; then
		cp "apps/magiccfg/doc/magiccfg_en.txt" "$BUILDROOT/$lang/EXTRAS/MAGICCFG/magiccfg.txt"
		cp "apps/magiccfg/doc/magiccfg_en.hyp" "$BUILDROOT/$lang/EXTRAS/MAGICCFG/magiccfg.hyp"
	else
		cp "apps/magiccfg/doc/magiccfg_${lang}.txt" "$BUILDROOT/$lang/EXTRAS/MAGICCFG/magiccfg.txt"
		cp "apps/magiccfg/doc/magiccfg_${lang}.hyp" "$BUILDROOT/$lang/EXTRAS/MAGICCFG/magiccfg.hyp"
	fi
	mcopy "$SRCDIR/apps/appline/$lang/appline.rsc" "$BUILDROOT/$lang/EXTRAS/APPLINE/"
	mcopy "$SRCDIR/doc/usage/magx_${lang}.inf" "$BUILDROOT/$lang/EXTRAS/magx.inf"
	mcopy "$SRCDIR/kernel/aes/wdialog/$lang/wdialog.prg" "$BUILDROOT/$lang/EXTRAS/WDIALOG/wdialog.prg"
	mcopy "$SRCDIR/extensio/pdlg_slb/$lang/pdlg.slb" "$BUILDROOT/$lang/GEMSYS/MAGIC/XTENSION/"

	mcopy "$SRCDIR/auto/accs/cpx/$lang/*.CPX" "$BUILDROOT/$lang/AUTO/ACCS/CPX/"
done


#
# Common files
#
for lang in $LANGUAGES; do
	mcopy "$SRCDIR/auto/accs/cops.inf" "$BUILDROOT/$lang/GEMSYS/HOME/"
	mcopy "$SRCDIR/auto/accs/cops.acc" "$BUILDROOT/$lang/AUTO/ACCS/COPS.ACC"
	mcopy "$SRCDIR/auto/accs/*.PAL" "$BUILDROOT/$lang/AUTO/ACCS/"
	mcopy "$SRCDIR/auto/accs/cpx/*.CPX" "$BUILDROOT/$lang/AUTO/ACCS/CPX/"
	mcopy "$SRCDIR/auto/accs/cpz/*.CPZ" "$BUILDROOT/$lang/AUTO/ACCS/CPZ/"
	
	mtype "$SRCDIR/apps/cpx/magxconf.hdr" > "$BUILDROOT/$lang/AUTO/ACCS/CPX/MAGXCONF.CPX"
	mtype "$SRCDIR/apps/cpx/magxconf.cp" >> "$BUILDROOT/$lang/AUTO/ACCS/CPX/MAGXCONF.CPX"
	mtype "$SRCDIR/apps/cpx/tslice.hdr" > "$BUILDROOT/$lang/AUTO/ACCS/CPX/TSLICE.CPX"
	mtype "$SRCDIR/apps/cpx/tslice.cp" >> "$BUILDROOT/$lang/AUTO/ACCS/CPX/TSLICE.CPX"

	mcopy "$SRCDIR/tools/crashdmp/crashdmp.tos" "$BUILDROOT/$lang/BIN/"
	mcopy "$SRCDIR/tools/fc/fc.ttp" "$BUILDROOT/$lang/BIN/"
	mcopy "$SRCDIR/apps/limitmem/limitmem.ttp" "$BUILDROOT/$lang/BIN/"
	mcopy "$SRCDIR/tools/memexamn/memexamn.ttp" "$BUILDROOT/$lang/BIN/"

	mcopy "$SRCDIR/apps/applicat/applicat.app" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	
	mcopy "$SRCDIR/apps/chgres/chgres.prg" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy "$SRCDIR/apps/cmd/mcmd.tos" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy "$SRCDIR/apps/cmd/help/help.bat" "$BUILDROOT/$lang/BIN/"
	mcopy "$SRCDIR/apps/magxdesk.5/magxdesk.app" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy "$SRCDIR/apps/magxdesk.5/rsc/*" "$BUILDROOT/$lang/GEMSYS/GEMDESK/RSC/"
	
	mcopy -s "$SRCDIR/apps/magxdesk.5/pat/*"  "$BUILDROOT/$lang/GEMSYS/GEMDESK/PAT/"
	mcopy "$SRCDIR/apps/mgclock/mgclock.prg" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy "$SRCDIR/apps/mgcopy/mgcopy.app" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy "$SRCDIR/apps/mgedit/mgedit.app" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy "$SRCDIR/apps/mgformat/mgformat.prg" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy "$SRCDIR/apps/mgnotice.2/mgnotice.app" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy "$SRCDIR/apps/mgsearch/mgsearch.app" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy "$SRCDIR/apps/mgview/mgview.app" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy "$SRCDIR/apps/mgxclock/mgxclock.prg" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy "$SRCDIR/apps/mod_app/mod_app.ttp" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy "$SRCDIR/apps/showfile/showfile.ttp" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy "$SRCDIR/tools/showfree/showfree.tos" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy "$SRCDIR/apps/shutdown/shutdown.prg" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy "$SRCDIR/apps/shutdown/shutdown.inf" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy "$SRCDIR/apps/vfatconf/vfatconf.prg" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy "$SRCDIR/apps/vt52/vt52.prg" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy "$SRCDIR/apps/magiccfg/magiccfg.app" "$BUILDROOT/$lang/EXTRAS/MAGICCFG/"
	mcopy "$SRCDIR/apps/magiccfg/history.txt" "$BUILDROOT/$lang/EXTRAS/MAGICCFG/"
	mcopy "$SRCDIR/apps/appline/appline.app" "$BUILDROOT/$lang/EXTRAS/APPLINE/"
	mcopy "$SRCDIR/apps/appline/appline.inf" "$BUILDROOT/$lang/EXTRAS/APPLINE/"
	mcopy "$SRCDIR/apps/wbdaemon/wbdaemon.prg" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy "$SRCDIR/apps/mmxdaemn/mmxdaemn.prg" "$BUILDROOT/$lang/GEMSYS/MAGIC/START/MMXDAEMN.PRX"
	mcopy "$SRCDIR/tools/dev_ser/dev_ser.dev" "$BUILDROOT/$lang/GEMSYS/MAGIC/XTENSION/"
	mcopy "$SRCDIR/extensio/ramdisk/ramdisk.xfs" "$BUILDROOT/$lang/GEMSYS/MAGIC/XTENSION/RAMDISK.XFX"
	mcopy "$SRCDIR/extensio/cd-mxfs/spinmagc.xfs" "$BUILDROOT/$lang/GEMSYS/MAGIC/XTENSION/SPINMAGC.XFX"
	mcopy "$SRCDIR/extensio/edit_slb/editobjc.slb" "$BUILDROOT/$lang/GEMSYS/MAGIC/XTENSION/"
	mcopy "$SRCDIR/extensio/load_img/load_img.slb" "$BUILDROOT/$lang/GEMSYS/MAGIC/XTENSION/"
	mcopy "$SRCDIR/kernel/winframe/winframe.slb" "$BUILDROOT/$lang/GEMSYS/MAGIC/XTENSION/"
	mcopy "$SRCDIR/kernel/winframe/winframe.rsc" "$BUILDROOT/$lang/GEMSYS/MAGIC/XTENSION/"
	mcopy "$SRCDIR/kernel/winframe/winframe.inf" "$BUILDROOT/$lang/GEMSYS/MAGIC/XTENSION/"
	mcopy -s "$SRCDIR/kernel/winframe/themes/*" "$BUILDROOT/$lang/GEMSYS/MAGIC/XTENSION/THEMES/"
	mcopy "$SRCDIR/tools/addmem/addmem.prg" "$BUILDROOT/$lang/EXTRAS/"
	mcopy "$SRCDIR/tools/misc_tst/adr.prg" "$BUILDROOT/$lang/EXTRAS/BIN/"
	mcopy "$SRCDIR/tools/misc_tst/bomb.prg" "$BUILDROOT/$lang/EXTRAS/BIN/"
	mcopy "$SRCDIR/tools/misc_tst/il0008.prg" "$BUILDROOT/$lang/EXTRAS/BIN/"
	mcopy "$SRCDIR/tools/misc_tst/il4afc.prg" "$BUILDROOT/$lang/EXTRAS/BIN/"
	mcopy "$SRCDIR/tools/misc_tst/ilf000.prg" "$BUILDROOT/$lang/EXTRAS/BIN/"
	mcopy "$SRCDIR/tools/misc_tst/priv_rte.prg" "$BUILDROOT/$lang/EXTRAS/BIN/"
	mcopy "$SRCDIR/tools/misc_tst/priv_sr.prg" "$BUILDROOT/$lang/EXTRAS/BIN/"
	mcopy "$SRCDIR/tools/misc_tst/trap7.prg" "$BUILDROOT/$lang/EXTRAS/BIN/"
	mcopy "$SRCDIR/extensio/romdrvr/romdrvr.prg" "$BUILDROOT/$lang/EXTRAS/"
	mcopy "$SRCDIR/kernel/bios/atari/boot/magxboot.prg" "$BUILDROOT/$lang/EXTRAS/"
	mcopy "$SRCDIR/kernel/bios/atari/boot/magxbo32.prg" "$BUILDROOT/$lang/EXTRAS/"
	mcopy "$SRCDIR/kernel/bios/atari/boot/ct60new.tos" "$BUILDROOT/$lang/EXTRAS/ct60boot.prg"
	mcopy "$SRCDIR/kernel/bios/atari/boot/magic_p.tos" "$BUILDROOT/$lang/EXTRAS/"
	mcopy "$SRCDIR/kernel/bios/atari/boot/ct60.txt" "$BUILDROOT/$lang/EXTRAS/"
	mcopy "$SRCDIR/kernel/bios/atari/boot/magxmila.prg" "$BUILDROOT/$lang/EXTRAS/"
	mcopy "$SRCDIR/kernel/bios/atari/boot/magxboot.prg" "$BUILDROOT/$lang/AUTO/"
	mcopy "$SRCDIR/tools/hardcopy/hardcopy.prg" "$BUILDROOT/$lang/EXTRAS/"
	mcopy "$SRCDIR/tools/flock_ok/flock_ok.prg" "$BUILDROOT/$lang/EXTRAS/FLOCK_OK/"
	# TODO: french translation
	mcopy "$SRCDIR/tools/flock_ok/$lang/flock_ok.txt" "$BUILDROOT/$lang/EXTRAS/FLOCK_OK/"
	mcopy "$SRCDIR/tools/aes_lupe/aes_lupe.app" "$BUILDROOT/$lang/EXTRAS/AES_LUPE/"
	mcopy "$SRCDIR/tools/aes_lupe/aes_lupe.img" "$BUILDROOT/$lang/EXTRAS/AES_LUPE/"
	# TODO: english & french translation
	mcopy "$SRCDIR/tools/aes_lupe/aes_lupe.txt" "$BUILDROOT/$lang/EXTRAS/AES_LUPE/"
	mcopy "$SRCDIR/tools/clock/clock.app" "$BUILDROOT/$lang/EXTRAS/CLOCK/"
	mcopy "$SRCDIR/tools/clock/clock.gen" "$BUILDROOT/$lang/EXTRAS/CLOCK/"
	mcopy "$SRCDIR/tools/clock/clock.inf" "$BUILDROOT/$lang/EXTRAS/CLOCK/"
	mcopy "$SRCDIR/tools/clock/clock.man" "$BUILDROOT/$lang/EXTRAS/CLOCK/"
	mcopy "$SRCDIR/tools/clock/clock.mup" "$BUILDROOT/$lang/EXTRAS/CLOCK/"
	mcopy "$SRCDIR/tools/clock/clockcol.cpx" "$BUILDROOT/$lang/EXTRAS/CLOCK/"
	mcopy "$SRCDIR/tools/clock/maus.ruf" "$BUILDROOT/$lang/EXTRAS/CLOCK/"
	mcopy "$SRCDIR/tools/clock/readme.cat" "$BUILDROOT/$lang/EXTRAS/CLOCK/"
	# mcopy "$SRCDIR/apps/instmagc/magx.inf" "$BUILDROOT/$lang/"

	mcopy "$SRCDIR/kernel/vdi/drivers/*.SYS" "$BUILDROOT/$lang/GEMSYS/"
	mcopy "$SRCDIR/kernel/vdi/drivers/*.OSD" "$BUILDROOT/$lang/GEMSYS/"
	
	# strip ROM header for magic_pc.os kernels
	if test -f "$BUILDROOT/$lang/magic_pc.os"; then
		if test `dd if="$BUILDROOT/$lang/magic_pc.os" bs=1 count=2` = '`$'; then  # magic 0x6024
			dd if="$BUILDROOT/$lang/magic_pc.os" of="$BUILDROOT/$lang/magic_pc.tmp" bs=1 skip=38
			mv "$BUILDROOT/$lang/magic_pc.tmp" "$BUILDROOT/$lang/magic_pc.os"
		fi
	fi
done

set +e
