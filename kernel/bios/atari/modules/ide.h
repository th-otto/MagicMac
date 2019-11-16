/*
	@(#)SCSI-Tool/ide.h
	
	structures for the access to IDE devices
	Julian F. Reschke, 12. November 1993
*/
#include <portab.h>
#ifndef __IDE_H
#define __IDE_H

#define IDEDR (ULONG *)0xfff00000L
#define IDEER (ULONG *)0xfff00005L
typedef struct
{
	struct {
		unsigned reserved1 : 1;
		unsigned fstgr : 1;
		unsigned tooa : 1;
		unsigned dsooa : 1;
		unsigned rst : 1;
		unsigned dtrgt10 : 1;
		unsigned dtrgt5 : 1;
		unsigned dtrlt5 : 1;
		unsigned removable : 1;
		unsigned fixed : 1;
		unsigned smcoi : 1;
		unsigned hst : 1;
		unsigned notmfm : 1;
		unsigned softsec : 1;
		unsigned hardsec : 1;
		unsigned reserved2 : 1;
	} configuration;

	UWORD	cylinders;
	UWORD	reserved1;
	UWORD	heads;
	UWORD	unformatted_UBYTEs_per_track;
	UWORD	unformatted_UBYTEs_per_sector;
	UWORD	sectors_per_track;
	UWORD	reserved2a, reserved2b, reserved2c;
	char	serialnum[20];
	UWORD	buffer_type;
	UWORD	buffer_size;
	UWORD	ecc_UBYTEs;
	char	firmware[8];
	char	modelnumber[40];
	UBYTE	reserved3;
	UBYTE	rw_multiple;
	UWORD	doubleword;
	struct {
		unsigned reserved1 : 6;
		unsigned lba : 1;
		unsigned dma : 1;
		unsigned reserved2: 8;
	} capabilities;
	UWORD	reserved4;
	UBYTE	pio_data_timing;
	UBYTE	reserved5;
	UBYTE	dma_data_timing;
	UBYTE	reserved6;
	UWORD	have_current;
	UWORD	curcyl, curheads, curspt;
	UWORD	capacityl, capacityh;
	UBYTE	w59h, w59l;
	UWORD	capacity_lbal, capacity_lbah;
	UWORD	swdma, mwdma;
	UWORD	reserved7[192];
} IDE_IDENTIFICATION;

#if sizeof(IDE_IDENTIFICATION) != 512
#error "IDE_IDENTIFICATION kaputt"
#endif

typedef struct
{
	char	key[32];
	BYTE	flags1;
	BYTE	reserved[3];
	BYTE	flags2;
	BYTE	retries;
	BYTE	ecc_scan;
	BYTE	flags3;
	BYTE	reserved2[472];
} IDE_QUANTUM_CONF;

typedef WORD idestatus;
typedef WORD ideerror;
typedef WORD unit;

#define IDE_EBBK	0x80
#define IDE_EUNC	0x40
#define IDE_EMC		0x20
#define IDE_EIDNF	0x10
#define IDE_EMCR	0x08
#define IDE_EABRT	0x04
#define IDE_ETK0NF	0x02
#define IDE_EAMNF	0x01

#define IDE_SBSY	0x80
#define	IDE_SDRDY	0x40
#define IDE_SDWF	0x20
#define IDE_SDSC	0x10
#define IDE_SDRQ	0x08
#define IDE_SCORR	0x04
#define IDE_SIDX	0x02
#define IDE_SERR	0x01

ideerror IDEDiagnostic(void);
ideerror IDEError(void);
idestatus IDEFormatTrack(unit device, WORD head, UWORD cylinder, WORD sector_count, void *data, WORD *retries);
idestatus IDEIdentify(unit device, IDE_IDENTIFICATION *data);
idestatus IDEInitDrive(unit device, IDE_IDENTIFICATION *data );
idestatus IDEPowerMode(unit devive, char idle, char standby);
idestatus IDERead(unit device, ULONG sector, UWORD count, void *data, LONG *jiffies);
idestatus IDEQuantumReadConfiguration(unit device, IDE_QUANTUM_CONF *data);
idestatus IDEQuantumWriteConfiguration(unit device, IDE_QUANTUM_CONF *data);
idestatus IDERecalibrate (unit device);
void IDEReset(void);
idestatus IDEWrite(unit device, ULONG sector, UWORD count, const void *data);


#endif
