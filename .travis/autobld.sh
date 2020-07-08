#!mupfel

#
# a mupfel script, executed inside ARAnyM
#

set -e

cd C:\src\magicmac
export PATH="${PWD}\pc,${PATH}"
echo "%033v%c"

ERRFILE="C:\src\magicmac\pcerr.txt"
rm -f "$ERRFILE"

pcmake -B -F tools/all.prj >> "$ERRFILE"
pcmake -B -F test/all.prj >> "$ERRFILE"
pcmake -B -F apps/all.prj >> "$ERRFILE"
pcmake -B -F extensio/all.prj >> "$ERRFILE"

#
# pdlg currently has to be build separately, because
# we need different localizations for it
#
cd extensio\pdlg_slb
# english
export PCCFLAGS=-DCOUNTRY=0
pcmake -B -F pdlg_slb.prj >> "$ERRFILE"
mv pdlg.slb en
# french
export PCCFLAGS=-DCOUNTRY=2
pcmake -B -F pdlg_slb.prj >> "$ERRFILE"
mv pdlg.slb fr
# german
export PCCFLAGS=-DCOUNTRY=1
pcmake -B -F pdlg_slb.prj >> "$ERRFILE"
mv pdlg.slb de
unset PCCFLAGS

cd ..\..

#
# now wdialog
#
cd kernel\aes\wdialog

# english
export PCCFLAGS=-DCOUNTRY=0
pcmake -B -F wdialog.prj >> "$ERRFILE"
mv wdialog.prg en

# french
export PCCFLAGS=-DCOUNTRY=2
pcmake -B -F wdialog.prj >> "$ERRFILE"
mv wdialog.prg fr

# german
export PCCFLAGS=-DCOUNTRY=1
pcmake -B -F wdialog.prj >> "$ERRFILE"
mv wdialog.prg de

unset PCCFLAGS

cd ..\..\..

cd kernel

pcmake -B -F vdi/drivers/all.prj >> "$ERRFILE"
pcmake -B -F winframe/winframe.prj >> "$ERRFILE"
pcmake -B -F bios/atari/boot/all.prj >> "$ERRFILE"
pcmake -B -F bios/atari/boot/ct60new.prj >> "$ERRFILE"

#
# now the kernels
#
cd build

# english
export PCCFLAGS=-DCOUNTRY=0
pcmake -B -F magcmacx.prj >> "$ERRFILE"
mv magcmacx.os en
pcmake -B -F magicmac.prj >> "$ERRFILE"
mv mag_mac.ram en
pcmake -B -F atari.prj >> "$ERRFILE"
mv magic.ram en
pcmake -B -F hades.prj >> "$ERRFILE"
mv mhades.ram en
pcmake -B -F milan.prj >> "$ERRFILE"
mv mmilan.ram en

# french
export PCCFLAGS=-DCOUNTRY=2
pcmake -B -F magcmacx.prj >> "$ERRFILE"
mv magcmacx.os fr
pcmake -B -F magicmac.prj >> "$ERRFILE"
mv mag_mac.ram fr
pcmake -B -F atari.prj >> "$ERRFILE"
mv magic.ram fr
pcmake -B -F hades.prj >> "$ERRFILE"
mv mhades.ram fr
pcmake -B -F milan.prj >> "$ERRFILE"
mv mmilan.ram fr

# german
export PCCFLAGS=-DCOUNTRY=1
pcmake -B -F magcmacx.prj >> "$ERRFILE"
mv magcmacx.os de
pcmake -B -F magicmac.prj >> "$ERRFILE"
mv mag_mac.ram de
pcmake -B -F atari.prj >> "$ERRFILE"
mv magic.ram de
pcmake -B -F hades.prj >> "$ERRFILE"
mv mhades.ram de
pcmake -B -F milan.prj >> "$ERRFILE"
mv mmilan.ram de

unset PCCFLAGS

cd ..\..

set +e
