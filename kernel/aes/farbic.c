/*
     Tabulatorweite: 3
     Kommentare ab: Spalte 60                     *Spalte 60*

     Compilerschalter: -B-P
*/

#include <PORTAB.H>
#include <tos.h>
#include "std.h"

/*

     6.8.95:
     - Sonderbehandlung fuer 1 Plane ergaenzt: Andreas Kromke

     25.11.95:
     - Da das MagiC-VDI mittlerweile vq_scrninfo() unterstuetzt, wird bei 
       unbekannten Formaten wieder von gepackten Pixeln ausgegangen (Grafikkarte).

*/

/*----------------------------------------------------------------------------------------*/ 
/* extern aus dem AES                                                                                                                  */
/*----------------------------------------------------------------------------------------*/ 
extern    WORD vintout[];                              /* intout fuer VDI-Aufrufe */
extern    void *xp_tab;
extern    void (*xp_ptr)( void );
extern    void vq_color( WORD index, WORD setflag );   /* aus AESOBJ */
extern    void vq_scrninfo( WORD *work_out );          /* aus AESOBJ */


extern    WORD srchEdDI( void );                       /* EdDI-Cookie suchen */

/*----------------------------------------------------------------------------------------*/ 
/* externe Wandelfunktionen                                                                                                       */
/*----------------------------------------------------------------------------------------*/ 
extern    void xp_ip_4( void );
extern    void xp_ip_8( void );
extern    void xp_pp_4( void );
extern    void xp_pp_8( void );
extern    void xp_pp_16( void );
extern    void xp_pp_24( void );
extern    void xp_pp_32( void );
extern    void xp_unknown( void );
extern    void xp_dummy( void );

extern    LONG W_mul_L( UWORD a, UWORD b );       /* entspricht mulu: w * w => l */
extern    WORD L_div_W( ULONG a, UWORD b );       /* entspricht divu: l / w => w */

WORD      xp_init( WORD planes );
void      xp_colmp( WORD planes, WORD *work_out, UWORD *colour_values );
static    ULONG intensity_to_value( WORD intensity, WORD bits, WORD *bit_no );

static    UBYTE color_remap[16] = { 0,2,3,6,4,7,5,8,9,10,11,14,12,15,13,255 };


static void _vq_scrninfo( WORD *work_out )
{
     if ( srchEdDI() )                            /* vq_scrninfo() vorhanden? */
          vq_scrninfo( work_out );
     else
          work_out[0] = 2;                        /* Packed Pixels */
}


/*------------------------------------------------------------------------------*/ 
/* Expandier-Funktion initialisieren - nur im Supervisor-Modus aufrufen!        */
/* Funktionsresultat:    0: nicht unterstuetztes Format                          */
/*                       1: alles in Ordnung, Format wird unterstuetzt           */
/*                       -1: Format muss nicht gewandelt werden                  */
/*                                                                              */
/* handle:               VDI-Handle des AES                                     */
/* planes:               Anzahl der Ebenen                                      */
/*------------------------------------------------------------------------------*/ 
WORD xp_init( WORD planes )
{
     WORD work_out[272];

     if   ( planes == 1 )                         /* nur eine Ebene? */
     {
          xp_ptr = xp_dummy;
          return( -1 );                           /* Wandlung nicht noetig */
     }

     if ( planes > 8 )                            /* Direct Colour? */
     {
          LONG len;
          
          len = ( planes + 15 ) / 8;              /* Bytes pro Farbe */
          len *= 256;                             /* Platz fuer 256 Farben lassen */
          xp_tab = (void *)mmalloc( len );                 /* Speicher fuer Expandiertabelle */
     }
     /*
     else
          xp_tab = 0L;        wird vom AES erledigt
     */

     _vq_scrninfo( work_out );

     switch( work_out[0] )                        /* Pixelorganisation */
     {
          case 0:                                 /* Interleaved Planes? */
          {
               switch( planes )
               {
                    case 4:   xp_ptr = xp_ip_4;   break;
                    case 8:   xp_ptr = xp_ip_8;   break;
                    default:  xp_ptr = xp_unknown;
               }
               break;
          }
          case 2:                                 /* Packed Pixels? */
          {
               switch( planes )
               {
                    case 4:   xp_ptr = xp_pp_4;   break;
                    case 8:   xp_ptr = xp_pp_8;   break;
                    case 16:  xp_ptr = xp_pp_16;  break;
                    case 24:  xp_ptr = xp_pp_24;  break;
                    case 32:  xp_ptr = xp_pp_32;  break;
                    default:  xp_ptr = xp_unknown;
               }
               break;
          }
          default:  xp_ptr = xp_unknown;
     }
     
     xp_colmp( planes, work_out, (void *) 0 );
     
     if ( xp_ptr == xp_unknown )                  /* unbekanntes Format? */
          return( 0 );
     else
          return( 1 );
}


/**************************************************************************
*
* Berechnet die Farbtabelle fuer direct colour.
* Beim ersten Aufruf ist <colour_values> Null, daher wird der VDI-
* Farbwert ueber vq_color berechnet. Beim Aendern der Palette werden
* 3*256 UWORDs mit den Promillewerten fuer r,g,b uebergeben.
*
**************************************************************************/

void xp_colmp( WORD planes, WORD *work_out, UWORD *colour_values )
{
     WORD _work_out[272];
     register WORD i;
     WORD index;
     register UWORD *wtab = (UWORD *) xp_tab;
     register ULONG *ltab = (ULONG *) xp_tab;
     register UWORD *cv;
     ULONG value;



     if   (!xp_tab)                               /* Indirect Colour? */
          return;                                 /* ja, Ende */

     if   (!work_out)
          {
          work_out = _work_out;
          _vq_scrninfo( work_out );
          }


     for  ( i = 0; i < 256; i++ )
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

          if   (colour_values)
               {
               cv = colour_values+3*index;
               vintout[1] = *cv++;
               vintout[2] = *cv++;
               vintout[3] = *cv;
               }
          else vq_color( index, 0 );

          value = intensity_to_value( vintout[1], work_out[8], &work_out[16] );/* Bitmuster fuer Rot-Intensitaet */
          value |= intensity_to_value( vintout[2], work_out[9], &work_out[32] );/* Bitmuster fuer Gruen-Intensitaet */
          value |= intensity_to_value( vintout[3], work_out[10], &work_out[48] );/* Bitmuster fuer Blau-Intensitaet */

          /* Farbwert ablegen */
          /* ---------------- */

          if   (planes == 16)
               *wtab++ = (UWORD) value;
          else *ltab++ = value;
          }
}


/*----------------------------------------------------------------------------------------*/ 
/* Farbintensitaet in Promille in Pixelwert wandeln                                        */
/* Funktionsresultat:    Pixelwert fuer die uebergebene Farbkomponente                      */
/*   intensity:          Intensitaet in Promille                                           */
/*   bits:               Anzahl der Bits fuer diese Intensitaet                             */
/*   bit_no:             Zuordnung von Bitnummer zum Wert innerhalb des Pixels (work_out) */
/*----------------------------------------------------------------------------------------*/ 
static ULONG intensity_to_value( WORD intensity, WORD bits, WORD *bit_no )
{
     ULONG     value;
     ULONG     ret_val;
     WORD bit;

     value = ( 1L << bits ) - 1;

     value = W_mul_L((UWORD) value, intensity );
     value = L_div_W( value, 1000 );

     ret_val = 0;

     for ( bit = 0; bit < bits; bit++ )
     {
          if ( value & ( 1L << bit ))                  /* Bit gesetzt? */
               ret_val |= ( 1L << ( *bit_no ));

          bit_no++;
     }

     return( ret_val );
}
