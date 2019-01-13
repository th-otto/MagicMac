Note about MAGXBOOT.PRG for CT60
--------------------------------
This MAGXBOOT.PRG has been rewritten to support normal mode (68030) and
turbo mode (68060), and in turbo mode MAGIC.RAM has been patched to not
overwrite some parts of TOS such as FPU emulation, etc... You must install
this program in the AUTO folder. Tested with MagiC 6.10 and 6.20.
You must use the Centek MAGIC.RAM patch (with MAGIC_P.PRG) before using
MagiC. 

You also need to install CT60XBIO.PRG and DSPXBIOS.PRG in the AUTO 
folder. 

For more information:
aniplay@wanadoo.fr
