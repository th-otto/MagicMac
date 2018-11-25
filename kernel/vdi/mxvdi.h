/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*
*/

#ifndef	__VDI_SETUP__
#define	__VDI_SETUP__

/*----------------------------------------------------------------------------------------*/
/* Monitorbeschreibung																							*/
/*----------------------------------------------------------------------------------------*/
#define	VDI_DISPLAY_MAGIC	0x76646964L /* 'vdid' */
#define	VDI_DISPLAY_ACTIVE	1

typedef int32_t fixed;

typedef struct VDI_DISPLAY
{
	int32_t			magic;				/* Strukturkennung 'vdim' */
	int32_t			length;				/* Strukturlaenge */
	int32_t			format;				/* Strukturformat (0) */
	int32_t			reserved;			/* reserviert (0) */
	
	struct VDI_DISPLAY	*next;			/* Zeiger auf naechste Bildschirmbeschreibung */
	int32_t			display_id;			/* Monitorkennung (erstmal nur von 0 aufsteigend zaehlend) */
	int32_t			flags;				/* VDI_DISPLAY_ACTIVE */
	int32_t			reserved1;			/* reserviert (0) */

	fixed			hdpi;
	fixed			vdpi;
	int32_t			reserved2;			/* reserviert (0) */
	int32_t			reserved3;			/* reserviert (0) */

	int32_t			reserved4;			/* reserviert (0) */
	int32_t			reserved5;			/* reserviert (0) */
	int32_t			reserved6;			/* reserviert (0) */
	int32_t			reserved7;			/* reserviert (0) */

	GCBITMAP	bm;						/* Beschreibung des Grafikspeichers */

} VDI_DISPLAY;

#if 0
	Folgenden Aufbau sollte eine GCBITMAP fuer einen Monitor haben:

{
	CBITMAP_MAGIC,						/* Strukturkennung 'cbtm' */
	sizeof( GCBITMAP ),					/* Strukturlaenge */
	0,									/* Strukturformat (0) */
	0,									/* reserviert (0) */

	vram_address,						/* Adresse des Grafikspeichers */
	vram_width,							/* Breite einer Zeile in Bytes */
	vram_bits,							/* Bits pro Pixel */
	vram_px_format,						/* Pixelformat (siehe Color2B.h) */

	display_xmin,						/* minimale diskrete x-Koordinate der Bitmap (0 - solange wir nur einen Monitor unterstuetzen) */
	display_ymin;						/* minimale diskrete y-Koordinate der Bitmap (0 - solange wir nur einen Monitor unterstuetzen) */
	display_xmax;						/* maximale diskrete x-Koordinate der Bitmap + 1 */
	display_ymax;						/* maximale diskrete y-Koordinate der Bitmap + 1 */

	0,									/* Verweis auf die Farbtabelle ist hier 0 */
	0,									/* Verweis auf die inverse Farbtabelle ist hier 0 */
	display_cspace,						/* Farbraum, entweder CSPACE_RGB oder CSPACE_GRAY (um Graustufenbetrieb vernuenftig zu unterstuetzen) */
	0,									/* reserviert */
}
#endif


/*----------------------------------------------------------------------------------------*/
/* Info-Struktur fuer Initialisierung des VDIs. Wird bei vdi_blinit() uebergeben				*/
/*----------------------------------------------------------------------------------------*/

typedef int32_t	VDI_SETUP_TROUBLE( int32_t err );
#define	VDI_DRIVER_MISSING	-1


#define	VDI_SETUP_MAGIC	0x76646969L /* 'vdii' */

typedef struct
{
	int32_t			magic;				/* Strukturkennung 'vdii' */
	int32_t			length;				/* Strukturlaenge */
	int32_t			format;				/* Strukturformat (0) */
	int32_t			reserved;			/* reserviert (0) */

	VDI_DISPLAY	*displays;				/* Liste der angeschlossenen Monitore */
	VDI_SETUP_TROUBLE	*report_error;
	int32_t			reserved1;			/* reserviert (0) */
	int32_t			reserved2;			/* reserviert (0) */

} VDI_SETUP_DATA;

#endif /* __VDI_SETUP__ */
