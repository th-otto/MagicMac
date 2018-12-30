#ifndef __HFS_H__
#define __HFS_H__

#define HFS_BLOCKSZ			512
#define HFS_BLOCKSZ_BITS	9

#define HFS_NAMELEN			31     /* maximum length of an HFS filename */
#define HFS_MAX_VLEN		27

typedef signed char hfss08_t;
typedef unsigned char hfsu08_t;
typedef signed short hfss16_t;
typedef unsigned short hfsu16_t;
typedef signed long hfss32_t;
typedef unsigned long hfsu32_t;

typedef unsigned long hfscnid_t;

/* offsets to various blocks */
#define HFS_DD_BLK		0 /* Driver Descriptor block */
#define HFS_PMAP_BLK	1 /* First block of partition map */
#define HFS_MDB_BLK		2 /* Block (w/i partition) of MDB */

/* magic numbers for various disk blocks */
#define HFS_DRVR_DESC_MAGIC	0x4552 /* "ER": driver descriptor map */
#define HFS_OLD_PMAP_MAGIC	0x5453 /* "TS": old-type partition map */
#define HFS_NEW_PMAP_MAGIC	0x504D /* "PM": new-type partition map */
#define HFS_SUPER_MAGIC		0x4244 /* "BD": HFS MDB (super block) */
#define HFS_MFS_SUPER_MAGIC	0xD2D7 /* MFS MDB (super block) */

/* Some special File ID numbers */
#define HFS_POR_CNID		1			/* Parent Of the Root */
#define HFS_ROOT_CNID		2			/* ROOT directory */
#define HFS_EXT_CNID		3			/* EXTents B-tree */
#define HFS_CAT_CNID		4			/* CATalog B-tree */
#define HFS_BAD_CNID		5			/* BAD blocks file */
#define HFS_ALLOC_CNID		6			/* ALLOCation file (HFS+) */
#define HFS_START_CNID		7			/* STARTup file (HFS+) */
#define HFS_ATTR_CNID		8			/* ATTRibutes file (HFS+) */
#define HFS_EXCH_CNID		15			/* ExchangeFiles temp id */
#define HFS_FIRSTUSER_CNID	16

/* values for cdrType */
#define HFS_CDR_DIR    0x01    /* folder (directory) */
#define HFS_CDR_FIL    0x02    /* file */
#define HFS_CDR_THD    0x03    /* folder (directory) thread */
#define HFS_CDR_FTH    0x04    /* file thread */

/* legal values for hfs_ext_key.FkType and hfs_file.fork */
#define HFS_FK_DATA	0x00
#define HFS_FK_RSRC	0xFF

/* bits in fil.filFlags */
#define HFS_FIL_LOCK	0x01  /* locked */
#define HFS_FIL_THD		0x02  /* file thread */
#define HFS_FIL_DOPEN   0x04  /* data fork open */
#define HFS_FIL_ROPEN   0x08  /* resource fork open */
#define HFS_FIL_DIR     0x10  /* directory (always clear) */
#define HFS_FIL_NOCOPY  0x40  /* copy-protected file */
#define HFS_FIL_USED	0x80  /* open */

/* bits in dir.dirFlags */
#define HFS_DIR_LOCK        0x01  /* locked */
#define HFS_DIR_THD         0x02  /* directory thread */
#define HFS_DIR_INEXPFOLDER 0x04  /* in a shared area */
#define HFS_DIR_MOUNTED     0x08  /* mounted */
#define HFS_DIR_DIR         0x10  /* directory (always set) */
#define HFS_DIR_EXPFOLDER   0x20  /* share point */

/* bits finfo.fdFlags */
#define HFS_FLG_INITED		0x0100
#define HFS_FLG_LOCKED		0x1000
#define HFS_FLG_INVISIBLE	0x4000



#define HFS_FNDR_ISONDESK				(1 <<  0)
#define HFS_FNDR_COLOR					0x0e
#define HFS_FNDR_COLORRESERVED			(1 <<  4)
#define HFS_FNDR_REQUIRESSWITCHLAUNCH	(1 <<  5)
#define HFS_FNDR_ISSHARED				(1 <<  6)
#define HFS_FNDR_HASNOINITS				(1 <<  7)
#define HFS_FNDR_HASBEENINITED			(1 <<  8)
#define HFS_FNDR_RESERVED				(1 <<  9)
#define HFS_FNDR_HASCUSTOMICON			(1 << 10)
#define HFS_FNDR_ISSTATIONERY			(1 << 11)
#define HFS_FNDR_NAMELOCKED				(1 << 12)
#define HFS_FNDR_HASBUNDLE				(1 << 13)
#define HFS_FNDR_ISINVISIBLE			(1 << 14)
#define HFS_FNDR_ISALIAS				(1 << 15)

typedef char Str15[1 + 15];
typedef char Str31[1 + HFS_NAMELEN];

typedef struct
{
	hfss16_t sbSig;						/* device signature (should be 0x4552) */
	hfss16_t sbBlkSize;					/* block size of the device (in bytes) */
	hfss32_t sbBlkCount;				/* number of blocks on the device */
	hfss16_t sbDevType;					/* reserved */
	hfss16_t sbDevId;					/* reserved */
	hfss32_t sbData;					/* reserved */
	hfss16_t sbDrvrCount;				/* number of driver descriptor entries */
	hfss32_t ddBlock;					/* first driver's starting block */
	hfss16_t ddSize;					/* size of the driver, in 512-byte blocks */
	hfss16_t ddType;					/* driver operating system type (MacOS = 1) */
} Block0;

typedef struct
{
	hfsu16_t pmSig;						/* partition signature (0x504d or 0x5453) */
	hfss16_t pmSigPad;					/* reserved */
	hfss32_t pmMapBlkCnt;				/* number of blocks in partition map */
	hfss32_t pmPyPartStart;				/* first physical block of partition */
	hfss32_t pmPartBlkCnt;				/* number of blocks in partition */
	char pmPartName[32];				/* partition name */
	char pmPartType[32];				/* partition type */
#if 0
	hfss32_t pmLgDataStart;				/* first logical block of data area */
	hfss32_t pmDataCnt;					/* number of blocks in data area */
	hfss32_t pmPartStatus;				/* partition status information */
	hfss32_t pmLgBootStart;				/* first logical block of boot code */
	hfss32_t pmBootSize;				/* size of boot code, in bytes */
	hfss32_t pmBootAddr;				/* boot code load address */
	hfss32_t pmBootAddr2;				/* reserved */
	hfss32_t pmBootEntry;				/* boot code entry point */
	hfss32_t pmBootEntry2;				/* reserved */
	hfss32_t pmBootCksum;				/* boot code checksum */
	char pmProcessor[16];				/* processor type */
#endif
} Partition;

typedef struct
{
	hfss16_t bbID;						/* boot blocks signature */
	hfss32_t bbEntry;					/* entry point to boot code */
	hfss16_t bbVersion;					/* boot blocks version number */
	hfss16_t bbPageFlags;				/* used internally */
	Str15 bbSysName;					/* System filename */
	Str15 bbShellName;					/* Finder filename */
	Str15 bbDbg1Name;					/* debugger filename */
	Str15 bbDbg2Name;					/* debugger filename */
	Str15 bbScreenName;					/* name of startup screen */
	Str15 bbHelloName;					/* name of startup program */
	Str15 bbScrapName;					/* name of system scrap file */
	hfss16_t bbCntFCBs;					/* number of FCBs to allocate */
	hfss16_t bbCntEvts;					/* number of event queue elements */
	hfss32_t bb128KSHeap;				/* system heap size on 128K Mac */
	hfss32_t bb256KSHeap;				/* used internally */
	hfss32_t bbSysHeapSize;				/* system heap size on all machines */
	hfss16_t filler;					/* reserved */
	hfss32_t bbSysHeapExtra;			/* additional system heap space */
	hfss32_t bbSysHeapFract;			/* fraction of RAM for system heap */
} BootBlkHdr;

#if 0
typedef struct
{
	hfsu16_t block;						/* first allocation block */
	hfsu16_t count;						/* number of allocation blocks */
} hfs_extent;

typedef hfs_extent hfs_extent_rec[3];
#endif


typedef struct
{
	hfss08_t key_len;					/* key length */
	hfss08_t FkType;					/* fork type (0x00/0xff == data/resource */
	hfsu32_t FNum;						/* file number */
	hfsu16_t FABN;						/* starting file allocation block */
} hfs_ext_key;

/* The key used in the catalog b-tree: */
typedef struct
{
	hfss08_t key_len;					/* key length */
	hfss08_t reserved;					/* reserved */
	hfsu32_t ParID;						/* parent directory ID */
	Str31 CName;						/* catalog node name */
} hfs_cat_key;

typedef struct
{
	hfss16_t v;							/* vertical coordinate */
	hfss16_t h;							/* horizontal coordinate */
} hfs_point;

typedef struct
{
	hfss16_t top;						/* top edge of rectangle */
	hfss16_t left;						/* left edge */
	hfss16_t bottom;					/* bottom edge */
	hfss16_t right;						/* right edge */
} hfs_rect;

typedef struct
{
	hfs_rect frRect;					/* folder's rectangle */
	hfss16_t frFlags;					/* flags */
	hfs_point frLocation;				/* folder's location */
	hfss16_t frView;					/* folder's view */
} hfs_dinfo;

typedef struct
{
	hfs_point frScroll;					/* scroll position */
	hfss32_t frOpenChain;				/* directory ID chain of open folders */
	hfss16_t frUnused;					/* reserved */
	hfss16_t frComment;					/* comment ID */
	hfss32_t frPutAway;					/* directory ID */
} hfs_dxinfo;

typedef struct
{
	hfss32_t fdType;					/* file type */
	hfss32_t fdCreator;					/* file's creator */
	hfss16_t fdFlags;					/* flags */
	hfs_point fdLocation;				/* file's location */
	hfss16_t fdFldr;					/* file's window */
} hfs_finfo;

typedef struct
{
	hfss16_t fdIconID;					/* icon ID */
	hfss16_t fdUnused[4];				/* reserved */
	hfss16_t fdComment;					/* comment ID */
	hfss32_t fdPutAway;					/* home directory ID */
} hfs_fxinfo;

typedef struct
{
	hfsu16_t drSigWord;					/* volume signature (0x4244 for HFS) */
	hfss32_t drCrDate;					/* date and time of volume creation */
	hfss32_t drLsMod;					/* date and time of last modification */
	hfss16_t drAtrb;					/* volume attributes */
	hfsu16_t drNmFls;					/* number of files in root directory */
	hfsu16_t drVBMSt;					/* first block of volume bit map (always 3) */
	hfsu16_t drAllocPtr;				/* start of next allocation search */
	hfsu16_t drNmAlBlks;				/* number of allocation blocks in volume */
	hfsu32_t drAlBlkSiz;				/* size (in bytes) of allocation blocks */
	hfsu32_t drClpSiz;					/* default clump size */
	hfsu16_t drAlBlSt;					/* first allocation block in volume */
	hfss32_t drNxtCNID;					/* next unused catalog node ID (dir/file ID) */
	hfsu16_t drFreeBks;					/* number of unused allocation blocks */
	char drVN[1 + HFS_MAX_VLEN];		/* volume name (1-27 chars) */
	hfss32_t drVolBkUp;					/* date and time of last backup */
	hfss16_t drVSeqNum;					/* volume backup sequence number */
	hfsu32_t drWrCnt;					/* volume write count */
	hfsu32_t drXTClpSiz;				/* clump size for extents overflow file */
	hfsu32_t drCTClpSiz;				/* clump size for catalog file */
	hfsu16_t drNmRtDirs;				/* number of directories in root directory */
	hfsu32_t drFilCnt;					/* number of files in volume */
	hfsu32_t drDirCnt;					/* number of directories in volume */
	hfss32_t drFndrInfo[8];				/* information used by the Finder */
	hfsu16_t drEmbedSigWord;			/* type of embedded volume */
	hfs_extent drEmbedExtent;			/* location of embedded volume */
	hfsu32_t drXTFlSize;				/* size (in bytes) of extents overflow file */
	hfs_extent_rec drXTExtRec;			/* first extent record for extents file */
	hfsu32_t drCTFlSize;				/* size (in bytes) of catalog file */
	hfs_extent_rec drCTExtRec;			/* first extent record for catalog file */
} MDB;

typedef struct
{
	hfss08_t cdrType;					/* record type */
	hfss08_t cdrResrv2;					/* reserved */
	union
	{
		struct
		{								/* cdrDirRec */
			hfss16_t Flags;				/* directory flags */
			hfsu16_t Val;				/* directory valence */
			hfsu32_t DirID;				/* directory ID */
			hfsu32_t CrDat;				/* date and time of creation */
			hfsu32_t MdDat;				/* date and time of last modification */
			hfsu32_t BkDat;				/* date and time of last backup */
			hfs_dinfo UsrInfo;			/* Finder information */
			hfs_dxinfo FndrInfo;		/* additional Finder information */
			hfss32_t Resrv[4];			/* reserved */
		} dir;
		struct
		{								/* cdrFilRec */
			hfss08_t Flags;				/* file flags */
			hfss08_t Typ;				/* file type */
			hfs_finfo UsrWds;			/* Finder information */
/* $14 */	hfsu32_t FlNum;				/* file ID */
			hfsu16_t StBlk;				/* first alloc block of data fork */
/* $1a */	hfsu32_t LgLen;				/* logical EOF of data fork */
			hfsu32_t PyLen;				/* physical EOF of data fork */
			hfsu16_t RStBlk;			/* first alloc block of resource fork */
/* $24 */	hfsu32_t RLgLen;			/* logical EOF of resource fork */
			hfsu32_t RPyLen;			/* physical EOF of resource fork */
			hfsu32_t CrDat;				/* date and time of creation */
			hfsu32_t MdDat;				/* date and time of last modification */
/* $34 */	hfsu32_t BkDat;				/* date and time of last backup */
			hfs_fxinfo FndrInfo;		/* additional Finder information */
/* $48 */	hfsu16_t ClpSize;			/* number of bytes to allocate when extending files */
/* $4a */	hfs_extent_rec ExtRec;		/* first data fork extent record */
/* $56 */	hfs_extent_rec RExtRec;		/* first resource fork extent record */
/* $62 */	hfss32_t Resrv;				/* reserved */
/* $66 */
		} fil;
		struct
		{								/* cdrThdRec */
			hfss32_t Resrv[2];			/* reserved */
			hfsu32_t ParID;				/* parent ID for this directory */
			Str31 CName;				/* name of this directory */
		} dthd;
		struct
		{								/* cdrFThdRec */
			hfss32_t Resrv[2];			/* reserved */
			hfsu32_t ParID;				/* parent ID for this file */
			Str31 CName;				/* name of this file */
		} fthd;
	} u;
} CatDataRec;

/*
 * on-disk structure of B-tree node
 */
typedef struct
{
	hfsu32_t next;					/* forward link */
	hfsu32_t prev;					/* backward link */
	hfsu08_t type;					/* node type */
	hfsu08_t height;				/* node level (leaves=1) */
	hfsu16_t num_recs;				/* number of records in node */
	hfss16_t reserved;				/* reserved */
} hfs_bnode_desc;

#define HFS_NODE_INDEX	0x00	/* An internal (index) node */
#define HFS_NODE_HEADER	0x01	/* The tree header node (node 0) */
#define HFS_NODE_MAP	0x02	/* Holds part of the bitmap of used nodes */
#define HFS_NODE_LEAF	0xFF	/* A leaf (height==1) node */

typedef struct
{
	hfsu16_t depth;					/* current depth of tree */
	hfsu32_t root;					/* number of root node */
	hfsu32_t leaf_count;			/* number of leaf records in tree */
	hfsu32_t leaf_head;				/* number of first leaf node */
	hfsu32_t leaf_tail;				/* number of last leaf node */
	hfsu16_t node_size;				/* size of a node */
	hfsu16_t max_key_len;			/* maximum length of a key */
	hfsu32_t node_count;			/* total number of nodes in tree */
	hfsu32_t free_nodes;			/* number of free nodes */
	hfsu16_t reserved1;
	hfsu32_t clump_size;
	hfsu08_t btree_type;
	hfsu08_t reserved2;
	hfsu32_t attributes;
	hfss08_t reserved3[64];			/* reserved */
} hfs_btree_header_rec;

#define BTREE_ATTR_BADCLOSE	0x00000001	/* b-tree not closed properly. not used by hfsplus. */
#define HFS_TREE_BIGKEYS	0x00000002	/* key length is u16 instead of u8. used by hfsplus. */
#define HFS_TREE_VARIDXKEYS	0x00000004	/* variable key length instead of
						   max key length. use din catalog
						   b-tree but not in extents
						   b-tree (hfsplus). */

#endif /* __HFS_H__ */
