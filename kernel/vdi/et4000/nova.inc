/* VGA index register ports */
CRTC_IM   equ 0x3B4   /* CRT Controller index port (monochrome) */
CRTC_IG   equ 0x3D4   /* CRT Controller index port (color) */
ATC_IW    equ 0x3C0   /* Attribute controller: index and data write */
GDC_I     equ 0x3CE   /* Graphics Controller Index */
TS_I      equ 0x3C4   /* Timing Sequencer index port */
DAC_IW    equ 0x3C8   /* RAMDAC PEL write index */
DAC_IR    equ 0x3C7   /* RAMDAC PEL read index */

/* VGA data register ports */
CRTC_DM   equ 0x3B5   /* CRT Controller data port (monochrome) */
CRTC_DG   equ 0x3D5   /* CRT Controller data port (color) */
ATT_R     equ 0x3C1   /* Attribute Controller Data Read Register */
GENMO     equ 0x3CC   /* Miscellaneous output read register */
GDC_SEG   equ 0x3CD   /* GDC segment select, index and data ports */
GDC_D     equ 0x3CF   /* Graphics Controller Data Register */
GENHP     equ 0x3BF   /* Herucles Page */
TS_D      equ 0x3C5   /* Timing Sequencer data port */
VIDSUB    equ 0x3C3   /* Video Subsystem register */
MISC_W    equ 0x3C2   /* Misc Output Write Register */
DAC_PEL   equ 0x3C6   /* RAMDAC pixel mask */
DAC_D     equ 0x3C9   /* RAMDAC palette data */
IS1_RC    equ 0x3DA   /* Input Status Register 1: color emulation */
CGAMODE   equ 0x3D8   /* Display mode control */


VGA_MEMSIZE equ 0x100000
