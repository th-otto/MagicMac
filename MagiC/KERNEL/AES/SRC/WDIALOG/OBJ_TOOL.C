/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*
*/

#include	<PORTAB.H>
#include	<MATH.H>
#include	<AES.H>

#include	"OBJ_TOOL.H"

#if 0																			/* damit der Linker diese Funktionen nicht einbindet */

/*----------------------------------------------------------------------------------------*/ 
/* Fliežkommazahl in ein Objekt mit TEDINFO-Struktur eintragen										*/
/* Funktionsresultat:	-																						*/
/* obj:						Zeiger auf das Objekt															*/
/* n:							Fliežkommazahl																		*/
/*----------------------------------------------------------------------------------------*/ 
void	double_to_tedinfo( OBJECT *obj, double n )
{
	BYTE	*mask;
	
	mask = obj->ob_spec.tedinfo->te_ptmplt;		/* Zeiger auf die Textmaske */

	while (( *mask ) && ( *mask != '_' ))			/* Beginn der Maske suchen	*/
		mask++;	
	
	if ( *mask )
	{
		BYTE	*text;
		LONG	number;
		WORD	digits1,
				digits2;
		WORD	i;
		
		digits1 = digits2 = 0;

		while ( *mask++ == '_' )
			digits1++;									/* Anzahl der Vorkommastellen erh”hen	*/
		
		if ( *(mask-1) )								/* String noch nicht beendet?	*/
		{
			while ( *mask++ == '_' )
				digits2++;								/* Anzahl der Nachkommastellen erh”hen	*/
		}
		
		number = (LONG) (( n * pow( 10, digits2 )) + 0.5 );
		
		text = obj->ob_spec.tedinfo->te_ptext + digits1 + digits2;
		
		for ( i = digits1 + digits2; i > 0; i-- )
		{
			text--;
			if (( number > 0 ) || ( i >= digits1 ))
				*text = (number % 10) + '0';
			else
				*text = ' ';							/* Die unbenutzen Vorkommastellen mit Leerzeichen auffllen	*/
			number /= 10;
		}
	} 
}

/*----------------------------------------------------------------------------------------*/ 
/* Aus der TEDINFO-Struktur eines Objekts eine Fliežkommazahl extrahieren						*/
/* Funktionsresultat:	Fliežkommazahl																		*/
/* obj:						Zeiger auf das Objekt															*/
/*----------------------------------------------------------------------------------------*/ 
double	tedinfo_to_double( OBJECT *obj )
{
	BYTE	*mask;
	
	mask = obj->ob_spec.tedinfo->te_ptmplt;		/* Zeiger auf die Textmaske */

	while (( *mask ) && ( *mask != '_' ))			/* Beginn der Maske suchen	*/
		mask++;	
	
	if ( *mask )
	{
		BYTE	*text;
		LONG	number;
		WORD	digits1,
				digits2;
		WORD	i;
		
		digits1 = digits2 = 0;

		while ( *mask++ == '_' )
			digits1++;									/* Anzahl der Vorkommastellen erh”hen	*/
		
		if ( *(mask-1) )								/* String noch nicht beendet?	*/
		{
			while ( *mask++ == '_' )
				digits2++;								/* Anzahl der Nachkommastellen erh”hen	*/
		}
		
		text = obj->ob_spec.tedinfo->te_ptext;
		number = 0L;
		
		for ( i = 0; i < digits1 + digits2; i++ )
		{
			BYTE	tmp;
			
			number *= 10;
			tmp = *text++;
						
			if (( tmp >= '0' ) && ( tmp <= '9' ))
				number += tmp - '0';
			else
			{
				if ( i < digits1 )					/* unerlaubte Zeichen im Vorkommabereich?	*/
					number /= 10;						/* dann diese Stelle ignorieren	*/
			}
		}
		return(((double) number ) / pow( 10, digits2 ));
	} 
	return( 0 );
}

#endif

/*----------------------------------------------------------------------------------------*/ 
/* String in Festkommazahl (16.16) umwandeln																*/
/* Funktionsresultat:	Festkommazahl (16.16 - Fixed)													*/
/*	str:						Zeiger auf die Zeichenkette													*/
/*	bad_chars:				wenn 1 zurckgeliefert wird, sind ungltige Zeichen vorhanden		*/
/*----------------------------------------------------------------------------------------*/ 
static LONG str_to_fixed( BYTE *str, WORD *bad_chars )
{
	LONG	number;
	BYTE	*last;
	WORD	digits;
	
	number = get_number( str, &last, &digits );					/* Vorkommateil in Wort umwandeln */
	
	number <<= 16;
		
	if ( *last == '.' )													/* war das letzte Zeichen ein Punkt? */
	{
		LONG	low;
		LONG	divisor;
		LONG	remainder;
		
		low = get_number( last + 1, &last, &digits );			/* Nachkommateil in Wort umwandeln */
		low <<= 16;															/* um 16 Bit nach links shiften */
		
		divisor = 1;
		
		while ( digits > 0 )
		{
			divisor *= 10;													/* divisor = 10^digits */
			digits--;
		}
		
		remainder = low;													/* merken */
		low /= divisor;													/* Nachkommateil */
		remainder -= low * divisor;									/* Rest */

		if (( 2 * remainder ) >= divisor  )							/* Rest > 0.5 * Divisor? */
			low += 1;														/* runden */

		number += low;														/* Nachkommateil addieren */
	}	
	
	if ( *last != 0 )														/* ungltiges Zeichen? */
		*bad_chars = 1;
	else
		*bad_chars = 0;
		
	return( number );
}

/*----------------------------------------------------------------------------------------*/ 
/* String in Zahl umwandeln																					*/
/* Funktionsresultat:	Zahl																					*/
/*	str:						Zeiger auf die Zeichenkette													*/
/*	end:						Adresse des Zeigers auf das erste nicht numerische Zeichen			*/
/*	digits:					Adresse der Ziffernanzahl														*/
/*----------------------------------------------------------------------------------------*/ 
static LONG get_number( BYTE *str, BYTE **end, WORD *digits )
{
	LONG	number;
	BYTE	digit;
	
	*digits = 0;
	number = 0;
		
	while (( digit = *str ) != 0 )
	{
		if (( digit >= '0' ) && ( digit <= '9' ))					/* eine Ziffer? */
		{
			number *= 10;
			number += digit - '0';
			(*digits)++;													/* Anzahl der Ziffern erh”hen */
		}
		else
			break;			

		str++;
	}
	
	*end = str;																/* Zeiger auf das erste nicht numerische Zeichen*/

	return( number );														/* Zahl zurckliefern */
}

/*----------------------------------------------------------------------------------------*/ 
/* Eine Festkommazahl (16.16) umwandeln in ein Textobjekt eintragen								*/
/* Funktionsresultat:	-																						*/
/*	str:						Zeiger auf die Zeichenkette													*/
/*	len:						maximale L„nge ohne Nullbyte													*/
/*	number:					Festkommazahl																		*/
/*----------------------------------------------------------------------------------------*/ 
static void fixed_to_str( BYTE *str, WORD len, LONG number )
{
	LONG	digit;
	LONG	high;
	LONG	low;

	high = number >> 16;													/* Vorkommateil */
	low = number & 0xffffL;												/* Nachkommateil */
	
	if ( high )																/* Vorkommateil > 0? */
	{
		LONG	base;
	
		base = 10000;
	
		while ( base > 0 )
		{
			if ( high / base )
				break;
			base /= 10;
		}
		
		while (( len > 0 ) && ( base > 0 ))
		{
			digit = ( high / base );									/* Ziffer ermitteln */
			*str++ = (BYTE) digit + '0';
			high -= digit * base;										/* vom Vorkommateil subtrahieren */
			base /= 10;
			len--;															/* verbleibende L„nge verringern */												
		}
	}
	else if ( len > 0 )
	{
		*str ++ = '0';														/* Vorkommateil ist 0 */
		len--;																/* verbleibende L„nge verringern */												
	}
	
	if (( len > 1 ) && ( low > 0 ))									/* Nachkommateil vorhanden? */
	{
		*str++ = '.';
		len--;

		low += 1;															/* 1/65536 addieren, um Fehler durch Abrundung zu vermeiden! */

		while (( len > 0 ) && ( low > 10 ))							/* Nachkommateil gr”žer als m”gliche Rechenungenauigkeit? */
		{
			low *= 10;
			digit = low >> 16;											/* Ziffer */
			low -= digit << 16;											/* vom Nachkommateil subtrahieren */
	
			*str++ = (BYTE ) digit + '0';
			len--;															/* verbleibende L„nge verringern */												
		}
	}

	*str++ = 0;															/* String terminieren */
}
