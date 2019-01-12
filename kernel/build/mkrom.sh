#!/bin/sh
for i in magic.rom en/magic.rom fr/magic.rom; do
	header=`dd if=$i bs=1 count=2 status=none | od -t x1 | head -1`
	if test "$header" = "0000000 60 24"; then
		echo "stripping header from $i"
		dd if="$i" of=magic.r1 bs=1 skip=38
		dd if=magic.r1 of=magic.r2 bs=524288 conv=sync
		mv magic.r2 "$i"
		rm magic.r1
	elif test -f "$i"; then
		echo "skipping $i"
	fi
done
