/*
*
* Binding zum Aufruf von LOAD_IMG.SLB
*
*/

struct initparm {
	WORD cdecl (*xp_raster)( LONG words, LONG len, WORD planes, void *src, void *des );
	LONG xp_ret;
	WORD nplanes;
};

typedef struct _img {
	UBYTE *buf;		/* Bild */
	WORD w;			/* Bildbreite */
	WORD h;			/* Bildhîhe */
	WORD line_width;	/* Bytes pro Zeile */
	WORD nplanes;		/* Tiefe */
	WORD *palette;		/* Zeiger auf Palette */
	WORD pal_entries;	/* LÑnge der Palette */
} img_descriptor;

/* ermittle Funktionszeiger zur Wandlung */
#define LOADIMG_GETFNS(a,b) (*xprastr_exec)(xprastr, 0L, 4, a, b)
/* neue Farbtabelle Åbergeben */
#define LOADIMG_NEWCOLTAB(a) (*xprastr_exec)(xprastr, 1L, 2, a)
