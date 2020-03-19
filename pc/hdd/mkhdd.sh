#!/bin/sh

#
# semi-automatic script to generate harddisk image
# used for automatic builds
#
# needs several Atari tools (Pure-C, gemini, etc.)
# and some host tools (e.g. mtools)
#

PURE_C=/windows/c/atari/pc


force=false
test "$1" = --force && force=true

if ! mdir --version >/dev/null 2>&1; then
	echo "mtools not found; exiting" >&2
	exit 1
fi

export MTOOLSRC="$PWD/mtoolsrc"

image=$PWD/hdd.img
offset=0

if test -f "$image" && ! $force; then
	echo -n "$image already exists; overwrite? "
	read a
	test "$a" != "y" && exit 1
fi

echo "drive c: file=\"$image\" MTOOLS_SKIP_CHECK=1 MTOOLS_LOWER_CASE=1 MTOOLS_NO_VFAT=1 offset=$offset" > "$MTOOLSRC"

trap "rm -f $MTOOLSRC" 0 1 2 3 15

if ! test -f ../lib/pcgemlib.lib -o ! -f ../lib/cstartv.o; then
	echo "gem libraries and startup code for Pure-C must be compiled first" >&2
	exit 1
fi

mkdir -p pc/lib pc/include
mkdir -p src/magicmac/pc/lib

cp -pr ../include/. pc/include
cp -pr ../lib/*.s ../lib/*.o pc/lib
cp -pr ../lib/*.s ../lib/*.o src/magicmac/pc/lib

if ! test -d "$PURE_C"; then
	echo -n "Where are the Pure-C libraries? ($PURE_C) "
	read PURE_C
fi

if ! test -f "$PURE_C/lib/pcstdlib.lib"; then
	echo "Pure-C libraries not found; aborting" >&2
	exit 1
fi

#
# original libraries
#
for lib in pcstdlib.lib pcfltlib.lib pclnalib.lib pc881lib.lib pcextlib.lib; do
	cp -a "$PURE_C/lib/$lib" pc/lib || exit 1
	cp -a "$PURE_C/lib/$lib" src/magicmac/pc/lib || exit 1
done

#
# GEM & TOS libraries, built from our sources
#
for lib in pcgemlib.lib pctoslib.lib; do
	cp -a "../lib/$lib" pc/lib || exit 1
	cp -a "../lib/$lib" src/magicmac/pc/lib || exit 1
done

#
# original executables
#
for prg in cpp.ttp dispobj.ttp pasm.ttp pcc.ttp plink.ttp; do
	cp -a "$PURE_C/$prg" pc || exit 1
done

# our make tool; must be in the Pure-C directory
cp -a bin/pcmake.ttp pc
cp -a bin/pcmake.ttp src/magicmac/pc


#
# now generate image
#
dd if=/dev/zero of=$image count=488280
mformat -T 61035 -h 64 -s 32 -H 0 -S 5 c:

clash_option="-D s"

for file in autoexec.bat emudesk.inf mcmd.tos newdesk.inf gemini bin pc src; do
	mcopy $clash_option -bso $file C:/
done

echo "$image generated"

dd if=/dev/zero of=floppy.empty count=2880
mformat -t 80 -h 2 -s 18 -i "floppy.empty" ::

tar cvfj mag-hdd.tar.bz2 hdd.img config-hdd emutos-aranym.img floppy.empty

rm -f floppy.empty
