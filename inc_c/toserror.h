/* BIOS level errors */

#define E_OK	  0		/* OK, no error 		*/
#define ERROR	 -1L	/* basic, fundamental error	*/
#define EDRVNR	 -2L	/* drive not ready		*/
#define EUNCMD	 -3L	/* unknown command		*/
#define E_CRC	 -4L	/* CRC error			*/
#define EBADRQ	 -5L	/* bad request			*/
#define E_SEEK	 -6L	/* seek error			*/
#define EMEDIA	 -7L	/* unknown media		*/
#define ESECNF	 -8L	/* sector not found		*/
#define EPAPER	 -9L	/* no paper			*/
#define EWRITF	-10L	/* write fault			*/
#define EREADF	-11L	/* read fault			*/
#define EGENRL	-12L	/* general error		*/
#define EWRPRO	-13L	/* write protect		*/
#define E_CHNG	-14L	/* media change 		*/
#define EUNDEV	-15L	/* unknown device		*/
#define EBADSF	-16L	/* bad sectors on format	*/
#define EOTHER	-17L	/* insert other disk	*/
#define EINSERT -18     /* insert media */

/* BDOS level errors */

#define EINVFN	-32L	/* invalid function number		 1 */
#define EFILNF	-33L	/* file not found				 2 */
#define EPTHNF	-34L	/* path not found				 3 */
#define ENHNDL	-35L	/* no handles left				 4 */
#define EACCDN	-36L	/* access denied				 5 */
#define EIHNDL	-37L	/* invalid handle				 6 */
#define ENSMEM	-39L	/* insufficient memory			 8 */
#define EIMBA	-40L	/* invalid memory block address 	 9 */
#define EDRIVE	-46L	/* invalid drive was specified	15 */
#define ENSAME - 48L	/* MV between two different drives 17 */
#define ENMFIL	-49L	/* no more files				18 */


/* our own inventions */

#define ERANGE	-64		/* range error (EBADARG in MiNT) */
#define EINTRN	-65 	/* internal error				34 */
#define EPLFMT	-66 	/* invalid program load format	35 */
#define EGSBF	-67 	/* setblock failure 			36 */

/* KAOS extensions */

#define EBREAK	-68 	/* user break (^C)				37 */
#define EXCPT	-69 	/* 68000- exception ("bombs")		38 */

/* MiNT extensions */

#define EROFS     EWRPRO
#define ENODEV    EUNDEV
#define ENOMEDIUM EOTHER
#define ESRCH   -20     /* no such process */
#define ECHILD  -21     /* no child processes */
#define EDEADLK -22     /* Resource deadlock would occur */
#define ENOTBLK -23     /* Block device required */
#define EISDIR  -24     /* Is a directory */
#define EINVAL  -25     /* Invalid argument */
#define EFTYPE  -26     /* Inappropriate file type or format */
#define EILSEQ  -27     /* Illegal byte sequence */
#define ENOSYS  EINVFN
#define ENOENT  EFILNF
#define ENOTDIR EPTHNF
#define EMFILE  ENHNDL
#define EACCES  EACCDN
#define EBADF   EIHNDL
#define EPERM   -38     /* Operation not permitted */
#define ENOMEM  ENSMEM
#define EFAULT  EIMBA
#define ENXIO   EDRIVE
#define EXDEV   ENSAME
#define ENMFILES ENMFIL
#define ENFILE  -50     /* File table overflow */
#define ELOCKED -58     /* Locking conflict */
#define ENSLOCK -59     /* No such lock */
#define EBADARG -64		/* Bad argument */
#define EINTERNAL EINTRN
#define ENOEXEC  EPLFMT
#define ETXTBSY -70		/* Text file busy */
#define EFBIG   -71		/* File too big */
#define ELOOP   -80		/* too many symlinks in path */
#define EPIPE   -81		/* Broken pipe */
#define EMLINK  -82		/* Too many links */
#define ENOTEMPTY -83	/* Directory not empty */
#define EEXIST   -85	/* File exists */
#define ENAMETOOLONG -86 /* Name too long */
#define ENOTTY   -87	/* Not a tty */
#define _ERANGE  -88	/* Range error; conflicts in MagiC */
#define EDOM     -89	/* Domain error */
#define EIO      -90	/* I/O error */
#define ENOSPC   -91	/* No space left on device */

#define EINTR    -128	/* Interrupted function call */

/* Falcon XBIOS errors.  */
#define ESNDLOCKED -129	/* Sound system is already locked */
#define ESNDNOTLOCK -128 /* Sound system is not locked */
/* note1: sometimes incorrectly defined as -130 */
/* note2: conflicts with EINTR from MiNT */


/*  MagiC extensions */

#define EBREAK -68  /* user break/Aborted by user              KAOS 1.2 */
#define EXCPT  -69  /* 68000- exception ("bombs")              KAOS 1.2 */
#define EPTHOV -70  /* path overflow (conflicts with ETXTBSY)  MAG!X    */

