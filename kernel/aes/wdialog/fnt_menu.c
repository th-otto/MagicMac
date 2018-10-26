/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*

	Compilerschalter: -B-P
*/

/*----------------------------------------------------------------------------------------*/ 
/* Globale Includes																								*/
/*----------------------------------------------------------------------------------------*/ 
#include <country.h>
#include <portab.h>
#include <aes.h>
#include <vdi.h>
#include <tos.h> 
#include "std.h"

#define	CALL_MAGIC_KERNEL	1

#include "ker_bind.h"

#if	CALL_MAGIC_KERNEL

/*----------------------------------------------------------------------------------------*/ 
/* Makros und Funktionsdefinitionen fuer Aufrufe an den MagiC-Kernel								*/
/*----------------------------------------------------------------------------------------*/ 

extern int enable_3d;

#define	is_3d_look \
			(enable_3d)

#define	bell() \
			putch(7)

#define	objc_draw( tree, obj, depth, clip ) \
			set_clip_grect( clip ), \
			_objc_draw( tree, obj, depth )

#define	form_xdial( flag, little, big, flyinf ) \
			frm_xdial( flag, little, big, flyinf )

#define	form_center_grect( tree, rect ) \
			_form_center_grect( tree, rect )

#define	evnt_timer( low, high ) \
			_evnt_timer( low )

#define	Malloc( size )	((void *) mmalloc( size ))

#ifdef BINEXACT
LONG mmalloc( ULONG size);
#endif

#include "shelsort.h"
#else

#include <stdio.h>
#include <stddef.h>
#include <string.h>
#include <stdlib.h>

/*----------------------------------------------------------------------------------------*/ 
/* Makros fuer die Pure C-GEMLIB																				*/
/*----------------------------------------------------------------------------------------*/ 

#define	is_3d_look \
			objc_sysvar( 0, AD3DVALUE, 0, 0, &dummy, &dummy )

#define	objc_draw( tree, obj, depth, clip ) \
			objc_draw( tree, obj, depth, (clip)->g_x, (clip)->g_y, (clip)->g_w, (clip)->g_h )

#define	form_dial( flag, l, b ) \
			form_dial(flag, (l)->g_x, (l)->g_y, (l)->g_w, (l)->g_h, \
			 (b)->g_x, (b)->g_y, (b)->g_w, (b)->g_h )

#define	form_xdial( flag, l, b, flyinf ) \
			form_xdial(flag, (l)->g_x, (l)->g_y, (l)->g_w, (l)->g_h, \
			 (b)->g_x, (b)->g_y, (b)->g_w, (b)->g_h, flyinf)

#define	bell() \
			Bconout( 2, 7 )

#define	Malloc( size ) _malloc( size )
#define	Mfree( addr ) _mfree( addr )

#define	lbox_free_items \
			free_items

#define	lbox_free_list \
			free_list

extern void _rsrc_rcfix( void *global, RSHDR *rsc );
static void	*_malloc( LONG size );
static void	_mfree( void *addr );

#include "objcsysv.h"

WORD		errno;															/* fuer Pure C, u.a. wegen malloc() */
extern WORD	aes_flags;
extern WORD	is_magic;
#endif

#include "vdi_bind.h"
#include "vdi_bind.c"

/*----------------------------------------------------------------------------------------*/ 
/* Lokale Includes																								*/
/*----------------------------------------------------------------------------------------*/ 
#include "obj_tool.h"
#include "ger\FONTSLCT.H"
#include "wdialog.h"
#include "listbox.h"
#include "fnts.h"

#if		COUNTRY==COUNTRY_DE
#include "ger\fnts_rsc.h"													/* Die Resource-Datei */
#elif	COUNTRY==COUNTRY_US
#include "us\fnts_rsc.h"
#elif	COUNTRY==COUNTRY_FR
#include "fra\fnts_rsc.h"
#endif

typedef struct
{
	WORD	id;
	BYTE	mono;
	BYTE	outline;
	BYTE	full_name[64];
	BYTE	family_name[64];
	BYTE	style_name[64];
	WORD	npts;
	BYTE	pts[128];
} TMP_FNT;

#define	FH_FNTNM 24														/* 70 Byte - Name des Fonts (siehe auch vqt_name()), z.B. "Century 725 Italic BT" */
#define	FH_NKTKS 258													/*  2 Byte - Anzahl der Track-Kerning-Informationen */
#define	FH_NKPRS 260													/*  2 Byte - Anzahl der Kerning-Paare, (siehe auch vst_kern()) */
#define	FH_CLFGS 263													/*  1 Byte - Klassifizierung, u.a. Italic und Monospace */
#define	FH_SFNTN 266													/* 32 Byte - Name des korrespondierenden Postscript-Fonts, z.B. "Century725BT-Italic" */
#define	FH_SFACN 298													/* 16 Byte - Kurzname der Fontfamilie, z.B. "Century725 BT" */
#define	FH_FNTFM 314													/* 14 Byte - Stil/Form, z.B. "Italic" */
#define	FH_ITANG 328													/*  2 Byte - Schraegstellung in 1/256-Grad (bei italic-Schnitten), z.B 4480 (17,5 Grad) */

/*----------------------------------------------------------------------------------------*/ 
/* konstante globale Variablen (DATA)																		*/
/*----------------------------------------------------------------------------------------*/ 
/* Zuordnung von Index zur Objektnummer in der Listbox */

#define	NO_FNAMES	11
const WORD	fname_ctrl[5] =
{
	FNAME_BOX,
	FNAME_UP,
	FNAME_DOWN,
	FNAME_BACK,
	FNAME_WHITE
};
const WORD	fname_obj[NO_FNAMES] =
{
	FNAME_0, 
	FNAME_1, 
	FNAME_2, 
	FNAME_3, 
	FNAME_4, 
	FNAME_5, 
	FNAME_6, 
	FNAME_7, 
	FNAME_8, 
	FNAME_9, 
	FNAME_10
}; 

#define	NO_FSTYLES	4
const WORD	fstyle_ctrl[5] = 
{
	FSTL_BOX,
	FSTL_UP,
	FSTL_DOWN,
	FSTL_BACK,
	FSTL_WHITE
};
const WORD	fstyle_obj[NO_FSTYLES] =
{
	FSTL_0,
	FSTL_1,
	FSTL_2,
	FSTL_3
};

#define	NO_FSIZES	6
const WORD	fsize_ctrl[5] =
{
	FPT_BOX,
	FPT_UP,
	FPT_DOWN,
	FPT_BACK,
	FPT_WHITE
};	
const WORD	fsize_obj[NO_FSIZES] =
{
	FPT_0,
	FPT_1,
	FPT_2,
	FPT_3,
	FPT_4,
	FPT_5
};

const BYTE	move_objs[25] =
{
	FSAMPLE,
	FNAME_UP,
	FSTL_UP,
	FNAME_BOX,
	FSTL_BOX,
	FNAME_BACK,
	CHECK_STYLE,
	FSTL_BACK,
	FSTL_DOWN,
	FPT_UP,
	CHECK_NAME,
	FPT_BOX,
	FPT_BACK,
	FPT_USER,
	CHECK_SIZE,
	CHECK_RATIO,
	F_BH_STRING,
	F_BH,
	FNAME_DOWN,
	FPT_DOWN,
	FSET,
	FMARK,
	FOPTIONS,
	FOK,
	FCANCEL
};

/*----------------------------------------------------------------------------------------*/ 
/* interne Funktionen																							*/
/*----------------------------------------------------------------------------------------*/ 
static WORD	init_dialog( FNT_DIALOG *fnt_dialog, WORD button_flags, LONG id, LONG pt, LONG ratio );
static FNT	*create_lboxes( FNT_DIALOG *fnt_dialog, LONG id, LONG pt );
static FNT	*build_lists( FNT *font_list, LONG id, LONG pt, LBOX_ITEM **font_names, LBOX_ITEM **font_styles, LBOX_ITEM **font_sizes );
static LBOX_ITEM	*build_name_list( FNT *font, LONG id, FNT **family, FNT **fnt );
static LBOX_ITEM	*build_style_list( FNT *font, LONG id );
static LBOX_ITEM	*build_pt_list( FNT *font, LONG size, LBOX_ITEM **selected );
static void	free_lboxes( FNT_DIALOG *fnt_dialog );
static void	free_items( LIST_BOX *box );
static void	free_list( LBOX_ITEM *item );
static void	enable_lbox( OBJECT *tree, WORD *objs, WORD n );
static void	disable_lbox( OBJECT *tree, WORD *objs, WORD n );

static FNT	*build_font_list( WORD vdi_handle, WORD no_fonts, WORD font_flags );
static WORD	get_pt_sizes( WORD vdi_handle, BYTE *pts );
static WORD	is_bitmap_mono( WORD vdi_handle, WORD pt );
static void	sort_FNTs( FNT **fonts, WORD font_cnt );
static int	cmp_font_names( FNT **a, FNT **b );
static FNT	*get_FNT( FNT *font, LONG id );
static WORD	count_fonts( FNT *font );

static void	set_top( LIST_BOX *box, WORD last_top, WORD last_cnt, GRECT *rect );
static LONG	slct_closest_height( LBOX_ITEM *item, LBOX_ITEM **slct, FNT *font, LONG pt );

static RSHDR	*copy_rsrc( RSHDR *rsc, LONG len );
static void	init_rsrc( RSHDR *rsh, FNT_DIALOG *fnt_dialog, WORD dialog_flags );
static void	make_check_box( OBJECT *obj, USERBLK *userblk );
static void	no3d_rsrc( RSHDR *rsh, OBJECT *tree );
static void FTEXT_to_FBOXTEXT( OBJECT *obj );
static void	adapt_rsrc( OBJECT *tree, WORD button_flags );
static void	move_hor_obj( OBJECT *tree, WORD offset );

static void	redraw_obj( FNT_DIALOG *fnt_dialog, WORD obj );
static void	set_edit_obj( FNT_DIALOG *fnt_dialog, WORD obj );
static WORD	get_edit_obj( FNT_DIALOG *fnt_dialog );
static void	deselect_button( FNT_DIALOG *fnt_dialog, WORD obj );
static void	show_check_box( OBJECT *tree, WORD obj );
static void	hide_check_box( OBJECT *tree, WORD obj );
static WORD	get_check_state( OBJECT *tree );

static WORD	do_buttons( FNT_DIALOG *fnt_dialog, WORD obj );
static void	do_CHECK_NAME( OBJECT *tree );
static void	do_CHECK_STYLE( OBJECT *tree );
static void	do_CHECK_SIZE( OBJECT *tree );
static void	do_CHECK_RATIO( OBJECT *tree );
static WORD	get_fixed( OBJECT *obj, LONG *old_value, LONG min, LONG max );
static WORD	check_key( UWORD code );
static void	draw_3d_box( PARMBLK *parmblock, WORD vdi_handle, VRECT *rect, VRECT *clip_rect, WORD dialog_flags );
static WORD	use_vqt_xfontinfo( void );

/*----------------------------------------------------------------------------------------*/ 
/* Funktionen fuer Userdefs, Listbox und Fensterdialog													*/
/*----------------------------------------------------------------------------------------*/ 
WORD	cdecl sample_text( PARMBLK *parmblock );
WORD	cdecl check_box( PARMBLK *parmblock );

WORD	cdecl	set_str_item( LIST_BOX *box, OBJECT *tree, LBOX_ITEM *item, WORD index, void *user_data, GRECT *rect, WORD first );

void	cdecl	slct_family( LIST_BOX *box, OBJECT *tree, LBOX_ITEM *item, void *user_data, WORD obj_index, WORD last_state );
void	cdecl	slct_style( LIST_BOX *box, OBJECT *tree, LBOX_ITEM *item, void *user_data, WORD obj_index, WORD last_state );
void	cdecl	slct_size( LIST_BOX *box, OBJECT *tree, LBOX_ITEM *item, void *user_data, WORD obj_index, WORD last_state );

WORD	cdecl	do_slct_font( DIALOG *d, EVNT *events, int objnr, int clicks, void *data );

/*----------------------------------------------------------------------------------------*/ 
/* Objektmanipulation																							*/
/*----------------------------------------------------------------------------------------*/ 
#include "objmacro.h"

/*----------------------------------------------------------------------------------------*/ 
/* Fontselektor initialisieren und Zeiger auf Struktur zurueckliefern								*/
/* Funktionsergebnis:	Zeiger auf Struktur																*/
/*	vdi_handle:				Handle der zu benutzenden VDI-Workstation									*/
/*	no_fonts:				Anzahl der System- und der nachgeladenen Fonts oder 0, wenn 		*/
/*								vst_load_fonts() aufgerufen werden soll									*/
/*	font_flags:				Flags, die charakterisieren, welche Fonts angezeigt werden sollen	*/
/*	sample:					Zeiger auf Beispiel-String fuer die Anzeige								*/
/*	opt_button:				Zeiger auf String fuer den Options-Button oder 0L						*/
/*----------------------------------------------------------------------------------------*/ 
FNT_DIALOG	*fnts_create( WORD vdi_handle, WORD no_fonts, WORD font_flags, WORD dialog_flags, BYTE *sample, BYTE *opt_button )
{
	FNT_DIALOG	*fnt_dialog;
	
	if ( no_fonts == 0 )
	{
		WORD	work_out[57];
		
		vq_extnd( vdi_handle, 0, work_out );						/* vq_extnd() aufrufen, um die Anzahl der Systemfonts zu erfragen */
		no_fonts = work_out[10];
		
		if ( vq_gdos())													/* koennen Fonts geladen werden? */	
			no_fonts += vst_load_fonts( vdi_handle, 0 );			/* Fonts laden und ihre Anzahl erfragen */
	}
		
	fnt_dialog = Malloc( sizeof( FNT_DIALOG ));					/* Speicher fuer Strukturen und Fonttabelle anfordern */

	if ( fnt_dialog )														/* alles in Ordnung? */
	{
		RSHDR	*resource;
		
		resource = copy_rsrc( (RSHDR *) fnts_rsc, RSC_LEN );	/* Resource kopieren und beim AES anmelden */

		if ( resource )
		{
			OBJECT	*tree;
			FNT	*fonts;

#if CALL_MAGIC_KERNEL
			if ( is_3d_look == 0	)										/* kein 3D-Look? */
				dialog_flags &= ~FNTS_3D;								/* 3D-Look ausschalten */
#else
			WORD	dummy;

			if ( aes_flags & GAI_MAGIC )								/* MagiC-AES? */
			{
				if ( is_3d_look == 0	)									/* kein 3D-Look? */
					dialog_flags &= ~FNTS_3D;							/* 3D-Look ausschalten */
			}
			else
				dialog_flags &= ~FNTS_3D;								/* 3D-Look ausschalten */
#endif

			fnt_dialog->resource = resource;							/* Zeiger auf den Resource-Header */
			init_rsrc( resource, fnt_dialog, dialog_flags );	/* Resource anpassen */

			tree = fnt_dialog->tree_addr[FONTSL];

			if	( opt_button )												/* wird der Options-Button unterstuetzt? */
			{
				obj_ENABLED( tree, FOPTIONS );
				tree[FOPTIONS].ob_spec.free_string = opt_button;	/* Text eintragen */
			}
			else
				obj_DISABLED( tree, FOPTIONS );

			fonts = build_font_list( vdi_handle, no_fonts, font_flags );	/* Liste mit allen vorhandenen Fonts aufbauen */
		
			if ( fonts )
			{
				fnt_dialog->magic = 'fnts';

				fnt_dialog->dialog = 0L;								/* Zeiger auf die Dialog-Struktur */
				fnt_dialog->whdl = 0;									/* Handle des Fensters */
				
				fnt_dialog->tree = tree;								/* Zeiger auf den Objektbaum */
				fnt_dialog->dialog_flags = dialog_flags;			/* Aussehen des Dialogs */
				fnt_dialog->edit_obj = 0;

				fnt_dialog->font_list = fonts;						/* Zeiger auf den ersten Font */
				fnt_dialog->vdi_handle = vdi_handle;				/* VDI-Handle */
				fnt_dialog->sample_string = sample;					/* Zeiger auf den Beispiel-String */
	
				fnt_dialog->udef_sample_text.ub_parm = (LONG) fnt_dialog;
				fnt_dialog->udef_check_box.ub_parm = (LONG) fnt_dialog;
			}
			else
			{
				Mfree( fnt_dialog );
				fnt_dialog = 0L;
			}
		}
		else
		{
			Mfree( fnt_dialog );
			fnt_dialog = 0L;
		}
		
	}
	return( fnt_dialog );
}

/*----------------------------------------------------------------------------------------*/ 
/* Speicher fuer Font-Strukturen und Resource zurueckgeben												*/
/* Funktionsergebnis:	1																						*/
/*	fnt_dialog:				Zeiger auf die Dialog-Struktur												*/
/*	vdi_handle:				Handle der VDI-Workstation oder 0, wenn vst_unload_fonts() nicht	*/
/*								aufgerufen werden soll.															*/
/*----------------------------------------------------------------------------------------*/ 
WORD	fnts_delete( FNT_DIALOG *fnt_dialog, WORD vdi_handle )
{
	FNT	*font;
	
	font = fnt_dialog->font_list;
	
	while ( font )
	{
		FNT	*delete;

		delete = font;
		font = font->next;												/* Zeiger auf den naechsten Font */
		Mfree( delete );
	}
	
	Mfree(fnt_dialog->resource);
	
	Mfree( fnt_dialog );

	if ( vdi_handle )														/* soll vst_unload_fonts() aufgerufen werden? */
	{
		if ( vq_gdos())													/* koennen Fonts entfernt werden? */	
			vst_unload_fonts( vdi_handle, 0 );
	}
	
	return( 1 );
}

/*----------------------------------------------------------------------------------------*/ 
/* Fontauswahl-Dialog anzeigen																				*/
/* Funktionsergebnis:	Handle des Fensters oder 0 (Fehler)											*/
/*	fnt_dialog:				Zeiger auf die Dialog-Struktur												*/
/*	button_flags:			Flags fuers Aussehen des Dialogs												*/
/*	x:							x-Koordinate des Dialogs (oder -1)											*/
/*	y:							y-Koordinate des Dialogs (oder -1)											*/
/*	id:						ID des einzustellenden Fonts													*/
/*	pt:						Hoehe in 1/65536 Punkten															*/
/*	ratio:					Verhaeltnis Breite/Hoehe															*/
/*----------------------------------------------------------------------------------------*/ 
WORD	fnts_open( FNT_DIALOG *fnt_dialog, WORD button_flags, WORD x, WORD y, LONG id, LONG pt, LONG ratio )
{
	OBJECT	*tree;

	tree = fnt_dialog->tree;
	
	fnt_dialog->dialog = wdlg_create( do_slct_font, tree, (void *) fnt_dialog, 0, 0, 0 );
	
	if ( fnt_dialog->dialog )											/* konnte die Dialog-Struktur angelegt werden? */
	{
		if ( init_dialog( fnt_dialog, button_flags, id, pt, ratio ))	/* konnte der Dialog initialisiert werden? */
		{
			WORD	handle;

			handle = wdlg_open( fnt_dialog->dialog, fnt_dialog->fstring_addr[FONTSL_NAME], NAME + MOVER + CLOSER, x, y, 0, 0L );
								
			if ( handle )													/* alles in Ordnung? */
			{
				fnt_dialog->whdl = handle;
				set_edit_obj( fnt_dialog, 0 );						/* Edit-Objekt ausschalten */

				return( handle );
			}
			else
				free_lboxes( fnt_dialog );								/* Speicher fuer Listboxen und Listen freigeben */
		}
		wdlg_delete( fnt_dialog->dialog );							/* Fensterdialog loeschen */
	}
	return( 0 );
}

/*----------------------------------------------------------------------------------------*/ 
/* Fontauswahl-Dialog schliessen																				*/
/* Funktionsergebnis:	1																						*/
/*	fnt_dialog:				Zeiger auf die Dialog-Struktur												*/
/*	x:							x-Koordinate des Dialogs wird zurueckgeliefert							*/
/*	y:							y-Koordinate des Dialogs wird zurueckgeliefert							*/
/*----------------------------------------------------------------------------------------*/ 
WORD	fnts_close( FNT_DIALOG *fnt_dialog, WORD *x, WORD *y )
{
	if ( fnt_dialog->whdl )
	{
		wdlg_close( fnt_dialog->dialog, x, y );					/* Fensterdialog schliessen */
		wdlg_delete( fnt_dialog->dialog );							/* Speicher freigeben */
	
		free_lboxes( fnt_dialog );										/* Speicher fuer Listboxen und Listen freigeben */
	
		fnt_dialog->dialog = 0L;										/* Zeiger auf die Dialog-Struktur */
		fnt_dialog->whdl = 0;											/* Handle des Fensters */
	}
	else
	{
		*x = -1;
		*y = -1;
	}
	
	return( 1 );
}

/*----------------------------------------------------------------------------------------*/ 
/* Fontauswahl-Dialog updaten, neuen Font anzeigen														*/
/* Funktionsergebnis:	1: alles in Ordnung 0: Fehler													*/
/*	fnt_dialog:				Zeiger auf die Dialog-Struktur												*/
/*	button_flags:			Flags fuers Aussehen des Dialogs												*/
/*	id:						ID des einzustellenden Fonts													*/
/*	pt:						Hoehe in 1/65536 Punkten															*/
/*	ratio:					Verhaeltnis Breite/Hoehe															*/
/*----------------------------------------------------------------------------------------*/ 
WORD	fnts_update( FNT_DIALOG *fnt_dialog, WORD button_flags, LONG id, LONG pt, LONG ratio )
{
	if ( fnt_dialog->dialog )											/* konnte die Dialog-Struktur angelegt werden? */
	{
		free_lboxes( fnt_dialog );										/* Speicher fuer Listboxen und Listen freigeben */

		if ( init_dialog( fnt_dialog, button_flags, id, pt, ratio ))	/* konnte der Dialog initialisiert werden? */
		{
			set_edit_obj( fnt_dialog, 0 );							/* Edit-Objekt ausschalten */
			redraw_obj( fnt_dialog, ROOT );
			return( 1 );
		}
	}
	return( 0 );
}

/*----------------------------------------------------------------------------------------*/ 
/* Event-Behandlung fuer den Fontauswahl-Dialog															*/
/* Funktionsergebnis:	0: ein Exit-Button wurde betaetigt 1: nichts passiert					*/
/*	fnt_dialog:				Zeiger auf die Dialog-Struktur												*/
/*	events:					Zeiger auf EVNT-Struktur														*/
/*	button:					angewaehlter Button																*/
/*	check_boxes:			Bitvektor fuer Selektion der Checkboxen										*/
/*	id:						ID des eingestellten Fonts														*/
/*	pt:						Hoehe in 1/65536 Punkten															*/
/*	ratio:					Verhaeltnis Breite/Hoehe															*/
/*----------------------------------------------------------------------------------------*/ 
WORD	fnts_evnt( FNT_DIALOG *fnt_dialog, EVNT *events, WORD *button, WORD *check_boxes, LONG *id, LONG *pt, LONG *ratio )
{
	WORD	cont;
	
	cont = wdlg_evnt( fnt_dialog->dialog, events );				/* Event fuer den Fensterdialog behandeln */
	
	*button = fnt_dialog->button;										/* angewaehlter Button */
	*check_boxes = get_check_state( fnt_dialog->tree );		/* Bitvektor fuer selektierte Check-Buttons */
	*id = fnt_dialog->id;												/* ID des eingestellten Fonts */
	*pt = fnt_dialog->pt;												/* Hoehe in 1/65536 Punkten */
	
	if ( fnt_dialog->outline )											/* Vektorfont? */
		*ratio = fnt_dialog->ratio;									/* Verhaeltnis Breite/Hoehe */
	else
		*ratio = 0x10000L;												/* bei Bitmapfonts ist das Verhaeltnis immer 1 */
		
	fnt_dialog->button = 0;												/* Button-Status loeschen */
	
	return( cont );
}

/*----------------------------------------------------------------------------------------*/ 
/* Fontdialog mit form_xdo() ausfuehren																		*/
/* Funktionsergebnis:	Nummer des Exit-Button (FNTS_CANCEL, usw.)								*/
/*	fnt_dialog:				Zeiger auf die Dialog-Struktur												*/
/*	button_flags:			Flags fuers Aussehen des Dialogs												*/
/*	id_in:					ID des einzustellenden Fonts													*/
/*	pt_in:					Hoehe in 1/65536 Punkten															*/
/*	ratio_in:				Verhaeltnis Breite/Hoehe															*/
/*	check_boxes:			Bitvektor fuer Selektion der Checkboxen										*/
/*	id:						ID des eingestellten Fonts														*/
/*	pt:						Hoehe in 1/65536 Punkten															*/
/*	ratio:					Verhaeltnis Breite/Hoehe															*/
/*----------------------------------------------------------------------------------------*/ 
WORD	fnts_do( FNT_DIALOG *fnt_dialog, WORD button_flags, LONG id_in, LONG pt_in, LONG ratio_in, WORD *check_boxes, LONG *id, LONG *pt, LONG *ratio )
{
	if ( init_dialog( fnt_dialog, button_flags, id_in, pt_in, ratio_in ))	/* konnte der Dialog initialisiert werden? */
	{
		OBJECT	*tree;
		GRECT		size;
		void		*flyinf;
		
		tree = fnt_dialog->tree;

		move_hor_obj( tree, 1 );										/* alle Objekt um ein Pixel nach rechts schieben, damit */
		tree[CHECK_NAME].ob_x += 1;									/* die Checkbox CHECK_NAME nicht direkt am Rand liegt */
		tree[FSAMPLE].ob_y += 6;										/* den Beispieltext um 6 Pixel nach unten verschieben und um */
		tree[FSAMPLE].ob_height -= 4;									/* 4 Pixel niedriger machen, damit er nicht die Flugecke ueberdeckt */
		
		wind_update( BEG_UPDATE );										/* Bildschirm sperren */
		wind_update( BEG_MCTRL );										/* Mauskontrolle holen */
	
		form_center_grect( tree, &size );									/* Dialog zentrieren */
	
#if CALL_MAGIC_KERNEL
		form_xdial( FMD_START, &size, &size, &flyinf );			/* Bildbereich reservieren */
#else
		if ( aes_flags & GAI_MAGIC )									/* MagiC-AES? */
			form_xdial( FMD_START, &size, &size, &flyinf );		/* Bildbereich reservieren */
		else
			form_dial( FMD_START, &size, &size );					/* Bildbereich reservieren */
#endif

		objc_draw( tree, ROOT, MAX_DEPTH, &size );				/* Dialog zeichnen */

		fnt_dialog->edit_obj = FPT_USER;								/* Nummer des Edit-Objekts */

		while ( 1 )
		{
			WORD	obj;

#if CALL_MAGIC_KERNEL
			obj = form_xdo( tree, fnt_dialog->edit_obj, &fnt_dialog->edit_obj, 0L, flyinf );	/* auf EXIT-Objekt warten */
#else
			if ( aes_flags & GAI_MAGIC )								/* MagiC-AES? */
				obj = form_xdo( tree, fnt_dialog->edit_obj, &fnt_dialog->edit_obj, 0L, flyinf );	/* auf EXIT-Objekt warten */
			else
				obj = form_do( tree, 0 );								/* auf EXIT-Objekt warten */
#endif			

			if ( do_buttons( fnt_dialog, obj ) == 0 )				/* Dialog schliessen? */
				break;
		}
		
#if CALL_MAGIC_KERNEL
		form_xdial( FMD_FINISH, &size, &size, &flyinf );
#else
		if ( aes_flags & GAI_MAGIC )									/* MagiC-AES? */
			form_xdial( FMD_FINISH, &size, &size, &flyinf );
		else
			form_dial( FMD_FINISH, &size, &size );
#endif

		wind_update( END_MCTRL );										/* Maus freigeben */	
		wind_update( END_UPDATE );										/* Bildschirm freigeben */
	
		move_hor_obj( tree, -1 );										/* alle Objekt wieder in die */
		tree[CHECK_NAME].ob_x -= 1;									/* Urpsrungsposition zurueck- */
		tree[FSAMPLE].ob_y -= 6;										/* bewegen, so dass es beim naechsten */
		tree[FSAMPLE].ob_height += 4;									/* Aufruf keine Probleme gibt */

		*check_boxes = get_check_state( fnt_dialog->tree );	/* Bitvektor fuer selektierte Check-Buttons */
		*id = fnt_dialog->id;											/* ID des eingestellten Fonts */
		*pt = fnt_dialog->pt;												/* Hoehe in 1/65536 Punkten */

		if ( fnt_dialog->outline )										/* Vektorfont? */
			*ratio = fnt_dialog->ratio;								/* Verhaeltnis Breite/Hoehe */
		else
			*ratio = 0x10000L;											/* bei Bitmapfonts ist das Verhaeltnis immer 1 */
		
		free_lboxes( fnt_dialog );										/* Speicher fuer Listboxen und Listen freigeben */
		
		return( fnt_dialog->button );									/* angewaehlter Button */
	}
	else
		return( 0 );														/* Fehler */
}

/*----------------------------------------------------------------------------------------*/ 
/* Programmeigene Fonts hinzufuegen																			*/
/* Funktionsergebnis:	0: Fehler 1: alles in Ordnung													*/
/*	fnt_dialog:				Zeiger auf die Fontdialog-Struktur											*/
/*	user_fonts:				Zeiger auf programmeigene Fonts												*/
/*----------------------------------------------------------------------------------------*/ 
WORD	fnts_add( FNT_DIALOG *fnt_dialog, FNTS_ITEM *user_fonts )
{
	FNT	**font_tab;
	FNT	*vdi_fonts;
	WORD	no_fonts;
	
	vdi_fonts = fnt_dialog->font_list;
	
	no_fonts = count_fonts( vdi_fonts );							/* Anzahl der systemeigenen Schriften */
	no_fonts += count_fonts((FNT *) user_fonts );				/* + Anzahl der programmeigenen Schriften */

	font_tab = Malloc( no_fonts * sizeof(FNT *));				/* Zeiger auf Fonttabelle */

	if ( font_tab )														/* genuegend Speicher? */
	{
		FNT	**tmp;

		tmp = font_tab;
		
		while ( vdi_fonts )
		{
			*tmp++ = vdi_fonts;											/* Zeiger in der Tabelle eintragen */
			vdi_fonts = vdi_fonts->next;								/* Zeiger auf den naechsten Font */
		}
	
		while ( user_fonts )
		{
			*tmp++ = (FNT *) user_fonts;								/* Zeiger in der Tabelle eintragen */
			user_fonts->reserved[0] = (LONG) user_fonts->next;	/* Zeiger sichern */
			user_fonts = user_fonts->next;							/* Zeiger auf den naechsten programmeigenen Font */
		}
		
		sort_FNTs( font_tab, no_fonts );								/* Fonts sortieren und verketten */

		fnt_dialog->font_list = font_tab[0];						/* Zeiger auf den ersten Font */

		Mfree( font_tab );

		return( 1 );
	}
	else
		return( 0 );
}

/*----------------------------------------------------------------------------------------*/ 
/* Programmeigene Fonts aus der Liste entfernen															*/
/* Funktionsergebnis:	-																						*/
/*	fnt_dialog:				Zeiger auf die Fontdialog-Struktur											*/
/*----------------------------------------------------------------------------------------*/ 
void	fnts_remove( FNT_DIALOG *fnt_dialog )
{
	FNT	**fonts;
	
	fonts = &fnt_dialog->font_list;
	
	while ( *fonts )
	{
		FNT	*font;
		
		font = *fonts;
		
		if ( font->display )												/* programmeigener Font? */
		{
			FNTS_ITEM	*tmp;
			
			tmp = (FNTS_ITEM *) font;
			
			*fonts = font->next;											/* Font aus der Verkettung loesen */
			tmp->next = (FNTS_ITEM *) tmp->reserved[0];			/* und alte Verkettung herstellen */
		}
		else
			fonts = &font->next;
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* Anzahl der zu einer Familie gehoerigen Stile (Fonts) ermitteln									*/
/* Funktionsergebnis:	Anzahl der zu einer Familie gehoerigen Stile (Fonts)					*/
/*	fnt_dialog:				Zeiger auf die Dialog-Struktur												*/
/*	id:						ID eines Fonts der Familie														*/
/*----------------------------------------------------------------------------------------*/ 
WORD	fnts_get_no_styles( FNT_DIALOG *fnt_dialog, LONG id )
{
	FNT	*family;
	FNT	*font;
	WORD	no_styles;
	
	font = fnt_dialog->font_list;
	family = get_FNT( font, id );											/* Zeiger auf den Font holen */
	no_styles = 0;
		
	if ( family )																/* Font gefunden? */
	{
		while ( font )
		{
			if ( strcmp( family->family_name, font->family_name ) == 0 )	/* gleiche Familie? */
				no_styles++;													/* Anzahl erhoehen */

			font = font->next;
		}
	}
	return( no_styles );														/* Anzahl zurueckliefern */
}

/*----------------------------------------------------------------------------------------*/ 
/* ID eines Fonts zurueckliefern, der zur gleichen Familie wie <id> gehoert, und der der		*/
/*	<index>-te Font der Familie ist.																			*/
/*																														*/
/* Funktionsergebnis:	ID des Fonts																		*/
/*	fnt_dialog:				Zeiger auf die Dialog-Struktur												*/
/*	id:						ID eines Fonts der Familie														*/
/*	index:					Index innerhalb der Familie (1 <= index <= Anzahl der Stile)		*/
/*----------------------------------------------------------------------------------------*/ 
LONG	fnts_get_style( FNT_DIALOG *fnt_dialog, LONG id, WORD index )
{
	FNT	*family;
	FNT	*font;
	
	font = fnt_dialog->font_list;
	family = get_FNT( font, id );											/* Zeiger auf den Font holen */
		
	if ( family )																/* Font gefunden? */
	{
		while ( font )
		{
			if ( strcmp( family->family_name, font->family_name ) == 0 )	/* gleiche Familie? */
			{
				index--;
				
				if ( index == 0 )												/* Font gefunden? */
					return( font->id );										/* ID zurueckliefern */
			}
			font = font->next;
		}
	}
	return( 0 );																/* Fehler */
}

/*----------------------------------------------------------------------------------------*/ 
/* Die Namen eines Fonts zurueckliefern																		*/
/* Funktionsergebnis:	0: Fehler 1: alles in Ordnung													*/
/*	fnt_dialog:				Zeiger auf die Dialog-Struktur												*/
/*	id:						ID des Fonts																		*/
/*	full_name:				Zeiger auf String fuer den vollstaendigen Namen oder 0L					*/
/*	family_name:			Zeiger auf String fuer den Familiennamen oder 0L							*/
/*	style_name:				Zeiger auf String fuer Stilnamen oder 0L									*/
/*----------------------------------------------------------------------------------------*/ 
WORD	fnts_get_name( FNT_DIALOG *fnt_dialog, LONG id, BYTE *full_name, BYTE *family_name, BYTE *style_name )
{
	FNT	*font;
	
	font = get_FNT( fnt_dialog->font_list, id );						/* Zeiger auf den Font holen */

	if ( font )
	{
		if ( full_name )
			vstrcpy( full_name, font->full_name );

		if ( family_name )
			vstrcpy( family_name, font->family_name );

		if ( style_name )
			vstrcpy( style_name, font->style_name );

		return( 1 );
	}
	else
		return( 0 );
}

/*----------------------------------------------------------------------------------------*/ 
/* Index eines Fonts zurueckliefern (z.B. fuer vqt_name)												*/
/* Funktionsergebnis:	0: Fehler > 0: Index des Fonts												*/
/*	fnt_dialog:				Zeiger auf die Dialog-Struktur												*/
/*	id:						ID des Fonts																		*/
/*	mono:						Zeiger auf Flag fuer Aquidistanz												*/
/*	outline:					Zeiger auf Flag fuer Vektorfont												*/
/*----------------------------------------------------------------------------------------*/ 
WORD	fnts_get_info( FNT_DIALOG *fnt_dialog, LONG id, WORD *mono, WORD *outline )
{
	FNT	*font;
	
	font = get_FNT( fnt_dialog->font_list, id );						/* Zeiger auf den Font holen */

	if ( font )
	{
		*mono = font->mono;
		*outline = font->outline;

		return( font->index );
	}
	return( 0 );
}

static void	set_dialog( FNT_DIALOG *fnt_dialog, FNT *font, WORD button_flags, LONG id, LONG pt, LONG ratio );

/*****************************************************************************************/
/*****************************************************************************************/
/*****************************************************************************************/
/*****************************************************************************************/
/*****************************************************************************************/
/*****************************************************************************************/
/*****************************************************************************************/
/*****************************************************************************************/
/*****************************************************************************************/
/*****************************************************************************************/

/*----------------------------------------------------------------------------------------*/ 
/* Dialog initialisieren, Listboxen anlegen																*/
/* Funktionsergebnis:	0: Fehler 1: alles in Ordnung													*/
/*	fnt_dialog:				Zeiger auf die Dialog-Struktur												*/
/*	id:						ID des Fonts																		*/
/*	pt:						Hoehe in Punkten																	*/
/*	ratio:					Breiten-Hoehen-Verhaeltnis														*/
/*----------------------------------------------------------------------------------------*/ 
static WORD	init_dialog( FNT_DIALOG *fnt_dialog, WORD button_flags, LONG id, LONG pt, LONG ratio )
{
	FNT	*font;

	font = create_lboxes( fnt_dialog, id, pt );					/* Listboxen anlegen */
	
	if ( font )
	{
		set_dialog( fnt_dialog, font, button_flags, id, pt, ratio );
		return( 1 );
	}
	return( 0 );
}

static void	set_dialog( FNT_DIALOG *fnt_dialog, FNT *font, WORD button_flags, LONG id, LONG pt, LONG ratio )
{
	OBJECT	*tree;
	
	(void)id;
	if ( pt > ( 1000L << 16 ))											/* groesser als 1000 Punkte? */
		pt = 1000L << 16;
	if ( pt < 65536L )													/* kleiner als 1 Punkt? */
		pt = 65536L;

	if ( ratio < 6554 )													/* < 0.1 ? */
		ratio = 6554;
	else if ( ratio > 655360L )										/* > 10.0 ? */
		ratio = 655360L;

	fnt_dialog->id = font->id;
	fnt_dialog->mono = font->mono;
	fnt_dialog->outline = font->outline;
	fnt_dialog->display = font->display;
	fnt_dialog->pt = pt;
	fnt_dialog->ratio = ratio;

	fnt_dialog->button = 0;												/* kein Button ausgewaehlt */

	tree = fnt_dialog->tree;
	adapt_rsrc( tree, button_flags );								/* Dialog entsprechend <button_flags> anpassen */

	fixed_to_str( tree[FPT_USER].ob_spec.tedinfo->te_ptext, 5, pt );
	fixed_to_str( tree[F_BH].ob_spec.tedinfo->te_ptext, 4, ratio );

	if ( font->outline )													/* Vektorfont? */
	{
		obj_ENABLED( tree, CHECK_RATIO );							/* Checkbox fuer B/H-Verhaeltnis disablen */
		obj_TOUCHEXIT( tree, CHECK_RATIO );							/* Checkbox nicht anwaehlbar */
		obj_ENABLED( tree, F_BH );										/* FTEXT fuer B/H-Verhaeltnis disablen */
		obj_EDITABLE( tree, F_BH );									/* FTEXT nicht editierbar */
	}
	else																		/* Bitmapfont */
	{
		obj_DISABLED( tree, CHECK_RATIO );							/* Checkbox fuer B/H-Verhaeltnis disablen */
		obj_NOT_TOUCHEXIT( tree, CHECK_RATIO );					/* Checkbox nicht anwaehlbar */
		obj_DISABLED( tree, F_BH );									/* FTEXT fuer B/H-Verhaeltnis disablen */
		obj_NOT_EDITABLE( tree, F_BH );								/* FTEXT nicht editierbar */
	}

	if ( lbox_get_slct_item( fnt_dialog->fnt_size ))			/* Selektion in der Punktliste? */
		obj_DESELECTED( tree, FPT_USER );							/* Edit-Objekt deselektieren */
	else
	{
		if ( font->outline == 0 )										/* handelt es sich um einen Bitmap-Font? */
		{
			LBOX_ITEM	*sizes;
			LBOX_ITEM	*slct;
			
			sizes = lbox_get_items( fnt_dialog->fnt_size );	/* Zeiger auf die Liste holen */
			pt = slct_closest_height( sizes, &slct, font, pt );	/* am naechsten liegende Hoehe suchen */
			lbox_update( fnt_dialog->fnt_size, 0L );				/* Objekte updaten; nicht zeichnen */
		}
		else
			obj_SELECTED( tree, FPT_USER );							/* Edit-Objekt selektieren */
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* Listboxen fuer den Fontdialog anlegen																	*/
/* Funktionsergebnis:	Zeiger auf den ausgewaehlten Font oder 0L (Fehler)						*/
/*	fnt_dialog:				Zeiger auf die Dialog-Struktur												*/
/*	id:						ID des Fonts																		*/
/*	pt:						Hoehe in Punkten																	*/
/*----------------------------------------------------------------------------------------*/ 
static FNT	*create_lboxes( FNT_DIALOG *fnt_dialog, LONG id, LONG pt )
{
	extern const WORD	fname_obj[NO_FNAMES];
	extern const WORD	fstyle_obj[NO_FSTYLES];
	extern const WORD	fsize_obj[NO_FSIZES];
	extern const WORD	fname_ctrl[5];
	extern const WORD	fstyle_ctrl[5];
	extern const WORD	fsize_ctrl[5];

	LBOX_ITEM	*name_list;
	LBOX_ITEM	*style_list;
	LBOX_ITEM	*size_list;
	LIST_BOX	*lbox_name;
	LIST_BOX	*lbox_style;
	LIST_BOX	*lbox_size;
	FNT	*font;
	
	font = build_lists( fnt_dialog->font_list, id, pt, &name_list, &style_list, &size_list );	/* Listen aufbauen */

	if ( font )																/* konnten die Listen erzeugt werden? */
	{
		LBOX_ITEM	*tmp;
		WORD	index;
		
		for ( index = 0, tmp = name_list; tmp && ( tmp->selected == 0 ); tmp = tmp->next )	/* Index der selektieren Familie ermitteln */
			index++;

		lbox_name = lbox_create( fnt_dialog->tree, slct_family, set_str_item, name_list,
										 NO_FNAMES, index - (NO_FNAMES / 2), fname_ctrl, fname_obj,
										 LBOX_VERT + LBOX_AUTO + LBOX_AUTOSLCT + LBOX_REAL + LBOX_SNGL, 20, fnt_dialog, fnt_dialog->dialog,
										 0, 0, 0, 0 );
		
		if ( lbox_name )													/* konnte die Listbox erzeugt werden? */
		{
			for ( index = 0, tmp = style_list; tmp && ( tmp->selected == 0 ); tmp = tmp->next )	/* Index des selektieren Stils ermitteln */
				index++;
			
			if ( tmp == 0L )												/* nichts selektiert? */
				index = 0;
		
			lbox_style = lbox_create( fnt_dialog->tree, slct_style, set_str_item, style_list,
											  NO_FSTYLES, index - (NO_FSTYLES / 2), fstyle_ctrl, fstyle_obj, 
											  LBOX_VERT + LBOX_AUTO + LBOX_AUTOSLCT + LBOX_REAL + LBOX_SNGL, 40, fnt_dialog, fnt_dialog->dialog,
											 0, 0, 0, 0 );
			
			if ( lbox_style )												/* konnte die Listbox erzeugt werden? */
			{
				for ( index = 0, tmp = size_list; tmp && ( tmp->selected == 0 ); tmp = tmp->next )	/* Index der selektierten Groesse ermitteln */
					index++;

				if ( tmp == 0L )											/* nichts selektiert? */
					index = 0;
			
				lbox_size = lbox_create( fnt_dialog->tree, slct_size, set_str_item, size_list,
												 NO_FSIZES, index - (NO_FSIZES / 2), fsize_ctrl, fsize_obj, 
												 LBOX_VERT + LBOX_AUTO + LBOX_AUTOSLCT + LBOX_REAL + LBOX_SNGL, 60, fnt_dialog, fnt_dialog->dialog,
												 0, 0, 0, 0 );
				
				if ( lbox_size )											/* konnte die Listbox erzeugt werden? */
				{
					fnt_dialog->fnt_name = lbox_name;
					fnt_dialog->fnt_style = lbox_style;
					fnt_dialog->fnt_size = lbox_size;
					
					return( font );
				}
				else
					lbox_delete( lbox_style );
			}
			lbox_delete( lbox_name );
		}
		lbox_free_list( size_list );									/* Speicher fuer die Punkt-Liste freigeben */
		lbox_free_list( style_list );									/* Speicher fuer die Stil-Liste freigeben */
		lbox_free_list( name_list );									/* Speicher fuer die Namens-Liste freigeben */
	}
	return( 0L );
}

/*----------------------------------------------------------------------------------------*/ 
/* Listen fuer die Listboxen bauen																			*/
/* Funktionsergebnis:	Zeiger auf den ausgewaehlten Font oder 0L (Fehler)						*/
/*	font_list:				Zeiger auf die Font-Strukturen												*/
/*	id:						ID des Fonts																		*/
/*	pt:						Hoehe in Punkten																	*/
/*	font_names:				Adresse des Zeigers auf die Namensliste									*/
/*	font_styles:			Adresse des Zeigers auf die Stilliste										*/
/*	font_sizes:				Adresse des Zeigers auf die Hoehenliste										*/
/*----------------------------------------------------------------------------------------*/ 
static FNT	*build_lists( FNT *font_list, LONG id, LONG pt, LBOX_ITEM **font_names, LBOX_ITEM **font_styles, LBOX_ITEM **font_sizes )
{
	LBOX_ITEM	*names;
	FNT	*family;
	FNT	*font;
	
	names = build_name_list( font_list, id, &family, &font );	/* Liste mit Namen der Fontfamilien aufbauen */
	
	if ( names )															/* genuegend Speicher fuer die Liste? */
	{
		LBOX_ITEM	*styles;
		
		if ( family == 0L )												/* konnte der Font gefunden werden? */
		{
			names->selected = 1;
			family = (FNT *) names->data;								/* ersten Font der Liste auswaehlen */
			font = family;
			id = font->id;
		}
			
		styles = build_style_list( family, id );					/* Liste mit Fontstilen aufbauen */
		
		if ( styles )
		{
			LBOX_ITEM	*sizes;
			LBOX_ITEM	*slct;
			
			sizes = build_pt_list( font, pt, &slct );				/* Liste mit Punkthoehen aufbauen */
		
			if ( sizes )
			{
				*font_names = names;										/* Zeiger auf die Namensliste */
				*font_styles = styles;									/* Zeiger auf die Stilliste */
				*font_sizes = sizes;										/* Zeiger auf die Hoehenliste */
				return( font );											/* Zeiger auf den Font */
			}
			else
				lbox_free_list( styles );								/* Speicher fuer die Stil-Liste freigeben */
		}
		else
			lbox_free_list( names );									/* Speicher fuer die Names-Liste freigeben */
	}
	return( 0L );
}

/*----------------------------------------------------------------------------------------*/ 
/* Verkettete Liste mit Namen der Fontfamilien fuer die Listbox erstellen						*/
/* Funktionsergebnis:	Zeiger auf die Liste																*/
/*	font:						Zeiger auf die Font-Struktur der ersten Familie							*/
/* id:						ID des angewaehlten Fonts														*/
/*	family_index:			Index des LBOX_ITEMs der aktuellen Familie								*/
/*	family:					Zeiger auf die angewaehlte Familie oder 0L wird zurueckgeliefert		*/
/*	fnt:						Zeiger auf den ausgewaehlten Font oder 0L wird zurueckgeliefert		*/
/*----------------------------------------------------------------------------------------*/ 
static LBOX_ITEM	*build_name_list( FNT *font, LONG id, FNT **slct_family, FNT **slct_font )
{
	LBOX_ITEM	*name_list;
	LBOX_ITEM	**last;
	FNT	*family;
		
	name_list = 0L;														/* Zeiger auf die Namensliste initialisieren */
	last = &name_list;
	
	*slct_family = 0L;
	*slct_font = 0L;
	
	family = 0L;
	
	while ( font )
	{
		LBOX_ITEM	*item;
		
		if (( family == 0L ) || strcmp( font->family_name, family->family_name ))	/* unterschiedliche Familie? */
		{
			family = font;													/* Zeiger auf ersten Font der naechsten Familie */

			item = Malloc( sizeof( LBOX_ITEM ));					/* Speicher fuer LBOX_ITEM anfordern */
			
			if ( item )
			{
				*last = item;												/* mit dem vorhergehenden LBOX_ITEM verketten */
				last = &item->next;										/* Adresse des naechsten Verkettungszeigers */
				
				item->next = 0L;
				item->data = font;
				item->name = font->family_name;						/* Zeiger auf den Familiennamen */
				item->selected = 0;
			}
		}
		
		if ( font->id == id )											/* ausgewaehlter Font? */
		{
			item->selected = 1;
			*slct_family = family;
			*slct_font = font;
		}

		font = font->next;												/* naechster Font */
	}
	return( name_list );													/* Zeiger auf die Liste zurueckliefern */
}

/*----------------------------------------------------------------------------------------*/ 
/* Verkettete Liste mit Namen der Fontstile fuer die Listbox erstellen							*/
/* Funktionsergebnis:	Zeiger auf die Liste																*/
/*	family:					Zeiger auf die erste Font-Struktur der Familie							*/
/* id:						ID des angewaehlten Fonts														*/
/*----------------------------------------------------------------------------------------*/ 
static LBOX_ITEM	*build_style_list( FNT *family, LONG id )
{
	LBOX_ITEM	*style_list;
	LBOX_ITEM	**last;
	FNT	*font;
	
	style_list = 0L;														/* Zeiger auf die Stilliste initialisieren */
	last = &style_list;
	
	font = family;															/* Zeiger auf den ersten Font der Familie */
	
	while ( font )
	{
		LBOX_ITEM	*item;
		
		if ( strcmp( font->family_name, family->family_name ) == 0)	/* gleiche Familie? */
		{
			if (( item = Malloc( sizeof( LBOX_ITEM ))) != 0 )	/* Speicher fuer LBOX_ITEM anfordern */
			{
				*last = item;
				last = &item->next;
				
				item->next = 0L;
				item->data = font;
				item->name = font->style_name;						/* Zeiger auf den Stil-Namen */
	
				if ( font->id == id )									/* handelt es sich um den angewaehlten Font? */
					item->selected = 1;
				else
					item->selected = 0;
			}
		}
		font = font->next;												/* naechster Font der Familie */
	}
	return( style_list );												/* Zeiger auf die Liste zurueckliefern */
}

/*----------------------------------------------------------------------------------------*/ 
/* Verkettete Liste mit Punkthoehen fuer die Listbox erstellen										*/
/* Funktionsergebnis:	Zeiger auf die Liste																*/
/*	font:						Zeiger auf die Font-Struktur													*/
/*	size:						eingestellte Punktgroesse															*/
/*----------------------------------------------------------------------------------------*/ 
static LBOX_ITEM	*build_pt_list( FNT *font, LONG size, LBOX_ITEM **selected )
{
	LBOX_ITEM	*font_sizes;
	LBOX_ITEM	**last;
	WORD	i;
	
	*selected = 0L;
	font_sizes = 0L;
	last = &font_sizes;
	
	for ( i = 0; i < font->npts; i++ )
	{
		LBOX_ITEM	*item;
		
		if (( item = Malloc( sizeof( LBOX_ITEM ) + 6 )) != 0 )	/* Speicher fuer LBOX_ITEM und fuer String anfordern */
		{
			BYTE	*str;
			
			str = (BYTE *) (item + 1);									/* Zeiger auf Platz fuer den String */
			fixed_to_str( str, 4, ((LONG) font->pts[i] ) << 16 );	/* Punkthoehe in String umwandeln */

			*last = item;
			last = &item->next;
			
			item->next = 0L;
			item->data = font;											/* Zeiger auf die zugehoerige Font-Struktur */
			item->name = str;												/* Zeiger auf den String */

			if (((LONG) font->pts[i] << 16 ) == size )			/* handelt es sich um die angewaehlte Punktgroesse? */
			{
				*selected = item;											/* Zeiger auf den selektierten Eintrag */
				item->selected = 1;										/* Eintrag ist selektiert */
			}
			else
				item->selected = 0;										/* Eintrag ist nicht selektiert */
		}
	}
	return( font_sizes );												/* Zeiger auf die Liste zurueckliefern */
}

/*----------------------------------------------------------------------------------------*/ 
/* Speicher fuer Listboxen und Listen freigeben															*/
/* Funktionsresultat:	-																						*/
/*	fnt_dialog:				Zeigehr auf die Dialog-Struktur												*/
/*----------------------------------------------------------------------------------------*/ 
static void	free_lboxes( FNT_DIALOG *fnt_dialog )
{
	if ( fnt_dialog->fnt_size )
	{
		lbox_free_items( fnt_dialog->fnt_size );					/* Speicher fuer LBOX_ITEMs freigeben */
		lbox_delete( fnt_dialog->fnt_size );						/* Speicher fuer die Listbox-Struktur freigeben */
		fnt_dialog->fnt_size = 0L;
	}
		
	if ( fnt_dialog->fnt_style )
	{
		lbox_free_items( fnt_dialog->fnt_style );				/* Speicher fuer LBOX_ITEMs freigeben */
		lbox_delete( fnt_dialog->fnt_style );						/* Speicher fuer die Listbox-Struktur freigeben */
		fnt_dialog->fnt_style = 0L;
	}
	
	if ( fnt_dialog->fnt_name )
	{
		lbox_free_items( fnt_dialog->fnt_name );					/* Speicher fuer LBOX_ITEMs freigeben */
		lbox_delete( fnt_dialog->fnt_name );						/* Speicher fuer die Listbox-Struktur freigeben */
		fnt_dialog->fnt_name = 0L;
	}
}

#if CALL_MAGIC_KERNEL == 0

static void	*_malloc( LONG size )
{
#undef	Malloc
	
	if ( is_magic )
		return( Malloc( size ));
	else
		return( malloc( size ));

#define	Malloc( size ) _malloc( size )
}

static void	_mfree( void *addr )
{
#undef	Mfree

	if ( is_magic )
		Mfree( addr );
	else
		free( addr );

#define	Mfree( addr ) _mfree( addr )
}

/*----------------------------------------------------------------------------------------*/ 
/* Speicher fuer alle Eintraege in der Listbox freigeben, Pure-C-Funktionen benutzen			*/
/* Funktionsresultat:	1																						*/
/*	box:						Zeiger auf die LIST_BOX-Struktur												*/
/*----------------------------------------------------------------------------------------*/ 
static void	free_items( LIST_BOX *box )
{
	free_list( box->items );
}

/*----------------------------------------------------------------------------------------*/ 
/* Speicher fuer alle Eintraege in der Listbox freigeben, Pure-C-Funktionen benutzen			*/
/* Funktionsresultat:	1																						*/
/* item:						Zeiger auf das erste LBOX_ITEM												*/
/*----------------------------------------------------------------------------------------*/ 
static void	free_list( LBOX_ITEM *item )
{
	while ( item )
	{
		LBOX_ITEM *next;
		
		next = item->next;
		Mfree( item );														/* Speicher freigeben */
		item = next;														/* naechstes Element */
	}
}

#endif

/*----------------------------------------------------------------------------------------*/ 
/* Eintraege in einer Listbox anwaaehlbar machen															*/
/* Funktionsergebnis:	-																						*/
/*	tree:						Zeiger auf den Objektbaum														*/
/*	objs:						Feld mit n Objektnummern der Listbox-Objekte								*/
/*	n:							Anzahl der Listbox-Objekte														*/
/*----------------------------------------------------------------------------------------*/ 
static void	enable_lbox( OBJECT *tree, WORD objs[], WORD n )
{
	while ( n > 0 )
	{
		WORD	obj;
		
		obj = *objs++;
		n--;
		
		obj_ENABLED( tree, obj );
		obj_TOUCHEXIT( tree, obj );
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* Eintraege in einer Listbox nicht anwaehlbar machen													*/
/* Funktionsergebnis:	-																						*/
/*	tree:						Zeiger auf den Objektbaum														*/
/*	objs:						Feld mit n Objektnummern der Listbox-Objekte								*/
/*	n:							Anzahl der Listbox-Objekte														*/
/*----------------------------------------------------------------------------------------*/ 
static void	disable_lbox( OBJECT *tree, WORD objs[], WORD n )
{
	while ( n > 0 )
	{
		WORD	obj;
		
		obj = *objs++;
		n--;
		
		obj_DISABLED( tree, obj );
		obj_NOT_TOUCHEXIT( tree, obj );
	}
}
	
/*----------------------------------------------------------------------------------------*/ 
/* Fontliste aufbauen																							*/
/* Funktionsergebnis:	Zeiger auf die Liste oder 0L (Fehler)										*/
/*	vdi_handle:				Handle der Workstation															*/
/*	no_fonts:				Anzahl der Fonts																	*/
/*	font_flags:				Art der anzuzeigenden Fonts													*/
/*----------------------------------------------------------------------------------------*/ 
static FNT	*build_font_list( WORD vdi_handle, WORD no_fonts, WORD font_flags )
{
	XFNT_INFO	*info;
	FNT	*font;
	FNT	**font_tab;
	TMP_FNT	*tmp;
	WORD	i;
	WORD	font_cnt;
	LONG	len;
	WORD	call_xfntinfo;
		
	len = sizeof( XFNT_INFO ) + sizeof( TMP_FNT ) + ( no_fonts * sizeof( FNT *));
		
	info = (XFNT_INFO *) Malloc( len );								/* Zeiger auf die XFNT-Info-Struktur */
	tmp = (TMP_FNT *) ( info + 1 );									/* Zeiger auf temporaere Font-Struktur */
	font_tab = (FNT **) ( tmp + 1 );									/* Zeiger auf Fonttabelle */
	
	font_cnt = 0;
	
	call_xfntinfo = use_vqt_xfontinfo();							/* Flag dafuer, ob vqt_xfntinfo() aufgerufen werden soll */
	
	for ( i = 1; i <= no_fonts; i++ )	
	{
		LONG	name_len;
		LONG	family_len;
		LONG	style_len;
		
		UWORD	flags;
		UWORD	font_format;
		
		tmp->npts = 0;														/* Anzahl der vorhandenen Punkthoehen initialisieren */
		tmp->mono = 0;														/* aequidistanz-Flag initialisieren */	

		tmp->id = vqt_ext_name( vdi_handle, i, tmp->full_name, &font_format, &flags );	/* vollstaendigen Namen und Typ erfragen */
		tmp->id = vst_font( vdi_handle, tmp->id );				/* Font einstellen */

		if ( tmp->full_name[32] )										/* Vektorfont? */
		{
			tmp->outline = 1;												/* Vektorfont */
			
			if ( call_xfntinfo )											/* vqt_xfontinfo() benutzen? */
			{
				WORD	j;
				
				if ( flags & 0x0001 )									/* aequidistant? */
					tmp->mono = 1;

				info->size = sizeof( XFNT_INFO );
				vqt_xfntinfo( vdi_handle, 0x2ff, tmp->id, 0, info );
			
				vstrcpy( tmp->family_name, info->family_name );	/* Name der Fontfamilie */
				vstrcpy( tmp->style_name, info->style_name );		/* Name des Stils */
 
 				tmp->npts = info->pt_cnt;								/* Anzahl der vordefinierten Punktgroessen */
 				for ( j = 0; j < info->pt_cnt; j++ )
 					tmp->pts[j] = info->pt_sizes[j];
			}
			else																/* vqt_xfntinfo() ist nicht vorhanden */
			{
				BYTE	buf[1024];
				BYTE	path[128];
							
				vqt_fontheader( vdi_handle, buf, path );

				vmemcpy( tmp->family_name, buf + FH_SFACN, 16 );	/* Name der Fontfamilie */
				tmp->family_name[16] = 0;
				vmemcpy( tmp->style_name, buf + FH_FNTFM, 14 );	/* Name des Stils */
				tmp->style_name[14] = 0;

				if ( buf[FH_CLFGS] & 2 )								/* aequidistant?	*/
					tmp->mono = 1;
			}
		
		}
		else																	/* Bitmap-Font */
		{
			tmp->outline = 0;
			vstrcpy( tmp->family_name, tmp->full_name );			/* Familienname ist gleich dem Fontnamen */
			vstrcpy( tmp->style_name, "   -" );						/* kein Stilname */
		}
		
		if ( tmp->npts == 0 )											/* sind die Punkthoehen noch nicht bekannt? */
			tmp->npts = get_pt_sizes( vdi_handle, tmp->pts );	/* Punkthoehen erfragen */

		if ( tmp->outline == 0 )										/* Bitmap-Font? */
			tmp->mono = is_bitmap_mono( vdi_handle, tmp->pts[tmp->npts - 1] );	/* ermitteln, ob der Font aequidistant ist */
		
		name_len = strlen( tmp->full_name ) + 1;					/* Laenge des vollstaendigen Namens inklusive Null-Byte */
		family_len = strlen( tmp->family_name ) + 1;				/* Laenge des Familienamens inklusive Null-Byte */
		style_len = strlen( tmp->style_name ) + 1;				/* Laenge des Stilamens inklusive Null-Byte */

		len = sizeof( FNT ) + name_len + family_len + style_len + tmp->npts;	/* fuer die Struktur benoetigter Speicher */

		if ( tmp->mono )													/* Font aequidistant? */
		{
			if (( font_flags & FNTS_MONO ) == 0 )					/* keine aequidistanten Fonts anzeigen? */
				continue;
		}	
		else																	/* Font proportional */
		{
			if (( font_flags & FNTS_PROP ) == 0 )					/* keine proportionalen Fonts anzeigen? */
				continue;
		}
		
		if ( tmp->outline )												/* Vektorfont? */
		{
			if (( font_flags & FNTS_OUTL ) == 0 )					/* keine Vektorfonts anzeigen? */
				continue;
		}
		else																	/* Bitmap-Font */
		{
			if (( font_flags & FNTS_BTMP ) == 0 )					/* keine Bitmap-Fonts anzeigen? */
				continue;
		}

		font = Malloc( len );
		
		if ( font )															/* Speicher vorhanden? */
		{
			WORD	j;
			
			font->next = 0L;
			font->display = 0L;											/* keine Anzeige-Funktion, da VDI-Font */
			font->id = tmp->id;											/* ID des Fonts */
			font->index = i;												/* Index des Fonts */
			font->npts = tmp->npts;										/* Anzahl der vorhandenen Punkthoehen */
			font->mono = tmp->mono;										/* aequidistanz-Flag */
			font->outline = tmp->outline;								/* Vektorfont-Flag */
			
			font->full_name = (BYTE *) (font + 1);
			vstrcpy( font->full_name, tmp->full_name );			/* vollstaendiger Name */

			font->family_name = font->full_name + name_len;
			vstrcpy( font->family_name, tmp->family_name );		/* Familienname */

			font->style_name = font->family_name + family_len;
			vstrcpy( font->style_name, tmp->style_name );			/* Stilname */

			font->pts = font->style_name + style_len;
			for ( j = 0; j < tmp->npts; j++ )						/* Punkthoehen kopieren */
				font->pts[j] = tmp->pts[j];

			font_tab[font_cnt] = font;									/* Fontstruktur in Tabelle eintragen */
			font_cnt++;														/* Anzahl der Fonts erhoehen */
		}
	}

	sort_FNTs( font_tab, font_cnt );									/* Fonts sortieren und verketten */

	font = font_tab[0];
	
	Mfree( info );															/* Speicher freigeben */

	return( font );
}

/*----------------------------------------------------------------------------------------*/ 
/* Punktgroessen fuer einen Bitmap-Font ermitteln															*/
/* Funktionsergebnis:	Anzahl der Punkthoehen															*/
/*	pts:						Zeiger auf ein Feld fuer die Punkthoehen										*/
/*----------------------------------------------------------------------------------------*/ 
static WORD	get_pt_sizes( WORD vdi_handle, BYTE *pts )
{		
	WORD	j;
	WORD	pt_last;
	WORD	pt;
	WORD	npts;
	
	npts = 0;																/* Anzahl der Punkthoehen */
	pt_last = 99 + 1;														/* groesste Punkthoehe sind 99 pt */
	
	while ( pt_last > 1 )												/* schon alle Punkthoehen durchgegangen? */
	{
		WORD	tmp;

		pt = vst_point( vdi_handle, pt_last - 1, &tmp, &tmp, &tmp, &tmp );
		if ( pt == pt_last )												/* laesst sich keine kleinere Punkthoehe mehr einstellen? */
			break;															/* naechsten Font */
				
		pts[npts] = pt;
		npts++;																/* Anzahl der Punkthoehen inkrementieren */

		pt_last = pt;														/* letzte Punkthoehe merken */
	}
		
	for ( j = 0; j < (npts/2); j++ )									/* Reihenfolge umkehren... */
	{
		WORD	point;
		
		point = pts[j];													/* tauschen... */
		pts[j] = pts[npts - j - 1];
		pts[npts - j - 1] = point;
	}
	
	return( npts );														/* Anzahl der Punkthoehen */
}

/*----------------------------------------------------------------------------------------*/ 
/* ueberpruefen, ob ein Bitmap-Font aequidistant ist														*/
/* Funktionsergebnis:	0: Font ist proportional 1: Font ist aequidistant						*/
/*	pt:						testweise einzustellende Punkthoehe											*/
/*----------------------------------------------------------------------------------------*/ 
static WORD	is_bitmap_mono( WORD vdi_handle, WORD pt )
{
	WORD	first_ade;
	WORD	last_ade;
	WORD	d[8];
	WORD	first_width;
	WORD	width;
	
	vst_point( vdi_handle, pt, d, d, d, d );						/* groesste Punkthoehe einstellen */
	vqt_fontinfo( vdi_handle, &first_ade, &last_ade, d, d, d );	/* Index des ersten und letzten Zeichens erfragen */
	
	vqt_width( vdi_handle, first_ade, &first_width, d, d );	/* Breite des ersten Zeichens */

	do			
	{
		first_ade++;														/* naechstes Zeichen */
		vqt_width( vdi_handle, first_ade, &width, d, d );
		
		if ( first_width != width )									/* verschiedene Breite? */
			return( 0 );													/* Font ist proportional */	

	} while ( first_ade <= last_ade );								/* schon alle Zeichen untersucht? */

	return( 1 );															/* Font ist aequidistant */	
}

/*----------------------------------------------------------------------------------------*/ 
/* Fonts mit Quicksort sortieren und anschliessend verketten											*/
/* Funktionsergebnis:	-																						*/
/*	fonts:					vorsortiertes Feld mit Zeigern auf die Font-Strukuren					*/
/*	cnt:						Anzahl der Fonts (Laenge von fonts)											*/
/*----------------------------------------------------------------------------------------*/ 
static void	sort_FNTs( FNT **fonts, WORD font_cnt )
{
#if CALL_MAGIC_KERNEL
	shelsort( fonts, font_cnt, sizeof(FNT *), (int (*)(void *, void *, void *))cmp_font_names, 0L );	/* Fonts sortieren, so dass die Familien aufeinander folgen */
#else
	qsort( fonts, font_cnt, sizeof(FNT *), cmp_font_names );	/* Fonts nach Familien aufeinander folgenden sortieren */
#endif

	while ( font_cnt > 0 )
	{
		FNT	*font;

		font = *fonts++;

		if ( font_cnt > 1 )
			font->next = *fonts;											/* Zeiger auf die naechste Font-Struktur */
		else
			font->next = 0L;												/* kein Nachfolger */

		font_cnt--;
	}	
}

/*----------------------------------------------------------------------------------------*/ 
/* Fontfamilennamen vergleichen und bei gleichem Namen anhand der ID einordnen (Qsort)		*/
/* Funktionsergebnis:	< 0: ( a < b ); 0: ( a = b ); > 0: ( a > b )								*/
/*	a:							Zeiger																				*/
/*	b:							Zeiger																				*/
/*----------------------------------------------------------------------------------------*/ 
static int	cmp_font_names( FNT **a, FNT **b )
{
	FNT	*c;
	FNT	*d;
	WORD	cmp;
	
	c = *a;
	d = *b;
	
	cmp = strcmp( c->family_name, d->family_name );

	if ( cmp == 0 )														/* gleicher Familienname? */
	{
		if ( c->id == d->id )
			cmp = 0;															/* a == b */
		else if ( c->id > d->id )
			cmp = 1;															/* a > b */
		else
			cmp = -1;														/* a < b */
	}

	return( cmp );
}

/*----------------------------------------------------------------------------------------*/ 
/* Zeiger auf die Struktur des Fonts mit der ID <id> zurueckliefern								*/
/* Funktionsergebnis:	Zeiger auf die FNT-Struktur													*/
/*	font:						Zeiger auf den ersten Font der Liste										*/
/*	id:						ID des gesuchten Fonts															*/
/*----------------------------------------------------------------------------------------*/ 
static FNT	*get_FNT( FNT *font, LONG id )
{
	while ( font )
	{
		if ( font->id == id )
			break;
					 
		font = font->next;
	}
	
	return( font );
}

/*----------------------------------------------------------------------------------------*/ 
/* Anzahl der Fonts ermitteln																					*/
/* Funktionsergebnis:	Anzahl der Fonts																	*/
/*	font:						Zeiger auf den ersten Font														*/
/*----------------------------------------------------------------------------------------*/ 
static WORD	count_fonts( FNT *font )
{
	WORD	cnt;
	
	cnt = 0;

	while ( font )
	{
		font = font->next;
		cnt++;
	}
	return( cnt );
}

/*----------------------------------------------------------------------------------------*/ 
/* Index erstes Element in der Listbox ueberpruefen (nach Wechsel des Inhalts)					*/
/* Funktionsergebnis:	-																						*/
/*	box:						Zeiger auf die Listbox															*/
/*	last_top:				Index des bisher ersten sichtbaren Elements								*/
/*	last_cnt:				Anzahl der bisherigen Elemente												*/
/*----------------------------------------------------------------------------------------*/ 
static void	set_top( LIST_BOX *box, WORD last_top, WORD last_cnt, GRECT *rect )
{
	WORD	cnt;
	WORD	first;
	
	cnt = lbox_cnt_items( box );										/* Anzahl der Elemente in der Listbox */
	
	if ( cnt <= lbox_get_visible( box ))							/* weniger Elemente als die Box Eintraege hat? */
		first = 0;															/* erstes Element ist auch das erste sichtbare */
	else
		first = (WORD) (((LONG) last_top ) * cnt / last_cnt );	/* erstes sichbares Element berechnen */

	lbox_set_slider( box, first, rect );							/* Slider positionieren */
	lbox_update( box, rect );											/* Listbox zeichnen */
}

/*----------------------------------------------------------------------------------------*/ 
/* Die zu einer eingestellten Hoehe naheliegendste verfuegbare Hoehe zurueckliefern				*/
/* Funktionsergebnis:	einstellbare Hoehe in 1/65536 Punkten										*/
/*	item:						Zeiger auf die Liste der verfuegbaren Punkthoehen							*/
/*	slct:						Adresse des Zeigers auf den angewaehlten Eintrag							*/
/*	font:						Zeiger auf die Font-Struktur													*/
/*	pt:						eingestellte Hoehe																	*/
/*----------------------------------------------------------------------------------------*/ 
static LONG	slct_closest_height( LBOX_ITEM *item, LBOX_ITEM **slct, FNT *font, LONG pt )
{
	LBOX_ITEM	*size;
	LONG	diff;
	LONG	set_pt;
	WORD	i;
	
	diff = 0x7fffffffL;

	set_pt = 0;
	size = item;
						
	for ( i = 0; i < font->npts; i++ )
	{
		LONG	tmp;
		
		tmp = ((LONG) font->pts[i] << 16 ) - pt;
		if ( tmp < 0 ) 
			tmp = -tmp;
			
		if ( tmp < diff )													/* Unterschied kleiner als bisher? */
		{
			set_pt = ((LONG) font->pts[i] ) << 16;					/* einstellbare Punkthoehe */
			diff = tmp;
			size = item;
		}
		item->selected = 0;												/* deselektieren */
		item = item->next;
	}
	
	size->selected = 1;													/* Element selektieren */
	*slct = size;															/* Zeiger auf angewaehlten Eintrag */
	
	return( set_pt );														/* realisierbare Hoehe zurueckliefern */
}

/*----------------------------------------------------------------------------------------*/ 
/* Speicher fuer Resource anfordern und es kopieren														*/
/* Funktionsergebnis:	Zeiger auf den Resource-Header oder 0L (Fehler)							*/
/*	rsc:						Zeiger auf das zu kopierende Resource										*/
/*	len:						Laenge des Resource																*/
/*----------------------------------------------------------------------------------------*/ 
static RSHDR	*copy_rsrc( RSHDR *rsc, LONG len )
{
	RSHDR	*new;

	new = Malloc( len );
	
	if ( new )
	{
		WORD	dummy_global[15];

#if CALL_MAGIC_KERNEL
		vmemcpy( new, rsc, (UWORD) len );								/* Resource kopieren */
#else
		vmemcpy( new, rsc, len );										/* Resource kopieren */
#endif
		_rsrc_rcfix( dummy_global, new );							/* Resource anpassen */
	}
	return( new );															/* Zeiger auf den Resource-Header */
}

/*----------------------------------------------------------------------------------------*/ 
/* Resource und dazugehoerige Strukturen initialisieren												*/
/* Funktionsergebnis:	-																						*/
/*	rsh:						Zeiger auf den Resource-Header												*/
/*	fnt_dialog:				Zeiger auf die Dialog-Struktur												*/
/*	dialog_flags:			...																					*/
/*----------------------------------------------------------------------------------------*/ 
static void	init_rsrc( RSHDR *rsh, FNT_DIALOG *fnt_dialog, WORD dialog_flags )
{
	OBJECT	**tree_addr;
	OBJECT	*tree;
	OBJECT	*obj;

	fnt_dialog->tree_addr = (OBJECT **)(((UBYTE *)rsh) + rsh->rsh_trindex);	/* Zeiger auf die Objektbaumtabelle holen */

	fnt_dialog->tree_count = rsh->rsh_ntree;						/* und Anzahl der Objektbaeume (von 1 ab gezaehlt) bestimmen */

	fnt_dialog->fstring_addr = (BYTE **)((UBYTE *)rsh + rsh->rsh_frstr);

	tree_addr = fnt_dialog->tree_addr;
	tree = tree_addr[FONTSL];
	
	fnt_dialog->udef_sample_text.ub_code = sample_text;
	obj = tree + FSAMPLE;
	obj->ob_type = G_USERDEF;
	obj->ob_spec.userblk = &fnt_dialog->udef_sample_text;
	obj->ob_x -= 1;
	obj->ob_y -= 3;
	obj->ob_width += 3;
	obj->ob_height += 5;
	 
	fnt_dialog->udef_check_box.ub_code = check_box;
	obj = tree + CHECK_NAME;
	make_check_box( obj, &fnt_dialog->udef_check_box );		/* in Checkbox-USERDEF wandeln */
	obj->ob_x -= 1;														/* um ein Pixel nach links verschieben */

	obj = tree + CHECK_STYLE;
	make_check_box( obj, &fnt_dialog->udef_check_box );		/* in Checkbox-USERDEF wandeln */

	obj = tree + CHECK_SIZE;
	make_check_box( obj, &fnt_dialog->udef_check_box );		/* in Checkbox-USERDEF wandeln */

	obj = tree + CHECK_RATIO;
	make_check_box( obj, &fnt_dialog->udef_check_box );		/* in Checkbox-USERDEF wandeln */
	obj->ob_y += 4;														/* um 4 Pixel nach rechts verschieben */
	
	obj = tree + FPT_USER;
	obj->ob_y += 4;														/* FTEXT fuer Punkthoehe um 4 Pixel nach unten verschieben */

	obj = tree + F_BH;
	obj->ob_x += 1;														/* um 1 Pixel nach rechts (wegen der Checkbox) */
	obj->ob_y += 4;														/* FTEXT fuer B/H um 4 Pixel nach unten verschieben */

	tree[FNAME_UP].ob_y -= 1;											/* Buttons der Slider um 1 Pixel nach oben bewegen */
	tree[FNAME_DOWN].ob_y -= 1;
	tree[FSTL_UP].ob_y -= 1;
	tree[FSTL_DOWN].ob_y -= 1;
	tree[FPT_UP].ob_y -= 1;
	tree[FPT_DOWN].ob_y -= 1;

	if (( dialog_flags & FNTS_3D ) == 0 )							/* kein 3D-Look */
		no3d_rsrc( rsh, tree );											/* 3D-Flags loeschen und Objekte anpassen */
}

/*----------------------------------------------------------------------------------------*/ 
/* Position und Ausmasse einer Checkbox korrigieren														*/
/* Funktionsergebnis:	-																						*/
/*	obj:						Zeiger auf das Objekt															*/
/*----------------------------------------------------------------------------------------*/ 
static void	make_check_box( OBJECT *obj, USERBLK *userblk )
{
	obj->ob_type = G_USERDEF;											/* Typ auf USERDEF aendern */
	obj->ob_spec.userblk = userblk;
	obj->ob_x += 3;
	obj->ob_y += 3;
	obj->ob_width = 11;
	obj->ob_height = 11;
}

/*----------------------------------------------------------------------------------------*/ 
/* 3D-Flags loeschen und Objektgroessen anpassen, wenn 3D-Look ausgeschaltet ist					*/
/* Funktionsergebnis:	-																						*/
/*	rsh:						Zeiger auf den Resource-Header												*/
/*	tree:						Zeiger auf den Objektbaum														*/
/*----------------------------------------------------------------------------------------*/ 
static void	no3d_rsrc( RSHDR *rsh, OBJECT *tree )
{
	OBJECT	*obj;
	UWORD	i;
	
	obj = (OBJECT *) (((BYTE *) rsh ) + rsh->rsh_object );	/* Zeiger auf die Objekte */
	
	i = rsh->rsh_nobs;													/* Anzahl der Objekte */
	
	while ( i > 0 )
	{
		obj->ob_flags &= 0x00ff;										/* 3D-Flags loeschen */
		obj++;																/* naechstes Objekt */
		i--;
	}

	tree[FNAME_UP].ob_spec.obspec.framesize = 1;					/* innen 1 Pixel Rahmen */
	tree[FNAME_DOWN].ob_spec.obspec.framesize = 1;				/* innen 1 Pixel Rahmen */
	tree[FNAME_WHITE].ob_spec.obspec.framesize = 1;				/* innen 1 Pixel Rahmen */

	tree[FNAME_BACK].ob_spec.obspec.interiorcol = 1;			/* Farbe schwarz */
	tree[FNAME_BACK].ob_spec.obspec.fillpattern = 1;			/* Muster */

	tree[FSTL_UP].ob_spec.obspec.framesize = 1;					/* innen 1 Pixel Rahmen */
	tree[FSTL_DOWN].ob_spec.obspec.framesize = 1;				/* innen 1 Pixel Rahmen */
	tree[FSTL_WHITE].ob_spec.obspec.framesize = 1;				/* innen 1 Pixel Rahmen */
	tree[FSTL_BACK].ob_spec.obspec.interiorcol = 1;				/* Farbe schwarz */
	tree[FSTL_BACK].ob_spec.obspec.fillpattern = 1;				/* Muster */

	tree[FPT_UP].ob_spec.obspec.framesize = 1;					/* innen 1 Pixel Rahmen */
	tree[FPT_DOWN].ob_spec.obspec.framesize = 1;					/* innen 1 Pixel Rahmen */
	tree[FPT_WHITE].ob_spec.obspec.framesize = 1;				/* innen 1 Pixel Rahmen */
	tree[FPT_BACK].ob_spec.obspec.interiorcol = 1;				/* Farbe schwarz */
	tree[FPT_BACK].ob_spec.obspec.fillpattern = 1;				/* Muster */

	FTEXT_to_FBOXTEXT( tree + FPT_USER );
	FTEXT_to_FBOXTEXT( tree + F_BH );
}

/*----------------------------------------------------------------------------------------*/ 
/* FTEXT in FBOXTEXT umwandeln (wird beim Ausschalten des 3D-Looks noetig)						*/
/* Funktionsergebnis:	-																						*/
/*	obj:						Zeiger auf das Objekt															*/
/*----------------------------------------------------------------------------------------*/ 
static void FTEXT_to_FBOXTEXT( OBJECT *obj )
{
	obj->ob_type = G_FBOXTEXT;											/* Typ auf FBOXTEXT aendern */
	obj->ob_spec.tedinfo->te_thickness = -1;						/* aussen 1 Pixel Rahmen */
	obj->ob_x -= 1;
	obj->ob_y -= 1;
	obj->ob_width += 2;
	obj->ob_height += 2;
}

/*----------------------------------------------------------------------------------------*/ 
/* Resource entsprechend <button_flags> anspassen														*/
/* Funktionsergebnis:	-																						*/
/*	tree:						Zeiger auf den Objektbaum														*/
/*	button_flags:			...																					*/
/*----------------------------------------------------------------------------------------*/ 
static void	adapt_rsrc( OBJECT *tree, WORD button_flags )
{
	if ( button_flags & FNTS_CHNAME )								/* Checkbox fuer die Namens-Listbox sichtbar? */
		show_check_box( tree, CHECK_NAME );
	else
		hide_check_box( tree, CHECK_NAME );

	if ( button_flags & FNTS_SNAME )									/* Checkbox fuer die Namens-Listbox selektiert? */
		obj_SELECTED( tree, CHECK_NAME );
	else
		obj_DESELECTED( tree, CHECK_NAME );

	if ( button_flags & FNTS_CHSTYLE )								/* Checkbox fuer die Stil-Listbox sichtbar? */
		show_check_box( tree, CHECK_STYLE );
	else
		hide_check_box( tree, CHECK_STYLE );

	if ( button_flags & FNTS_SSTYLE )								/* Checkbox fuer die Stil-Listbox selektiert? */
		obj_SELECTED( tree, CHECK_STYLE );
	else
		obj_DESELECTED( tree, CHECK_STYLE );
	
	if ( button_flags & FNTS_CHSIZE )								/* Checkbox fuer die Hoehen-Listbox sichtbar? */
		show_check_box( tree, CHECK_SIZE );
	else
		hide_check_box( tree, CHECK_SIZE );

	if ( button_flags & FNTS_SSIZE )									/* Checkbox fuer die Hoehen-Listbox selektiert? */
		obj_SELECTED( tree, CHECK_SIZE );
	else
		obj_DESELECTED( tree, CHECK_SIZE );
	
	if ( button_flags & FNTS_CHRATIO )								/* Checkbox fuer das B/H-Verhaeltnis sichtbar? */
		show_check_box( tree, CHECK_RATIO );
	else
		hide_check_box( tree, CHECK_RATIO );

	if ( button_flags & FNTS_SRATIO )								/* Checkbox fuer das B/H-Verhaeltnis selektiert? */
		obj_SELECTED( tree, CHECK_RATIO );
	else
		obj_DESELECTED( tree, CHECK_RATIO );

	if ( button_flags & FNTS_RATIO )									/* ist das B/H-Verhaeltnis einstellbar? */
	{
		obj_VISIBLE( tree, CHECK_RATIO );
		obj_VISIBLE( tree, F_BH_STRING );
		obj_VISIBLE( tree, F_BH );
		obj_EDITABLE( tree, F_BH );
	}
	else
	{
		obj_HIDDEN( tree, CHECK_RATIO );
		obj_HIDDEN( tree, F_BH_STRING );
		obj_HIDDEN( tree, F_BH );
		obj_NOT_EDITABLE( tree, F_BH );
	}
		
	if ( button_flags & FNTS_BSET )									/* wird der "setzen"-Button unterstuetzt? */
		obj_ENABLED( tree, FSET );
	else
		obj_DISABLED( tree, FSET );
	
	if ( button_flags & FNTS_BMARK )									/* wird der "markieren"-Button unterstuetzt? */
		obj_ENABLED( tree, FMARK );
	else
		obj_DISABLED( tree, FMARK );

	if ( button_flags & FNTS_CHNAME )								/* Checkbox fuer die Namens-Listbox sichtbar? */
		do_CHECK_NAME( tree );											/* die Namens-Listbox evtl. disablen */

	if ( button_flags & FNTS_CHSTYLE )								/* Checkbox fuer die Stil-Listbox sichtbar? */
		do_CHECK_STYLE( tree );											/* die Stil-Listbox evtl. disablen */

	if ( button_flags & FNTS_CHSIZE )								/* Checkbox fuer die Hoehen-Listbox sichtbar? */
		do_CHECK_SIZE( tree );											/* die Hoehen-Listbox evtl. disablen */

	if ( button_flags & FNTS_CHRATIO )								/* Checkbox fuer das B/H-Verhaeltnis sichtbar? */
		do_CHECK_RATIO( tree );											/* den B/H-FTEXT evtl. disablen */
}

/*----------------------------------------------------------------------------------------*/ 
/* Objekte im Dialog horizontal verschieben (nur bei umrandetem Root-Objekt noetig)			*/
/* Funktionsergebnis:	-																						*/
/*	tree:						Zeiger auf den Objektbaum														*/
/*	offset:					Verschiebung (-1 oder +1)														*/
/*----------------------------------------------------------------------------------------*/ 
static void	move_hor_obj( OBJECT *tree, WORD offset )
{
	extern const BYTE	move_objs[25];									/* Nummern der zu verschiebenden Objekte */
	WORD	i;

	for ( i = 0; i < 25; i++ )
	{
		tree[move_objs[i]].ob_x += offset;
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* Objekt zeichnen																								*/
/* Funktionsresultat:	-																						*/
/*	fnt_dialog:				Zeiger auf die Fontdialog-Struktur											*/
/*	obj:						Nummer des Objekts																*/
/*----------------------------------------------------------------------------------------*/ 
static void	redraw_obj( FNT_DIALOG *fnt_dialog, WORD obj )
{
	OBJECT	*tree;
	GRECT		rect;

	tree = fnt_dialog->tree;
	rect = *(GRECT *) &tree->ob_x;									/* Dialog-Rechteck */
	
	wind_update( BEG_UPDATE );											/* Bildschirm sperren */

	if ( fnt_dialog->dialog )											/* Fensterdialog? */
		wdlg_redraw( fnt_dialog->dialog, &rect, obj, MAX_DEPTH );
	else																		/* normaler Dialog */
		objc_draw( tree, obj, MAX_DEPTH, &rect );

	wind_update( END_UPDATE );											/* Bildschirm freigeben */
}

/*----------------------------------------------------------------------------------------*/ 
/* Nummer des aktiven Edit-Objekts setzen																	*/
/* Funktionsresultat:	Nummer des Edit-Objekts															*/
/*	fnt_dialog:				Zeiger auf die Fontdialog-Struktur											*/
/*	obj:						Nummer des neuen Edit-Objekts oder 0 (kein Edit-Objekt)				*/
/*----------------------------------------------------------------------------------------*/ 
static void	set_edit_obj( FNT_DIALOG *fnt_dialog, WORD obj )
{
	if ( fnt_dialog->dialog )											/* Fensterdialog? */
		wdlg_set_edit( fnt_dialog->dialog, obj );
	else																		/* normaler Dialog */
		fnt_dialog->edit_obj = obj;									/* Nummer des neuen Edit-Objekts fuer form_xdo() */
}

/*----------------------------------------------------------------------------------------*/ 
/* Nummer des aktiven Edit-Objekts zurueckliefern														*/
/* Funktionsresultat:	Nummer des Edit-Objekts	(0: kein Objekt aktiv)							*/
/*	fnt_dialog:				Zeiger auf die Fontdialog-Struktur											*/
/*----------------------------------------------------------------------------------------*/ 
static WORD	get_edit_obj( FNT_DIALOG *fnt_dialog )
{
	WORD	cursor;
	
	if ( fnt_dialog->dialog )											/* Fensterdialog? */
		return( wdlg_get_edit( fnt_dialog->dialog, &cursor ));
	else
		return( fnt_dialog->edit_obj );
}
	
/*----------------------------------------------------------------------------------------*/ 
/* Selektion eines Buttons loeschen und Button zeichnen												*/
/* Funktionsergebnis:	-																						*/
/*	fnt_dialog:				Zeiger auf die Fontdialog-Struktur											*/
/*	obj:						Objektnummer																		*/
/*----------------------------------------------------------------------------------------*/ 
static void	deselect_button( FNT_DIALOG *fnt_dialog, WORD obj )
{
	OBJECT	*tree;
	
	tree = fnt_dialog->tree;

	if	( tree[obj].ob_state & SELECTED )							/* ist der Button selektiert? */
	{
		evnt_timer( 40, 0 );												/* warten, damit der 3D-Effekt deutlich wird */
		obj_DESELECTED( tree, obj );
		redraw_obj( fnt_dialog, obj );
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* Button sichtbar und anwaehlbar machen (nicht zeichnen!)											*/
/* Funktionsergebnis:	-																						*/
/*	tree:						Zeiger auf den Objektbaum														*/
/*	obj:						Nummer des Objekts																*/
/*----------------------------------------------------------------------------------------*/ 
static void	show_check_box( OBJECT *tree, WORD obj )
{
	tree[obj].ob_flags &= 0xff00;
	tree[obj].ob_flags |= SELECTABLE + TOUCHEXIT;
}

/*----------------------------------------------------------------------------------------*/ 
/* Button verstecken und nicht anwaehlbar machen	(nicht zeichnen!)									*/
/* Funktionsergebnis:	-																						*/
/*	tree:						Zeiger auf den Objektbaum														*/
/*	obj:						Nummer des Objekts																*/
/*----------------------------------------------------------------------------------------*/ 
static void	hide_check_box( OBJECT *tree, WORD obj )
{
	tree[obj].ob_flags &= 0xff00;
	obj_HIDDEN( tree, obj );
	obj_DESELECTED( tree, obj );
}

/*----------------------------------------------------------------------------------------*/ 
/* Bitvektor fuer selektierte Checkboxen zurueckliefern													*/
/* Funktionsergebnis:	Bitvektor fuer selektierte Checkboxen										*/
/*	tree:						Zeiger auf den Objektbaum														*/
/*----------------------------------------------------------------------------------------*/ 
static WORD	get_check_state( OBJECT *tree )
{
	WORD	check_boxes;
	
	check_boxes = 0;

	if ( tree[CHECK_NAME].ob_state & SELECTED )					/* Namens-Listbox aktiv? */
		check_boxes |= FNTS_SNAME;

	if ( tree[CHECK_STYLE].ob_state & SELECTED )					/* Stil-Listbox aktiv? */
		check_boxes |= FNTS_SSTYLE;
		
	if ( tree[CHECK_SIZE].ob_state & SELECTED )					/* Hoehen-Listbox aktiv? */
		check_boxes |= FNTS_SSIZE;

	if ( tree[CHECK_RATIO].ob_state & SELECTED )					/* B/H-Einstellung aktiv? */
		check_boxes |= FNTS_SRATIO;

	return( check_boxes );
}

/*----------------------------------------------------------------------------------------*/ 
/* Exit-Objekte behandeln				 																		*/
/* Funktionsergebnis:	0: Dialog schliessen 1: weitermachen											*/
/*	fnt_dialog:				Zeiger auf die Fontdialog-Struktur											*/
/*	obj:						Nummer des Objekts																*/
/*----------------------------------------------------------------------------------------*/ 
static WORD	do_buttons( FNT_DIALOG *fnt_dialog, WORD obj )
{
	OBJECT	*tree;
	WORD	exit_obj;
	WORD	i;

	tree = fnt_dialog->tree;

	for ( i = 0; i < NO_LBOXES; i++ )								/* alle Listboxen abtesten */
	{
		exit_obj = lbox_do( fnt_dialog->lboxes[i], obj ); 
		
		if ( exit_obj == -1 )											/* Doppelklick auf einen Eintrag? */
		{
			exit_obj = FOK;												/* wie Klick auf den "OK"-Button behandeln" */
			break;
		}	
	}
	exit_obj &= 0x7fff;

	switch ( exit_obj )
	{
		case	CHECK_NAME:													/* Checkbox fuer die Namens-Listbox? */
		{
			do_CHECK_NAME( tree );
			redraw_obj( fnt_dialog, FNAME_BOX );
			break;
		}
		case	CHECK_STYLE:												/* Checkbox fuer die Stil-Listbox? */
		{
			do_CHECK_STYLE( tree );
			redraw_obj( fnt_dialog, FSTL_BOX );
			break;
		}
		case	CHECK_SIZE:													/* Checkbox fuer die Hoehen-Listbox? */
		{
			do_CHECK_SIZE( tree );
			set_edit_obj( fnt_dialog, 0 );							/* Edit-Objekt ausschalten */
			set_edit_obj( fnt_dialog, 0 );							/* Edit-Objekt ausschalten */
			redraw_obj( fnt_dialog, FPT_BOX );
			redraw_obj( fnt_dialog, FPT_USER );
			break;
		}
		case	CHECK_RATIO:
		{
			do_CHECK_RATIO( tree );
			set_edit_obj( fnt_dialog, 0 );							/* Edit-Objekt ausschalten */
			redraw_obj( fnt_dialog, F_BH );
			break;
		}
		case	FSAMPLE:														/* der Beispieltext wurde angewaehlt... */
		case	FSET:															/* "setzen"-Button */
		{
			LBOX_ITEM	*style;

			if ( get_fixed( tree + FPT_USER, &fnt_dialog->pt, 65536L, 1000L << 16 ))	/* Fehler beim String? */
			{
				fixed_to_str( tree[FPT_USER].ob_spec.tedinfo->te_ptext, 5, fnt_dialog->pt );
				redraw_obj( fnt_dialog, FPT_USER );
				bell();
			}			

			if ( get_fixed( tree + F_BH, &fnt_dialog->ratio, 6554L, 655360L ))	/* Fehler beim String? */
			{
				fixed_to_str( tree[F_BH].ob_spec.tedinfo->te_ptext, 4, fnt_dialog->ratio );
				redraw_obj( fnt_dialog, F_BH );
				bell();
			}
				
			style = lbox_get_slct_item( fnt_dialog->fnt_style );
			slct_style( fnt_dialog->fnt_style, tree, style, (void *) fnt_dialog, 0, 0 );

			if ( exit_obj == FSET )										/* wurde der "setzen"-Button angeklickt? */
			{
				deselect_button( fnt_dialog, FSET );
				if (( tree[FSET].ob_state & DISABLED ) == 0 )	/* ist der Button anwaehlbar? */
				{
					fnt_dialog->button = FNTS_SET;
					return( 0 );
				}
			}
			break;
		}
		case	FCANCEL:														/* "Abbruch"-Button */
		{
			deselect_button( fnt_dialog, FCANCEL );
			fnt_dialog->button = FNTS_CANCEL;
			return( 0 );
		}
		case	FOK:															/* "OK"-Button */
		{
			deselect_button( fnt_dialog, FOK );
			fnt_dialog->button = FNTS_OK;
			return( 0 );
		}
		case	FMARK:														/* "markieren"-Button */
		{	
			deselect_button( fnt_dialog, FMARK );
			fnt_dialog->button = FNTS_MARK;
			return( 0 );
		}
		case	FOPTIONS:													/* "Optionen"-Button */
		{
			deselect_button( fnt_dialog, FOPTIONS );
			fnt_dialog->button = FNTS_OPT;
			return( 0 );
		}
	}
	return( 1 );	
}

/*----------------------------------------------------------------------------------------*/ 
/* Auf Selektionsstatus der Namens-Checkbox reagieren													*/
/* Funktionsergebnis:	-																						*/
/*	tree:						Zeiger auf den Objektbaum														*/
/*----------------------------------------------------------------------------------------*/ 
static void	do_CHECK_NAME( OBJECT *tree )
{
	if	( tree[CHECK_NAME].ob_state & SELECTED )					/* selektiert? */
		enable_lbox( tree, fname_obj, NO_FNAMES );				/* Objekte der Listbox sind anwaehlbar */
	else
		disable_lbox( tree, fname_obj, NO_FNAMES );				/* Objekte der Listbox sind nicht anwaehlbar */
}					

/*----------------------------------------------------------------------------------------*/ 
/* Auf Selektionsstatus der Stil-Checkbox reagieren													*/
/* Funktionsergebnis:	-																						*/
/*	tree:						Zeiger auf den Objektbaum														*/
/*----------------------------------------------------------------------------------------*/ 
static void	do_CHECK_STYLE( OBJECT *tree )
{
	if	( tree[CHECK_STYLE].ob_state & SELECTED )					/* selektiert? */
		enable_lbox( tree, fstyle_obj, NO_FSTYLES );				/* Objekte der Listbox sind anwaehlbar */
	else
		disable_lbox( tree, fstyle_obj, NO_FSTYLES );			/* Objekte der Listbox sind nicht anwaehlbar */
}				

/*----------------------------------------------------------------------------------------*/ 
/* Auf Selektionsstatus der Hoehen-Checkbox reagieren													*/
/* Funktionsergebnis:	-																						*/
/*	tree:						Zeiger auf den Objektbaum														*/
/*----------------------------------------------------------------------------------------*/ 
static void	do_CHECK_SIZE( OBJECT *tree )
{
	if	( tree[CHECK_SIZE].ob_state & SELECTED )					/* selektiert? */
	{
		enable_lbox( tree, fsize_obj, NO_FSIZES );				/* Objekte der Listbox sind anwaehlbar */
		obj_ENABLED( tree, FPT_USER );
		obj_EDITABLE( tree, FPT_USER );								/* Eingaben zulassen */
	}
	else
	{
		disable_lbox( tree, fsize_obj, NO_FSIZES );				/* Objekte der Listbox sind nicht anwaehlbar */
		obj_DISABLED( tree, FPT_USER );
		obj_NOT_EDITABLE( tree, FPT_USER );							/* Eingaben nicht zulassen */
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* Auf Selektionsstatus der Verhaeltnis-Checkbox reagieren											*/
/* Funktionsergebnis:	-																						*/
/*	tree:						Zeiger auf den Objektbaum														*/
/*----------------------------------------------------------------------------------------*/ 
static void	do_CHECK_RATIO( OBJECT *tree )
{
	if	( tree[CHECK_RATIO].ob_state & SELECTED )					/* selektiert? */
	{
		obj_ENABLED( tree, F_BH );
		obj_EDITABLE( tree, F_BH );									/* Eingaben zulassen */
	}
	else
	{
		obj_DISABLED( tree, F_BH );
		obj_NOT_EDITABLE( tree, F_BH );								/* Eingaben nicht zulassen */
	}
}					

/*----------------------------------------------------------------------------------------*/ 
/* Zahl aus einen Edit-Feld als Festkommazahl zurueckliefern											*/
/* Funktionsergebnis:	0: keine fehlerhaften Zeichen 1: ungueltige Zeichen in der Eingabe	*/
/*	obj:						Zeiger auf das Objekt															*/
/*	old_value:				Adresse der Festkommazahl														*/
/*	min:						Minimum																				*/
/*	max:						Maximum																				*/
/*----------------------------------------------------------------------------------------*/ 
static WORD	get_fixed( OBJECT *obj, LONG *old_value, LONG min, LONG max )
{
	LONG	a;
	WORD	err;
		
	a = str_to_fixed( obj->ob_spec.tedinfo->te_ptext, &err );

	if ( err == 0 )														/* keine fehlerhaften Zeichen? */
	{
		if ( a < min )														/* zu klein? */
		{
			a = min;
			err = 1 ;														/* Textobjekt neu zeichnen */
		}

		if ( a > max )														/* zu gross? */
		{
			a = max;
			err = 1;															/* Textobjekt neu zeichnen */
		}

		*old_value = a;	
	}

	return( err );
}

/*----------------------------------------------------------------------------------------*/ 
/* ueberpruefen, ob die gedrueckte Taste im Edit-Feld zugelassen ist									*/
/* Funktionsergebnis:	0: Taste ignorieren 1: Taste ist zugelassen								*/
/*	ucode:					Tastencode																			*/
/*----------------------------------------------------------------------------------------*/ 
static WORD	check_key( UWORD code )
{
	WORD	asc;

	asc = code & 0xff;													/* ASCII-Code */

	if ( code == 0x537f )												/* Delete-Taste? */
		return( 1 );
	
	if (( asc >= 32 ) && ( asc <= 42 ))
		return( 0 );
	
	if ( asc == 44 )
		return( 0 );
	
	if ( asc == 47 )
		return( 0 );
	
	if (( asc >= 58 ) && ( asc <= 255 ))							/* irgendein Buchstabe oder Sonderzeichen? */
		return( 0 );

	return( 1 );
}

/*----------------------------------------------------------------------------------------*/ 
/* Box mit innerem grauen Rand fuer sample_text() bzw.check_box() zeichnen						*/
/* Funktionsresultat:	-																						*/
/* parmblock:				Zeiger auf die Parameter-Block-Struktur									*/
/*	vdi_handle:				VDI-Handle																			*/
/*	rect:						Zeiger auf VRECT-Struktur fuer die Objektausmasse							*/
/*	clip_rect:				Zeiger auf VRECT-Struktur fuer das Clipping-Rechteck					*/
/*	dialog_flags:			Aussehen des Dialogs																*/
/*----------------------------------------------------------------------------------------*/ 
static void	draw_3d_box( PARMBLK *parmblock, WORD vdi_handle, VRECT *rect, VRECT *clip_rect, WORD dialog_flags )
{
	WORD	xy[10];

	*clip_rect = *(VRECT *) &parmblock->pb_xc;					/* Clipping-Rechteck... */
	clip_rect->x2 += clip_rect->x1 - 1;
	clip_rect->y2 += clip_rect->y1 - 1;

	vs_clip( vdi_handle, 1, (WORD *) clip_rect );				/* Zeichenoperationen auf gegebenen Bereich beschraenken */
	
	*rect = *(VRECT *) &parmblock->pb_x;							/* Objekt-Rechteck... */
	rect->x2 += rect->x1 - 1;
	rect->y2 += rect->y1 - 1;
	
	vswr_mode( vdi_handle, 1 );										/* Ersetzend */

	vsl_type( vdi_handle, 1 );											/* durchgehende Linie */

	vsl_color( vdi_handle, 1 );										/* schwarz */
	xy[0] = rect->x1;
	xy[1] = rect->y1;
	xy[2] = rect->x2;
	xy[3] = rect->y1;
	xy[4] = rect->x2;
	xy[5] = rect->y2;
	xy[6] = rect->x1;
	xy[7] = rect->y2;
	xy[8] = rect->x1;
	xy[9] = rect->y1;
	v_pline( vdi_handle, 5, xy );										/* schwarzen Rahmen zeichnen */

	vsf_interior( vdi_handle, FIS_SOLID );							/* vollflaechig */
	vsf_color( vdi_handle, 0 );										/* weiss */
	
	xy[0] = rect->x1 + 1;
	xy[1] = rect->y1 + 1;
	xy[2] = rect->x2 - 1;
	xy[3] = rect->y2 - 1;
	vr_recfl( vdi_handle, xy );										/* weisse Box zeichnen */

	if ( dialog_flags & FNTS_3D )										/* 3D-Look? */
	{
		vsl_color( vdi_handle, 8 );									/* hellgrau */
		xy[0] = rect->x1 + 1;
		xy[1] = rect->y2 - 2;
		xy[2] = rect->x1 + 1;
		xy[3] = rect->y1 + 1;
		xy[4] = rect->x2 - 2;
		xy[5] = rect->y1 + 1;
		v_pline( vdi_handle, 3, xy );									/* hellgraue Umrandung zeichnen */
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* NVDI-Cookie suchen und feststellen, ob vqt_xfntinfo() aufgerufen werden kann				*/
/* Funktionsresultat:	0: nicht aufrufen 1: aufrufen													*/
/*----------------------------------------------------------------------------------------*/ 
static WORD	use_vqt_xfontinfo( void )
{
	struct _nvdi_struct													/* verkuerzte NVDI-Struktur */
	{
		WORD	version;
		LONG	datum;
		WORD	conf;
	} *nvdi_struct;

	struct _cookie															/* Cookie-Struktur */
	{
		LONG	id;
		LONG	value;
	} *search;
	
	search = *(struct _cookie **) 0x5a0;							/* Zeiger auf den Cookie-Jar */
	
	if ( search )
	{
		while ( search->id )
		{
			if ( search->id == 'NVDI' )								/* NVDI-Cookie? */
			{
				LONG	datum;
				LONG	cmp;
				
				nvdi_struct = (struct _nvdi_struct *) search->value;
				
				datum = nvdi_struct->datum;
				cmp = ( datum & 0x0000ffffL ) << 16;				/* Jahr */
				cmp |= ( datum & 0x00ff0000L ) >> 8;				/* Monat */
				cmp |= ( datum & 0xff000000L ) >> 24;				/* Tag */

				if ( cmp >= 0x19950606L )								/* neueres Versionsdatum als 06.06.1995? */
					return( 1 );											/* vqt_xfntinfo() benutzen */
				else
					return( 0 );											/* vqt_fontheader() benutzen */
			}
			search++;														/* naechster Cookie */
		}		
	}
	return( 0 );
}

/*----------------------------------------------------------------------------------------*/ 
/* Listbox: Ein Eintrag in der Familien-Listbox ist angewaehlt worden								*/
/* Funktionsergebnis:	-																						*/
/*	box:						Zeiger auf die Listbox-Struktur												*/
/*	tree:						Zeiger auf den Objektbaum des Dialogs										*/
/*	item:						Zeiger auf den angewaehlten Eintrag											*/
/* user_data:				Zeiger auf FNT_DIALOG-Struktur												*/
/*----------------------------------------------------------------------------------------*/ 
void	cdecl	slct_family( LIST_BOX *box, OBJECT *tree, LBOX_ITEM *item, void *user_data, WORD obj_index, WORD last_state )
{
	FNT_DIALOG	*fnt_dialog;
	GRECT		*rect;
	FNT		*family;
	FNT		*font;
	BYTE		last_style[64];
	LBOX_ITEM	*style;
	WORD		old_cnt;
	WORD		old_top;

	(void) obj_index;
	(void) box;
	fnt_dialog = (FNT_DIALOG *) user_data;

	if (( item->selected == 0 )|| ( item->selected == last_state ))	/* Deselektion ignorieren */
		return;
		
	rect = (GRECT *) &tree->ob_x;										/* Dialog-Rechteck */

	style = lbox_get_slct_item( fnt_dialog->fnt_style );		/* bisher angewaehlten Stil ermitteln */

	if ( style )															/* gefunden? */
		vstrcpy( last_style, ((FNT *) style->data )->style_name );
	else
		last_style[0] = 0;
		
	old_top = lbox_get_first( fnt_dialog->fnt_style );
	old_cnt = lbox_cnt_items( fnt_dialog->fnt_style );
	lbox_free_items( fnt_dialog->fnt_style );					/* Speicher fuer LBOX_ITEMs freigeben */

	family = (FNT *) item->data;										/* erster Font der Familie */
	
	font = family;
	fnt_dialog->id = font->id;											/* ID des ersten Fonts der Familie */

	while ( font )
	{
		if ( strcmp( family->family_name, font->family_name ) == 0 )	/* gleiche Familie? */
		{
			if ( strcmp( last_style, font->style_name ) == 0 )	/* gleicher Stil? */
			{
				fnt_dialog->id = font->id;								/* ID des Fonts */
				break;
			}
		}
		else
			break;
			
		font = font->next;												/* naechster Font */
	}

	style = build_style_list( (FNT *) item->data, fnt_dialog->id );	/* Liste mit den Stilnamen aufbauen */
	lbox_set_items( fnt_dialog->fnt_style, style );			/* Liste mit den Stilnamen aufbauen */
	set_top( fnt_dialog->fnt_style, old_top, old_cnt, rect );	/* Index des obersten Elements setzen und set_slider() aufrufen */

	while ( style )
	{
		if ( style->selected )											/* angewaehlter Eintrag? */
		{
			slct_style( fnt_dialog->fnt_style, tree, style, user_data, 0, 0 );	/* Stil anwaehlen */
			break;
		}	
		style = style->next;
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* Listbox: Ein Eintrag in der Stil-Listbox ist angewaehlt worden									*/
/* Funktionsergebnis:	-																						*/
/*	box:						Zeiger auf die Listbox-Struktur												*/
/*	tree:						Zeiger auf den Objektbaum des Dialogs										*/
/*	item:						Zeiger auf den angewaehlten Eintrag											*/
/* user_data:				Zeiger auf FNT_DIALOG-Struktur												*/
/*----------------------------------------------------------------------------------------*/ 
void	cdecl	slct_style( LIST_BOX *box, OBJECT *tree, LBOX_ITEM *item, void *user_data, WORD obj_index, WORD last_state )
{
	LBOX_ITEM	*size_list;
	GRECT		*rect;
	WORD		old_cnt;
	WORD		old_top;
	LBOX_ITEM	*size;
	FNT	*font;
	FNT_DIALOG	*fnt_dialog;

	(void) obj_index;
	(void) box;
	fnt_dialog = (FNT_DIALOG *) user_data;

	if (( item->selected == 0 ) || ( item->selected == last_state ))	/* Deselektion ignorieren */
		return;

	rect = (GRECT *) &tree->ob_x;										/* Dialog-Rechteck */
		
	font = (FNT *) item->data;											/* angewaehlter Font */
	fnt_dialog->id = font->id;											/* ID des Fonts */
	fnt_dialog->mono = font->mono;
	fnt_dialog->outline = font->outline;
	fnt_dialog->display = font->display;							/* Zeiger auf die Anzeige-Funktion */
	
	old_top = lbox_get_first( fnt_dialog->fnt_size );
	old_cnt = lbox_cnt_items( fnt_dialog->fnt_size );
	lbox_free_items( fnt_dialog->fnt_size );						/* Speicher fuer LBOX_ITEMs freigeben */

	size_list = build_pt_list( font, fnt_dialog->pt, &size );	/* Liste mit den Punktgroessen aufbauen */
	lbox_set_items( fnt_dialog->fnt_size, size_list );		/* Liste mit den Punktgroessen aufbauen */
	
	if ( size == 0L )														/* kein Eintrag mit der gesuchten Groesse vorhanden? */
	{
		if ( font->outline == 0 )										/* handelt es sich um einen Bitmap-Font? */
			slct_closest_height( size_list, &size, font, fnt_dialog->pt );	/* am naechsten liegende Hoehe suchen */
	}	

	if ( font->outline )													/* Vektorfont? */
	{
		if ( tree[CHECK_RATIO].ob_state & DISABLED )				/* ist die Checkbox fuers B/H-Verhaeltnis disabled? */
		{
			obj_ENABLED( tree, CHECK_RATIO );						/* Checkbox enabled */
			obj_TOUCHEXIT( tree, CHECK_RATIO );						/* Checkbox anwaehlbar */
			redraw_obj( fnt_dialog, CHECK_RATIO );
		
			if	( tree[CHECK_RATIO].ob_state & SELECTED )			/* ist das B/H-Verhaeltnis veraenderbar? */
			{
				obj_ENABLED( tree, F_BH );								/* FTEXT wieder anwaehlbar */
				obj_EDITABLE( tree, F_BH );							/* FTEXT wieder editierbar */
				redraw_obj( fnt_dialog, F_BH );
			}
		}
	}
	else																		/* Bitmap-Font */
	{
		obj_DISABLED( tree, CHECK_RATIO );							/* Check-Button fuer B/H-Verhaeltnis disablen */
		obj_NOT_TOUCHEXIT( tree, CHECK_RATIO );					/* Checkbox nicht anwaehlbar */
		obj_DISABLED( tree, F_BH );									/* FTEXT fuer B/H-Verhaeltnis disablen */
		obj_NOT_EDITABLE( tree, F_BH );								/* FTEXT nicht editierbar */
		
		if ( get_edit_obj( fnt_dialog ) == F_BH )
			set_edit_obj( fnt_dialog, 0 );							/* Cursor ausschalten */
			
		redraw_obj( fnt_dialog, CHECK_RATIO );
		redraw_obj( fnt_dialog, F_BH );
	}

	set_top( fnt_dialog->fnt_size, old_top, old_cnt, rect );	/* Index des obersten Elements setzen und set_slider() aufrufen */

	slct_size( fnt_dialog->fnt_size, tree, size, user_data, 0, 0 );
}

/*----------------------------------------------------------------------------------------*/ 
/* Ein Eintrag in der Groessen-Listbox ist angewaehlt worden											*/
/* Funktionsergebnis:	-																						*/
/*	box:						Zeiger auf die Listbox-Struktur												*/
/*	tree:						Zeiger auf den Objektbaum des Dialogs										*/
/*	item:						Zeiger auf den angewaehlten Eintrag											*/
/* user_data:				Zeiger auf FNT_DIALOG-Struktur												*/
/*----------------------------------------------------------------------------------------*/ 
void	cdecl	slct_size( LIST_BOX *box, OBJECT *tree, LBOX_ITEM *item, void *user_data, WORD obj_index, WORD last_state )
{
	FNT_DIALOG	*fnt_dialog;
	WORD		edit_obj;
	WORD	index;
	
	(void) obj_index;
	if ( item && (( item->selected == 0 ) || ( item->selected == last_state )))	/* Deselektion ignorieren */
		return;

	fnt_dialog = (FNT_DIALOG *) user_data;							/* Zeiger auf die Fontdialog-Struktur */

	edit_obj = get_edit_obj( fnt_dialog );
	
	if ( edit_obj == FPT_USER )										/* war bisher noch ein Cursor im Textedit-Feld? */
		set_edit_obj( fnt_dialog, 0 );								/* Cursor ausschalten */

	if ( item )																/* wurde eine Punkthoehe in der Listbox eingestellt? */
		index = lbox_get_slct_idx( box );
	else
		index = -1;
	
	if ( index >= 0 )
	{
		fnt_dialog->pt = ((FNT *) item->data)->pts[index];
		fnt_dialog->pt <<= 16;
	
		fixed_to_str( tree[FPT_USER].ob_spec.tedinfo->te_ptext, 5, fnt_dialog->pt );
	
		obj_DESELECTED( tree, FPT_USER );							/* deselektieren */

		redraw_obj( fnt_dialog, FPT_USER );
	}
	else																		/* eine freie Punkthoehe wurde eingestellt */
	{
		obj_SELECTED( tree, FPT_USER );								/* selektieren */

		redraw_obj( fnt_dialog, FPT_USER );

		if ( edit_obj == FPT_USER )
			set_edit_obj( fnt_dialog, FPT_USER );					/* Cursor einschalten */
	}
	
	redraw_obj( fnt_dialog, FSAMPLE );
}

/*----------------------------------------------------------------------------------------*/ 
/* String und Objektstatus eines GTEXT-Objekts in der Listbox setzen								*/
/* Funktionsresultat:	Nummer des zu zeichnenden Startobjekts										*/
/*	box:						Zeiger auf die Listbox-Struktur												*/
/*	tree:						Zeiger auf den Objektbaum														*/
/* item:						Zeiger auf den Eintrag															*/
/* index:					Objektnummer																		*/
/* user_data:				...																					*/
/*	rect:						GRECT fuer Selektion/Deselektion oder 0L (nicht veraenderbar)			*/					
/*----------------------------------------------------------------------------------------*/ 
WORD	cdecl	set_str_item( LIST_BOX *box, OBJECT *tree, LBOX_ITEM *item, WORD index, void *user_data, GRECT *rect, WORD first )
{
	BYTE	*str;
	BYTE	*ptext;

	(void)first;
	(void)rect;
	(void)user_data;
	(void)box;
	ptext = tree[index].ob_spec.tedinfo->te_ptext;				/* Zeiger auf String des GTEXT-Objekts */

	if ( item )
	{
		if ( item->selected )											/* selektiert? */
			obj_SELECTED( tree, index );
		else
			obj_DESELECTED( tree, index );

		str = item->name;
	
		if ( *ptext )
			*ptext++ = ' ';												/* vorangestelltes Leerzeichen */
	
		while ( *ptext && *str )
			*ptext++ = *str++;
	}
	else
		obj_DESELECTED( tree, index );

	while ( *ptext )
		*ptext++ = ' ';													/* Stringende mit Leerzeichen auffuellen */	

	return( index );
}

/*----------------------------------------------------------------------------------------*/ 
/* Service-Routine fuer Fensterdialog 																		*/
/* Funktionsergebnis:	0: Dialog schliessen 1: weitermachen											*/
/*	dialog:					Zeiger auf die Dialog-Struktur												*/
/*	events:					Zeiger auf EVNT-Struktur oder 0L												*/
/*	obj:						Nummer des Objekts oder Ereignisnummer										*/
/*	clicks:					Anzahl der Mausklicks															*/
/*	data:						Zeiger auf zusaetzliche Daten													*/
/*----------------------------------------------------------------------------------------*/ 
WORD	cdecl	do_slct_font( DIALOG *dialog, EVNT *events, WORD obj, WORD clicks, void *data )
{
	FNT_DIALOG	*fnt_dialog;
	
	(void)events;
	if ( obj < 0 )															/* Nachricht? */
	{
		if ( obj == HNDL_CLSD )											/* Dialog geschlossen? */
		{
			fnt_dialog = (FNT_DIALOG *) wdlg_get_udata( dialog );
			fnt_dialog->button = FNTS_OK;
			return( 0 );
		}
		if ( obj == HNDL_EDIT )											/* wurde ein Edit-Objekt angewaehlt? */
		{
			if ( check_key( *(UWORD *) data ))						/* Taste auf Gueltigkeit ueberpruefen */
				return( 1 );												/* gueltige Taste */
			else
			{
				bell();
				return( 0 );												/* ungueltige Taste */
			}
		}
	}
	else
	{
		fnt_dialog = (FNT_DIALOG *) data;

		if ( clicks == 2 )												/* Doppelklick? */
			obj |= 0x8000;			

		return( do_buttons( fnt_dialog, obj ));					/* Exit-Objekt behandeln */
	}
	
	return( 1 );	
}

/*----------------------------------------------------------------------------------------*/ 
/* USERDEF-Funktion fuer den Beispieltext																	*/
/* Funktionsresultat:	nicht aktualisierte Objektstati												*/
/* parmblock:				Zeiger auf die Parameter-Block-Struktur									*/
/*----------------------------------------------------------------------------------------*/ 
WORD	cdecl sample_text( PARMBLK *parmblock )
{
	FNT_DIALOG	*fnt_dialog;
	WORD	tmp;
	VRECT	clip_rect;
	VRECT	rect;
	WORD	vdi_handle;
	
	fnt_dialog = (FNT_DIALOG *) parmblock->pb_parm;
	vdi_handle = fnt_dialog->vdi_handle;
	
	draw_3d_box( parmblock, vdi_handle, &rect, &clip_rect, fnt_dialog->dialog_flags );	/* Box mit innerem grauen Rand zeichnen */
	
	rect.x1 += 2;															/* zum Objektrand 2 Pixel Abstand halten */
	rect.y1 += 2;
	rect.x2 -= 2;
	rect.y2 -= 2;
	
	rect_sort( &rect );													
	if ( rect_intersect( &rect, &clip_rect, &clip_rect ) == 0 )	/* schneiden sich die Rechtecke nicht? */
	{
		clip_rect.x1 = 0;													/* Dummy-Rechteck */
		clip_rect.y1 = 0;
		clip_rect.x2 = 0;
		clip_rect.y2 = 0;
		
	}
	vs_clip( vdi_handle, 1, (WORD *) &clip_rect );				/* Clipping-Rechteck fuer den Text setzen */
	
	if ( fnt_dialog->display )											/* kein VDI-Font? */
	{
		fnt_dialog->display( rect.x1 + 1, rect.y2 - 5, (WORD *) &clip_rect,
									fnt_dialog->id, fnt_dialog->pt, fnt_dialog->ratio,
									fnt_dialog->sample_string );

	}
	else																		/* VDI-Font */
	{
		vst_font( vdi_handle, (WORD) fnt_dialog->id );			/* Font einstellen */
	
		vst_effects( vdi_handle, 0 );									/* keine Effekte */
		vst_alignment( vdi_handle, 0, 0, &tmp, &tmp );			/* an der Basislinie ausrichten */
		vst_color( vdi_handle, 1 );									/* schwarz */
		vswr_mode( vdi_handle, 2 );									/* Transparent zeichnen */

		if ( fnt_dialog->outline )										/* Vektorfont? */
		{
			LONG	pt;
			LONG	ratio;
			WORD	negative;
			ULONG	w1;
			ULONG	w2;
			LONG	width;

			vst_arbpt32( vdi_handle, fnt_dialog->pt, &tmp, &tmp, &tmp, &tmp );	/* Hoehe einstellen */

			pt = fnt_dialog->pt;
			ratio = fnt_dialog->ratio;

			negative = 0;

			if ( pt < 0 )													/* negative Hoehe? */
			{
				pt = - pt;
				negative ^= 1;
			}
						
			if ( ratio < 0 )												/* negatives B/H-Verhaeltnis? */
			{
				ratio = - ratio;
				negative ^= 1;
			}

			w1 = (ULONG) pt >> 16;
			w1 *= (ULONG) ratio;											/* Vorkommaanteil der Breite */
			w2 = (ULONG) pt & 0xffffL;
			w2 *= (ULONG) ratio;											/* Nachkommaanteil der Breite */
		
			width = (LONG) ( w1 + (( w2 + 32768L ) >> 16 ));	/* Breite in 1/65536 Punkten */

			if ( negative )												/* negative Breite? */
				width = - width;

			vst_setsize32( vdi_handle, width, &tmp, &tmp, &tmp, &tmp );

			vst_skew( vdi_handle, 0 );									/* keine Schraegstellung */
			vst_kern( vdi_handle, 0, 1, &tmp	, &tmp );			/* Pair-Kerning einschalten */

			v_ftext ( vdi_handle, rect.x1 + 1, rect.y2 - 5, fnt_dialog->sample_string );
		}
		else
		{
			vst_point( vdi_handle, (WORD) ( fnt_dialog->pt >> 16 ), &tmp, &tmp, &tmp, &tmp );	/* Hoehe einstellen */
			v_gtext ( vdi_handle, rect.x1 + 1, rect.y2 - 5, fnt_dialog->sample_string );
		}
	}
	
	return( parmblock->pb_currstate );
}

/*----------------------------------------------------------------------------------------*/ 
/* USERDEF-Funktion fuer Checkbox																				*/
/* Funktionsresultat:	nicht aktualisierte Objektstati												*/
/* parmblock:				Zeiger auf die Parameter-Block-Struktur									*/
/*----------------------------------------------------------------------------------------*/ 
WORD	cdecl check_box( PARMBLK *parmblock )
{
	FNT_DIALOG	*fnt_dialog;
	VRECT	clip_rect;
	VRECT	rect;
	WORD	xy[10];
	WORD	vdi_handle;
	
	fnt_dialog = (FNT_DIALOG *) parmblock->pb_parm;
	vdi_handle = fnt_dialog->vdi_handle;

	draw_3d_box( parmblock, vdi_handle, &rect, &clip_rect, fnt_dialog->dialog_flags );	/* Box mit grauem Rand zeichnen */

	if ( parmblock->pb_currstate & SELECTED )
	{
		parmblock->pb_currstate &= ~SELECTED;						/* Bit loeschen */

		vsl_type( vdi_handle, 1 );										/* durchgehende Linie */

		if ( fnt_dialog->dialog_flags & FNTS_3D )					/* 3D-Look? */
		{
			vsl_color( vdi_handle, 8 );								/* hellgrau - fuer antialisende Linien neben dem Kreuz */
			xy[0] = rect.x1 + 3;
			xy[1] = rect.y1 + 2;
			xy[2] = rect.x2 - 2;
			xy[3] = rect.y2 - 3;
			v_pline( vdi_handle, 2, xy );
	
			xy[1] = rect.y2 - 2;
			xy[3] = rect.y1 + 3;
			v_pline( vdi_handle, 2, xy );
	
			xy[0] = rect.x1 + 2;
			xy[1] = rect.y1 + 3;
			xy[2] = rect.x2 - 3;
			xy[3] = rect.y2 - 2;
			v_pline( vdi_handle, 2, xy );
	
			xy[1] = rect.y2 - 3;
			xy[3] = rect.y1 + 2;
			v_pline( vdi_handle, 2, xy );
		}
		
		vsl_color( vdi_handle, 1 );									/* schwarz - fuer das Kreuz */
		xy[0] = rect.x1 + 2;
		xy[1] = rect.y1 + 2;
		xy[2] = rect.x2 - 2;
		xy[3] = rect.y2 - 2;
		v_pline( vdi_handle, 2, xy );
		
		xy[1] = rect.y2 - 2;
		xy[3] = rect.y1 + 2;
		v_pline( vdi_handle, 2, xy );
	}

	return( parmblock->pb_currstate );
}

/*----------------------------------------------------------------------------------------*/ 
/* Routinen aus OBJ_TOOL.C einbinden																		*/
/*----------------------------------------------------------------------------------------*/ 

#include "obj_tool.c"
