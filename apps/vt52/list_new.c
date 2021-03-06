/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*
*/

/*----------------------------------------------------------------------------------------*/
/* Routinen zum Verwalten einer einfach verketteten Liste. 											*/
/* LIST_ENTRY * ist immer ein Zeiger auf die nachfolgende Struktur, z.B. &FONT->next		*/
/*																														*/
/*	30.08.95																											*/
/*																														*/
/*----------------------------------------------------------------------------------------*/
#include <portab.h>
#include <stddef.h>

#include <tos.h>
#include <vdi.h>
#include <list.h>

#define	NEXT( ptr, offset )	( * (void **) ((char *) ptr + offset ))

/*----------------------------------------------------------------------------------------*/
/* Eintrag aus der verketteten Liste entfernen															*/
/* Funktionsresultat:	0: Fehler 1: Eintrag entfernt													*/
/*	root:						Zeiger auf den Zeiger auf den ersten Eintrag								*/
/* entry:					Zeiger auf den Eintrag															*/
/*----------------------------------------------------------------------------------------*/
int	list_remove( void **root, void *entry, int32_t offset )
{
	void	*search;

	search = (void *) ((char *) root - offset );				/* virtueller Anfangseintrag */

	while ( NEXT( search, offset ))									/* Nachfolger vorhanden? */
	{
		void	*prev;

		prev = search;
		search = NEXT( search, offset );
		
		if ( search == entry )											/* gesuchter Eintrag? */
		{
			NEXT( prev, offset ) = NEXT( search, offset );		/* Eintrag ausketten */
			return( 1 );
		}
		
	}
	return( 0 );
}

/*----------------------------------------------------------------------------------------*/
/* Eintrag als erstes Element in die verkettete Liste einf�gen										*/
/* Funktionsresultat:	1: alles in Ordnung																*/
/*	root:						Zeiger auf den Zeiger auf den ersten Eintrag								*/
/* entry:					Zeiger auf den Eintrag															*/
/*----------------------------------------------------------------------------------------*/
void	list_insert( void **root, void *entry, int32_t offset )
{
	NEXT( entry, offset ) = *root;
	*root = entry;
}

/*----------------------------------------------------------------------------------------*/
/* Eintrag and die verkettete Liste anh�ngen																*/
/* Funktionsresultat:	1: alles in Ordnung																*/
/*	root:						Zeiger auf den Zeiger auf den ersten Eintrag								*/
/* entry:					Zeiger auf den Eintrag															*/
/*----------------------------------------------------------------------------------------*/
void	list_append( void **root, void *entry, int32_t offset )
{
	void	*append;

	append = (void *) ((char *) root - offset );				/* virtueller Anfangseintrag */

	while ( NEXT( append, offset ))									/* Nachfolger vorhanden? */
		append = NEXT( append, offset );								/* Zeiger auf den Nachfolger */

	NEXT( append, offset ) = entry;									/* Eintrag anh�ngen */
}

/*----------------------------------------------------------------------------------------*/
/* Eintrag in einer Liste suchen																				*/
/* Funktionsresultat:	Zeiger auf den Eintrag oder 0L, wenn nicht vorhanden					*/
/*	root:						Zeiger auf den Zeiger auf den ersten Eintrag								*/
/*	what:						zu suchender Wert																	*/
/*	cmp_entries:			Vergleichsfunktion																*/
/*----------------------------------------------------------------------------------------*/
void	*list_search( void *root, int32_t what, int32_t offset, int (*cmp_entries)( int32_t what, void *entry ))
{
	void	*search;
	
	search = root;
	
	while ( search )
	{
		if ( cmp_entries( what, search ) == 0 )					/* gesuchter Eintrag? */
			return( search );
			
		search = NEXT( search, offset );
	}
	return( 0L );															/* Eintrag wurde nicht gefunden */
}

/*----------------------------------------------------------------------------------------*/
/* nten Eintrag in einer Liste suchen																		*/
/* Funktionsresultat:	Zeiger auf den Eintrag oder 0L, wenn nicht vorhanden					*/
/*	root:						Zeiger auf den Zeiger auf den ersten Eintrag								*/
/*	index:					Index des Eintrags (0 bis ...)												*/
/*----------------------------------------------------------------------------------------*/
void	*list_search_nth( void *root, int32_t index, int32_t offset )
{
	while ( root )
	{
		if ( index == 0 )													/* nten Eintrag gefunden? */
			return( root );
		
		index--;		
		root = NEXT( root, offset );
	}
	
	return( 0L );															/* Eintrag wurde nicht gefunden */
}

/*----------------------------------------------------------------------------------------*/
/* Index eines Eintrags bestimmen																			*/
/* Funktionsresultat:	Index des Eintrags oder -1, falls nicht in der Liste vorhanden		*/
/*	root:						Zeiger auf den Zeiger auf den ersten Eintrag								*/
/*	search:					Zeiger auf den zu suchenden Eintrag											*/
/*----------------------------------------------------------------------------------------*/
int32_t	list_get_index( void *root, void *search, int32_t offset )
{
	int32_t	index;
	
	index = 0;
	
	while ( root )
	{
		if ( root == search )											/* Eintrag gefunden? */
			return( index );
		
		index++;		
		root = NEXT( root, offset );
	}
	return( -1 );															/* Eintrag wurde nicht gefunden */
}

/*----------------------------------------------------------------------------------------*/
/* Eintrage z�hlen																								*/
/* Funktionsresultat:	Anzahl der Eintr�ge																*/
/*	root:						Zeiger auf den ersten Eintrag													*/
/*----------------------------------------------------------------------------------------*/
int32_t	list_count( void *root, int32_t offset )
{
	int32_t	count;
	
	count = 0;
	
	while ( root )
	{
		count++;
		root = NEXT( root, offset );
	}
	return( count );
}

#undef	NEXT
