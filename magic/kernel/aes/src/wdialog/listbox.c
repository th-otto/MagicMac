/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*

	Compilerschalter: -B-P
*/


#include	<PORTAB.H>
#include	<TOS.H>
#include	<AES.H>
#include	<VDI.H>

#define	CALL_MAGIC_KERNEL	1

#if	CALL_MAGIC_KERNEL

/*----------------------------------------------------------------------------------------*/ 
/* Makros und Funktionsdefinitionen fÅr Aufrufe an den MagiC-Kernel								*/
/*----------------------------------------------------------------------------------------*/ 

typedef struct
{
	WORD	flag;
	GRECT	g;
} MGRECT;

#define	evnt_timer( low, high ) \
			_evnt_timer( low )

#define	wind_get( handle, field, a, b, c, d ) \
			_wind_get( handle, field, (WORD *) a )
			
#define	Malloc( size )	((void *) malloc( size ))

#define rc_intersect(a,b)	grects_intersect(a,b)

extern LONG malloc( LONG size );
extern void _graf_mkstate( WORD data[4] );
extern void set_clip_grect( GRECT *g );
extern void cdecl blitcopy_rectangle( WORD src_x, WORD src_y, WORD dst_x, WORD dst_y, WORD w, WORD h );
extern WORD _evnt_timer( LONG clicks_50hz );
extern WORD appl_yield( void );
extern int cdecl _evnt_multi( WORD mtypes, MGRECT *mm1, MGRECT *mm2, LONG ms, LONG but, WORD *mbuf, WORD *out );
extern void _objc_draw( OBJECT *tree, WORD startob, WORD depth );
extern void _objc_change( OBJECT *tree, WORD objnr, WORD newstate, WORD draw );
extern WORD _wind_get( WORD whdl, WORD code, WORD *g );

#else

#define	appl_yield() \
			evnt_timer( 0, 0 );

#endif

#include	"WDIALOG.H"
#include	"LISTBOX.H"

/*----------------------------------------------------------------------------------------*/ 
/* extern aus WDINTRFC.S																						*/
/*----------------------------------------------------------------------------------------*/ 
extern void	slct_item( LIST_BOX *box, LBOX_ITEM *item, WORD index, WORD last_state );
extern WORD	set_item( LIST_BOX *box, LBOX_ITEM *item, WORD index, GRECT *rect );

/*----------------------------------------------------------------------------------------*/ 
/* extern aus WDIALOG.C																							*/
/*----------------------------------------------------------------------------------------*/ 
extern WORD	rc_intersect( GRECT *p1, GRECT *p2 );

/*----------------------------------------------------------------------------------------*/ 
/* interne Funktionen																							*/
/*----------------------------------------------------------------------------------------*/ 
static void	do_scroll_button( LIST_BOX *box, WORD button );
static void	do_slider( LIST_BOX *box, WORD mx, WORD my );
static void	real_aslider( LIST_BOX *box, WORD count, WORD xy, WORD ob_min, WORD ob_max );
static void	do_slider_back( LIST_BOX *box, WORD mx, WORD my );
static void	set_slider_obj( WORD first, WORD number, WORD visible, WORD wh, WORD *ob_xy, WORD *ob_wh );
static void ascroll_to( LIST_BOX *box, WORD old, WORD new, GRECT *box_rect, GRECT *slider_rect );

static void scroll_up( LIST_BOX *box );
static void scroll_left( LIST_BOX *box );
static void scroll_down( LIST_BOX *box );
static void scroll_right( LIST_BOX *box );

static WORD	auto_scroll( LIST_BOX *box, WORD obj );
static void	auto_scroll_up( LIST_BOX *box, WORD obj_y );
static void	auto_scroll_left( LIST_BOX *box, WORD obj_x );
static void	auto_scroll_down( LIST_BOX *box, WORD obj_y );
static void	auto_scroll_right( LIST_BOX *box, WORD obj_x );

static void	ascroll( LIST_BOX *box, WORD first, WORD obj, WORD x1, WORD y1, WORD x2, WORD y2, WORD w, WORD h );
static void	move_area( OBJECT *tree, WORD obj, WORD x1, WORD y1, WORD x2, WORD y2, WORD w, WORD h );
static void	do_scroll_pause( WORD offset );

static void	change_item_state( LIST_BOX *box, LBOX_ITEM *item, WORD index, WORD new_state );
static void	deselect_list( LIST_BOX *box );

static WORD	is_visible( LIST_BOX *box, GRECT *r );
static WORD	is_b_in_a( GRECT *a, GRECT *b );
static void	get_GRECT( OBJECT *tree, WORD obj, GRECT *r );
static void	set_dial_clip( WORD handle, OBJECT *dial, WORD obj );

static void	obj_change( OBJECT *tree, GRECT *rect, WORD obj, WORD state );
static void	obj_redraw( LIST_BOX *box, GRECT *rect, WORD obj, WORD depth );

#define	mkstate	graf_mkstate

#if 0
WORD	mkstate( WORD *mx, WORD *my, WORD *mbutton, WORD *kstate );
#endif

static void	bscroll( LIST_BOX *box, WORD first, WORD x1, WORD y1, WORD x2, WORD y2, WORD w, WORD h );
static void	do_slider2_back( LIST_BOX *box, WORD mx, WORD my );
static void	do_slider_b( LIST_BOX *box, WORD mx, WORD my );
static void	real_bslider( LIST_BOX *box, WORD count, WORD xy, WORD ob_min, WORD ob_max );
static void bscroll_to( LIST_BOX *box, WORD old, WORD new, GRECT *box_rect, GRECT *slider_rect );


/*----------------------------------------------------------------------------------------*/ 
/* Speicher fÅr LIST_BOX anfordern und initialisieren													*/
/* Funktionsresultat:	Zeiger auf LIST_BOX-Struktur oder 0L										*/
/*	tree:						Zeiger auf den Objektbaum														*/
/*	slct:						Routine, die bei Objektauswahl angesprungen wird						*/
/*	set:						Routine, die die Elemente der Liste setzt									*/
/*	items:					Zeiger auf die Liste mit Elementen (LBOX_ITEM)							*/
/*	visible_a				Anzahl der sichtbaren EintrÑge												*/
/* first:					Index des ersten sichtbaren Elements										*/
/*	ctrl_objs:				Feld mit Objektnummer von Slidern und den anderen Objekten			*/
/*	objs:						Feld mit Objektnummern der Listbox-Elemente								*/
/*	flags:					div. Flags, die u.a. festlegen, ob vert. oder hor. gescrollt wird	*/
/*	pause_a:					Verzîgerung in ms fÅr die Scroll-Buttons									*/
/*	user_data:				dieser Zeiger wird slct und set_item beim Aufruf Åbergeben			*/
/* dialog:					Zeiger auf eine Fensterdialog-Struktur oder 0L							*/
/*----------------------------------------------------------------------------------------*/ 
LIST_BOX	*lbox_create( OBJECT *tree, SLCT_ITEM slct, SET_ITEM set, LBOX_ITEM *items, WORD visible_a, WORD first_a,
								WORD *ctrl_objs, WORD *objs, WORD flags, WORD pause_a, void *user_data, void *dialog,
								WORD visible_b, WORD first_b, WORD entries_b, WORD pause_b )
{
	LIST_BOX	*box;
	
	box = Malloc( sizeof( LIST_BOX ));
	
	if ( box )
	{
		box->flags = flags;												/* diverse Flags */
		
		box->dialog = dialog;											/* Zeiger auf die Fensterdialog-Struktur */
		box->tree = tree;													/* Zeiger auf den Objektbaum */
		box->user_data = user_data;

		box->parent_box = *ctrl_objs++;								/* Nummer des BOX-Hintergrund-Objekts  */
		box->button1 = *ctrl_objs++;									/* Nummer des Scroll-Up/Left-Objekts */
		box->button2 = *ctrl_objs++;									/* Nummer des Scroll-Down/Right-Objekts */
		box->back1 = *ctrl_objs++;										/* Objektnummer des Slider-Hintergrunds */
		box->slider1 = *ctrl_objs++;									/* Objektnummer des Sliders */

		if ( flags & LBOX_2SLDRS )										/* 2 Slider? */
		{
			box->button_hl = *ctrl_objs++;
			box->button_hr = *ctrl_objs++;
			box->back_h = *ctrl_objs++;
			box->slider_h = *ctrl_objs++;
			box->visible_b = visible_b;
			box->entries_b = entries_b;
			box->pause_b = pause_b;
		}
		else																	/* nur ein Slider */
		{
			box->button_hl = -1;
			box->button_hr = -1;
			box->back_h = -1;
			box->slider_h = -1;
			box->visible_b = 0;
			box->first_b = 0;
			box->entries_b = 0;
			box->pause_b = 0;
		}

		box->obj_index = objs;											/* Feld mit Objektnummern der Box-Elemente */

		box->visible_a = visible_a;									/* Anzahl der sichtbaren EintrÑge */

		box->items = items;												/* Zeiger auf Elementliste */

		box->pause_a = pause_a;											/* Verzîgerung fÅrs Scrolling */

		box->slct = slct;													/* Zeiger auf Auswahlfunktion */
		box->set_item = set;												/* Zeiger auf Setzfunktion */
	
		lbox_set_asldr( box, first_a, 0L );							/* Slider positionieren (nicht zeichnen) */
		if ( flags & LBOX_2SLDRS )										/* 2 Slider? */
			lbox_set_bsldr( box, first_b, 0L );
		lbox_update( box, 0L );											/* Objekte besetzen (nicht zeichnen) */
	}
	
	return( box );
}

/*----------------------------------------------------------------------------------------*/ 
/* Speicher fÅr LIST_BOX freigeben																			*/
/* Funktionsresultat:	0: Fehler 1: alles in Ordnung													*/
/*	box:						Zeiger auf die LIST_BOX-Struktur												*/
/*----------------------------------------------------------------------------------------*/ 
WORD	lbox_delete( LIST_BOX *box )
{
	if ( box )
	{
		Mfree( box );
		return( 1 );
	}
	
	return( 0 );
}

/*----------------------------------------------------------------------------------------*/ 
/* Abtesten, ob die Listbox betÑtigt wurde																*/
/* Funktionsresultat:	angewÑhlte Objektnummer (oberstes Bit gelîscht, & 0x7fff), -1 ist das Default-Objekt			*/
/*	box:						Zeiger auf die LIST_BOX-Struktur												*/
/*	obj:						Nummer des ausgewÑhlten Objekts												*/
/*----------------------------------------------------------------------------------------*/ 
WORD	lbox_do( LIST_BOX *box, WORD obj )
{
	OBJECT	*tree;
	WORD	i;
	WORD	dclick;
	
	WORD	mx;
	WORD	my;
	WORD	mbutton;
	WORD	kstate;

	tree = box->tree;
	
	dclick = obj & 0x8000;
	obj &= 0x7fff;

	mkstate( &mx, &my, &mbutton, &kstate );						/* Mausstatus */

	if ( obj == box->button1 )											/* Scroll-Button 1? */
		do_scroll_button( box, obj );
	else if ( obj == box->button2 )									/* Scroll-Button 2? */
		do_scroll_button( box, obj );
	else if ( obj == box->button_hl )								/* Scroll-Button 3? */
		do_scroll_button( box, obj );
	else if ( obj == box->button_hr )								/* Scroll-Button 4? */
		do_scroll_button( box, obj );
	else if ( obj == box->back1 )										/* Slider-Hintergrund? */
		do_slider_back( box, mx, my );
	else if ( obj == box->slider1 )									/* Slider? */
		do_slider( box, mx, my );
	else if ( obj == box->back_h )									/* Slider-Hintergrund? */
		do_slider2_back( box, mx, my );
	else if ( obj == box->slider_h )									/* Slider? */
		do_slider_b( box, mx, my );
	else
	{	
		WORD	found;
		
		found = 0;
		
		for( i = 0; i < box->visible_a; i++ )
		{
			if( obj == box->obj_index[i] )							/* wurde einer der EintrÑge angewÑhlt? */
	 		{
				LBOX_ITEM *selected;
				
				selected = lbox_get_item( box, box->first_a + i );	
				if( selected )												/* Eintrag vorhanden? */
				{
					WORD	last_state;
					
					last_state = selected->selected;					/* Status merken */
					
					if ( last_state == 0 )								/* Eintrag noch nicht angewÑhlt? */
					{
						if ( box->flags & LBOX_SNGL )					/* keine Mehrfachselektion? */
							deselect_list( box );						/* deselektieren */
							
						if (( box->flags & LBOX_SHFT ) && (( kstate & ( K_RSHIFT + K_LSHIFT )) == 0 ))	/* Shift nicht gedrÅckt? */
							deselect_list( box );						/* deselektieren */
							
						change_item_state( box, selected, obj, 1 );	/* angewÑhlten Eintrag selektieren */
					}
					else														/* Eintrag ist bereits angewÑhlt */
					{
						if ( dclick == 0 )								/* kein Doppelklick? */
						{
							if ( box->flags & LBOX_SHFT )				/* Shift-Taste beachten? */
							{
								if ( kstate & ( K_RSHIFT + K_LSHIFT ))
									change_item_state( box, selected, obj, 0 );	/* angewÑhlten Eintrag deselektieren */
							}
							else if ( box->flags & LBOX_TOGGLE )	/* Status toggeln? */
								change_item_state( box, selected, obj, 0 );	/* angewÑhlten Eintrag deselektieren */
						}
					}

					slct_item( box, selected, obj + dclick, last_state );	/* Service-Routine anspringen */

					if( dclick )											/* Doppelklick? */
						return( -1 );

					found = 1;												/* eines der Listbox-Objekte wurde ausgewÑhlt */
				}
			}
		}
		
		if ( found )														/* wurde eines der Listbox-Objekte ausgewÑhlt? */
		{
			WORD	mwhich;
			WORD	buf[16];

#if	CALL_MAGIC_KERNEL == 0
			WORD	dummy;
			GRECT	rect;

			get_GRECT( tree, obj, &rect );
#else
			MGRECT	rect;
			WORD		out[6];
			
			rect.flag = 1;													/* warte auf Verlassen */			
			get_GRECT( tree, obj, &rect.g );
#endif	
			wind_update( BEG_MCTRL );									/* Mauskontrolle holen */
						
			while( 1 )
			{

#if	CALL_MAGIC_KERNEL == 0
				mwhich = evnt_multi( MU_M1 + MU_BUTTON,
											2,									/* Doppelklicks erkennen */
											1,									/* nur linke Maustaste */
											0,									/* linke Maustaste losgelassen */
											1, rect.g_x, rect.g_y, rect.g_w, rect.g_h,	/* Objekt-Rechteck */
											0,0,0,0,0,						/* kein 2. Rechteck			*/
											buf,								/* Dummy-Buffer */
											0,0,								/* ms */
											&dummy, &dummy,
											&mbutton, &dummy,
											&dummy, &dummy );
#else
				mwhich = _evnt_multi( MU_M1 + MU_BUTTON,
											 &rect,							/* 1. Rechteck */
											 0L,								/* 2. Rechteck */
											 0L,								/* ms */
											 0x00020100L,					/* Doppelklicks erkennen */
																				/* nur linke Maustaste */
																				/* linke Maustaste losgelassen */
										 	 buf,								/* Dummy-Buffer */
											 out );
				mbutton = out[2];											/* bstate */
#endif

				if ( mwhich & MU_M1 )									/* wurde das Rechteck verlassen? */
					break;
				
				if ( mwhich & MU_BUTTON )								/* wurde die Maustaste losgelassen? */
					break;
			}
			wind_update( END_MCTRL );									/* Mauskontrolle freigeben */
		}	
			
		if (( box->flags & LBOX_AUTO ) && ( mbutton == 1 ))	/* Auto-Scrolling und wird die Maustaste noch gedrÅckt? */
		{
			wind_update( BEG_MCTRL );									/* Mauskontrolle holen */
			auto_scroll( box, obj );
			wind_update( END_MCTRL );									/* Mauskontrolle freigeben */
		}
	}
	return( obj );
}

/*----------------------------------------------------------------------------------------*/ 
/* Anzahl der Elemente in der Listbox ermitteln															*/
/* Funktionsresultat:	Anzahl der Elemente																*/
/*	box:						Zeiger auf die LIST_BOX-Struktur												*/
/*----------------------------------------------------------------------------------------*/ 
WORD	lbox_cnt_items( LIST_BOX *box )
{
	LBOX_ITEM	*item;
	WORD	cnt;
	
	cnt = 0;
	item = box->items;													/* Zeiger auf das erste Element */

	while( item )
	{
		cnt++;
		item = item->next;
	}
	return( cnt );															/* Anzahl der Elemente */
}

/*----------------------------------------------------------------------------------------*/ 
/* Zeiger auf LBOX_ITEMs zurÅckliefern																		*/
/* Funktionsresultat:	Zeiger auf LBOX_ITEMs															*/
/*	box:						Zeiger auf die LIST_BOX-Struktur												*/
/*----------------------------------------------------------------------------------------*/ 
LBOX_ITEM	*lbox_get_items( LIST_BOX *box )
{
	return( box->items );
}

/*----------------------------------------------------------------------------------------*/ 
/* Zeiger auf Objektbaum zurÅckliefern																		*/
/* Funktionsresultat:	Zeiger auf Objektbaum															*/
/*	box:						Zeiger auf die LIST_BOX-Struktur												*/
/*----------------------------------------------------------------------------------------*/ 
OBJECT	*lbox_get_tree( LIST_BOX *box )
{
	return( box->tree );
}

/*----------------------------------------------------------------------------------------*/ 
/* Anzahl der sichtbaren EintrÑge zurÅckliefern															*/
/* Funktionsresultat:	Hîhe																					*/
/*	box:						Zeiger auf die LIST_BOX-Struktur												*/
/*----------------------------------------------------------------------------------------*/ 
WORD	lbox_get_avis( LIST_BOX *box )
{
	return( box->visible_a );
}

/*----------------------------------------------------------------------------------------*/ 
/* Zeiger auf benutzerdefinierte Daten zurÅckliefern													*/
/* Funktionsresultat:	Zeiger auf benutzerdefinierte Daten 										*/
/*	box:						Zeiger auf die LIST_BOX-Struktur												*/
/*----------------------------------------------------------------------------------------*/ 
void	*lbox_get_udata( LIST_BOX *box )
{
	return( box->user_data );
}

/*----------------------------------------------------------------------------------------*/ 
/* Index des ersten sichbaren Elements zurÅckliefern													*/
/* Funktionsresultat:	Index des ersten sichbaren LBOX_ITEMS										*/
/*	box:						Zeiger auf die LIST_BOX-Struktur												*/
/*----------------------------------------------------------------------------------------*/ 
WORD	lbox_get_afirst( LIST_BOX *box )
{
	return( box->first_a );
}

/*----------------------------------------------------------------------------------------*/ 
/* LBOX_ITEM mit Index n zurÅckliefern																		*/
/* Funktionsresultat:	Zeiger auf den Eintrag mit Index n											*/
/*	box:						Zeiger auf die LIST_BOX-Struktur												*/
/* n:							index																					*/
/*----------------------------------------------------------------------------------------*/ 
LBOX_ITEM	*lbox_get_item( LIST_BOX *box, WORD n )
{
	LBOX_ITEM *item;
	
	item = box->items;
	
	while ( item && ( n > 0 ))
	{
		item = item->next;
		n--;
	}
	return( item );
}

/*----------------------------------------------------------------------------------------*/ 
/* Index des ausgewÑhlten LBOX_ITEMs zurÅckliefern														*/
/* Funktionsresultat:	-																						*/
/*	box:						Zeiger auf die LIST_BOX-Struktur												*/
/*----------------------------------------------------------------------------------------*/ 
WORD	lbox_get_slct_idx( LIST_BOX *box )
{
	LBOX_ITEM *item;
	WORD			index;
	
	item = box->items;
	index = 0;
	
	while ( item )
	{
		if ( item->selected )
			return( index );
		item = item->next;
		index++;
	}
	return( -1 );
}

/*----------------------------------------------------------------------------------------*/ 
/* AusgewÑhltes LBOX_ITEM zurÅckliefern																	*/
/* Funktionsresultat:	-																						*/
/*	box:						Zeiger auf die LIST_BOX-Struktur												*/
/*----------------------------------------------------------------------------------------*/ 
LBOX_ITEM *lbox_get_slct_item( LIST_BOX *box )
{
	LBOX_ITEM *item;
	
	item = box->items;
	
	while ( item )
	{
		if ( item->selected )
			return( item );
		item = item->next;
	}
	return( 0L );
}

/*----------------------------------------------------------------------------------------*/ 
/* Index eines LBOX_ITEMs zurÅckliefern																	*/
/* Funktionsresultat:	Index des Elements																*/
/*	items:					Zeiger auf das erste LBOX_ITEM der List									*/
/*	search:					Zeiger auf das gesuchte LBOX_ITEM											*/
/*----------------------------------------------------------------------------------------*/ 
WORD	lbox_get_idx( LBOX_ITEM *items, LBOX_ITEM *search )
{
	WORD	index;
	
	index = 0;

	while ( items )
	{
		if ( search == items )
			return( index );												/* Index des Elements zurÅckliefern */
		
		index++;
		items = items->next;
	}

	return( -1 );															/* Fehler */
}

/*----------------------------------------------------------------------------------------*/ 
/* Anzahl der sichtbaren Einteilungen zurÅckliefern													*/
/* Funktionsresultat:	Hîhe																					*/
/*	box:						Zeiger auf die LIST_BOX-Struktur												*/
/*----------------------------------------------------------------------------------------*/ 
WORD	lbox_get_bvis( LIST_BOX *box )
{
	return( box->visible_b );
}

/*----------------------------------------------------------------------------------------*/ 
/* Anzahl der sichtbaren Einteilungen Ñndern										*/
/* Funktionsresultat:	alter Wert													*/
/*	box:						Zeiger auf die LIST_BOX-Struktur												*/
/* new_bvis:				neue Anzahl */
/*----------------------------------------------------------------------------------------*/ 
WORD	lbox_set_bvis( LIST_BOX *box, WORD new_bvis )
{
	WORD old;

	old = box->visible_b;
	box->visible_b = new_bvis;
	return( old );
}

/*----------------------------------------------------------------------------------------*/ 
/* Anzahl der Elemente fÅr Slider B zurÅckliefern														*/
/* Funktionsresultat:	Anzahl der Elemente																*/
/*	box:						Zeiger auf die LIST_BOX-Struktur												*/
/*----------------------------------------------------------------------------------------*/ 
WORD	lbox_get_bentries( LIST_BOX *box )
{
	return( box->entries_b );
}

/*----------------------------------------------------------------------------------------*/ 
/* Index des ersten sichbaren Elements fÅr Slider B zurÅckliefern									*/
/* Funktionsresultat:	Index des ersten sichbaren Elements											*/
/*	box:						Zeiger auf die LIST_BOX-Struktur												*/
/*----------------------------------------------------------------------------------------*/ 
WORD	lbox_get_bfirst( LIST_BOX *box )
{
	return( box->first_b );
}

/*----------------------------------------------------------------------------------------*/ 
/* Slider positionieren und evtl. neuzeichnen (Elemente werden nicht aktualisiert)			*/
/* Funktionsresultat:	-																						*/
/*	box:						Zeiger auf die LIST_BOX-Struktur												*/
/*	first:					Index des ersten sichtbaren Elements										*/
/*	rect:						Zeiger auf das Redraw-Rechteck oder 0L (keinen Redraw auslîsen)	*/
/*----------------------------------------------------------------------------------------*/ 
void	lbox_set_asldr( LIST_BOX *box, WORD first, GRECT *rect )
{
	OBJECT	*tree;
	WORD	number;
	
	tree = box->tree;
	
	number = lbox_cnt_items( box );									/* Anzahl der Elemente */

	if ( first > number - box->visible_a )							/* zu groû? */
		first = number - box->visible_a;

	if ( first < 0 )														/* zu klein? */
		first = 0;

	box->first_a = first;												/* Index des ersten sichtbaren Elements */

	if ( box->slider1 != -1 )											/* Slider vorhanden? */
	{
		if ( box->flags & LBOX_VERT )									/* vertikales Scrolling? */
			set_slider_obj( box->first_a, number, box->visible_a,
								 tree[box->back1].ob_height, &tree[box->slider1].ob_y, &tree[box->slider1].ob_height );
		else
			set_slider_obj( box->first_a, number, box->visible_a,
								 tree[box->back1].ob_width, &tree[box->slider1].ob_x, &tree[box->slider1].ob_width );
	
		if ( rect )															/* Redraw des Sliders? */
			obj_redraw( box, rect, box->back1, MAX_DEPTH );
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* Element-Liste setzen																							*/
/* Funktionsresultat:	-																						*/
/*	box:						Zeiger auf die LIST_BOX-Struktur												*/
/* items:					Zeiger auf den ersten Eintrag der Scroll-Liste							*/
/*----------------------------------------------------------------------------------------*/ 
void	lbox_set_items( LIST_BOX *box, LBOX_ITEM *items )
{
	box->items = items;													/* neue Elementliste setzen */
}

/*----------------------------------------------------------------------------------------*/ 
/* Speicher fÅr alle EintrÑge in der Listbox freigeben												*/
/* Funktionsresultat:	1																						*/
/*	box:						Zeiger auf die LIST_BOX-Struktur												*/
/*----------------------------------------------------------------------------------------*/ 
void	lbox_free_items( LIST_BOX *box )
{
	lbox_free_list( box->items );
}

/*----------------------------------------------------------------------------------------*/ 
/* Speicher fÅr alle EintrÑge in der Listbox freigeben												*/
/* Funktionsresultat:	1																						*/
/* item:						Zeiger auf das erste LBOX_ITEM												*/
/*----------------------------------------------------------------------------------------*/ 
void	lbox_free_list( LBOX_ITEM *item )
{
	while ( item )
	{
		LBOX_ITEM *next;
		
		next = item->next;
		Mfree( item );														/* Speicher freigeben */
		item = next;														/* nÑchstes Element */
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* Slider A positionieren, Listbox aktualisieren und evtl. neuzeichnen 							*/
/* Funktionsresultat:	-																						*/
/*	box:						Zeiger auf die LIST_BOX-Struktur												*/
/*	first:					Index des ersten sichtbaren Elements										*/
/*	box_rect:				Redraw-Rechteck fÅr die Listbox oder 0L									*/
/*	slider_rect:			Redraw-Rechteck fÅr den Slider oder 0L										*/
/*----------------------------------------------------------------------------------------*/ 
void	lbox_ascroll_to( LIST_BOX *box, WORD first, GRECT *box_rect, GRECT *slider_rect )
{
	WORD	cnt;
	
	cnt = lbox_cnt_items( box );
	
	if ( first > ( cnt - box->visible_a ))							/* zu groû? */
		first = cnt - box->visible_a;

	if ( first < 0 )														/* zu klein? */
		first = 0;

	ascroll_to( box, box->first_a, first, box_rect, slider_rect );
}

/*----------------------------------------------------------------------------------------*/ 
/* Zweiten Slider positionieren und evtl. neuzeichnen (Elemente werden nicht aktualisiert)*/
/* Funktionsresultat:	-																						*/
/*	box:						Zeiger auf die LIST_BOX-Struktur												*/
/*	first:					Index des ersten sichtbaren Elements										*/
/*	rect:						Zeiger auf das Redraw-Rechteck oder 0L (keinen Redraw auslîsen)	*/
/*----------------------------------------------------------------------------------------*/ 
void	lbox_set_bsldr( LIST_BOX *box, WORD first, GRECT *rect )
{
	OBJECT	*tree;
	
	tree = box->tree;
	
	if ( first > box->entries_b - box->visible_b )
		first = box->entries_b - box->visible_b;
		
	if ( first < 0 )
		first = 0;

	box->first_b = first;												/* Verschiebung */

	if ( box->slider_h != -1 )											/* zweiter Slider vorhanden? */
	{
		if ( box->flags & LBOX_VERT )									/* vertikales Scrolling? */
			set_slider_obj( first, box->entries_b , box->visible_b,
								 tree[box->back_h].ob_width, &tree[box->slider_h].ob_x, &tree[box->slider_h].ob_width );
		else
			set_slider_obj( first, box->entries_b , box->visible_b,
								 tree[box->back_h].ob_height, &tree[box->slider_h].ob_y, &tree[box->slider1].ob_height );
	
		if ( rect )															/* Redraw des Sliders? */
			obj_redraw( box, rect, box->back_h, MAX_DEPTH );
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* Element-Liste setzen																							*/
/* Funktionsresultat:	-																						*/
/*	box:						Zeiger auf die LIST_BOX-Struktur												*/
/* items:					Zeiger auf den ersten Eintrag der Scroll-Liste							*/
/*----------------------------------------------------------------------------------------*/ 
void	lbox_set_bentries( LIST_BOX *box, WORD entries )
{
	box->entries_b = entries;											/* neue Elementanzahl fÅr Slider B setzen */
}

/*----------------------------------------------------------------------------------------*/ 
/* Slider B positionieren, Listbox aktualisieren und evtl. neuzeichnen 							*/
/* Funktionsresultat:	-																						*/
/*	box:						Zeiger auf die LIST_BOX-Struktur												*/
/*	first:					Index des ersten sichtbaren Elements										*/
/*	box_rect:				Redraw-Rechteck fÅr die Listbox oder 0L									*/
/*	slider_rect:			Redraw-Rechteck fÅr den Slider oder 0L										*/
/*----------------------------------------------------------------------------------------*/ 
void	lbox_bscroll_to( LIST_BOX *box, WORD first, GRECT *box_rect, GRECT *slider_rect )
{
	if ( first > ( box->entries_b - box->visible_b ))			/* zu groû? */
		first = box->entries_b - box->visible_b;

	if ( first < 0 )														/* zu klein? */
		first = 0;

	bscroll_to( box, box->first_b, first, box_rect, slider_rect );
}

/*----------------------------------------------------------------------------------------*/ 
/* Alle Strings der Listbox besetzen																		*/
/* Funktionsresultat:	-																						*/
/* box:						Zeiger auf die Listbox															*/
/* rect:						Zeiger auf GRECT fÅr Redraw oder 0L (keinen Redraw auslîsen)		*/
/*----------------------------------------------------------------------------------------*/ 
void	lbox_update( LIST_BOX *box, GRECT *rect )
{
	LBOX_ITEM	*item;
	WORD	i;
	WORD	first;
	
	item = box->items;
	first = box->first_a;

	while( first && item )
	{
		item = item->next;
		first--;
	}
	
	for( i = 0; i < box->visible_a; i++ )
	{
		set_item( box, item, box->obj_index[i], 0L );

		if ( item )
			item = item->next;

	}
	
	if ( rect )
		obj_redraw( box, rect, box->parent_box, MAX_DEPTH );
}


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
/* auf Scroll-Button reagieren																				*/
/* Funktionsresultat:	-																						*/
/*	box:						Zeiger auf die LIST_BOX-Struktur												*/
/*	button:					Nummer des ausgewÑhlten Objekts												*/
/*----------------------------------------------------------------------------------------*/ 
static void	do_scroll_button( LIST_BOX *box, WORD button )
{
	OBJECT	*tree;
	GRECT	*rect;
	WORD	d;
	WORD	mbutton;
	WORD	pause;
	
	tree = box->tree;
	rect = (GRECT *) &tree->ob_x;										/* Dialog-Rechteck */

	obj_change( tree, rect, button, SELECTED );

	pause = box->pause_a;
	if ( pause < 200 )
		pause = 200;														/* Anfangsverzîgerung auf 200ms einstellen */
	
	do 
	{
		WORD	p;
		
		p = pause;
		
		if ( button == box->button1 )									/* Scroll-Button 1? */
		{
			pause = box->pause_a;
			if ( box->flags & LBOX_VERT )								/* vertikales Scrolling? */
				scroll_up( box );											/* nach oben scrollen */
			else
				scroll_left( box );										/* nach links scrollen */
		}
		else if ( button == box->button2 )							/* Scroll-Button 2? */
		{
			pause = box->pause_a;
			if ( box->flags & LBOX_VERT )								/* vertikales Scrolling? */
				scroll_down( box );										/* nach unten scrollen */
			else
				scroll_right( box );										/* nach rechts scrollen */
		}
		else if ( button == box->button_hl )						/* Scroll-Button 3? */
		{
			pause = box->pause_b;
			if ( box->flags & LBOX_VERT )								/* vertikales Scrolling? */
				scroll_left( box );										/* nach links scrollen */
			else
				scroll_up( box );											/* nach oben scrollen */
		}
		else																	/* Scroll-Button 4 */
		{
			pause = box->pause_b;
			if ( box->flags & LBOX_VERT )								/* vertikales Scrolling? */
				scroll_right( box );										/* nach rechts scrollen */
			else
				scroll_down( box );										/* nach unten scrollen */
		}

		evnt_timer( p, 0 );												/* Verzîgerung */
		mkstate( &d, &d, &mbutton, &d );
	} while ( mbutton == 1 );											/* wird der Button noch gedrÅckt? */

	obj_change( tree, rect, button, NORMAL );
}

/*----------------------------------------------------------------------------------------*/ 
/* auf Slider-Hintergrund reagieren																			*/
/* Funktionsresultat:	-																						*/
/*	box:						Zeiger auf die LIST_BOX-Struktur												*/
/*	mx:						x-Koordinate des Mauszeigers													*/
/*	my:						y-Koordinate des Mauszeigers													*/
/*----------------------------------------------------------------------------------------*/ 
static void	do_slider_back( LIST_BOX *box, WORD mx, WORD my )
{
	WORD	visible;
	WORD	count;
	WORD	first;
	WORD	obj_x;
	WORD	obj_y;

	objc_offset( box->tree, box->slider1, &obj_x, &obj_y );	/* x- und y-Koordinate des Sliders */
		
	first = box->first_a;													/* Index des ersten sichtbaren Elements */
	visible = box->visible_a;
	count = lbox_cnt_items( box );									/* Anzahl der Elemente */

	if ( box->flags & LBOX_VERT )										/* vertikales Scrolling? */
	{
		if ( my < obj_y )													/* nach oben scrollen? */
			first -= visible;
		else
			first += visible;
	}
	else																		/* horizontales Scrolling */
	{
		if ( mx < obj_x )													/* nach links scrollen? */
			first -= visible;
		else
			first += visible;
	}
	
	if ( first < 0 )														/* zu klein? */
		first = 0;

	if ( first > count - visible )									/* zu groû? */
		first = count - visible;
			
	if ( first != box->first_a )										/* PositionsÑnderung? */
	{
		GRECT	*rect;
	
		rect = (GRECT *) &box->tree->ob_x;							/* Dialog-Rechteck */
	
		lbox_set_asldr( box, first, rect );							/* Slider positionieren und zeichnen */
		lbox_update( box, rect );										/* Listbox-Elemente zeichnen */
		evnt_timer( box->pause_a, 0 );								/* Verzîgerung */ 
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* auf Slider-Hintergrund reagieren																			*/
/* Funktionsresultat:	-																						*/
/*	box:						Zeiger auf die LIST_BOX-Struktur												*/
/*	mx:						x-Koordinate des Mauszeigers													*/
/*	my:						y-Koordinate des Mauszeigers													*/
/*----------------------------------------------------------------------------------------*/ 
static void	do_slider2_back( LIST_BOX *box, WORD mx, WORD my )
{
	WORD	first;
	WORD	obj_x;
	WORD	obj_y;

	objc_offset( box->tree, box->slider_h, &obj_x, &obj_y );	/* x- und y-Koordinate des Sliders */
		
	first = box->first_b;												/* Index des ersten sichtbaren Elements */

	if ( box->flags & LBOX_VERT )										/* vertikale Listbox? */
	{
		if ( mx < obj_x )													/* nach links scrollen? */
			first -= box->visible_b;
		else
			first += box->visible_b;
	}
	else																		/* horizontale Listbox */
	{
		if ( my < obj_y )													/* nach oben scrollen? */
			first -= box->visible_b;
		else
			first += box->visible_b;
	}
	
	if ( first < 0 )														/* zu klein? */
		first = 0;

	if ( first > box->entries_b - box->visible_b )				/* zu groû? */
		first = box->entries_b - box->visible_b;
			
	if ( first != box->first_b )										/* PositionsÑnderung? */
	{
		GRECT	*rect;
	
		rect = (GRECT *) &box->tree->ob_x;							/* Dialog-Rechteck */
	
		lbox_set_bsldr( box, first, rect );							/* Slider positionieren und zeichnen */
		lbox_update( box, rect );										/* Listbox-Elemente zeichnen */
		evnt_timer( box->pause_b, 0 );								/* Verzîgerung */ 
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* auf Slider reagieren																							*/
/* Funktionsresultat:	-																						*/
/*	box:						Zeiger auf die LIST_BOX-Struktur												*/
/*	mx:						x-Koordinate des Mauszeigers													*/
/*	my:						y-Koordinate des Mauszeigers													*/
/*----------------------------------------------------------------------------------------*/ 
static void	do_slider( LIST_BOX *box, WORD mx, WORD my )
{
	WORD	count;
	
	count = lbox_cnt_items( box );									/* Anzahl der EintrÑge */
	
	if( count > box->visible_a )										/* genÅgend EintrÑge zum Scrollen vorhanden? */
	{
		OBJECT	*tree;
		GRECT	*rect;

		graf_mouse( FLAT_HAND, 0 );									/* Mausform umschalten: Hand */

		tree = box->tree;													/* Zeiger auf den Objektbaum */
		rect = (GRECT *) &tree->ob_x;									/* Dialog-Rechteck */

		if ( box->flags & LBOX_REAL )									/* Real-Time-Scrolling? */
		{
			WORD	mbutton;
			WORD	kstate;
	
			WORD	d;
			WORD	offset;
			WORD	ob;
			WORD	ob_min;
			WORD	ob_max;

			if ( box->flags & LBOX_VERT )								/* vertikales Scrolling? */
			{	
				objc_offset( tree, box->back1, &d, &ob_min );		/* y-Koordinate des Slider-Backgrounds */
				objc_offset( tree, box->slider1, &d, &ob );			/* y-Koordinate des Sliders */
		 		ob_max = tree[box->back1].ob_height - tree[box->slider1].ob_height - 1;
				offset = my - ob;											/* Abstand des Mauszeigers zur Slider-Oberkante */
			}
			else
			{
				objc_offset( tree, box->back1, &ob_min, &d );		/* x-Koordinate des Slider-Backgrounds */
				objc_offset( tree, box->slider1, &ob, &d );			/* x-Koordinate des Sliders */
		 		ob_max = tree[box->back1].ob_width - tree[box->slider1].ob_width - 1;
				offset = mx - ob;											/* Abstand des Mauszeigers zum Slider-Rand */
			}
	 		
	 		do
			{
				if ( box->flags & LBOX_VERT )							/* vertikales Scrolling? */
					real_aslider( box, count, my - offset, ob_min, ob_max );
				else
					real_aslider( box, count, mx - offset, ob_min, ob_max );
			
				appl_yield();
				mkstate( &mx, &my, &mbutton, &kstate );
			} while ( mbutton == 1 );									/* wird die Maustaste noch gedrÅckt? */
		}
		else
		{
			WORD	pos;
	 		WORD	first;
	 		
	 		pos = graf_slidebox( tree, box->back1, box->slider1, box->flags & LBOX_VERT );	/* Slider verschieben */
			first = (WORD) ((LONG) ( count - box->visible_a ) * pos / 1000L );	/* Index des ersten sichbaren Elements */
			
			if ( first != box->first_a )								/* PositionsÑnderung? */
			{
				lbox_set_asldr( box, first, rect );					/* Slider positionieren und zeichnen */
				lbox_update( box, rect );								/* Listbox-Elemente zeichnen */
			}
		}
		graf_mouse( ARROW, 0 );											/* Mausform umschalten: Pfeil */
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* Slider A verschieben und Inhalt neuzeichnen															*/
/* Funktionsresultat:	-																						*/
/*	box:						Zeiger auf die LIST_BOX-Struktur												*/
/*	count:					Anzahl der Elemente																*/
/*	xy:						x- oder y-Koordinate des Sliders												*/
/*	ob_min:					minimale Koordinate des Sliders												*/
/*	ob_max:					maximale Koordinate des Sliders												*/
/*----------------------------------------------------------------------------------------*/ 
static void	real_aslider( LIST_BOX *box, WORD count, WORD xy, WORD ob_min, WORD ob_max )
{
	OBJECT	*tree;
	WORD	previous;
	WORD	first;

	previous = box->first_a;											/* Index des bisher sichtbaren ersten Elements */

	xy -= ob_min;
	
	if ( xy < 0 )															/* Maus Åberhalb/links des Slider-Backgrounds? */
		xy = 0;
		
	if ( xy > ob_max )													/* Maus unterhalb/rechts des Slider-Backgrounds? */
		 xy = ob_max;
	
	first = (WORD) (((LONG)( count - box->visible_a )) * xy / ob_max );	/* Index des ersten sichtbaren Elements */
	
	tree = box->tree;
	ascroll_to( box, previous, first, (GRECT *) &tree->ob_x, (GRECT *) &tree->ob_x );
}

/*----------------------------------------------------------------------------------------*/ 
/* Slider A verschieben, Inhalt scrollen und neuzeichnen												*/
/* Funktionsresultat:	-																						*/
/*	box:						Zeiger auf die LIST_BOX-Struktur												*/
/* old:						bisher sichtbares erstes Element												*/
/*	box_rect:				Redraw-Rechteck fÅr die Listbox												*/
/*	slider_rect:			Redraw-Rechteck fÅr den Slider												*/
/*----------------------------------------------------------------------------------------*/ 
static void ascroll_to( LIST_BOX *box, WORD old, WORD new, GRECT *box_rect, GRECT *slider_rect )
{
	if ( new != old )														/* PositionsÑnderung? */
	{
		OBJECT	*tree;
		GRECT	rect;
		
		tree = box->tree;

 		lbox_set_asldr( box, new, slider_rect );					/* Slider positionieren und zeichnen */

		get_GRECT( tree, box->parent_box, &rect );				/* GRECT des Hintergrundobjekts berechnen (ohne zusÑtzliche RÑnder!) */
		
		if ( box_rect && rc_intersect( box_rect, &rect ))		/* innerhalb des Redraw-Rechtecks? */
		{
			if ( is_visible( box, &rect ))							/* Listbox vollstÑndig sichtbar? */
			{
				WORD	x1;
				WORD	y1;
				WORD	x2;
				WORD	y2;
				WORD	w;
				WORD	h;
				WORD	last_obj;
			
				if (( new < old ) && (( new + box->visible_a ) > old ))	/* Scrolling nach links bzw. oben? */
				{
					objc_offset( tree, box->obj_index[0], &x1, &y1 );	/* x/y-Quellkoordinaten */
					objc_offset( tree, box->obj_index[old - new], &x2, &y2 );	/* x/y-Zielkoordinaten */
					
					last_obj = box->obj_index[box->visible_a + new - old - 1];
					objc_offset( tree, last_obj, &w, &h );			/* x/y-Zielkoordinaten */
					w -= x1;
					w += tree[last_obj].ob_width;
					h -= y1;
					h += tree[last_obj].ob_height;
					
					move_area( tree, box->parent_box, x1, y1, x2, y2, w, h );	/* Bereich verschieben */
		
					if ( box->flags & LBOX_VERT )
						rect.g_h -= h;										/* Hîhe des Redraw-Rechtecks verkleinern */
					else
						rect.g_w -= w;										/* Breite des Redraw-Rechtecks verkleinern */
				}
		
				if (( new > old ) && (( new - box->visible_a ) < old ))	/* Scrolling nach rechts bzw. unten? */
				{
					objc_offset( tree, box->obj_index[new - old], &x1, &y1 );	/* x/y-Quellkoordinaten */
					objc_offset( tree, box->obj_index[0], &x2, &y2 );	/* x/y-Zielkoordinaten */
					
					last_obj = box->obj_index[box->visible_a + old - new - 1];
					objc_offset( tree, last_obj, &w, &h );			/* x/y-Zielkoordinaten */
					w -= x1;
					w += tree[last_obj].ob_width;
					h -= y1;
					h += tree[last_obj].ob_height;
					
					move_area( tree, box->parent_box, x1, y1, x2, y2, w, h );	/* Bereich verschieben */
		
					if ( box->flags & LBOX_VERT )
					{
						rect.g_y += h;										/* y-Koordinate des Redraw-Rechtecks verschieben */
						rect.g_h -= h;										/* Hîhe des Redraw-Rechtecks verkleinern */
					}
					else
					{
						rect.g_x += w;										/* x-Koordinate des Redraw-Rechtecks verschieben */
						rect.g_w -= w;										/* Breite des Redraw-Rechtecks verkleinern */
					}
				}
			}
			lbox_update( box, &rect );									/* Listbox-Elemente zeichnen */
		}
		else
			lbox_update( box, 0L );										/* Listbox-Elemente eintragen, nicht zeichnen */
	}
}

static void	do_slider_b( LIST_BOX *box, WORD mx, WORD my )
{
	if( box->entries_b > box->visible_b )							/* genÅgend EintrÑge zum Scrollen vorhanden? */
	{
		OBJECT	*tree;
		GRECT	*rect;

		graf_mouse( FLAT_HAND, 0 );									/* Mausform umschalten: Hand */

		tree = box->tree;													/* Zeiger auf den Objektbaum */
		rect = (GRECT *) &tree->ob_x;									/* Dialog-Rechteck */

		if ( box->flags & LBOX_REAL )									/* Real-Time-Scrolling? */
		{
			WORD	mbutton;
			WORD	kstate;
	
			WORD	d;
			WORD	offset;
			WORD	ob;
			WORD	ob_min;
			WORD	ob_max;

			if ( box->flags & LBOX_VERT )								/* vertikales Scrolling? */
			{
				objc_offset( tree, box->back_h, &ob_min, &d );		/* x-Koordinate des Slider-Backgrounds */
				objc_offset( tree, box->slider_h, &ob, &d );			/* x-Koordinate des Sliders */
		 		ob_max = tree[box->back_h].ob_width - tree[box->slider_h].ob_width - 1;
				offset = mx - ob;											/* Abstand des Mauszeigers zum Slider-Rand */
			}
			else
			{	
				objc_offset( tree, box->back_h, &d, &ob_min );		/* y-Koordinate des Slider-Backgrounds */
				objc_offset( tree, box->slider_h, &d, &ob );			/* y-Koordinate des Sliders */
		 		ob_max = tree[box->back_h].ob_height - tree[box->slider_h].ob_height - 1;
				offset = my - ob;											/* Abstand des Mauszeigers zur Slider-Oberkante */
			}
	 		
	 		do
			{
				if ( box->flags & LBOX_VERT )							/* vertikales Scrolling? */
					real_bslider( box, box->entries_b, mx - offset, ob_min, ob_max );
				else
					real_bslider( box, box->entries_b, my - offset, ob_min, ob_max );
			
				appl_yield();
				mkstate( &mx, &my, &mbutton, &kstate );
			} while ( mbutton == 1 );									/* wird die Maustaste noch gedrÅckt? */
		}
		else
		{
			WORD	pos;
	 		WORD	first;
	 		
	 		pos = graf_slidebox( tree, box->back_h, box->slider_h, !( box->flags & LBOX_VERT ));	/* Slider verschieben */
			first = (WORD) ((LONG) ( box->entries_b - box->visible_b ) * pos / 1000L );	/* Index des ersten sichbaren Elements */
			
			if ( first != box->first_b )								/* PositionsÑnderung? */
			{
				lbox_set_bsldr( box, first, rect );					/* Slider positionieren und zeichnen */
				lbox_update( box, rect );								/* Listbox-Elemente zeichnen */
			}
		}
		graf_mouse( ARROW, 0 );											/* Mausform umschalten: Pfeil */
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* Slider B verschieben und Inhalt neuzeichnen															*/
/* Funktionsresultat:	-																						*/
/*	box:						Zeiger auf die LIST_BOX-Struktur												*/
/*	count:					Anzahl der Elemente																*/
/*	xy:						x- oder y-Koordinate des Sliders												*/
/*	ob_min:					minimale Koordinate des Sliders												*/
/*	ob_max:					maximale Koordinate des Sliders												*/
/*----------------------------------------------------------------------------------------*/ 
static void	real_bslider( LIST_BOX *box, WORD count, WORD xy, WORD ob_min, WORD ob_max )
{
	OBJECT	*tree;
	WORD	previous;
	WORD	first;

	previous = box->first_b;											/* Index des bisher sichtbaren ersten Elements */

	xy -= ob_min;
	
	if ( xy < 0 )															/* Maus Åberhalb/links des Slider-Backgrounds? */
		xy = 0;
		
	if ( xy > ob_max )													/* Maus unterhalb/rechts des Slider-Backgrounds? */
		 xy = ob_max;
	
	first = (WORD) (((LONG)( count - box->visible_b )) * xy / ob_max );	/* Index des ersten sichtbaren Elements */
	
	tree = box->tree;
	bscroll_to( box, previous, first, (GRECT *) &tree->ob_x, (GRECT *) &tree->ob_x );
}

/*----------------------------------------------------------------------------------------*/ 
/* Slider B verschieben, Inhalt scrollen und neuzeichnen												*/
/* Funktionsresultat:	-																						*/
/*	box:						Zeiger auf die LIST_BOX-Struktur												*/
/* old:						bisher sichtbares erstes Element												*/
/*	box_rect:				Redraw-Rechteck fÅr die Listbox												*/
/*	slider_rect:			Redraw-Rechteck fÅr den Slider												*/
/*----------------------------------------------------------------------------------------*/ 
static void bscroll_to( LIST_BOX *box, WORD old, WORD new, GRECT *box_rect, GRECT *slider_rect )
{
	if ( new != old )														/* PositionsÑnderung? */
	{
		OBJECT	*tree;
		GRECT	rect;
		
		tree = box->tree;

		get_GRECT( tree, box->parent_box, &rect );				/* GRECT des Hintergrundobjekts berechnen (ohne zusÑtzliche RÑnder!) */
		
		if ( box_rect && rc_intersect( box_rect, &rect ))		/* innerhalb des Redraw-Rechtecks? */
		{
			if ( is_visible( box, &rect ))							/* Listbox vollstÑndig sichtbar? */
			{
				if ((( new < old ) && (( new + box->visible_b ) > old )) || (( new > old ) && (( new - box->visible_b ) < old )))
				{
					if ( box->flags & LBOX_VERT )						/* vertikale Listbox? */
					{
						WORD		dx;
						WORD		x;
						WORD		w;
												
						dx = tree[*box->obj_index].ob_width / box->visible_b;		
			
						if ( new < old )									/* nach links scrollen? */
						{
							x = rect.g_x + ( dx * ( old - new ));
							w = rect.g_w - ( dx * ( old - new ));
							bscroll( box, new, rect.g_x, rect.g_y, x, rect.g_y, w, rect.g_h );
						}
						else													/* nach rechts scrollen */
						{
							x = rect.g_x + ( dx * ( new - old ));
							w = rect.g_w - ( dx * ( new - old ));
							bscroll( box, new, x, rect.g_y, rect.g_x, rect.g_y, w, rect.g_h );
						}
					}
					else														/* horizontale Listbox */
					{
						WORD		dy;
						WORD		y;
						WORD		h;

						dy = tree[*box->obj_index].ob_height / box->visible_b;		
			
						if ( new < old )									/* nach oben scrollen? */
						{
							y = rect.g_y + ( dy * ( old - new ));
							h = rect.g_h - ( dy * ( old - new ));
							bscroll( box, new, rect.g_x, rect.g_y, rect.g_x, y, rect.g_w, h );
						}
						else													/* nach unten scrollen */
						{
							y = rect.g_y + ( dy * ( new - old ));
							h = rect.g_h - ( dy * ( new - old ));
							bscroll( box, new, rect.g_x, y, rect.g_x, rect.g_y, rect.g_w, h );
						}
					}
					return;
				}
			}
	 		lbox_set_bsldr( box, new, slider_rect );				/* Slider positionieren und zeichnen */
			lbox_update( box, &rect );									/* Listbox-Elemente zeichnen */
		}
		else
	 	{
	 		lbox_set_bsldr( box, new, slider_rect );				/* Slider positionieren und zeichnen */
			lbox_update( box, 0L );										/* Listbox-Elemente eintragen, nicht zeichnen */
		}
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* Ggf. automatisch scrollen, wenn erstes oder letztes Element ausgewÑhlt wurden				*/
/* Funktionsresultat:	0: kein Scrolling, 1: es wurde gescrollt									*/
/*	box:						Zeiger auf die LIST_BOX-Struktur												*/
/*	obj:						Nummer des ausgewÑhlten Objekts												*/
/*----------------------------------------------------------------------------------------*/ 
static WORD	auto_scroll( LIST_BOX *box, WORD obj )
{
	OBJECT	*o;
	WORD	obj_x;
	WORD	obj_y;
				
	o = box->tree;															/* Zeiger auf den Objektbaum */
	objc_offset( o, obj, &obj_x, &obj_y );							/* x- und y-Koordinate des Sliders */
	o += obj;																/* Zeiger auf das Objekt */
	
	if ( obj == box->obj_index[0] )									/* erstes sichtbares Element? */
	{
		if ( box->flags & LBOX_VERT )
			auto_scroll_up( box, obj_y );								/* vertikales Scrolling */
		else													
			auto_scroll_left( box, obj_x );							/* horizontales Scrolling */

		return( 1 );
	}
	else if ( obj == box->obj_index[box->visible_a - 1] )		/* letztes sichtbares Element? */
	{
		if ( box->flags & LBOX_VERT )
			auto_scroll_down( box, obj_y += o->ob_height );		/* vertikales Scrolling */
		else
			auto_scroll_right( box, obj_x += o->ob_width );		/* horizontales Scrolling */

		return( 1 );
	}
	
	return( 0 );															/* kein Scrolling */
}

/*----------------------------------------------------------------------------------------*/ 
/* nach oben scrollen, wenn die Maustaste Åber dem ersten Element gehalten wird				*/
/* Funktionsresultat:	-																						*/
/*	box:						Zeiger auf die LIST_BOX-Struktur												*/
/*	obj_y:					y-Koordinate des ersten Objekts												*/
/*----------------------------------------------------------------------------------------*/ 
static void	auto_scroll_up( LIST_BOX *box, WORD obj_y )
{
	LBOX_ITEM	*item;
	WORD	last_state;
	WORD	mx;
	WORD	my;
	WORD	mbutton;
	WORD	kstate;

	item = 0L;
	mkstate( &mx, &my, &mbutton, &kstate );						/* Mausstatus */

	while (( my <= obj_y + 1 ) && ( mbutton == 1 ))				/* ist die Maus Oberhalb des Objekts? */
	{
		if ( box->first_a > 0 )											/* kann noch nach oben gescrollt werden? */
		{
			item = lbox_get_item( box, box->first_a - 1 );		/* Zeiger auf das Element Åber dem ersten sichtbaren */
			last_state = item->selected;								/* Status merken */

			if (( box->flags & LBOX_SNGL ) ||						/* keine Mehrfachselektion erlaubt oder */
				(( box->flags & LBOX_SHFT ) &&						/* nur mit gedrÅckter Shift-Taste erlaubt */
				(( kstate & ( K_LSHIFT + K_RSHIFT )) == 0 )))	/* und Shift ist nicht gedrÅckt? */
				deselect_list( box );									/* deselektieren */
	
			item->selected = !item->selected;						/* Element anwÑhlen */
			scroll_up( box );												/* nach oben scrollen */

			if ( box->flags & LBOX_AUTOSLCT )						/* auch beim Scrollen Service-Routine anspringen? */				
				slct_item( box, item, box->obj_index[0], last_state );

			do_scroll_pause( obj_y - my ); 							/* Verzîgerung je nach Abstand */
		}
		else
		{
			if (( mbutton == 0 ) || ( my > obj_y ))				/* warten bis Maustaste losgelassen wird oder die Maus nach unten geschoben wird */
				break;

			appl_yield();													/* Rechenzeit abgeben */
		}
		mkstate( &mx, &my, &mbutton, &kstate );
	}

	if ( item && (( box->flags & LBOX_AUTOSLCT ) == 0 ))		/* wurde die Service-Routine noch nicht angesprungen? */
		slct_item( box, item, box->obj_index[0], last_state );
}

/*----------------------------------------------------------------------------------------*/ 
/* nach links scrollen, wenn die Maustaste Åber dem ersten Element gehalten wird				*/
/* Funktionsresultat:	-																						*/
/*	box:						Zeiger auf die LIST_BOX-Struktur												*/
/*	obj_x:					x-Koordinate des ersten Objekts												*/
/*----------------------------------------------------------------------------------------*/ 
static void	auto_scroll_left( LIST_BOX *box, WORD obj_x )
{
	LBOX_ITEM	*item;
	WORD	last_state;
	WORD	mx;
	WORD	my;
	WORD	mbutton;
	WORD	kstate;

	item = 0L;
	mkstate( &mx, &my, &mbutton, &kstate );						/* Mausstatus */

	while (( mx <= obj_x + 1 ) && ( mbutton == 1 ))
	{
		if ( box->first_a > 0 )											/* kann noch nach links gescrollt werden? */
		{
			item = lbox_get_item( box, box->first_a - 1 );		/* Zeiger auf Element links des ersten sichtbaren */
			last_state = item->selected;								/* Status merken */

			if (( box->flags & LBOX_SNGL ) ||						/* keine Mehrfachselektion erlaubt oder */
				(( box->flags & LBOX_SHFT ) &&						/* nur mit gedrÅckter Shift-Taste erlaubt */
				(( kstate & ( K_LSHIFT + K_RSHIFT )) == 0 )))	/* und Shift ist nicht gedrÅckt? */
				deselect_list( box );									/* deselektieren */

			item->selected = !item->selected;						/* Element selektieren */
			scroll_left( box );											/* nach links scrollen */

			if ( box->flags & LBOX_AUTOSLCT )						/* auch beim Auto-Scrolling Service-Routine anspringen? */
				slct_item( box, item, box->obj_index[0], last_state );

			do_scroll_pause( obj_x - mx );							/* Verzîgerung je nach Abstand*/
		}
		else
		{
			if (( mbutton == 0 ) || ( mx > obj_x ))				/* warten bis Maustaste losgelassen wird oder die Maus nach rechts geschoben wird */
				break;

			appl_yield();													/* Rechenzeit abgeben */
		}
		mkstate( &mx, &my, &mbutton, &kstate );
	}

	if ( item && (( box->flags & LBOX_AUTOSLCT ) == 0 ))		/* wurde die Service-Routine noch nicht angesprungen? */
		slct_item( box, item, box->obj_index[0], last_state );
}

/*----------------------------------------------------------------------------------------*/ 
/* nach unten scrollen, wenn die Maustaste Åber dem letzten Element gehalten wird			*/
/* Funktionsresultat:	-																						*/
/*	box:						Zeiger auf die LIST_BOX-Struktur												*/
/*	obj_y:					y2-Koordinate des letzten Objekts (ob_y + ob_height - 1)				*/
/*----------------------------------------------------------------------------------------*/ 
static void	auto_scroll_down( LIST_BOX *box, WORD obj_y )
{
	LBOX_ITEM	*item;
	WORD	last_state;
	WORD	mx;
	WORD	my;
	WORD	mbutton;
	WORD	kstate;
	WORD	count;

	count = lbox_cnt_items( box );									/* Anzahl der EintrÑge */
	item = 0L;

	mkstate( &mx, &my, &mbutton, &kstate );						/* Mausstatus */
	
	while (( my >= obj_y - 1 ) && ( mbutton == 1 ))
	{
		if ( box->first_a < count - box->visible_a )				/* kan noch nach unten gescrollt werden? */
		{
			item = lbox_get_item( box, box->first_a + box->visible_a );	/* Zeiger auf Element unter dem letzten sichtbaren */	
			last_state = item->selected;								/* Status merken */

			if (( box->flags & LBOX_SNGL ) ||						/* keine Mehrfachselektion erlaubt oder */
				(( box->flags & LBOX_SHFT ) &&						/* nur mit gedrÅckter Shift-Taste erlaubt */
				(( kstate & ( K_LSHIFT + K_RSHIFT )) == 0 )))	/* und Shift ist nicht gedrÅckt? */
				deselect_list( box );									/* deselektieren */

			item->selected = !item->selected;						/* Element selektieren */
			scroll_down( box );											/* nach unten scrollen */

			if ( box->flags & LBOX_AUTOSLCT )						/* auch beim Auto-Scrolling Service-Routine anspringen? */
				slct_item( box, item, box->obj_index[box->visible_a - 1], last_state );

			do_scroll_pause( my - obj_y );							/* Verzîgerung je nach Abstand */ 			
		}
		else
		{
			if (( mbutton == 0 ) || ( my < obj_y ))				/* warten bis Maustaste losgelassen wird oder die Maus nach oben geschoben wird */
				break;
				
			appl_yield();													/* Rechenzeit abgeben */
		}
		mkstate( &mx, &my, &mbutton, &kstate );
	}

	if ( item && (( box->flags & LBOX_AUTOSLCT ) == 0 ))		/* wurde die Service-Routine noch nicht angesprungen? */
		slct_item( box, item, box->obj_index[box->visible_a - 1], last_state );
}

/*----------------------------------------------------------------------------------------*/ 
/* nach rechts scrollen, wenn die Maustaste Åber dem letzten Element gehalten wird			*/
/* Funktionsresultat:	-																						*/
/*	box:						Zeiger auf die LIST_BOX-Struktur												*/
/*	obj_x:					x2-Koordinate des letzten Objekts (ob_x + ob_width - 1)				*/
/*----------------------------------------------------------------------------------------*/ 
static void	auto_scroll_right( LIST_BOX *box, WORD obj_x )
{
	LBOX_ITEM	*item;
	WORD	last_state;
	WORD	mx;
	WORD	my;
	WORD	mbutton;
	WORD	kstate;
	WORD	count;

	item = 0L;
	count = lbox_cnt_items( box );									/* Anzahl der EintrÑge */
	mkstate( &mx, &my, &mbutton, &kstate );						/* Mausstatus */

	while (( mx >= obj_x - 1 ) && ( mbutton == 1 ))
	{
		if ( box->first_a < count - box->visible_a )				/* kann noch nach rechts gescrollt werden? */
		{
			item = lbox_get_item( box, box->first_a + box->visible_a );	/* Zeiger auf Element rechts vom letzten sichtbaren */	
			last_state = item->selected;								/* Status merken */

			if (( box->flags & LBOX_SNGL ) ||						/* keine Mehrfachselektion erlaubt oder */
				(( box->flags & LBOX_SHFT ) &&						/* nur mit gedrÅckter Shift-Taste erlaubt */
				(( kstate & ( K_LSHIFT + K_RSHIFT )) == 0 )))	/* und Shift ist nicht gedrÅckt? */
				deselect_list( box );									/* deselektieren */

			item->selected = !item->selected;						/* Element selektieren */
			scroll_right( box );											/* nach rechts scrollen */

			if ( box->flags & LBOX_AUTOSLCT )						/* auch beim Auto-Scrolling Service-Routine anspringen? */				
				slct_item( box, item, box->obj_index[box->visible_a - 1], last_state );

			do_scroll_pause( mx - obj_x );							/* Verzîgerung je nach Abstand setzen */ 			
		}
		else
		{
			if (( mbutton == 0 ) || ( mx < obj_x ))				/* warten bis Maustaste losgelassen wird oder die Maus nach links geschoben wird */
				break;
				
			appl_yield();													/* Rechenzeit abgeben */
		}
		mkstate( &mx, &my, &mbutton, &kstate );
	}

	if ( item && (( box->flags & LBOX_AUTOSLCT ) == 0 ))		/* wurde die Service-Routine noch nicht angesprungen? */
		slct_item( box, item, box->obj_index[box->visible_a - 1], last_state );
}

/*----------------------------------------------------------------------------------------*/ 
/* Verzîgerung beim Auto-Scrolling je nach Abstand der Maus zum Objekt setzen					*/
/* Funktionsresultat:	-																						*/
/*	offset:					Abstand der Maus vom Objekt (negativ: dann Vorzeichenwechsel)		*/
/*----------------------------------------------------------------------------------------*/ 
static void	do_scroll_pause( WORD offset )
{					
	WORD	pause;

	if ( offset < 0 )														/* negativer Abstand? */
		offset = -offset;													/* Vorzeichen wechseln */
		
	pause = 0;
	
	if ( offset < 14 )													/* Abstand kleiner als 14 Pixel? */
		pause = 20;
	if ( offset < 10 )													/* Abstand kleiner als 10 Pixel? */
		pause = 40;
	if ( offset < 6 )														/* Abstand kleiner als 6 Pixel? */
		pause = 80;
	if ( offset < 2 )														/* Abstand kleiner als 2 Pixel? */
		pause = 160;

	evnt_timer( pause, 0 );												/* warten */
}

/*----------------------------------------------------------------------------------------*/ 
/* Objektausmaûe des Slider setzen																			*/
/* Funktionsresultat:	-																						*/
/*	box:						Zeiger auf die LIST_BOX-Struktur												*/
/*	number:					Anzahl der EintrÑge 																*/
/*	wh:						Breite oder Hîhe des Slider-Hintergrunds									*/
/*	ob_xy:					Zeiger auf ob_x oder ob_y des Slider-Objekts								*/
/*	ob_wh:					Zeiger auf ob_width oder ob_height des Slider-Objekts					*/
/*----------------------------------------------------------------------------------------*/ 
static void	set_slider_obj( WORD first, WORD number, WORD visible, WORD wh, WORD *ob_xy, WORD *ob_wh )
{
	if( number > visible )												/* Slider vorhanden? */
	{
		WORD	slider_xy;
		WORD 	slider_wh;
	
		slider_wh = (WORD) (( visible * (LONG) wh ) / number );
		
		if ( slider_wh < 12 )											/* Slider kleiner als 12 Pixel? */
			slider_wh = 12;
		
		slider_xy = (WORD) (( wh - slider_wh ) * (LONG) first / ( number - visible ));
		
		*ob_xy = slider_xy;												/* Slider-Position */
		*ob_wh = slider_wh;												/* Breite/Hîhe des Sliders */
	}
	else
	{
		*ob_xy = 0;
		*ob_wh = wh;
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* In der Listbox hochscrollen																				*/
/* Funktionsresultat:	-																						*/
/* item:						Zeiger auf den ersten Eintrag der Scroll-Liste							*/
/*----------------------------------------------------------------------------------------*/ 
static void scroll_up( LIST_BOX *box )
{
	OBJECT	*tree;
	WORD		*obj_index;
	
	tree = box->tree;														/* Zeiger auf den Objektbaum */
	obj_index = box->obj_index;
	
	if ( box->flags & LBOX_VERT )										/* vertikale Listbox? */
	{
		if( box->first_a > 0 )											/* noch nicht oben? */
		{
			WORD	x1;
			WORD	y1;
			WORD	x2;
			WORD	y2;
			WORD	x3;
			WORD	y3;
			
			WORD	first_obj;
			WORD	second_obj;
			WORD	last_obj;
	
			first_obj = obj_index[0];									/* erstes Objekt in der Liste */
			second_obj = obj_index[1];									/* zweites Objekt in der Liste */
			last_obj = obj_index[box->visible_a - 1];				/* letztes Objekt in der Liste */
			
			objc_offset( tree, first_obj, &x1, &y1 );
			objc_offset( tree, last_obj, &x2, &y2 );
			objc_offset( tree, second_obj, &x3, &y3 );
	
			ascroll( box, box->first_a - 1, first_obj, x1, y1, x1, y3, tree[first_obj].ob_width, y2 - y1 );	/* Ausschnitt verschieben */
		}
	}
	else																		/* horizontale Listbox */
	{
		if ( box->first_b > 0 )											/* noch nicht oben? */
		{
			GRECT		rect;
			WORD		dy;
			WORD		y;
			WORD		h;

			get_GRECT( tree, box->parent_box, &rect );
			dy = tree[*obj_index].ob_height / box->visible_b;		
			y = rect.g_y + dy;
			h = rect.g_h - dy;

			bscroll( box, box->first_b - 1, rect.g_x, rect.g_y, rect.g_x, y, rect.g_w, h );
		}
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* In der Listbox herunterscrollen																			*/
/* Funktionsresultat:	-																						*/
/* item:						Zeiger auf den ersten Eintrag der Scroll-Liste							*/
/*----------------------------------------------------------------------------------------*/ 
static void scroll_down( LIST_BOX *box )
{
	OBJECT	*tree;
	WORD		*obj_index;
	
	tree = box->tree;														/* Zeiger auf den Objektbaum */
	obj_index = box->obj_index;
	
	if ( box->flags & LBOX_VERT )										/* vertikale Listbox? */
	{
		if( box->first_a + box->visible_a < lbox_cnt_items( box ))	/* noch nicht unten? */
		{
			WORD	x1;
			WORD	y1;
			WORD	x2;
			WORD	y2;
			WORD	x3;
			WORD	y3;
			
			WORD	first_obj;
			WORD	second_obj;
			WORD	last_obj;
			
			first_obj = obj_index[0];									/* erstes Objekt in der Liste */
			second_obj = obj_index[1];									/* zweites Objekt in der Liste */
			last_obj = obj_index[box->visible_a - 1];				/* letztes Objekt in der Liste */
	
			objc_offset( tree, second_obj, &x1, &y1 );
			objc_offset( tree, last_obj, &x2, &y2 );
			objc_offset( tree, first_obj, &x3, &y3 );
	
			ascroll( box, box->first_a + 1, last_obj, x1, y1, x1, y3, tree[second_obj].ob_width, y2 - y3 );	/* Ausschnitt verschieben */
		}
	}
	else																		/* horizontale Listbox */
	{
		if ( box->first_b < box->entries_b - box->visible_b )	/* noch nicht unten? */
		{
			GRECT		rect;
			WORD		dy;
			WORD		y;
			WORD		h;

			get_GRECT( tree, box->parent_box, &rect );
			dy = tree[*obj_index].ob_height / box->visible_b;		
			y = rect.g_y + dy;
			h = rect.g_h - dy;

			bscroll( box, box->first_b + 1, rect.g_x, y, rect.g_x, rect.g_y, rect.g_w, h );
		}
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* In der Listbox hochscrollen																				*/
/* Funktionsresultat:	-																						*/
/* item:						Zeiger auf den ersten Eintrag der Scroll-Liste							*/
/*----------------------------------------------------------------------------------------*/ 
static void	scroll_left( LIST_BOX *box )
{
	OBJECT	*tree;
	WORD		*obj_index;
	
	tree = box->tree;														/* Zeiger auf den Objektbaum */
	obj_index = box->obj_index;
	
	if ( box->flags & LBOX_VERT )										/* vertikale Listbox? */
	{
		if ( box->first_b > 0 )											/* noch nicht links? */
		{
			GRECT		rect;
			WORD		dx;
			WORD		x;
			WORD		w;

			get_GRECT( tree, box->parent_box, &rect );
			dx = tree[*obj_index].ob_width / box->visible_b;		
			x = rect.g_x + dx;
			w = rect.g_w - dx;

			bscroll( box, box->first_b - 1, rect.g_x, rect.g_y, x, rect.g_y, w, rect.g_h );
		}
	}
	else																		/* horizontale Listbox */
	{
		if( box->first_a > 0 )											/* noch nicht links? */
		{
			WORD	x1;
			WORD	y1;
			WORD	x2;
			WORD	y2;
			WORD	x3;
			WORD	y3;
			
			WORD	first_obj;
			WORD	second_obj;
			WORD	last_obj;
			
			first_obj = obj_index[0];									/* erstes Objekt in der Liste */
			second_obj = obj_index[1];									/* zweites Objekt in der Liste */
			last_obj = obj_index[box->visible_a - 1];				/* letztes Objekt in der Liste */
			
			objc_offset( tree, first_obj, &x1, &y1 );
			objc_offset( tree, last_obj, &x2, &y2 );
			objc_offset( tree, second_obj, &x3, &y3 );
	
			ascroll( box, box->first_a - 1, first_obj, x1, y1, x3, y1, x2 - x1, tree[first_obj].ob_height );	/* Ausschnitt verschieben */
		}
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* In der Listbox herunterscrollen																			*/
/* Funktionsresultat:	-																						*/
/* item:						Zeiger auf den ersten Eintrag der Scroll-Liste							*/
/*----------------------------------------------------------------------------------------*/ 
static void scroll_right( LIST_BOX *box )
{
	OBJECT	*tree;
	WORD		*obj_index;
	
	tree = box->tree;														/* Zeiger auf den Objektbaum */
	obj_index = box->obj_index;
	
	if ( box->flags & LBOX_VERT )										/* vertikale Listbox? */
	{
		if ( box->first_b < box->entries_b - box->visible_b )	/* noch nicht rechts? */
		{
			GRECT		rect;
			WORD		dx;
			WORD		x;
			WORD		w;

			get_GRECT( tree, box->parent_box, &rect );
			dx = tree[*obj_index].ob_width / box->visible_b;		
			x = rect.g_x + dx;
			w = rect.g_w - dx;

			bscroll( box, box->first_b + 1, x, rect.g_y, rect.g_x, rect.g_y, w, rect.g_h );
		}
	}
	else																		/* horizontale Listbox */
	{
		if( box->first_a + box->visible_a < lbox_cnt_items( box ))	/* noch nicht rechts? */
		{
			WORD	x1;
			WORD	y1;
			WORD	x2;
			WORD	y2;
			WORD	x3;
			WORD	y3;
			
			WORD	first_obj;
			WORD	second_obj;
			WORD	last_obj;
			
			first_obj = obj_index[0];									/* erstes Objekt in der Liste */
			second_obj = obj_index[1];									/* zweites Objekt in der Liste */
			last_obj = obj_index[box->visible_a - 1];				/* letztes Objekt in der Liste */
	
			objc_offset( tree, second_obj, &x1, &y1 );
			objc_offset( tree, last_obj, &x2, &y2 );
			objc_offset( tree, first_obj, &x3, &y3 );
	
			ascroll( box, box->first_a + 1, last_obj, x1, y1, x3, y1, x2 - x3, tree[second_obj].ob_height );	/* Ausschnitt verschieben */
		}
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* Bereich scrollen																								*/
/* Funktionsresultat:	-																						*/
/*	box:						Zeiger auf die LIST_BOX-Struktur												*/
/*	first:					Index des ersten sichtbaren Elements										*/
/*	obj:						Nummer des neu zu zeichnenden Objekts										*/
/*	x1:						x-Quellkoordinate																	*/
/*	y1:						y-Quellkoordinate																	*/
/*	x2:						x-Zielkoordinate																	*/
/*	y2:						y-Zielkoordinate																	*/
/*	w:							Breite des Bereichs in Pixeln													*/
/*	h:							Hîhe des Bereichs in Pixeln													*/
/*----------------------------------------------------------------------------------------*/ 
static void	ascroll( LIST_BOX *box, WORD first, WORD obj, WORD x1, WORD y1, WORD x2, WORD y2, WORD w, WORD h )
{
	OBJECT	*tree;
	GRECT		rect;

	tree = box->tree;														/* Zeiger auf den Objektbaum */

	lbox_set_asldr( box, first, (GRECT *) &tree->ob_x );		/* Slider positionieren und zeichnen */
	
	get_GRECT( tree, box->parent_box, &rect );
	
	if ( is_visible( box, &rect ))
	{
		lbox_update( box, 0L );											/* Objektnamen neu besetzen */
		move_area( tree, box->parent_box, x1, y1, x2, y2, w, h );	/* Bereich verschieben */
		get_GRECT( tree, obj, &rect );								/* GRECT des Eintrags */
		obj_redraw( box, &rect, box->parent_box, MAX_DEPTH );	/* untersten Eintrag neu zeichnen */
	}
	else
		lbox_update( box, &rect );										/* Objektnamen neu besetzen */
}

/*----------------------------------------------------------------------------------------*/ 
/* Bereich scrollen																								*/
/* Funktionsresultat:	-																						*/
/*	box:						Zeiger auf die LIST_BOX-Struktur												*/
/*	first:					Index des ersten sichtbaren Elements										*/
/*	obj:						Nummer des neu zu zeichnenden Objekts										*/
/*	x1:						x-Quellkoordinate																	*/
/*	y1:						y-Quellkoordinate																	*/
/*	x2:						x-Zielkoordinate																	*/
/*	y2:						y-Zielkoordinate																	*/
/*	w:							Breite des Bereichs in Pixeln													*/
/*	h:							Hîhe des Bereichs in Pixeln													*/
/*----------------------------------------------------------------------------------------*/ 
static void	bscroll( LIST_BOX *box, WORD first, WORD x1, WORD y1, WORD x2, WORD y2, WORD w, WORD h )
{
	OBJECT	*tree;
	GRECT		rect;

	tree = box->tree;														/* Zeiger auf den Objektbaum */

	lbox_set_bsldr( box, first, (GRECT *) &tree->ob_x );		/* Slider positionieren und zeichnen */
	
	get_GRECT( tree, box->parent_box, &rect );
	
	if ( is_visible( box, &rect ))
	{
		lbox_update( box, 0L );											/* Objektnamen neu besetzen */
		move_area( tree, box->parent_box, x1, y1, x2, y2, w, h );	/* Bereich verschieben */

		if ( x1 == x2 )
		{
			rect.g_x = x1;
			rect.g_w = w;
			
			if ( y1 < y2 )													/* nach oben scrollen? */
			{
				rect.g_y = y1;
				rect.g_h = y2 - y1;
			}
			else																/* nach unten scrollen */
			{
				rect.g_y = y2 + h;
				rect.g_h = y1 - y2;
			}
		}
		else																	/* horizontales Scrolling */
		{
			rect.g_y = y1;
			rect.g_h = h;
			
			if ( x1 < x2 )													/* nach links scrollen? */
			{
				rect.g_x = x1;
				rect.g_w = x2 - x1;
			}
			else																/* nach rechts scrollen */
			{
				rect.g_x = x2 + w;
				rect.g_w = x1 - x2;
			}
		}

		obj_redraw( box, &rect, box->parent_box, MAX_DEPTH );	/* Spalte neu zeichnen */
	}
	else
		lbox_update( box, &rect );										/* Objektnamen neu besetzen */
}

/*----------------------------------------------------------------------------------------*/ 
/* Bereich verschieben																							*/
/* Funktionsresultat:	-																						*/
/*	tree:						Zeiger auf den Objektbaum														*/
/*	obj:						Nummer des begrenzenden Objekts												*/
/*	x1:						x-Quellkoordinate																	*/
/*	y1:						y-Quellkoordinate																	*/
/*	x2:						x-Zielkoordinate																	*/
/*	y2:						y-Zielkoordinate																	*/
/*	w:							Breite des Bereichs in Pixeln													*/
/*	h:							Hîhe des Bereichs in Pixeln													*/
/*----------------------------------------------------------------------------------------*/ 
static void	move_area( OBJECT *tree, WORD obj, WORD x1, WORD y1, WORD x2, WORD y2, WORD w, WORD h )
{
#if	CALL_MAGIC_KERNEL == 0
	extern WORD vdi_handle;
	MFDB	src;
	MFDB	des;
	WORD	xy[8];

	graf_mouse( M_OFF, 0 );												/* Maus ausschalten */
	set_dial_clip( vdi_handle, tree, obj );						/* Clipping setzen */
	wind_update( BEG_UPDATE );

	src.fd_addr = 0L;
	des.fd_addr = 0L;

	w--;
	h--;
	xy[0] = x1;
	xy[1] = y1;
	xy[2] = x1 + w;
	xy[3] = y1 + h;
	xy[4] = x2;
	xy[5] = y2;
	xy[6] = x2 + w;
	xy[7] = y2 + h;

	vro_cpyfm( vdi_handle, 3, xy, &src, &des );					/* Bereich verschieben */

	wind_update( END_UPDATE );
	graf_mouse( M_ON, 0 );												/* Maus einschalten */
#else
	graf_mouse( M_OFF, 0 );												/* Maus ausschalten */
	set_dial_clip( 0, tree, obj );									/* Clipping setzen */
	wind_update( BEG_UPDATE );

	blitcopy_rectangle(x1, y1, x2, y2, w, h);
	wind_update( END_UPDATE );
	graf_mouse( M_ON, 0 );												/* Maus einschalten */
#endif
}

/*----------------------------------------------------------------------------------------*/ 
/* AngewÑhlte EintrÑge in der Listbox deselektieren													*/
/* Funktionsresultat:	-																						*/
/*	box:						Zeiger auf die LIST_BOX-Struktur												*/
/*----------------------------------------------------------------------------------------*/ 
static void	deselect_list( LIST_BOX *box )
{
	LBOX_ITEM	*item;
	WORD	index;
	
	item = box->items;													/* Zeiger auf das erste Element */
	index = 0;
	
	while( item )
	{
		if ( item->selected )											/* selektiert? */
		{
			if (( index >= box->first_a ) && ( index < ( box->first_a + box->visible_a )))	/* sichtbar? */
			{
				change_item_state( box, item, box->obj_index[index - box->first_a], 0 );
				slct_item( box, item, box->obj_index[index - box->first_a], 1 );	/* neuen Status mitteilen */
			}
			else
			{
				item->selected = 0;
				slct_item( box, item, 0, 1 );							/* neuen Status mitteilen */
			}
		}
		index++;
		item = item->next;
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* Status eines LBOX_ITEMS Ñndern und es zeichnen													*/
/* Funktionsresultat:	-																						*/
/*	box:						Zeiger auf die LIST_BOX-Struktur											*/
/* item:						Zeiger auf den ersten Eintrag der Scroll-Liste							*/
/* index:					Objektnummer																		*/
/*	new_state:				Objektstatus																		*/
/*----------------------------------------------------------------------------------------*/ 
static void change_item_state( LIST_BOX *box, LBOX_ITEM *item, WORD index, WORD new_state )
{
	if ( item )
	{
		GRECT		rect;
		
		get_GRECT( box->tree, index, &rect );						/* GRECT des Objekts */
		
		item->selected = new_state;									/* Status */
		index = set_item( box, item, index, &rect );				/* Element eintragen */
		obj_redraw( box, &rect, box->parent_box, MAX_DEPTH );	/* zeichnen vom Grundobjekt aus */
	}
}

static void	get_GRECT( OBJECT *tree, WORD obj, GRECT *r )
{
	objc_offset( tree, obj, &r->g_x, &r->g_y );
	r->g_w = tree[obj].ob_width;
	r->g_h = tree[obj].ob_height;
}

/*----------------------------------------------------------------------------------------*/ 
/* Untersuchen, ob ein Rechteck vollstÑndig sichtbar ist												*/
/* Funktionsresultat:	0: (teilweise) verdeckt 1: vollstÑndig sichtbar							*/
/*	box:						Zeiger auf die LIST_BOX-Struktur											*/
/*	r:							Zeiger auf das GRECT																*/
/*----------------------------------------------------------------------------------------*/ 
static WORD	is_visible( LIST_BOX *box, GRECT *r )
{
	GRECT	w0;
	
	wind_update( BEG_UPDATE );											/* Rechteckliste sperren */

	wind_get( 0, WF_WORKXYWH, &w0.g_x, &w0.g_y, &w0.g_w, &w0.g_h );	/* Grîûe des Desktops */

	if ( box->dialog )													/* Fensterdialog? */
	{
		WORD	handle;
		GRECT	w;
		
		handle = wdlg_get_handle( box->dialog );
		
		wind_get( handle, WF_FIRSTXYWH, &w.g_x, &w.g_y, &w.g_w, &w.g_h );	/* erstes Redraw-Rechteck */
	
		do
		{
			if ( rc_intersect( &w0, &w ))								/* Fenster mit Desktop schneiden */
			{
				if ( is_b_in_a( &w, r ))								/* Rechteck vollstÑndig sichtbar? */
				{
					wind_update( END_UPDATE );							/* Rechteckliste freigeben */
					return( 1 );
				}
			}
			wind_get( handle, WF_NEXTXYWH, &w.g_x, &w.g_y , &w.g_w, &w.g_h );	/* nÑchstes Redraw-Rechteck */

		} while ( w.g_w > 0 );											/* alle Rechtecke abgearbeitet? */

	}
	else																		/* modaler Dialog */
	{
		wind_update( END_UPDATE );										/* Rechteckliste freigeben */
		return( is_b_in_a( &w0, r ));
	}
	
	wind_update( END_UPDATE );											/* Rechteckliste freigeben */
	return( 0 );															/* nicht vollstÑndig sichtbar */
}

static WORD	is_b_in_a( GRECT *a, GRECT *b )
{
	if (( b->g_x >= a->g_x ) &&
		 ( b->g_y >= a->g_y ) &&
		(( b->g_x + b->g_w ) <= ( a->g_x + a->g_w )) &&
		(( b->g_y + b->g_h ) <= ( a->g_y + a->g_h )))
	{
		return( 1 );														/* b ist Untermenge von a */
	}
	else
		return( 0 );
}

static void	set_dial_clip( WORD handle, OBJECT *dial, WORD obj )
{
	GRECT	r;

	get_GRECT( dial, obj, &r );

#if	CALL_MAGIC_KERNEL == 0 
 	r.g_w += r.g_x - 1;
 	r.g_h += r.g_y - 1;

 	vs_clip( handle, 1, (WORD *) &r );
#else
	set_clip_grect( &r );
#endif
}

/*----------------------------------------------------------------------------------------*/ 
/* Objektstatus Ñndern und Objekt zeichnen																*/
/* Funktionsresultat:	-																						*/
/*	tree:						Zeiger auf den Objektbaum														*/
/*	rect:						begrenzendes Rechteck															*/
/*	obj:						Objektnummer																		*/
/*	state:					neuer Objektstatus																*/
/*----------------------------------------------------------------------------------------*/ 
static void	obj_change( OBJECT *tree, GRECT *rect, WORD obj, WORD state )
{
	wind_update( BEG_UPDATE );
#if	CALL_MAGIC_KERNEL == 0 
	objc_change( tree, obj, 0, rect->g_x, rect->g_y, rect->g_w, rect->g_h, state, 1 );
#else
	set_clip_grect(rect);
	_objc_change( tree, obj, state, 1 );
#endif
	wind_update( END_UPDATE );
}

/*----------------------------------------------------------------------------------------*/ 
/* Objekt zeichnen																								*/
/* Funktionsresultat:	-																						*/
/*	box:						Zeiger auf die LIST_BOX-Struktur											*/
/*	rect:						begrenzendes Rechteck															*/
/*	obj:						Objektnummer																		*/
/*	depth:					Anzahl der Objektebenen															*/
/*----------------------------------------------------------------------------------------*/ 
static void	obj_redraw( LIST_BOX *box, GRECT *rect, WORD obj, WORD depth )
{
	wind_update( BEG_UPDATE );
	
	if ( box->dialog )													/* Fensterdialog? */
		wdlg_redraw( box->dialog, rect, obj, depth );
	else
	{
#if	CALL_MAGIC_KERNEL == 0 
		objc_draw( box->tree, obj, depth, rect->g_x, rect->g_y, rect->g_w, rect->g_h );
#else
		set_clip_grect(rect);
		_objc_draw( box->tree, obj, depth );
#endif
	}
	wind_update( END_UPDATE );
}

#if 0
WORD	mkstate( WORD *mx, WORD *my, WORD *mbutton, WORD *kstate )
{
	WORD	buf[16];
	WORD	dummy;

	wind_update( BEG_MCTRL );									/* Mauskontrolle holen */
				
	evnt_multi( MU_TIMER,
					2,									/* Doppelklicks erkennen */
					1,									/* nur linke Maustaste */
					0,									/* linke Maustaste losgelassen */
					0, 0, 0, 0, 0,					/* Objekt-Rechteck */
					0, 0, 0, 0, 0,					/* kein 2. Rechteck			*/
					buf,								/* Dummy-Buffer */
					0,0,								/* ms */
					mx, my,
					mbutton, kstate,
					&dummy, &dummy );

	wind_update( END_MCTRL );									/* Mauskontrolle holen */

	return( 1 );
}
#endif

#if	CALL_MAGIC_KERNEL

WORD	graf_mkstate( WORD *mx, WORD *my, WORD *mbutton, WORD *kstate )
{
	WORD	data[4];

	_graf_mkstate( data );

	*mx = data[0];
	*my = data[1];
	*mbutton = data[2];
	*kstate = data[3];

	return( 1 );
}

#endif
	