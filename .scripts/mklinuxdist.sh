#!/bin/sh

set -e

srcdir="$PWD"

for lang in $LANGUAGES; do

	cd "$BUILDROOT/$lang"

	cp "$srcdir/auto/autoexec.bat" AUTO/AUTOEXEC.BAT
	cp "$srcdir/apps/instmagc/autoexec.bat" AUTOEXEC.BAT

	cp "$srcdir/apps/instmagc/magx_lin.inf" MAGX.INF

	find . -depth | while read i; do
		test "$i" = "." && continue
		f=`basename $i`
		d=`dirname $i`
		f="$d/"`basename $i | tr '[[:lower:]]' '[[:upper:]]'`
		test "$f" = "$i" && continue
		mv "$i" "$d/xxxx$$"; mv "$d/xxxx$$" "$f"
	done

	mv AUTO/ACCS/CPX/MAGXCONF.CPX AUTO/ACCS/CPX/MAGXCONF.CPZ
	rm -f AUTO/ACCS/CPX/NCACHE.CPX
	rm -f AUTO/ACCS/CPX/NPRNCONF.CPX
	rm -f AUTO/ACCS/CPX/MODEM.CPX
	rm -f AUTO/ACCS/CPX/PRINTER.CPX
	mv AUTO/ACCS/CPZ/SET_FLG.CPZ AUTO/ACCS/CPX/SET_FLG.CPX
	rm -f AUTO/ACCS/CPX/TTSOUND.CPX
	rm -f AUTO/MAGXBOOT.PRG

	rm -f *.RAM
	rm -f MAGCMACX.OS
	rm -f MAGIC_PC.OS
	
	rm -f EXTRAS/CT60.TXT
	rm -f EXTRAS/CT60BOOT.PRG
	rm -f EXTRAS/MAGIC_P.TOS
	rm -f EXTRAS/MAGXBO32.PRG
	rm -f EXTRAS/MAGXBOOT.PRG
	rm -f EXTRAS/MAGXMILA.PRG
	rm -f EXTRAS/ROMDRVR.PRG
	rm -f EXTRAS/WDIALOG/WDIALOG.PRG
	rmdir EXTRAS/WDIALOG
	rm -f GEMSYS/MAGIC/START/MMXDAEMN.PR?

	cd ..

	mv $lang Atari-rootfs

	zip -r "$OUT/magiconlinux-${ATAG}-$lang.zip" Atari-rootfs

	rm -rf Atari-rootfs

done

cd "$srcdir"

set +e
