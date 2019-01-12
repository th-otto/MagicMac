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
done


#
# German localizations
#
mcopy -b "$SRCDIR/apps/applicat/applicat.inf" "$BUILDROOT/de/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/applicat/applicat.rsc" "$BUILDROOT/de/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/chgres/chgres.rsc" "$BUILDROOT/de/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/magxdesk.5/magxdesk.rsc" "$BUILDROOT/de/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/cmd/mcmd.tos" "$BUILDROOT/de/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/mgcopy/mgcopy.rsc" "$BUILDROOT/de/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/mgedit/mgedit.rsc" "$BUILDROOT/de/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/mgformat/mgformat.rsc" "$BUILDROOT/de/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/mgnotice.2/mgnotice.rsc" "$BUILDROOT/de/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/mgnotice.2/mgnotice.txt" "$BUILDROOT/de/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/mgsearch/mgsearch.rsc" "$BUILDROOT/de/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/mod_app/mod_app.txt" "$BUILDROOT/de/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/shutdown/de/shutdown.prg" "$BUILDROOT/de/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/vfatconf/vfatconf.rsc" "$BUILDROOT/de/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/vt52/de/vt52.rsc" "$BUILDROOT/de/GEMSYS/GEMDESK/"

mcopy -b "$SRCDIR/extensio/pdlg_slb/de/pdlg.slb" "$BUILDROOT/de/GEMSYS/MAGIC/XTENSION/"

mcopy -b "$SRCDIR/auto/accs/de/cops.app" "$BUILDROOT/de/AUTO/ACCS/"
mcopy -b "$SRCDIR/auto/accs/cpx/de/*.CPX" "$BUILDROOT/de/AUTO/ACCS/CPX/"

mcopy -b "$SRCDIR/kernel/build/de/magic.ram" "$BUILDROOT/de"
mcopy -b "$SRCDIR/kernel/build/de/mmilan.ram" "$BUILDROOT/de"
mcopy -b "$SRCDIR/kernel/build/de/mhades.ram" "$BUILDROOT/de"


#
# English localizations
#
mcopy -b "$SRCDIR/apps/applicat/us/applicat.inf" "$BUILDROOT/en/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/applicat/us/applicat.rsc" "$BUILDROOT/en/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/chgres/en/chgres.rsc" "$BUILDROOT/en/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/magxdesk.5/us/magxdesk.rsc" "$BUILDROOT/en/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/cmd/mcmd.tos" "$BUILDROOT/en/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/mgcopy/us/mgcopy.rsc" "$BUILDROOT/en/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/mgedit/us/mgedit.rsc" "$BUILDROOT/en/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/mgformat/us/mgformat.rsc" "$BUILDROOT/en/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/mgnotice.2/us/mgnotice.rsc" "$BUILDROOT/en/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/mgnotice.2/us/mgnotice.txt" "$BUILDROOT/en/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/mgsearch/us/mgsearch.rsc" "$BUILDROOT/en/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/mod_app/en/mod_app.txt" "$BUILDROOT/en/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/shutdown/en/shutdown.prg" "$BUILDROOT/en/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/vfatconf/en/vfatconf.rsc" "$BUILDROOT/en/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/vt52/en/vt52.rsc" "$BUILDROOT/en/GEMSYS/GEMDESK/"

mcopy -b "$SRCDIR/extensio/pdlg_slb/en/pdlg.slb" "$BUILDROOT/en/GEMSYS/MAGIC/XTENSION/"

mcopy -b "$SRCDIR/auto/accs/en/cops.app" "$BUILDROOT/en/AUTO/ACCS/"
mcopy -b "$SRCDIR/auto/accs/cpx/en/*.CPX" "$BUILDROOT/en/AUTO/ACCS/CPX/"

mcopy -b "$SRCDIR/kernel/build/en/magic.ram" "$BUILDROOT/en"
mcopy -b "$SRCDIR/kernel/build/en/mmilan.ram" "$BUILDROOT/en"
mcopy -b "$SRCDIR/kernel/build/en/mhades.ram" "$BUILDROOT/en"


#
# French localizations
#
mcopy -b "$SRCDIR/apps/applicat/fr/applicat.inf" "$BUILDROOT/fr/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/applicat/fr/applicat.rsc" "$BUILDROOT/fr/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/chgres/fr/chgres.rsc" "$BUILDROOT/fr/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/magxdesk.5/fr/magxdesk.rsc" "$BUILDROOT/fr/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/cmd/mcmd.tos" "$BUILDROOT/fr/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/mgcopy/fr/mgcopy.rsc" "$BUILDROOT/fr/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/mgedit/fr/mgedit.rsc" "$BUILDROOT/fr/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/mgformat/fr/mgformat.rsc" "$BUILDROOT/fr/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/mgnotice.2/fr/mgnotice.rsc" "$BUILDROOT/fr/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/mgnotice.2/fr/mgnotice.txt" "$BUILDROOT/fr/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/mgsearch/fr/mgsearch.rsc" "$BUILDROOT/fr/GEMSYS/GEMDESK/"
# TODO: french translation
mcopy -b "$SRCDIR/apps/mod_app/en/mod_app.txt" "$BUILDROOT/fr/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/shutdown/fr/shutdown.prg" "$BUILDROOT/fr/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/vfatconf/fr/vfatconf.rsc" "$BUILDROOT/fr/GEMSYS/GEMDESK/"
mcopy -b "$SRCDIR/apps/vt52/fr/vt52.rsc" "$BUILDROOT/fr/GEMSYS/GEMDESK/"

mcopy -b "$SRCDIR/extensio/pdlg_slb/fr/pdlg.slb" "$BUILDROOT/fr/GEMSYS/MAGIC/XTENSION/"

mcopy -b "$SRCDIR/auto/accs/fr/cops.app" "$BUILDROOT/fr/AUTO/ACCS/"
mcopy -b "$SRCDIR/auto/accs/cpx/fr/*.CPX" "$BUILDROOT/fr/AUTO/ACCS/CPX/"

mcopy -b "$SRCDIR/kernel/build/fr/magic.ram" "$BUILDROOT/fr"
mcopy -b "$SRCDIR/kernel/build/fr/mmilan.ram" "$BUILDROOT/fr"
mcopy -b "$SRCDIR/kernel/build/fr/mhades.ram" "$BUILDROOT/fr"

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
	
	mcopy -bs "$SRCDIR/apps/magxdesk.5/pat/."  "$BUILDROOT/$lang/GEMSYS/GEMDESK/PAT/"
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
	mcopy -b "$SRCDIR/apps/wbdaemon/wbdaemon.prg" "$BUILDROOT/$lang/GEMSYS/GEMDESK/"
	mcopy -b "$SRCDIR/apps/mmxdaemn/mmxdaemn.prg" "$BUILDROOT/$lang/GEMSYS/MAGIC/START/"
	mcopy -b "$SRCDIR/tools/dev_ser/dev_ser.tos" "$BUILDROOT/$lang/GEMSYS/MAGIC/XTENSION/"
	mcopy -b "$SRCDIR/extensio/ramdisk/ramdisk.xfs" "$BUILDROOT/$lang/GEMSYS/MAGIC/XTENSION/"
	mcopy -b "$SRCDIR/extensio/cd-mxfs/spinmagc.xfs" "$BUILDROOT/$lang/GEMSYS/MAGIC/XTENSION/"
	mcopy -b "$SRCDIR/extensio/edit_slb/editobjc.slb" "$BUILDROOT/$lang/GEMSYS/MAGIC/XTENSION/"
	mcopy -b "$SRCDIR/extensio/load_img/load_img.slb" "$BUILDROOT/$lang/GEMSYS/MAGIC/XTENSION/"
	mcopy -b "$SRCDIR/kernel/winframe/winframe.slb" "$BUILDROOT/$lang/GEMSYS/MAGIC/XTENSION/"
	mcopy -b "$SRCDIR/kernel/winframe/winframe.rsc" "$BUILDROOT/$lang/GEMSYS/MAGIC/XTENSION/"
	mcopy -b "$SRCDIR/kernel/winframe/winframe.inf" "$BUILDROOT/$lang/GEMSYS/MAGIC/XTENSION/"
	mcopy -bs "$SRCDIR/kernel/winframe/themes/." "$BUILDROOT/$lang/GEMSYS/MAGIC/XTENSION/THEMES/"
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
	mcopy -b "$SRCDIR/doc/usage/magx.inf" "$BUILDROOT/$lang/EXTRAS/"
	# mcopy -b "$SRCDIR/apps/instmagc/magx.inf" "$BUILDROOT/$lang/"

	mcopy -b "$SRCDIR/kernel/vdi/drivers/*.SYS" "$BUILDROOT/$lang/GEMSYS/"
	mcopy -b "$SRCDIR/kernel/vdi/drivers/*.OSD" "$BUILDROOT/$lang/GEMSYS/"
done

set +e
