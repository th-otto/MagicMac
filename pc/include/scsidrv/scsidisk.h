/*********************************************************************
 *
 * Kommandos zum Zugriff auf CD-ROMs
 *
 * $Source: u:\k\usr\src\scsi\cbhd\rcs\scsidisk.h,v $
 *
 * $Revision: 1.2 $
 *
 * $Author: S_Engel $
 *
 * $Date: 1995/11/28 19:14:14 $
 *
 * $State: Exp $
 *
 **********************************************************************
 * History:
 *
 * $Log: scsidisk.h,v $
 * Revision 1.2  1995/11/28  19:14:14  S_Engel
 * *** empty log message ***
 *
 * Revision 1.1  1995/11/13  23:45:38  S_Engel
 * Initial revision
 *
 *
 *
 *********************************************************************/

#ifndef __SCSIDISK_H
#define __SCSIDISK_H

long Read6(unsigned long BlockAdr, unsigned short TransferLen, void *buffer);

long Read10(unsigned long BlockAdr, unsigned short TransferLen, void *buffer);

long Write6(unsigned long BlockAdr, unsigned short TransferLen, void *buffer);

long Write10(unsigned long BlockAdr, unsigned short TransferLen, void *buffer);


long Read(unsigned long BlockAdr, unsigned short TransferLen, void *buffer);
  /*
   * ReadCmd liest Datenblîcke ein
   * Wenn nîtig, wird ein langes Kommando (10 Byte, Class 1) verwendet.
   */

long Write(unsigned long BlockAdr, unsigned short TransferLen, void *buffer);
  /*
   * WriteCmd speichert Datenblîcke ab.
   * Wenn nîtig, wird ein langes Kommando (10 Byte, Class 1) verwendet.
   */

long StartStop(int LoadEject, int StartFlag);


/*-------------------------------------------------------------------------*/
/*-                                                                       -*/
/*- ReadCapacity fragt die Grîûe des Laufwerkes ab.                       -*/
/*- Bei PMI = TRUE wird der nach BlockAdr nÑchste Block angegeben, der    -*/
/*- noch ohne Verzîgerung Åbertragen werden kann.                         -*/
/*- Bei Platten kann dies der letzte PBlock auf dem gleichen Zylinder wie -*/
/*- BlockAdr sein, bei CD-ROMs in etwa der letzte Block, der ohne         -*/
/*- GeschwindigkeitsÑnderung Åbertragen werden kann.                      -*/
/*- PMI=FALSE erfragt die absolute Grîûe des GerÑtes.                     -*/
/*- SCSI-Opcode $25                                                       -*/
/*-                                                                       -*/
/*-                                                                       -*/
/*-------------------------------------------------------------------------*/
long ReadCapacity(int PMI, unsigned long *BlockAdr, unsigned long *BlockLen);


int init_scsidisk (void);
  /* Initialisierung des Moduls */


#endif


