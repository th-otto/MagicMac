		    .offset 0
vgainf_magic:       ds.b 8     /* 0: 'NVDIVGA' */
                    ds.b 24
                    ds.w 1     /* 32 */
vgainf_nummodes:    ds.w 1     /* 34 */ ; number of modes in file
                    ds.w 1     /* 36 */
vgainf_defmode:     ds.w 10    /* 38 */ ; default mode numbers
                    ds.w 1     /* 58 */
                    ds.w 1     /* 60 */
                    ds.w 1     /* 62 */
                    ds.w 1     /* 64 */
                    ds.w 1     /* 66 */
vgainf_modes:                  /* 68 */ ; list of mode offsets/ptrs

		    .offset 0

vga_next:           ds.l 1     /* 0 */  ; offset/ptr to next mode
vgainf_length:      ds.w 1     /* 4 */  ; maximum length of this structure, including variable fields
vga_modename:       ds.l 1     /* 6 */  ; offset/ptr to user defined modename
vga_xres:           ds.w 1     /* 10 */ ; Maximum addressable width
vga_yres:           ds.w 1     /* 12 */ ; Maximum addressable height
vga_visible_xres:   ds.w 1     /* 14 */ ; Maximum addressable visible width
vga_visible_yres:   ds.w 1     /* 16 */ ; Maximum addressable visible height
vga_pixw:           ds.w 1     /* 18 */ ; Pixel width in microns
vga_pixh:           ds.w 1     /* 20 */ ; Pixel height in microns
vga_planes:         ds.w 1     /* 22 */ ; Number of planes
vga_colors:         ds.l 1     /* 24 */ ; Number of colors
vga_line_width:     ds.w 1     /* 28 */ ; bytes per scanline
vga_membase:        ds.l 1     /* 30 */ ; base address of video RAM
vga_regbase:        ds.l 1     /* 34 */ ; base address of VGA registers
vga_dac_type:       ds.w 1     /* 38 */ ; 0=8bit; 1=6bit
vga_synth:          ds.w 1     /* 40 */ ; 006c
vga_hfreq:          ds.w 1     /* 42 */ ; horizontal frequency * 10 (Khz)
vga_vfreq:          ds.w 1     /* 44 */ ; vertical frequency * 10 (Hz)
vga_pfreq:          ds.l 1     /* 46 */ ; pixel frequency * 1000000 (Mhz)
                    ds.w 1     /* 50 */
                    ds.w 1     /* 52 */
                    ds.w 1     /* 54 */
                    ds.w 1     /* 56 */
                    ds.w 1     /* 58 */
                    ds.w 1     /* 60 */
                    ds.w 1     /* 62 */
                    ds.w 1     /* 64 */
                    ds.w 1     /* 66 */
                    ds.w 1     /* 68 */
                    ds.w 1     /* 70 */
                    ds.w 1     /* 72 */
                    ds.w 1     /* 74 */
                    ds.w 1     /* 76 */
                    ds.w 1     /* 78 */
                    ds.b 1     /* 80 */
vga_PEL2:           ds.b 1     /* 81 */ ; value for DAC_PEL
vga_PEL:            ds.b 1     /* 82 */ ; value for DAC_PEL
vga_MISC_W:         ds.b 1     /* 83 */ ; value for MISC_W (0xe3)
vga_ts_regs:        ds.l 1     /* 84 */ ; offset/ptr to TS register values   ; 00AC
vga_crtc_regs:      ds.l 1     /* 88 */ ; offset/ptr to CRTC register values ; 00b6
vga_atc_regs:       ds.l 1     /* 92 */ ; offset/ptr to ATC register values  ; 00f8
vga_gdc_regs:       ds.l 1     /* 96 */ ; offset/ptr to GDC register values  ; 0112

VGA_MODESIZE equ $268          /* size needed for a mode + all register values */


VGA_PIXW equ 265
VGA_PIXH equ 265

TOS_PIXW equ 278
TOS_PIXH equ 278



GC_VOLKSFARBEN      equ 0
GC_GENGTEC_VGA      equ 0
GC_CRAZY_DOTS_MST   equ 0
GC_CRAZY_DOTS_VME   equ 0
GC_CRAZY_DOTS_II    equ 0
GC_SPEKTRUM_1       equ 0
GC_SPEKTRUM_HC      equ 0
GC_SPEKTRUM_TC      equ 0
GC_MEDUSA           equ 0
GC_MEGA_4000        equ 0
