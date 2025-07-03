#!/bin/sh

#
# This script uses a pre-build image for ARAnyM,
# where Pure-C, GEMINI and a few other tools are installed,
# a custom pcmake tool to build a Pure-C project file from the
# command line, and mtools to access the image
#

export BUILDROOT="${SCRIPT_DIR}/tmp"
export OUT="${SCRIPT_DIR}/out"
echo "BUILDROOT=$BUILDROOT" >> $GITHUB_ENV 
echo "OUT=$OUT" >> $GITHUB_ENV

mkdir -p "${BUILDROOT}"
mkdir -p "${OUT}"

aranym="${SCRIPT_DIR}/aranym"
aranym="$aranym/usr/bin/aranym"

unset CC CXX

SRCDIR=c:/src/magicmac

clash_option="-D s"
mmd $clash_option $SRCDIR
mcopy $clash_option -so apps auto doc extensio inc_as inc_c kernel lib non-tos pc test tools $SRCDIR
mcopy $clash_option "C:/pc/lib/*.lib" $SRCDIR/pc/lib
mcopy $clash_option "C:/pc/lib/*.o" $SRCDIR/pc/lib

export SDL_VIDEODRIVER=dummy
export SDL_AUDIODRIVER=dummy

mdel C:/status.txt
mcopy -o ${SCRIPT_DIR}/autobld.sh C:/autobld.sh
"$aranym" -c config-hdd
echo ""
echo "##################################"
echo "error output from emulator run:"
echo "##################################"
mtype C:/errors.txt | grep -v ": entering directory" | grep -v ": processing "
echo ""
status=`mtype -t C:/status.txt`
mtype "$SRCDIR/pcerr.txt" | grep -F "Error 
Fatal 
Warning "
echo ""
test "$status" != "0" && exit 1

UDO=~/tmp/udo/udo
export UDO
HCP=~/tmp/hcp/bin/hcp
export HCP

make -C apps/magiccfg/doc

. ${SCRIPT_DIR}/mkbindist.sh


isrelease=false
export isrelease

VERSION=`date +%Y%m%d-%H%M%S`
ATAG=${VERSION}
BINARCHIVE="${PROJECT_LOWER}-${ATAG}-bin.zip"
SRCARCHIVE="${PROJECT_LOWER}-${ATAG}-src.zip"

export BINARCHIVE
export SRCARCHIVE
echo "BINARCHIVE=$BINARCHIVE" >> $GITHUB_ENV
echo "SRCARCHIVE=$SRCARCHIVE" >> $GITHUB_ENV


(
cd "${BUILDROOT}"
zip -r "${OUT}/${BINARCHIVE}" .
)
git archive --format=zip --prefix=${PROJECT_LOWER}/ HEAD > "${OUT}/${SRCARCHIVE}"
ls -l "${OUT}"
