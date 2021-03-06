/***********************************************************************
*
* Men_XCMD.h
*
* Mac-Men� f�r MagiCMac
*
************************************************************************/

enum {
	xcmdOpenMenu		= 0,
	xcmdCloseMenu		= 1,
	xcmdDrawMenu		= 2,
	xcmdSelectMenu		= 3,
	xcmdHiliteMenu		= 4,
	xcmdEnableItem		= 5,
	xcmdDisableItem	= 6,
	xcmdRedrawBg		= 10,
	xcmdSwitchToMacOS	= 11
};

typedef struct {
	char *rsc_filename;
	short rsc_mbar_rscno;
} OpenMenuParm;

typedef struct {
	short x;
	short y;
	short mbutstate;
} SelectMenuParm;

typedef struct {
	short id;
} HiliteMenuParm;

typedef struct {
	short id;
	short item;
} EnableDisableMenuParm;

typedef struct {
	short x;
	short y;
	short w;
	short h;
} RedrawBgParm;

typedef struct {
	short x;
	short y;
} SwitchToMacOSParm;

/* EOF */
