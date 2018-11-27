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
static VDI_SETUP_DATA vdi_setup;
static VDI_DISPLAY vdi_display;

VDI_SETUP_DATA *MM_init(VDI_SETUP_DATA *in_setup);

VDI_SETUP_DATA *MM_init(VDI_SETUP_DATA *in_setup)
{
	if (in_setup)
	{
		MXVDI_PIXMAP *pm;

		if (in_setup->magic == VDI_SETUP_MAGIC)		/* wurde uns eine VDI_SETUP_DATA-Struktur uebergeben? */
			return in_setup;						/* dann muessen wir nicht konvertieren */

		pm = (MXVDI_PIXMAP *) in_setup;				/* altes MagiCMac: uebergibt Zeiger auf PixMap */

		vdi_display.magic = VDI_DISPLAY_MAGIC;
		vdi_display.length = sizeof(VDI_DISPLAY);
		vdi_display.format = 0;
		vdi_display.reserved = 0;
		
		vdi_display.next = 0;							/* keine weiteren Monitore */
		vdi_display.display_id = 0;
		vdi_display.flags = VDI_DISPLAY_ACTIVE;
		vdi_display.reserved1 = 0;
		
		vdi_display.hdpi = pm->hRes;					/* Pixelgroesse in dpi (16.16) */
		vdi_display.vdpi = pm->vRes;
		vdi_display.reserved2 = 0;
		vdi_display.reserved3 = 0;

		vdi_display.reserved4 = 0;
		vdi_display.reserved5 = 0;
		vdi_display.reserved6 = 0;
		vdi_display.reserved7 = 0;

		/* Bitmapbeschreibung aufbauen */
		vdi_display.bm.magic = CBITMAP_MAGIC;
		vdi_display.bm.length = sizeof(GCBITMAP);		/* Strukturlaenge */
		vdi_display.bm.format = 0;						/* Strukturformat (0) */
		vdi_display.bm.reserved = 0;					/* reserviert (0) */

		vdi_display.bm.addr = pm->baseAddr;				/* Bildschirmadresse */
		vdi_display.bm.width = pm->rowBytes & 0x3fff;	/* Breite in Bytes (obere zwei Bits von QD muessen ausmaskiert werden) */
		vdi_display.bm.bits = pm->pixelSize;

		if (pm->planeBytes == 2)						/* Emulation eines ATARI-Pixelformats? */
		{
			if (vdi_display.bm.bits == 1)
				vdi_display.bm.px_format = PX_PREF1;
			else if (vdi_display.bm.bits == 2)			/* 4 Farben, 640 * 200 Kompatibilitaetsmodus */
				vdi_display.bm.px_format = PX_ATARI2;
			else if (vdi_display.bm.bits == 8)
				vdi_display.bm.px_format = PX_ATARI8;	/* 256 Farben 320 * 480 Kompatibilitaetsmodus */
			else
				vdi_display.bm.px_format = PX_ATARI4;	/* 16 Farben 320 * 200 Kompatibilitaetsmodus */
		}
		else											/* normales MAC-Pixelformat */
		{
			if (vdi_display.bm.bits <= 8)
				vdi_display.bm.px_format = PX_PREFn(vdi_display.bm.bits);
			else if (vdi_display.bm.bits == 16)			/* 16 Bit xRGB? */
				vdi_display.bm.px_format = PX_PREF15;
			else										/* 32 Bit xRGB? */
				vdi_display.bm.px_format = PX_PREF32;
		}

		vdi_display.bm.xmin = pm->bounds.left;			/* minimale diskrete x-Koordinate der Bitmap */
		vdi_display.bm.ymin = pm->bounds.top;			/* minimale diskrete y-Koordinate der Bitmap */
		vdi_display.bm.xmax = pm->bounds.right;			/* maximale diskrete x-Koordinate der Bitmap + 1 */
		vdi_display.bm.ymax = pm->bounds.bottom;		/* maximale diskrete y-Koordinate der Bitmap + 1 */
	
		vdi_display.bm.ctab = 0;						/* Verweis auf die Farbtabelle ist hier 0 */
		vdi_display.bm.itab = 0;						/* Verweis auf die inverse Farbtabelle ist hier 0 */
		vdi_display.bm.color_space = CSPACE_RGB;		/* Farbraum, entweder CSPACE_RGB oder CSPACE_GRAY (um Graustufenbetrieb vernuenftig zu unterstuetzen) */
		vdi_display.bm.reserved1 = 0;					/* reserviert */
	
		vdi_setup.magic = VDI_SETUP_MAGIC;
		vdi_setup.length = sizeof(VDI_SETUP_DATA);
		vdi_setup.format = 0;
		vdi_setup.reserved = 0;
		
		vdi_setup.displays = &vdi_display;
		vdi_setup.report_error = MSys.error;			/* Funktion fuer den VDI-GAU */
		vdi_setup.reserved1 = 0;
		vdi_setup.reserved2 = 0;
	
		return &vdi_setup;
	}
	return 0;											/* Direkter Hardwarezugriff fuer Atari */
}
