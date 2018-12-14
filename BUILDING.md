# Changes compared to original version

Major changes include

* Restructuring of most directories, to keep pathnames short
(Pure-C does not like too long pathnames very much)

* Converting source files to CR/LF line endings, where that was not already
the case (again, mainly for Pure-C)

* Converting UTF-8 input to ASCII. German umlauts in comments
are converted to ae, ue etc, while characters in messages were
converted to their hexadecimal equivalents. This was needed to be
able to compile the sources just after checking out, without having
to convert them every time.

* Disassembling of mxvdiknl.o into source file. In the meantime, the
original source was uploaded to the upstream archive, but the version
there is slightly different than the object, and does not work with the
VDI drivers.

* Sources for some CPX control modules were added

* Some constants were moved to separate files, and included where needed.
This was mainly done because some EQUs that were exported could not be
linked to elsewhere.

* Sources for PDLG.SLB were added.

* Sources to build WDIALOG.PRG were added.

* Sources for CHGRES.PRG were added.

* binary files that can be rebuild were removed

* Some bug fixes. Take a look at the commit history.


# Prerequisites for building

Most applications and the kernel can only be build with Pure-C V 1.1.

Most headers and libraries are provided in this repository, except for

* pc.prg (has to be copied to the top-level pc directory)
* pasm.ttp (has to be copied to the top-level pc directory)
* plink.ttp (has to be copied to the top-level pc directory)
* pcstdlib.lib (has to be copied to the top-level pc/lib directory)
* pcfltlib.lib (has to be copied to the top-level pc/lib directory)


# Preparation

* Copy the binaries mentioned above to their appropriate locations.

* Enter the pc/pctoslib directory, and compile the TOS library.
This will replace the pc/lib/pctoslib library, adding all MiNT/MagiC functions.
Be sure to use that library only with the supplied headers, since it is not 100%
compatible to the one shipped with Pure-C, but instead should be source-compatible
to mintlib.

* Enter the pc/pcgemlib directory, and compile the GEM library.
This will replace the pc/lib/pcgemlib library, adding all MiNT/MagiC functions.
Be sure to use that library only with the supplied headers, since it is not 100%
compatible to the one shipped with Pure-C, but instead should be source-compatible
to gemlib.


# Building the Kernel

Project files for the various kernels are found in the kernel/build directory.

* magcmagx.prj: to build the kernel needed for MagicMacX/AtariX

* magicmac.prj: to build the kernel needed for older MagicMac (only for
68k/ppc computers)

* atari.prj: to build the kernel (magic.ram) for Atari hardware.

* hades.prj: to build the kernel for Hades hardware.

* milan.prj: to build the kernel for Milan hardware.

Other project files you might need:

* [kernel/vdi/drivers/all.prj](kernel/vdi/drivers/all.prj): to build all the MVDI drivers

* kernel/aes/wdialog/wdialog.prj: to build WDIALOG.PRG


# Building the applications

Each application has its own subdirectory and project file in the
toplevel [apps](apps) directory. Note that in almost all cases, the resource file
(if any) in that directory is the german version.
