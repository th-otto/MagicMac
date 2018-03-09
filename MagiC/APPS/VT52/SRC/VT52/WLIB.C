/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*
*/

/*----------------------------------------------------------------------------------------*/
/* Globale Includes																								*/
/*----------------------------------------------------------------------------------------*/
#include "types2b.h"
#include <MGX_DOS.H> 
#include	<MT_AES.H>
#include <VDI.H>
#include	"VDICOL.H"														/* VDI-Farbfunktionen */
#include	<STRING.H>
#include	<STDDEF.H>
#include <STDLIB.H>


/*----------------------------------------------------------------------------------------*/
/* Lokale Includes																								*/
/*----------------------------------------------------------------------------------------*/
#include "WSTRUCT.H"														/*	Fensterstuktur */
#include "WLIB.H"															/*	Funktionsprototypen */

#include	"LIST.H"

/*----------------------------------------------------------------------------------------*/
/* Defines                                                                                */
/*----------------------------------------------------------------------------------------*/
#define	max( A,B ) ( (A)>(B) ? (A) : (B) )
#define	min( A,B ) ( (A)<(B) ? (A) : (B) )
#define	ABS( a )	(( a ) < 0 ? -( a ) : ( a ))
#define	WWORK window->workarea

/*----------------------------------------------------------------------------------------*/
/* Globale Variablen                                                                      */
/*----------------------------------------------------------------------------------------*/
static WORD	app_id;
static WORD	vdi_handle;
static WORD	work_out[57];
			
static WINDOW	*window_list;

/*----------------------------------------------------------------------------------------*/
static void	scroll_horizontal( WINDOW *window, WORD dx );
static void	scroll_vertical( WINDOW *window, WORD dy );

/*----------------------------------------------------------------------------------------*/
/* Library initialisieren																						*/
/* Funktionsergebnis:	0: Fehler 1: alles in Ordnung													*/
/* id:						AES-Programm-ID																	*/
/*----------------------------------------------------------------------------------------*/
WORD init_wlib( WORD id )
{
	WORD	work_in[11];
	WORD	i;
			
	app_id = id;															/* AES-Programm-ID */
	window_list = 0L;

	for ( i = 1; i < 10 ; i++ )
		work_in[i] = 1;

	work_in[0] = Getrez() + 2;											/* Auflîsung */
	work_in[10] = 2;														/* Rasterkoordinaten benutzen */

	vdi_handle = graf_handle( &i, &i, &i, &i );
	v_opnvwk( work_in, &vdi_handle, work_out );
	
	if ( vdi_handle > 0 )
		return( 1 );
	else
		return( 0 );
}

/*----------------------------------------------------------------------------------------*/
/* Library zurÅcksetzen																							*/
/* Funktionsergebnis:	0: Fehler 1: alles in Ordnung													*/
/*----------------------------------------------------------------------------------------*/
WORD reset_wlib( void )
{
	while ( window_list )
		delete_window( window_list->handle );						/* Fenster lîschen */

	v_clsvwk( vdi_handle );												/* Workstation schlieûen */
	
	return( 1 );
}

/*----------------------------------------------------------------------------------------*/
/* Zeiger auf die Fensterliste zurÅckliefern																*/
/* Funktionsergebnis:	Zeiger auf das erste Fenster oder 0											*/
/*----------------------------------------------------------------------------------------*/
WINDOW	*get_window_list( void )
{
	return( window_list );												/* Zeiger auf das erste Element der Fensterliste */
}

/*----------------------------------------------------------------------------------------*/
/* Fenster beim AES anmelden, aber nicht zeichnen                                         */
/* Funktionsresultat:	Zeiger auf eine WINDOW-Struktur oder 0L bei Fehlern					*/
/* kind:						Fenster-Elemente																	*/
/* border:					Zeiger auf ein GRECT mit den maximalen Ñuûeren Fenstermaûen			*/
/*	handle:					Zeiger auf das Fensterhandle (bei Fehler < 0)							*/
/* name:						Zeiger auf den Fensternamen oder 0L											*/
/*----------------------------------------------------------------------------------------*/
WINDOW *create_window( WORD kind,
					GRECT *border,
					WORD *handle,
					int8 *name,
					int8 *iconified_name,
					OBJECT *iconified_tree )
{
	WINDOW	*new = 0L;

	*handle = wind_create( kind, border );

	if( *handle >= 0 )
	{
		GRECT	workarea;
		uint32	size;
				
		wind_calc( WC_WORK, kind, border, &workarea );
		
		if ( name )															/* Fensternamen vorhanden? */
		{
			size = ( strlen( name ) + 1 ) & 0xfffe;
			if ( size < 128 )												/* mindestens 128 Bytes fÅr Fensternamen */
				size = 128;
				
			if ( iconified_name )										/* 16 Bytes fÅr Namen des ikonifizierten Fensters */
				size += 16;

			size += sizeof( WINDOW );
		}
		else
			size = sizeof( WINDOW );
			
		new = malloc( size );
		new->handle = *handle;											/* Fensterhandle */
		new->kind = kind;													/* Fensterattribute */
		new->border = *border;											/* FensterauûenflÑche */
		new->workarea = workarea;										/* FensterinnenflÑche */
		if ( name )															/* Fensternamen vorhanden? */
		{
			new->name = ((int8 *) new ) + sizeof( WINDOW );
			strcpy( new->name, name );
			wind_set_string( new->handle, WF_NAME, new->name );

			if ( iconified_name )
			{
				new->iconified_name = (int8 *) new + size - 16;
				strncpy( new->iconified_name, iconified_name, 15 );
				new->iconified_name[15] = 0;
			}
		}
		else
		{
			new->name = 0L;												/* kein Fenstername */
			new->iconified_name = 0L;
		}

		memcpy(new->iconified_tree, iconified_tree, 2*sizeof(OBJECT));
		new->wflags.hide_cursor = 1;									/* Cursor vor dem Redraw immer ausschalten */
		new->wflags.snap_width = 0;									/* Breite nicht auf Vielfache von dx anpassen */
		new->wflags.snap_height = 0;									/* Hîhe nicht auf Vielfache von dy anpassen */
		new->wflags.snap_x = 0;											/* x-Koordinate nicht auf Vielfache von dx anpassen */
		new->wflags.snap_y = 0;											/* y-Koordinate nicht auf Vielfache von dy anpassen */
		new->wflags.smart_size = 1;									/* Smart Redraw fÅrs Sizen */
		new->wflags.limit_wsize = 0;									/* maximale Fenstergrîûe nicht begrenzen */
		new->wflags.fuller = 0;											/* Fuller wurde noch nicht betÑtigt */
		new->wflags.iconified = 0;										/* Iconifier wurde noch nicht betÑtigt */
	
		new->redraw = 0L;

		new->interior_flags = 0L;
		new->interior = 0L;

		new->x = 0;															/* x-Koordinate der linken oberen Ecke */
		new->y = 0;															/* y-Koordinate der linken oberen Ecke */
		new->w = 0;															/* Breite der ArbeitsflÑche */
		new->h = 0;															/* Hîhe der ArbeitsflÑche */
		new->dx = 0;														/* Breite einer Scrollspalte in Pixeln */
		new->dy = 0;														/* Hîhe einer Scrollzeile in Pixeln */
		new->snap_dx = 1;													/* Vielfaches fÅr horizontale Fensterposition */
		new->snap_dy = 1;													/* Vielfaches fÅr vertikale Fensterposition */
		new->snap_dw = 1;													/* Vielfaches der Fensterbreite */
		new->snap_dh = 1;													/* Vielfaches der Fensterhîhe */
		new->limit_w = 0;													/* ArbeitsflÑche nicht begrenzen */
		new->limit_h = 0;													/* ArbeitsflÑche nicht begrenzen */

		new->hslide = 0;													/* Position des hor. Sliders in Promille */
		new->vslide = 0;													/* Position des ver. Sliders in Promille */
		new->hslsize = 0;													/* Grîûe des hor. Sliders in Promille */
		new->vslsize = 0;													/* Grîûe des ver. Sliders in Promille */

		new->next = 0L;													/* keine Folgestruktur vorhanden */

		new->dirty = FALSE;

		list_insert((void **) &window_list, new, offsetof( WINDOW, next ));
	}
	return( new );
}

/*----------------------------------------------------------------------------------------*/
/* öberlappung von p1 und p2 ÅberprÅfen																	*/
/* Funktionsresultat:	bei öberlappung einen Wert ungleich 0, andernfalls 0;					*/
/*								die Struktur *p2 enthÑlt dann die SchnittflÑche							*/
/* p1, p2:					Zeiger auf die zu vergleichenden GRECTs									*/
/*----------------------------------------------------------------------------------------*/
WORD rc_intersect( GRECT *p1, GRECT *p2 )
{
	WORD tx, ty, tw, th;

	tw = min( p2->g_x + p2->g_w, p1->g_x + p1->g_w );
	th = min( p2->g_y + p2->g_h, p1->g_y + p1->g_h );
	tx = max( p2->g_x, p1->g_x );
	ty = max( p2->g_y, p1->g_y );
	p2->g_x = tx;
	p2->g_y = ty;
	p2->g_w = tw - tx;
	p2->g_h = th - ty;
	return(( tw > tx ) && ( th > ty ));
}

/*----------------------------------------------------------------------------------------*/
/* Redraw eines Fensters																						*/
/* Funktionsergebnis:	-																						*/
/* handle:				  	Fensterhandle																		*/
/* area:				  		Zeiger auf ein GRECT mit den Ausmaûen des zu zeichnenden Bereichs	*/
/*----------------------------------------------------------------------------------------*/
void	redraw_window( WORD handle, GRECT *area )
{
	GRECT		box,
				desk;
	WINDOW	*window;
	
	window = search_struct( handle );

	if ( window )
	{
		wind_update( BEG_UPDATE );										/* Bildschirm fÅr andere Apps sperren */
		if ( window->wflags.hide_cursor )
			graf_mouse( M_OFF, 0L );									/* Maus ausschalten */

		if	(window->wflags.iconified)
			{
			objc_wdraw( window->iconified_tree, 0, 8,
							area,	window->handle );
			}
		else
			{
			wind_get_grect( 0, WF_WORKXYWH, &desk );					/* Grîûe des Hintergrunds erfragen */
			wind_get_grect( window->handle, WF_FIRSTXYWH, &box );	/* erstes Element der Rechteckliste erfragen */
	
			while ( box.g_w && box.g_h )									/* noch gÅltige Rechtecke vorhanden? */
			{
				if ( rc_intersect( &desk, &box ))						/* sichtbar? */
				{
					if ( rc_intersect( area, &box ))						/* innerhalb des zu zeichnenden Bereichs? */
						window->redraw( window, &box );					/* Bereich box zeichnen */
				}
				wind_get_grect( window->handle, WF_NEXTXYWH, &box );	/* nÑchstes Element der Rechteckliste holen */
			}
			}

		if ( window->wflags.hide_cursor )
			graf_mouse( M_ON, 0L );										/* Maus an */
		wind_update( END_UPDATE );										/* Bildschirm freigeben */
	}
}

/*----------------------------------------------------------------------------------------*/
/* FÅr ein Fensterhandle die WINDOW-Struktur suchen													*/
/* Funktionsergebnis:	Zeiger auf die WINDOW-Struktur oder 0L										*/
/*	handle:					Fensterhandle																		*/
/*----------------------------------------------------------------------------------------*/
WINDOW	*search_struct( WORD handle )
{
	WINDOW	*search;
	
	search = window_list;
	
	while( search != 0L )
	{
		if( search->handle == handle )
			return( search );

		search = search->next;
	}
	return( 0L );
}

/*----------------------------------------------------------------------------------------*/
/* Fenster beim AES abmelden und Speicher fÅr WINDOW-Struktur freigeben							*/
/* Funktionsergebnis:	-																						*/
/* handle:					Fensterhandle																		*/
/*----------------------------------------------------------------------------------------*/
void	delete_window( WORD handle )
{
	WINDOW	*window;
	
	window = search_struct( handle );

	if( window )	
	{
		list_remove((void **) &window_list, window, offsetof( WINDOW, next ));
		
		wind_close( window->handle );
		wind_delete( window->handle );
		free( window );
	}
}

/*----------------------------------------------------------------------------------------*/
/* Fenster bewegen																								*/
/* Funktionsergebnis:	-																						*/
/* handle:					Fensterhandle																		*/
/* area:						Fenstergrîûe																		*/
/*----------------------------------------------------------------------------------------*/
void	move_window( WORD handle, GRECT *area )
{
	WINDOW	*window;
	GRECT		desk;

	wind_update( BEG_UPDATE );											/* Bildschirm sperren */

	window = search_struct( handle );
	if ( window )
	{
		WORD	kind;
		
		if ( window->wflags.iconified )
			kind = NAME + MOVER;
		else
			kind = window->kind;
		
		wind_get_grect( 0, WF_WORKXYWH, &desk );					/* Grîûe des Hintergrunds erfragen */

		wind_calc( WC_WORK, kind, area, &window->workarea );

		if ( window->wflags.snap_x )				
		{
			WWORK.g_x += window->snap_dx - 2;	
			if ( WWORK.g_x > ( desk.g_x + desk.g_w - 32 ))
				WWORK.g_x = desk.g_x + desk.g_w - 32;
			WWORK.g_x -= WWORK.g_x % window->snap_dx;
		}
		
		if ( window->wflags.snap_y )
		{
			WWORK.g_y += window->snap_dy - 1;
			if ( WWORK.g_y > ( desk.g_y + desk.g_h - 2 ))
				WWORK.g_y = desk.g_y + desk.g_h - 2;
			WWORK.g_y -= WWORK.g_y % window->snap_dy;
		}

		wind_calc( WC_BORDER, kind, &window->workarea, &window->border );
		wind_set_grect( handle, WF_CURRXYWH, &window->border );
		if	(window->wflags.iconified)
			{
			window->iconified_tree->ob_x = window->workarea.g_x;
			window->iconified_tree->ob_y = window->workarea.g_y;
			}
	}
	wind_update( END_UPDATE );											/* Bildschirm freigeben */

}

/*----------------------------------------------------------------------------------------*/
/* Scrolling																										*/
/* Funktionsergebnis:	-																						*/
/* handle:					Fensterhandle																		*/
/* command:					Gibt an, auf welche Art zu scrollen ist									*/
/*----------------------------------------------------------------------------------------*/
void	arr_window( WORD handle, WORD command )
{
	WINDOW	*window;
	
	wind_update( BEG_UPDATE );											/* Bildschirm freigeben */

	window = search_struct( handle );
	if ( window )
	{
		switch ( command )
		{
			case WA_UPPAGE: up_window( window, window->workarea.g_h ); break;
	      case WA_DNPAGE: dn_window( window, window->workarea.g_h ); break;
			case WA_UPLINE: up_window( window, window->dy ); break;
	      case WA_DNLINE: dn_window( window, window->dy ); break; 
	      case WA_LFPAGE: lf_window( window, window->workarea.g_w ); break;
	      case WA_RTPAGE: rt_window( window, window->workarea.g_w ); break;
	      case WA_LFLINE: lf_window( window, window->dx ); break;
	      case WA_RTLINE: rt_window( window, window->dx ); break;
		}
	}
	wind_update( END_UPDATE );											/* Bildschirm freigeben */
}

/*----------------------------------------------------------------------------------------*/
/* Um dy Zeilen nach oben Scrollen																			*/
/* Funktionsergebnis:	-																						*/
/* window:					Zeiger auf Fensterstruktur														*/
/*	dy:						Anzahl der Zeilen																	*/
/*----------------------------------------------------------------------------------------*/
void	up_window( WINDOW *window, int32 dy )
{
	if ( window->y > 0 )													/* Slider schon oben? */
	{
		wind_update( BEG_UPDATE );										/* Bildschirm fÅr andere Apps sperren */
		graf_mouse( M_OFF, 0L );										/* Maus ausschalten */

		if ( window->y < dy )
			dy = window->y;
			
		window->y -= dy;													/* dy Pixelzeilen weiter nach oben */
	
		scroll_vertical( window, (WORD) -dy );								/* nach links scrollen */

		graf_mouse( M_ON, 0L );											/* Maus einschalten */
		wind_update( END_UPDATE );										/* Bildschirm freigeben */
	}
}

/*----------------------------------------------------------------------------------------*/
/* Um dy Zeilen nach unten Scrollen																			*/
/* Funktionsergebnis:	-																						*/
/* window:					Zeiger auf Fensterstruktur														*/
/*	dy:						Anzahl der Zeilen																	*/
/*----------------------------------------------------------------------------------------*/
void	dn_window( WINDOW *window, int32 dy )
{
	if (( window->y + window->workarea.g_h ) < window->h )	/* Slider bereits unten? */
	{
		wind_update( BEG_UPDATE );										/* Bildschirm fÅr andere Apps sperren */
		graf_mouse( M_OFF, 0L );										/* Maus ausschalten */
		
		if (( window->y + window->workarea.g_h + dy ) > window->h )
			dy = window->h - window->y - window->workarea.g_h;

		window->y += dy;
		scroll_vertical( window, (WORD) dy );								/* nach unten scrollen */

		graf_mouse( M_ON, 0L );											/* Maus einschalten */
		wind_update( END_UPDATE );										/* Bildschirm freigeben */
	}
}

/*----------------------------------------------------------------------------------------*/
/* Um dx Spalten nach links Scrollen																		*/
/* Funktionsergebnis:	-																						*/
/* window:					Zeiger auf Fensterstruktur														*/
/*	dx:						Anzahl der Spalten																*/
/*----------------------------------------------------------------------------------------*/
void	lf_window( WINDOW *window, int32 dx )
{
	if ( window->x > 0 )													/* Slider schon linnks? */
	{
		wind_update( BEG_UPDATE );										/* Bildschirm fÅr andere Apps sperren */
		graf_mouse( M_OFF, 0L );										/* Maus ausschalten */
		
		if ( window->x < dx )											/* kann um dx Pixelspalten gescrollt werden? */
			dx = window->x;
			
		window->x -= dx;													/* dx Pixelzeilen weiter nach oben */
	
		scroll_horizontal( window, (WORD) -dx );							/* nach links scrollen */

		graf_mouse( M_ON, 0L );											/* Maus einschalten */
		wind_update( END_UPDATE );										/* Bildschirm freigeben */
	}
}

/*----------------------------------------------------------------------------------------*/
/* Um dx Spalten nach rechts Scrollen																		*/
/* Funktionsergebnis:	-																						*/
/* window:					Zeiger auf Fensterstruktur														*/
/*	dx:						Anzahl der Spalten																*/
/*----------------------------------------------------------------------------------------*/
void	rt_window( WINDOW *window, int32 dx )
{
	if (( window->x + window->workarea.g_w ) < window->w ) 	/* Slider bereits rechts? */
	{
		wind_update( BEG_UPDATE );										/* Bildschirm fÅr andere Apps sperren */
		graf_mouse( M_OFF, 0L );										/* Maus ausschalten */
		
		if (( window->x + window->workarea.g_w + dx ) > window->w )
			dx = window->w - window->x - window->workarea.g_w;

		window->x += dx;

		scroll_horizontal( window, (WORD) dx );								/* nach rechts scrollen */

		graf_mouse( M_ON, 0L );											/* Maus einschalten */
		wind_update( END_UPDATE );										/* Bildschirm freigeben */
	}
}


/*----------------------------------------------------------------------------------------*/
/* Horizontale Sliderposition setzen																		*/
/* Funktionsergebnis:	-																						*/
/* handle:					Fensterhandle																		*/
/* hslid:					neue Sliderposition in Promille												*/
/*----------------------------------------------------------------------------------------*/
void	hlsid_window( WORD handle, WORD hslid )
{
	WINDOW	*window;

	wind_update( BEG_UPDATE );											/* Bildschirm sperren */
	graf_mouse( M_OFF, 0L );											/* Maus ausschalten */

	window = search_struct( handle );
	if ( window )
	{
		int32	old_x;

		old_x = window->x;

		if (( WWORK.g_w + window->x ) > window->w )				/* Fenster breiter als der sichtbare Inhalt? */
		{
			window->x = hslid * window->x / 1000;
			set_slsize( window );
		}
		else
			window->x = hslid * ( window->w - window->workarea.g_w ) / 1000;

		if ( window->wflags.snap_width )
			window->x -= window->x % window->snap_dw;

		if ( old_x != window->x )										/* Sliderposition verÑndert? */
			scroll_horizontal( window, (WORD) (window->x - old_x ));
	}
	graf_mouse( M_ON, 0L );												/* Maus einschalten */
	wind_update( END_UPDATE );											/* Bildschirm freigeben */
}

/*----------------------------------------------------------------------------------------*/
/* Vertikale Sliderposition setzen																			*/
/* Funktionsergebnis:	-																						*/
/* handle:					Fensterhandle																		*/
/* vslid:					neue Sliderposition in Promille												*/
/*----------------------------------------------------------------------------------------*/
void	vslid_window( WORD handle, WORD vslid )
{
	WINDOW	*window;
	
	wind_update( BEG_UPDATE );											/* Bildschirm fÅr andere Apps sperren */
	graf_mouse( M_OFF, 0L );											/* Maus ausschalten */

	window = search_struct( handle );
	if ( window )
	{
		int32	old_y;
		
		old_y = window->y;
		
		if (( WWORK.g_h + window->y ) > window->h )				/* Fenster hîher als der sichtbare Inhalt? */
		{
			window->y = vslid * window->y / 1000;
			set_slsize( window );
		}
		else
			window->y =  vslid * ( window->h - window->workarea.g_h ) / 1000;
	
		if ( window->wflags.snap_height )
			window->y -= window->y % window->snap_dh;

		if ( old_y != window->y )										/* Sliderposition verÑndert? */
			scroll_vertical( window, (WORD) (window->y - old_y ));
	}
	graf_mouse( M_ON, 0L );												/* Maus einschalten */
	wind_update( END_UPDATE );											/* Bildschirm freigeben */
}

/*----------------------------------------------------------------------------------------*/
/* Horizontales Scrolling (BEG_UPDATE muû bereits gesetzt sein)									*/
/* Funktionsergebnis:	-																						*/
/*	window:					Fensterstruktur																	*/
/*	dx:						horizontale Verschiebung (< 0: nach links > 0: nach rechts)			*/
/*----------------------------------------------------------------------------------------*/
static void	scroll_horizontal( WINDOW *window, WORD dx )
{
	GRECT		box;
	GRECT		desk;
	MFDB		screen;
	RECT16	rect[2];

	if ( dx )
	{
		wind_get_grect( 0, WF_WORKXYWH, &desk );					/* Grîûe des Hintergrunds erfragen */
		wind_get_grect( window->handle, WF_FIRSTXYWH, &box );	/* erstes Element der Rechteckliste erfragen */

		while ( box.g_w && box.g_h )									/* Ende der Rechteckliste? */
		{
			if ( rc_intersect( &desk, &box  ))						/* Rechteck innerhalb des Schirms? */
			{			
				if ( rc_intersect( &window->workarea, &box ))	/* Rechteck innerhalb des Fensters? */
				{			
					if ( ABS( dx ) < box.g_w )							/* kann verschoben werden? */
					{
						screen.fd_addr = 0L;								/* Bildschirm */
					
						*(GRECT *)rect = box;
						rect[0].x2 += box.g_x - 1;
						rect[0].y2 += box.g_y - 1;
		
						vs_clip( vdi_handle, 1, (WORD *) rect );	/* Clipping-Rechteck setzen */
					
						rect[1] = rect[0];
						
						if ( dx >= 0 )
						{
							rect[0].x1 += dx;
							rect[1].x2 -= dx;
						
						   box.g_x += box.g_w - dx;
						}
						else
						{
							rect[0].x2 += dx;
							rect[1].x1 -= dx;
						}
				  		box.g_w = ABS( dx );
					
						vro_cpyfm( vdi_handle, S_ONLY, (WORD *) rect, &screen, &screen );
					   
					}
					window->redraw( window, &box );					/* Bereich box zeichnen */
				}	
			}	
			wind_get_grect( window->handle, WF_NEXTXYWH, &box );	/* nÑchstes Element der Rechteckliste holen */
		}		

		if (( WWORK.g_w + window->x ) > window->w )				/* Fenster breiter als der sichtbare Inhalt? */
			set_slsize( window );
		else
			set_slpos( window );
	}
}

/*----------------------------------------------------------------------------------------*/
/* Vertikales Scrolling (BEG_UPDATE muû bereits gesetzt sein)										*/
/* Funktionsergebnis:	-																						*/
/*	window:					Fensterstruktur																	*/
/*	dy:						vertikale Verschiebung (< 0: nach oben > 0: nach unten)				*/
/*----------------------------------------------------------------------------------------*/
static void	scroll_vertical( WINDOW *window, WORD dy )
{
	GRECT		box;
	GRECT		desk;
	MFDB		screen;
	RECT16	rect[2];
	
	if ( dy )																/* Sliderposition verÑndert? */
	{
		wind_get_grect( 0, WF_WORKXYWH, &desk );					/* Grîûe des Hintergrunds erfragen */
		wind_get_grect( window->handle, WF_FIRSTXYWH, &box );	/* erstes Element der Rechteckliste erfragen */
		
		while ( box.g_w && box.g_h )									/* Ende der Rechteckliste? */
		{
			if ( rc_intersect( &desk, &box  ))						/* Rechteck innerhalb des Schirms? */
			{			
				if ( rc_intersect( &window->workarea, &box ))	/* Rechteck innerhalb des Fensters? */
				{			
					if ( ABS( dy ) < box.g_h )							/* kann verschoben werden? */
					{
						screen.fd_addr = 0L;								/* Bildschirm */
					
						*(GRECT *)rect = box;
						rect[0].x2 += box.g_x - 1;
						rect[0].y2 += box.g_y - 1;
		
						vs_clip( vdi_handle, 1, (WORD *) rect );	/* Clipping-Rechteck setzen */
					
						rect[1] = rect[0];
		
						if ( dy >= 0 )										/* nach unten scrollen? */
						{
							rect[0].y1 += dy;
							rect[1].y2 -= dy;
		
						   box.g_y += box.g_h - dy;
						}
						else													/* nach oben scrollen */
						{
							rect[0].y2 += dy;
							rect[1].y1 -= dy;
						}
		
				  		box.g_h = ABS( dy );
		
						vro_cpyfm( vdi_handle, S_ONLY, (WORD *) rect, &screen, &screen );
					}
					window->redraw( window, &box );					/* Bereich box zeichnen */
				}	
			}	
			wind_get_grect( window->handle, WF_NEXTXYWH, &box );	/* nÑchstes Element der Rechteckliste holen */
		}		

		if (( WWORK.g_h + window->y ) > window->h )				/* Fenster hîher als der sichtbare Inhalt? */
			set_slsize( window );
		else
			set_slpos( window );
	}
}


/*----------------------------------------------------------------------------------------*/
/* Fenstergrîûe verÑndern																						*/
/* Funktionsergebnis:	-																						*/
/* handle:					Fensterhandle																		*/
/* size:						Zeiger auf GRECT mit Fensterausmaûen										*/
/*----------------------------------------------------------------------------------------*/
void	size_window( WORD handle, GRECT *size )
{
	WINDOW	*window;
	WORD		buf[8];
	GRECT		desk;
	
	window = search_struct( handle );

	if ( window )
	{
		boolean	full_redraw;
		
		full_redraw = FALSE;
		
		if ( window->wflags.smart_size == 0  )						/* gesamtes Fenster neuzeichnen? */
			full_redraw = TRUE;	

		wind_update( BEG_UPDATE );										/* Bildschirm sperren */
	
		wind_get_grect( 0, WF_WORKXYWH, &desk );					/* Grîûe des Hintergrunds erfragen */

		window->border = *size;											/* Grîûe von Fensterauûen und -InnenflÑche bestimmen */
		wind_calc( WC_WORK, window->kind, &window->border, &window->workarea );
	
		if ( window->wflags.snap_x )									/* x-Koordinate snappen? */
		{
			WWORK.g_x += window->snap_dx - 2;	
			if ( WWORK.g_x > ( desk.g_x + desk.g_w - 32 ))
				WWORK.g_x = desk.g_x + desk.g_w - 32;
			WWORK.g_x -= WWORK.g_x % window->snap_dx;
		}
		
		if ( window->wflags.snap_y )									/* y-Koordinate snappen? */
		{
			WWORK.g_y += window->snap_dy - 1;
			if ( WWORK.g_y > ( desk.g_y + desk.g_h - 2 ))
				WWORK.g_y = desk.g_y + desk.g_h - 2;
			WWORK.g_y -= WWORK.g_y % window->snap_dy;
		}
		
		if ( window->wflags.snap_width )								/* Breite snappen? */
		{
			WWORK.g_w += window->snap_dw - 1;
			if ( WWORK.g_w > desk.g_w )
				WWORK.g_h = desk.g_w;
			WWORK.g_w -= WWORK.g_w % window->snap_dw;
		}
		
		if ( window->wflags.snap_height )							/* Hîhe snappen? */
		{
			WWORK.g_h += window->snap_dh - 1;
			if ( WWORK.g_h > desk.g_h )
				WWORK.g_h = desk.g_h;
			WWORK.g_h -= WWORK.g_h % window->snap_dh;
		}
		
		window->wflags.fuller = 0;										/* das Fenster hat nicht mehr die volle Grîûe */
		if ( window->wflags.limit_wsize )							/* Grîûe begrenzt? */
		{
			WORD	max_w,
					max_h;
			
			if ( window->limit_w )										/* sichtbare Breite zusÑtzlich begrenzt? */
				max_w = window->limit_w;
			else
				max_w = (WORD) window->w;
				
			if ( window->limit_h )										/* sichtbare Hîhe zusÑtzlich begrenzt? */
				max_h = window->limit_h;
			else
				max_h = (WORD) window->h;
			
			if ( WWORK.g_w >= max_w )
			{
				window->border.g_w -= WWORK.g_w - max_w;
				WWORK.g_w = max_w;
			}
			if ( WWORK.g_h >= max_h )
			{
				window->border.g_h -= WWORK.g_h - max_h;
				WWORK.g_h = max_h;
			}

			if ( window->x + WWORK.g_w > window->w )
			{
				window->x = window->w - WWORK.g_w;
				full_redraw = TRUE;										/* gesamtes Fenster neuzeichnen */
			}

			if ( window->y + WWORK.g_h > window->h )
			{
				window->y = window->h - WWORK.g_h;
				full_redraw = TRUE;										/* gesamtes Fenster neuzeichnen */
			}
		}

		wind_calc( WC_BORDER, window->kind, &window->workarea, &window->border );
		wind_set_grect( handle, WF_CURRXYWH, &window->border );
		
		set_slsize( window );											/* Slidergrîûe setzen */
		set_slpos( window );												/* Sliderposition setzen */

		if ( full_redraw )												/* gesamtes Fenster neuzeichnen? */
		{
			buf[0] = WM_REDRAW;											/* Nachrichtennummer */
			buf[1] = app_id;												/* Absender der Nachricht */
		 	buf[2] = 0;														/* öberlÑnge in Bytes */
			buf[3] = handle;												/* Fensternummer */
			*(GRECT *)&buf[4] = *size;									/* Fensterkoordinaten */
			appl_write( app_id, 16, buf );							/* Redraw-Meldung an sich selber schicken */
		}
		
		wind_update( END_UPDATE );										/* Bildschirm freigeben */
	}
}

/*----------------------------------------------------------------------------------------*/
/* Sliderposition setzen																						*/
/* Funktionsergebnis:	-																						*/
/* window:					Zeiger auf Fensterdaten															*/
/*----------------------------------------------------------------------------------------*/
void	set_slpos( WINDOW *window )
{
	if ( window->kind & HSLIDE )										/* horizontaler Slider vorhanden? */
	{
		WORD	old_pos;
		
		old_pos = window->hslide;

		if (( WWORK.g_w + window->x ) >= window->w )				/* Fenster breiter als der sichtbare Inhalt? */
			window->hslide = 1000;
		else
			window->hslide = (WORD)( window->x * 1000 / ( window->w - window->workarea.g_w ));

		if ( old_pos != window->hslide )								/* Sliderposition verÑndert? */
			wind_set( window->handle, WF_HSLIDE, window->hslide, 0, 0, 0 );
	}
	
	if ( window->kind & VSLIDE )										/* vertikaler Slider vorhanden? */
	{
		WORD	old_pos;
		
		old_pos = window->vslide;

		if (( WWORK.g_h + window->y ) >= window->h )				/* Fenster hîher als der sichtbare Inhalt? */
			window->vslide = 1000;
		else
			window->vslide = (WORD)( window->y * 1000 / ( window->h - window->workarea.g_h ));

		if ( old_pos != window->vslide )								/* Sliderposition verÑndert? */
			wind_set( window->handle, WF_VSLIDE, window->vslide, 0, 0, 0 );
	}
}

/*----------------------------------------------------------------------------------------*/
/* Slidergrîûe setzen																							*/
/* window:					Zeiger auf Fensterdaten															*/
/*----------------------------------------------------------------------------------------*/
void	set_slsize( WINDOW *window )
{
	if ( window->kind & HSLIDE )										/* horizontaler Slider vorhanden? */
	{
		WORD	old_size;

		old_size = window->hslsize;

		if (( WWORK.g_w + window->x ) > window->w )				/* Fenster breiter als der sichtbare Inhalt? */
			window->hslsize = (WORD) ((int32) WWORK.g_w * 1000 / ( WWORK.g_w + window->x ));
		else
			window->hslsize = (WORD) ((int32) window->workarea.g_w * 1000 / window->w );
		
		if ( window->hslsize == 0 )
			window->hslsize = -1;
		if ( window->hslsize > 1000 )
			window->hslsize = 1000;
			
		if ( old_size != window->hslsize )							/* Slidergrîûe verÑndert? */
			wind_set( window->handle, WF_HSLSIZE, window->hslsize, 0, 0, 0 );
	}
	
	if ( window->kind & VSLIDE )										/* vertikaler Slider vorhanden? */
	{
		WORD	old_size;

		old_size = window->vslsize;

		if (( WWORK.g_h + window->y ) > window->h )				/* Fenster hîher als der sichtbare Inhalt? */
			window->vslsize = (WORD) ((int32) WWORK.g_h * 1000 / ( WWORK.g_h + window->y ));
		else
			window->vslsize = (WORD) ((int32) window->workarea.g_h * 1000 / window->h );
		
		if ( window->vslsize == 0 )
			window->vslsize = -1;
		if ( window->vslsize > 1000 )
			window->vslsize = 1000;
			
		if ( old_size != window->vslsize )							/* Slidergrîûe verÑndert? */
			wind_set( window->handle, WF_VSLSIZE, window->vslsize, 0, 0, 0 );
	}
}

/*----------------------------------------------------------------------------------------*/
/* Fenster auf maximale Grîûe																					*/
/* Funktionsergebnis:	-																						*/
/* handle:					Fensterhandle																		*/
/*	max_width:				0: ignorieren >0: maximale Breite, Position nicht verÑndern			*/
/*	max_height:				0: ignorieren >0: maximale Hîhe, Position nicht verÑndern			*/
/*----------------------------------------------------------------------------------------*/
void	full_window( WORD handle, WORD max_width, WORD max_height )
{
	WINDOW	*window;
	GRECT		area;
	GRECT		desk;
	
	window = search_struct( handle );
	if ( window )
	{
		if ( window->wflags.fuller )									/* bereits maximale Grîûe ? */
		{
			wind_get_grect( handle, WF_PREVXYWH, &area ); 
			size_window( handle, &area );
			window->wflags.fuller = 0;
		}
		else
		{
			wind_get_grect( 0, WF_WORKXYWH, &desk );				/* Grîûe des Desktops */
			wind_calc( WC_WORK, window->kind, &desk, &desk );	/* Grîûe der FensterinnenflÑche */
			
			area = desk;

			area.g_x = window->workarea.g_x;							/* die Position nicht verÑndern */
			area.g_y = window->workarea.g_y;

			if ( window->wflags.limit_wsize )						/*	Fenstergrîûe begrenzt? */
			{
				int32	max_w;
				int32	max_h;

				if ( window->limit_w )									/* sichtbare Breite zusÑtzlich begrenzt? */
					max_w = window->limit_w;
				else
					max_w = (WORD) window->w;
					
				if ( window->limit_h )									/* sichtbare Hîhe zusÑtzlich begrenzt? */
					max_h = window->limit_h;
				else
					max_h = window->h;

				if ( area.g_w > max_w )
					area.g_w = (WORD) max_w;
				if ( area.g_h > max_h )
					area.g_h = (WORD) max_h;
			}

			if ( max_width || max_height )							/* Fenstergrîûe nur so groû wie nîtig machen? */
			{
				if ( area.g_w > max_width )
					area.g_w = max_width;
				if ( area.g_h > max_height )
					area.g_h = max_height;
			}
			
			if (( area.g_x + area.g_w ) > ( desk.g_x + desk.g_w ))
				area.g_x = desk.g_x + desk.g_w - area.g_w;
			
			if ( area.g_x < desk.g_x )
				area.g_x = desk.g_x;

			if (( area.g_y + area.g_h ) > ( desk.g_y + desk.g_h ))
				area.g_y = desk.g_y + desk.g_h - area.g_h;
			
			if ( area.g_y < desk.g_y )
				area.g_y = desk.g_y;
			
			wind_calc( WC_BORDER, window->kind, &area, &area );
			size_window( handle, &area );
			window->wflags.fuller = 1;
		}
	}
}

/*----------------------------------------------------------------------------------------*/
/* Fenster ikonifizieren																						*/
/* Funktionsergebnis:	-																						*/
/*	handle:					Fensterhandle																		*/
/*	size:						neue Fenstergrîûe oder 0L														*/
/*----------------------------------------------------------------------------------------*/
void	iconify_window( WORD handle, GRECT *size )
{
	WINDOW	*window;
	OBJECT *tree;
	int ob;

	window = search_struct( handle );

	if ( window )
	{
		GRECT	area;
	
		window->saved_border = window->border;
	
		if (( size == 0L ) || ( size->g_w < 1 ) || ( size->g_h < 1 ))
		{
			GRECT	unknown = { -1, -1, -1, -1 };
	
			wind_close( window->handle );
			wind_set_grect( window->handle, WF_ICONIFY, &unknown );
			wind_get_grect( window->handle, WF_CURRXYWH, &area ); 
			size = &area;
	
			wind_open( window->handle, &area );
		}
		else
		{
			graf_shrinkbox( size , &window->border );
			wind_set_grect( window->handle, WF_ICONIFY, size );
		}
	
		window->border = *size;
		wind_get_grect( window->handle, WF_WORKXYWH, &window->workarea );
	
		if ( window->iconified_name )									/* spezieller Fenstertitel? */
			wind_set_string( window->handle, WF_NAME, window->iconified_name );
	
		wind_set( window->handle, WF_BOTTOM, 0, 0, 0, 0 );		/* nach hinten legen */
		window->wflags.iconified = 1;

		tree = window->iconified_tree;
		tree->ob_x = window->workarea.g_x;
		tree->ob_y = window->workarea.g_y;
		ob = tree->ob_head;
		if	(ob > 0)
			{
			tree+=ob;
			tree->ob_x = (window->workarea.g_w - tree->ob_width)/2;
			tree->ob_y = (window->workarea.g_h - tree->ob_height)/2;
			}
	}
}

/*----------------------------------------------------------------------------------------*/
/* Fenster auf normale Grîûe bringen																		*/
/* Funktionsergebnis:	-																						*/
/*	handle:					Fensterhandle																		*/
/*	size:						neue Fenstergrîûe oder 0L														*/
/*----------------------------------------------------------------------------------------*/
void	uniconify_window( WORD handle, GRECT *size )
{
	WINDOW	*window;

	window = search_struct( handle );

	if ( window )
	{
		if (( size == 0L ) || ( size->g_w < 1 ) || ( size->g_h < 1 ))
			size = &window->saved_border;

		graf_growbox( &window->border, size );
		wind_set_grect( window->handle, WF_UNICONIFY, size );
		window->border = *size;
		wind_get_grect( window->handle, WF_WORKXYWH, &window->workarea );
	
		if ( window->name )												/* Fenstertitel? */
			wind_set_string( window->handle, WF_NAME, window->name );
	
		wind_set( window->handle, WF_TOP, 0, 0, 0, 0 );
		window->wflags.iconified = 0;
	}
}

/*----------------------------------------------------------------------------------------*/
/* Das nÑchste Fenster in den Vordergrund bringen														*/
/* Funktionsergebnis:	-																						*/
/*----------------------------------------------------------------------------------------*/
void	switch_window( void )
{
	WORD	handle,buf[8];
	WINDOW *change;
		
	wind_get( 0, WF_TOP, &handle, 0, 0, 0 );
	change = search_struct( handle );
	
	if ( change )															/* liegt ein Fenster des eigenen Programms vorne? */
	{
		if ( change->next )
			change = change->next;
		else
			change = window_list;
		
		buf[0] = WM_TOPPED;												/* Nachrichtennummer */
		buf[1] = app_id;													/* Absender der Nachricht */
		buf[2] = 0;															/* öberlÑnge in Bytes */
		buf[3] = change->handle;										/* Fensternummer */
		appl_write( app_id, 16, buf );								/* Redraw-Meldung an sich selber schicken */
	}
}


#if 0	/* ersetzter Code */

			case WA_UPPAGE: uppage_window( window ); break;
	      case WA_DNPAGE: dnpage_window( window ); break;
	      case WA_UPLINE: upline_window( window ); break;
	      case WA_DNLINE: dnline_window( window ); break; 
	      case WA_LFPAGE: lfpage_window( window ); break;
	      case WA_RTPAGE: rtpage_window( window ); break;
	      case WA_LFLINE: lfline_window( window ); break;
	      case WA_RTLINE: rtline_window( window ); break;

/*----------------------------------------------------------------------------------------*/
/* Um eine Seite nach oben Scrollen																			*/
/* Funktionsergebnis:	-																						*/
/* window:					Zeiger auf Fensterstruktur														*/
/*----------------------------------------------------------------------------------------*/
void	uppage_window( WINDOW *window )
{
	if ( window->y )
	{
		if ( window->y > window->workarea.g_h )
			window->y -= window->workarea.g_h;
		else
			window->y = 0;

		if (( window->y + window->workarea.g_h ) > window->h )	/* Fenster hîher als der sichtbare Inhalt? */
			set_slsize( window );										/* Slidergrîûe verÑndern */
		else
			set_slpos( window );
	
		redraw_window( window->handle, &window->workarea );
	}
}

/*----------------------------------------------------------------------------------------*/
/* Um eine Seite nach unten Scrollen																		*/
/* Funktionsergebnis:	-																						*/
/* window:					Zeiger auf Fensterstruktur														*/
/*----------------------------------------------------------------------------------------*/
void	dnpage_window( WINDOW *window )
{
	if (( window->y + window->workarea.g_h ) != window->h )
	{
		window->y += window->workarea.g_h;
	
		if (( window->y + window->workarea.g_h ) > window->h )
			window->y = window->h - window->workarea.g_h;

		set_slpos( window );
	
		redraw_window( window->handle, &window->workarea );
	}
}

/*----------------------------------------------------------------------------------------*/
/* Um eine Zeile nach oben Scrollen																			*/
/* Funktionsergebnis:	-																						*/
/* window:					Zeiger auf Fensterstruktur														*/
/*----------------------------------------------------------------------------------------*/
void	upline_window( WINDOW *window )
{
	WORD	dy;
		
	if ( window->y > 0 )													/* Slider schon oben? */
	{
		wind_update( BEG_UPDATE );										/* Bildschirm fÅr andere Apps sperren */
		graf_mouse( M_OFF, 0L );										/* Maus ausschalten */
		
		if ( window->y < window->dy )									/* kann um dy Pixelzeilen gescrollt werden? */
			dy = (WORD) window->y;
		else
			dy = window->dy;
			
		window->y -= dy;													/* dy Pixelzeilen weiter nach oben */
	
		scroll_vertical( window, -dy );								/* nach links scrollen */

		graf_mouse( M_ON, 0L );											/* Maus einschalten */
		wind_update( END_UPDATE );										/* Bildschirm freigeben */
	}
}


/*----------------------------------------------------------------------------------------*/
/* Um eine Zeile nach unten Scrollen																		*/
/* Funktionsergebnis:	-																						*/
/* window:					Zeiger auf Fensterstruktur														*/
/*----------------------------------------------------------------------------------------*/
void	dnline_window( WINDOW *window )
{
	WORD	dy;
	
	if (( window->y + window->workarea.g_h ) < window->h )	/* Slider bereits unten? */
	{
		wind_update( BEG_UPDATE );										/* Bildschirm fÅr andere Apps sperren */
		graf_mouse( M_OFF, 0L );										/* Maus ausschalten */
		
		if (( window->y + window->workarea.g_h + window->dy ) > window->h )
			dy = (WORD) ( window->h - window->y - window->workarea.g_h );
		else
			dy = window->dy;

		window->y += dy;

		scroll_vertical( window, dy );								/* nach unten scrollen */

		graf_mouse( M_ON, 0L );											/* Maus einschalten */
		wind_update( END_UPDATE );										/* Bildschirm freigeben */
	}
}

/*----------------------------------------------------------------------------------------*/
/* Um eine Spalte nach links Scrollen																		*/
/* Funktionsergebnis:	-																						*/
/* window:					Zeiger auf Fensterstruktur														*/
/*----------------------------------------------------------------------------------------*/
void	lfline_window( WINDOW *window )
{
	WORD	dx;

	if ( window->x > 0 )													/* Slider schon linnks? */
	{
		wind_update( BEG_UPDATE );										/* Bildschirm fÅr andere Apps sperren */
		graf_mouse( M_OFF, 0L );										/* Maus ausschalten */
		
		if ( window->x < window->dx )									/* kann um dx Pixelspalten gescrollt werden? */
			dx = (WORD) window->x;
		else
			dx = window->dx;
			
		window->x -= dx;													/* dx Pixelzeilen weiter nach oben */
	
		scroll_horizontal( window, -dx );							/* nach links scrollen */

		graf_mouse( M_ON, 0L );											/* Maus einschalten */
		wind_update( END_UPDATE );										/* Bildschirm freigeben */
	}
}

/*----------------------------------------------------------------------------------------*/
/* Um eine Spalte nach rechts Scrollen																		*/
/* Funktionsergebnis:	-																						*/
/* window:					Zeiger auf Fensterstruktur														*/
/*----------------------------------------------------------------------------------------*/
void	rtline_window( WINDOW *window )
{
	WORD	dx;

	if (( window->x + window->workarea.g_w ) < window->w ) 	/* Slider bereits rechts? */
	{
		wind_update( BEG_UPDATE );										/* Bildschirm fÅr andere Apps sperren */
		graf_mouse( M_OFF, 0L );										/* Maus ausschalten */
		
		if (( window->x + window->workarea.g_w + window->dx ) > window->w )
			dx = (WORD) ( window->w - window->x - window->workarea.g_w );
		else
			dx = window->dx;

		window->x += dx;

		scroll_horizontal( window, dx );								/* nach rechts scrollen */

		graf_mouse( M_ON, 0L );											/* Maus einschalten */
		wind_update( END_UPDATE );										/* Bildschirm freigeben */
	}
}

/*----------------------------------------------------------------------------------------*/
/* Um eine Seite nach links Scrollen																		*/
/* Funktionsergebnis:	-																						*/
/* window:					Zeiger auf Fensterstruktur														*/
/*----------------------------------------------------------------------------------------*/
void	lfpage_window( WINDOW *window )
{
	WORD		buf[8];

	wind_update( BEG_UPDATE );											/* Bildschirm fÅr andere Apps sperren */

	if ( window->x > window->workarea.g_w )
		window->x -= window->workarea.g_w;
	else
		window->x = 0;
		
	if (( window->x + window->workarea.g_w ) > window->w )	/* Fenster breiter als der sichtbare Inhalt? */
		set_slsize( window );
	else
		set_slpos( window );

	buf[0] = WM_REDRAW;													/* Nachrichtennummer */
	buf[1] = app_id;														/* Absender der Nachricht */
	buf[2] = 0;																/* öberlÑnge in Bytes */
	buf[3] = window->handle;											/* Fensternummer */
	*(GRECT *)&buf[4] = window->workarea;							/* Fensterkoordinaten */
	appl_write( app_id, 16, buf );									/* Redraw-Meldung an sich selber schicken */
	
	wind_update( END_UPDATE );											/* Bildschirm freigeben */
}

/*----------------------------------------------------------------------------------------*/
/* Um eine Seite nach rechts Scrollen																		*/
/* Funktionsergebnis:	-																						*/
/* window:					Zeiger auf Fensterstruktur														*/
/*----------------------------------------------------------------------------------------*/
void	rtpage_window( WINDOW *window )
{
	WORD		buf[8];

	wind_update( BEG_UPDATE );											/* Bildschirm fÅr andere Apps sperren */

	window->x += window->workarea.g_w;

	if (( window->x + window->workarea.g_w ) > window->w )
		window->x = window->w - window->workarea.g_w;
		
	set_slpos( window );													/* Sliderposition setzen */

	buf[0] = WM_REDRAW;													/* Nachrichtennummer */
	buf[1] = app_id;														/* Absender der Nachricht */
	buf[2] = 0;																/* öberlÑnge in Bytes */
	buf[3] = window->handle;											/* Fensternummer */
	*(GRECT *)&buf[4] = window->workarea;							/* Fensterkoordinaten */
	appl_write( app_id, 16, buf );									/* Redraw-Meldung an sich selber schicken */
	
	wind_update( END_UPDATE );											/* Bildschirm freigeben */
}
#endif
