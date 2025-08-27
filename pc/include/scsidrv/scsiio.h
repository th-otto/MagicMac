/****************************************************************************
 *
 * Definitions and commands for SCSI-Calls in C
 *
 * $Source: U:\USR\src\scsi\CBHD\include\scsidrv\RCS\scsiio.h,v $
 *
 * $Revision: 1.7 $
 *
 * $Author: S_Engel $
 *
 * $Date: 1995/11/28 19:14:14 $
 *
 * $State: Exp $
 *
 *****************************************************************************
 * History:
 *
 * $Log: scsiio.h,v $
 * Revision 1.7  1995/11/28  19:14:14  S_Engel
 * *** empty log message ***
 *
 * Revision 1.6  1995/10/22  15:43:34  S_Engel
 * Kommentare leicht ueberarbeitet
 *
 * Revision 1.5  1995/10/03  12:49:08  S_Engel
 * Typendefinitionen nach scsidefs uebertragen
 *
 * Revision 1.4  1995/09/29  09:12:16  S_Engel
 * alles noetige fuer virtuelles RAM
 *
 * Revision 1.3  1995/06/16  12:06:46  S_Engel
 * *** empty log message ***
 *
 * Revision 1.2  1995/03/09  09:53:16  S_Engel
 * Flags: Disconnect eingefuehrt
 *
 * Revision 1.1  1995/03/05  18:54:16  S_Engel
 * Initial revision
 *
 *
 *
 ****************************************************************************/


#ifndef __SCSIIO_H
#define __SCSIIO_H

#include "scsidrv/scsidefs.h"

/*****************************************************************************
 * Types
 *****************************************************************************/


/*****************************************************************************
 * Constants                                                                 *
 *****************************************************************************/
#define DefTimeout 4000




/*****************************************************************************
 * Variables
 *****************************************************************************/

extern tpScsiCall scsicall;   /* READ ONLY!! */

extern int HasVirtual;        /* READ ONLY!! */

extern tReqData ReqBuff;      /* Request sense buffer for all commands */

extern short DriverRev;       /* Revision of identified scsidriver in system */

/*****************************************************************************
 * Functions and associated types
 *****************************************************************************/




/* These routines can be called for In and Out, they automatically observe
 * if the data has to be copied over in virtual RAM
 */
long In(tpSCSICmd Parms);

long Out(tpSCSICmd Parms);

long InquireSCSI(short what, tBusInfo *Info);

long InquireBus(short what, short BusNo, tDevInfo *Dev);

long CheckDev(short BusNo, const DLONG *DevNo, char *Name, unsigned short *Features);

long RescanBus(short BusNo);

long Open(short bus, const DLONG *Id, unsigned long *MaxLen);

long Close(tHandle handle);

long Error(tHandle handle, short rwflag, short ErrNo);



/* initialization of the module */
int init_scsiio(void);

#endif
