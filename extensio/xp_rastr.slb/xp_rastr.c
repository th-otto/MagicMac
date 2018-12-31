/*
*
* "shared library" zur Expandierung einer Bitmap.
* Wird fÅr die Ausgabe von Farbicons oder Pixelbildern
* (IMG) benîtigt.
* Die im Standard-Format (Planes hintereinander) vorliegende
* Bitmap wird auf die Bildschirm-Bit-Tiefe expandiert und
* hardwareabhÑngig umgewandelt.
*
*
* (C) Seven Behne 1996
*
* Implementation als SLB:
*  Andreas Kromke
*  22.10.97
*
*/

#include <portab.h>
#include <tos.h>
#include <toserror.h>
#include <vdi.h>
#include "farbicon.h"

#pragma warn -par

typedef struct {
	char intern[128];
	char cmd[128];
} PD;

struct initparm {
	VDIPB *vdipb;
	WORD nplanes;
};

void *xp_tab;		/* Farbtabelle Index => Farbe */
void (*xp_ptr)( void );
static UBYTE color_remap[16] = { 0,2,3,6,4,7,5,8,9,10,11,14,12,15,13,255 };
static WORD nplanes;

static void xp_colmp( VDIPB *vdipb, WORD planes,
				WORD *work_out, UWORD *colour_values );
static ULONG intensity_to_value( WORD intensity, WORD bits, WORD *bit_no );


/*****************************************************************
*
* Ab MagiC 6 erhÑlt man den eigenen PD und optional einen
* Parameter.
*
* RÅckgabe:		-1L	Wandlung nicht notwendig
*				-2L	unbekanntes Format
*				0L	OK
*
*****************************************************************/

extern LONG cdecl slb_init( PD *mypd, struct initparm *ip )
{
	WORD	work_out[272];
	WORD planes = ip->nplanes;
	LONG	len;


	if	( planes <= 1 )	/* nur eine Ebene? */
		return(ERROR);		/* Wandlung nicht nîtig */

	_vq_scrninfo( ip->vdipb, work_out );

	switch( work_out[0] )		/* Pixelorganisation */
	{
		case	0:				/* Interleaved Planes? */
		{
			switch( planes )
			{
				case	4:	xp_ptr = xp_ip_4;	break;
				case	8:	xp_ptr = xp_ip_8;	break;
				default:	return(-2L);	/* unbekanntes Format */
			}
			break;
		}
		case	2:				/* Packed Pixels? */
		{
			switch( planes )
			{
				case	4:	xp_ptr = xp_pp_4;	break;
				case	8:	xp_ptr = xp_pp_8;	break;
				case	16:	xp_ptr = xp_pp_16;	break;
				case	24:	xp_ptr = xp_pp_24;	break;
				case	32:	xp_ptr = xp_pp_32;	break;
				default:	return(-2L);	/* unbekanntes Format */
			}
			break;
		}
		default:	return(-2L);	/* unbekanntes Format */
	}

	if	( planes > 8 )		/* Direct Colour? */
		{
		len = ( planes + 15 ) / 8;	/* Bytes pro Farbe */
		len *= 256;				/* Platz fÅr 256 Farben lassen */
		xp_tab = Malloc( len );		/* Speicher fÅr Expandiertabelle */
		}
	/*
	else
		xp_tab = 0L;		ist so initialisiert.
	*/

	xp_colmp( ip->vdipb, planes, work_out, (void *) 0 );

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

extern LONG cdecl slb_open( PD *pd )
{
	return(E_OK);
}


/*****************************************************************
*
*****************************************************************/

extern void cdecl slb_close( PD *pd )
{
}


/************************************************************************
*
* Berechnet die Farbtabelle fÅr direct colour.
* Beim ersten Aufruf ist <colour_values> Null, daher wird der VDI-
* Farbwert Åber vq_color berechnet. Beim éndern der Palette werden
* 3*256 UWORDs mit den Promillewerten fÅr r,g,b Åbergeben.
*
************************************************************************/

static void xp_colmp( VDIPB *vdipb, WORD planes,
				WORD *work_out, UWORD *colour_values )
{
	int *vintout;
	WORD	_work_out[272];
	register WORD i;
	WORD	index;
	register UWORD *wtab = (UWORD *) xp_tab;
	register ULONG *ltab = (ULONG *) xp_tab;
	register UWORD *cv;
	ULONG value;



	if	(!xp_tab)							/* Indirect Colour? */
		return;							/* ja, Ende */

	if	(vdipb)
		vintout = vdipb->intout;

	if	(!work_out)
		{
		work_out = _work_out;
		_vq_scrninfo( vdipb, work_out );
		}


	for	( i = 0; i < 256; i++ )
		{

		/* Pixelwert in VDI-Farbindex umrechnen */
		/* ------------------------------------ */

		if ( i < 16 )
			index = color_remap[i];
		else if ( i < 255 )
			index = i;
		else
			index = 1;

		/* Farbwert berechnen */
		/* ------------------ */

		if	(colour_values)
			{
			cv = colour_values+3*index;
			vintout[1] = *cv++;
			vintout[2] = *cv++;
			vintout[3] = *cv;
			}
		else	_vq_color( vdipb, index, 0 );

		value = intensity_to_value( vintout[1], work_out[8], &work_out[16] );/* Bitmuster fÅr Rot-IntensitÑt */
		value |= intensity_to_value( vintout[2], work_out[9], &work_out[32] );/* Bitmuster fÅr GrÅn-IntensitÑt */
		value |= intensity_to_value( vintout[3], work_out[10], &work_out[48] );/* Bitmuster fÅr Blau-IntensitÑt */

		/* Farbwert ablegen */
		/* ---------------- */

		if	(planes == 16)
			*wtab++ = (UWORD) value;
		else	*ltab++ = value;
		}
}


/*----------------------------------------------------------------------------------------*/ 
/* FarbintensitÑt in Promille in Pixelwert wandeln								*/
/* Funktionsresultat:	Pixelwert fÅr die Åbergebene Farbkomponente					*/
/*	intensity:		IntensitÑt in Promille									*/
/*	bits:			Anzahl der Bits fÅr diese IntensitÑt						*/
/*	bit_no:			Zuordnung von Bitnummer zum Wert innerhalb des Pixels (work_out)	*/
/*----------------------------------------------------------------------------------------*/ 
static ULONG intensity_to_value( WORD intensity, WORD bits, WORD *bit_no )
{
	ULONG	value;
	ULONG	ret_val;
	WORD	bit;

	value = ( 1L << bits ) - 1;

	value = W_mul_L((UWORD) value, intensity );
	value = L_div_W( value, 1000 );

	ret_val = 0;

	for ( bit = 0; bit < bits; bit++ )
	{
		if ( value & ( 1L << bit ))				/* Bit gesetzt? */
			ret_val |= ( 1L << ( *bit_no ));

		bit_no++;
	}

	return( ret_val );
}


/*****************************************************************
*
* Funktion #0: Gibt Funktionszeiger fÅr Assembler- und
* 'cdecl'-Zugriff zurÅck.
*
*****************************************************************/

extern LONG cdecl slb_fn0( PD *pd, LONG fn, WORD nargs,
					void **xp_r_ass, void **xp_r_cdecl )
{
	if	(nargs >= 2)
		*xp_r_ass = &xp_raster;
	if	(nargs >= 4)
		*xp_r_cdecl = &xp_rasterC;
	return(E_OK);
}


/*****************************************************************
*
* Funktion #1: neue Farbtabelle Åbergeben.
*
*****************************************************************/

extern LONG cdecl slb_fn1( PD *pd, LONG fn, WORD nargs,
					UWORD *colour_values )
{
	xp_colmp( (void *) 0L, nplanes, (void *) 0L, colour_values );
	return(E_OK);
}
