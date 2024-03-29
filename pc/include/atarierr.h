/*
 * This file has been modified as part of the FreeMiNT project. See
 * the file Changes.MH for details and dates.
 */

/*
 * Copyright 1991,1992 Eric R. Smith.
 * Copyright 1992,1993,1994 Atari Corporation.
 * All rights reserved.
 */

#ifndef _ATARIERR_H
#define _ATARIERR_H


#define E_OK		0	/* ok :-) */

/* BIOS errors */

#undef ERROR

#define ERROR		-1	/* generic error */
#define EDRVNR		-2	/* drive not ready */
#define EUNCMD		-3	/* unknown command */
#define E_CRC		-4	/* crc error */
#define EBADRQ		-5	/* bad request */
#define E_SEEK		-6	/* seek error */
#define EMEDIA		-7	/* unknown media */
#define ESECNF		-8	/* sector not found */
#define EPAPER		-9	/* out of paper */
#define EWRITF		-10	/* write fault */
#define EREADF		-11	/* read fault */
#define EGENRL		-12	/* general error */
#define EWRPRO		-13	/* device write protected */
#define E_CHNG		-14	/* media change detected */
#define EUNDEV		-15	/* unknown device */
#define EBADSF		-16	/* bad sectors on format */
#define EOTHER		-17	/* insert other disk request */
#define EINSERT		-18	/* insert media (MetaDOS) */
#define EDVNRSP		-19	/* drive not responding (MetaDOS) */

/* GEMDOS errors */

#define EINVFN		-32	/* invalid function */
#define EINVAL		EINVFN
#define EFILNF		-33	/* file not found */
#define ESRCH		EFILNF
#define EPTHNF		-34	/* path not found */
#define ENHNDL		-35	/* no more handles */
#define EACCDN		-36	/* access denied */
#define EACCES		EACCDN
#define EPERM		EACCDN
#define EIHNDL		-37	/* invalid handle */
#define ENSMEM		-39	/* insufficient memory */
#define EIMBA		-40	/* invalid memory block address */
#define EDRIVE		-46	/* invalid drive specification */
#define ECWD		-47	/* tried to delete current directory (Big-DOS) */
#define ENSAME		-48	/* cross device rename */
#define EXDEV		ENSAME
#define ENMFIL		-49	/* no more files (from fsnext) */
#define ELOCKED		-58	/* record is locked already */
#define ENSLOCK		-59	/* invalid lock removal request */
#define ERANGE		-64	/* range error */
#define EINTRN		-65	/* internal error */
#define EPLFMT		-66	/* invalid program load format */
#define ENOEXEC		EPLFMT
#define EGSBF		-67	/* memory block growth failure */
#define EBREAK		-68	/* terminated with ^C (KAOS, MagiC, Big-DOS) */
#define EXCPT		-69	/* terminated with bombs (KAOS, MagiC) */
#define EPTHOV		-70	/* path overflow (MagiC) */
#define ENAMETOOLONG	ERANGE	/* a filename component is too long */
#define ELOOP		-80	/* too many symbolic links */
#define EPIPE		-81	/* write to a broken pipe */

/* Falcon XBIOS errors */

#define SNDNOTLOCK	-128	/* sound system isn't locked */
#define SNDLOCKED	-129	/* sound system is already locked */

/* 
 * this isn't really an error at all, just an indication to the kernel
 * that a mount point may have been crossed
 */

#define EMOUNT		-200

#define EAGAIN		-326		/* Operation would block.  */
#undef EWOULDBLOCK
#define EWOULDBLOCK	EAGAIN


#endif /* _ATARIERR_H */
