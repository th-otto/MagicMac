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
	ULONG magic;				/* magic to identify a memory block */
	struct MB_tag *prev;		/* predecessor in block list */
	struct MB_tag *next;		/* successor in block list */
	struct MB_tag *mem_prev;	/* predecessor in memory */
	struct MB_tag *mem_next;	/* successor in memory */
	LONG len;					/* length of memory area that follows */
	UWORD status;
} MB;

/* Memory Pool */
typedef struct MP_tag
{
	WORD used;					/* semaphore for access */
	MB ff_mb;					/* first free block */
	MB lf_mb;					/* last free block */
	MB fu_mb;					/* first used block */
	MB lu_mb;					/* last used block */
	LONG len;					/* size of usable memory area */
	struct MP_tag *next;		/* pointer to next MP */
} MP;

/* Fast Memory Pool */
typedef struct FMP_tag
{
	MP pool;
	WORD fast_used;
	void *fast;					/* pointer to fast memory area of fixed size */
	MP *merged;
	LONG merged_size;
} FMP;

#define	FIRST_MB ff_mb.mem_next	/* Zeiger auf den ersten MB eines Pools */
#define	LAST_MB	lf_mb.mem_prev	/* Zeiger auf den letzten MB eines Pools */

/*
 * After the memory pool has been initialized, ff_mb.mem_next always points to the first
 * Memory block in the memory and lf_mb.mem_prev always points to the last memory block in the
 * Memory of the pool.
 *
 * Len specifies the length of the pool memory.
 */

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

extern MP acache_mp;
extern MP bcache_mp;
extern MP fcache_mp;
extern MP kcache_mp;
extern MP wcache_mp;
extern MP div_mp;
