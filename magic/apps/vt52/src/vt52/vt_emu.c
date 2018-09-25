/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*
*/

/*----------------------------------------------------------------------------------------*/
/* Globale Includes																								*/
/*----------------------------------------------------------------------------------------*/
/* #include <PORTAB.H> */
#include <TOS.H>
#include <VDI.H>
#include <MT_AES.H>
#include <STDDEF.H>
#include <STDLIB.H>

/* #include "types2b.H" */
#include "WSTRUCT.H"
#include "WLIB.H"

/*----------------------------------------------------------------------------------------*/
/* Defines																											*/
/*----------------------------------------------------------------------------------------*/
#define	CONTERM ( *(BYTE *) 0x484 )
#define	CTRL_C 0x002e0003L
#define	CTRL_Q 0x00100011L
#define	CTRL_S 0x001f0013L
#define	KEY_OK 1
#define	KEY_NO_CTRL 0
#define	KEY_TERM -1
#define	SPACE 32

typedef struct
{
	WORD	x1,
			y1,
			x2,
			y2;
}VRECT;

/*----------------------------------------------------------------------------------------*/
/* Lokale Includes																								*/
/*----------------------------------------------------------------------------------------*/
#include "VTSTRUCT.H"
#include "VT_EMU.H"

extern	GRECT	mouse_xy;
extern	WORD	move_flag;
extern	UBYTE		*key_state;

/*
static	WORD		global[12] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
*/

#define	global	(_GemParBlk.global)
static	GRECT		no_clip = { 0,0,0,0 };							/* GRECT fÅr ausgeschaltetes Clipping */
static	UWORD		color_remap[16] = { 0, 2, 3, 6, 4, 7, 5, 8, 9, 10, 11, 14, 12, 15, 13, 1 };	/* Tabelle fÅr die Umwandlung von Farbebenenflag zu Farbnummer */
static	WORD		dummy;

extern	WORD	update_flag;

#define	WBORDER window->border
#define	WWORK window->workarea
#define	WTSCREEN ((TSCREEN *) window->interior )

/*----------------------------------------------------------------------------------------*/
/* Angeben, ob ein Zeichen von der Tastatur eingelesen werden kann								*/
/* Funktionsresultat:	-1 (Zeichen vorhanden) oder 0 (kein Zeichen)								*/
/*	window:					Zeiger auf die Fensterstruktur												*/
/*----------------------------------------------------------------------------------------*/
LONG	vt_Bconstat( WINDOW *window )
{
	appl_yield();															/* Rechenzeit abgeben */
	if ( WTSCREEN->tcnt >= 0 )											/* Zeichen vorhanden? */
		return( -1 );														/* Zeichen sind vorhanden */
	else
		return( 0 );														/* keine Zeichen vorhanden */
}

void	vt_mm( WORD *mbuf );

/*----------------------------------------------------------------------------------------*/
/* Zeichen von der Tastatur einlesen und Bildschirm updaten											*/
/* Funktionsresultat:	Tastencode																			*/
/*	window:					Zeiger auf die Fensterstruktur												*/
/*----------------------------------------------------------------------------------------*/
LONG	vt_Bconin( WINDOW	*window )
{
	TSCREEN	*tscreen;
	LONG		key;
	WORD		mbuf[8];
	
	tscreen = WTSCREEN;

	if ( inc_sem( &tscreen->output ))								/* Ausgabe mîglich? */
	{
		update_window( BEG_UPDATE );									/* Bildschirm fÅr andere Apps sperren */
		draw_cursor( window );											/* Cursorposition aktualisieren */
		redraw_changed( window );										/* Fensterinhalt aktualisieren */
		update_window( END_UPDATE );									/* Bildschirm freigeben */
		tscreen->output--;												/* Ausgabesemaphore zurÅcksetzen */
	}

	if ( tscreen->tcnt >= 0 )											/* sind bereits Zeichen im Buffer? */
		vt_mm( mbuf );														/* Nachrichtenbuffer auslesen */
	else																		/* auf Nachricht warten */
	{
		while ( tscreen->tcnt < 0 )									/* kein Zeichen vorhanden? */
			vt_mesag( mbuf );												/* dann auf Nachricht warten */
	}
	
	while ( inc_sem( &tscreen->input ) == 0 )						/* warten, bis Zeichen ausgelesen werden kann */
		appl_yield();														/* Rechenzeit teilen */

	key = WTSCREEN->tbuf[0] & 0xffff00ffL;
	if (( CONTERM & 0x08 ) == 0 )										/* Status der Kontrolltasten zurÅckliefern? */
		key &= 0x00ff00ffL;												/* wenn nein ausmaskieren */
		
	move_tbuf( tscreen->tbuf, tscreen->tcnt );					/* Tastaturbuffer verschieben */
	tscreen->tcnt--;														/* Anzahl dekrementieren */

	tscreen->input--;														/* Eingabesemaphore zurÅcksetzen */

	return( key );
}

/*----------------------------------------------------------------------------------------*/
/* Tastaturstatus zurÅckliefern																				*/
/* Funktionsresultat:	Tastaturstatus																		*/
/*	window:					Zeiger auf die Fensterstruktur												*/
/*----------------------------------------------------------------------------------------*/
LONG	vt_Kbshift( WINDOW *window )
{
	WORD	handle;
	LONG	status;
	
	handle = get_top();													/* Handle des obersten Fensters erfragen */
	if ( handle == window->handle )									/* gehîrt es der TOS-Applikation? */
	{
		if ( WTSCREEN->tcnt > 0 )										/* Zeichen im Tastaturbuffer vorhanden? */
			status = ( WTSCREEN->tbuf[0] >> 24 ) & 0xff;		/* Status des ersten Zeichens zurÅckliefern */
		else
			status = (LONG) *key_state;								/* aktuellen Status zurÅckliefern */
	}
	else
	{
		if ( get_owner( handle ) == WTSCREEN->child_id )
		{
			status = (LONG) *key_state;								/* aktuellen Status zurÅckliefern */
		}
		else
			status = 0;														/* keine Kontrolltasten gedrÅckt */
	}
	return( status );
}

/*----------------------------------------------------------------------------------------*/
/* String fÅrs GEMDOS ausgeben																				*/
/* Funktionsresultat:	Anzahl der ausgegebenen Zeichen oder -1L bei Ctrl-C					*/
/*	window:					Zeiger auf die Fensterstruktur												*/
/* str:						Zeiger auf den _nicht_ nullterminierten String							*/
/* cnt:						LÑnge des Strings																	*/
/*----------------------------------------------------------------------------------------*/
LONG	vt_Cconout( WINDOW *window, BYTE *str, LONG cnt )
{
	TSCREEN	*tscreen;
	
	tscreen = WTSCREEN;

	if (( tscreen->tcnt >= 0 ) && ( search_ctrl( tscreen ) == KEY_TERM ))	/* Zeichen vorhanden und Ctrl-C gedrÅckt? */
	{
		cnt = -1L;															/* -1L ans GEMDOS zurÅckliefern */
		tscreen->tcnt = -1;												/* Tastaturpuffer ungÅltig machen */
	}
	else
	{
		LONG	i;
		
		tscreen->output++;												/* Ausgabesemaphore setzen */
		while ( tscreen->output != 1 )								/* warten, bis Ausgabe mîglich ist */
			appl_yield();													/* Rechenzeit abgeben */

		for ( i = 1; i <= cnt; i++ )
			tscreen->vt_function( window, *str++ );				/* Zeichen ausgeben */

		if	(cnt)
			window->dirty = TRUE;

		tscreen->output--;												/* Ausgabesemaphore zurÅcksetzen */
	}

	return( cnt );															/* Anzahl der ausgegebenen Zeichen */
}

/*----------------------------------------------------------------------------------------*/
/* Zeichen von der Tastatur fÅrs GEMDOS einlesen und Bildschirm updaten							*/
/* Funktionsresultat:	Tastencode oder -1L bei Ctrl-C												*/
/*	window:					Zeiger auf die Fensterstruktur												*/
/*----------------------------------------------------------------------------------------*/
LONG	vt_Cconin( WINDOW *window )
{
	LONG		key;
	TSCREEN	*tscreen;
	
	tscreen = WTSCREEN;
	
	if ( inc_sem( &tscreen->output ))								/* Ausgabe mîglich? */
	{
		update_window( BEG_UPDATE );									/* Bildschirm fÅr andere Apps sperren */
		draw_cursor( window );											/* Cursorposition aktualisieren */
		redraw_changed( window );										/* Fensterinhalt aktualisieren */
		update_window( END_UPDATE );									/* Bildschirm freigeben */
		tscreen->output--;												/* Ausgabesemaphore zurÅcksetzen */
	}
 
 	do
 	{
	 	if ( search_ctrl( tscreen ) == KEY_TERM )					/* Ctrl-C gedrÅckt? */
		{
			tscreen->tcnt = -1;											/* Tastaturpuffer wird ungÅltig */
			return( -1L );
		}
	} while ( tscreen->tcnt < 0 );									/* warten, bis Zeichen vorhanden */

	while ( inc_sem( &tscreen->input ) == 0 )						/* warten, bis Zeichen ausgelesen werden kann */
		appl_yield();														/* Rechenzeit abgeben */

	key = tscreen->tbuf[0];
	move_tbuf( tscreen->tbuf, tscreen->tcnt );					/* Tastaturbuffer verschieben */
	tscreen->tcnt--;														/* Anzahl dekrementieren */

	tscreen->input--;														/* Eingabesemaphore zurÅcksetzen */

	return( key );	
}


/*----------------------------------------------------------------------------------------*/
/* Tastaturpuffer auf Ctrl-C ÅberprÅfen und Ctrl-S und Ctrl-Q behandeln							*/
/* Funktionsresultat:	KEY_TERM bei Ctrl-C																*/
/*	tscreen:					Zeiger auf die Textschirmstruktur											*/
/*----------------------------------------------------------------------------------------*/
WORD	search_ctrl( TSCREEN *tscreen )
{
	WORD	found;
	
	do
	{
		found = search_ctrl_sq( tscreen, CTRL_Q, CTRL_S );		/* Ctrl-S suchen */

		if ( found == KEY_OK )											/* Ctrl-S vorhanden? */
		{
			do
			{
				appl_yield();
				found = search_ctrl_sq( tscreen, CTRL_S, CTRL_Q );
			} while ( found == KEY_NO_CTRL );						/* bis Ctrl-Q gefunden */
			return( KEY_NO_CTRL );										/* keine weitere Ctrl-Taste im Buffer */
		}	

	} while ( found == KEY_OK );										/* solange Ctrl-Tasten vorhanden sind */

	return( found );
}

/*----------------------------------------------------------------------------------------*/
/* Tastaturpuffer nach Ctrl-C absuchen																		*/
/* Funktionsresultat:	KEY_TERM bei Ctrl-C																*/
/*	tscreen:					Zeiger auf die Textschirmstruktur											*/
/*----------------------------------------------------------------------------------------*/
WORD	search_ctrl_c( TSCREEN *tscreen )
{
	WORD	i;
	
	for ( i = 0; i <= tscreen->tcnt; i++ )
	{
		if ( ( tscreen->tbuf[i] & 0xff00ffL ) == CTRL_C )
			return( KEY_TERM );
	}
	return( KEY_NO_CTRL );
}

/*----------------------------------------------------------------------------------------*/
/* Tastaturpuffer nach search absuchen und alle del davor lîschen									*/
/* Falls nîtig wird eine Eingabe abgewartet																*/
/* Funktionsresultat:	KEY_TERM bei Ctrl-C, KEY_OK bei search, sonst KEY_NO_CTRL			*/
/*	tscreen:					Zeiger auf die Textschirmstruktur											*/
/* del:						zu lîschende Tastenkombination												*/
/* search:					zu suchende Tastenkombination													*/
/*----------------------------------------------------------------------------------------*/
WORD	search_ctrl_sq( TSCREEN *tscreen, ULONG del, ULONG search )
{
	WORD	mbuf[8];
	WORD	cnt;
	ULONG	*buf;
	ULONG	key;
		
	if ( tscreen->tcnt >= 0 )											/* sind bereits Zeichen im Buffer? */
		vt_mm( mbuf );														/* Nachrichtenbuffer lîschen */
	else																		/* auf Nachricht warten */
	{
		while ( tscreen->tcnt < 0 )									/* kein Zeichen vorhanden? */
			vt_mesag( mbuf );												/* dann auf Nachricht warten */
	}
	
	while ( inc_sem( &tscreen->input ) == 0 )						/* warten, bis Zeichen ausgelesen werden kann */
		appl_yield();														/* Rechenzeit abgeben */

	if ( search_ctrl_c( tscreen ) == KEY_TERM )					/* Ctrl-C gedrÅckt? */
	{
		tscreen->input--;													/* Eingabesemaphore zurÅcksetzen */
		return( KEY_TERM );
	}

	buf = tscreen->tbuf;
	cnt = tscreen->tcnt;

	while ( cnt >= 0 )													/* noch Tasten im Puffer? */
	{
		cnt--;
		key = *buf & 0xff00ffL;
		
		if ( key == del )													/* zu lîschende Taste? */
		{
			move_tbuf( buf, cnt );										/* Taste lîschen */
			tscreen->tcnt--;												/* Anzahl dekrementieren */
		}
		else
		{
			if ( key == search )											/* gesuchte Taste? */
			{
				cnt++;
				while ( cnt >= 0 )
				{
					cnt--;
					key = *buf & 0xff00ffL;
			
					if ( key == search )									/* ÅberflÅssige Taste? */
					{
						move_tbuf( buf, cnt );							/* Taste lîschen */
						tscreen->tcnt--;									/* Anzahl dekrementieren */
					}
					else
					{
						if ( key == del )									/* begrenzende Taste? */
							break;
	
						buf++;
					}
				}				
			
				tscreen->input--;											/* Eingabesemaphore zurÅcksetzen */
				return( KEY_OK );											/* gesuchte Taste wurde gefunden */
			}
			buf++;
		}
	}

	tscreen->input--;														/* Eingabesemaphore zurÅcksetzen */
	return( KEY_NO_CTRL );												/* gesuchte Taste wurde nicht gefunden */
}

/*----------------------------------------------------------------------------------------*/
/* Fensterinhalt periodisch aktualisieren																	*/
/*----------------------------------------------------------------------------------------*/
void	redraw_timer( void )
{
	extern OBJECT 	*iconified_tree1;
	extern OBJECT 	*iconified_tree2;
	WINDOW	*window;
	GRECT g;
	OBJECT *tree;


	window = get_window_list();										/* Zeiger auf das erste Fenster */

	if ( update_window( BEG_UPDATE | update_flag ))				/* Bildschirm fÅr andere Apps sperren */
	{
		while( window )
		{
			WTSCREEN->output++;											/* Ausgabesemaphore setzen */
			if ( WTSCREEN->output == 1 )								/* Ausgabe mîglich? */
			{
			if	(window->wflags.iconified)
				{
				if	(window->dirty)
					{
					tree = window->iconified_tree+1;
					if	(tree->ob_spec.bitblk == iconified_tree1[1].ob_spec.bitblk)
						tree->ob_spec.bitblk = iconified_tree2[1].ob_spec.bitblk;
					else
						tree->ob_spec.bitblk = iconified_tree1[1].ob_spec.bitblk;
					wind_get_grect( 0, WF_WORKXYWH, &g );
					redraw_window(window->handle, &g);
					window->dirty = FALSE;
					}
				}
			else
				{
				draw_cursor( window );									/* Cursorposition aktualisieren */
				redraw_changed( window );								/* Fensterinhalt aktualisieren */
				}
			}
			WTSCREEN->output--;											/* Ausgabesemaphore zurÅcksetzen */

			window = window->next;										/* Zeiger auf die nÑchste Fensterstruktur */
		}
		update_window( END_UPDATE );									/* Bildschirm freigeben */
	}
}

/*----------------------------------------------------------------------------------------*/
/* Cursorposition aktualisieren																				*/
/*	window:					Zeiger auf die Fensterstruktur												*/
/*----------------------------------------------------------------------------------------*/
void	draw_cursor( WINDOW *window )
{
	TSCREEN *tscreen;

	tscreen = WTSCREEN;
	if ( !tscreen->cur_cnt )											/* Cursor an? */
	{
		if ( tscreen->cur_y >= 0 )										/* alter Cursor auf dem Schirm? */
			if (( tscreen->cur_y !=tscreen->y ) || ( tscreen->cur_x != tscreen->x )) 
				cursor( &tscreen->first_line[tscreen->cur_y], 0, tscreen->cur_x );	/* alten Cursor lîschen */

		cursor( &tscreen->first_line[tscreen->y], CUR_POS, tscreen->x );	/* neuen Cursor setzen */
		tscreen->cur_x = tscreen->x;
		tscreen->cur_y = tscreen->y;
	}
	else			
	{
		if ( tscreen->cur_y >= 0 )										/* alter Cursor auf dem Schirm? */
			cursor( &tscreen->first_line[tscreen->cur_y], 0, tscreen->cur_x );	/* alten Cursor lîschen */
		cursor( &tscreen->first_line[tscreen->y], 0, tscreen->x );	/* zuletzt gezeichneten Cursor lîschen */
	}
}

/*----------------------------------------------------------------------------------------*/
/* Cursorposition setzen oder lîschen																		*/
/* line_ptr:				Zeiger auf die Zeilenstruktur													*/
/* attr:						neues Cursor-Attribut ( 0 oder CUR_POS )									*/
/* x:							Cursor-Spalte																		*/
/*----------------------------------------------------------------------------------------*/
void	cursor( TPTR *line_ptr, ULONG attr, WORD x )
{
	ULONG	*pos;
	ULONG	cur;
	
	pos = &line_ptr->line[x];											/* Zeiger auf das Zeichen, Åber dem der Cursor steht */
	cur = *pos;
	
	if (( cur & CUR_POS ) == ( attr ^ CUR_POS ))					/* muû der Cursor-Zustand geÑndert werden? */
	{
		*pos = (( cur << 8 ) & 0xff000000L) | (( cur >> 8 ) & 0x00ff0000L ) | ( cur & 0xff ) | attr;
		if ( line_ptr->head == -1 )
		{
			line_ptr->head = x;											/* erste neu zu zeichnende Spalte */
			line_ptr->tail = x;											/* letzte neu zu zeichnende Spalte */
		}
		else
		{
			if ( line_ptr->tail < x )
				line_ptr->tail = x;										/* letzte neu zu zeichnende Spalte */
			if ( line_ptr->head > x )
				line_ptr->head = x;										/* erste neu zu zeichnende Spalte */
		}
	}
}

/*----------------------------------------------------------------------------------------*/
/* Fensterinhalt aktualisieren; die Maus wird nîtigenfalls ab und wieder angeschaltet		*/
/*	window:					Zeiger auf die Fensterstruktur												*/
/*----------------------------------------------------------------------------------------*/
void	redraw_changed( WINDOW *window )
{
	TSCREEN	*tscreen;
	TPTR		*line_ptr;
	GRECT		box;
	WORD		ymin,
				ymax,
				mouse_flag;


	if	(window->wflags.iconified)
		return;

	mouse_flag = M_ON;
	ymin	= 32767;
	ymax	= -32767;
	tscreen = WTSCREEN;

	get_rect( window->handle, WF_FIRSTXYWH, &box );				/* erstes Element der Rechteckliste erfragen */

	while( box.g_w && box.g_h )										/* noch gÅltige Rechtecke vorhanden? */
	{
		if ( rc_intersect( &WWORK, &box ))
		{
			VRECT		clip;
			WORD		first_index,
						last_index,
						x,
						y;

			clip = *(VRECT *) &box;
			clip.x2 += clip.x1 - 1;
			clip.y2 += clip.y1 - 1;
			vt_clip( tscreen->handle, &clip );

			if ( clip.y2 > ymax )
				ymax = clip.y2;

			x = (WORD)( box.g_x - WWORK.g_x + window->x );
			y = (WORD)( box.g_y - WWORK.g_y + window->y );

			first_index = x / tscreen->char_width;					/* Index des ersten auszugebenden Zeichens */
			last_index = ( x + box.g_w - 1 ) / tscreen->char_width;
			line_ptr = tscreen->first_line + ( y / tscreen->char_height );

			x = box.g_x - ( x % tscreen->char_width );
			y = box.g_y - ( y % tscreen->char_height );

			if ( y < ymin )
				ymin = y;

			while ( y <= clip.y2 )										/* Solange innerhalb des Fensters */
			{
				if ( line_ptr->head != -1 )							/* Zeile ausgeben? */
				{
					WORD	f, l, x2;

					mouse_off( &mouse_flag, &box );					/* Maus ausschalten */

					f = first_index;
					l = last_index;
					x2 = x;

					if ( f < line_ptr->head )
					{
						x2 += ( line_ptr->head - f ) * tscreen->char_width;
						f = line_ptr->head;
					}
					if ( l > line_ptr->tail )
						l = line_ptr->tail;

					write_string( x2, y, ( l - f + 1 ), tscreen, (line_ptr->line + f ), &no_clip );
				}
				y += tscreen->char_height;
				line_ptr++;
			}
		}
		get_rect( window->handle, WF_NEXTXYWH, &box );			/* nÑchstes Element der Rechteckliste holen */
	}

	mouse_on( &mouse_flag );											/* Maus anschalten */

	line_ptr = tscreen->first_line + ((WORD)( ymin - WWORK.g_y + window->y ) / tscreen->char_height );

	while ( ymin <= ymax )
	{
		line_ptr->head = -1;
		line_ptr->tail = -1;
		line_ptr++;
		ymin += tscreen->char_height;
	}
}

/*----------------------------------------------------------------------------------------*/
/* Zeichen Åber das Device CON ausgeben																	*/
/*	window:					Zeiger auf die Fensterstruktur												*/
/* c:							Zeichen																				*/
/*----------------------------------------------------------------------------------------*/
void	vt_jmp( WINDOW *window, UWORD c )
{
	TSCREEN	*tscreen;
	
	tscreen = WTSCREEN;
	
	tscreen->output++;													/* Ausgabesemaphore setzen */
	while ( tscreen->output != 1 )									/* warten, bis Ausgabe mîglich ist */
		appl_yield();														/* Rechenzeit abgeben */

	tscreen->vt_function( window, c );								/* Zeichen ausgeben */
	window->dirty = TRUE;
	tscreen->output--;											 		/* Ausgabesemaphore zurÅcksetzen */
}

/*----------------------------------------------------------------------------------------*/
/* Zeichen Åber das Device RAW ausgeben																	*/
/*	window:					Zeiger auf die Fensterstruktur												*/
/* c:							Zeichen																				*/
/*----------------------------------------------------------------------------------------*/
void	rawcon_jmp( WINDOW *window, UWORD c )
{
	TPTR		*line_ptr;
	TSCREEN	*tscreen;

	tscreen = WTSCREEN;
	
	tscreen->output++;													/* Ausgabesemaphore setzen */
	while ( tscreen->output != 1 )									/* warten, bis Ausgabe mîglich ist */
		appl_yield();

	line_ptr = tscreen->first_line +tscreen->y;
	*( line_ptr->line + tscreen->x ) = c | tscreen->colors;

	if (( line_ptr->head < 0 ) || ( line_ptr->head > tscreen->x ))
		line_ptr->head = tscreen->x;

	if ( line_ptr->tail < tscreen->x )
		line_ptr->tail = tscreen->x;									/* letzte zu aktualisierende Spalte */

	if ( tscreen->x < tscreen->columns )							/* noch nicht in der letzten Spalte? */
		tscreen->x++;														/* eine Spalte weiter */
	else
	{
		if ( update_window( BEG_UPDATE | update_flag ))			/* Bildschirm fÅr andere Apps sperren */
		{
			redraw_changed( window );									/* Fensterinhalt aktualisieren */
			update_window( END_UPDATE );								/* Bildschirm freigeben */
		}
		if ( tscreen->wrap )												/* Umbruch? */
		{
			tscreen->x = 0;												/* erste Spalte */
			if ( tscreen->y < tscreen->rows )
				{
				tscreen->y++;												/* nÑchste Zeile */
				tscreen->term_y++;										/* auch fÅr BIOS */
				}
			else
				scroll_up_page( window );								/* hochscrollen */
		}
	}
	tscreen->output--;													/* Ausgabesemaphore zurÅcksetzen */
}

/*----------------------------------------------------------------------------------------*/
/* Zeichen Åber das Device CON ausgeben oder Steuercodes beachten									*/
/*	window:					Zeiger auf die Fensterstruktur												*/
/* c:							Zeichen																				*/
/*----------------------------------------------------------------------------------------*/
void	vt_con( WINDOW	*window, UWORD c )
{
	if ( c >= 32 )															/* normales Zeichen oder Steuerzeichen? */
	{
		TPTR	*line_ptr;
		TSCREEN	*tscreen;

		tscreen = WTSCREEN;
		line_ptr = tscreen->first_line +tscreen->y;
		*( line_ptr->line + tscreen->x ) = c | tscreen->colors;

		if (( line_ptr->head < 0 ) || ( line_ptr->head > tscreen->x ))
			line_ptr->head = tscreen->x;

		if ( line_ptr->tail < tscreen->x )
			line_ptr->tail = tscreen->x;								/* letzte zu aktualisierende Spalte */

		if ( tscreen->x < tscreen->columns )						/* noch nicht in der letzten Spalte? */
			tscreen->x++;													/* eine Spalte weiter */
		else
		{
			if ( update_window( BEG_UPDATE | update_flag ))		/* Bildschirm fÅr andere Apps sperren */
			{
				redraw_changed( window );								/* Fensterinhalt aktualisieren */
				update_window( END_UPDATE );							/* Bildschirm freigeben */
			}
			if (tscreen->wrap )											/* Umbruch? */
			{
				tscreen->x = 0;											/* erste Spalte */
				if ( tscreen->y < tscreen->rows )
					{
					tscreen->y++;											/* nÑchste Zeile */
					tscreen->term_y++;									/* auch fÅr BIOS */
					}
				else
					scroll_up_page( window );							/* hochscrollen */
			}
		}
		
	}
	else																		/* Steuerzeichen */
	{
		if ( c == 27 )														/* Escape? */
			WTSCREEN->vt_function = vt_esc;
		else
		{
			switch ( c )
			{
				case	7:		vt_bel();			break;
				case	8:		vt_bs( window );	break;
				case	9:		vt_ht( window );	break;
				case	10:	vt_lf( window );	break;
				case	11:	vt_lf( window );	break;
				case	12:	vt_lf( window );	break;
				case	13:	vt_cr( window );	break;
			}
			WTSCREEN->vt_function = vt_con;
		}
	}
}

/* BELL */
void	vt_bel( void )
{
	Supexec( call_vt_bel );												/* "Pling" ausgeben */
}

/* BACKSPACE */
void	vt_bs( WINDOW *window )
{
	TSCREEN	*tscreen;

	tscreen = WTSCREEN;
	if ( tscreen->x > 0 )
		tscreen->x--;														/* eine Spalte zurÅck */
}

/* TAB */
void	vt_ht( WINDOW *window )
{
	TSCREEN	*tscreen;

	tscreen = WTSCREEN;
	tscreen->x = (tscreen->x & 0xfff8) + 8;						/* nÑchste Tabulatorposition */
	if ( tscreen->x > tscreen->columns )
		tscreen->x = tscreen->columns;								/* Spalte begrenzen */
}

/* LINEFEED */
void	vt_lf( WINDOW *window )
{
	TSCREEN	*tscreen;

	tscreen = WTSCREEN;

	if ( update_window( BEG_UPDATE | update_flag ))				/* Bildschirm fÅr andere Apps sperren */
	{
		redraw_changed( window );										/* Fensterinhalt aktualisieren */
		update_window( END_UPDATE );									/* Bildschirm freigeben */
	}

	if ( tscreen->y == tscreen->rows )								/* bereits in der letzten Zeile? */
		scroll_up_page( window );										/* hochscrollen */
	else
		{
		tscreen->y++;														/* nÑchste Zeile */
		tscreen->term_y++;												/* auch fÅr BIOS */
		}
}

/* RETURN */
void	vt_cr( WINDOW *window )
{
	WTSCREEN->x = 0;														/* Cursor nach links */
}

/* ESCAPE */
void	vt_esc( WINDOW *window, UWORD c )
{
	TSCREEN	*tscreen;

	tscreen = WTSCREEN;

	switch ( c )
	{
		case	'A':	vt_seq_A( tscreen );	break;	
		case	'B':	vt_seq_B( tscreen );	break;	
		case	'C':	vt_seq_C( tscreen ); break;	
		case	'D':	vt_seq_D( tscreen ); break;	
		case	'E':	vt_seq_E( tscreen ); break;	
		case	'H':	vt_seq_H( tscreen ); break;	
		case	'I':	vt_seq_I( window );	break;	
		case	'J':	vt_seq_J( tscreen ); break;	
		case	'K':	vt_seq_K( tscreen ); break;	
		case	'L':	vt_seq_L( tscreen ); break;	
		case	'M':	vt_seq_M( tscreen ); break;	
		case	'Y':	vt_seq_Y( tscreen ); break;	
		case	'b':	vt_seq_b( tscreen ); break;	
		case	'c':	vt_seq_c( tscreen ); break;	
		case	'd':	vt_seq_d( tscreen ); break;	
		case	'e':	vt_seq_e( tscreen ); break;	
		case	'f':	vt_seq_f( tscreen ); break;	
		case	'j':	vt_seq_j( tscreen ); break;	
		case	'k':	vt_seq_k( tscreen ); break;	
		case	'l':	vt_seq_l( tscreen ); break;	
		case	'o':	vt_seq_o( tscreen ); break;	
		case	'p':	vt_seq_p( tscreen ); break;	
		case	'q':	vt_seq_q( tscreen ); break;	
		case	'v':	vt_seq_v( tscreen ); break;	
		case	'w':	vt_seq_w( tscreen ); break;	
	}
	if (( c != 'Y' ) && ( c != 'b' ) && ( c != 'c' ))
		tscreen->vt_function = vt_con;

}
/* Cursor up */
void	vt_seq_A( TSCREEN *tscreen )
{
	if ( tscreen->y > ( tscreen->rows - tscreen->visible_rows ))	/* noch nicht in der obersten Zeile? */
		{
		tscreen->y--;														/* eine Zeile nach oben */
		tscreen->term_y--;												/* auch fÅr BIOS */
		}
}

/* Cursor down */
void	vt_seq_B( TSCREEN *tscreen )	
{
	if ( tscreen->y < tscreen->rows )								/* noch nicht in der untersten Zeile? */
		{
		tscreen->y++;														/* eine Zeile nach unten */
		tscreen->term_y++;												/* auch fÅr BIOS */
		}
}

/* Cursor forward */
void	vt_seq_C( TSCREEN *tscreen )
{
	if ( tscreen->x < tscreen->columns )							/* noch nicht in der letzten Spalte? */
		tscreen->x++;														/* eine Spalte nach rechts */
}

/* Cursor backward */
void	vt_seq_D( TSCREEN *tscreen )
{
	if ( tscreen->x > 0 )												/* noch nicht in der ersten Spalte? */
		tscreen->x--;														/* eine Spalte nach links */
}

/* Clear screen and home cursor */
void	vt_seq_E( TSCREEN *tscreen )
{
	vt_seq_H( tscreen );													/* Home cursor */
	vt_seq_J( tscreen );													/* Erase to end of page */
}

/* Home cursor */
void	vt_seq_H( TSCREEN *tscreen )
{
	tscreen->x = 0;														/* erste Spalte */
	tscreen->term_y = 0;													/* oberste BIOS-Zeile */
	tscreen->y = tscreen->rows - tscreen->visible_rows;		/* oberste Zeile */
}

/* Reverse index */
void	vt_seq_I( WINDOW *window )
{
	TSCREEN *tscreen;
 
 	tscreen = WTSCREEN;
 	/* im folgenden: "tscreen->term_y > 0" */
	if ( tscreen->y > ( tscreen->rows - tscreen->visible_rows ))	/* noch nicht in der obersten Zeile? */
		{
		tscreen->y--;														/* eine Zeile nach oben */
		tscreen->term_y--;												/* auch fÅr BIOS */
		}
	else
		scroll_down_page( window );									/* runterscrollen */
}

/*	Erase to end of page */
void	vt_seq_J( TSCREEN *tscreen )
{
	WORD	i,
			rows;
	TPTR	*tmp;
	
	tmp = tscreen->first_line + tscreen->y;

	rows = tscreen->rows - tscreen->y;

	if ( tscreen->x > 0 )												/* Cursor nicht in der ersten Spalte? */
	{
		vt_seq_K( tscreen );												/* bis zum Zeilenende lîschen */
		tmp++;																/* nÑchste Zeile */
		rows--;																/* ZÑhler dekrementieren */
	}
	
	while ( rows >= 0 )
	{
		tmp->head = 0;														/* erste neu zu zeichnende Spalte */
		tmp->tail = tscreen->columns;									/* letzte neu zu zeichnende Spalte */

		for ( i = 0; i <= tscreen->columns; i++ )					/* Zeile lîschen */
			tmp->line[i] = 32 | tscreen->colors;
			
		tmp++;																/* nÑchste Zeile */
		rows--;																/* ZÑhler dekrementieren */	
	}
}

/*	Clear to end of line */
void	vt_seq_K( TSCREEN *tscreen )
{
	WORD	i;
	ULONG	*tline;
	TPTR	*line_ptr;
		
	line_ptr = tscreen->first_line + tscreen->y;
	tline = line_ptr->line + tscreen->x;
	
	for( i = tscreen->x; i <= tscreen->columns; i++ )			/* bis zum Zeilenende lîschen */
		*tline++ = 32 | tscreen->colors;
	
	line_ptr->tail= tscreen->columns;								/* letzte neu zu zeichnende Spalte */
	if (( line_ptr->head > tscreen->x ) || ( line_ptr->head == -1 ))
		line_ptr->head = tscreen->x;									/* erste neu zu zeichnende Spalte */

}

/* Insert line */
void	vt_seq_L( TSCREEN *tscreen )
{
	register WORD	i;
	ULONG *last_line;
	TPTR	*tmp;

	tmp = tscreen->first_line + tscreen->rows;					/* letzte Schirmzeile */
	last_line = tmp->line;
	
	for ( i = tscreen->y; i < tscreen->rows; i++ )	
	{
		*tmp = *(tmp - 1);												/* um eine Zeile nach unten schieben */
		tmp->head = 0;														/* erste neu zu zeichnende Spalte */
		tmp->tail = tscreen->columns;									/* letzte neu zu zeichnende Spalte */
		tmp--;																/* ZÑhler dekrementieren */
	}
	
	tmp->line = last_line;
	tmp->head = 0;															/* erste neu zu zeichnende Spalte */
	tmp->tail = tscreen->columns;										/* letzte neu zu zeichnende Spalte */

	for ( i = 0; i <= tscreen->columns; i++ ) 					/* letzte Zeile lîschen */
		*last_line++ = 32 | tscreen->colors;

	tscreen->x = 0;														/* erste Spalte */
}

/* Delete line */
void	vt_seq_M( TSCREEN *tscreen )
{
	register WORD	i;
	ULONG *fline;
	TPTR	*tmp;

	tmp	= tscreen->first_line + tscreen->y;						/* Zeiger auf die zu lîschende Zeile */
	fline = tmp->line;
	
	for ( i = tscreen->y; i < tscreen->rows; i++ )
	{
		*tmp = *(tmp + 1);												/* um eine Zeile tiefer schieben */
		tmp->head = 0;														/* erste neu zu zeichnende Spalte */
		tmp->tail = tscreen->columns;									/* letzte neu zu zeichnende Spalte */
		tmp++;
	}

	tmp->line = fline;
	tmp->head = 0;															/* erste neu zu zeichnende Spalte */
	tmp->tail = tscreen->columns;										/* letzte neu zu zeichnende Spalte */

	for ( i = 0; i <= tscreen->columns; i++ ) 					/* Zeile lîschen */
		*fline++ = 32 | tscreen->colors;

	tscreen->x = 0;														/* erste Spalte */
}

/* Position cursor */
void	vt_seq_Y( TSCREEN *tscreen )
{
	tscreen->vt_function = vt_seq_Y_y;
}

/* Cursorzeile setzen */
void	vt_seq_Y_y( WINDOW *window, UWORD y )
{
	TSCREEN	*tscreen;
	
	tscreen = WTSCREEN;
	y -= 32;																	/* relative Zeile */
	
	if ( y <= tscreen->visible_rows )								/* innerhalb des sichtbaren Textschirms? */
	{
		tscreen->y = tscreen->rows - tscreen->visible_rows + y;	/* Zeile */
		tscreen->term_y = y;												/* auch fÅr BIOS */
		tscreen->vt_function = vt_seq_Y_x;
	}
	else
		tscreen->vt_function = vt_con;
}

/* Cursorspalte setzen */
void	vt_seq_Y_x( WINDOW *window, UWORD x )
{
	TSCREEN	*tscreen;
	
	tscreen = WTSCREEN;
	x -= 32;																	/*	Spalte */
	
	if ( x <= tscreen->columns )										/* innerhalb des Textschirms? */
	{
		tscreen->x = x;
	}
	tscreen->vt_function = vt_con;
}

/* Set foreground color */
void	vt_seq_b( TSCREEN *tscreen )
{
	if ( tscreen->revers )												/* invertiert? */
		tscreen->vt_function = vt_seq_c_color;						/* dann Hintergrundfarbe setzen */
	else
		tscreen->vt_function = vt_seq_b_color;						/* Vordergrundfarbe setzen */
}

/* Vordergrundfarbe eintragen */
void	vt_seq_b_color( WINDOW *window, UWORD color )
{
	WTSCREEN->colors &= 0x00ffffffL;
	WTSCREEN->colors |= ((ULONG) color_remap[color&15]) << 24;
	WTSCREEN->vt_function = vt_con;
}

/* Set background color */
void	vt_seq_c( TSCREEN *tscreen )
{
	if ( tscreen->revers )												/* invertiert? */
		tscreen->vt_function = vt_seq_b_color;						/* dann Vordergrundfarbe setzen */
	else
		tscreen->vt_function = vt_seq_c_color;						/* Hintergrundfarbe setzen */
}

/* Hintergrundfarbe eintragen */
void	vt_seq_c_color( WINDOW *window, UWORD color )
{
	WTSCREEN->colors &= 0xff00ffffL;
	WTSCREEN->colors |= ((ULONG) color_remap[color&15]) << 16;
	WTSCREEN->vt_function = vt_con;
}

/*	Erase beginning of display */
void	vt_seq_d( TSCREEN *tscreen )
{
	WORD	i,
			j,
			rows;
	TPTR	*tmp;
	
	vt_seq_o( tscreen );													/* bis zur Cursorspalte lîschen */
	
	tmp = tscreen->first_line + tscreen->rows - tscreen->visible_rows;	/* erste zu lîschende Zeile */
	rows = tscreen->y + tscreen->visible_rows - tscreen->rows;	/* Anzahl der zu lîschenden Zeilen - 1 */

	for ( i = 0; i <= rows; i++ )
	{
		tmp->head = 0;														/* erste neu zu zeichnende Spalte */
		tmp->tail = tscreen->columns;									/* letzte neu zu zeichnende Spalte */
		
		for ( j = 0; j <= tscreen->columns; j++ );
			tmp->line[j] = 32 | tscreen->colors;

		tmp++;
	}
}

/* Enable cursor */
void	vt_seq_e( TSCREEN *tscreen )
{
	if ( tscreen->cur_cnt > 0 )										/* Cursor aus? */
		tscreen->cur_cnt--;												/* dann einschalten */
}

/* Disable cursor */
void	vt_seq_f( TSCREEN *tscreen )
{
	tscreen->cur_cnt++;													/* Cursor ausschalten */
}

/* Save cursor position */
void	vt_seq_j( TSCREEN *tscreen )
{
	tscreen->save_x = tscreen->x;
	tscreen->save_y = tscreen->y;
}

/* Restore cursor position */
void	vt_seq_k( TSCREEN *tscreen )
{
	if ( tscreen->save_x != -1 )										/* Cursorposition gespeichert? */
	{
		tscreen->x = tscreen->save_x;
		tscreen->y = tscreen->save_y;
		tscreen->term_y = tscreen->y + tscreen->visible_rows - tscreen->rows;	/* auch fÅr BIOS */
		tscreen->save_x = -1;											/* Spalte nicht gespeichert */
		tscreen->save_y = -1;											/* Zeile nicht gespeichert */
	}
}

/*	Erase entire line */
void	vt_seq_l( TSCREEN *tscreen )
{
	tscreen->x = 0;														/* erste Spalte */
	vt_seq_K( tscreen );													/* bis zum Zeilenende lîschen */
}

/* Erase beginning of line */
void	vt_seq_o( TSCREEN *tscreen )
{
	WORD	i;
	ULONG	*tline;
	TPTR	*line_ptr;
		
	if ( tscreen->x > 0 )
	{
		line_ptr = tscreen->first_line + tscreen->y;				/* aktuelle Zeile */
		tline = line_ptr->line;
	
		for( i = 0; i < tscreen->x; i++ )							/* bis zur Cursorspalte lîschen */
			*tline++ = 32 | tscreen->colors;
	
		line_ptr->head = 0;												/* erste neu zu zeichnende Spalte */
		if ( line_ptr->tail < tscreen->x )
			line_ptr->tail = tscreen->x - 1;							/* letzte neu zu zeichnende Spalte */
	}
}

/* Enter reverse video mode */
void	vt_seq_p( TSCREEN *tscreen )
{
	if ( tscreen->revers == 0 )										/* noch nicht invertiert? */
		tscreen->colors = (( tscreen->colors << 8 ) & 0xff000000L )
							 | (( tscreen->colors >> 8 ) & 0x00ff0000L );	/* Farben tauschen */

	tscreen->revers = 1;													/* invertiert */
}

/* Exit reverse video mode */
void	vt_seq_q( TSCREEN *tscreen )
{
	if ( tscreen->revers == 1 )										/* invertiert? */
		tscreen->colors = (( tscreen->colors << 8 ) & 0xff000000L )
							 | (( tscreen->colors >> 8 ) & 0x00ff0000L );	/* Farben tauschen */

	tscreen->revers = 0;													/* nicht invertiert */
}

/*	Wrap at end of line */
void	vt_seq_v( TSCREEN *tscreen )
{
	tscreen->wrap = 1;													/* Umbruch */
}

/* Discard at end of line */
void	vt_seq_w( TSCREEN *tscreen )
{
	tscreen->wrap = 0;													/* kein Umbruch */
}

/*----------------------------------------------------------------------------------------*/
/* Um eine Zeile nach oben scrollen																			*/
/*	window:					Zeiger auf die Fensterstruktur												*/
/*----------------------------------------------------------------------------------------*/
void	scroll_up_page( WINDOW *window )
{
	WORD	i;
	ULONG *fline;
	TPTR	*tmp;
	TSCREEN	*tscreen;
	
	tscreen = WTSCREEN;
	if ( tscreen->cur_y > 0 )
		tscreen->cur_y--;
	fline = tscreen->first_line->line;
	
	tmp	= tscreen->first_line;
	
	for ( i = 0; i < tscreen->rows; i++ )
	{
		*tmp = *(tmp + 1);												/* um eine Zeile nach oben */
		tmp++;																/* nÑchste Zeile */
	}

	tmp->line = fline;
	tmp->head = -1;
	tmp->tail = -1;

	for ( i = 0; i <= tscreen->columns; i++ ) 					/* letzte Zeile lîschen */
		*fline++ = 32 | tscreen->colors;		

	if ( !(window->wflags.iconified) && update_window( BEG_UPDATE | update_flag ))				/* Bildschirm fÅr andere Apps sperren */
	{
		GRECT	box,
				desk;
		MFDB	src,
				dst;
		VRECT	rect[2];
		WORD	mouse_flag;
		
		mouse_flag = M_ON;

		get_rect( 0, WF_WORKXYWH, &desk );							/* Grîûe des Hintergrunds erfragen */
		get_rect( window->handle, WF_FIRSTXYWH, &box );			/* erstes Element der Rechteckliste erfragen */

		while ( box.g_w && box.g_h )									/* Ende der Rechteckliste? */
		{
			if ( rc_intersect( &desk, &box ))
			{
				if( rc_intersect( &window->workarea, &box ) )	
				{			
					mouse_off( &mouse_flag, &box );					/* Maus ausschalten */
			
					if ( window->dy < box.g_h )						/* kann der Bereich verschoben werden? */
					{
						src.fd_addr = 0L;
						dst.fd_addr = 0L;
					
						*(GRECT *)rect = box;
						rect[0].x2 += box.g_x - 1;
						rect[0].y2 += box.g_y - 1;
		
						vt_clip( tscreen->handle, rect );
					
						rect[1] = rect[0];
						rect[0].y1 += window->dy;
						rect[1].y2 -= window->dy;
					
						vt_cpyfm( tscreen->handle, rect, &src, &dst );
						
						box.g_y += box.g_h - window->dy;
						box.g_h = window->dy;
					}
					redraw( window, &box );								/* unterste Zeile neu zeichnen */
				}	
			}
			get_rect( window->handle, WF_NEXTXYWH, &box );		/* nÑchstes Element der Rechteckliste holen */
		}
		
		mouse_on( &mouse_flag );										/* Maus anschalten */

		update_window( END_UPDATE );									/* Bildschirm freigeben */
	}
	else																		/* Ausgabe ist nicht mîglich */
	{
		tmp = tscreen->first_line;
	  	for ( i = 0; i <= tscreen->rows; i++ )
		{
			tmp->head = 0;													/* erste neu zu zeichnende Spalte */
			tmp->tail = tscreen->columns;								/* letzte neu zu zeichnende Spalte */
			tmp++;															/* nÑchste Zeile */
		}
	}
}

/*----------------------------------------------------------------------------------------*/
/* Um eine Zeile nach unten scrollen																		*/
/*	window:					Zeiger auf die Fensterstruktur												*/
/*----------------------------------------------------------------------------------------*/
void  scroll_down_page( WINDOW *window )
{
	WORD	i;
	ULONG *last_line;
	TPTR	*tmp;
	TSCREEN	*tscreen;
	
	tscreen = WTSCREEN;
	if ( tscreen->cur_y < tscreen->rows )
		tscreen->cur_y++;
	tmp	= tscreen->first_line + tscreen->rows;
	last_line = tmp->line;
	
	for ( i = 0; i < tscreen->visible_rows; i++ )
	{
		*tmp = *(tmp - 1);												/* um eine Zeile nach unten verschieben */
		tmp--;																/* nÑchste Zeile */
	}

	tmp->line = last_line;
	tmp->head = -1;
	tmp->tail = -1;

	for ( i = 0; i <= tscreen->columns; i++ ) 					/* erste Zeile lîschen */
		*last_line++ = 32 | tscreen->colors;
		
	if ( !(window->wflags.iconified) && update_window( BEG_UPDATE | update_flag ))				/* Bildschirm fÅr andere Apps sperren */
	{	
		GRECT	box,
				desk;
		MFDB	src,
				dst;
		VRECT	rect[2];
		WORD	mouse_flag;
		
		mouse_flag = M_ON;

		get_rect( 0, WF_WORKXYWH, &desk );							/* Grîûe des Hintergrunds erfragen */
		get_rect( window->handle, WF_FIRSTXYWH, &box );			/* erstes Element der Rechteckliste erfragen */

		while ( box.g_w && box.g_h )									/* Ende der Rechteckliste? */
		{
			if ( rc_intersect( &desk, &box ))
			{
				if ( rc_intersect( &window->workarea, &box ))	
				{			
					mouse_off( &mouse_flag, &box );					/* Maus ausschalten */

					if ( window->dy < box.g_h )						/* kann der Bereich verschoben werden? */
					{
						src.fd_addr = 0L;
						dst.fd_addr = 0L;
					
						*(GRECT *)rect = box;
						rect[0].x2 += box.g_x - 1;
						rect[0].y2 += box.g_y - 1;
		
						vt_clip( tscreen->handle, rect );
					
						rect[1] = rect[0];
						rect[0].y2 -= window->dy;
						rect[1].y1 += window->dy;
					
						vt_cpyfm( tscreen->handle, rect, &src, &dst );
						
						box.g_h = window->dy;
					}
					redraw( window, &box );								/* oberste Zeile neu zeichnen */
				}	
			}
			get_rect( window->handle, WF_NEXTXYWH, &box );		/* nÑchstes Element der Rechteckliste holen */
		}		
		mouse_on( &mouse_flag );										/* Maus anschalten */
			
		update_window( END_UPDATE );									/* Bildschirm freigeben */
	}
	else																		/* Ausgabe ist nicht mîglich */
	{
		tmp	= tscreen->first_line + tscreen->rows - tscreen->visible_rows;
		 for ( i = 0; i <= tscreen->visible_rows; i++ )
		 {
			tmp->head = 0;													/* erste neu zu zeichnende Spalte */
			tmp->tail = tscreen->columns;								/* letzte neu zu zeichnende Spalte */
			tmp++;															/* nÑchste Zeile */
		}
	}
}

/*----------------------------------------------------------------------------------------*/
/* Fensterbereich neuzeichnen																					*/
/*	window:					Zeiger auf die Fensterstruktur												*/
/*	area:						Zeiger auf ein GRECT des zu zeichnenden Bereichs						*/
/*----------------------------------------------------------------------------------------*/
void	redraw(	WINDOW *window, GRECT *area )
{
	WORD	line_count,
			first_index,
			char_count;
	TPTR	*line_ptr;
	VRECT	xy;
	WORD	x,y;
	TSCREEN	*tscreen;
	
	tscreen = WTSCREEN;
	
	xy = *(VRECT *) area;
	xy.x2 += xy.x1 - 1;
	xy.y2 += xy.y1 - 1;
	vt_clip( tscreen->handle, &xy );									/* Clipping setzen */
	
	x = (WORD) ( area->g_x - window->workarea.g_x + window->x );
	y = (WORD) ( area->g_y - window->workarea.g_y + window->y );

	line_count = y / tscreen->char_height;							/* Index der ersten auszugebenden Zeile */
	line_ptr = tscreen->first_line + line_count;					/* Zeiger auf die erste auszugebenden Zeile */
	line_count = ( y + area->g_h - 1 ) / tscreen->char_height - line_count + 1;

	first_index = x / tscreen->char_width;							/* Index des ersten auszugebenden Zeichens */
	char_count = ( x + area->g_w - 1 ) / tscreen->char_width;
	if ( char_count > tscreen->columns )
		char_count = tscreen->columns;
		
	char_count -= first_index -1;										/* Anzahl der auszugebenden Zeichen */
	
	x = xy.x1 - ( x % tscreen->char_width );
	y = xy.y1 - ( y % tscreen->char_height );

	while ( line_count )
	{
		write_string( x, y, char_count, tscreen, (line_ptr->line + first_index ), &no_clip );

		y += tscreen->char_height;										/* nÑchste Zeile */
		line_ptr++;															/* nÑchste Zeile */
		line_count--;
	}
}

/*----------------------------------------------------------------------------------------*/
/* VT52-String ausgeben																							*/
/* Wenn clip->g_w kleiner oder gleich 0 ist, wird das Clipping nicht eingeschaltet.			*/
/* x,y:						Startkoordinaten des Strings													*/
/* count:					Anzahl der Zeichen (von 1 aus gezÑhlt)										*/
/*	tscreen:					Zeiger auf VT52-Struktur														*/
/* line:						Zeiger auf VT52-String															*/
/*	clip:						Zeiger auf ein GRECT mit den Clipping-Koordinaten						*/
/*----------------------------------------------------------------------------------------*/
void	write_string( WORD x, WORD y, WORD count, TSCREEN *tscreen, ULONG *line, GRECT *clip )
{
	WORD	string[MAX_COLUMNS];
	WORD	*str_ptr;
	UWORD	cmp;
	VRECT	xy;

	if ( clip->g_w > 0 )	/* Clipping eingeschalten? */
	{
		xy = *(VRECT *) clip;
		xy.x2 += xy.x1 - 1;
		xy.y2 += xy.y1 - 1;
	
		vt_clip( tscreen->handle, &xy );
	}

	xy.y1 = y;
	xy.x2 = x - 1;
	xy.y2 = y + tscreen->char_height - 1;
	
	while ( count > 0 )
	{
		cmp = *(UWORD *)line;											/* Farben des ersten Zeichens */

		str_ptr = string;
		
		while ( count && (*(UWORD *)line == cmp ))				/* gleiche Zeichenfarbe? */
		{
			*str_ptr++ = ((WORD) *line++ ) & 0xff;					/* Zeichen in den Ausgabestring kopieren */
			count--;
		} 

		xy.x1 = xy.x2 + 1;												/* Startkoordinate */
		xy.x2 += ((WORD) ( str_ptr- string )) * tscreen->char_width;	/* Endkoordinate */
		
		vt_wrmode( tscreen->handle, MD_REPLACE );			

		if ( cmp & 0xff )													/* Hintergrundfarbe nicht weiû? */
		{
			vt_fcolor( tscreen->handle, cmp & 0xff );
			vt_finterior( tscreen->handle, FIS_SOLID );
			vt_rect( tscreen->handle, &xy );							/* Rechteck in der Hintergrundfarbe	zeichnen */
			vt_wrmode( tscreen->handle, MD_TRANS );
		}
		vt_tcolor( tscreen->handle, cmp >> 8 );					/* Text in der Vordergrundfarbe */
	
		{
			WORD	*pb[5];
			WORD	contrl[15];
			WORD	intout[1];
			WORD	ptsin[2];
			WORD	ptsout[1];

			pb[0] = contrl;
			pb[1] = string;
			pb[2] = ptsin;
			pb[3] = intout;
			pb[4] = ptsout;

			contrl[0] = 8;													/* v_gtext() */
			contrl[1] = 1;
			contrl[3] = (WORD) ( str_ptr - string );				/* Zeichenanzahl */
			contrl[6] = tscreen->handle;								/* VDI-Handle */
			ptsin[0] = xy.x1;
			ptsin[1] = xy.y1;
	
			vt_vdi( (VDIPB *) pb );										/* VDI aufrufen */

		}
	}
}

/*----------------------------------------------------------------------------------------*/
/* Struktur fÅr Textbildschirm anlegen																		*/
/* Funktionsresultat:	Zeiger auf Struktur																*/
/* columns:					Anzahl der Spalten																*/
/* rows:						Anzahl der Zeilen																	*/
/* buffer_rows:			Anzahl der zusÑtzlichen Zeilen zum ZurÅckscrollen						*/
/* font:						Nummer des einzustellenden Zeichensatzes									*/
/* point:					Hîhe in Punkten																	*/
/*----------------------------------------------------------------------------------------*/
TSCREEN	*open_vt( WORD	columns, WORD rows, WORD buffer_rows, WORD font, WORD point )
{
	TSCREEN	*tscreen;
	ULONG		size;
	
	size = sizeof( TSCREEN ) + ( rows + buffer_rows ) * ( sizeof( TPTR ) + ( columns * sizeof( ULONG )));
	
	if (( tscreen = malloc( size )) != 0 )
	{
		WORD	work_in[11],
				work_out[57],
				i;
			
		for( i = 1; i < 10 ; work_in[i++] = 1 );					/* work_in initialisieren */
		work_in[0] = Getrez() + 2;										/* Auflîsung */
		work_in[10] = 2;													/* Rasterkoordinaten benutzen */
		tscreen->handle = graf_handle( &i, &i, &i, &i );
		v_opnvwk( work_in, &tscreen->handle, work_out );

		if ( tscreen->handle )
		{
			TPTR	*line_ptr;
			ULONG	*line;
			
			vst_load_fonts( tscreen->handle, 0 );
			
			line_ptr = (TPTR *) (tscreen + 1);
			line = (ULONG *) ( line_ptr + rows + buffer_rows );

			tscreen->refcnt = 0;
			tscreen->child_id = 0;										/* Nummer der TOS-Applikation */
			tscreen->parent_id = 0;										/* Nummer der Vater-Applikation */
			tscreen->input = 0;											/* Semaphore fÅr Ausgaben */
			tscreen->output = 0;										 	/* Semaphore fÅr Eingaben */
			
			tscreen->term = 0; 											/* Flag fÅrs Beenden	 */
			
			tscreen->name[0] = 0;										/* Programmpfad */
			
			vst_alignment( tscreen->handle, 0, 5, &dummy, &dummy );	/* linksbÅndig an der Zeichenoberkante ausrichten */
			tscreen->font_id = vst_font( tscreen->handle, font );	/* Nummer des Zeichensatzes */
			tscreen->point_size = vst_point( tscreen->handle, point,	&dummy, &dummy,
														&tscreen->char_width, &tscreen->char_height );	/* Hîhe in Punkten */
			vqt_width( tscreen->handle, SPACE, &tscreen->char_width, &dummy, &dummy );		/* zusÑtzliche Abfrage fÅr FSM */
			
			tscreen->columns = columns - 1;							/* Anzahl der Spalten - 1 */
			tscreen->rows = rows + buffer_rows - 1;				/* Anzahl der Zeilen	- 1 */
			tscreen->visible_rows = rows -1;							/* Anzahl der vom Benutzer vorgebenen Zeilen	- 1 */
	
			tscreen->cur_cnt = 0;										/* Cursor an */
			tscreen->cur_x = 0;											/* zuletzt gezeichnete Cursor-Spalte (von 0 aus)*/
			tscreen->cur_y = buffer_rows;								/* zuletzt gezeichnete Cursor-Zeile (von 0 aus) */
			tscreen->save_x = -1;										/* keine gespeicherte Spalte */
			tscreen->save_y = -1;										/* keine gespeicherte Zeile */
	
			tscreen->wrap = 1;											/* Zeilenumbruch */
			tscreen->revers = 0;											/* Vorder- und Hintergrund normal */
		
			tscreen->colors = 0x01000000L;							/* Vordergrundfarbe schwarz, Hintergrundfarbe weiû */
	
			tscreen->x = 0;												/* aktuelle Spalte (von 0 aus) */
			tscreen->y = buffer_rows;									/* aktuelle Zeile (von 0 aus) */
			tscreen->term_y = tscreen->y + tscreen->visible_rows - tscreen->rows;	/* auch fÅr BIOS */
 
			tscreen->vt_function = vt_con;							/* Funktion fÅr Console-Ausgabe */
		
			tscreen->tcnt = -1;											/* Eingabepuffer ist leer */
		
			tscreen->first_line = line_ptr;							/*	Zeiger auf die erste Textzeile */
		
			for ( rows += buffer_rows; rows > 0; rows-- )
			{
				line_ptr->head = 0;										/* erste zu zeichnende Spalte */
				line_ptr->tail = columns -1;							/* letzte zu zeichnende Spalte */
				line_ptr->line = line;						
				line_ptr++;
	
				for ( i = columns; i > 0; i-- )
					*line++ = 0x01000020L;								/* Zeile lîschen, Vordergrundfarbe schwarz, Hintergrundfarbe weiû */
			}
		}
		else
		{
			free( tscreen );	
			tscreen = 0L;
		}
	}
	return( tscreen );
}

/*----------------------------------------------------------------------------------------*/
/* Struktur fÅr Textbildschirm freigeben																	*/
/* tscreen:					Zeiger auf Struktur																*/
/*----------------------------------------------------------------------------------------*/
void	close_vt( TSCREEN *tscreen )
{
	if ( tscreen )
	{
		vst_unload_fonts( tscreen->handle, 0 );
		v_clsvwk( tscreen->handle );
		free( tscreen );
	}
}

/*----------------------------------------------------------------------------------------*/
/* VDI-Schreibmodus einstellen																				*/
/* handle:					VDI-Handle																			*/
/*	mode:						Schreibmodus																		*/
/*----------------------------------------------------------------------------------------*/
void	vt_wrmode( WORD handle, WORD mode )
{
	WORD	*pb[5];
	WORD	contrl[15];
	WORD	intin[1];
	WORD	intout[1];
	WORD	ptsin[1];
	WORD	ptsout[1];

	pb[0] = contrl;
	pb[1] = intin;
	pb[2] = ptsin;
	pb[3] = intout;
	pb[4] = ptsout;
	
	contrl[0] = 32;
	contrl[1] = 0;
	contrl[3] = 1;
	contrl[6] = handle;
	intin[0] = mode;

	vt_vdi( (VDIPB *) pb );	
}

/*----------------------------------------------------------------------------------------*/
/* VDI-Textfarbe einstellen																					*/
/* handle:					VDI-Handle																			*/
/*	color:					Textfarbe																			*/
/*----------------------------------------------------------------------------------------*/
void	vt_tcolor( WORD handle, WORD color )
{
	WORD	*pb[5];
	WORD	contrl[15];
	WORD	intin[1];
	WORD	intout[1];
	WORD	ptsin[1];
	WORD	ptsout[1];

	pb[0] = contrl;
	pb[1] = intin;
	pb[2] = ptsin;
	pb[3] = intout;
	pb[4] = ptsout;
	
	contrl[0] = 22;
	contrl[1] = 0;
	contrl[3] = 1;
	contrl[6] = handle;
	intin[0] = color;

	vt_vdi( (VDIPB *) pb );	
}

/*----------------------------------------------------------------------------------------*/
/* VDI-Musterfarbe einstellen																					*/
/* handle:					VDI-Handle																			*/
/*	color:					Musterfarbe																			*/
/*----------------------------------------------------------------------------------------*/
void	vt_fcolor( WORD handle, WORD color )
{
	WORD	*pb[5];
	WORD	contrl[15];
	WORD	intin[1];
	WORD	intout[1];
	WORD	ptsin[1];
	WORD	ptsout[1];

	pb[0] = contrl;
	pb[1] = intin;
	pb[2] = ptsin;
	pb[3] = intout;
	pb[4] = ptsout;
	
	contrl[0] = 25;
	contrl[1] = 0;
	contrl[3] = 1;
	contrl[6] = handle;
	intin[0] = color;

	vt_vdi( (VDIPB *) pb );	
}

/*----------------------------------------------------------------------------------------*/
/* VDI-Musterart einstellen																					*/
/* handle:					VDI-Handle																			*/
/*	interior:				Musterart																			*/
/*----------------------------------------------------------------------------------------*/
void	vt_finterior( WORD handle, WORD interior )
{
	WORD	*pb[5];
	WORD	contrl[15];
	WORD	intin[1];
	WORD	intout[1];
	WORD	ptsin[1];
	WORD	ptsout[1];

	pb[0] = contrl;
	pb[1] = intin;
	pb[2] = ptsin;
	pb[3] = intout;
	pb[4] = ptsout;
	
	contrl[0] = 23;
	contrl[1] = 0;
	contrl[3] = 1;
	contrl[6] = handle;
	intin[0] = interior;

	vt_vdi( (VDIPB *) pb );	
}

/*----------------------------------------------------------------------------------------*/
/* VDI-Clipping einstellen																						*/
/* handle:					VDI-Handle																			*/
/*	xy:						Zeiger auf ein VRECT																*/
/*----------------------------------------------------------------------------------------*/
void	vt_clip( WORD handle, VRECT *xy )
{
	WORD	*pb[5];
	WORD	contrl[15];
	WORD	intin[1];
	WORD	intout[1];
	WORD	ptsin[4];
	WORD	ptsout[1];

	pb[0] = contrl;
	pb[1] = intin;
	pb[2] = ptsin;
	pb[3] = intout;
	pb[4] = ptsout;
	
	contrl[0] = 129;
	contrl[1] = 2;
	contrl[3] = 1;
	contrl[6] = handle;
	intin[0] = 1;
	*(VRECT *) ptsin = *xy;

	vt_vdi( (VDIPB *) pb );	
}

/*----------------------------------------------------------------------------------------*/
/* VDI-Rechteck zeichnen																						*/
/* handle:					VDI-Handle																			*/
/*	xy:						Zeiger auf ein VRECT																*/
/*----------------------------------------------------------------------------------------*/
void	vt_rect( WORD handle, VRECT *xy )
{
	WORD	*pb[5];
	WORD	contrl[15];
	WORD	intin[1];
	WORD	intout[1];
	WORD	ptsin[4];
	WORD	ptsout[1];

	pb[0] = contrl;
	pb[1] = intin;
	pb[2] = ptsin;
	pb[3] = intout;
	pb[4] = ptsout;
	
	contrl[0] = 114;
	contrl[1] = 2;
	contrl[3] = 0;
	contrl[6] = handle;
	*(VRECT *) ptsin = *xy;

	vt_vdi( (VDIPB *) pb );	
}

/*----------------------------------------------------------------------------------------*/
/* Bildbereich verschieben																						*/
/* handle:					VDI-Handle																			*/
/*	xy:						Zeiger auf zwei VRECTs mit Quell- und Zielkoordinaten					*/
/* src:						Zeiger auf den Quell-MFDB														*/
/* des:						Zeiger auf den Ziel-MFDB														*/
/*----------------------------------------------------------------------------------------*/
void	vt_cpyfm( WORD handle, VRECT *xy, MFDB *src, MFDB *des )
{
	WORD	*pb[5];
	WORD	contrl[15];
	WORD	intin[1];
	WORD	intout[1];
	WORD	ptsin[8];
	WORD	ptsout[1];

	pb[0] = contrl;
	pb[1] = intin;
	pb[2] = ptsin;
	pb[3] = intout;
	pb[4] = ptsout;
	
	contrl[0] = 109;
	contrl[1] = 4;
	contrl[3] = 1;
	contrl[6] = handle;
	*(MFDB **) &contrl[7] = src;
	*(MFDB **) &contrl[9] = des;
	intin[0] = 3;
	*(VRECT *) ptsin = *xy;
	*((VRECT *) &ptsin[4]) = *(xy + 1);

	vt_vdi( (VDIPB *) pb );	
}

/*----------------------------------------------------------------------------------------*/
/* Auf eine AES-Nachricht warten																				*/
/* mbuf:						Zeiger auf den Nachrichtenbuffer												*/
/*----------------------------------------------------------------------------------------*/
void	vt_mesag( WORD *mbuf )
{
	WORD	*pb[6];
	WORD	contrl[5];
	WORD	intin[16];
	WORD	intout[8];
	void	*addrin[2];
	void	*addrout[1];
	
	pb[0] = contrl;
	pb[1] = global;
	pb[2] = intin;
	pb[3] = intout;
	pb[4] = (WORD *) addrin;
	pb[5] = (WORD *) addrout;
	
	contrl[0] = 23;
	contrl[1] = 0;
	contrl[3] = 1;

	addrin[0] = mbuf;
	vt_aes( (AESPB *) pb );
}

/*----------------------------------------------------------------------------------------*/
/* Auf eine AES-Nachricht warten																				*/
/* mbuf:						Zeiger auf den Nachrichtenbuffer												*/
/*----------------------------------------------------------------------------------------*/
void	vt_mm( WORD *mbuf )
{
	WORD	*pb[6];
	WORD	contrl[5];
	WORD	intin[16];
	WORD	intout[8];
	void	*addrin[2];
	void	*addrout[1];
	
	pb[0] = contrl;
	pb[1] = global;
	pb[2] = intin;
	pb[3] = intout;
	pb[4] = (WORD *) addrin;
	pb[5] = (WORD *) addrout;
	
	intin[0] = -1;
	intin[1] = 16;
	
	addrin[0] = mbuf;
	
	contrl[0] = 11;
	contrl[1] = 2;
	contrl[3] = 1;

	vt_aes( (AESPB *) pb );
}

void	mouse_on( WORD *flag )
{
	if ( *flag == M_OFF )												/* ist die Maus ausgeschaltet? */
	{
		*flag = M_ON;
		switch_mouse( M_ON );
	}
}

void	mouse_off( WORD *flag, GRECT *box )
{
	if ( *flag == M_ON )													/* ist die Maus sichtbar? */
	{
		EVNTDATA	mouse;
		GRECT		mouse_rect;

		graf_mkstate( &mouse.x, &mouse.y, &mouse.bstate, &mouse.kstate );
		mouse_rect.g_x = mouse.x - 50;
		mouse_rect.g_y = mouse.y - 50;
		mouse_rect.g_w = 100;
		mouse_rect.g_h = 100;

		if ( rc_intersect( box, &mouse_rect ))						/* befindet sich die Maus im Bereich des Rechtecks? */
		{
			*flag = M_OFF;
			switch_mouse( M_OFF );
		}
	}
}

/*----------------------------------------------------------------------------------------*/
/* Maus an- bzw. ausschalten																					*/
/* mform:					Opcode																				*/
/*----------------------------------------------------------------------------------------*/
void	switch_mouse( WORD mform )
{
	WORD	*pb[6];
	WORD	contrl[5];
	WORD	intin[2];
	WORD	intout[8];
	void	*addrin[2];
	void	*addrout[1];
	
	pb[0] = contrl;
	pb[1] = global;
	pb[2] = intin;
	pb[3] = intout;
	pb[4] = (WORD *) addrin;
	pb[5] = (WORD *) addrout;
	
	contrl[0] = 78;
	contrl[1] = 1;
	contrl[3] = 1;

	intin[0] = mform;
	addrin[0] = 0L;

	vt_aes( (AESPB *) pb );
}

/*----------------------------------------------------------------------------------------*/
/* Rechteck aus der Fensterliste abfragen																	*/
/* handle:					Fensterhandle																		*/
/* info:						Opcode																				*/
/* box:						Zeiger auf GRECT																	*/
/*----------------------------------------------------------------------------------------*/
void	get_rect( WORD handle, WORD info, GRECT *box )
{
	WORD	*pb[6];
	WORD	contrl[5];
	WORD	intin[2];
	WORD	intout[8];
	void	*addrin[2];
	void	*addrout[1];
	
	pb[0] = contrl;
	pb[1] = global;
	pb[2] = intin;
	pb[3] = intout;
	pb[4] = (WORD *) addrin;
	pb[5] = (WORD *) addrout;
	
	contrl[0] = 104;
	contrl[1] = 2;
	contrl[3] = 0;

	intin[0] = handle;
	intin[1] = info;

	vt_aes( (AESPB *) pb );
	
	*box = *(GRECT *) &intout[1];

}

/*----------------------------------------------------------------------------------------*/
/* oberstes Fenster erfragen																					*/
/* Funktionsresultat:	Handle des Fensters																*/
/*----------------------------------------------------------------------------------------*/
WORD	get_top( void )
{
	WORD	*pb[6];
	WORD	contrl[5];
	WORD	intin[2];
	WORD	intout[8];
	void	*addrin[2];
	void	*addrout[1];
	
	pb[0] = contrl;
	pb[1] = global;
	pb[2] = intin;
	pb[3] = intout;
	pb[4] = (WORD *) addrin;
	pb[5] = (WORD *) addrout;
	
	contrl[0] = 104;
	contrl[1] = 2;
	contrl[3] = 0;

	intin[0] = 0;
	intin[1] = WF_TOP;
	
	vt_aes( (AESPB *) pb );
	
	if ( intout[1] != -2 )
		return( intout[1] );
	else
		return( intout[4] );
}

/*----------------------------------------------------------------------------------------*/
/* Eigner eines Fensters erfragen																			*/
/* Funktionsresultat:	Applikationsnummer																*/
/* handle:					Fensternummer																		*/
/*----------------------------------------------------------------------------------------*/
WORD	get_owner( WORD handle )
{
	WORD	*pb[6];
	WORD	contrl[5];
	WORD	intin[2];
	WORD	intout[8];
	void	*addrin[2];
	void	*addrout[1];
	
	pb[0] = contrl;
	pb[1] = global;
	pb[2] = intin;
	pb[3] = intout;
	pb[4] = (WORD *) addrin;
	pb[5] = (WORD *) addrout;
	
	contrl[0] = 104;
	contrl[1] = 2;
	contrl[3] = 0;

	intin[0] = handle;
	intin[1] = WF_OWNER;
	
	vt_aes( (AESPB *) pb );
	
	return( intout[1] );
}

/*----------------------------------------------------------------------------------------*/
/* Schirm sperren																									*/
/* beg_update:				Opcode																				*/
/*----------------------------------------------------------------------------------------*/
WORD	update_window( WORD beg_update )
{
	WORD	*pb[6];
	WORD	contrl[5];
	WORD	intin[2];
	WORD	intout[8];
	void	*addrin[2];
	void	*addrout[1];
	
	pb[0] = contrl;
	pb[1] = global;
	pb[2] = intin;
	pb[3] = intout;
	pb[4] = (WORD *) addrin;
	pb[5] = (WORD *) addrout;
	
	contrl[0] = 107;
	contrl[1] = 1;
	contrl[3] = 0;

	intin[0] = beg_update;
	
	vt_aes( (AESPB *) pb );
	
	return( intout[0] );
}
