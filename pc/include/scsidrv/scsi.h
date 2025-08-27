/*********************************************************************
 *
 * SCSI-Calls for all devices
 *
 * $Source: U:\USR\src\scsi\CBHD\include\scsidrv\RCS\scsi.h,v $
 *
 * $Revision: 1.2 $
 *
 * $Author: Steffen_Engel $
 *
 * $Date: 1996/02/14 11:33:52 $
 *
 * $State: Exp $
 *
 **********************************************************************
 * History:
 *
 * $Log: scsi.h,v $
 * Revision 1.2  1996/02/14  11:33:52  Steffen_Engel
 * keine globalen Kommandostrukturen mehr
 *
 * Revision 1.1  1995/11/28  19:14:14  S_Engel
 * Initial revision
 *
 *
 *
 *********************************************************************/

#ifndef __SCSI_H
#define __SCSI_H

#include "scsidrv/scsidefs.h"


/*****************************************************************************
 * Konstanten
 *****************************************************************************/

#define DIRECTACCESSDEV  0       /* direct access device (harddisk)      */
#define SEQACCESSDEV     1       /* sequentidal acces  (Streamer)        */
#define PRINTERDEV       2       /* Printer                              */
#define PROCESSORDEV     3       /* Hostadapter                          */
#define WORMDEV          4       /* WORM-drive                           */
#define ROMDEV           5       /* read-only drive (CD-ROM)             */
#define SCANNERDEF       6       /* scanner                              */
#define OPTICALMEMDEV    7       /* optical memory device                */
#define MEDIUMCHNGDEV    8       /* medium changer device (eg. JukeBox)  */
#define COMMDEV          9       /* Communicationdevice                  */
#define GRAPHDEV1       10
#define GRAPHDEV2       11
#define UNKNOWNDEV      31


/*
        SCSI opcodes
*/

#define TEST_UNIT_READY         0x00
#define REZERO_UNIT             0x01
#define REQUEST_SENSE           0x03
#define FORMAT_UNIT             0x04
#define READ_BLOCK_LIMITS       0x05
#define REASSIGN_BLOCKS         0x07
#define READ_6                  0x08
#define WRITE_6                 0x0a
#define SEEK_6                  0x0b
#define READ_REVERSE            0x0f
#define WRITE_FILEMARKS         0x10
#define SPACE                   0x11
#define INQUIRY                 0x12
#define RECOVER_BUFFERED_DATA   0x14
#define MODE_SELECT             0x15
#define RESERVE                 0x16
#define RELEASE                 0x17
#define COPY                    0x18
#define ERASE                   0x19
#define MODE_SENSE              0x1a
#define START_STOP              0x1b
#define RECEIVE_DIAGNOSTIC      0x1c
#define SEND_DIAGNOSTIC         0x1d
#define ALLOW_MEDIUM_REMOVAL    0x1e

#define READ_FORMAT_CAPACITIES  0x23
#define SET_WINDOW              0x24
#define READ_CAPACITY           0x25
#define READ_10                 0x28
#define WRITE_10                0x2a
#define SEEK_10                 0x2b
#define WRITE_VERIFY            0x2e
#define VERIFY                  0x2f
#define SEARCH_HIGH             0x30
#define SEARCH_EQUAL            0x31
#define SEARCH_LOW              0x32
#define SET_LIMITS              0x33
#define PRE_FETCH               0x34
#define READ_POSITION           0x34
#define SYNCHRONIZE_CACHE       0x35
#define LOCK_UNLOCK_CACHE       0x36
#define READ_DEFECT_DATA        0x37
#define MEDIUM_SCAN             0x38
#define COMPARE                 0x39
#define COPY_VERIFY             0x3a
#define WRITE_BUFFER            0x3b
#define READ_BUFFER             0x3c
#define UPDATE_BLOCK            0x3d
#define READ_LONG               0x3e
#define WRITE_LONG              0x3f
#define CHANGE_DEFINITION       0x40
#define WRITE_SAME              0x41
#define UNMAP		            0x42
#define READ_TOC                0x43
#define READ_HEADER             0x44
#define GET_CONFIGURATION       0x46
#define GET_EVENT_STATUS_NOTIFICATION 0x4a
#define LOG_SELECT              0x4c
#define LOG_SENSE               0x4d
#define XDWRITEREAD_10          0x53
#define MODE_SELECT_10          0x55
#define RESERVE_10				0x56
#define RELEASE_10				0x57
#define MODE_SENSE_10           0x5a
#define PERSISTENT_RESERVE_IN	0x5e
#define PERSISTENT_RESERVE_OUT	0x5f
#define VARIABLE_LENGTH_CMD		0x7f
#define EXTENDED_COPY       	0x83
#define RECEIVE_COPY_RESULTS	0x84
#define ACCESS_CONTROL_IN   	0x86
#define ACCESS_CONTROL_OUT  	0x87
#define READ_16             	0x88
#define COMPARE_AND_WRITE   	0x89
#define WRITE_16            	0x8a
#define READ_ATTRIBUTE      	0x8c
#define WRITE_ATTRIBUTE	    	0x8d
#define VERIFY_16				0x8f
#define SYNCHRONIZE_CACHE_16	0x91
#define WRITE_SAME_16			0x93
#define SERVICE_ACTION_BIDIRECTIONAL 0x9d
#define SERVICE_ACTION_IN_16	0x9e
#define SERVICE_ACTION_OUT_16	0x9f
#define REPORT_LUNS				0xa0
#define SECURITY_PROTOCOL_IN	0xa2
#define MAINTENANCE_IN      	0xa3
#define MAINTENANCE_OUT			0xa4
#define MOVE_MEDIUM             0xa5
#define EXCHANGE_MEDIUM     	0xa6
#define READ_12             	0xa8
#define SERVICE_ACTION_OUT_12	0xa9
#define WRITE_12                0xaa
#define READ_MEDIA_SERIAL_NUMBER 0xab /* Obsolete with SPC-2 */
#define SERVICE_ACTION_IN_12	0xab
#define WRITE_VERIFY_12         0xae
#define VERIFY_12	      		0xaf
#define SEARCH_HIGH_12          0xb0
#define SEARCH_EQUAL_12         0xb1
#define SEARCH_LOW_12           0xb2
#define SECURITY_PROTOCOL_OUT	0xb5
#define SEND_VOLUME_TAG         0xb6
#define READ_ELEMENT_STATUS     0xb8
#define WRITE_LONG_2            0xea

/*
 *  SCSI Architecture Model (SAM) Status codes. Taken from SAM-3 draft
 *  T10/1561-D Revision 4 Draft dated 7th November 2002.
 */
#define SAM_STAT_GOOD            0x00
#define SAM_STAT_CHECK_CONDITION 0x02
#define SAM_STAT_CONDITION_MET   0x04
#define SAM_STAT_BUSY            0x08
#define SAM_STAT_INTERMEDIATE    0x10
#define SAM_STAT_INTERMEDIATE_CONDITION_MET 0x14
#define SAM_STAT_RESERVATION_CONFLICT 0x18
#define SAM_STAT_COMMAND_TERMINATED 0x22	/* obsolete in SAM-3 */
#define SAM_STAT_TASK_SET_FULL   0x28
#define SAM_STAT_ACA_ACTIVE      0x30
#define SAM_STAT_TASK_ABORTED    0x40

/* values for service action in */
#define SAI_REPORT_SUPPORTED_OPCODES  0x0c
#define SAI_READ_CAPACITY_16  0x10
#define SAI_SEEK_CAPACITY_16  0x11
#define SAI_GET_LBA_STATUS    0x12
#define SAI_REPORT_REFERRALS  0x13
#define SAI_GET_PHY_ELEM_STATUS 0x17

/* values for VARIABLE_LENGTH_CMD service action codes
 * see spc4r17 Section D.3.5, table D.7 and D.8 */
#define VLC_SA_RECEIVE_CREDENTIAL 0x1800

/* values for maintenance in */
#define MI_REPORT_IDENTIFYING_INFORMATION 0x05
#define MI_REPORT_TARGET_PGS  0x0a
#define MI_REPORT_ALIASES     0x0b
#define MI_REPORT_SUPPORTED_OPERATION_CODES 0x0c
#define MI_REPORT_SUPPORTED_TASK_MANAGEMENT_FUNCTIONS 0x0d
#define MI_REPORT_PRIORITY    0x0e
#define MI_REPORT_TIMESTAMP   0x0f
#define MI_MANAGEMENT_PROTOCOL_IN 0x10

/* value for MI_REPORT_TARGET_PGS ext header */
#define MI_EXT_HDR_PARAM_FMT  0x20

/* values for maintenance out */
#define MO_SET_IDENTIFYING_INFORMATION 0x06
#define MO_SET_TARGET_PGS     0x0a
#define MO_CHANGE_ALIASES     0x0b
#define MO_SET_PRIORITY       0x0e
#define MO_SET_TIMESTAMP      0x0f
#define MO_MANAGEMENT_PROTOCOL_OUT 0x10

/* values for variable length command */
#define XDREAD_32	      0x03
#define XDWRITE_32	      0x04
#define XPWRITE_32	      0x06
#define XDWRITEREAD_32	      0x07
#define READ_32		      0x09
#define VERIFY_32	      0x0a
#define WRITE_32	      0x0b
#define WRITE_SAME_32	      0x0d


/* Values for T10/04-262r7 */
#define	ATA_16		      0x85	/* 16-byte pass-thru */
#define	ATA_12		      0xa1	/* 12-byte pass-thru */

/* Vendor specific CDBs start here */
#define VENDOR_SPECIFIC_CDB 0xc0

/*
 *  SENSE KEYS
 */
#define NO_SENSE            0x00
#define RECOVERED_ERROR     0x01
#define NOT_READY           0x02
#define MEDIUM_ERROR        0x03
#define HARDWARE_ERROR      0x04
#define ILLEGAL_REQUEST     0x05
#define UNIT_ATTENTION      0x06
#define DATA_PROTECT        0x07
#define BLANK_CHECK         0x08
#define VENDOR_SPECIFIC		0x09
#define COPY_ABORTED        0x0a
#define ABORTED_COMMAND     0x0b
#define VOLUME_OVERFLOW     0x0d
#define MISCOMPARE          0x0e
#define COMPLETED			0x0f


/*
 *  DEVICE TYPES
 */

#define TYPE_DISK           0x00
#define TYPE_TAPE           0x01
#define TYPE_PRINTER        0x02
#define TYPE_PROCESSOR      0x03    /* HP scanners use this */
#define TYPE_WORM           0x04
#define TYPE_ROM            0x05
#define TYPE_SCANNER        0x06
#define TYPE_MOD            0x07    /* Magneto-optical disk - treated as TYPE_DISK */
#define TYPE_MEDIUM_CHANGER 0x08
#define TYPE_COMM           0x09    /* Communications device */
#define TYPE_RAID           0x0c
#define TYPE_ENCLOSURE      0x0d    /* Enclosure Services Device */
#define TYPE_RBC			0x0e	/* Simplified Direct Access */
#define TYPE_OCR			0x0f	/* Optical Card Reader */
#define TYPE_BRIDGE			0x10	/* Bridge Controller */
#define TYPE_OSD            0x11	/* Object-based Storage */
#define TYPE_ADC			0x12	/* Automation/Drive Interface */
#define TYPE_SECURITY		0x13
#define TYPE_ZBC            0x14	/* Zoned Block Commands */
#define TYPE_WLUN           0x1e    /* well-known logical unit */
                         /* 0x1f       unknown or no device type */
#define TYPE_NO_LUN         0x7f


/*****************************************************************************
 * Typen
 *****************************************************************************/

/* Inquiry-Struktur */
typedef struct
{
  unsigned char Device;
  unsigned char Qualifier;
  unsigned char Version;
  unsigned char Format;
  unsigned char AddLen;
  unsigned char Res1;
  unsigned short Res2;
  char  Vendor[8];
  char  Product[16];
  char  Revision[4];
} tInqData;

/* Modesense/select-Typen */

/* Pages for CD-ROMS */
typedef struct{
  unsigned char CDP0DRes2;
  unsigned char InactTMul;      /* lower Nibble */
  unsigned short SperMSF;
  unsigned short FperMSF;
} tCDPage0D;

typedef struct {
  unsigned char ImmedFlags;
  unsigned char CD0ERes3;
  unsigned char CD0ERes4;
  unsigned char LBAFlags;
  unsigned short BlocksPerSecond;
    /* Genau:
     *   LBAFlags MOD 10H = 0 -> BlocksPerSecond
     *   LBAFlags MOD 10H = 8 -> 256 * BlocksPerSecond
     */
  unsigned char Port0Channel;
  unsigned char Port0Volume;
  unsigned char Port1Channel;
  unsigned char Port1Volume;
  unsigned char Port2Channel;
  unsigned char Port2Volume;
  unsigned char Port3Channel;
  unsigned char Port3Volume;
} tCDPage0E;

/* general strcture for ModeSense/Select */
typedef struct{
  signed char ModeLength;
  signed char MediumType;
  unsigned char DeviceSpecs;  /* device dependant */
  signed char BlockDescLen;
} tParmHead;

typedef struct{
  unsigned long Blocks;                  /* Byte HH = DensityCode */
  unsigned long BlockLen;                /* Byte HH = Reserved    */
} tBlockDesc;

/* variants of Pages */
typedef union{
  tCDPage0D CDP0D;
  tCDPage0E CDP0E;
} tPage;

typedef struct{
  tParmHead ParmHead;
  tBlockDesc BlockDesc;
  tPage Page;
} tModePage;


/*****************************************************************************
 * Variables
 *****************************************************************************/
extern long ScsiFlags;   /* values for tScsiCmd.Flags */


/*****************************************************************************
 * Functions
 *****************************************************************************/

long TestUnitReady(void);


/* read inquiry from a device */
long Inquiry(void  *data, int Vital, unsigned short VitalPage, short length);

#define MODESEL_SMP 0x01            /* Save Mode Parameters */
#define MODESEL_PF  0x10            /* Page Format          */

long ModeSelect(unsigned short SelectFlags, void *Buffer, unsigned short ParmLen);

#define MODESENSE_CURVAL 0          /* current values     */
#define MODESENSE_CHANGVAL 1        /* changeable values  */
#define MODESENSE_DEFVAL 2          /* default values     */
#define MODESENSE_SAVEDVAL 3        /* save values        */

long ModeSense(unsigned short PageCode, unsigned short PageControl, void *Buffer, unsigned short ParmLen);


long PreventMediaRemoval(int Prevent);


/* Initialization of the module */
int init_scsi(void);



/*-------------------------------------------------------------------------*/
/*-                                                                       -*/
/*- General tools                                                         -*/
/*-                                                                       -*/
/*-------------------------------------------------------------------------*/
void SuperOn(void);

void SuperOff(void);

void Wait(unsigned long Ticks);

/*
 * SetBlockLen defines the block size of the device
 * (normally 512 bytes).
 */
void SetBlockSize(unsigned long NewLen);

/*
 * GetBlockLen return the define block size.
 */
unsigned long GetBlockSize(void);


/*
 * SetScsiUnit specifies the device to which the following commands
 * are sent and the maximum length of the transfers.
 */
void SetScsiUnit(tHandle handle, short Lun, unsigned long MaxLen);


/*-------------------------------------------------------------------------*/
/*-                                                                       -*/
/*- Access for submodules (ScsiStreamer, ScsiCD, ScsiDisk...)             -*/
/*-                                                                       -*/
/*-------------------------------------------------------------------------*/

typedef struct
{
  unsigned char Command;
  unsigned char LunAdr;
  unsigned short     Adr;
  unsigned char Len;
  unsigned char Flags;
} tCmd6;

typedef struct
{
  unsigned char Command;
  unsigned char Lun;
  unsigned long     Adr;
  signed char Reserved;
  unsigned char LenHigh;
  unsigned char LenLow;
  unsigned char Flags;
} tCmd10;

typedef struct
{
  unsigned char Command;
  unsigned char Lun;
  unsigned long     Adr;
  unsigned long     Len;
  signed char Reserved;
  unsigned char Flags;
} tCmd12;


extern unsigned long    BlockLen;
extern unsigned long    MaxDmaLen;
extern unsigned short    LogicalUnit;

void SetCmd6(tCmd6 *Cmd, unsigned short Opcode, unsigned long BlockAdr, unsigned short TransferLen);
void SetCmd10(tCmd10 *Cmd, unsigned short Opcode, unsigned long BlockAdr, unsigned short TransferLen);
         
void SetCmd12(tCmd12 *Cmd, unsigned short Opcode, unsigned long BlockAdr, unsigned long TransferLen);

tpSCSICmd SetCmd(char *Cmd, short CmdLen, void *Buffer, unsigned long Len, unsigned long TimeOut);


#endif
