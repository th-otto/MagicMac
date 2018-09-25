/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*
*/


/*----------------------------------------------------------------------------------------*/
/* Globale Includes																								*/
/*----------------------------------------------------------------------------------------*/
#include <MGX_DOS.H>
#include <VDI.H>
#include	<MT_AES.H>
#include	<STDIO.H>
#include	<STDDEF.H>
#include <STRING.H>
#include	<STDLIB.H>
#include	<SCANCODE.H>
#include	<DRAGDROP.H>

#include "WSTRUCT.H"
#include "WLIB.H"

#include "AESMACRO.H"

typedef struct {
	void *next;
	WORD apid;
} APPL;

#include "vtsys.h"

#define	NAPPS 128

typedef struct
{
	WORD	x1,
			y1,
			x2,
			y2;
}VRECT;

typedef struct
{
	WORD	x1,	/* Index des ersten markierten Spalte	*/
			y1,	/* Index der ersten markierten Zeile 	*/
			x2,	/* Index der ersten nicht markierten Spalte */
			y2;	/* Index der letzten markierten Zeile */
}BLOCK;

/*----------------------------------------------------------------------------------------*/
/* Lokale Includes																								*/
/*----------------------------------------------------------------------------------------*/
#include "VT52.H"
#include "VTSTRUCT.H"
#include "VT_EMU.H"

/*----------------------------------------------------------------------------------------*/
/* Defines                                                                                */
/*----------------------------------------------------------------------------------------*/
enum{ OBJ, TXT_SCRN, MF };

#define	WBORDER window->border
#define	WWORK window->workarea
#define	WTSCREEN ((TSCREEN *) window->interior )

#define	ON 1
#define	OFF 0
#define	WELEMENTS  (NAME + CLOSER + MOVER + FULLER + SIZER + UPARROW + DNARROW + VSLIDE + LFARROW + RTARROW + HSLIDE + ICONIFIER)
#define	SHW_PARALLEL	100
#define	SM_M_SPECIAL	101
#define	RUN_TOS			0x1411
#define	CR 13
#define	LF 10
#define  SPACE 32

#define	VA_START		0x4711
#define	AV_STARTED	0x4738

/* Screnmgr Function codes */
#define	SMC_TIDY_UP		0
#define	SMC_TERMINATE	1
#define	SMC_SWITCH		2
#define	SMC_FREEZE		3
#define	SMC_UNFREEZE	4

#define	SCRENMGR			1

/*
#define	p_vt52_winlst	(*(WINDOW ***) 0x98c)
#define	p_vt_interior_off (*(WORD *) 0x990)
#define	p_vt_columns_off (*(WORD *) 0x992)
#define	p_vt_rows_off (*(WORD *) 0x994)
#define	p_vt_visible_off (*(WORD *) 0x996)
#define	p_vt_x_off (*(WORD *) 0x998)
#define	p_vt_y_off (*(WORD *) 0x99a)
#define	p_vt_Cconout ( *( LONG (**)( WINDOW *window, BYTE *str, LONG cnt )) 0x99c)
#define	p_vt_Cconin ( *( LONG (**)( WINDOW *window )) 0x9a0)
*/

extern	void	bios_disp( void );
extern	void	xbios_disp( void );
extern	void	new_etv_term( void );
extern	void	xconstat( void );
extern	void	xconin( void );
extern	void	xconout_con( void );
extern	void	xconout_raw( void );
extern	void	xcostat_con( void );
extern	void	xcostat_raw( void );

extern	void	*old_bios_vec;
extern	void	*old_xbios_vec;
extern	void	*old_etv_term;
extern	void	*old_xconstat;
extern	void	*old_xconin;
extern	void	*old_xconout_con;
extern	void	*old_xconout_raw;
extern	void	*old_xcostat_con;
extern	void	*old_xcostat_raw;

/* extern	ULONG	search_cookie( ULONG id, ULONG *data ); */

/*----------------------------------------------------------------------------------------*/
/* Typedefs                                                                               */
/*----------------------------------------------------------------------------------------*/

typedef struct
{
	LONG	magic;                   /* muû $87654321 sein         */
	void	*membot;                 /* Ende der AES- Variablen    */
	void	*aes_start;              /* Startadresse               */
	/* KAOS */
	LONG	magic2;                  /* ist 'MAGX' oder 'KAOS'     */
	LONG	date;                    /* Erstelldatum               */
	void	(*chgres)(int res, int txt);  /* Auflîsung Ñndern      */
	LONG	(**shel_vector)(void);   /* ROM- Desktop               */
	BYTE	 *aes_bootdrv;            /* Hierhin kommt DESKTOP.INF  */
	WORD	*vdi_device;             /* vom AES benutzter Treiber  */
	void	**nvdi_workstation;      /* vom AES benutzte Workst.   */
	WORD	*shelw_doex;
	WORD	*shelw_isgr;
	/* MAG!X */
	WORD	version;
	WORD	release;
	LONG	_basepage;
	WORD	*moff_cnt;
	LONG	shel_buf_len;
	LONG	shel_buf;
	LONG	notready_list;
	LONG	menu_app;
	LONG	menutree;
	LONG	desktree;
	LONG	desktree_1stob;
	LONG	dos_magic;
	LONG	maxwindn;
	WORD	(**p_fsel)(char *path, char *name, int *button, char *title);
	LONG	(*ctrl_timeslice) (long settings);
	LONG	dummy;
} XT_AESVARS;


/*----------------------------------------------------------------------------------------*/
/* Globale Variablen                                                                      */
/*----------------------------------------------------------------------------------------*/
WORD  	app_id,
			aes_handle,
			pwchar, phchar,
			pwbox, phbox;
WORD		*aes_global;

RSHDR		*rsh;
BYTE		**fstring_addr;
OBJECT	**tree_addr;
WORD		tree_count;

WORD		buf[128];

WORD		mousex, mousey,
			mbutton,
			mkstate,
			keycode,
			mclicks;

WORD		quit;

GRECT		std_win;

WORD     work_out[57],
         vdi_handle;

WINDOW	*app_window[NAPPS];		/* wird auf NULL initialisiert */
VTCLIENT_INFO	vtclients[NAPPS];	/* wird auf NULL initialisiert */

APPL		**pact_appl;				/* Zeiger auf den Zeiger auf die aktive Task */

UWORD		stack_offset;
UBYTE		*key_state;

WORD		utime;
WORD		update_flag;
WORD		close_term;
WORD		copy_opt,
			paste_opt,
			term_opt;
WORD		input_opt;
						
WORD		columns,
			rows,
			buffer_rows;

WORD		font_id,
			cpoint;

int8		home[128];
BYTE		path[128];
BYTE		inf_name[128];
BYTE		scrp_path[128];
BYTE		cmd[128];

OBJECT 	*iconified_tree1;
OBJECT 	*iconified_tree2;

/*----------------------------------------------------------------------------------------*/
/* Funktionsdeklarationen                                                                 */
/*----------------------------------------------------------------------------------------*/
WORD open_screen_wk( WORD aes_handle, WORD *work_out );
WORD	do_dialog( OBJECT *dial );
void	menu_about( void );
void	menu_open( void );
void	menu_close( void );
void	menu_quit( void );
void	menu_paste( void );
WORD	insert_data( WORD handle, WINDOW *window, LONG cnt );
void	menu_changew( void );
void	menu_clipboard( void );
void	menu_terminal( void );
void	menu_font( void );
void	menu_tosende( void );
void	menu_save( void );
void	hdle_keybd( WORD keycode, WORD key_state );
void	hdle_mesag( WORD *mbuf );
void	menu_selected( WORD title, WORD entry );
void	event_loop( void );
void	init_rsrc( void );
void	receive_dragdrop( WORD *mbuf );
void	child_terminated( WORD *mbuf );
LONG	get_act_appl( void );
LONG	get_stack_frame( void );
LONG	get_kbshift( void );
void	close_tos_window( WORD handle );
void	std_settings( void );
void	**search_vec( void **addr, void * vt_vec );
void	*change_vec( void **addr, void *new );
void	set_vec( void );
LONG	reset_vec( void );
WORD	exec_tos( BYTE *fname, BYTE *fpath, BYTE *fcmd );
WINDOW	*open_tos_window( BYTE *fname, TSCREEN *tscreen );
void	run_tos( WORD *mbuf );
WORD	close_all( void );
void	hdle_button( WORD x, WORD y, WORD button, WORD key_state, WORD clicks );
void	select_block( WINDOW *window, BLOCK *old, BLOCK *new, WORD select );
void	draw_selected( WINDOW *window, BLOCK *area );
void	intersect_blocks( BLOCK *old, BLOCK *new, BLOCK *draw );
void	sort_block( BLOCK *rect );
void	save_block( TSCREEN *tscreen, BLOCK *area );
void	save_line( WORD handle, ULONG *src, UBYTE *des, WORD src_len, WORD opt );
void	load_inf( void );
void	save_inf( void );
void	save_value( WORD handle, BYTE *exp, WORD value );
LONG	get_len( BYTE *line, LONG max_len, LONG *parse_len );
WORD	set_value( BYTE *line, BYTE *exp, WORD *x, WORD min, WORD max );
void	get_std_win( BYTE *line );
void	auto_exec( BYTE *line );
BYTE	*get_string( BYTE *pos, BYTE *des );
BYTE	*get_number( BYTE *pos, WORD *value, WORD min, WORD max );
WORD	clip_value( WORD value, WORD min, WORD max );
void	scrap_clear( void );
void	start_tos( BYTE *file );

static LONG inherit( WORD dst_apid, WORD src_apid);
static LONG uninherit( WORD apid);
static LONG vt_app_Sconout( APPL *app, BYTE *str, LONG cnt );
static LONG vt_app_Cconin( APPL *app);
static LONG vt_getVDIESC( APPL *app);

/*----------------------------------------------------------------------------------------*/
/* Virtuelle Bildschirm-Workstation îffnen                                                */
/* Funktionsresultat:  VDI-Handle oder 0 als Fehlernummer                                 */
/* work_out:           GerÑteinformationen                                                */
/*----------------------------------------------------------------------------------------*/
WORD open_screen_wk( WORD aes_handle, WORD *work_out )
{
   WORD  handle,
         work_in[11],
         i;

   for( i = 1; i < 10 ; work_in[i++] = 1 );  /* work_in initialisieren */
   work_in[0] = Getrez() + 2;                /* Auflîsung */
   work_in[10] = 2;                          /* Rasterkoordinaten benutzen */
   handle = aes_handle;

   v_opnvwk( work_in, &handle, work_out );
   return( handle );
}

/*----------------------------------------------------------------------------------------*/
/* Dialogbox zeichnen																							*/
/* Funktionsergebnis:	Nummer des Exit-Objekts															*/
/* dialog:				  	Zeiger auf den Objektbaum														*/
/*----------------------------------------------------------------------------------------*/
WORD	do_dialog( OBJECT *dialog )
{
	GRECT		size;
	WORD		selected;
	void		*flyinf;
	void		*scantab=0L;
	int		lastcrsr;

	wind_update( BEG_UPDATE );	/* Bildschirm sperren */
	wind_update( BEG_MCTRL );	/* Mauskontrolle holen */
	
	/* Dialog zentrieren */
	form_center_grect( dialog, &size );
	
	/* Bildbereich reservieren */
	form_xdial( FMD_START, &size, &size, &flyinf );

	/* Dialog zeichnen */
	objc_draw( dialog, ROOT, MAX_DEPTH, &size );
	
	/* Dialog abarbeiten */
	selected = form_xdo( dialog, ROOT, &lastcrsr, scantab, flyinf ) & 0x7fff;	/* Nummer des Ausgangsobjekts */
	 
	form_xdial( FMD_FINISH, &size, &size, &flyinf );

	wind_update( END_MCTRL );	/* Maus freigeben */
	wind_update( END_UPDATE );	/* Bildschirm freigeben */
	
	dialog[selected].ob_state &= ( ~SELECTED );	/* Objekt deselektieren */
					
	return( selected );	/* Objektnummer zurÅckgeben */
}

/*----------------------------------------------------------------------------------------*/
/* Dialogbox "öber xxx..."																						*/
/*----------------------------------------------------------------------------------------*/
void	menu_about( void )
{
	strcpy( tree_addr[ABOUT][VNUMMER].ob_spec.tedinfo->te_ptext, "Version 2.00" );
	do_dialog( tree_addr[ABOUT] );
}

/*----------------------------------------------------------------------------------------*/
/* MenÅpunkt "ôffnen"																							*/
/*----------------------------------------------------------------------------------------*/
void	menu_open( void )
{
	BYTE		fpath[150];
	BYTE		fname[14];
	WORD		but;
	WORD		ret;
			
	strcpy( fname, "" );
	strcpy( fpath, path );
	strcat( fpath, "*.TOS,*.TTP" );
	wind_update( BEG_UPDATE );
	ret = fsel_exinput( fpath, fname, &but, fstring_addr[FSHEADL] );
	wind_update( END_UPDATE );

	if ( ret && ( but == 1 ) && *fname )
	{
		BYTE		*pos;

		pos = strrchr( fname, '.' );
		if ( pos && ( strcmp( pos + 1, "TTP" ) == 0 ))	/* TTP?	*/
		{
			strcpy( tree_addr[CMDLINE][CPNAME].ob_spec.free_string, fname );
			*tree_addr[CMDLINE][CLINE1].ob_spec.tedinfo->te_ptext = 0;
			*tree_addr[CMDLINE][CLINE2].ob_spec.tedinfo->te_ptext = 0;
			if ( do_dialog( tree_addr[CMDLINE] ) == COK )
			{
				strcpy( cmd + 1, tree_addr[CMDLINE][CLINE1].ob_spec.tedinfo->te_ptext );
				strcat( cmd + 1, tree_addr[CMDLINE][CLINE2].ob_spec.tedinfo->te_ptext );
				*cmd = (BYTE) strlen( cmd + 1 );	/* LÑnge der Kommandozeile	*/
				exec_tos( fname, fpath, cmd );
			}
		}
		else
			exec_tos( fname, fpath, cmd );
	}
}

/*----------------------------------------------------------------------------------------*/
/* MenÅpunkt "Schlieûen"																						*/
/*----------------------------------------------------------------------------------------*/
void	menu_close( void )
{
	WORD		handle;

	wind_get( 0, WF_TOP, &handle, 0, 0, 0 );
	close_tos_window( handle );
}

/*----------------------------------------------------------------------------------------*/
/* MenÅpunkt "Ende"																								*/
/*----------------------------------------------------------------------------------------*/
void	menu_quit( void )
{
	quit = TRUE;
}

/*----------------------------------------------------------------------------------------*/
/* MenÅpunkt "EinfÅgen"																							*/
/*----------------------------------------------------------------------------------------*/
void	menu_paste( void )
{
	WINDOW	*window;
	BYTE	scrp_name[256];
	WORD	whandle;
	LONG	handle;
	DTA	dta;
	DTA	*old_dta;
	
	wind_get( 0, WF_TOP, &whandle, 0, 0, 0 );
	window = search_struct( whandle );
	if (( window ) && !(window->wflags.iconified))
	{
		strcpy( scrp_name, scrp_path );
		strcat( scrp_name, "SCRAP.TXT" );
	
		old_dta = Fgetdta();
		Fsetdta( &dta );
	
		if ( Fsfirst( scrp_name, 0 ) == 0 )
		{
			handle = Fopen( scrp_name, FO_READ );
			if ( handle > 0 )
			{
				insert_data( (WORD) handle, window, dta.d_length );
				Fclose( (WORD) handle );
			}
		}
		Fsetdta( old_dta );
	}
}

/*----------------------------------------------------------------------------------------*/
/* Daten in den Tastaturpuffer einer Applikation eintragen											*/
/* Funktionsresultat:	Adresse des zu Ñndernden Vektors oder 0L									*/
/*	addr:						Aresse des Vektors, ab der gesucht wird									*/
/*	vt_vec:					gesuchter Vektor-Inhalt															*/
/*----------------------------------------------------------------------------------------*/
WORD	insert_data( WORD handle, WINDOW *window, LONG cnt )
{
	UBYTE		*insert;
	TSCREEN	*tscreen;
	
	insert = malloc( cnt );
	
	if ( insert )
	{
		cnt = Fread( handle, cnt, insert );

		tscreen = (TSCREEN *) window->interior;
		if ( cnt > TBUFSIZE - tscreen->tcnt - 1 )
			cnt = TBUFSIZE - tscreen->tcnt - 1;
		
		if ( cnt > 0 )
		{
			UBYTE		*input;
			ULONG		*output;
			WORD		buf[8];
			
			input = (UBYTE *)insert;
			output = tscreen->tbuf + tscreen->tcnt + 1;
				
			while( cnt > 0 )
			{
				*output++ = (ULONG) *input;
		
				switch ( paste_opt )
				{
					case 0:	if (( *input == CR ) && ( *(input + 1) == LF )) 
								{
									input++;
									cnt--;
								}
								break;
					case 1:	if ( *input == LF ) 
									*(output - 1) = CR;
								break;
					case 2:	if ( *input < SPACE )
									output--;
								break;
				}
				input++;
				cnt--;
			}
		
			tscreen->tcnt = (WORD)( output - tscreen->tbuf ) - 1;
		
			buf[0] = 1000;								/* Nachrichtennummer */
			buf[1] = app_id;							/* Absender der Nachricht */
			buf[2] = 0;									/* öberlÑnge in Bytes */
			buf[3] = window->handle;				/* Fensternummer */
			buf[4] = 0;									/* Taste	*/
			buf[5] = 0;
			appl_write( tscreen->child_id, 16, buf );
		}

		free( insert );
	}
	else
		return( -1 );
		
	return( 0 );
}

/*----------------------------------------------------------------------------------------*/
/* MenÅpunkt "Wechseln"																							*/
/*----------------------------------------------------------------------------------------*/
void	menu_changew( void )
{
	switch_window();	/* nÑchstes Fenster in den Vordergrund bringen	*/
}

/*----------------------------------------------------------------------------------------*/
/* MenÅpunkt "Clipboard"																						*/
/*----------------------------------------------------------------------------------------*/
void	menu_clipboard( void )
{
	OBJECT	*dialog;
		
	dialog = tree_addr[CLPBRD];

	/* Objekte deselektieren	*/
	dialog[CC_END].ob_state &= ~SELECTED;
	dialog[CC_DEL].ob_state &= ~SELECTED;
	dialog[CC_DONT].ob_state &= ~SELECTED;
	dialog[CI_CR].ob_state &= ~SELECTED;
	dialog[CI_LF].ob_state &= ~SELECTED;
	dialog[CI_DEL].ob_state &= ~SELECTED;
	dialog[CI_DONT].ob_state &= ~SELECTED;

	/* Die Objekte CC_END, CCDEL und CC_DONT mÅssen direkt aufeinander folgen	*/
	dialog[copy_opt + CC_END].ob_state |= SELECTED;

	/* Die Objekte CI_CR, CI_LF, CI_DEL und CI_DONT mÅssen direkt aufeinander folgen	*/
	dialog[paste_opt + CI_CR].ob_state |= SELECTED;

	if ( do_dialog( dialog ) == CLP_OK )
	{
		if ( dialog[CC_END].ob_state & SELECTED )
			copy_opt = 0;
		if ( dialog[CC_DEL].ob_state & SELECTED )
			copy_opt = 1;
		if ( dialog[CC_DONT].ob_state & SELECTED )
			copy_opt = 2;

		if ( dialog[CI_CR].ob_state & SELECTED )
			paste_opt = 0;
		if ( dialog[CI_LF].ob_state & SELECTED )
			paste_opt = 1;
		if ( dialog[CI_DEL].ob_state & SELECTED )
			paste_opt = 2;
		if ( dialog[CI_DONT].ob_state & SELECTED )
			paste_opt = 3;
	}
}

/*----------------------------------------------------------------------------------------*/
/* MenÅpunkt "Terminal"																							*/
/*----------------------------------------------------------------------------------------*/
void	menu_terminal( void )
{
	OBJECT	*dialog;
	
	dialog = tree_addr[TERMINAL];
	
	itoa( columns, dialog[TCOLUMNS].ob_spec.tedinfo->te_ptext, 10 );
	itoa( rows, dialog[TROWS].ob_spec.tedinfo->te_ptext, 10 );
	itoa( buffer_rows, dialog[TBUFFER].ob_spec.tedinfo->te_ptext, 10 );
	itoa( utime, dialog[TREDRAW].ob_spec.tedinfo->te_ptext, 10 );
	
	if ( update_flag )
		dialog[TUPDATE].ob_state |= SELECTED;
	else
		dialog[TUPDATE].ob_state &= ~SELECTED;

	if ( input_opt )
		dialog[TINPUT].ob_state |= SELECTED;
	else
		dialog[TINPUT].ob_state &= ~SELECTED;

	if ( do_dialog( dialog ) == TOK )
	{
		if ( dialog[TUPDATE].ob_state & SELECTED )
			update_flag = 0x0100;
		else
			update_flag = 0x0000;

		if ( dialog[TINPUT].ob_state & SELECTED )
			input_opt = 1;
		else
			input_opt = 0;

		columns = clip_value( atoi( dialog[TCOLUMNS].ob_spec.tedinfo->te_ptext ), MIN_COLUMNS, MAX_COLUMNS );
		rows = clip_value( atoi( dialog[TROWS].ob_spec.tedinfo->te_ptext ), MIN_ROWS, MAX_ROWS );
		buffer_rows = clip_value( atoi( dialog[TBUFFER].ob_spec.tedinfo->te_ptext ), MIN_BUFFER, MAX_BUFFER );
		utime = clip_value( atoi( dialog[TREDRAW].ob_spec.tedinfo->te_ptext ), MIN_TIMER, MAX_TIMER );
	}
}

/*----------------------------------------------------------------------------------------*/
/* MenÅpunkt "Zeichensatz"																						*/
/*----------------------------------------------------------------------------------------*/
void	menu_font( void )
{
#define	FONT_FLAGS	( FNTS_BTMP + FNTS_OUTL + FNTS_MONO )
#define	BUTTON_FLAGS ( FNTS_SNAME + FNTS_SSTYLE + FNTS_SSIZE + FNTS_SRATIO )
	
	LONG	id;
	LONG	pt;
	
	WINDOW	*window;
	WORD	whandle;
	WORD	vhandle;
	WORD	button;
	
	wind_get( 0, WF_TOP, &whandle, 0, 0, 0 );
	window = search_struct( whandle );

	if ( window )								/* liegt ein eigenes Fenster oben?	*/
	{
		id = ((TSCREEN *) window->interior )->font_id;
		pt = ((TSCREEN *) window->interior )->point_size;
	}
	else
	{
		id = font_id;
		pt = cpoint;
	}

	vhandle = open_screen_wk( aes_handle, work_out );	/* Workstation îffnen */

	if( vhandle )
	{
		FNT_DIALOG	*fnt_dialog;

		fnt_dialog = fnts_create( vhandle, 0, FONT_FLAGS, FNTS_3D, "Was Shake'beer Your Favourite Poet?", 0L );

		if ( fnt_dialog )
		{
			WORD	check_boxes;
			LONG	ratio;

			pt <<= 16;
			ratio = 1L << 16;											/* VerhÑltnis 1/1 (Bitmapfonts kînnen nicht gestaucht oder gedehnt werden) */

			button = fnts_do( fnt_dialog, BUTTON_FLAGS, font_id, pt, ratio, &check_boxes, &id, &pt, &ratio );
			
			fnts_delete( fnt_dialog, vhandle );					/* Speicher fÅr Fontdialog freigeben */
		}
		v_clsvwk( vhandle );
	}
		
	if ( button == FNTS_OK )
	{
		font_id = (WORD) id;
		cpoint = (WORD)( pt >> 16 );

		if ( window )
		{
			WORD		buf[8];
			WORD		dummy;
			TSCREEN	*tscreen;
					
			tscreen = ((TSCREEN *) window->interior );
			
			WWORK.g_w /= tscreen->char_width;	/* sichtbare Spaltenanzahl	*/
			WWORK.g_h /= tscreen->char_height;	/* sichtbare Zeilenanzahl	*/
			window->x /= tscreen->char_width;	/* erste sichtbare Textspalte	*/
			window->y /= tscreen->char_height;	/* erste sichtbare Textzeile	*/
			window->w /= tscreen->char_width;	/* Spaltenanzahl	*/
			window->h /= tscreen->char_height;	/* Zeilenanzahl	*/

			vhandle = tscreen->handle;

			vst_alignment( vhandle, 0, 5, &dummy, &dummy );	/* linksbÅndig an der Zeichenoberkante ausrichten	*/
			tscreen->font_id = vst_font( vhandle, font_id );	/* Nummer des Zeichensatzes	*/
			tscreen->point_size = vst_point( vhandle, cpoint, &dummy, &dummy,
														&tscreen->char_width, &tscreen->char_height );	/* Hîhe in Punkten	*/
			vqt_width( vhandle, SPACE, &tscreen->char_width, &dummy, &dummy );		/* zusÑtzliche Abfrage fÅr FSM	*/

			WWORK.g_w *= tscreen->char_width;	/* sichtbare Breite	*/
			WWORK.g_h *= tscreen->char_height;	/* sichtbare Hîhe	*/
			window->x *= tscreen->char_width;	/* erste sichtbare x-Koordinate	*/
			window->y *= tscreen->char_height;	/* erste sichtbare y-Koordinate	*/
			window->w *= tscreen->char_width;	/* Breite	*/
			window->h *= tscreen->char_height;	/* Hîhe	*/
			window->dx = tscreen->char_width;	/* Breite einer Scrollspalte */
			window->dy = tscreen->char_height;	/* Hîhe einer Scrollzeile */
			window->snap_dw = tscreen->char_width;
			window->snap_dh = tscreen->char_height;
			window->limit_w = ( tscreen->columns + 1 ) * tscreen->char_width;	/* maximal sichtbare Breite	*/
			window->limit_h = ( tscreen->visible_rows + 1 ) * tscreen->char_height;	/* maximal sichtbare Hîhe	*/

			wind_calc( WC_BORDER, WELEMENTS, &WWORK, &WBORDER );

			size_window( window->handle, &WBORDER );	/* Fenster verschieben und Grîûe verÑndern	*/
			
			buf[0] = WM_REDRAW;						/* Nachrichtennummer */
			buf[1] = app_id;							/* Absender der Nachricht */	
			buf[2] = 0;									/* öberlÑnge in Bytes */
			buf[3] = whandle;							/* Fensternummer */
			*(GRECT *)&buf[4] = window->workarea;				/* Fensterkoordinaten */
			appl_write( app_id, 16, buf );		/* Redraw-Meldung an sich selber schicken */
		}
	}

#undef	BUTTON_FLAGS
#undef	FONT_FLAGS
}

/*----------------------------------------------------------------------------------------*/
/* MenÅpunkt "Diverses"																						*/
/*----------------------------------------------------------------------------------------*/
void	menu_tosende( void )
{
	OBJECT	*dialog;
		
	dialog = tree_addr[TOSENDE];

	/* Objekte deselektieren	*/
	dialog[TERM_FG].ob_state &= ~SELECTED;
	dialog[TERM_BG].ob_state &= ~SELECTED;
	dialog[TERM_QUIT].ob_state &= ~SELECTED;

	if ( close_term )
		dialog[TERM_CLOSE].ob_state |= SELECTED;
	else
		dialog[TERM_CLOSE].ob_state &= ~SELECTED;

	/* Die Objekte TERM_FG, TERM_BG und TERM_QUIT mÅssen direkt aufeinander folgen	*/
	dialog[term_opt + TERM_FG].ob_state |= SELECTED;

	if ( do_dialog( dialog ) == TERM_OK )
	{
		if ( dialog[TERM_CLOSE].ob_state & SELECTED )
			close_term = 1;
		else
			close_term = 0;
		
		if ( dialog[TERM_FG].ob_state & SELECTED )
			term_opt = 0;
		if ( dialog[TERM_BG].ob_state & SELECTED )
			term_opt = 1;
		if ( dialog[TERM_QUIT].ob_state & SELECTED )
			term_opt = 2;
	}
}

/*----------------------------------------------------------------------------------------*/
/* MenÅpunkt "Parameter sichern"																				*/
/*----------------------------------------------------------------------------------------*/
void	menu_save( void )
{
	if ( do_dialog( tree_addr[SAVEINF] ) == SSAVE )
		save_inf();
}

/*----------------------------------------------------------------------------------------*/
/* Drag & Drop - Message bearbeiten																			*/
/*	mbuf:						Zeiger auf den Nachrichtenpuffer												*/
/*								mbuf[3]:	Handle des betroffenen Fensters									*/
/*								mbuf[4]:	x-Koordinate der Maus												*/
/*								mbuf[5]:	y-Koordinate der Maus												*/
/*								mbuf[6]:	Status der Kontrolltasten											*/
/*								mbuf[7]:	Endung des Pipenamens												*/
/*----------------------------------------------------------------------------------------*/
void	receive_dragdrop( WORD *mbuf )
{
	WINDOW	*window;
	
	window = search_struct( mbuf[3] );

	if (( window ) && !(window->wflags.iconified))		/* Fenster vorhanden?	*/
	{
		WORD	handle;
		void	*oldsig;
		BYTE	*pipe = "U:\\PIPE\\DRAGDROP.AA";
		ULONG	data_types[8] = { 'ARGS',
										'.TXT',
										0L,0L,0L,0L,0L,0L };
	
		pipe[17] = *(((BYTE *) mbuf ) + 14 );			/* erstes Byte der Namensendung	*/
		pipe[18] = *(((BYTE *) mbuf ) + 15 );			/* zweites Byte der Namensendung	*/
		
		handle = ddopen( pipe, data_types, &oldsig );	/* Pipe îffnen	*/
		if ( handle >= 0 )
		{
			ULONG	ext;
			LONG	size;
			BYTE	name[DD_NAMEMAX];
			
			while ( ddrtry( handle, name, &ext, &size ))	/* Datentyp lesen */
			{
			
				if ( ext == 'ARGS' || ext == '.TXT' )	/* bekannter Datentyp?	*/
				{
					ddreply( handle, DD_OK );				/* alles in Ordnung	*/
					insert_data( handle, window, size );	/* Daten auslesen	*/
					break;										/* die Schleife verlassen */
				}
				else
					ddreply( handle, DD_EXT );				/* Datentyp wird nicht unterstÅtzt	*/
			}
				
			ddclose( handle, oldsig );						/* Pipe schlieûen	*/
		}
	}
}

/*----------------------------------------------------------------------------------------*/
/* Kind-Applikation wurde beendet																			*/
/*	mbuf:						Zeiger auf den Nachrichtenpuffer												*/
/*								mbuf[3]:	Applikationsnummer													*/
/*								mbuf[4]:	Returncode																*/
/*----------------------------------------------------------------------------------------*/
void	child_terminated( WORD *mbuf )
{
	BYTE	*terminated;
	VTCLIENT_INFO *vti;
	WORD apid = mbuf[3];
	WINDOW	*window;
	TSCREEN *ts;


	if	((UWORD) apid >= NAPPS)
		return;											/* ungÅltige ap_id */

	vti = vtclients + apid;
	window = vti->w;

	terminated = fstring_addr[PRG_TERM];		/* "Programm beendet" */

	if ( window )
	{
		ts = WTSCREEN;

		/* Wenn VT52 nicht "parent" ist, muû die CH_EXIT-Nachricht */
		/* an den tatsÑchlichen "parent" weitergeleitet werden. */
		/* Das ist immer dann der Fall, wenn der Client vom AES */
		/* gestartet wurde und VT52 sein Terminal ist. */

		if ( ts->parent_id != app_id )		/* Ist der VT52 Parent?	*/
			appl_write( ts->parent_id, 16, mbuf );	/* MSG ans Parent	*/

		vti->w = NULL;
		app_window[ apid ] = 0L;
		if	(ts->refcnt)
			ts->refcnt--;

		if	(!ts->refcnt)
			{
			WTSCREEN->child_id = 0;
			if ( close_term || WTSCREEN->term )
			{
				close_vt( WTSCREEN );	
				delete_window( window->handle );
				window = 0L;
			}
			else
			{
				vt_jmp( window, 10 );
				vt_jmp( window, 10 );
				vt_jmp( window, 13 );
				while ( *terminated )
				{
					vt_jmp( window, (UWORD) *terminated );
					terminated++;
				}
			}
		}
	}

	if ( term_opt > 0 )
	{
		WORD	i;
		
		for ( i = 0; i < 128; i++ )
		{
			if ( app_window[i] != 0L )
				return;
		}

		switch ( term_opt )
		{
			case 	1:	{
							WORD	buf[8];
							WORD	handle,
									owner_id;

							if ( window )
						    	wind_set( window->handle, WF_BOTTOM, 0, 0, 0, 0 );

							wind_get( 0, WF_TOP, &handle, 0, 0, 0 );
							wind_get( handle, WF_OWNER, &owner_id, 0, 0, 0 );
				
							if ( owner_id == app_id )				/* VT52-Fenster?	*/
								owner_id = 0;							/* auf den Desktop umschalten	*/
			
							buf[0] = SM_M_SPECIAL;					/* Nachricht an den SCRENMGR */
							buf[1] = app_id;							/* Absender der Nachricht */
							buf[2] = 0;									/* öberlÑnge in Bytes */
							buf[3] = 0;									/* muû 0 sein */
							buf[4] = 'MA';								/* Magic	*/
							buf[5] = 'GX';								/* Magic	*/
							buf[6] = SMC_SWITCH;						/* Programm umschalten	*/
							buf[7] = owner_id;						/* Applikationsnummer	*/
							appl_write( SCRENMGR, 16, buf );
							
							break;
						}
			case 	2:	quit = TRUE; break;
		}
	}
}

/*----------------------------------------------------------------------------------------*/
/* TOS-Programm starten																							*/
/*	file:						Zeiger auf den Pfad mit dem Programmnamen									*/
/*----------------------------------------------------------------------------------------*/
void	start_tos( BYTE *file )
{
	BYTE *pos;
	BYTE	aname[14];
	BYTE	apath[128];
	BYTE	acmd[128];
	
	if ( strlen( file ) > 0 )
	{
		strcpy( apath, file );
		if (( pos = strrchr( apath, '\\' )) != 0L )
			pos++;
		else
			pos = apath;
	
		strcpy( aname, pos );	/* Dateiname	*/
		*pos = 0;					/* Ende des Pfades	*/
	
		pos = strrchr( aname, '.' );
		if ( pos && ( strcmp( pos + 1, "TTP" ) == 0 ))
		{
			strcpy( tree_addr[CMDLINE][CPNAME].ob_spec.free_string, aname );
			*tree_addr[CMDLINE][CLINE1].ob_spec.tedinfo->te_ptext = 0;
			*tree_addr[CMDLINE][CLINE2].ob_spec.tedinfo->te_ptext = 0;
			if ( do_dialog( tree_addr[CMDLINE] ) == COK )
			{
				strcpy( cmd + 1, tree_addr[CMDLINE][CLINE1].ob_spec.tedinfo->te_ptext );
				strcat( cmd + 1, tree_addr[CMDLINE][CLINE2].ob_spec.tedinfo->te_ptext );
				*cmd = (BYTE) strlen( cmd + 1 );
				exec_tos( aname, apath, acmd );
			}
		}
		else
			exec_tos( aname, apath, "" );
	}
	else
	{
		menu_bar( tree_addr[MENU], 0 );
		menu_bar( tree_addr[MENU], 1 );
	}
}

/*----------------------------------------------------------------------------------------*/
/* TOS-Programm starten																							*/
/* Funktionsresultat:	Applikationsnummer oder -1 (Fehler)											*/
/*	fname:					Zeiger auf den Programmnamen													*/
/*	fpath:					Zeiger auf den Pfad																*/
/*	fcmd:						Zeiger auf die Kommandozeile													*/
/*----------------------------------------------------------------------------------------*/
WORD	exec_tos( BYTE *fname, BYTE *fpath, BYTE *fcmd )
{
	WINDOW	*window;
	TSCREEN	*tscreen;
	WORD		child_id;
	BYTE		*pos;


	pos = strrchr( fpath, '\\' );
	if ( pos )
		*( pos + 1 ) = 0;
	else
		strcat( fpath, "\\" );

	strcpy( path, fpath );
	strupr( path );
	strcat( fpath, fname );

	if ( path[0] >= 'A' )
		Dsetdrv( path[0] - 65 );
	Dsetpath( path );

	tscreen = open_vt( columns, rows, buffer_rows, font_id, cpoint );
	window = open_tos_window( fname, tscreen );
	if ( window )
	{
		wind_update( BEG_UPDATE );
		/* im Grafikmodus starten */
		child_id = shel_write( 1, 1, SHW_PARALLEL, fpath, fcmd );

		if (( child_id > 0 ) && ( child_id < 128 ))
		{
			strcpy( WTSCREEN->name, fpath );
			WTSCREEN->refcnt = 1;		/* nur fÅr Haupt-Thread des Prozesses */
			WTSCREEN->child_id = child_id;
			WTSCREEN->parent_id = app_id;	/* VT52 ist Parent	*/

			app_window[ child_id ] = window;

			vtclients[ child_id ].par_apid = app_id;	/* VT52 ist Parent */
			vtclients[ child_id ].w = window;
		}
		else
		{
			close_tos_window( window->handle );
			child_id = -1;
		}
			
		wind_update( END_UPDATE );
	}
	else
		child_id = -1;

	return( child_id );
}

/*----------------------------------------------------------------------------------------*/
/* Fenster fÅr TOS-Programm îffnen und dem AES Bereitschaft signalisieren						*/
/* mbuf:						Zeiger auf den Message-Buffer													*/
/*							   mbuf[0]:		Message																*/
/*							   mbuf[1]:		Applikationsnummer des parent									*/
/*							   mbuf[2]:		öberlÑnge (0)														*/
/*							   mbuf[3]:		Applikationsnummer des child									*/
/*							   mbuf[4/5]:	BYTE *p ( *p muû zum Starten auf 0 gesetzt werden )	*/
/*							   mbuf[6/7]:  BYTE *cmd Zeiger auf den Pfad inklusive Namen			*/
/*----------------------------------------------------------------------------------------*/
void	run_tos( WORD *mbuf )
{
	BYTE		*pos;
	BYTE		fname[14];
	WORD		child_id = mbuf[3];
	WINDOW	*window;
	TSCREEN	*tscreen;


	if	((UWORD) child_id >= NAPPS)
		{
		error:
	   **(BYTE **)&mbuf[4] = -1;			/* ein Fehler ist aufgetreten	*/
		return;			/* ungÅltige apid */
		}

	pos = strrchr( *(BYTE **)&mbuf[6], '\\' );
	if ( pos )
		strcpy( fname, pos + 1 );
	else
		strcpy( fname, *(BYTE **)&mbuf[6] );

	tscreen = open_vt( columns, rows, buffer_rows, font_id, cpoint );		
	window = open_tos_window( fname, tscreen );
	if ( !window )
		{
		close_vt( tscreen);		/* hatten die Behnes vergessen! */
		goto error;
		}

	strcpy( WTSCREEN->name, *(BYTE **)&mbuf[6] );
	WTSCREEN->child_id = child_id;
	WTSCREEN->parent_id = mbuf[1];
	WTSCREEN->refcnt = 1;		/* nur fÅr Haupt-Thread des Prozesses */

	app_window[ child_id ] = window;

	vtclients[ child_id ].par_apid = mbuf[1];	/* AES liefert Parent */
	vtclients[ child_id ].w = window;

	**(BYTE **)&mbuf[4] = 0;		/* Programm kann gestartet werden	*/
}

/*----------------------------------------------------------------------------------------*/
/* Fenster fÅr ein TOS-Programm îffnen																		*/
/* Funktionsresultat:	Zeiger auf die Fensterstruktur oder 0L										*/
/*	fname:					Zeiger auf den Programmnamen													*/
/*----------------------------------------------------------------------------------------*/
WINDOW	*open_tos_window( BYTE *fname, TSCREEN *tscreen )
{
	BYTE		title[128];
	WINDOW	*window;
	GRECT		mwork,
				mborder,
				win;
	WORD		handle;



	window = 0L;
		
	if ( tscreen )
	{
		wind_get( 0, WF_WORKXYWH, &mborder.g_x, &mborder.g_y, &mborder.g_w, &mborder.g_h );

		win.g_x = (WORD) ((( LONG ) std_win.g_x * mborder.g_w + 5000 ) / 10000 + mborder.g_x );
		win.g_y = (WORD) ((( LONG ) std_win.g_y * mborder.g_h + 5000 ) / 10000 + mborder.g_y );
		win.g_w = (WORD) ((( LONG ) std_win.g_w * mborder.g_w + 5000 ) / 10000 );
		win.g_h = (WORD) ((( LONG ) std_win.g_h * mborder.g_h + 5000 ) / 10000 );

		if (( win.g_x >= mborder.g_x ) && ( win.g_x < ( mborder.g_x + mborder.g_w )))
			mborder.g_x = win.g_x;
		if (( win.g_y >= mborder.g_y ) && ( win.g_y < ( mborder.g_y + mborder.g_h )))
			mborder.g_y = win.g_y;
		if ( win.g_w <= mborder.g_w )
			mborder.g_w = win.g_w;
		if ( win.g_h <= mborder.g_h )
			mborder.g_h = win.g_h;

		wind_calc( WC_WORK, WELEMENTS, &mborder, &mwork );

		if ( mwork.g_w > tscreen->char_width * columns )
			mwork.g_w = tscreen->char_width * columns;

		if ( mwork.g_h > tscreen->char_height * rows )
			mwork.g_h = tscreen->char_height * rows;

		mwork.g_w -= mwork.g_w % tscreen->char_width;

		mwork.g_h -= mwork.g_h % tscreen->char_height;

		wind_calc( WC_BORDER, WELEMENTS, &mwork, &mborder );

		strcpy( title, " " );
		strcat( title, fname );
		strcat( title, " "  );

		window = create_window( WELEMENTS, &mborder, &handle,
								title, title, iconified_tree1 );

		if ( window )
		{
			window->redraw = redraw; 									/* Adresse der Redrawroutine */
			window->interior_flags = TXT_SCRN;						/* Typ des Fensterinhalts */
			window->interior = (void *) tscreen;					/* Zeiger auf Fensterobjekt */
			window->w = columns * tscreen->char_width;			/* Breite der ArbeitsflÑche */
			window->h = ( rows + buffer_rows ) * tscreen->char_height;	/* Hîhe der ArbeitsflÑche */
			window->dx = tscreen->char_width;						/* Breite einer Scrollspalte */
			window->dy = tscreen->char_height;						/* Hîhe einer Scrollzeile */
			window->snap_dx = 1;											/* kein horizontales Snapping	*/
			window->snap_dy = 1;											/* kein vertikales Snapping	*/
			window->snap_dw = tscreen->char_width;					/* Breite ist immer Vielfaches der Zeichenbreite */
			window->snap_dh = tscreen->char_height;				/* Hîhe ist immer Vielfaches der Zeichenhîhe */
			window->limit_w = columns * tscreen->char_width;	/* maximale Breite */
			window->limit_h = rows * tscreen->char_height;		/* maximale Hîhe */
			window->wflags.smart_size = 1;							/* Smart Redraw beim Vergrîûern ausnutzen */
			window->wflags.limit_wsize = 1;							/* maximale Grîûe begrenzen */
			window->wflags.snap_width = 1;							/* Breite in Stufen Ñndern */
			window->wflags.snap_height = 1;							/* Hîhe in Stufen Ñndern */
			window->wflags.snap_x = 0;		
			window->wflags.snap_y = 0;	
	
			if ( buffer_rows > 0 )
				vslid_window( window->handle,
									(WORD) (1000 * (LONG) buffer_rows / ( buffer_rows + rows - ( mwork.g_h / tscreen->char_height ))));
			else
				vslid_window( window->handle, 0 );
	
			set_slsize( window );					/* Slidergrîûen berechnen	*/
			wind_open( handle, &WBORDER );
		}
		else
			form_alert( 1, fstring_addr[NOWINDOWS] );
	}

	return( window );
}

/*----------------------------------------------------------------------------------------*/
/* Fenster schlieûen und Applikation nîtigenfalls beenden											*/
/*	handle:					Fensternummer																		*/
/*----------------------------------------------------------------------------------------*/
void	close_tos_window( WORD handle )
{
	WINDOW	*window;

	window = search_struct( handle );
	if ( window )
	{
		if (( WTSCREEN->child_id != 0 ) && ( app_window[WTSCREEN->child_id] != 0L ))
		{
			OBJECT	*dialog;
	
			dialog = tree_addr[TERMTOS];
	
			strcpy( dialog[TERMNAME].ob_spec.free_string, window->name );	/* Achtung, Fenstertitel enthÑlt links und rechts ein Leerzeichen! */
			if ( do_dialog( dialog ) == TTOS )		/* Programm beenden?	*/
			{
				WORD	buf[8];
				
				WTSCREEN->term = 1;
				
				buf[0] = SM_M_SPECIAL;					/* Nachricht an den SCRENMGR */
				buf[1] = app_id;							/* Absender der Nachricht */
				buf[2] = 0;									/* öberlÑnge in Bytes */
				buf[3] = 0;									/* muû 0 sein */
				buf[4] = 'MA';								/* Magic	*/
				buf[5] = 'GX';								/* Magic	*/
				buf[6] = SMC_TERMINATE;					/* Programm terminieren	*/
				buf[7] = WTSCREEN->child_id;			/* Applikationsnummer	*/
				appl_write( SCRENMGR, 16, buf );
			}
		}
		else
		{
			close_vt( WTSCREEN );	
			delete_window( handle );
		}
	}
}

/*----------------------------------------------------------------------------------------*/
/* Auf Tastendruck reagieren																					*/
/*----------------------------------------------------------------------------------------*/
void	hdle_keybd( WORD keycode, WORD key_state )
{
	WORD		handle;
	WINDOW	*window;
	
	switch (keycode)
	{
		case ALT_O:	menu_selected( MDATEI, DOPEN );	break;
		case ALT_U:	menu_selected( MDATEI, DCLOSE );	break;
		case ALT_Q:	menu_selected( MDATEI, DQUIT );	break;
		case ALT_V:	menu_selected( MEDIT, BPASTE );	break;
		case ALT_W:	menu_selected( MFENSTER, FCHANGEW );	break;
		case ALT_C:	menu_selected( MOPTIONEN, OCLIP );	break;
		case ALT_P:	menu_selected( MOPTIONEN, OTOSENDE );	break;
		case ALT_T:	menu_selected( MOPTIONEN, OTERMINAL );	break;
		case ALT_Z:	menu_selected( MOPTIONEN, OFONT );	break;
		case ALT_S:	menu_selected( MOPTIONEN, OSAVE );	break;
			
		default:
		{
			wind_get( 0, WF_TOP, &handle, 0, 0, 0 );
			window = search_struct( handle );

			if (( window ) && !(window->wflags.iconified))
			{
				if ( WTSCREEN->tcnt < ( TBUFSIZE - 1 ))
				{
					if ( input_opt )							/* Fenster bei Tastatureingaben scrollen?	*/
					{
						LONG	y;
						
						y = WTSCREEN->y * WTSCREEN->char_height;
						
						if (( y < window->y ) || ( y >= window->y + WWORK.g_h ))
						{
							LONG	vslid;
							
							vslid = WTSCREEN->rows * WTSCREEN->char_height - WWORK.g_h;
	
							if ( vslid < y )
								vslid = 1000;
							else
								vslid = 1000 * y / vslid;
	 						
							vslid_window( window->handle, (WORD) vslid );
						}
					}
					
					WTSCREEN->input++;
					
					while ( WTSCREEN->input != 1 )	
						appl_yield();
					
					WTSCREEN->tcnt++;
					WTSCREEN->tbuf[WTSCREEN->tcnt] = 
					(( keycode | (((ULONG ) keycode) << 8 )) & 0x00ff00ffL ) | ((((ULONG) key_state) << 24 ) & 0xff000000L );

					WTSCREEN->input--;
		
					if ( WTSCREEN->tcnt == 0 )
					{
						WORD	buf[8];
						
						buf[0] = 1000;								/* Nachrichtennummer */
						buf[1] = app_id;							/* Absender der Nachricht */
						buf[2] = 0;									/* öberlÑnge in Bytes */
						buf[3] = window->handle;				/* Fensternummer */
						buf[4] = keycode;							/* Taste	*/
						buf[5] = key_state;
						appl_write( WTSCREEN->child_id, 16, buf );
					}
				}
			}
			break;
		}
	}
}

/*----------------------------------------------------------------------------------------*/
/* Auf Mausereignis reagieren																					*/
/*	x:							x-Koordinate																		*/
/*	y:							y-Koordinate																		*/
/*	button:					Maustasten																			*/
/* key_state:				Tastaturzustand																	*/
/* clicks:					Anzahl der TastendrÅcke															*/
/*----------------------------------------------------------------------------------------*/
#pragma warn -par
void	hdle_button( WORD x, WORD y, WORD button, WORD key_state, WORD clicks )
{
	if (( clicks == 1 ) && ( button &= 1 ))
	{
		WINDOW	*window;
		BLOCK		old,
					new;

		window = search_struct( wind_find( x, y ));
		if (( window ) && !(window->wflags.iconified))
		{
			EVNTDATA	mouse;

			wind_update( BEG_UPDATE );
			wind_update( BEG_MCTRL );
		
			redraw_changed( window );
			evnt_timer( 100 );
			graf_mkstate( &mouse.x, &mouse.y, &mouse.bstate, &mouse.kstate );
			new.x2 = mouse.x;
			new.y2 = mouse.y;
			button = mouse.bstate;

			if ( button &= 1 )
			{
				vswr_mode( vdi_handle, 3 );
				vsf_color( vdi_handle, 1 );
				vsf_interior( vdi_handle, 1 );
				
				old.x2 = old.x1 = x = ( x - WWORK.g_x + (WORD) window->x ) / WTSCREEN->char_width;
				old.y2 = old.y1 = y = ( y - WWORK.g_y + (WORD) window->y ) / WTSCREEN->char_height;
	
				while ( button &= 1 )
				{
					graf_mkstate( &mouse.x, &mouse.y, &mouse.bstate, &mouse.kstate );
					new.x2 = mouse.x;
					new.y2 = mouse.y;
					button = mouse.bstate;
	
					new.x1 = x;
					new.y1 = y;
					new.x2 = clip_value( new.x2, WWORK.g_x, WWORK.g_x + WWORK.g_w - 1 );
					new.x2 = ( new.x2 + ( WTSCREEN->char_width / 2 ) - WWORK.g_x + (WORD) window->x ) / WTSCREEN->char_width;

					if ( new.y2 < WWORK.g_y )
					{
						BLOCK	tmp_blk;
						WORD	tmp_y;
						
						upline_window( window );
						new.y2 = WWORK.g_y;
						
						tmp_y = ( new.y2 - WWORK.g_y + (WORD) window->y ) / WTSCREEN->char_height;

						if ( tmp_y >= y )						
						{
							tmp_blk.x1 = 0;
							tmp_blk.y1 = tmp_y;
							tmp_blk.x2 = WTSCREEN->columns+1;
							tmp_blk.y2 = tmp_y;
							
							if ( tmp_y == y )
									tmp_blk.x1 = x;
							
							select_block( window, &tmp_blk, &tmp_blk, 0 );		/* Block deselektieren	*/
						}
					}
	
					if ( new.y2 >= ( WWORK.g_y + WWORK.g_h ))
					{
						BLOCK	tmp_blk;
						WORD	tmp_y;

						dnline_window( window );
						new.y2 = WWORK.g_y + WWORK.g_h - 1;
						
						tmp_y = ( new.y2 - WWORK.g_y + (WORD) window->y ) / WTSCREEN->char_height;

						if ( tmp_y <= y )						
						{
							tmp_blk.x1 = 0;
							tmp_blk.y1 = tmp_y;
							tmp_blk.x2 = WTSCREEN->columns+1;
							tmp_blk.y2 = tmp_y;

							if ( tmp_y == y )
									tmp_blk.x2 = x;

							select_block( window, &tmp_blk, &tmp_blk, 0 );		/* Block deselektieren	*/
						}
					}
				
					new.y2 = ( new.y2 - WWORK.g_y + (WORD) window->y ) / WTSCREEN->char_height;
					
					select_block( window, &old, &new, 1 );	
					old = new;
				}
				
				select_block( window, &old, &new, 0 );		/* Block deselektieren	*/
				save_block( WTSCREEN, &new );	/* Block speichern	*/
			}
			wind_update( END_MCTRL );
			wind_update( END_UPDATE );
		}
	}
}
#pragma warn .par

/*----------------------------------------------------------------------------------------*/
/* Textbereich selektieren																						*/
/* window:					Zeiger auf die Fensterstruktur												*/
/*	old:						Zeiger auf den letzten markierten Textblock								*/
/*	new:						Zeiger auf den zu markierenden Textblock									*/
/* select:					0: old deselektieren 1: new selektieren									*/
/*----------------------------------------------------------------------------------------*/
void	select_block( WINDOW *window, BLOCK *old, BLOCK *new, WORD select )
{
	BLOCK	draw;
	GRECT	box;

	sort_block( old );
	sort_block( new );
	
	if ( select ) 
	{
		if (( new->x1 != old->x1 ) || ( new->y1 != old->y1 ) || ( new->x2 != old->x2 ) || ( new->y2 != old->y2 ))
			intersect_blocks( old, new, &draw );						
		else
			draw.x1 = draw.y1 = draw.x2 = draw.y2 = 0;
	}
	else
		draw = *old;

	if ( draw.x1 | draw.y1 | draw.x2 | draw.y2 )
	{
		graf_mouse( M_OFF, 0L );

		/* erstes Element der Rechteckliste erfragen */
		wind_get( window->handle, WF_FIRSTXYWH, &box.g_x, &box.g_y, &box.g_w, &box.g_h );
					
		while( box.g_w && box.g_h )	/* noch gÅltige Rechtecke vorhanden? */
		{
			if( rc_intersect( &WWORK, &box ) )	/* innerhalb des zu zeichnenden Bereichs? */
			{
				box.g_w += box.g_x - 1;
				box.g_h += box.g_y - 1;
				vs_clip( vdi_handle, 1, (WORD *) &box );
	
				draw_selected( window, &draw );
			}
			/* nÑchstes Element der Rechteckliste holen */
			wind_get( window->handle, WF_NEXTXYWH, &box.g_x, &box.g_y, &box.g_w, &box.g_h );
		}
		graf_mouse( M_ON, 0L );
	}
}

/*----------------------------------------------------------------------------------------*/
/* Textblîcke schneiden und einen neu zu zeichnenden Textblock berechnen						*/
/*	old:						Zeiger auf den letzten markierten Textblock								*/
/*	new:						Zeiger auf den zu markierenden Textblock									*/
/* draw:						Zeiger auf den zu zeichnenden Textblock									*/
/*----------------------------------------------------------------------------------------*/
void	intersect_blocks( BLOCK *old, BLOCK *new, BLOCK *draw )
{
	if (( new->x1 == old->x1 ) && ( new->y1 == old->y1 ))
	{
		draw->x1 = old->x2;
		draw->y1 = old->y2;
		draw->x2 = new->x2;
		draw->y2 = new->y2;
	}
	else if (( new->x1 == old->x2 ) && ( new->y1 == old->y2 ))
	{
		draw->x1 = old->x1;
		draw->y1 = old->y1;
		draw->x2 = new->x2;
		draw->y2 = new->y2;
	}
	else if (( new->x2 == old->x2 ) && ( new->y2 == old->y2 ))
	{
		draw->x1 = new->x1;
		draw->y1 = new->y1;
		draw->x2 = old->x1;
		draw->y2 = old->y1;
	}
	else
	{
		draw->x1 = new->x1;
		draw->y1 = new->y1;
		draw->x2 = old->x2;
		draw->y2 = old->y2;
	}
	sort_block( draw );
}

/*----------------------------------------------------------------------------------------*/
/* Koordinaten eines Textblockes sortieren																*/
/*	area:						Zeiger auf den zu sortierenden Textblock									*/
/*----------------------------------------------------------------------------------------*/
void	sort_block( BLOCK *area )
{
	if (( area->y2 < area->y1 ) || (( area->y2 == area->y1 ) && ( area->x2 < area->x1 )))
	{
		WORD	x,
				y;
		
		x = area->x1;
		y = area->y1;
		area->x1 = area->x2;
		area->y1 = area->y2;
		area->x2 = x;
		area->y2 = y;
	}
}

/*----------------------------------------------------------------------------------------*/
/* Textbereich invertieren																						*/
/* window:					Zeiger auf die Fensterstruktur												*/
/*	area:						Zeiger auf den zu invertierenden Textblock								*/
/*----------------------------------------------------------------------------------------*/
void	draw_selected( WINDOW *window, BLOCK *area )
{
	VRECT	rect;
	VRECT	a;
	
	if (( area->x1 != area->x2 ) || ( area->y1 != area->y2 ))
	{
		a.x1 = area->x1 * WTSCREEN->char_width - (WORD) window->x + WWORK.g_x;
		a.y1 = area->y1 * WTSCREEN->char_height - (WORD) window->y + WWORK.g_y;
		a.x2 = area->x2 * WTSCREEN->char_width - (WORD) window->x + WWORK.g_x - 1;
		a.y2 = area->y2 * WTSCREEN->char_height - (WORD) window->y + WWORK.g_y + WTSCREEN->char_height - 1;

		rect = a;
					
		if ( rect.y1 < ( rect.y2 - WTSCREEN->char_height + 1 ))
		{
			rect.x2 = WWORK.g_x + WWORK.g_w - 1;
			rect.y2 = rect.y1 + WTSCREEN->char_height - 1;
		
			if ( rect.x2 > rect.x1 )
		 		vr_recfl( vdi_handle, (WORD *) &rect );
	
			rect.x1 = WWORK.g_x;
			rect.y1 += WTSCREEN->char_height;
			
			if ( rect.y1 < ( a.y2 - WTSCREEN->char_height + 1 ))
			{
				if ( a.x2 < rect.x2 )
				{		
					rect.y2 = a.y2 - WTSCREEN->char_height;
					vr_recfl( vdi_handle, (WORD *) &rect );
	
					rect.y1 = rect.y2 + 1;
				}
			}
			
			rect.x2 = a.x2;
			rect.y2 = a.y2;
		}	
		if ( rect.x2 > rect.x1 )
			vr_recfl( vdi_handle, (WORD *) &rect );
	}
}

/*----------------------------------------------------------------------------------------*/
/* Textbereich speichern																						*/
/* tscreen:					Zeiger auf die Textschirmstruktur											*/
/*	area:						Zeiger auf den zu speichernden Textblock									*/
/*----------------------------------------------------------------------------------------*/
void	save_block( TSCREEN *tscreen, BLOCK *area )
{
	BLOCK	save;
	BYTE	scrp_name[256];
	UBYTE	des_line[MAX_COLUMNS + 2];
	WORD	line_cnt;
	WORD	cnt,
			opt;
	LONG	handle;
	TPTR	*line_ptr;
	ULONG	*src_line;
	
	scrap_clear();
	
	strcpy( scrp_name, scrp_path );
	strcat( scrp_name, "SCRAP.TXT" );
	
	save = *area;
	save.x1 = clip_value( save.x1, 0, tscreen->columns + 1 );
	save.y1 = clip_value( save.y1, 0, tscreen->rows );
	save.x2 = clip_value( save.x2, 0, tscreen->columns + 1 );
	save.y2 = clip_value( save.y2, 0, tscreen->rows );
	
	if (( handle = Fcreate( scrp_name, 0 )) >= 0 )
	{
		line_ptr = tscreen->first_line + area->y1;
		line_cnt = area->y1;
	
		while ( line_cnt <= save.y2 )
		{
			opt = copy_opt;
			cnt = tscreen->columns + 1;	/* ZeilenlÑnge	*/

			src_line = line_ptr->line;
			
			if ( line_cnt == save.y2 )		/* letzte Zeile?	*/
			{
				cnt = save.x2;					/* dann bis save.x2 speichern	*/
				opt = 2;							/* kein CR,LF	*/
			}
			if ( line_cnt == save.y1 )		/* erste Zeile?	*/
			{
				src_line += save.x1;			/* dann ab save.x1 speichern	*/
				cnt -= save.x1;
			}
			save_line( (WORD) handle, src_line, des_line, cnt, opt );
			
			line_ptr++;
			line_cnt++;
		}
		Fclose( (WORD) handle );
	}
}

/*----------------------------------------------------------------------------------------*/
/* Zeile aus dem Textbuffer abspeichern																	*/
/*	handle:					Handle der zu beschreibenden Datei											*/
/* src:						Zeiger auf die Textbufferzeile												*/
/* des:						Zeiger auf den Zielstring														*/
/* src_len:					TextzeilenlÑnge																	*/
/* opt:						Kopieroptionen 0 - 2 (copy_opt)												*/
/*----------------------------------------------------------------------------------------*/
void	save_line( WORD handle, ULONG *src, UBYTE *des, WORD src_len, WORD opt )
{
	UBYTE	*des_start;
	UBYTE	x;
	
	des_start= des;
	while ( src_len > 0 )
	{
		x = (BYTE) *src++;
		if (( opt == 1 ) || ( x >= SPACE ))
			*des++ = x;
		src_len--;
	}

	if ( opt == 0 )
	{
		*des++ = 13;
		*des++ = 10;
	}
	
	if ( des - des_start )
		Fwrite( handle, des - des_start, des_start );
}

/*----------------------------------------------------------------------------------------*/
/* Alle SCRAP-Dateien im Ordner CLIPBRD lîschen															*/
/*----------------------------------------------------------------------------------------*/
void	scrap_clear( void )
{
	DTA	dta;
	DTA	*old_dta;
	BYTE	search[256];
	BYTE	del[256];
	
	strcpy( search, scrp_path );
	strcat( search, "SCRAP.*" );
	
	old_dta = Fgetdta();
	Fsetdta( &dta );
	while ( Fsfirst( search, 0 ) == 0 )
	{
		strcpy( del, scrp_path );
		strcat( del, dta.d_fname );
		Fdelete( del );
	}
	Fsetdta( old_dta );
}

/*----------------------------------------------------------------------------------------*/
/* Auf angeklickten MenÅeintrag reagieren																	*/
/*	title:					Objektnummer des MenÅtitels													*/
/*	entry:					Objektnummer des MenÅpunktes													*/
/*----------------------------------------------------------------------------------------*/
void	menu_selected( WORD title, WORD entry )
{
	menu_tnormal( tree_addr[MENU], title, 0 );	/* MenÅtitel selektieren */
	
	switch( entry )
	{
		case	WABOUT:		menu_about();	break;	
		case	DOPEN:		menu_open();	break;	
		case	DCLOSE:		menu_close();	break;	
		case	DQUIT: 		menu_quit();	break;	
		case	BPASTE:		menu_paste();	break;
		case	FCHANGEW: 	menu_changew();	break;
		case	OCLIP:		menu_clipboard();	break;
		case	OTOSENDE:	menu_tosende();	break;
		case	OTERMINAL:	menu_terminal();	break;
		case	OFONT:		menu_font();	break;
		case	OSAVE:		menu_save();	break;
	}
	menu_tnormal( tree_addr[MENU], title, 1 );	/* MenÅtitel deselektieren */
}

/*----------------------------------------------------------------------------------------*/
/* AES-Nachrichten bearbeiten																					*/
/*	mbuf:						Zeiger auf den Nachrichtenpuffer												*/
/*----------------------------------------------------------------------------------------*/
void	hdle_mesag( WORD *mbuf )
{
	WORD whdl = mbuf[3];
	GRECT *g = (GRECT *)&mbuf[4];


	switch( mbuf[0] )
	{
		case	MN_SELECTED:	menu_selected( whdl, mbuf[4] ); break;
		case	WM_REDRAW:		redraw_window( whdl, (GRECT *)&mbuf[4] ); break;
		case	WM_TOPPED:		wind_set( whdl, WF_TOP, 0, 0, 0, 0 ); break;
		case	WM_CLOSED:		close_tos_window( whdl ); break;
		case	WM_FULLED:		full_window( whdl, 0, 0 ); break;
		case	WM_ARROWED:		arr_window( whdl, mbuf[4] ); break;
		case	WM_HSLID:		hlsid_window( whdl, mbuf[4] ); break;
		case	WM_VSLID:		vslid_window( whdl, mbuf[4] ); break;
		case	WM_SIZED:		size_window( whdl, g ); break;
		case	WM_MOVED:		move_window( whdl, g ); break;
		case	WM_ALLICONIFY:		iconify_window( -1, g); break;
		case	WM_ICONIFY:		iconify_window( whdl, g); break;
		case	WM_UNICONIFY:	uniconify_window( whdl, g ); break;

		case	AP_TERM:			menu_quit(); break;
		case	AP_DRAGDROP:	receive_dragdrop( mbuf ); break;	
		case	CH_EXIT:			child_terminated( mbuf ); break;
		case	RUN_TOS:			run_tos( mbuf ); break;
		case	VA_START:
		{
			WORD	av_app;

			start_tos( *(BYTE **)&mbuf[3] );
				
			mbuf[0] = AV_STARTED;										/* Message zurÅcksenden */
			av_app = mbuf[1];
			mbuf[1] = app_id;
			appl_write( av_app, 16, mbuf );
			break;
		}
	}

	while ( mbuf[2] > 0 )
	{
		int16	read;
		
		read = 16;
		if ( read > mbuf[2] )
			read = mbuf[2];
		mbuf[2] -= read;
		appl_read( app_id, read, &buf[8] );							/* Rest einlesen */
	}
}
		
/*----------------------------------------------------------------------------------------*/
/* AES-Events anfordern																							*/
/*----------------------------------------------------------------------------------------*/
void	event_loop( void )
{
	WORD	evnt;
	
	while( quit == FALSE )
	{
		EVNTDATA	mouse;

		evnt = evnt_multi( MU_KEYBD | MU_BUTTON | MU_MESAG | MU_TIMER,
								 2, 1, 1,
								 0, 0L,
								 0, 0L,
								 buf,
								 utime,
								 &mouse,
								 &keycode, &mclicks );

		mousex = mouse.x;
		mousey = mouse.y;
		mbutton = mouse.bstate;
		mkstate = mouse.kstate;

		/* Tastendruck? */
		if( evnt & MU_KEYBD )
			hdle_keybd( keycode, mkstate );

		/* Mausclicks? */
		if( evnt & MU_BUTTON )
			hdle_button( mousex, mousey, mbutton, mkstate, mclicks );

		/* Mitteilungen des SCRENMGR? */
		if( evnt & MU_MESAG )
			hdle_mesag( buf );

		if( evnt & MU_TIMER )
			redraw_timer();
	}
}

/*----------------------------------------------------------------------------------------*/
/* Resource und dazugehîrige Strukturen initialisieren												*/
/*----------------------------------------------------------------------------------------*/
void	init_rsrc( void )
{
	/* Adresse des Resource-Headers Åber global[7/8] holen */
	rsh = *((RSHDR **)(&_GemParBlk.global[7]));

	/* Zeiger auf die Objektbaumtabelle holen */
	tree_addr = (OBJECT **)(((UBYTE *)rsh) + rsh->rsh_trindex);

	/* und Anzahl der ObjektbÑume (von 1 ab gezÑhlt) bestimmen */
	tree_count = rsh->rsh_ntree;

	fstring_addr = (BYTE **)((UBYTE *)rsh + rsh->rsh_frstr);

	rsrc_gaddr(R_TREE, T_ICONIFIED1, &iconified_tree1);
	rsrc_gaddr(R_TREE, T_ICONIFIED2, &iconified_tree2);
}

/*----------------------------------------------------------------------------------------*/
/* Vektoren initialisieren																						*/
/*----------------------------------------------------------------------------------------*/
void	set_vec( void )
{
	static struct vtsys vtsys;

	vtsys.version = 0;
	vtsys.getVDIESC = vt_getVDIESC;
/*
	vtsys.winlist = (void *) app_window;
	vtsys.interior_offs = (WORD) offsetof( WINDOW, interior );
	vtsys.columns_offs = (WORD) offsetof( TSCREEN, columns );
	vtsys.rows_offs = (WORD) offsetof( TSCREEN, rows );
	vtsys.visible_offs = (WORD) offsetof( TSCREEN, visible_rows ); 
	vtsys.x_offs = (WORD) offsetof( TSCREEN, x );
	vtsys.y_offs = (WORD) offsetof( TSCREEN, y );
*/
	vtsys.sout_cooked = (void *) vt_app_Sconout;
	vtsys.cin_cooked = (void *) vt_app_Cconin;
	vtsys.inherit = (void *) inherit;
	vtsys.uninherit = (void *) uninherit;
	vtsys.bg = 0;
	vtsys.fg = 0;

	xbios(39, 'AnKr', (WORD) 6, &vtsys);
/*
	p_vt52_winlst = &app_window[0];
	p_vt_interior_off = (WORD) offsetof( WINDOW, interior );
	p_vt_columns_off = (WORD) offsetof( TSCREEN, columns );
	p_vt_rows_off = (WORD) offsetof( TSCREEN, rows );
	p_vt_visible_off = (WORD) offsetof( TSCREEN, visible_rows ); 
	p_vt_x_off = (WORD) offsetof( TSCREEN, x );
	p_vt_y_off = (WORD) offsetof( TSCREEN, y );
	p_vt_Cconin = vt_Cconin;
	p_vt_Cconout = vt_Cconout;
*/

	old_bios_vec = change_vec( (void **) 0xb4, (void *) bios_disp );
	old_xbios_vec = change_vec( (void **) 0xb8, (void *) xbios_disp );
	old_etv_term = change_vec( (void **) 0x408, (void *) new_etv_term );
	old_xconstat = change_vec( (void **) 0x526, (void *) xconstat );
	old_xconin = change_vec( (void **) 0x532, (void *) xconin );
	old_xconout_con = change_vec( (void **) 0x586, (void *) xconout_con );
	old_xconout_raw = change_vec( (void **) 0x592, (void *) xconout_raw );
	old_xcostat_con = change_vec( (void **) 0x566, (void *) xcostat_con );
	old_xcostat_raw = change_vec( (void **) 0x572, (void *) xcostat_raw );
}


/*----------------------------------------------------------------------------------------*/
/* Vektoren zurÅcksetzen																						*/
/*----------------------------------------------------------------------------------------*/
LONG	reset_vec( void )
{
	void	**ch_bios,
			**ch_xbios,
			**ch_etv_term,
			**ch_xconstat,
			**ch_xin_con,
			**ch_xout_con,
			**ch_xout_raw,
			**ch_xstat_con,
			**ch_xstat_raw;

	ch_bios = search_vec( (void **) 0xb4, (void *) bios_disp );
	ch_xbios = search_vec( (void **) 0xb8, (void *) xbios_disp );
	ch_etv_term = search_vec( (void **) 0x408, (void *) new_etv_term );
	ch_xconstat = search_vec( (void **) 0x526, (void *) xconstat );
	ch_xin_con = search_vec( (void **) 0x532, (void *) xconin );
	ch_xout_con = search_vec( (void **) 0x586, (void *) xconout_con );
	ch_xout_raw = search_vec( (void **) 0x592, (void *) xconout_raw );
	ch_xstat_con = search_vec( (void **) 0x566, (void *) xcostat_con );
	ch_xstat_raw = search_vec( (void **) 0x572, (void *) xcostat_raw );

	if ( ch_bios && ch_xbios && ch_etv_term && ch_xconstat && ch_xin_con &&
			ch_xout_con && ch_xout_raw && ch_xstat_con && ch_xstat_raw )
	{
		change_vec( ch_bios, old_bios_vec );
		change_vec( ch_xbios, old_xbios_vec );
		change_vec( ch_etv_term, old_etv_term );
		change_vec( ch_xconstat, old_xconstat );
		change_vec( ch_xin_con, old_xconin );
		change_vec( ch_xout_con, old_xconout_con );
		change_vec( ch_xout_raw, old_xconout_raw );
		change_vec( ch_xstat_con, old_xcostat_con );
		change_vec( ch_xstat_raw, old_xcostat_raw );
/*
		p_vt52_winlst = 0L;
*/
		xbios(39, 'AnKr', (WORD) 6, NULL);
		return( TRUE );
	}
	else
		return( FALSE );
}

/*----------------------------------------------------------------------------------------*/
/* Adresse des zu Ñndernden Vektors suchen																*/
/* Funktionsresultat:	Adresse des zu Ñndernden Vektors oder 0L									*/
/*	addr:						Aresse des Vektors, ab der gesucht wird									*/
/*	vt_vec:					gesuchter Vektor-Inhalt															*/
/*----------------------------------------------------------------------------------------*/
void	**search_vec( void **addr, void * vt_vec )
{
	void	*old;
	ULONG	*xbra;
	void	**vec;
	
	old = change_vec( addr, 0L );	/* Vektorinhalt auslesen	*/
	if ( old == vt_vec )
		return( addr );
	
	do
	{	
		xbra = ((ULONG *) old ) - 3;
		vec = (void **) ( xbra + 2 );
		old = *vec;							/* Zeiger auf nÑchste Routine	*/
	
		if ( *xbra == 'XBRA' )			/* XBRA-Verkettung?	*/
		{
			if ( *vec == vt_vec )		/* VT52-Routine?	*/
				break;
		}
		else
			vec = 0L;

	} while ( vec );

	return( vec );
}

/*----------------------------------------------------------------------------------------*/
/* Vektor verÑndern																								*/
/* Funktionsresultat:	alter Vektor-Inhalt																*/
/*	addr:						Adresse des Vektors oder 0L													*/
/*	new:						neuer Vektor-Inhalt oder 0L													*/
/*----------------------------------------------------------------------------------------*/
void	*change_vec( void **addr, void *new )
{
	WORD	vec;
	void	*old;
		
	vec =  ((WORD) addr ) >> 2;
	
	if (((((WORD) addr) & 3 ) == 0 ) && ( addr < (void **) 2048 ))
	{
		if ( addr )
			old = (void *) Setexc( vec, (void (*)()) -1L );
		if ( new )
			Setexc( vec, (void (*)()) new );
	}
	else
	{
		if ( addr )
			old = *addr;
		if ( new )
			*addr = new;
	}
	return( old );
}

/*----------------------------------------------------------------------------------------*/
/* Zeiger auf die aktuelle Applikationsstruktur liefern												*/
/* Funktionsresultat:	Zeiger auf die aktuelle Applikationsstruktur								*/
/*----------------------------------------------------------------------------------------*/
LONG	get_act_appl( void )
{
	XT_AESVARS *aesvars;
	LONG	data;
	
	aesvars = *((XT_AESVARS **) (aes_global+11));
	if	(aesvars->magic2 != 'MAGX')
		return(0);

	data = aesvars->dos_magic;
	data = data + 4;	/* Adresse des Zeiger auf die aktuelle Applikationsstruktur */
	return( data );
}

/*----------------------------------------------------------------------------------------*/
/* Stack-Offset im Supervisor-Modus bestimmen															*/
/* Funktionsresultat:	Stack-Offset fÅr BIOS und XBIOS												*/
/*----------------------------------------------------------------------------------------*/
LONG	get_stack_frame( void )
{
	if	( *(WORD *)0x59e )
		return( 8 );
	else
		return( 6 );
}

/*----------------------------------------------------------------------------------------*/
/* Adresse der Variable kbshift bestimmen																	*/
/* Funktionsresultat:	Adresse von kbshift																*/
/*----------------------------------------------------------------------------------------*/
LONG get_kbshift( void )
{
	return( (LONG)	( *(SYSHDR **) 0x4f2 )->kbshift );
}

/*----------------------------------------------------------------------------------------*/
/* Variablen auf Standardwerte setzen																		*/
/*----------------------------------------------------------------------------------------*/
void	std_settings( void )
{
	WORD	/*i,*/
			drive;
	int8	*env;
	
	columns = 80;
	rows = 25;
	buffer_rows = 50;
	
	font_id = 1;
	cpoint = 10;

	std_win.g_x = 0;
	std_win.g_y = 0;
	std_win.g_w = 10000;
	std_win.g_h = 10000;

	utime = 200;
	update_flag = 0x0100;
	copy_opt = 0;	/* CR,LF am Zeilenende	*/
	paste_opt = 0;	/* CR beim EinfÅgen statt CR, LF	*/
	close_term = 0;	/* Fenster nach Programmende offen lassen	*/
	term_opt = 0;	/* VT52 bleibt im Vordergrund */
	input_opt = 0;	/* nicht zur Eingabe scrollen	*/
	pact_appl = (APPL **) get_act_appl();
	stack_offset = (WORD) Supexec( get_stack_frame );
	key_state = (UBYTE *) Supexec( get_kbshift );

/* unnîtig
	for ( i = 0; i < 128; app_window[i++] = 0L );
*/
	drive = Dgetdrv();
	*path = drive + 'A';
	*( path + 1 )= ':';
	Dgetpath( path + 2, drive + 1 ); 
	if ( *( path + strlen( path )) != '\\' )
		strcat( path, "\\" );

	env = getenv( "HOME" );												/* Environment suchen */
	if ( env )
	{
		strcpy( home, env );
		if ( strlen( home ) > 0 )
		{
			if ( home[strlen( home ) - 1] != '\\' )
				strcat( home, "\\" );									/* Backslash anhÑngen */
		}
	}
	else																		/* aktuellen Pfad benutzen */
	{
		home[0] = Dgetdrv() + 'A';
		home[1] = ':';
		Dgetpath( home + 2, 0 );
		if ( home[strlen( home ) - 1] != '\\' )					/* kein Backslash am Ende? */
			strcat( home, "\\" );
	}

	strcpy( inf_name, home );
	strcat( inf_name, "VT52.INF" );

	scrp_read( scrp_path );
	if ( *scrp_path != 0 )
	{
		if ( *( scrp_path + strlen( scrp_path ) - 1 ) != '\\' )
			strcat( scrp_path, "\\" );
	}
	else
	{
		
		if (( Dsetdrv( Dgetdrv()) & 4 ))								/* Laufwerk C vorhanden?	*/
			*scrp_path = 'C';
		else
			*scrp_path = 'A';
		
		strcat( scrp_path, ":\\CLIPBRD\\" );
		
		if ( Fsfirst( scrp_path, FA_SUBDIR ))
			Dcreate( scrp_path );

		scrp_write( scrp_path );
	}

}

/*----------------------------------------------------------------------------------------*/
/* VT52.INF laden																									*/
/*----------------------------------------------------------------------------------------*/
void	load_inf( void )
{
	DTA	dta;
	DTA	*old_dta;
	BYTE	upper[512];
	BYTE	*inf,
			*pos,
			*line;
	LONG	handle;
	LONG	len;
	LONG	line_len;
	LONG	parse_len;
	int32	err;
	
	old_dta = Fgetdta();
	Fsetdta( &dta );

	err = Fsfirst( inf_name, 0 );
	
	if ( err )
	{
		strcpy( inf_name, home );
		strcat( inf_name, "DEFAULTS\\VT52.INF" );
		err = Fsfirst( inf_name, 0 );
	}
	
	if ( err == 0 )
	{
		handle = Fopen( inf_name, FO_READ );
		if ( handle > 0 )
		{
			inf = malloc( dta.d_length + 1 );	/* DateilÑnge + Null-Byte fÅr Stringende	*/
			if ( inf )
			{
				if ( Fread( (WORD) handle, dta.d_length, inf ) == dta.d_length )
				{
					line = inf;
					len = dta.d_length;
					do
					{
						line_len = get_len( line, len, &parse_len );
						len -= line_len;
						
						*( line + parse_len ) = 0;
						upper[511] = 0;
						strncpy( upper, line, 511 );
						strupr( upper );

						set_value( upper, "#COPY", &copy_opt, 0, 2 );
						set_value( upper, "#PASTE", &paste_opt, 0, 3 );
						set_value( upper, "#COLUMNS", &columns, MIN_COLUMNS, MAX_COLUMNS );
						set_value( upper, "#ROWS", &rows, MIN_ROWS, MAX_ROWS );
						set_value( upper, "#BUFFER", &buffer_rows, MIN_BUFFER, MAX_BUFFER );
						if ( set_value( upper, "#UPDATE", &update_flag, 0, 1 ))
							update_flag = ( update_flag ^ 1 ) << 8;
						set_value( upper, "#INPUTLINE", &input_opt, 0, 1 );
						set_value( upper, "#TIMER", &utime, MIN_TIMER, MAX_TIMER );
						set_value( upper, "#CLOSE", &close_term, 0, 1 );
						set_value( upper, "#TERM", &term_opt, 0, 2 );
						set_value( upper, "#FACE", &font_id, 1, 32767 );
						set_value( upper, "#POINTS", &cpoint, MIN_POINT, MAX_POINT );
						if(( pos = strstr( upper, "#WINDOW" )) != 0L )
							get_std_win( pos + 7 );
						if(( pos = strstr( upper, "#EXEC" )) != 0L )
							auto_exec( pos - upper + line + 5 );

						line += line_len;
					} while (( len > 0 ) && ( line_len > 0 ));
				}
				free( inf );
			}	
		}
		Fclose( (WORD) handle );
	}	
	Fsetdta( old_dta );
}

/*----------------------------------------------------------------------------------------*/
/* LÑnge einer mit CR,LF oder LF abgeschlossenen Zeile ermitteln									*/
/* Funktionsresultat:	LÑnge der Zeile																	*/
/* line:						Zeiger auf die Zeile																*/
/* max_len:					Maximale LÑnge der Zeile														*/
/*----------------------------------------------------------------------------------------*/
LONG	get_len( BYTE *line, LONG max_len, LONG *parse_len )
{
	WORD	semi;
	BYTE	*start;
	BYTE	tmp;
	
	start = line;
	*parse_len = 0;
	semi = 0;
	while ( max_len > 0 )
	{
		tmp = *line++;
		max_len--;
			
		if ( tmp == CR )
		{
			if ( *line == LF )
			{
				line++;
				max_len--;
			}
			break;
		}
		if ( tmp == LF )	
			break;
		if ( tmp == ';' )
			semi = 1;
		
		if ( semi == 0 )
			(*parse_len)++;
	}
	return( line - start );
}

/*----------------------------------------------------------------------------------------*/
/* Ausdruck suchen und die ihm zugewiesene Zahl ermitteln											*/
/* Funktionsresultat:	0 bei einem Fehler, ansonsten 1												*/
/* line:						Zeiger auf den String															*/
/*	exp:						Zeiger auf den zu suchenden Ausdruck										*/
/*	x:							Zeiger auf ein WORD fÅr die nach dem Ausdruck stehende Zahl			*/
/* min:						untere Grenze der Zahl															*/
/* max:						obere Grenze der Zahl															*/
/*----------------------------------------------------------------------------------------*/
WORD	set_value( BYTE *line, BYTE *exp, WORD *x, WORD min, WORD max )
{
	BYTE	*pos;

	pos = strstr( line, exp );
	if ( pos )
	{
		*x = clip_value( atoi( pos + strlen( exp )), min, max );
		return( 1 );
	}
	else
		return( 0 );
}


/*----------------------------------------------------------------------------------------*/
/* Standard- Fensterposition- und grîûe bestimmen														*/
/* line:						Zeiger auf Fensterposition- und grîûe 										*/
/*----------------------------------------------------------------------------------------*/
void	get_std_win( BYTE *line )
{
	line = get_number( line, &std_win.g_x, 0, 10000 );
	line = get_number( line, &std_win.g_y, 0, 10000 );
	line = get_number( line, &std_win.g_w, 0, 10000 );
	line = get_number( line, &std_win.g_h, 0, 10000 );
}

/*----------------------------------------------------------------------------------------*/
/* Programm mit zugehîriger Umgebung laden																*/
/* line:						Zeiger auf die Parameterzeile	bestehend aus								*/
/*								Pfad mit Programmnamen in AnfÅhrungszeichen								*/
/*								Kommandozeile in AnfÅhrungszeichen											*/
/*								Fensterposition und -grîûe in Promille										*/
/*								Spalten																				*/
/*								Zeilen																				*/
/*								Bufferzeilen																		*/
/*								Zeichensatznummer																	*/
/*								Hîhe in Punkten																	*/
/*----------------------------------------------------------------------------------------*/
void	auto_exec( BYTE *line )
{
	BYTE	apath[256],
			acmd[128],
			aname[14];
	GRECT	win;
	WORD	c,
			r,
			b,
			f,
			p;

	c = columns;
	r = rows;
	b = buffer_rows;
	f = font_id;
	p = cpoint;
	win = std_win;

	if (( line = get_string( line, apath )) != 0L )
	{
		line = get_string( line, acmd + 1 );	
		line = get_number( line, &std_win.g_x, 0, 10000 );
		line = get_number( line, &std_win.g_y, 0, 10000 );
		line = get_number( line, &std_win.g_w, 0, 10000 );
		line = get_number( line, &std_win.g_h, 0, 10000 );
		line = get_number( line, &columns, MIN_COLUMNS, MAX_COLUMNS );
		line = get_number( line, &rows, MIN_ROWS, MAX_ROWS );
		line = get_number( line, &buffer_rows, MIN_BUFFER, MAX_BUFFER );
		line = get_number( line, &font_id, 1, 32767 );
		line = get_number( line, &cpoint, MIN_POINT, MAX_POINT );		

		if (( line = strrchr( apath, '\\' )) != 0L )
			line++;
		else
			line = apath;

		strcpy( aname, line );	/* Dateiname	*/
		*line = 0;					/* Ende des Pfades	*/

		acmd[0] = strlen( acmd + 1 );

		exec_tos( aname, apath, acmd );
	}
		
	std_win = win;
	columns = c;
	rows = r;
	buffer_rows = b;
	font_id = f;
	cpoint = p;
}

/*----------------------------------------------------------------------------------------*/
/* Durch AnfÅhrungszeichen begrenzten String suchen und nach des kopieren						*/
/* Funktionsresultat:	Zeiger hinter den String oder 0L												*/
/*	pos:						Startadresse, ab der gesucht wird											*/
/* des:						Zeiger auf Speicherplatz fÅr den gefundenen String						*/
/*----------------------------------------------------------------------------------------*/
BYTE	*get_string( BYTE *pos, BYTE *des )
{
	BYTE	*left,
			*right;
			
	right = 0L;
	
	if (( left = strchr( pos, '"' )) != 0L )
	{
		left++;
		if (( right= strchr( left , '"' )) != 0L )
		{
			*right++ = 0;
			strcpy( des, left );
		}
	}
	return( right );
}			

/*----------------------------------------------------------------------------------------*/
/* Durch Leerzeichen abgetrennte Zahl in ein Integer konvertieren									*/
/* Funktionsresultat:	Zeiger auf die Zahl als String												*/
/*	pos:						Startadresse, ab der gesucht wird											*/
/* value:					Zeiger auf die Zahl als WORD													*/
/* min:						untere Grenze																		*/
/* max:						obere Grenze																		*/
/*----------------------------------------------------------------------------------------*/
BYTE	*get_number( BYTE *pos, WORD *value, WORD min, WORD max )
{
	if ( pos )
	{
		if (( pos = strchr( pos, ' ' )) != 0L)
		{
	
			while ( *pos == ' ' )
			{
				if ( *pos == 0 )
					return( 0L );
				pos++;
			}
			*value = clip_value( atoi( pos ), min, max );
		}
	}	
	return( pos );
}

/*----------------------------------------------------------------------------------------*/
/* Zahl nach oben und unten begrenzen																		*/
/* Funktionsresultat:	begrenzte Zahl																		*/
/* value:					unbearbeitete Zahl																*/
/* min:						untere Grenze																		*/
/* max:						obere Grenze																		*/
/*----------------------------------------------------------------------------------------*/
WORD	clip_value( WORD value, WORD min, WORD max )
{
	if ( value < min )
		return( min );
	if ( value > max )
		return( max );
	return( value );
}

/*----------------------------------------------------------------------------------------*/
/* VT52.INF speichern																							*/
/*----------------------------------------------------------------------------------------*/
void	save_inf( void )
{
	LONG		handle;
	WINDOW	*window;
	BYTE		line[512];
			
	handle = Fcreate( inf_name, 0 );

	if ( handle < 0L )
	{
		strcpy( inf_name, home );
		strcat( inf_name, "VT52.INF" );		
		handle = Fcreate( inf_name, 0 );
		
		if ( handle < 0L )
		{
			strcpy( inf_name, "VT52.INF" );		
			handle = Fcreate( inf_name, 0 );
		}
	}

	if ( handle > 0 )
	{
		save_value( (WORD) handle, "#COPY", copy_opt );
		save_value( (WORD) handle, "#PASTE", paste_opt );
		save_value( (WORD) handle, "#COLUMNS", columns );
		save_value( (WORD) handle, "#ROWS", rows );
		save_value( (WORD) handle, "#BUFFER", buffer_rows );
		save_value( (WORD) handle, "#UPDATE", ( update_flag >> 8 ) ^ 1 );
		save_value( (WORD) handle, "#TIMER", utime );
		save_value( (WORD) handle, "#INPUTLINE", input_opt );
		save_value( (WORD) handle, "#CLOSE", close_term );
		save_value( (WORD) handle, "#TERM", term_opt );
		save_value( (WORD) handle, "#FACE", font_id );
		save_value( (WORD) handle, "#POINTS", cpoint );
		
		sprintf( line, "%s %d %d %d %d\r\n",
					"#WINDOW",
					std_win.g_x,
					std_win.g_y,
					std_win.g_w,
					std_win.g_h );
		Fwrite( (WORD) handle, strlen( line ), line );

		window = get_window_list();
		
		while ( window )
		{
			if ( WTSCREEN->child_id )
			{
				GRECT	desk;
	
				wind_get( 0, WF_WORKXYWH, &desk.g_x, &desk.g_y, &desk.g_w, &desk.g_h );
						
				sprintf( line, "%s \"%s\" \"\" %d %d %d %d %d %d %d %d %d\r\n",
							"#EXEC",
							WTSCREEN->name,																/* Programmpfad mit Namen	*/
							(WORD)(((LONG) WBORDER.g_x - desk.g_x ) * 10000 / desk.g_w ),	/* x-Koordinate in Promille	*/
							(WORD)(((LONG) WBORDER.g_y - desk.g_y ) * 10000 / desk.g_h ),	/* y-Koordinate in Promille	*/
							(WORD)(((LONG) WBORDER.g_w ) * 10000 / desk.g_w ),					/* Breite in Promille	*/
							(WORD)(((LONG) WBORDER.g_h ) * 10000 / desk.g_h ),					/* Hîhe in Promille	*/
							WTSCREEN->columns + 1,														/* Spalten	*/
							WTSCREEN->visible_rows + 1,												/* Zeilen	*/
							WTSCREEN->rows - WTSCREEN->visible_rows,								/* Bufferzeilen	*/
							WTSCREEN->font_id,															/* Zeichensatz	*/
							WTSCREEN->point_size );														/* Hîhe in Punkten	*/
			
				Fwrite( (WORD) handle, strlen( line ), line );
			
			}
		
			window = window->next;
		}

		Fclose( (WORD) handle );
	}
}

/*----------------------------------------------------------------------------------------*/
/* Bezeichner und zugehîrige Zahl speichern																*/
/*	handle:					Datei-Handle																		*/
/* exp:						Zeiger auf den Bezeichner														*/
/* value:					Zahl																					*/
/*----------------------------------------------------------------------------------------*/
void	save_value( WORD handle, BYTE *exp, WORD value )
{
	BYTE	line[256];

	sprintf( line, "%s %d\r\n", exp, value );
	Fwrite( handle, strlen( line ), line );
}

/*----------------------------------------------------------------------------------------*/
/* Alle Fenster schlieûen und die dazugehîrigen Programme terminieren							*/
/* Funktionsresultat:	FALSE oder TRUE																	*/
/*----------------------------------------------------------------------------------------*/
WORD	close_all( void )
{
	WINDOW	*window;
	WINDOW	*next;
	WORD		i,
				ret;
	
	ret = TRUE;
	
	for ( i = 0; i < 128; i++ )
	{
		if ( app_window[i] != 0L ) /* Applikation noch aktiv?	*/
		{
			if ( do_dialog( tree_addr[TERMALL] ) != TALL )
				ret = FALSE;

			break;
		}
	}

	if ( ret )
	{
		window = get_window_list();					/* Zeiger auf das erste Fenster */
		while ( window )
		{
			next = window->next;

			if (( WTSCREEN->child_id != 0 ) && ( app_window[WTSCREEN->child_id] != 0L ))
			{
				WORD	buf[8];

				buf[0] = SM_M_SPECIAL;					/* Nachricht an den SCRENMGR */
				buf[1] = app_id;							/* Absender der Nachricht */
				buf[2] = 0;									/* öberlÑnge in Bytes */
				buf[3] = 0;									/* muû 0 sein */
				buf[4] = 'MA';								/* Magic	*/
				buf[5] = 'GX';								/* Magic	*/
				buf[6] = SMC_TERMINATE;					/* Programm terminieren	*/
				buf[7] = WTSCREEN->child_id;			/* Applikationsnummer	*/
				appl_write( SCRENMGR, 16, buf );
			}
			close_vt( WTSCREEN );	
			delete_window( window->handle );
			window = next;	
		}
	}
	return( ret );
}


/*----------------------------------------------------------------------------------------*/
/* Hauptprogramm																									*/
/*----------------------------------------------------------------------------------------*/
main( WORD argc, BYTE *argv[] )
{
   WORD	ret_code = -1;

   app_id = appl_init();
	aes_global = _GemParBlk.global;
   if( app_id != -1 )
   {
		aes_handle = graf_handle( &pwchar, &phchar, &pwbox, &phbox );
		graf_mouse( ARROW, 0L );
      vdi_handle = open_screen_wk( aes_handle, work_out );

      if( vdi_handle != 0 )
      {
			if( rsrc_load( "VT52.RSC" ) )
			{
				vst_load_fonts( vdi_handle, 0 );
				init_wlib( app_id );

				std_settings();
				Supexec( (LONG (*)()) set_vec );

				init_rsrc();
				menu_bar( tree_addr[MENU], 1 );

				load_inf();

				while ( argc > 1 )
				{
					argc--;
					start_tos( argv[argc] );
				}

				quit = FALSE;
				while ( quit == FALSE )
				{
					event_loop();
					quit = close_all();	/* Fenster schlieûen	*/
					if ( quit == TRUE	)	/* beenden?	*/
					{
						if ( Supexec( reset_vec ) == FALSE )	/* ausklinken nicht mîglich?	*/
						{
							do_dialog( tree_addr[CANTTERM] );	/* Meldung ausgeben	*/
							quit = FALSE;								/* nicht beenden	*/
						}
					}
				}

				menu_bar( tree_addr[MENU], 0 );
				rsrc_free();
			
				reset_wlib();
				vst_unload_fonts( vdi_handle, 0 );
				ret_code = 0;
			}
			v_clsvwk( vdi_handle );
		}		
		appl_exit();
   }

   return( ret_code );
}


/*******************************************************************
*
* Gibt eine Zeichenkette in das Fenster der Applikation <app>
* aus.
*
* RÅckgabe: -1L bei ^C. -2L bei ungÅltiger Applikation.
*           sonst Anzahl der ausgegebenen Zeichen
* str:	Zeiger auf den _nicht_ nullterminierten String
* cnt:	LÑnge des Strings
*
* Wird direkt vom DOS-Kern aufgerufen.
*
********************************************************************/

static LONG vt_app_Sconout( APPL *app, BYTE *str, LONG cnt )
{
	WINDOW *w = vtclients[app->apid].w;
	return((w) ? vt_Cconout( w, str, cnt ) : -2L);
}


/*******************************************************************
*
* Liest ein Zeichen aus dem Fenster der Applikation <app>.
*
* RÅckgabe: -1L bei ^C. -2L bei ungÅltiger Applikation.
*           sonst Tastencode
* str:	Zeiger auf den _nicht_ nullterminierten String
* cnt:	LÑnge des Strings
*
* Wird direkt vom DOS-Kern aufgerufen.
*
********************************************************************/

static LONG vt_app_Cconin( APPL *app)
{
	WINDOW *w = vtclients[app->apid].w;
	return((w) ? vt_Cconin( w ) : -2L);
}


/*******************************************************************
*
* Meldet einen neuen Thread <dst_apid> fÅr ein bereits geîffnetes
* Terminalfenster <src_apid> an.
*
* Wenn fÅr <src_apid> kein Terminalfenster geîffnet wurde, wird
* -1 zurÅckgegeben.
*
* Wird direkt vom AES-Kern aufgerufen.
*
********************************************************************/

static LONG inherit( WORD dst_apid, WORD src_apid)
{
	VTCLIENT_INFO *vtis,*vtid;
	WINDOW *window;


	if	(((UWORD) dst_apid >= NAPPS) || ((UWORD) src_apid >= NAPPS))
		return(ERANGE);

	vtis = vtclients+src_apid;
	vtid = vtclients+dst_apid;
	if	((!vtis->w) || (vtid->w))
		return(ERROR);
	window = vtis->w;
	vtid->w = window;
	vtid->par_apid = -1;					/* nur ein Thread */
	app_window[dst_apid] = window;
	WTSCREEN->refcnt++;
	return(E_OK);
}


/*******************************************************************
*
* Meldet einen neuen Thread <dst_apid> fÅr ein bereits geîffnetes
* Terminalfenster <src_apid> wieder ab.
*
* Wird direkt vom AES-Kern aufgerufen.
*
********************************************************************/

static LONG uninherit( WORD apid)
{
	VTCLIENT_INFO *vti;
	WINDOW *window;


	if	((UWORD) apid >= NAPPS)
		return(ERANGE);
	vti = vtclients+apid;
	window = vti->w;
	if	(!window)
		return(ERROR);
	if	(WTSCREEN->refcnt)
		WTSCREEN->refcnt--;
	vti->w = NULL;
	app_window[apid] = NULL;
	return(E_OK);
}


/*******************************************************************
*
* Gibt einen Zeiger auf eine aktive VDIESC-Struktur fÅr eine
* Applikation zurÅck.
*
* Wird direkt vom AES-Kern aufgerufen.
*
********************************************************************/

static LONG vt_getVDIESC( APPL *app)
{
	VTCLIENT_INFO *vti;
	WINDOW *window;


	vti = vtclients+app->apid;
	window = vti->w;
	if	(!window)
		return(ERROR);
	return(((LONG) (&WTSCREEN->columns))+0x2c);		/* Offset innerhalb LineA */
}
