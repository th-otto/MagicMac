/*
	Defines and prototypes for MetaDOS functions
    
    Copyright (c) Julian F. Reschke (jr@ms.maus.de), 13. Januar 1996
    Free distribution and usage allowed as long as the file remains 
    unchanged.
    
    See MetaDOS developer manuals for a description of the data structures.
*/

#ifndef _METADOS_H
#define _METADOS_H

typedef struct
{
	unsigned char trackno, minute, second, frame;
} CD_TOC_ENTRY;

typedef struct
{
	unsigned char disctype;		/* 0: audio, 1: data */
	unsigned char firsttrack, lasttrack, curtrack;
	unsigned char relposz, relposm, relposs, relposf;
	unsigned char absposz, absposm, absposs, absposf;
	unsigned char endposz, endposm, endposs, endposf;
	unsigned char index, res[3];
	unsigned long reserved[123];
} CD_DISC_INFO;

#ifndef _MINT_OSTRUCT_H
typedef struct
{
	unsigned short	mi_version;	/* 0x230 == '02.30' */
	long 			mi_magic;	/* == '_MET' */
	const char 		*mi_log2phys;	/* maps DOS-IDs to MetaDOS XBIOS device numbers */

	/* introduced with version 0x271 */
	unsigned int 	mi_handles;	/* max. number of open files, 0 == no limit */
} META_INFO_2;

typedef struct
{
	unsigned long	mi_drivemap;
	const char 		*mi_version_string;
	long 			reserved;
	META_INFO_2		*mi_info;
} META_INFO_1;
#endif

typedef struct
{
	char 			*mdr_name;
	long 			res[3];
} META_DRVINFO;

typedef struct
{
	long	mdi_magic;		/* 'INFO' */
	long	mdi_length;		/* size of this structure (input
							   and output parm) */
	short	mdi_major;		/* major and minor device number, */
	short	mdi_minor;		/* ... -1 if unknown (XHDI compatible) */
	char	mdi_name[64];	/* device name */
	short	mdi_devtype;	/* SCSI device type or -1 for unknown */
	unsigned long
			mdi_flags;		/* device flags */
	short	mdi_controller;	/* controller # (0: ACSI, 1: SCSI, 2: IDE */
	short	mdi_target;		/* target */
	short	mdi_lun;		/* lun */
} META_DEVINFO;

#define METAGETDEVINFO	0	/* Ioctl # for above info, only supported by
                               some drivers */

void Metainit (META_INFO_1 *);
long Metaopen (short drive, META_DRVINFO *buffer);
long Metaclose (short drive);
long Metaread (short drive, void *buffer, long blockno, short blks);
long Metawrite (short drive, void *buffer, long blockno, short blks);
long Metastatus (short drive, void *buffer);
long Metaioctl (short drive, long magic, short opcode, void *buffer);
long Metasetsongtime (short drive, short repeat, long starttime, long endtime);
long Metagettoc (short drive, short flag, CD_TOC_ENTRY *buffer);
long Metadiscinfo (short drive, CD_DISC_INFO *p);
long Metastartaudio (short drive, short flag, unsigned char *bytearray);
long Metastopaudio (short drive);

#endif
