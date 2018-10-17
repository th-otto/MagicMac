						OFFSET	0											;typedef struct _list_box
																				;{
LBOX_flags:			DS.W	1												;	WORD			flags;
																				;	
LBOX_dialog:		DS.L	1												;	void			*dialog;
LBOX_tree:			DS.L	1												;	OBJECT		*tree;
																				;	
LBOX_items:			DS.L	1												;	LBOX_ITEM	*items;			/* Zeiger auf die Liste der Elemente */
LBOX_visible_a:	DS.W	1												;	WORD			visible_a;
LBOX_obj_index:	DS.L	1												;	WORD			*obj_index;		/* Liste der Objekt-Indizes fÅr die EintrÑge */
																				;
LBOX_parent_box:	DS.W	1												;	WORD			parent_box;		/* Objektnummer des Hintergrundrechtecks der Box */
LBOX_button1:		DS.W	1												;	WORD			button1;			/* Objektnummer des Scroll-Up/Left-Buttons */
LBOX_button2:		DS.W	1												;	WORD			button2;			/* Objektnummer des Scroll-Down/Right-Buttons */
LBOX_back:			DS.W	1												;	WORD			back;				/* Objektnummer des Slider-Hintergrunds */
LBOX_slider:		DS.W	1												;	WORD			slider;			/* Objektnummer des Sliders */
																				;
LBOX_first_a:		DS.W	1												;	WORD			first_a;			/* Index des obersten sichtbaren Elements */
																				;	
LBOX_slct:			DS.L	1												;	SLCT_ITEM	slct;				/* Zeiger auf Auswahlfunktion */
LBOX_set_item:		DS.L	1												;	SET_ITEM		set_item;		/* Zeiger auf Setzfunktion */
																				;	
LBOX_pause_a:		DS.W	1												;	WORD			pause_a;
																				;	
LBOX_user_data:	DS.L	1												;	void			*user_data;

LBOX_button_hl:	DS.W	1												;	WORD			button_hl;
LBOX_button_hr:	DS.W	1												;	WORD			button_hr;
LBOX_back_h:		DS.W	1												;	WORD			back_h;
LBOX_slider_h:		DS.W	1												;	WORD			slider_h;

LBOX_first_b:		DS.W	1												;	WORD			first_b;
LBOX_visible_b:	DS.W	1												;	WORD			visible_b;
LBOX_entries_b:	DS.W	1												;	WORD			entries_b;
LBOX_pause_b:		DS.W	1												;	WORD			pause_b;

sizeof_LBOX:																;} LIST_BOX;



LBOX_CREATE			EQU	170
LBOX_UPDATE			EQU	171
LBOX_DO				EQU	172
LBOX_DELETE			EQU	173
LBOX_GET				EQU	174
LBOX_SET				EQU	175

LBOX_CNT_ITEMS		EQU	0
LBOX_GET_TREE		EQU	1
LBOX_GET_AVIS		EQU	2
LBOX_GET_UDATA		EQU	3
LBOX_GET_AFIRST	EQU	4
LBOX_GET_SLCT_IDX	EQU	5
LBOX_GET_ITEMS		EQU	6
LBOX_GET_ITEM		EQU	7
LBOX_GET_SLCT_ITEM	EQU	8
LBOX_GET_IDX		EQU	9
LBOX_GET_BVIS		EQU	10
LBOX_GET_BENTRS	EQU	11
LBOX_GET_BFIRST	EQU	12

LBOX_SET_ASLDR		EQU	0
LBOX_SET_ITEMS		EQU	1
LBOX_FREE_ITEMS	EQU	2
LBOX_FREE_LIST		EQU	3
LBOX_ASCROLL_TO	EQU	4
LBOX_SET_BSLIDER	EQU	5
LBOX_SET_BENTRS	EQU	6
LBOX_BSCROLL_TO	EQU	7

