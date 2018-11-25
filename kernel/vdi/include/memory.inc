						
BLK_MAGIC		EQU	'MBLK'

FREE_MB			EQU	1
USED_MB			EQU	2

.OFFSET
						;Memory Block
						;typedef struct MB_tag
						;{
MB_magic:		DS.L	1		;	ULONG magic;		 /* Magic, das den Block identifiziert	*/
MB_prev:		DS.L	1		;	struct MB_tag *prev;	 /* Zeiger auf den Vorgaenger in der Blockliste	*/
MB_next:		DS.L	1		;	struct MB_tag *next;	 /* Zeiger auf den Nachfolger in der Blockliste	*/
MB_mem_prev:		DS.L	1		;	struct MB_tag *mem_prev; /* Zeiger auf den im Speicher davorliegenden Block	*/
MB_mem_next:		DS.L	1		;	struct MB_tag *mem_next; /* Zeiger auf den im Speicher dahinterliegenden Block	*/
MB_len:			DS.L	1		;	LONG len;		 /* Laenge des folgenden Speicherbereichs	*/
MB_status:		DS.W	1		;	UWORD status;
						;} MB;
sizeof_MB:

.OFFSET
						;Memory  Pool
						;typedef struct MP_tag
						;{
MP_used:		DS.W	1		; WORD used;			/* Semaphore fuer Zugriffe auf den MP */
MP_ff_mb:		DS.B	sizeof_MB	; MB ff_mb;			/* erster freier Block */
MP_lf_mb:		DS.B	sizeof_MB	; MB lf_mb;			/* letzter freier Block	*/
MP_fu_mb:		DS.B	sizeof_MB	; MB fu_mb;			/* erster benutzter Block	*/
MP_lu_mb:		DS.B	sizeof_MB	; MB lu_mb;			/* letzter benutzter Block	*/
MP_len:			DS.L	1		; LONG len;			/* Laenge des Speicherbereichs	*/
MP_next:		DS.L	1		; struct MP_tag	*next;		/* Zeiger auf den naechsten MP	*/
						;} MP;
sizeof_MP:

MP_fast_used:		DS.W	1
MP_fast:		DS.L	1
MP_merged:		DS.L	1
MP_merged_size:		DS.L	1	

sizeof_FMP:

FIRST_MB		EQU	MP_ff_mb+MB_mem_next
LAST_MB			EQU	MP_lf_mb+MB_mem_prev

FAST_MB_SIZE	EQU	16384



