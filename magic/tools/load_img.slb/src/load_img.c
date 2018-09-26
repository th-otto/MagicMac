/*
*
* "shared library" zum Laden einer IMG-Datei.
*
*
* (C) Behne&Behne 1996
*
* Implementation als SLB:
*  Andreas Kromke
*  31.1.98
*
*/

#define DEBUG 0

#if DEBUG
#include <stdio.h>
#endif
#include <tos.h>
#include <vdi.h>
#include "imgload.h"
#include "load_img.h"

#pragma warn -par

#define MIN(a,b) ((a < b) ? a : b)
#define MAX(a,b) ((a > b) ? a : b)
#define ABS(X) ((X>0) ? X : -X)

typedef struct
{
	WORD	g_x;
	WORD	g_y;
	WORD	g_w;
	WORD	g_h;
} GRECT;

typedef struct {
	char intern[128];
	char cmd[128];
} PD;

struct initparm conf;

#if DEBUG
WORD errno;
#endif

/*****************************************************************
*
* Ab MagiC 6 erh„lt man den eigenen PD und optional einen
* Parameter.
*
*****************************************************************/

extern LONG cdecl slb_init( PD *mypd, struct initparm *parm )
{
	conf = *parm;
	return(E_OK);
}


/*****************************************************************
*
*****************************************************************/

extern void cdecl slb_exit( void )
{
}


/*****************************************************************
*
*****************************************************************/

extern LONG cdecl slb_open( PD *pd, LONG parm )
{
	return(E_OK);
}


/*****************************************************************
*
*****************************************************************/

extern void cdecl slb_close( PD *pd )
{
}


/*****************************************************************
*
* Funktion #0: IMG laden.
*
*****************************************************************/

extern LONG cdecl slb_fn0( PD *pd, LONG fn, WORD nargs,
					char *path, img_descriptor **pimg )
{
	img_descriptor *img = Malloc(sizeof(img_descriptor));

#if DEBUG
	printf("Lade %s\n", path);
	Cconin();
#endif

	*pimg = img;
	if	(!img)
		return(ENSMEM);
	return(load_IMG( path, &img->w, &img->h,
		&img->line_width, &img->nplanes,
		&img->palette, &img->pal_entries,
		&img->buf ));
}


/*****************************************************************
*
* Funktion #1: IMG freigeben.
*
*****************************************************************/

extern LONG cdecl slb_fn1( PD *pd, LONG fn, WORD nargs,
					img_descriptor *img )
{
	if	(img->buf)
		Mfree(img->buf);
	if	(img->palette)
		Mfree(img->palette);
	Mfree(img);
	return(E_OK);
}


/*****************************************************************
*
* Funktion #2: IMG in Bildschirmdarstellung wandeln.
* <max_pen> ist i.a. work_out[13] - 1
*
*****************************************************************/

extern LONG cdecl slb_fn2( PD *pd, LONG fn, WORD nargs,
					img_descriptor *img,
					MFDB *fill,
					WORD min_index,
					WORD max_pen,
					WORD vdi_handle )
{
	WORD	index;
	WORD	pen;
	static UBYTE color_map[16] = { 0, 255, 1, 2, 4, 6, 3, 5, 7 , 8, 9, 10, 12, 14, 11, 13 };
	LONG	plane_len;
	void *exp_img;


#if DEBUG
	printf("Einstellungen:\n"
			"xp_raster = %08lx\n"
			"xp_ret = %08lx\n",
			conf.xp_raster,
			conf.xp_ret);

	printf("Wandle Bild:\n"
			"desc = %08lx\n"
			"fill = %08lx\n"
			"min_index = %d max_pen = %d vdi_handle = %d\n",
			img,
			fill,
			min_index,
			max_pen,
			vdi_handle);

	printf("Bild:\n"
		"w = %d\n"
		"h = %d\n"
		"planes = %d\n",
		img->w,img->h,img->nplanes);
	Cconin();
#endif

/*	min_index = 16;	*/

	fill->fd_w = img->w;
	fill->fd_h = img->h;
	fill->fd_wdwidth = img->line_width / 2;
	fill->fd_stand = 0;
	fill->fd_r1 = 0;
	fill->fd_r2 = 0;
	fill->fd_r3 = 0;

	if	( (img->nplanes > 1) && (conf.xp_ret >= 0) )	/* farbiges IMG? */
		{
		exp_img = Malloc((LONG) img->line_width * img->h * conf.nplanes );	/* Speicher fr expandiertes IMG anfordern */

		if	(! exp_img )
			return(ENSMEM);

		plane_len = (LONG) img->line_width * img->h;		/* L„nge einer Ebene */

		if ( (*conf.xp_raster)( plane_len / 2,
						plane_len,
						img->nplanes, 
						img->buf,
						exp_img ))	/* IMG expandierbar? */
			{
			fill->fd_addr = exp_img;
			fill->fd_nplanes = conf.nplanes;
			}
		else	{
			Mfree(exp_img);
#if DEBUG
	printf("Fehler beim Wandeln?\n");
#endif
			return(ERROR);
			}
		}
	else						/* monochromes IMG */
		{
		exp_img = 0L;

		fill->fd_addr = img->buf;
		fill->fd_nplanes = img->nplanes;
		}

	if	( img->palette )				/* Palette vorhanden? */
		{

		if (( img->pal_entries - 1 ) > max_pen )	/* mehr Paletteneintr„ge als Farbstifte??? */
			img->pal_entries = max_pen + 1;
	
		for ( pen = 0; pen < img->pal_entries; pen++ )
			{
			if ( pen < 16 )		/* Systemfarbe? */
				index = color_map[pen] & max_pen;	/* dann Index anpassen */
			else if ( pen == 255 )
				index = 15;
			else
				index = pen;
			
			if ( pen >= min_index )	/* darf die Farbe ver„ndert werden? */
				vs_color( vdi_handle, pen, img->palette + (index * 3) );
		}
	}
	return(E_OK);
}


/*****************************************************************
*
* Funktion #3: zeichnen
*
*****************************************************************/

extern LONG cdecl slb_fn3( PD *pd, LONG fn, WORD nargs,
				WORD vdi_handle, MFDB *fill, WORD x, WORD y )
{
	WORD	r[8];				/* wird bei vro_cpyfm() benutzt */
	MFDB	screen;				/* MFDB fr Bildschirm */

	screen.fd_addr = 0L;		/* Bildschirm */

	r[0] = 0;
	r[1] = 0;
	r[2] = fill->fd_w - 1;
	r[3] = fill->fd_h - 1;
	r[5] = y;
	r[7] = y + fill->fd_h - 1;
	r[4] = x;
	r[6] = x + fill->fd_w - 1;
	if	( fill->fd_nplanes == 1 )									/* monochromes IMG? */
		{
		WORD	colors[2] = { 1, 0 };

		vrt_cpyfm( vdi_handle, 1, r, fill, &screen, colors );
		}
	else	{
		vro_cpyfm( vdi_handle, 3, r, fill, &screen );
		}

	return( E_OK );
}


/****************************************************************
*
* Bestimmt die Schnittmenge zwischen zwei Rechtecken
*
****************************************************************/

static int rc_intersect(GRECT *p1, GRECT *p2)
{
	int	tx, ty, tw, th;

	tw = MIN(p2->g_x + p2->g_w, p1->g_x + p1->g_w);
	th = MIN(p2->g_y + p2->g_h, p1->g_y + p1->g_h);
	tx = MAX(p2->g_x, p1->g_x);
	ty = MAX(p2->g_y, p1->g_y);
	p2->g_x = tx;
	p2->g_y = ty;
	p2->g_w = tw - tx;
	p2->g_h = th - ty;
	return( (tw > tx) && (th > ty) );
}


/*****************************************************************
*
* Funktion #4: Kacheln zeichnen
*
*****************************************************************/

extern LONG cdecl slb_fn4( PD *pd, LONG fn, WORD nargs,
				WORD vdi_handle, MFDB *fill,
				GRECT *g, GRECT *clipg )
{
	WORD	x;
	WORD	y;
	WORD clip_rect[4];			/* Clipping-Rechteck */
	WORD	obj[4];				/* Gr”že des zu zeichnenden Bildbereichs */
	WORD	r[8];				/* wird be vro_cpyfm() benutzt */
	MFDB	screen;				/* MFDB fr Bildschirm */


	screen.fd_addr = 0L;		/* Bildschirm */

	*(GRECT *) obj = *g;
	obj[2] += obj[0] - 1;
	obj[3] += obj[1] - 1;		/* GRECT->RECT */

	*(GRECT *) clip_rect = *g;
	/* Schneide Objekt-GRECT mit Clipping-GRECT => clip_rect*/
	rc_intersect( clipg, (GRECT *) clip_rect );	/* Clipping-Rechteck */
	/* clip_rect GRECT -> RECT */
	clip_rect[2] += clip_rect[0] - 1;
	clip_rect[3] += clip_rect[1] - 1;
	vs_clip( vdi_handle, 1, clip_rect );	/* Zeichenoperationen auf gegebenen Bereich beschr„nken */


	obj[0] -= obj[0] % fill->fd_w;	/* x-Startkoordinate an Musterbreite ausrichten */
	obj[1] -= obj[1] % fill->fd_h;	/* y-Startkoordinate an Musterh”he ausrichten */

	r[0] = 0;
	r[1] = 0;
	r[2] = fill->fd_w - 1;
	r[3] = fill->fd_h - 1;

	for ( y = obj[1]; y <= clip_rect[3]; y += fill->fd_h )
	{
		r[5] = y;
		r[7] = y + fill->fd_h - 1;

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
	
	return( E_OK );
}
