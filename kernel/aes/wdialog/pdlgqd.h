enum {
    getRslDataOp                = 4,
    setRslOp                    = 5,
    draftBitsOp                 = 6,
    noDraftBitsOp               = 7,
    getRotnOp                   = 8,
    NoSuchRsl                   = 1,
    OpNotImpl                   = 2,                            /*the driver doesn't support this opcode*/
    RgType1                     = 1
};

struct TGetRotnBlk {
    short                           iOpCode;
    short                           iError;
    long                            lReserved;
    THPrint                         hPrint;
    Boolean                         fLandscape;
    signed char                     bXtra;
};

struct TRslRg {
    short                           iMin;
    short                           iMax;
};
typedef struct TRslRg                   TRslRg;

struct TRslRec {
    short                           iXRsl;
    short                           iYRsl;
};
typedef struct TRslRec TRslRec;

/* get-resolution record */
struct TGetRslBlk {
	short iOpCode;  /* the getRslDataOp opcode */
	short iError;	/* result code returned by PrGeneral */
	long lReserved;	/* reserved */
	short iRgType;	/* printer driver version number */
	TRslRg xRslRg;	/* x-direction resolution range */
	TRslRg yRslRg;	/* y-direction resolution range */
	short iRslRecCnt; /* number of resolution records */
	TRslRec rgRslRec[27]; /* array of resolution records */
};

typedef struct dialog_item_struct {
    Handle  handle; /* handle or procedure pointer for this item */
    Rect    bounds; /* display rectangle for this item */
    unsigned char type;   /* item type - 1 */
    unsigned char data[1];    /* length byte of data */
} DialogItem, *DialogItemPtr, **DialogItemHandle;

typedef struct append_item_list_struct {
	short	max_index; /* number of items - 1 */
	DialogItem	items[1]; /* first item in the array */
} ItemList, *ItemListPtr, **ItemListHandle;

extern short mac_exit_code;
