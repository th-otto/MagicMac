#!/bin/sh

RELEASE_DIR=/tmp/atarix
RESOURCES_DIR="$RELEASE_DIR/AtariX.app/Contents/Resources"
SRC_DIR=`pwd`

function upper()
{
	echo "$@" | tr '[a-z]' '[A-Z]'
}

LANGUAGES="de fr en"

set -e

#
# German localizations
#
mkdir -p "$RESOURCES_DIR/de.lproj/rootfs/GEMSYS/GEMDESK"
mkdir -p "$RESOURCES_DIR/de.lproj/rootfs/GEMSYS/MAGIC/XTENSION"
mkdir -p "$RESOURCES_DIR/de.lproj/rootfs/AUTO/ACCS/CPX"
mkdir -p "$RESOURCES_DIR/de.lproj/rootfs/AUTO/ACCS/CPZ"

cp -a "$SRC_DIR/apps/applicat/applicat.inf" "$RESOURCES_DIR/de.lproj/rootfs/GEMSYS/GEMDESK/APPLICAT.INF"
cp -a "$SRC_DIR/apps/applicat/applicat.rsc" "$RESOURCES_DIR/de.lproj/rootfs/GEMSYS/GEMDESK/APPLICAT.RSC"
cp -a "$SRC_DIR/apps/chgres/chgres.rsc" "$RESOURCES_DIR/de.lproj/rootfs/GEMSYS/GEMDESK/CHGRES.RSC"
cp -a "$SRC_DIR/apps/magxdesk.5/magxdesk.rsc" "$RESOURCES_DIR/de.lproj/rootfs/GEMSYS/GEMDESK/MAGXDESK.RSC"
cp -a "$SRC_DIR/apps/cmd/mcmd.tos" "$RESOURCES_DIR/de.lproj/rootfs/GEMSYS/GEMDESK/MCMD.TOS"
cp -a "$SRC_DIR/apps/mgcopy/mgcopy.rsc" "$RESOURCES_DIR/de.lproj/rootfs/GEMSYS/GEMDESK/MGCOPY.RSC"
cp -a "$SRC_DIR/apps/mgedit/mgedit.rsc" "$RESOURCES_DIR/de.lproj/rootfs/GEMSYS/GEMDESK/MGEDIT.RSC"
cp -a "$SRC_DIR/apps/mgformat/mgformat.rsc" "$RESOURCES_DIR/de.lproj/rootfs/GEMSYS/GEMDESK/MGFORMAT.RSC"
cp -a "$SRC_DIR/apps/mgnotice.2/mgnotice.rsc" "$RESOURCES_DIR/de.lproj/rootfs/GEMSYS/GEMDESK/MGNOTICE.RSC"
cp -a "$SRC_DIR/apps/mgnotice.2/mgnotice.txt" "$RESOURCES_DIR/de.lproj/rootfs/GEMSYS/GEMDESK/MGNOTICE.TXT"
cp -a "$SRC_DIR/apps/mgsearch/mgsearch.rsc" "$RESOURCES_DIR/de.lproj/rootfs/GEMSYS/GEMDESK/MGSEARCH.RSC"
cp -a "$SRC_DIR/apps/mod_app/mod_app.txt" "$RESOURCES_DIR/de.lproj/rootfs/GEMSYS/GEMDESK/MOD_APP.TXT"
cp -a "$SRC_DIR/apps/shutdown/de/shutdown.prg" "$RESOURCES_DIR/de.lproj/rootfs/GEMSYS/GEMDESK/SHUTDOWN.PRG"
cp -a "$SRC_DIR/apps/vfatconf/vfatconf.rsc" "$RESOURCES_DIR/de.lproj/rootfs/GEMSYS/GEMDESK/VFATCONF.RSC"
cp -a "$SRC_DIR/apps/vt52/de/vt52.rsc" "$RESOURCES_DIR/de.lproj/rootfs/GEMSYS/GEMDESK/VT52.RSC"

cp -a "$SRC_DIR/extensio/pdlg_slb/pdlg.slb" "$RESOURCES_DIR/de.lproj/rootfs/GEMSYS/MAGIC/XTENSION/PDLG.SLB"

cp -a "$SRC_DIR/kernel/build/de/magcmacx.os" "$RESOURCES_DIR/de.lproj/MagicMacX.OS"

cp -a "$SRC_DIR/auto/accs/de/cops.app" "$RESOURCES_DIR/de.lproj/rootfs/AUTO/ACCS/COPS.ACC"
for f in "$SRC_DIR/auto/accs/cpx/de/"*.cpx; do
	cp -a "$f" "$RESOURCES_DIR/de.lproj/rootfs/AUTO/ACCS/CPX/$(upper $(basename $f))"
done

#
# English localizations
#
mkdir -p "$RESOURCES_DIR/English.lproj/rootfs/GEMSYS/GEMDESK"
mkdir -p "$RESOURCES_DIR/English.lproj/rootfs/GEMSYS/MAGIC/XTENSION"
mkdir -p "$RESOURCES_DIR/English.lproj/rootfs/AUTO/ACCS/CPX"
mkdir -p "$RESOURCES_DIR/English.lproj/rootfs/AUTO/ACCS/CPZ"

cp -a "$SRC_DIR/apps/applicat/us/applicat.inf" "$RESOURCES_DIR/English.lproj/rootfs/GEMSYS/GEMDESK/APPLICAT.INF"
cp -a "$SRC_DIR/apps/applicat/us/applicat.rsc" "$RESOURCES_DIR/English.lproj/rootfs/GEMSYS/GEMDESK/APPLICAT.RSC"
cp -a "$SRC_DIR/apps/chgres/en/chgres.rsc" "$RESOURCES_DIR/English.lproj/rootfs/GEMSYS/GEMDESK/CHGRES.RSC"
cp -a "$SRC_DIR/apps/magxdesk.5/us/magxdesk.rsc" "$RESOURCES_DIR/English.lproj/rootfs/GEMSYS/GEMDESK/MAGXDESK.RSC"
cp -a "$SRC_DIR/apps/cmd/mcmd.tos" "$RESOURCES_DIR/English.lproj/rootfs/GEMSYS/GEMDESK/MCMD.TOS"
cp -a "$SRC_DIR/apps/mgcopy/us/mgcopy.rsc" "$RESOURCES_DIR/English.lproj/rootfs/GEMSYS/GEMDESK/MGCOPY.RSC"
cp -a "$SRC_DIR/apps/mgedit/us/mgedit.rsc" "$RESOURCES_DIR/English.lproj/rootfs/GEMSYS/GEMDESK/MGEDIT.RSC"
cp -a "$SRC_DIR/apps/mgformat/us/mgformat.rsc" "$RESOURCES_DIR/English.lproj/rootfs/GEMSYS/GEMDESK/MGFORMAT.RSC"
cp -a "$SRC_DIR/apps/mgnotice.2/us/mgnotice.rsc" "$RESOURCES_DIR/English.lproj/rootfs/GEMSYS/GEMDESK/MGNOTICE.RSC"
cp -a "$SRC_DIR/apps/mgnotice.2/us/mgnotice.txt" "$RESOURCES_DIR/English.lproj/rootfs/GEMSYS/GEMDESK/MGNOTICE.TXT"
cp -a "$SRC_DIR/apps/mgsearch/us/mgsearch.rsc" "$RESOURCES_DIR/English.lproj/rootfs/GEMSYS/GEMDESK/MGSEARCH.RSC"
cp -a "$SRC_DIR/apps/mod_app/en/mod_app.txt" "$RESOURCES_DIR/English.lproj/rootfs/GEMSYS/GEMDESK/MOD_APP.TXT"
cp -a "$SRC_DIR/apps/shutdown/en/shutdown.prg" "$RESOURCES_DIR/English.lproj/rootfs/GEMSYS/GEMDESK/SHUTDOWN.PRG"
cp -a "$SRC_DIR/apps/vfatconf/en/vfatconf.rsc" "$RESOURCES_DIR/English.lproj/rootfs/GEMSYS/GEMDESK/VFATCONF.RSC"
cp -a "$SRC_DIR/apps/vt52/en/vt52.rsc" "$RESOURCES_DIR/English.lproj/rootfs/GEMSYS/GEMDESK/VT52.RSC"

cp -a "$SRC_DIR/extensio/pdlg_slb/en/pdlg.slb" "$RESOURCES_DIR/English.lproj/rootfs/GEMSYS/MAGIC/XTENSION/PDLG.SLB"

cp -a "$SRC_DIR/kernel/build/en/magcmacx.os" "$RESOURCES_DIR/English.lproj/MagicMacX.OS"

cp -a "$SRC_DIR/auto/accs/en/cops.app" "$RESOURCES_DIR/English.lproj/rootfs/AUTO/ACCS/COPS.ACC"
for f in "$SRC_DIR/auto/accs/cpx/en/"*.cpx; do
	cp -a "$f" "$RESOURCES_DIR/English.lproj/rootfs/AUTO/ACCS/CPX/$(upper $(basename $f))"
done

#
# French localizations
#
mkdir -p "$RESOURCES_DIR/fr.lproj/rootfs/GEMSYS/GEMDESK"
mkdir -p "$RESOURCES_DIR/fr.lproj/rootfs/GEMSYS/MAGIC/XTENSION"
mkdir -p "$RESOURCES_DIR/fr.lproj/rootfs/AUTO/ACCS/CPX"
mkdir -p "$RESOURCES_DIR/fr.lproj/rootfs/AUTO/ACCS/CPZ"

cp -a "$SRC_DIR/apps/applicat/fr/applicat.inf" "$RESOURCES_DIR/fr.lproj/rootfs/GEMSYS/GEMDESK/APPLICAT.INF"
cp -a "$SRC_DIR/apps/applicat/fr/applicat.rsc" "$RESOURCES_DIR/fr.lproj/rootfs/GEMSYS/GEMDESK/APPLICAT.RSC"
cp -a "$SRC_DIR/apps/chgres/fr/chgres.rsc" "$RESOURCES_DIR/fr.lproj/rootfs/GEMSYS/GEMDESK/CHGRES.RSC"
cp -a "$SRC_DIR/apps/magxdesk.5/fr/magxdesk.rsc" "$RESOURCES_DIR/fr.lproj/rootfs/GEMSYS/GEMDESK/MAGXDESK.RSC"
cp -a "$SRC_DIR/apps/cmd/mcmd.tos" "$RESOURCES_DIR/fr.lproj/rootfs/GEMSYS/GEMDESK/MCMD.TOS"
cp -a "$SRC_DIR/apps/mgcopy/fr/mgcopy.rsc" "$RESOURCES_DIR/fr.lproj/rootfs/GEMSYS/GEMDESK/MGCOPY.RSC"
cp -a "$SRC_DIR/apps/mgedit/fr/mgedit.rsc" "$RESOURCES_DIR/fr.lproj/rootfs/GEMSYS/GEMDESK/MGEDIT.RSC"
cp -a "$SRC_DIR/apps/mgformat/fr/mgformat.rsc" "$RESOURCES_DIR/fr.lproj/rootfs/GEMSYS/GEMDESK/MGFORMAT.RSC"
cp -a "$SRC_DIR/apps/mgnotice.2/fr/mgnotice.rsc" "$RESOURCES_DIR/fr.lproj/rootfs/GEMSYS/GEMDESK/MGNOTICE.RSC"
cp -a "$SRC_DIR/apps/mgnotice.2/fr/mgnotice.txt" "$RESOURCES_DIR/fr.lproj/rootfs/GEMSYS/GEMDESK/MGNOTICE.TXT"
cp -a "$SRC_DIR/apps/mgsearch/fr/mgsearch.rsc" "$RESOURCES_DIR/fr.lproj/rootfs/GEMSYS/GEMDESK/MGSEARCH.RSC"
# TODO: french translation
cp -a "$SRC_DIR/apps/mod_app/en/mod_app.txt" "$RESOURCES_DIR/fr.lproj/rootfs/GEMSYS/GEMDESK/MOD_APP.TXT"
cp -a "$SRC_DIR/apps/shutdown/fr/shutdown.prg" "$RESOURCES_DIR/fr.lproj/rootfs/GEMSYS/GEMDESK/SHUTDOWN.PRG"
cp -a "$SRC_DIR/apps/vfatconf/fr/vfatconf.rsc" "$RESOURCES_DIR/fr.lproj/rootfs/GEMSYS/GEMDESK/VFATCONF.RSC"
cp -a "$SRC_DIR/apps/vt52/fr/vt52.rsc" "$RESOURCES_DIR/fr.lproj/rootfs/GEMSYS/GEMDESK/VT52.RSC"

cp -a "$SRC_DIR/extensio/pdlg_slb/fr/pdlg.slb" "$RESOURCES_DIR/fr.lproj/rootfs/GEMSYS/MAGIC/XTENSION/PDLG.SLB"

cp -a "$SRC_DIR/kernel/build/fr/magcmacx.os" "$RESOURCES_DIR/fr.lproj/MagicMacX.OS"

cp -a "$SRC_DIR/auto/accs/fr/cops.app" "$RESOURCES_DIR/fr.lproj/rootfs/AUTO/ACCS/COPS.ACC"
for f in "$SRC_DIR/auto/accs/cpx/fr/"*.cpx; do
	cp -a "$f" "$RESOURCES_DIR/fr.lproj/rootfs/AUTO/ACCS/CPX/$(upper $(basename $f))"
done

#
# Common files
#
mkdir -p "$RESOURCES_DIR/rootfs-common"

mkdir -p "$RESOURCES_DIR/rootfs-common/AUTO/ACCS/CPX"
mkdir -p "$RESOURCES_DIR/rootfs-common/AUTO/ACCS/CPZ"
mkdir -p "$RESOURCES_DIR/rootfs-common/GEMSYS/HOME"
mkdir -p "$RESOURCES_DIR/rootfs-common/GEMSYS/MAGIC/START"
mkdir -p "$RESOURCES_DIR/rootfs-common/GEMSYS/MAGIC/STOP"
mkdir -p "$RESOURCES_DIR/rootfs-common/GEMSYS/MAGIC/UTILITY"
mkdir -p "$RESOURCES_DIR/rootfs-common/GEMSYS/MAGIC/XTENSION"
mkdir -p "$RESOURCES_DIR/rootfs-common/GEMSYS/MAGIC/XTENSION/HIDE"
mkdir -p "$RESOURCES_DIR/rootfs-common/GEMSYS/MAGIC/XTENSION/HIDE2"
mkdir -p "$RESOURCES_DIR/rootfs-common/GEMSYS/MAGIC/XTENSION/THEMES"
mkdir -p "$RESOURCES_DIR/rootfs-common/BIN"
mkdir -p "$RESOURCES_DIR/rootfs-common/CLIPBRD"
mkdir -p "$RESOURCES_DIR/rootfs-common/EXTRAS"
mkdir -p "$RESOURCES_DIR/rootfs-common/EXTRAS/BIN"
mkdir -p "$RESOURCES_DIR/rootfs-common/EXTRAS/FLOCK_OK"
mkdir -p "$RESOURCES_DIR/rootfs-common/EXTRAS/CLOCK"
mkdir -p "$RESOURCES_DIR/rootfs-common/EXTRAS/AES_LUPE"
mkdir -p "$RESOURCES_DIR/rootfs-common/GEMSYS/GEMSCRAP"
mkdir -p "$RESOURCES_DIR/rootfs-common/GEMSYS/GEMDESK"
mkdir -p "$RESOURCES_DIR/rootfs-common/GEMSYS/GEMDESK/PAT"
mkdir -p "$RESOURCES_DIR/rootfs-common/GEMSYS/GEMDESK/RSC"

cp -a "$SRC_DIR/auto/autoexec.bat" "$RESOURCES_DIR/rootfs-common/AUTO/AUTOEXEC.BAT"
cp -a "$SRC_DIR/apps/cmd/autoexec.bat" "$RESOURCES_DIR/rootfs-common/AUTOEXEC.BAT"

cp -a "$SRC_DIR/auto/accs/cops.inf" "$RESOURCES_DIR/rootfs-common/GEMSYS/HOME/COPS.INF"
for f in $SRC_DIR/auto/accs/*.pal; do
	cp -a "$f" "$RESOURCES_DIR/rootfs-common/AUTO/ACCS/$(upper $(basename $f))"
done
for f in "$SRC_DIR/auto/accs/cpx/"*.cpx; do
	cp -a "$f" "$RESOURCES_DIR/rootfs-common/AUTO/ACCS/CPX/$(upper $(basename $f))"
done
for f in $SRC_DIR/auto/accs/cpz/*.cpz; do
	cp -a "$f" "$RESOURCES_DIR/rootfs-common/AUTO/ACCS/CPZ/$(upper $(basename $f))"
done

cat "$SRC_DIR/apps/cpx/magxconf.hdr" "$SRC_DIR/apps/cpx/magxconf.cp" > "$RESOURCES_DIR/rootfs-common/AUTO/ACCS/CPX/MAGXCONF.CPX"
cat "$SRC_DIR/apps/cpx/tslice.hdr" "$SRC_DIR/apps/cpx/tslice.cp" > "$RESOURCES_DIR/rootfs-common/AUTO/ACCS/CPX/TSLICE.CPX"

cp -a "$SRC_DIR/tools/crashdmp/crashdmp.tos" "$RESOURCES_DIR/rootfs-common/BIN/CRASHDMP.TOS"
cp -a "$SRC_DIR/tools/fc/fc.ttp" "$RESOURCES_DIR/rootfs-common/BIN/FC.TTP"
cp -a "$SRC_DIR/apps/limitmem/limitmem.ttp" "$RESOURCES_DIR/rootfs-common/BIN/LIMITMEM.TTP"
cp -a "$SRC_DIR/tools/memexamn/memexamn.ttp" "$RESOURCES_DIR/rootfs-common/BIN/MEMEXAMN.TTP"

cp -a "$SRC_DIR/apps/applicat/applicat.app" "$RESOURCES_DIR/rootfs-common/GEMSYS/GEMDESK/APPLICAT.APP"
if test -d "$SRC_DIR/apps/applicat/rsc"; then
	for f in "$SRC_DIR/apps/applicat/rsc/"*.rsc; do
		cp -a "$f" "$RESOURCES_DIR/rootfs-common/GEMSYS/GEMDESK/RSC/$(upper $(basename $f))"
	done
fi
cp -a "$SRC_DIR/apps/chgres/chgres.prg" "$RESOURCES_DIR/rootfs-common/GEMSYS/GEMDESK/CHGRES.PRG"
cp -a "$SRC_DIR/apps/magxdesk.5/magxdesk.app" "$RESOURCES_DIR/rootfs-common/GEMSYS/GEMDESK/MAGXDESK.APP"
if test -d "$SRC_DIR/apps/magxdesk.5/rsc/"; then
	for f in "$SRC_DIR/apps/magxdesk.5/rsc/"*; do
		cp -a "$f" "$RESOURCES_DIR/rootfs-common/GEMSYS/GEMDESK/RSC/$(upper $(basename $f))"
	done
fi
cp -ar "$SRC_DIR/apps/magxdesk.5/pat/."  "$RESOURCES_DIR/rootfs-common/GEMSYS/GEMDESK/PAT"
cp -a "$SRC_DIR/apps/mgclock/mgclock.prg" "$RESOURCES_DIR/rootfs-common/GEMSYS/GEMDESK/MGCLOCK.PRG"
cp -a "$SRC_DIR/apps/mgcopy/mgcopy.app" "$RESOURCES_DIR/rootfs-common/GEMSYS/GEMDESK/MGCOPY.APP"
cp -a "$SRC_DIR/apps/mgedit/mgedit.app" "$RESOURCES_DIR/rootfs-common/GEMSYS/GEMDESK/MGEDIT.APP"
cp -a "$SRC_DIR/apps/mgformat/mgformat.prg" "$RESOURCES_DIR/rootfs-common/GEMSYS/GEMDESK/MGFORMAT.PRG"
cp -a "$SRC_DIR/apps/mgnotice.2/mgnotice.app" "$RESOURCES_DIR/rootfs-common/GEMSYS/GEMDESK/MGNOTICE.APP"
cp -a "$SRC_DIR/apps/mgsearch/mgsearch.app" "$RESOURCES_DIR/rootfs-common/GEMSYS/GEMDESK/MGSEARCH.APP"
cp -a "$SRC_DIR/apps/mgview/mgview.app" "$RESOURCES_DIR/rootfs-common/GEMSYS/GEMDESK/MGVIEW.APP"
cp -a "$SRC_DIR/apps/mgxclock/mgxclock.prg" "$RESOURCES_DIR/rootfs-common/GEMSYS/GEMDESK/MGXCLOCK.PRG"
cp -a "$SRC_DIR/apps/mod_app/mod_app.ttp" "$RESOURCES_DIR/rootfs-common/GEMSYS/GEMDESK/MOD_APP.TTP"
cp -a "$SRC_DIR/apps/showfile/showfile.ttp" "$RESOURCES_DIR/rootfs-common/GEMSYS/GEMDESK/SHOWFILE.TTP"
cp -a "$SRC_DIR/tools/showfree/showfree.tos" "$RESOURCES_DIR/rootfs-common/GEMSYS/GEMDESK/SHOWFREE.TOS"
cp -a "$SRC_DIR/apps/shutdown/shutdown.inf" "$RESOURCES_DIR/rootfs-common/GEMSYS/GEMDESK/SHUTDOWN.INF"
cp -a "$SRC_DIR/apps/vfatconf/vfatconf.prg" "$RESOURCES_DIR/rootfs-common/GEMSYS/GEMDESK/VFATCONF.PRG"
cp -a "$SRC_DIR/apps/vt52/vt52.prg" "$RESOURCES_DIR/rootfs-common/GEMSYS/GEMDESK/VT52.PRG"
cp -a "$SRC_DIR/apps/wbdaemon/wbdaemon.prg" "$RESOURCES_DIR/rootfs-common/GEMSYS/GEMDESK/WBDAEMON.PRG"
cp -a "$SRC_DIR/apps/mmxdaemn/mmxdaemn.prg" "$RESOURCES_DIR/rootfs-common/GEMSYS/MAGIC/START/MMXDAEMN.PRG"
cp -a "$SRC_DIR/tools/dev_ser/dev_ser.tos" "$RESOURCES_DIR/rootfs-common/GEMSYS/MAGIC/XTENSION/DEV_SER.DEV"
cp -a "$SRC_DIR/extensio/ramdisk/ramdisk.xfs" "$RESOURCES_DIR/rootfs-common/GEMSYS/MAGIC/XTENSION/RAMDISK.XFS"
cp -a "$SRC_DIR/extensio/cd-mxfs/spinmagc.xfs" "$RESOURCES_DIR/rootfs-common/GEMSYS/MAGIC/XTENSION/SPINMAGC.XFS"
cp -a "$SRC_DIR/extensio/edit_slb/editobjc.slb" "$RESOURCES_DIR/rootfs-common/GEMSYS/MAGIC/XTENSION/EDITOBJC.SLB"
cp -a "$SRC_DIR/extensio/load_img/load_img.slb" "$RESOURCES_DIR/rootfs-common/GEMSYS/MAGIC/XTENSION/LOAD_IMG.SLB"
cp -a "$SRC_DIR/kernel/winframe/winframe.slb" "$RESOURCES_DIR/rootfs-common/GEMSYS/MAGIC/XTENSION/WINFRAME.SLB"
cp -a "$SRC_DIR/kernel/winframe/winframe.rsc" "$RESOURCES_DIR/rootfs-common/GEMSYS/MAGIC/XTENSION/WINFRAME.RSC"
cp -a "$SRC_DIR/kernel/winframe/winframe.inf" "$RESOURCES_DIR/rootfs-common/GEMSYS/MAGIC/XTENSION/WINFRAME.INF"
cp -ar "$SRC_DIR/kernel/winframe/themes/." "$RESOURCES_DIR/rootfs-common/GEMSYS/MAGIC/XTENSION/THEMES"
cp -a "$SRC_DIR/tools/addmem/addmem.prg" "$RESOURCES_DIR/rootfs-common/EXTRAS/ADDMEM.PRG"
cp -a "$SRC_DIR/tools/misc_tst/adr.prg" "$RESOURCES_DIR/rootfs-common/EXTRAS/BIN/ADR.PRG"
cp -a "$SRC_DIR/tools/misc_tst/il0008.prg" "$RESOURCES_DIR/rootfs-common/EXTRAS/BIN/IL0008.PRG"
cp -a "$SRC_DIR/tools/misc_tst/il4afc.prg" "$RESOURCES_DIR/rootfs-common/EXTRAS/BIN/IL4AFC.PRG"
cp -a "$SRC_DIR/tools/misc_tst/ilf000.prg" "$RESOURCES_DIR/rootfs-common/EXTRAS/BIN/ILF000.PRG"
cp -a "$SRC_DIR/tools/misc_tst/priv_rte.prg" "$RESOURCES_DIR/rootfs-common/EXTRAS/BIN/PRIV_RTE.PRG"
cp -a "$SRC_DIR/tools/misc_tst/priv_sr.prg" "$RESOURCES_DIR/rootfs-common/EXTRAS/BIN/PRIV_SR.PRG"
cp -a "$SRC_DIR/tools/misc_tst/trap7.prg" "$RESOURCES_DIR/rootfs-common/EXTRAS/BIN/TRAP7.PRG"
cp -a "$SRC_DIR/extensio/romdrvr/romdrvr.prg" "$RESOURCES_DIR/rootfs-common/EXTRAS/ROMDRVR.PRG"
cp -a "$SRC_DIR/kernel/bios/atari/boot/magxboot.prg" "$RESOURCES_DIR/rootfs-common/EXTRAS/MAGXBOOT.PRG"
cp -a "$SRC_DIR/kernel/bios/atari/boot/magxbo32.prg" "$RESOURCES_DIR/rootfs-common/EXTRAS/MAGXBO32.PRG"
cp -a "$SRC_DIR/tools/hardcopy/hardcopy.prg" "$RESOURCES_DIR/rootfs-common/EXTRAS/HARDCOPY.PRG"
cp -a "$SRC_DIR/tools/flock_ok/flock_ok.prg" "$RESOURCES_DIR/rootfs-common/EXTRAS/FLOCK_OK/FLOCK_OK.PRG"
cp -a "$SRC_DIR/tools/flock_ok/flock_ok.eng" "$RESOURCES_DIR/rootfs-common/EXTRAS/FLOCK_OK/FLOCK_OK.ENG"
cp -a "$SRC_DIR/tools/flock_ok/flock_ok.txt" "$RESOURCES_DIR/rootfs-common/EXTRAS/FLOCK_OK/FLOCK_OK.TXT"
cp -a "$SRC_DIR/tools/aes_lupe/aes_lupe.app" "$RESOURCES_DIR/rootfs-common/EXTRAS/AES_LUPE/AES_LUPE.APP"
cp -a "$SRC_DIR/tools/aes_lupe/aes_lupe.img" "$RESOURCES_DIR/rootfs-common/EXTRAS/AES_LUPE/AES_LUPE.IMG"
cp -a "$SRC_DIR/tools/aes_lupe/aes_lupe.txt" "$RESOURCES_DIR/rootfs-common/EXTRAS/AES_LUPE/AES_LUPE.TXT"
cp -a "$SRC_DIR/tools/clock/clock.app" "$RESOURCES_DIR/rootfs-common/EXTRAS/CLOCK/CLOCK.APP"
cp -a "$SRC_DIR/tools/clock/clock.gen" "$RESOURCES_DIR/rootfs-common/EXTRAS/CLOCK/CLOCK.GEN"
cp -a "$SRC_DIR/tools/clock/clock.inf" "$RESOURCES_DIR/rootfs-common/EXTRAS/CLOCK/CLOCK.INF"
cp -a "$SRC_DIR/tools/clock/clock.man" "$RESOURCES_DIR/rootfs-common/EXTRAS/CLOCK/CLOCK.MAN"
cp -a "$SRC_DIR/tools/clock/clock.mup" "$RESOURCES_DIR/rootfs-common/EXTRAS/CLOCK/CLOCK.MUP"
cp -a "$SRC_DIR/tools/clock/clockcol.cpx" "$RESOURCES_DIR/rootfs-common/EXTRAS/CLOCK/CLOCKCOL.CPX"
cp -a "$SRC_DIR/tools/clock/maus.ruf" "$RESOURCES_DIR/rootfs-common/EXTRAS/CLOCK/MAUS.RUF"
cp -a "$SRC_DIR/tools/clock/readme.cat" "$RESOURCES_DIR/rootfs-common/EXTRAS/CLOCK/README.CAT"
cp -a "$SRC_DIR/doc/usage/magx.inf" "$RESOURCES_DIR/rootfs-common/EXTRAS/MAGX.INF"
cp -a "$SRC_DIR/apps/instmagc/magx.inf" "$RESOURCES_DIR/rootfs-common/MAGX.INF"

for f in "$SRC_DIR/kernel/vdi/drivers/"*.sys "$SRC_DIR/kernel/vdi/drivers/"*.osd; do
	cp -a "$f" "$RESOURCES_DIR/rootfs-common/GEMSYS/$(upper $(basename $f))"
done
