/****************************************************************************
 *
 * Types for SCSI-Calls in C
 *
 * $Source: u:\k\usr\src\scsi\cbhd\rcs\scsidefs.h,v $
 *
 * $Revision: 1.8 $
 *
 * $Author: Steffen_Engel $
 *
 * $Date: 1996/02/14 11:33:52 $
 *
 * $State: Exp $
 *
 *****************************************************************************
 * History:
 *
 * $Log: scsidefs.h,v $
 * Revision 1.8  1996/02/14  11:33:52  Steffen_Engel
 * keine globalen Kommandostrukturen mehr
 *
 * Revision 1.7  1996/01/25  17:53:16  Steffen_Engel
 * Tippfehler bei PARITYERROR korrigiert
 *
 * Revision 1.6  1995/11/28  19:14:14  S_Engel
 * *** empty log message ***
 *
 * Revision 1.5  1995/11/14  22:15:58  S_Engel
 * Kleine Korrekturen
 * aktualisiert auf aktuellen Stand
 *
 * Revision 1.4  1995/10/22  15:43:34  S_Engel
 * Kommentare leicht ueberarbeitet
 *
 * Revision 1.3  1995/10/13  22:30:54  S_Engel
 * GetMsg in Struktur eingefuegt
 *
 * Revision 1.2  1995/10/11  10:21:34  S_Engel
 * Handle als long, Disconnect auf Bit4 verlegt
 *
 * Revision 1.1  1995/10/03  12:49:42  S_Engel
 * Initial revision
 *
 *
 ****************************************************************************/


#ifndef __SCSIDEFS_H
#define __SCSIDEFS_H

/*****************************************************************************
 * Konstanten
 *****************************************************************************/
#define SCSIRevision 0x0101     /* Version 1.01
                                 * ATTENTION:
                                 * The version number represents the sub-revision in the
                                 * low byte, the major version in the high byte.
                                 * Clients must check the high byte for basic recognition
                                 * of a usable revision,
                                 * the low byte only for the use of extensions of a specific sub-revision.
                                 * See also scsiio.init_scsiio.
                                 */

#define MAXBUSNO        31      /* maximum possible bus number */

#ifdef WIN32
  #define USEASPI
#endif

/* Konvertierung Intel/Motorola */
#if __BYTE_ORDER__ != __ORDER_BIG_ENDIAN__
  #define w2mot(A) ((((A) & 0xff) << 8) | (((A) & 0xff00) >> 8))
  #define l2mot(A) (((unsigned long)w2mot((A) & 0xffff) << 16) | (unsigned long)w2mot((((unsigned long)(A) >> 16) & 0xffffUL))
#else
  #define w2mot(A) (A)
  #define l2mot(A) (A)
#endif


/* SCSI error message for In und Out */

#define NOSCSIERROR      0L /* No error                                      */
#define SELECTERROR     -1L /* Fehler beim Selektieren                       */
#define STATUSERROR     -2L /* Error while selecting                         */
#define PHASEERROR      -3L /* invalid phase                                 */
#define BSYERROR        -4L /* BSY lost                                      */
#define BUSERROR        -5L /* Bus error during DMA transfer                 */
#define TRANSERROR      -6L /* DMA transfer error (nothing transferred)      */
#define FREEERROR       -7L /* Bus is no longer released                     */
#define TIMEOUTERROR    -8L /* Timeout                                       */
#define DATATOOLONG     -9L /* Data too long for ACSI soft transfer          */
#define LINKERROR      -10L /* Error sending linked command (ACSI)           */
#define TIMEOUTARBIT   -11L /* Arbitration timeout                           */
#define PENDINGERROR   -12L /* there is an error on this handle              */
#define PARITYERROR    -13L /* Transfer caused parity errors                 */


/*****************************************************************************
 * Typen
 *****************************************************************************/

typedef struct
{
  unsigned long hi;
  unsigned long lo;
} DLONG;


typedef struct
{
  unsigned long BusIds;               /* processed bus numbers
                                       * Each driver must set the bit corresponding
                                       * to its bus number in InquireSCSI.
                                       */
  char  resrvd[28];                   /* for extensions */
} tPrivate;

typedef short *tHandle;               /* Pointer to BusFeatures */

typedef struct
{
  tHandle Handle;                     /* Handle for bus and device            */
  char *Cmd;                          /* Pointer to CmdBlock                  */
  unsigned short CmdLen;              /* Length of the cmd block (necessary for ACSI) */
  void *Buffer;                       /* Data buffer                          */
  unsigned long TransferLen;          /* Transmission length                  */
  char *SenseBuffer;                  /* Buffer for ReqSense (18 bytes)       */
  unsigned long Timeout;              /* Timeout in 1/200 sec                 */
  unsigned short Flags;               /* Bit vector for process requests      */
    #define Disconnect 0x10           /* try disconnect                       */

} tSCSICmd;
typedef tSCSICmd *tpSCSICmd;


typedef struct
{
  tPrivate Private;
   /* for the driver, drivers must respect and use the defined format,
    * For applications, interpreting these parameters is prohibited! */
  char BusName[20];
   /* eg. 'SCSI', 'ACSI', 'PAK-SCSI' */
  unsigned short BusNo;
   /* Number under which the bus can be contacted */
  unsigned short Features;
      #define cArbit     0x01     /* Arbitration takes place on the bus                   */
      #define cAllCmds   0x02     /* All SCSI-Cmds can be sent here                       */
      #define cTargCtrl  0x04     /* The target controls the process (that's how it should be!)      */
      #define cTarget    0x08     /* on this bus you can install yourself as a target */
      #define cCanDisconnect 0x10 /* Disconnect is possible                              */
      #define cScatterGather 0x20 /* scatter gather possible with virtual RAM */
      #define c32LUNs    0x40     /* SCSI Driver extension supported since HDDRIVER 12: Support for 32 LUNs */
  /* up to 16 features that the bus can do, e.g. Arbit,
   * Full SCSI (all SCSI Cmds as opposed to ACSI)
   * Target or initiator controlled
   * A SCSI handle is also a pointer to a copy of this information!
   */
  unsigned long MaxLen;
  /* maximum transfer length on this bus (in bytes)
   * For example, in ACSI, this corresponds to the size of the FRB
   */
} tBusInfo;

typedef struct
{
  char Private[32];
  DLONG SCSIId;
}tDevInfo;


#undef cdecl
#if defined(__PUREC__)
#  define cdecl cdecl
#elif defined(__GNUC__) && defined(__FASTCALL__)
#  define cdecl __attribute((__cdecl__))
#else
#  define cdecl
#endif


typedef struct ttargethandler
{
  struct  ttargethandler *next;
  short   cdecl (*TSel)         (short     bus, unsigned short    CSB, unsigned short CSD);
  short   cdecl (*TCmd)         (short     bus, char *Cmd);
  unsigned short   cdecl (*TCmdLen)      (short     bus, unsigned short    Cmd);
  void    cdecl (*TReset)       (unsigned short    bus);
  void    cdecl (*TEOP)         (unsigned short    bus);
  void    cdecl (*TPErr)        (unsigned short    bus);
  void    cdecl (*TPMism)       (unsigned short    bus);
  void    cdecl (*TBLoss)       (unsigned short    bus);
  void    cdecl (*TUnknownInt)  (unsigned short    bus);
} tTargetHandler;

typedef tTargetHandler *tpTargetHandler;

typedef char tReqData[18];

/* Cookie SCSI points to this */
typedef struct
{
  unsigned short Version;                /* Revision in BCD: $0100 = 1.00 */
  
  /* Routinen als Initiator */
  long  cdecl (*In)           (tpSCSICmd  Parms);
  long  cdecl (*Out)          (tpSCSICmd  Parms);
  
  long  cdecl (*InquireSCSI)  (short what, tBusInfo  *Info);
    #define cInqFirst  0
    #define cInqNext   1
  long  cdecl (*InquireBus)   (short       what,
                               short       BusNo,
                               tDevInfo  *Dev);

  long  cdecl (*CheckDev)     (short       BusNo,
                               const DLONG *SCSIId,
                               char      *Name,
                               unsigned short     *Features);
  long  cdecl (*RescanBus)    (short       BusNo);


  long  cdecl (*Open)         (short BusNo, const DLONG *SCSIId, unsigned long *MaxLen);
  long  cdecl (*Close)        (tHandle    handle);
  long  cdecl (*Error)        (tHandle    handle, short rwflag, short ErrNo);
        #define cErrRead   0
        #define cErrWrite  1
          #define cErrMediach  0
          #define cErrReset    1
  
  /* Routinen als Target (optional) */
  long  cdecl (*Install)    (short       bus, tpTargetHandler Handler);
  long  cdecl (*Deinstall)  (short       bus, tpTargetHandler Handler);
  long  cdecl (*GetCmd)     (short       bus, char *Cmd);
  long  cdecl (*SendData)   (short       bus, void *Buffer, unsigned long Len);
  long  cdecl (*GetData)    (short       bus, void *Buffer, unsigned long Len);
  long  cdecl (*SendStatus) (short       bus, unsigned short Status);
  long  cdecl (*SendMsg)    (short       bus, unsigned short Msg);
  long  cdecl (*GetMsg)     (short       bus, unsigned short *Msg);
  
  /* global variables (for target routines) */
  tReqData      *ReqData;
} tScsiCall;
typedef tScsiCall *tpScsiCall;

#endif
