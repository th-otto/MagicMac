/*
	@(#)dosix/macfs.h
	
	Julian F. Reschke, 16. Mai 1996
*/

#ifndef _DOSIX_SYS_MACFS
#define _DOSIX_SYS_MACFS

typedef struct _MacFinderInfo {
	long fdType;		/*the type of the file*/
	long fdCreator;		/*file's creator*/
	unsigned short fdFlags;	/*flags ex. hasbundle,invisible,locked, etc.*/
	short fdLocation1;	/*file's location in folder*/
	short fdLocation2;	/* rest of location */
	short fdFldr;		/*folder containing file*/
} MacFinderInfo;

#define FMACOPENRES             (('F' << 8) | 72)
#define FMACGETTYCR             (('F' << 8) | 73)
#define FMACSETTYCR             (('F' << 8) | 74)

int DOGetMacFileinfo (const char *filename, MacFinderInfo *M);
int DOSetMacFileinfo (const char *filename, MacFinderInfo *M);

#endif

