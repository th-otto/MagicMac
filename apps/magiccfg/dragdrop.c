/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*
*/

#include <portab.h>
#include <signal.h>
#include <tos.h>
#include <aes.h>
#include <string.h>
#include "dragdrop.h"
#include "toserror.h"

/*----------------------------------------------------------------------------------------*/
/* Drag & Drop - Pipe �ffnen (f�r den Sender)															*/
/* Funktionsresultat:	Handle der Pipe, -1 f�r Fehler oder -2 f�r Fehler bei appl_write	*/
/*	app_id:					ID des Senders (der eigenen Applikation)									*/
/*	rcvr_id:					ID des Empf�ngers																	*/
/*	window:					Handle des Empf�nger-Fensters													*/
/*	mx:						x-Koordinate der Maus beim Loslassen oder -1								*/
/*	my:						y-Koordinate der Maus beim Loslassen oder -1								*/
/*	kbstate:					Status der Kontrolltasten														*/
/*	format:					Feld f�r die max. 8 vom Empf�nger unterst�tzten Formate				*/
/*	oldpipesig:				Zeiger auf den alten Signal-Dispatcher										*/
/*----------------------------------------------------------------------------------------*/
WORD	ddcreate( WORD	app_id, WORD rcvr_id, WORD window, WORD mx, WORD my, WORD kbstate, ULONG format[8], void **oldpipesig )
{
	BYTE	pipe[24];
	WORD	mbuf[8];
	LONG	handle_mask;
	WORD	handle, i;

	strcpy( pipe, "U:\\PIPE\\DRAGDROP.AA" );
	pipe[18] = 'A' - 1;

	do
	{
		pipe[18]++;															/* letzten Buchstaben weitersetzen */
		if ( pipe[18] > 'Z' )											/* kein Buchstabe des Alphabets? */
		{
			pipe[17]++;														/* ersten Buchstaben der Extension �ndern */
			if ( pipe[17] > 'Z' )										/* lie� sich keine Pipe �ffnen? */
				return( -1 );
		}

		handle = (WORD) Fcreate( pipe, 0x02 );						/* Pipe anlegen, 0x02 bedeutet, da� EOF zur�ckgeliefert wird, */
																				/* wenn die Pipe von niemanden zum Lesen ge�ffnet wurde */
	} while ( handle == EACCDN );

	if ( handle < 0 )														/* lie� sich die Pipe nicht anlegen? */
		return( handle );

	mbuf[0] = AP_DRAGDROP;												/* Drap&Drop-Message senden */
	mbuf[1] = app_id;														/* ID der eigenen Applikation */
	mbuf[2] = 0;
	mbuf[3] = window;														/* Handle des Fensters */
	mbuf[4] = mx;															/* x-Koordinate der Maus */
	mbuf[5] = my;															/* y-Koordinate der Maus */
	mbuf[6] = kbstate;													/* Tastatur-Status */
	mbuf[7] = (((WORD) pipe[17]) << 8 ) + pipe[18];				/* Endung des Pipe-Namens */

	if ( appl_write( rcvr_id, 16, mbuf ) == 0 )					/* Fehler bei appl_write()? */
	{
		Fclose( handle );													/* Pipe schlie�en */
		return( -2 );
	}

	handle_mask = 1L << handle;
	i = Fselect( DD_TIMEOUT, &handle_mask, 0L, 0L );			/* auf Antwort warten */

	if ( i && handle_mask )												/* kein Timeout? */
	{
		BYTE	reply;
		
		if ( Fread( handle, 1L, &reply ) == 1 )					/* Antwort vom Empf�nger lesen */
		{
			if ( reply == DD_OK )										/* alles in Ordnung? */
			{
				if ( Fread( handle, DD_EXTSIZE, format ) == DD_EXTSIZE )	/* unterst�tzte Formate lesen */
				{
					*oldpipesig = Psignal( __MINT_SIGPIPE, __MINT_SIG_IGN );	/* Dispatcher ausklinken */
					return( handle );
				}
			}
		}
	}

	Fclose( handle );														/* Pipe schlie�en */
	return( -1 );
}


/*----------------------------------------------------------------------------------------*/
/* Drag & Drop - �berpr�fen ob der Empf�nger ein Format akzeptiert								*/
/* Funktionsresultat:	DD_OK: Empf�nger unters�tzt das Format										*/
/*								DD_EXT: Empf�nger akzeptiert das Format nicht							*/
/*								DD_LEN: Daten sind zu lang f�r den Empf�nger								*/
/*								DD_NAK: Fehler bei Kommunikation												*/								
/*	handle:					Handle der Pipe																	*/
/*	format:					K�rzel f�r das Format															*/
/*	name:						Beschreibung des Formats als C-String										*/
/*	size:						L�nge der zu sendenen Daten													*/
/*----------------------------------------------------------------------------------------*/
WORD	ddstry( WORD handle, ULONG format, BYTE *name, LONG size )
{
	LONG	str_len;
	WORD	hdr_len;
	
	str_len = strlen( name ) + 1;										/* L�nge des Strings inklusive Nullbyte */
	hdr_len = 4 + 4 + (WORD) str_len;								/* L�nge des Headers */

	if ( Fwrite( handle, 2, &hdr_len ) == 2 )						/* L�nge des Headers senden */
	{
		LONG	written;
		
		written = Fwrite( handle, 4, &format );					/* Formatk�rzel */
		written += Fwrite( handle, 4, &size );						/* L�nge der zu sendenden Daten */
		written += Fwrite( handle, str_len, name );				/* Beschreibung des Formats als C-String */

		if ( written == hdr_len )										/* lie� sich der Header schreiben? */
		{
			BYTE	reply;
			
			if ( Fread( handle, 1, &reply ) == 1 )
				return( reply );											/* Antwort zur�ckliefern */
		}
	}	
	return( DD_NAK );
}

/*----------------------------------------------------------------------------------------*/
/* Drag & Drop - Pipe schlie�en																				*/
/*	handle:					Handle der Pipe																	*/
/* oldpipesig:				Zeiger auf den alten Signalhandler											*/
/*----------------------------------------------------------------------------------------*/
void	ddclose( WORD handle, __mint_sighandler_t oldpipesig )
{
	Psignal( __MINT_SIGPIPE, oldpipesig );									/* wieder alten Dispatcher eintragen */
	Fclose( handle );														/* Pipe schlie�en */
}

/*----------------------------------------------------------------------------------------*/
/* Drag & Drop - Pipe �ffnen (f�r den Empf�nger)														*/
/* Funktionsresultat:	Handle der Pipe oder -1 (Fehler)												*/
/* pipe:						Zeiger auf den Namen der Pipe ("DRAGDROP.??")							*/
/* format:					Zeiger auf Array mit unterst�tzten Datenformaten						*/
/* oldpipesig:				Zeiger auf den Zeiger auf den alten Signalhandler						*/
/*----------------------------------------------------------------------------------------*/
WORD	ddopen( BYTE *pipe, ULONG format[8], __mint_sighandler_t *oldpipesig )
{
	WORD	handle;
	BYTE	reply;

	handle = (WORD) Fopen( pipe, FO_RW );							/* Handle der Pipe erfragen	*/
	if ( handle < 0 )
		return( -1 );

	reply = DD_OK;															/* Programm unterst�tzt Drag & Drop	*/

	*oldpipesig = Psignal( __MINT_SIGPIPE, __MINT_SIG_IGN );		/* Signal ignorieren	*/

	if ( Fwrite( handle, 1, &reply ) == 1 )
	{
		if ( Fwrite( handle, DD_EXTSIZE, format ) == DD_EXTSIZE )
			return( handle );
	}

	ddclose( handle, *oldpipesig );									/* Pipe schlie�en */
	return( -1 );
}

/*----------------------------------------------------------------------------------------*/
/* Header f�r Drag & Drop einlesen																			*/
/* Funktionsresultat:	0 Fehler 1: alles in Ordnung													*/
/*	handle:					Handle der Pipe																	*/
/* name:						Zeiger auf Array f�r den Datennamen											*/
/* format:					Zeiger auf ein Long, das das Datenformat anzeigt						*/
/* size:						Zeiger auf ein Long f�r die L�nge der Daten								*/
/*----------------------------------------------------------------------------------------*/
WORD	ddrtry( WORD handle, BYTE *name, ULONG *format, LONG *size )
{
	WORD	hdr_len;

	if ( Fread( handle, 2, &hdr_len ) == 2 )						/* Headerl�nge auslesen	*/
	{
		if ( hdr_len >= 9 )												/* kompletter Header?	*/
		{
			if ( Fread( handle, 4, format ) == 4 )					/* Datentyp auslesen	*/
			{
				if ( Fread( handle, 4, size ) == 4 )				/* L�nge der Daten in Bytes auslesen */
				{	
					WORD	name_len;
					
					name_len = hdr_len -= 8;							/* L�nge des Namens inklusive Nullbyte */

					if ( name_len > DD_NAMEMAX )				
						name_len = DD_NAMEMAX;

					if ( Fread( handle, name_len, name ) == name_len )	/* Datennamen auslesen	*/
					{
						BYTE	buf[64];
					
						hdr_len -= name_len;
	
						while ( hdr_len > 64 )							/* Headerrest auslesen	*/
						{
							Fread( handle, 64, buf );
							hdr_len -= 64;
						}
		
						if ( hdr_len > 0 )
							Fread( handle, hdr_len, buf );
	
						return( 1 );
					}
				}
			}
		}
	}
	return( 0 );															/* Fehler */
}

/*----------------------------------------------------------------------------------------*/
/* Meldung an den Drag & Drop - Initiator senden														*/
/* Funktionsresultat:	0: Fehler 1: alles in Ordnung													*/
/*	handle:					Handle der Pipe																	*/
/* msg:						Nachrichtennummer																	*/
/*----------------------------------------------------------------------------------------*/
WORD	ddreply( WORD handle, WORD msg )
{
	if ( Fwrite( handle, 1, ((BYTE *) &msg ) + 1 ) != 1 )		/* Fehler? */
	{
		Fclose( handle );													/* Pipe schlie�en */
		return( 0 );
	}
	return( 1 );
}
 
