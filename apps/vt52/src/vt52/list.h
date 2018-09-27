
/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*
*/

typedef	struct LIST_tag
{
	struct LIST_tag	*next;	/* Zeiger auf den Nachfolger */
} LIST_ENTRY;

#if 0
WORD	remove_list_entry( LIST_ENTRY **root, LIST_ENTRY *entry );
void	insert_list_entry( LIST_ENTRY **root, LIST_ENTRY *entry );
void	append_list_entry( LIST_ENTRY **root, LIST_ENTRY *entry );
LIST_ENTRY	*search_list_entry( LIST_ENTRY *root, LONG what, WORD (*cmp_entries)( LONG what, LIST_ENTRY *entry ) );
LIST_ENTRY	*search_nth_entry( LIST_ENTRY *root, WORD index );
WORD	get_entry_index( LIST_ENTRY *root, LIST_ENTRY *search );
WORD	count_list_entries( LIST_ENTRY *root );
#endif

int16	list_remove( void **root, void *entry, int32 offset );
void	list_insert( void **root, void *entry, int32 offset );
void	list_append( void **root, void *entry, int32 offset );
void	*list_search( void *root, int32 what, int32 offset, int16 (*cmp_entries)( int32 what, void *entry ));
void	*list_search_nth( void *root, int32 index, int32 offset );
int32	list_get_index( void *root, void *search, int32 offset );
int32	list_count( void *root, int32 offset );


#define	append_list_entry( root, entry )	list_append(( void **) root, (void *) entry, 0 )
