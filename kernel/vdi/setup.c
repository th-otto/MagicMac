#include <portab.h>
#include <tos.h>
#include <vdi.h>
#include "nvdi_wk.h"
#include "mxvdi.h"
#include "drivers.h"
#include "pixmap.h"	/* PixMap-Strukur */

/*----------------------------------------------------------------------------------------*/
/* Struktur fuer die Kompatibilitaet mit alten MM-Versionen								  */
/*----------------------------------------------------------------------------------------*/

typedef struct
{
	int32_t		magic;				/* ist 'MagC' */
	void		*syshdr;			/* Adresse des Atari-Syshdr */
	void		*keytabs;			/* 5*128 Bytes fuer Tastaturtabellen */
	int32_t		ver;				/* Version */
	int16_t		cpu; 				/* CPU (30=68030, 40=68040) */
	int16_t		fpu;				/* FPU (0=nix,4=68881,6=68882,8=68040) */
	void		*boot_sp; 			/* sp fuers Booten */
	void		*biosinit;			/* nach Initialisierung aufrufen */
	MXVDI_PIXMAP *pixmap;			/* Daten fuers VDI */
	void		*offs_32k;			/* Adressenoffset fuer erste 32k im MAC */
	void		*a5;				/* globales Register a5 fuer Mac-Programm */
	int32_t		tasksw;				/* != NULL, wenn Taskswitch erforderlich */
	void		*gettime;			/* Datum und Uhrzeit ermitteln */
	void		*bombs;				/* Atari-Routine, wird vom MAC aufgerufen */
	void		*syshalt;			/* "System halted", String in a0 */
	void		*coldboot;
	void		*debugout;			/* fuers Debugging */
	void		*prtis;				/* Fuer Drucker (PRT) */
	void		*prtos;
	void		*prtin;
	void		*prtout;
	void		*serconf;			/* Rsconf fuer ser1 */
	void		*seris;				/*  Fuer ser1 (AUX) */
	void		*seros;
	void		*serin;
	void		*serout;
	void		*xfs;				/* Routinen fuer das XFS */
	void		*xfs_dev;			/* Zugehoeriger Dateitreiber */
	void		*set_physbase;		/* Bildschirmadresse bei Setscreen umsetzen (a0 zeigt auf den Stack von Setscreen()) */
	void		*VsetRGB;			/* Farbe setzen (a0 zeigt auf den Stack bei VsetRGB()) */
	void		*VgetRGB;			/* Farbe erfragen (a0 zeigt auf den Stack bei VgetRGB()) */
	VDI_SETUP_TROUBLE	*error;		/* Fehlermeldung in d0.l an das Mac-System zurueckgeben */
} OLD_MACSYS;

extern OLD_MACSYS	MSys;			/* fuer alte MagiCMac-Version importieren (bei neuen nur Dummy) */

#define PX_PREFn(b) \
	((b) == 1 ? PX_PREF1 : \
	 (b) == 2 ? PX_PREF2 : \
	 (b) == 4 ? PX_PREF4 : \
	            PX_PREF8)

/*----------------------------------------------------------------------------------------*/
/* Statische Daten																		  */
/*----------------------------------------------------------------------------------------*/
static VDI_SETUP_DATA setup;
static VDI_DISPLAY display;

VDI_SETUP_DATA *MM_init(VDI_SETUP_DATA *in_setup);

VDI_SETUP_DATA *MM_init(VDI_SETUP_DATA *in_setup)
{
	if (in_setup)
	{
		MXVDI_PIXMAP *pm;

		if (in_setup->magic == VDI_SETUP_MAGIC)		/* wurde uns eine VDI_SETUP_DATA-Struktur uebergeben? */
			return in_setup;						/* dann muessen wir nicht konvertieren */

		pm = (MXVDI_PIXMAP *) in_setup;				/* altes MagiCMac: uebergibt Zeiger auf PixMap */

		display.magic = VDI_DISPLAY_MAGIC;
		display.length = sizeof(VDI_DISPLAY);
		display.format = 0;
		display.reserved = 0;
		
		display.next = 0;							/* keine weiteren Monitore */
		display.display_id = 0;
		display.flags = VDI_DISPLAY_ACTIVE;
		display.reserved1 = 0;
		
		display.hdpi = pm->hRes;					/* Pixelgroesse in dpi (16.16) */
		display.vdpi = pm->vRes;
		display.reserved2 = 0;
		display.reserved3 = 0;

		display.reserved4 = 0;
		display.reserved5 = 0;
		display.reserved6 = 0;
		display.reserved7 = 0;

		/* Bitmapbeschreibung aufbauen */
		display.bm.magic = CBITMAP_MAGIC;
		display.bm.length = sizeof(GCBITMAP);		/* Strukturlaenge */
		display.bm.format = 0;						/* Strukturformat (0) */
		display.bm.reserved = 0;					/* reserviert (0) */

		display.bm.addr = pm->baseAddr;	/* Bildschirmadresse */
		display.bm.width = pm->rowBytes & 0x3fff;	/* Breite in Bytes (obere zwei Bits von QD muessen ausmaskiert werden) */
		display.bm.bits = pm->pixelSize;

		if (pm->planeBytes == 2)					/* Emulation eines ATARI-Pixelformats? */
		{
			if (display.bm.bits == 1)
				display.bm.px_format = PX_PREF1;
			else if (display.bm.bits == 2)			/* 4 Farben, 640 * 200 Kompatibilitaetsmodus */
				display.bm.px_format = PX_ATARI2;
			else if (display.bm.bits == 8)
				display.bm.px_format = PX_ATARI8;	/* 256 Farben 320 * 480 Kompatibilitaetsmodus */
			else
				display.bm.px_format = PX_ATARI4;	/* 16 Farben 320 * 200 Kompatibilitaetsmodus */
		}
		else										/* normales MAC-Pixelformat */
		{
			if (display.bm.bits <= 8)
				display.bm.px_format = PX_PREFn(display.bm.bits);
			else if (display.bm.bits == 16)			/* 16 Bit xRGB? */
				display.bm.px_format = PX_PREF15;
			else									/* 32 Bit xRGB? */
				display.bm.px_format = PX_PREF32;
		}

		display.bm.xmin = pm->bounds.left;			/* minimale diskrete x-Koordinate der Bitmap */
		display.bm.ymin = pm->bounds.top;			/* minimale diskrete y-Koordinate der Bitmap */
		display.bm.xmax = pm->bounds.right;			/* maximale diskrete x-Koordinate der Bitmap + 1 */
		display.bm.ymax = pm->bounds.bottom;		/* maximale diskrete y-Koordinate der Bitmap + 1 */
	
		display.bm.ctab = 0;						/* Verweis auf die Farbtabelle ist hier 0 */
		display.bm.itab = 0;						/* Verweis auf die inverse Farbtabelle ist hier 0 */
		display.bm.color_space = CSPACE_RGB;		/* Farbraum, entweder CSPACE_RGB oder CSPACE_GRAY (um Graustufenbetrieb vernuenftig zu unterstuetzen) */
		display.bm.reserved1 = 0;					/* reserviert */
	
		in_setup = &setup;
		in_setup->magic = VDI_SETUP_MAGIC;
		in_setup->length = sizeof(VDI_SETUP_DATA);
		in_setup->format = 0;
		in_setup->reserved = 0;
		
		in_setup->displays = &display;
		in_setup->report_error = MSys.error;			/* Funktion fuer den VDI-GAU */
		in_setup->reserved1 = 0;
		in_setup->reserved2 = 0;
	}
	return in_setup;									/* Direkter Hardwarezugriff fuer Atari */
}
