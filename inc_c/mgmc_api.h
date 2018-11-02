/*
 * Definitions for MgMc-Cookie
 * Set TABs to 4
 *
 * asserts: "char" is 1 Byte, "short" is 2 Byte, "long" is 4 Byte
 */

#ifndef __MGMC_API_H__
#define __MGMC_API_H__

typedef unsigned char byte;

#ifdef __MWERKS__	/* if compiled on a Macintosh */
#define cdecl
#pragma options align=mac68k
#else				/* if compiled on an Atari (Pure C) */
typedef unsigned char Boolean;	/* "Boolean" is 1 Byte long! */
typedef void *Ptr;
typedef Ptr *Handle;
typedef unsigned char *StringPtr;
typedef void PixMap;
typedef int Integer;
typedef long Fixed;


typedef long Size;
typedef short MacOSErr;
typedef Handle ControlHandle;
typedef unsigned char Str255[256];

typedef struct {
	unsigned short top;
	unsigned short left;
	unsigned short bottom;
	unsigned short right;
} Rect;

typedef struct {
	Integer v;
	Integer h;
} Point;

typedef struct {
	/*  0 */ Ptr baseAddr;
	/*  2 */ Integer rowBytes;
	/*  6 */ Rect bounds;
	/* 14 */
} BitMap;

typedef unsigned char Pattern[8];

typedef struct {
	/*  0 */ Integer device;
	/*  2 */ BitMap portBits;
	/* 16 */ Rect portRect;
	/* 24 */ Handle visRgn;
	/* 28 */ Handle clipRgn;
	/* 32 */ Pattern bkPat;
	/* 40 */ Pattern fillPat;
	/* 48 */ Point pnLoc;
	/* 52 */ Point pnSize;
	/* 56 */ Integer pnMode;
	/* 58 */ Pattern pnPat;
	/* 66 */ Integer pnVis;
	/* 68 */ Integer txFont;
	/* 70 */ signed char txFace;
	/* 71 */ unsigned char filler;
	/* 72 */ Integer txMode;
	/* 74 */ Integer txSize;
	/* 76 */ Fixed spExtra;
	/* 80 */ long fgColor;
	/* 84 */ long bkColor;
	/* 88 */ Integer colrBit;
	/* 90 */ Integer patStretch;
	/* 92 */ Handle picSave;
	/* 96 */ Handle rgnSave;
	/* 100 */ Handle polySave;
	/* 104 */ /* QDProcsPtr */ void *grafProcs;
	/* 108 */
} GrafPort;

typedef struct __wr {
	/*   0 */ GrafPort port;
	/* 108 */ Integer windowKind;
	/* 110 */ Boolean visible;
	/* 111 */ Boolean hilited;
	/* 112 */ Boolean goAwayFlag;
	/* 113 */ Boolean spareFlag;
	/* 114 */ Handle strucRgn;
	/* 118 */ Handle contRgn;
	/* 122 */ Handle updateRgn;
	/* 126 */ Handle windowDefProc;
	/* 130 */ Handle dataHandle;
	/* 134 */ Handle titleHandle;
	/* 138 */ Integer titleWidth;
	/* 140 */ Handle controlList;
	/* 144 */ struct __wr *nextWindow;
	/* 148 */ Handle windowPic;
	/* 152 */ long refCon;
	/* 156 */
} WindowRecord;
typedef WindowRecord *WindowPtr;

typedef struct {
	/*  0  */ WindowRecord window;
	/* 156 */ Handle items;
	/* 160 */ Handle textH;
	/* 164 */ Integer editField;
	/* 166 */ Integer editOpen;
	/* 168 */ Integer aDefItem;
	/* 170 */
} DialogRecord;

typedef DialogRecord *DialogPtr;



typedef struct {
	Integer iDev;
	Integer iVRes;
	Integer iHRes;
	Rect rPage;
} TPrInfo;

enum {
    scanTB                      = 0,
    scanBT                      = 1,
    scanLR                      = 2,
    scanRL                      = 3
};
typedef signed char TScan;

typedef struct {
	Integer iRowBytes;
	Integer iBandV;
	Integer iBandH;
	Integer iDevBytes;
	Integer iBands;
	signed char bPatScale;
	signed char bUlThick;
	signed char bUlOffset;
	signed char bUlShadow;
	TScan scan;
	signed char bXInfoX;
} TPrXInfo;

enum {
    feedCut                     = 0,
    feedFanfold                 = 1,
    feedMechCut                 = 2,
    feedOther                   = 3
};
typedef signed char TFeed;

typedef struct {
	Integer wDev;
	Integer iPageV;
	Integer iPageH;
	signed char bPort;
	TFeed feed;
} TPrStl;

typedef void cdecl (*PrIdleProcPtr) (void);
typedef struct {
	Integer iFstPage;
	Integer iLstPage;
	Integer iCopies;
	signed char bJDocLoop;
	Boolean fFromUser;
	PrIdleProcPtr pIdleProc;
	StringPtr pFileName;
	Integer iFileVol;
	signed char bFileVers;
	signed char bJobX;
} TPrJob;

typedef struct {
	/*   0 */ Integer iPrVersion;        /* Printing software version */
	/*   2 */ TPrInfo prInfo;            /* the PrInfo data associated with the current style */
	/*   2       iDev; */
	/*   4       iVRes; */
	/*   6       iHRes; */
	/*   8       Rect rPage; */
	/*  16 */ Rect rPaper;               /* The paper rectangle [offset from rPage] */
	/*  24 */ TPrStl prStl;              /* This print request's style */
	/*  24       wDev; */
	/*  26       iPageV; */
	/*  28       iPageH; */
	/*  30       bPort; */
	/*  31       feed; */
	/*  32 */ TPrInfo prInfoPT;          /* Print Time Imaging metrics */
	/*  46 */ TPrXInfo prXInfo;          /* Print-time (expanded) Print info record */
	/*  46       iRowBytes; */
	/*  48       iBandV; */
	/*  50       iBandH; */
	/*  52       iDevBytes; */
	/*  54       iBands; */
	/*  56       bPatScale; */
	/*  57       bUlThick; */
	/*  58       bUlOffset; */
	/*  59       bUlShadow; */
	/*  60       scan; */
	/*  61       bXInfoX; */
	/*  62 */ TPrJob prJob;              /* The Print Job request */
	/*  62       Integer iFstPage; */
	/*  64       Integer iLstPage; */
	/*  66       Integer iCopies; */
	/*  68       signed char bJDocLoop; */
	/*  69       Boolean fFromUser; */
	/*  70       PrIdleProcPtr pIdleProc; */
	/*  74       StringPtr pFileName; */
	/*  78       Integer iFileVol; */
	/*  80       signed char bFileVers; */
	/*  81       signed char bJobX; */
	/*  82 */ Integer printX[19];
	/* 120 */
} TPrint;
typedef TPrint *TPPrint;
typedef TPPrint *THPrint;
/* enum {false,true}; */
typedef struct {
	short	vRefNum;
	long	parID;
	byte	name[64];	/* pascal string! */
} FSSpec;
typedef struct {
	short	what;
	long	message;
	long	when;
	short	whereV;
	short	whereH;
	short	modifiers;
} EventRecord;
#endif


typedef void pascal (*PItemProcPtr)(DialogPtr dlg, short item);
typedef Boolean pascal (*ModalFilterProcPtr)(DialogPtr dlg, EventRecord *event, short *data);

struct TPrDlg {               /* print dialog box record */
   DialogRecord   Dlg;        /* a dialog record */
   ModalFilterProcPtr pFltrProc;  /* pointer to event filter */
   PItemProcPtr   pItemProc;  /* pointer to item-handling function */
   THPrint        hPrintUsr;  /* handle to a TPrint record */
   Boolean        fDoIt;      /* TRUE means user clicked OK */
   Boolean        fDone;      /* TRUE means user clicked OK or Cancel */
   long           lUser1;     /* storage for your application */
   long           lUser2;     /* storage for your application */
   long           lUser3;     /* storage for your application */
   long           lUser4;     /* storage for your application */
};
typedef struct TPrDlg *TPPrDlg;



typedef struct MgMcCookie MgMcCookie;

typedef long cdecl (*GenProc) (short function, void *data);
typedef Boolean cdecl (*PrSetupProc) (Boolean alwaysInteractively);
typedef void cdecl (*VoidProcPtr) (void);
typedef long cdecl (*LongProcPtr) (void);
typedef void cdecl (*MacCtProc) (VoidProcPtr);
typedef Boolean cdecl (*EvtProcPtr) (EventRecord *event);

typedef struct {
	THPrint		printHdl;
	PrSetupProc	doPrintSetup;
	VoidProcPtr	saveSetup;
	long		reserved[7];
} PrintDesc;

enum {	/* status flags (bit numbers) for 'flags1' field */
	emul640x400Bit = 0,		/* ATARI screen simulation (physbase can be changed) */
	emulAtariScreenBit = 0,	/* same as above */
	distinctShiftKeysBit,	/* right & left shift keys give diff. scan codes */
	realTwoButtonMouseBit,	/* 2-button mouse is connected */
	runningOn68KEmulatorBit,/* running on PowerPC with emulation */
	atariIO1Disabled,		/* lower I/O area is not present (has RAM that can be used by applications) */
	atariIO2Disabled,		/* upper I/O area does not respond properly (no BUS Errors or McSTout) */
	speedEmulatorInstalled	/* new in v1.13: Speed Emulator (part of Speed Doubler) is installed */
};

typedef struct {	/* 'vers' resource definition, see Inside Mac docs */
	byte	vm;		/* first part of version number in BCD */
	byte	vn;		/* second and third part of version number in BCD */
	byte	vt;		/* development: 0x20, alpha: 0x40, beta: 0x60, release: 0x80 */
	byte	vd;		/* stage of prerelease version in BCD */
	short	region;	/* region code */
	char	str[];	/* version strings */
} MacVersion;

typedef struct {
	Boolean	inserted;		/* true: disk is inserted and available to GEMDOS/BIOS functions */
	Boolean	highDensity;	/* true: HD disk inserted, false: none or DD disk inserted */
	short	res1;			/* reserved */
	long	res2;			/* reserved */
} FlpDrvInfo;

typedef struct {
	Ptr		start;
	long	length;
} MemArea;

/*
 * The XCMD interface
 * ------------------
 */

enum {
	XCMDMajorVersion	= 1,	/* BCD format */
	XCMDRevision		= 0x01	/* BCD format */
};

enum {	/* some XCMD specific error codes */
	unknownFunctionXErr	= -65539L,	/* on callXCMD: unknown function code */
	notInstalledXErr	= -65540L,	/* on openXCMD: no XCMD with this name found */
	notOpenedXErr		= -65541L,	/* on openXCMD: XCMD refused to open */
	alreadyClosedXErr	= -65542L,	/* on closeXCMD: calls to close > calls to open */
	generalXErr			= -1,
	noXErr				= 0
};

enum {	/* predefined XCMD function codes */
	/* negative cmds are functions called by MagiCMac in Mac environment */
	xcmdOpen	= -2,	/* called each time some MagiC program opens this XCMD */
	xcmdClose	= -1	/* called each time some MagiC program closes this XCMD */
};

enum {	/* function codes for cookie functions 'ext' and 'extMac' */
	extMax = 0,
	extAlert,
	extAUXOpenErr,
	extFSSpecToPath,
	extDoMacTasks,
	extMgMcACCMsg,	/* internal use */
	extIntrInfo		/* internal use */
};

typedef struct {	/* to be used with extFSSpecToPath function as parameter */
	FSSpec	specIn;
	char	pathOut[256];	/* 0-terminated string */
} FSSpecToPathRec;

typedef long XCMDHdl;

typedef XCMDHdl cdecl (*XCMDOpenProc) (char *xcmdName);	/* returns handle or error code */
typedef long cdecl (*XCMDCloseProc) (XCMDHdl xcmdHdl);	/* returns error code or 0 if no error */
typedef long cdecl (*XCMDGenProc) (XCMDHdl xcmdHdl, short function, void *data);
typedef GenProc cdecl (*XCMDGetAdrProc) (XCMDHdl xcmdHdl);	/* returns zero, if not valid */

typedef struct {	/* the information in this record is static and the record does not move */
	short			recSize;	/* size of this whole structure */
	byte			majorVers;	/* major version of the XCMD Mgr (== XCMDMajorVersion) */
	byte			revision;	/* revision version of the XCMD Mgr (== XCMDRevision) */
	/* The following routines may be called from Atari User mode or Atari Supervisor mode, */
	/* but not from Interrupts!                                                            */
	XCMDOpenProc	open;		/* negative values mean errors, all positive are valid handles */
	XCMDCloseProc	close;		/* negative values mean errors, zero means OK */
	XCMDGenProc		call;		/* call a user function */
	XCMDGetAdrProc	getAdr;		/* returns the address of the XCMD function dispatcher */
	MgMcCookie		*cookie;	/* back-link to cookie. Is not yet initialized on init! */
	long			res[15];	/* reserved, zero */
} XCMDMgrRec;


/*
 * The cookie structure
 * --------------------
 */

struct MgMcCookie {
	short		vers;			/* Version number of Cookie */
	short		size;
	long		flags1;			/* Bits: see above */
	PixMap		*scrnPMPtr;
	Boolean		*updatePalette;
	VoidProcPtr	modeMac;
	VoidProcPtr	modeAtari;
	VoidProcPtr	getBaseMode;
	LongProcPtr	getIntrCount;
	VoidProcPtr	intrLock;
	VoidProcPtr	intrUnlock;
	MacCtProc	callMacContext;
	Ptr			atariZeroPage;
	Ptr			macA5;
	VoidProcPtr	macAppSwitch;
	VoidProcPtr	controlSwitch;
	long		hardwareAttr1;
	long		hardwareAttr2;
	Ptr			magiC_BP;
	StringPtr	auxOutName;
	StringPtr	auxInName;
	VoidProcPtr	auxControl;
	PrintDesc	*printDescPtr;
	GenProc		configKernel;
	Boolean		*atariModePossible;	/* (1.04) */
	MacVersion	*versionOfMacAppl;	/* (1.06) vers. of MagiCMac application */
	void		*hwEmulSupport;		/* (1.08) supports optional system bus error handler */
	FlpDrvInfo	*floppyDrvInfoPtr;	/* (1.07) array (2 elements) of infos about floppy drives */
	XCMDMgrRec	*xcmdMgrPtr;		/* (1.08) */
	VoidProcPtr	giveTimeToMac;		/* (1.09) call from Mac Context when idle */
	long		minStackSize;		/* (1.09) minimal supervisor stack size */
	GenProc		ext;				/* (1.10) support functions, call from Atari context */
	GenProc		extMac;				/* (1.10) same as "ext", but call from Mac context */
	VoidProcPtr	stackLoad;			/* (1.11) */
	VoidProcPtr	stackUnload;		/* (1.11) */
	EvtProcPtr	eventFilter;		/* (1.14) */
	long		reserved[2];
};

#endif /* __MGMC_API_H__ */
