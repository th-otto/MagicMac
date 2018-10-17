#if	CALL_MAGIC_KERNEL

#define	fnts_get_no_styles \
			fnts_gns

#define	fnts_get_style \
			fnts_gs
			
#define	fnts_get_name \
			fnts_gnm			

#define	fnts_get_info \
			fnts_gin

#endif

/* Definitionen fÅr <font_flags> bei fnts_create() */

#define	FNTS_BTMP	1													/* Bitmapfonts anzeigen */
#define	FNTS_OUTL	2													/* Vektorfonts anzeigen */
#define	FNTS_MONO	4													/* Ñquidistante Fonts anzeigen */
#define	FNTS_PROP	8													/* proportionale Fonts anzeigen */

/* Definitionen fÅr <dialog_flags> bei fnts_create() */
#define	FNTS_3D		1													/* 3D-Design benutzen */

/* Definitionen fÅr <button_flags> bei fnts_open() */
#define	FNTS_SNAME		0x01											/* Checkbox fÅr die Namen selektieren */
#define	FNTS_SSTYLE		0x02											/* Checkbox fÅr die Stile selektieren */
#define	FNTS_SSIZE		0x04											/* Checkbox fÅr die Hîhe selektieren */
#define	FNTS_SRATIO		0x08											/* Checkbox fÅr das VerhÑltnis Breite/Hîhe selektieren */

#define	FNTS_CHNAME		0x0100										/* Checkbox fÅr die Namen anzeigen */
#define	FNTS_CHSTYLE	0x0200										/* Checkbox fÅr die Stile anzeigen */
#define	FNTS_CHSIZE		0x0400										/* Checkbox fÅr die Hîhe anzeigen */
#define	FNTS_CHRATIO	0x0800										/* Checkbox fÅr das VerhÑltnis Breite/Hîhe anzeigen */
#define	FNTS_RATIO		0x1000										/* VerhÑltnis Breite/Hîhe einstellbar */
#define	FNTS_BSET		0x2000										/* Button "setzen" anwÑhlbar */
#define	FNTS_BMARK		0x4000										/* Button "markieren" anwÑhlbar */

/* Definitionen fÅr <button> bei fnts_evnt() */

#define	FNTS_CANCEL	1													/* "Abbruch" wurde angewÑhlt */
#define	FNTS_OK		2													/* "OK" wurde gedrÅckt */
#define	FNTS_SET		3													/* "setzen" wurde angewÑhlt */
#define	FNTS_MARK	4													/* "markieren" wurde betÑtigt */
#define	FNTS_OPT		5													/* der applikationseigene Button wurde ausgewÑhlt */

typedef	void	(cdecl *UTXT_FN)( WORD x, WORD y, WORD *clip_rect, LONG id, LONG pt, LONG ratio, BYTE *string );

typedef struct _fnts_item												/* nach drauûen gefÅhrte Definition */
{
	struct	_fnts_item	*next;										/* Zeiger auf den nÑchsten Font oder 0L (Ende der Liste) */
	UTXT_FN	display;														/* Zeiger auf die Anzeige-Funktion fÅr applikationseigene Fonts */
	LONG		id;															/* ID des Fonts, >= 65536 fÅr applikationseigene Fonts */
	WORD		index;														/* Index des Fonts (falls VDI-Font) */
	BYTE		mono;															/* Flag fÅr Ñquidistante Fonts */
	BYTE		outline;														/* Flag fÅr Vektorfont */
	WORD		npts;															/* Anzahl der vordefinierten Punkthîhen */
	BYTE		*full_name;													/* Zeiger auf den vollstÑndigen Namen */
	BYTE		*family_name;												/* Zeiger auf den Familiennamen */
	BYTE		*style_name;												/* Zeiger auf den Stilnamen */
	BYTE		*pts;															/* Zeiger auf Feld mit Punkthîhen */
	LONG		reserved[4];												/* reserviert, mÅssen 0 sein */
} FNTS_ITEM;

typedef struct _font_item												/* interne Definition */
{
	struct	_font_item	*next;										/* Zeiger auf den ersten Font der nÑchsten Familie oder 0L */
	UTXT_FN	display;														/* Zeiger auf die Anzeige-Funktion oder 0L */
	LONG	id;																/* ID des Fonts */
	WORD	index;															/* Index des Fonts (falls VDI-Font) */
	BYTE	mono;																/* Flag fÅr Ñquidistante Fonts */
	BYTE	outline;															/* Flag fÅr Vektorfont */
	WORD	npts;																/* Anzahl der vordefinierten Punkthîhen */
	BYTE	*full_name;														/* Zeiger auf den vollstÑndigen Namen */
	BYTE	*family_name;													/* Zeiger auf den Familiennamen */
	BYTE	*style_name;													/* Zeiger auf den Stilnamen */
	BYTE	*pts;																/* Zeiger auf Feld mit Punkthîhen */
}FNT;

#define	NO_LBOXES	3
#define	fnt_name		lboxes[0]
#define	fnt_style	lboxes[1]
#define	fnt_size		lboxes[2]

typedef struct
{
	LONG	magic;															/* 'fnts' */
	
	DIALOG	*dialog;														/* Zeiger auf die Dialog-Struktur oder 0L (Dialog nicht im Fenster) */
	WORD	whdl;																/*	Handle des Fensters */

	OBJECT	*tree;														/* Zeiger auf den Objektbaum */
	WORD	dialog_flags;													/* Aussehen des Dialogs */
	WORD	edit_obj;														/* Nummer des aktuellen Editobjekts (nur wenn der Dialog nicht im Fenster lÑuft) */

	WORD	vdi_handle;														/* Handle der VDI-Workstation */
	FNT	*font_list;														/* Zeiger auf die Fontliste */
	
	BYTE	mono;
	BYTE	outline;
	LONG	id;																/* Font-ID */
	LONG	pt;																/* Hîhe in 1/65536 Punkten */
	LONG	ratio;															/* Breiten/Hîhen-VerhÑltnis */

	WORD	button;
	
	BYTE	*sample_string;												/* Zeiger auf den Beispielstring */
	UTXT_FN	display;														/* Zeiger auf die Anzeige-Funktion oder 0L */

	RSHDR	*resource;														/* Zeiger auf den Resource-Header */
	BYTE		**fstring_addr;											/* Zeiger auf Feld mit FSTRING-Adressen */
	OBJECT	**tree_addr;												/* Zeiger auf Feld mit Baum-Adressen */
	WORD		tree_count;													/* Anzahl der BÑume */
	
	USERBLK	udef_sample_text;
	USERBLK	udef_check_box;

	LIST_BOX	*lboxes[NO_LBOXES];

} FNT_DIALOG;

FNT_DIALOG	*fnts_create( WORD vdi_handle, WORD no_fonts, WORD font_flags, WORD dialog_flags, BYTE *sample, BYTE *opt_button );
WORD	fnts_delete( FNT_DIALOG *fnt_dialog, WORD vdi_handle );
WORD	fnts_open( FNT_DIALOG *fnt_dialog, WORD button_flags, WORD x, WORD y, LONG id, LONG pt, LONG ratio );
WORD	fnts_close( FNT_DIALOG *fnt_dialog, WORD *x, WORD *y );

WORD	fnts_get_no_styles( FNT_DIALOG *fnt_dialog, LONG id );
LONG	fnts_get_style( FNT_DIALOG *fnt_dialog, LONG id, WORD index );
WORD	fnts_get_name( FNT_DIALOG *fnt_dialog, LONG id, BYTE *full_name, BYTE *family_name, BYTE *style_name );
WORD	fnts_get_info( FNT_DIALOG *fnt_dialog, LONG id, WORD *mono, WORD *outline );

WORD	fnts_add( FNT_DIALOG *fnt_dialog, FNTS_ITEM *user_fonts );
void	fnts_remove( FNT_DIALOG *fnt_dialog );
WORD	fnts_update( FNT_DIALOG *fnt_dialog, WORD button_flags, LONG id, LONG pt, LONG ratio );

WORD	fnts_evnt( FNT_DIALOG *fnt_dialog, EVNT *events, WORD *button, WORD *check_boxes, LONG *id, LONG *pt, LONG *ratio );
WORD	fnts_do( FNT_DIALOG *fnt_dialog, WORD button_flags, LONG id_in, LONG pt_in, LONG ratio_in, 
					WORD *check_boxes, LONG *id, LONG *pt, LONG *ratio );
