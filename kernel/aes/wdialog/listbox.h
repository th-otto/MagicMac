#ifndef __LISTBOX_H__
#define __LISTBOX_H__ 1

typedef	void	(cdecl *SLCT_ITEM)( struct _list_box *box, OBJECT *tree, struct _lbox_item *item, void *user_data, WORD obj_index, WORD last_state );
typedef	WORD	(cdecl *SET_ITEM)( struct _list_box *box, OBJECT *tree, struct _lbox_item *item, WORD obj_index, void *user_data, GRECT *rect, WORD first );

typedef struct	_lbox_item
{
	struct _lbox_item *next;	/* Zeiger auf den naechsten Eintrag in der Scroll-Liste */
	WORD	selected;				/* gibt an, ob das Objekt selektiert ist */

	WORD	data2;	
	void	*data;					/* Zeiger auf die zu diesem Eintrag gehoerige Datenstruktur */
	BYTE	*name;					/* Zeiger auf den String fuer diesen Eintrag */

} LBOX_ITEM;

/*----------------------------------------------------------------------------------------*/ 
/* Bei aenderungen an der LIST_BOX-Struktur muss auch die Assembler-Definition angepasst 	*/
/*	werden!																											*/
/*----------------------------------------------------------------------------------------*/ 

typedef struct _list_box
{
	WORD			flags;
	
	DIALOG		*dialog;			/* Zeiger auf die Fensterdialog-Struktur */
	OBJECT		*tree;
	
	LBOX_ITEM	*items;			/* Zeiger auf die Liste der Elemente */
	WORD			visible_a;
	WORD			*obj_index;		/* Liste der Objekt-Indizes fuer die Eintraege */

	WORD			parent_box;		/* Objektnummer des Hintergrundrechtecks der Box */
	WORD			button1;			/* Objektnummer des Scroll-Up-Buttons */
	WORD			button2;			/* Objektnummer des Scroll-Down-Buttons */
	WORD			back1;			/* Objektnummer des Slider-Hintergrunds */
	WORD			slider1;			/* Objektnummer des Sliders */

	WORD			first_a;			/* Index des obersten sichtbaren Elements */
	
	SLCT_ITEM	slct;				/* Zeiger auf Auswahlfunktion */
	SET_ITEM		set_item;		/* Zeiger auf Setzfunktion */
	
	WORD			pause_a;
	
	void			*user_data;

	WORD			button_hl;
	WORD			button_hr;
	WORD			back_h;
	WORD			slider_h;

	WORD			first_b;			/* augenblicke Verschiebung */
	WORD			visible_b;
	WORD			entries_b;
	WORD			pause_b;
	
} LIST_BOX;

#define	LBOX_VERT	1			/* Listbox mit vertikalem Slider */
#define	LBOX_AUTO	2			/* Auto-Scrolling */
#define	LBOX_AUTOSLCT	4		/* automatische Darstellung beim Auto-Scrolling */
#define	LBOX_REAL	8			/* Real-Time-Slider */
#define	LBOX_SNGL	16			/* nur ein anwaehlbarer Eintrag */
#define	LBOX_SHFT	32			/* Mehrfachselektionen mit Shift */
#define	LBOX_TOGGLE	64			/* Status eines Eintrags bei Selektion wechseln */
#define	LBOX_2SLDRS	128		/* Listbox hat einen hor. und einen vertikalen Slider */

LIST_BOX	*lbox_create( OBJECT *tree, SLCT_ITEM slct, SET_ITEM set, LBOX_ITEM *items, WORD visible_a, WORD first_a,
								WORD *ctrl_objs, WORD *objs, WORD flags, WORD pause_a, void *user_data, void *dialog,
								WORD visible_b, WORD first_b, WORD entries_b, WORD pause_b );
WORD	lbox_delete( LIST_BOX *box );

WORD	lbox_do( LIST_BOX *box, WORD obj );

void	lbox_update( LIST_BOX *box, GRECT *rect );

WORD	lbox_cnt_items( LIST_BOX *box );
OBJECT	*lbox_get_tree( LIST_BOX *box );
WORD	lbox_get_avis( LIST_BOX *box );
void	*lbox_get_udata( LIST_BOX *box );
WORD	lbox_get_afirst( LIST_BOX *box );
WORD	lbox_get_slct_idx( LIST_BOX *box );
LBOX_ITEM	*lbox_get_items( LIST_BOX *box );
LBOX_ITEM *lbox_get_slct_item( LIST_BOX *box );
LBOX_ITEM	*lbox_get_item( LIST_BOX *box, WORD n );
WORD	lbox_get_idx( LBOX_ITEM *items, LBOX_ITEM *search );
WORD	lbox_get_bvis( LIST_BOX *box );
WORD	lbox_get_bentries( LIST_BOX *box );
WORD	lbox_get_bfirst( LIST_BOX *box );

void	lbox_set_items( LIST_BOX *box, LBOX_ITEM *items );
void	lbox_set_asldr( LIST_BOX *box, WORD first, GRECT *rect );
void	lbox_free_items( LIST_BOX *box );
void	lbox_free_list( LBOX_ITEM *item );
void	lbox_ascroll_to( LIST_BOX *box, WORD first, GRECT *box_rect, GRECT *slider_rect );
void	lbox_set_bsldr( LIST_BOX *box, WORD first, GRECT *rect );
void	lbox_set_bentries( LIST_BOX *box, WORD entries );
void	lbox_bscroll_to( LIST_BOX *box, WORD first, GRECT *box_rect, GRECT *slider_rect );


#endif
