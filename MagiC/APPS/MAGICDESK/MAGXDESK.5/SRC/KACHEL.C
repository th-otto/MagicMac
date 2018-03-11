/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*
*/

/*----------------------------------------------------------------------------------------*/ 
/* Globale Includes																								*/
/*----------------------------------------------------------------------------------------*/ 
#include <PORTAB.H>
#include	<AES.H>
#include <VDI.H>
#include <TOS.H> 
#include	<STDDEF.H>

#include "kachel.h"
#include "imgload.h"

/*----------------------------------------------------------------------------------------*/ 
/* Defines                                                                                */
/*----------------------------------------------------------------------------------------*/ 

#define	max( A,B ) ( (A)>(B) ? (A) : (B) )
#define	min( A,B ) ( (A)<(B) ? (A) : (B) )

extern	WORD	vdi_handle;
extern WORD rc_intersect( GRECT *p1, GRECT *p2 );

static MFDB *fill;

/*--------------------------------------------------------------------*/ 
/* Titelzeile mit Unterstreichung ausgeben						*/
/* Funktionsresultat:	nicht aktualisierte Objektstati			*/
/* parmblock:				Zeiger auf die Parameter-Block-Struktur	*/
/*--------------------------------------------------------------------*/ 
WORD	cdecl drawdesk( PARMBLK *parmblock )
{
	WORD	x;
	WORD	y;
	extern int clip_rect[4];		/* Clipping-Rechteck */
	WORD	obj[4];				/* Grîûe des zu zeichnenden Bildbereichs */
	WORD	r[8];				/* wird be vro_cpyfm() benutzt */
	MFDB	screen;				/* MFDB fÅr Bildschirm */

	*(GRECT *) clip_rect = *(GRECT *) &parmblock->pb_x;
	*(GRECT *) obj = *(GRECT *) &parmblock->pb_x;
	obj[2] += obj[0] - 1;
	obj[3] += obj[1] - 1;		/* GRECT->RECT */

	/* Schneide Objekt-GRECT mit Clipping-GRECT => clip_rect*/
	rc_intersect( (GRECT *) &parmblock->pb_xc, (GRECT *) clip_rect );	/* Clipping-Rechteck */
	/* clip_rect GRECT -> RECT */
	clip_rect[2] += clip_rect[0] - 1;
	clip_rect[3] += clip_rect[1] - 1;
	vs_clip( vdi_handle, 1, clip_rect );	/* Zeichenoperationen auf gegebenen Bereich beschrÑnken */

	screen.fd_addr = 0L;		/* Bildschirm */

	obj[0] -= obj[0] % fill->fd_w;	/* x-Startkoordinate an Musterbreite ausrichten */
	obj[1] -= obj[1] % fill->fd_h;	/* y-Startkoordinate an Musterhîhe ausrichten */

	r[0] = 0;
	r[1] = 0;
	r[2] = fill->fd_w - 1;
	r[3] = fill->fd_h - 1;

/*	for ( y = obj[1]; y <= obj[3]; y += fill->fd_h )	*/
	for ( y = obj[1]; y <= clip_rect[3]; y += fill->fd_h )
	{
		r[5] = y;
		r[7] = y + fill->fd_h - 1;

/*		for ( x = obj[0]; x <= obj[2]; x += fill->fd_w )	*/
		for ( x = obj[0]; x <= clip_rect[2]; x += fill->fd_w )	
		{
			r[4] = x;
			r[6] = x + fill->fd_w - 1;

			if ( fill->fd_nplanes == 1 )									/* monochromes IMG? */
			{
				WORD	colors[2] = { 1, 0 };

				vrt_cpyfm( vdi_handle, 1, r, fill, &screen, colors );
			}
			else
				vro_cpyfm( vdi_handle, 3, r, fill, &screen );
		}
	}
	
	return( parmblock->pb_currstate );
}


static WORD min_index = 0;	/* Index des ersten verÑnderbaren Farbregisters */
static WORD cdecl (*xp_raster)( LONG words, LONG len, WORD planes, void *src, void *des );
static MFDB pat;
static void *exp_img;
static UBYTE *img;
static WORD *palette;

/* max_pen = work_out[13] - 1;	*/	/* hîchste Farbstiftnummer */

int kachel_init( char *path, WORD max_pen )
{
	LONG err;
	WORD	index;
	WORD	pen;
	WORD	w;
	WORD	h;
	WORD	line_width;
	WORD	planes;
	WORD	pal_entries;
	WORD	extnd_out[128];
	static UBYTE color_map[16] = { 0, 255, 1, 2, 4, 6, 3, 5, 7 , 8, 9, 10, 12, 14, 11, 13 };
	LONG	plane_len;
	struct {
		long		magic;
		int		subfn;
		int		xp_mode;		/* RÅckgabewert von xp_init */
		void		*xp_raster;	/* Assemblerfunktion */
		void		*xp_rasterC;	/* cdecl-Funktion */
	} magic_rcfix;



	vq_extnd( vdi_handle, 1, extnd_out );

	min_index = 16;
	magic_rcfix.magic = 'MagC';
	magic_rcfix.subfn = 1;
	magic_rcfix.xp_rasterC = NULL;
	if	(!rsrc_rcfix((RSHDR *) &magic_rcfix))	/* Fehler */
		return(-1);
	if	(!magic_rcfix.xp_rasterC)
		return(-1);
	if	(!magic_rcfix.xp_mode)
		return(-1);
	xp_raster = magic_rcfix.xp_rasterC;

	err = load_IMG( path, &w, &h, &line_width, &planes, &palette, &pal_entries,
					&img );
	if	(err < 0)
		return(-2);		/* Fehler beim Laden */

	fill = &pat;
	fill->fd_w = w;
	fill->fd_h = h;
	fill->fd_wdwidth = line_width / 2;
	fill->fd_stand = 0;
	fill->fd_r1 = 0;
	fill->fd_r2 = 0;
	fill->fd_r3 = 0;

	if	( (planes > 1) && (magic_rcfix.xp_mode > 0) )	/* farbiges IMG? */
		{
		exp_img = Malloc((LONG) line_width * h * extnd_out[4] );	/* Speicher fÅr expandiertes IMG anfordern */

		if	(! exp_img )
			{
			Mfree(img);
			return(-3);
			}
			
		plane_len = (LONG) line_width * h;		/* LÑnge einer Ebene */

		if ( (*xp_raster)( plane_len / 2, plane_len, planes, img, exp_img ))	/* IMG expandierbar? */
			{
			fill->fd_addr = exp_img;
			fill->fd_nplanes = extnd_out[4];
			}
		else	{
			Mfree(img);
			Mfree(exp_img);
			return(-4);
			}
		}
	else							/* monochromes IMG */
		{
		exp_img = 0L;

		fill->fd_addr = img;
		fill->fd_nplanes = planes;
		}

	if	( palette )				/* Palette vorhanden? */
		{

		if (( pal_entries - 1 ) > max_pen )	/* mehr PaletteneintrÑge als Farbstifte??? */
			pal_entries = max_pen + 1;
	
		for ( pen = 0; pen < pal_entries; pen++ )
			{
			if ( pen < 16 )		/* Systemfarbe? */
				index = color_map[pen] & max_pen;	/* dann Index anpassen */
			else if ( pen == 255 )
				index = 15;
			else
				index = pen;
			
			if ( pen >= min_index )	/* darf die Farbe verÑndert werden? */
				vs_color( vdi_handle, pen, palette + (index * 3) );
		}
	}
	return(0);
}


void kachel_exit( void )
{
	if ( exp_img )
		Mfree( exp_img );	/* Speicher fÅr expandiertes IMG freigeben */

	if ( palette )
		Mfree( palette );	/* Speicher fÅr Palette freigeben */

	if	(img)
		Mfree( img );		/* Speicher fÅr IMG freigeben */
}
