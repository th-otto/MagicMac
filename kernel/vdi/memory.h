#define	BLK_MAGIC	0x4d424c4bL /* 'MBLK' */

#define	FCB_SIZE	2048L

#define	FREE_MB	1
#define	USED_MB	2
#define	FREE_DUMMY_MB	(256+1)
#define	USED_DUMMY_MB	(256+2)

#define	FAST_MB_SIZE	16384L
#define	NVDI_POOL_SIZE	16384L

/* Memory Block */
typedef struct MB_tag
{
	ULONG magic;				/* Magic, das den Block identifiziert	*/
	struct MB_tag *prev;		/* Zeiger auf den Vorgaenger in der Blockliste	*/
	struct MB_tag *next;		/* Zeiger auf den Nachfolger in der Blockliste	*/
	struct MB_tag *mem_prev;	/* Zeiger auf den im Speicher davorliegenden Block	*/
	struct MB_tag *mem_next;	/* Zeiger auf den im Speicher dahinterliegenden Block	*/
	LONG len;					/* Laenge des folgenden Speicherbereichs	*/
	UWORD status;
} MB;

/* Memory  Pool */
typedef struct MP_tag
{
	WORD used;					/* Semaphore fuer Zugriffe auf den MP */
	MB ff_mb;					/* erster freier Block */
	MB lf_mb;					/* letzter freier Block	*/
	MB fu_mb;					/* erster benutzter Block	*/
	MB lu_mb;					/* letzter benutzter Block	*/
	LONG len;					/* Laenge des Speicherbereichs	ohne Verwaltungsinformationen */
	struct MP_tag *next;		/* Zeiger auf den naechsten MP	*/
} MP;

/* Fast Memory  Pool */
typedef struct FMP_tag
{
	MP pool;
	WORD fast_used;
	void *fast;					/* Zeiger auf einen schnellen Speicherbereich fester Groesse */
	MP *merged;
	LONG erged_size;
} FMP;

#define	FIRST_MB ff_mb.mem_next	/* Zeiger auf den ersten MB eines Pools */
#define	LAST_MB	lf_mb.mem_prev	/* Zeiger auf den letzten MB eines Pools */

/* Nachdem der Memory Pool initialisiert ist, zeigt ff_mb.mem_next immer auf den ersten	*/
/*	Memory Block im Speicher und lf_mb.mem_prev zeigt immer auf den letzen Memory Block im	*/
/*	Speicher des Pools.																							*/
/*	Durch len wird die Laenge des Pool-Speichers angegeben.											*/

void *malloc_mb(MP *pool, LONG len);
WORD mfree_mb(MP *pool, void *mem);
WORD init_div_mp(LONG len);
void clear_mem_pool(MP *pool);
void init_mem_pool(MP *pool);
void create_first_mb(MP *pool, void *mem, LONG len);
WORD alloc_mem_pool(MP *pool, LONG len);
WORD init_mem(void);
WORD reset_mem(void);

#define	malloc_acb(x) malloc_mb(&acache_mp, x)
#define	malloc_bcb(x) malloc_mb(&bcache_mp, x)
#define	malloc_fcb(x) malloc_mb(&fcache_mp, x)
#define	malloc_kcb(x) malloc_mb(&kcache_mp, x)
#define	malloc_wcb(x) malloc_mb(&wcache_mp, x)
#define	malloc_blk(x) malloc_mb(&div_mp, x)
#define	mfree_acb(x) mfree_mb(&acache_mp, x)
#define	mfree_bcb(x) mfree_mb(&bcache_mp, x)
#define	mfree_fcb(x) mfree_mb(&fcache_mp, x)
#define	mfree_kcb(x) mfree_mb(&kcache_mp, x)
#define	mfree_wcb(x) mfree_mb(&wcache_mp, x)
#define	mfree_blk(x) mfree_mb(&div_mp, x)

extern MP div_mp;
extern MP acache_mp;
extern MP bcache_mp;
extern MP fcache_mp;
