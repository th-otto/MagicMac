/*      MGX_DOS.H

     MagiC GEMDOS/(X)BIOS Definition Includes

	Andreas Kromke
	31.1.98

	- 20.8.99: SLB_EXEC und Slbclose korrigiert
*/

#include <tos.h>

/* Device Identifiers  (BIOS) */

#define CON	2

/* GEMDOS- Device- Handles */

#define HDL_CON -1
#define HDL_AUX -2
#define HDL_PRN -3
#define HDL_NUL -4		   /* KAOS extension */

/* GEMDOS Pexec Modes */

#define EXE_LDEX    0                                       /* TOS */
#define EXE_LD      3                                       /* TOS */
#define EXE_EX      4                                       /* TOS */
#define EXE_BASE    5                                       /* TOS */
#define EXE_EXFR    6                                       /* TOS 1.4  */
#define EXE_XBASE   7                                       /* TOS 3.01 */
#define XEXE_INIT   101                                     /* MAG!X      */
#define XEXE_TERM   102                                     /* MAG!X      */
#define XEXE_XBASE  107                                     /* Mag!X 2.10 */
#define XEXE_EXACC  108                                     /* Mag!X 2.10 */


/* Psemaphore */

#define PSEM_CRGET       0                                  /* MagiC 3.0 */
#define PSEM_DESTROY     1
#define PSEM_GET         2
#define PSEM_RELEASE     3

/* Dlock modes */

#define DLOCKMODE_LOCK   1
#define DLOCKMODE_UNLOCK 0
#define DLOCKMODE_GETPID 2

/* additional Dcntl/Fcntl Modes */

#define KER_DRVSTAT			0x0104	/* Kernel: Drive-Status (ab 9.9.95) */
#define KER_XFSNAME			0x0105	/* Kernel: XFS-Name (ab 15.6.96) */


/****** Tos *************************************************************/

/* Memory Control Block */

typedef struct
     {
     long mcb_magic;                    /* 'ANDR' oder 'KROM' (letzter)    */
     long mcb_len;                      /* Nettol„nge                      */
     long mcb_owner;                    /* PD *                            */
     long mcb_prev;                     /* vorh. Block oder NULL           */
     char mcb_data[0];
     } MCB;

/************************************************************************/
