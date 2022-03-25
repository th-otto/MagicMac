#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>
#include <errno.h>

typedef unsigned char belong[4];
typedef unsigned char beshort[2];


struct vgainf_mode {
	belong vga_next;              /* offset/ptr to next mode */
	beshort vgainf_length;        /* maximum length of this structure, including variable fields */
	belong vga_modename;          /* offset/ptr to user defined modename */
	beshort vga_xres;             /* Maximum addressable width */
	beshort vga_yres;             /* Maximum addressable height */
	beshort vga_visible_xres;     /* Maximum addressable visible width */
	beshort vga_visible_yres;     /* Maximum addressable visible height */
	beshort vga_pixw;             /* Pixel width in microns */
	beshort vga_pixh;             /* Pixel height in microns */
	beshort vga_planes;           /* Number of planes */
	belong vga_colors;            /* Number of colors */
	beshort vga_line_width;       /* bytes per scanline */
	belong vga_membase;           /* base address of video RAM */
	belong vga_regbase;           /* base address of VGA registers */
	beshort vga_dac_type;         /* 0=8bit; 1=6bit */
	beshort vga_synth;
	beshort vga_hfreq;            /* horizontal frequency * 10 (Khz) */
	beshort vga_vfreq;            /* vertical frequency * 10 (Hz) */
	belong vga_pfreq;             /* pixel frequency * 1000000 (Mhz) */
	beshort o50;
	beshort o52;
	beshort o54;
	beshort o56;
	beshort o58;
	beshort o60;
	beshort o62;
	beshort o64;
	beshort o66;
	beshort o68;
	beshort o70;
	beshort o72;
	beshort o74;
	beshort o76;
	beshort o78;
	unsigned char o80;
	unsigned char o81;
	unsigned char vga_PEL;        /* value for DAC_PEL */
	unsigned char vga_misc_W;     /* value for MISC_W (0xe3) */
	belong vga_ts_regs;           /* offset/ptr to TS register values */
	belong vga_crtc_regs;         /* offset/ptr to CRTC register values */
	belong vga_atc_regs;          /* offset/ptr to ATC register values */
	belong vga_gdc_regs;          /* offset/ptr to GDC register values */
};

struct vgainf {
	char vgainf_magic[8];               /* "NVDIVGA" */
	beshort o8;
	beshort o10;
	beshort o12;
	beshort o14;
	beshort o16;
	beshort o18;
	beshort o20;
	beshort o22;
	beshort o24;
	beshort o26;
	beshort o28;
	beshort o30;
	beshort o32;
	beshort vgainf_nummodes;              /* number of modes in file */
	beshort o36;
	beshort vgainf_defmode[10];           /* default mode numbers */
	beshort o58;
	beshort o60;
	beshort o62;
	beshort o64;
	beshort o66;
};


static uint16_t getbeshort(beshort s)
{
	return (s[0] << 8) | s[1];
}


static uint32_t getbelong(belong s)
{
	return ((uint32_t)s[0] << 24) | ((uint32_t)s[1] << 16) | ((uint32_t)s[2] << 8) | ((uint32_t)s[3]);
}


int main(int argc, char **argv)
{
	const char *filename;
	FILE *fp;
	struct vgainf inf;
	uint32_t val;
	uint16_t nummodes;
	long pos;
	struct vgainf_mode mode;
	uint32_t next;
	char modename[128];
	beshort regcount;
	uint16_t i, count;
	
	if (argc < 2)
	{
		fprintf(stderr, "usage: dumpvga <file>\n");
		return 1;
	}
	filename = argv[1];
	fp = fopen(filename, "rb");
	if (fp == NULL)
	{
		fprintf(stderr, "%s: %s\n", filename, strerror(errno));
		return 1;
	}
	fread(&inf, 1, sizeof(inf), fp);
	
	printf("magic:           %-.8s\n", inf.vgainf_magic);
	val = getbeshort(inf.o8);
	printf("8:               $%04x %u\n", val, val);
	val = getbeshort(inf.o10);
	printf("10:              $%04x %u\n", val, val);
	val = getbeshort(inf.o12);
	printf("12:              $%04x %u\n", val, val);
	val = getbeshort(inf.o14);
	printf("14:              $%04x %u\n", val, val);
	val = getbeshort(inf.o16);
	printf("16:              $%04x %u\n", val, val);
	val = getbeshort(inf.o18);
	printf("18:              $%04x %u\n", val, val);
	val = getbeshort(inf.o20);
	printf("20:              $%04x %u\n", val, val);
	val = getbeshort(inf.o22);
	printf("22:              $%04x %u\n", val, val);
	val = getbeshort(inf.o24);
	printf("24:              $%04x %u\n", val, val);
	val = getbeshort(inf.o26);
	printf("26:              $%04x %u\n", val, val);
	val = getbeshort(inf.o28);
	printf("28:              $%04x %u\n", val, val);
	val = getbeshort(inf.o30);
	printf("30:              $%04x %u\n", val, val);
	val = getbeshort(inf.o32);
	printf("32:              $%04x %u\n", val, val);
	val = getbeshort(inf.vgainf_nummodes);
	nummodes = val;
	printf("nummodes:        $%04x %u\n", val, val);
	val = getbeshort(inf.o36);
	printf("36:              $%04x %d\n", val, (int16_t)val);

	val = getbeshort(inf.vgainf_defmode[0]);
	printf("defmode[0]:      $%04x %d\n", val, (int16_t)val);
	val = getbeshort(inf.vgainf_defmode[1]);
	printf("defmode[1]:      $%04x %d\n", val, (int16_t)val);
	val = getbeshort(inf.vgainf_defmode[2]);
	printf("defmode[2]:      $%04x %d\n", val, (int16_t)val);
	val = getbeshort(inf.vgainf_defmode[3]);
	printf("defmode[3]:      $%04x %d\n", val, (int16_t)val);
	val = getbeshort(inf.vgainf_defmode[4]);
	printf("defmode[4]:      $%04x %d\n", val, (int16_t)val);
	val = getbeshort(inf.vgainf_defmode[5]);
	printf("defmode[5]:      $%04x %d\n", val, (int16_t)val);
	val = getbeshort(inf.vgainf_defmode[6]);
	printf("defmode[6]:      $%04x %d\n", val, (int16_t)val);
	val = getbeshort(inf.vgainf_defmode[7]);
	printf("defmode[7]:      $%04x %d\n", val, (int16_t)val);
	val = getbeshort(inf.vgainf_defmode[8]);
	printf("defmode[8]:      $%04x %d\n", val, (int16_t)val);
	val = getbeshort(inf.vgainf_defmode[9]);
	printf("defmode[9]:      $%04x %d\n", val, (int16_t)val);

	val = getbeshort(inf.o58);
	printf("58:              $%04x %u\n", val, val);
	val = getbeshort(inf.o60);
	printf("60:              $%04x %u\n", val, val);
	val = getbeshort(inf.o62);
	printf("62:              $%04x %u\n", val, val);
	val = getbeshort(inf.o64);
	printf("64:              $%04x %u\n", val, val);
	val = getbeshort(inf.o66);
	printf("66:              $%04x %u\n", val, val);
	
	printf("\nmodes:\n");
	while (nummodes > 0)
	{
		pos = ftell(fp);
		fread(&mode, 1, sizeof(mode), fp);
		
		next = getbelong(mode.vga_next);
		printf("next:            $%08x\n", next);
		val = getbeshort(mode.vgainf_length);
		printf("length:          $%04x %u\n", val, val);
		val = getbelong(mode.vga_modename);
		fseek(fp, pos + val, SEEK_SET);
		fread(modename, 1, sizeof(modename), fp);
		modename[sizeof(modename) - 1] = '\0';
		printf("name:            %s\n", modename);
		val = getbeshort(mode.vga_xres);
		printf("xres:            $%04x %u\n", val, val);
		val = getbeshort(mode.vga_yres);
		printf("yres:            $%04x %u\n", val, val);
		val = getbeshort(mode.vga_visible_xres);
		printf("visible xres:    $%04x %u\n", val, val);
		val = getbeshort(mode.vga_visible_yres);
		printf("visible yres:    $%04x %u\n", val, val);
		val = getbeshort(mode.vga_pixw);
		printf("pixw:            $%04x %u\n", val, val);
		val = getbeshort(mode.vga_pixh);
		printf("pixh:            $%04x %u\n", val, val);
		val = getbeshort(mode.vga_planes);
		printf("planes:          $%04x %u\n", val, val);
		val = getbelong(mode.vga_colors);
		printf("colors:          $%08x %u\n", val, val);
		val = getbeshort(mode.vga_line_width);
		printf("line width:      $%04x %u\n", val, val);
		val = getbelong(mode.vga_membase);
		printf("membase:         $%08x\n", val);
		val = getbelong(mode.vga_regbase);
		printf("regbase:         $%08x\n", val);
		val = getbeshort(mode.vga_dac_type);
		printf("dac type:        %u\n", val);
		val = getbeshort(mode.vga_synth);
		printf("synth:           $%04x %u\n", val, val);
		val = getbeshort(mode.vga_hfreq);
		printf("hfreq:           %u.%u kHz\n", val / 10, val % 10);
		val = getbeshort(mode.vga_vfreq);
		printf("vfreq:           %u.%u Hz\n", val / 10, val % 10);
		val = getbelong(mode.vga_pfreq);
		printf("pfreq:           %u.%06u MHz\n", val / 1000000, val % 1000000);
		val = getbeshort(mode.o50);
		printf("50:              $%04x %u\n", val, val);
		val = getbeshort(mode.o52);
		printf("52:              $%04x %u\n", val, val);
		val = getbeshort(mode.o54);
		printf("54:              $%04x %u\n", val, val);
		val = getbeshort(mode.o56);
		printf("56:              $%04x %u\n", val, val);
		val = getbeshort(mode.o58);
		printf("58:              $%04x %u\n", val, val);
		val = getbeshort(mode.o60);
		printf("60:              $%04x %u\n", val, val);
		val = getbeshort(mode.o62);
		printf("62:              $%04x %u\n", val, val);
		val = getbeshort(mode.o64);
		printf("64:              $%04x %u\n", val, val);
		val = getbeshort(mode.o66);
		printf("66:              $%04x %u\n", val, val);
		val = getbeshort(mode.o68);
		printf("68:              $%04x %u\n", val, val);
		val = getbeshort(mode.o70);
		printf("70:              $%04x %u\n", val, val);
		val = getbeshort(mode.o72);
		printf("72:              $%04x %u\n", val, val);
		val = getbeshort(mode.o74);
		printf("74:              $%04x %u\n", val, val);
		val = getbeshort(mode.o76);
		printf("76:              $%04x %u\n", val, val);
		val = getbeshort(mode.o78);
		printf("78:              $%04x %u\n", val, val);
		printf("80:              $%02x %u\n", mode.o80, mode.o80);
		printf("81:              $%02x %u\n", mode.o81, mode.o81);
		printf("PEL:             $%02x\n", mode.vga_PEL);
		printf("MISC_W:          $%02x\n", mode.vga_misc_W);
		
		val = getbelong(mode.vga_ts_regs);
		fseek(fp, pos + val, SEEK_SET);
		fread(regcount, 1, sizeof(regcount), fp);
		count = getbeshort(regcount);
		printf("TS regs (%2d):   ", count);
		for (i = 0; i < count; )
		{
			printf(" %02x", fgetc(fp));
			++i;
			if ((i % 16) == 0 && i < count)
				printf("\n                ");
		}
		printf("\n");

		val = getbelong(mode.vga_crtc_regs);
		fseek(fp, pos + val, SEEK_SET);
		fread(regcount, 1, sizeof(regcount), fp);
		count = getbeshort(regcount);
		printf("CRTC regs (%2d): ", count);
		for (i = 0; i < count; )
		{
			printf(" %02x", fgetc(fp));
			++i;
			if ((i % 16) == 0 && i < count)
				printf("\n                ");
		}
		printf("\n");

		val = getbelong(mode.vga_atc_regs);
		fseek(fp, pos + val, SEEK_SET);
		fread(regcount, 1, sizeof(regcount), fp);
		count = getbeshort(regcount);
		printf("ATC regs (%2d):  ", count);
		for (i = 0; i < count; )
		{
			printf(" %02x", fgetc(fp));
			++i;
			if ((i % 16) == 0 && i < count)
				printf("\n                ");
		}
		printf("\n");

		val = getbelong(mode.vga_gdc_regs);
		fseek(fp, pos + val, SEEK_SET);
		fread(regcount, 1, sizeof(regcount), fp);
		count = getbeshort(regcount);
		printf("GDC regs (%2d):  ", count);
		for (i = 0; i < count; )
		{
			printf(" %02x", fgetc(fp));
			++i;
			if ((i % 16) == 0 && i < count)
				printf("\n                ");
		}
		printf("\n");

		if (next == (uint32_t)-1)
			break;
		
		fseek(fp, pos + next, SEEK_SET);
		
		nummodes--;
		printf("\n");
	}
	
	fclose(fp);
	
	return 0;
}
