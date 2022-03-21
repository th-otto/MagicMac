struct vgainf_mode {
	struct vgainf_mode *vga_next;       /* offset/ptr to next mode */
	unsigned short vgainf_length;       /* maximum length of this structure, including variable fields */
	char *vga_modename;                 /* offset/ptr to user defined modename */
	short vga_xres;                     /* Maximum addressable width */
	short vga_yres;                     /* Maximum addressable height */
	short vga_visible_xres;             /* Maximum addressable visible width */
	short vga_visible_yres;             /* Maximum addressable visible height */
	short vga_pixw;                     /* Pixel width in microns */
	short vga_pixh;                     /* Pixel height in microns */
	short vga_planes;                   /* Number of planes */
	short o24;
	short o26;
	short vga_line_width;               /* bytes per scanline */
	void *vga_membase;                  /* base address of video RAM */
	void *vga_regbase;                  /* base address of VGA registers */
	short vga_dac_type;                 /* 0=8bit; 1=6bit */
	short vga_colors;
	short o42;
	unsigned short vga_vfreq;           /* vertical frequency * 10 */
	short o46;
	short o48;
	short o50;
	short o52;
	short o54;
	short o56;
	short o58;
	short o60;
	short o62;
	short o64;
	short o66;
	short o68;
	short o70;
	short o72;
	short o74;
	short o76;
	short o78;
	unsigned char o80;
	unsigned char vga_PEL2;             /* value for DAC_PEL */
	unsigned char vga_PEL;              /* value for DAC_PEL */
	unsigned char vga_misc_W;           /* value for MISC_W (0xe3) */
	unsigned char *vga_ts_regs;         /* offset/ptr to TS register values */
	unsigned char *vga_crtc_regs;       /* offset/ptr to CRTC register values */
	unsigned char *vga_atc_regs;        /* offset/ptr to ATC register values */
	unsigned char *vga_gdc_regs;        /* offset/ptr to GDC register values */
	
	unsigned char space[150];
};

struct vgainf {
	char vgainf_magic[8];               /* "NVDIVGA" */
	char o8[24];
	short o32;
	short vgainf_nummodes;              /* number of modes in file */
	short o36;
	short vgainf_defmode[6];            /* default mode numbers */
	short o50;
	short o52;
	short o54;
	short o56;
	short o58;
	short o60;
	short o62;
	short o64;
	short o66;
};

/* size needed for a mode + all register values */
#define VGA_MODESIZE 0x268

struct nvdipcinf_mode {
	long length;
	short planes;
	short xres;
	short yres;
};

struct nvdipcinf {
	long length;
	long magic;               /* "NFPC" */
	long version;
	long nummodes;
	short defmode[16];
	struct nvdipcinf_mode modes[];
};

#define VGA_PIXW 265
#define VGA_PIXH 265

#define TOS_PIXW 278
#define TOS_PIXH 278
