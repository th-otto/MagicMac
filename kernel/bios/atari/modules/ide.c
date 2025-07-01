/*
	@(#)SCSI-Tool/ide.c

	Julian F. Reschke, 21. November 1993
	Functions for the IDE interface
*/

#include <stddef.h>
#include <stdio.h>
#include <tos.h>

#include "ide.h"

#define _hz_200 ((volatile ULONG *)0x4baL)
#define GPIP ((volatile UBYTE *)0xfffffa01L)


#define SECTOR_SIZE 512


/* IDE opcodes */

#define IDE_DIAGNOSTIC	0x90
#define IDE_EXTCOMMAND	0xf0
#define IDE_FORMAT		0x50
#define IDE_IDENTIFY	0xec
#define IDE_IDLEMODE	0xe3
#define IDE_INIDRIVE	0x91
#define IDE_READ		0x20
#define IDE_READMULTIPLE	0xc4
#define IDE_RECALIBRATE	0x10
#define IDE_SETMULTIPLE	0xc6
#define IDE_STANDBYMODE	0xe2
#define IDE_WRITE		0x30


/* timeouts */

#define LONG_TIMEOUT	2000L
#define MEDIUM_TIMEOUT	200L
#define SHORT_TIMEOUT	200L
#define TIMEOUT -1

/* IO-Register-Struktur */

typedef struct
{
	volatile UWORD dr;
	UBYTE reserved1[3];
	volatile UBYTE er;
	UBYTE reserved2[3];
	volatile UBYTE sc;
	UBYTE reserved3[3];
	volatile UBYTE sn;
	UBYTE reserved4[3];
	volatile UBYTE cl;
	UBYTE reserved5[3];
	volatile UBYTE ch;
	UBYTE reserved6[3];
	volatile UBYTE sdh;
	UBYTE reserved7[3];
	volatile UBYTE srcr;
	UBYTE reserved8[0x1b];
	volatile UBYTE asrdor;
} IDEREGS;

#if offsetof(IDEREGS,asrdor) != 0x39
#error "error in IDEREGS"
#endif


/* place for the IDE data */

typedef struct
{
	UWORD heads;
	UWORD spt;
	UWORD cylinders;
	ULONG spc;
	WORD multi_sector;
	UWORD res[2];						/* to make it 16 bytes */
} IDE_PARAM;

extern IDE_PARAM ideparm[2];


/* timeout stuff */

static void ide_wait_ms(long ms)
{
	long old;

	ms /= 5;

	old = *_hz_200;
	while (*_hz_200 < old + ms)
		;
}


/* write 512 bytes to the IDE bus */

static void write_ide(IDEREGS *ide, const void *data)
{
	int count;
	const UWORD *from = (const UWORD *) data;

	for (count = 0; count < (SECTOR_SIZE / 16); count++)
	{
		ide->dr = *from++;
		ide->dr = *from++;
		ide->dr = *from++;
		ide->dr = *from++;
		ide->dr = *from++;
		ide->dr = *from++;
		ide->dr = *from++;
		ide->dr = *from++;
	}
}


/* read 512 bytes from IDE bus */

static void read_ide(IDEREGS *ide, void *data)
{
	UWORD *target = (UWORD *) data;
	int count;

	for (count = 0; count < (SECTOR_SIZE / 16); count++)
	{
		*target++ = ide->dr;
		*target++ = ide->dr;
		*target++ = ide->dr;
		*target++ = ide->dr;
		*target++ = ide->dr;
		*target++ = ide->dr;
		*target++ = ide->dr;
		*target++ = ide->dr;
	}
}


/* wait for status from IDE interface */

static idestatus wait_for_ready(IDEREGS *ide, ULONG timeout)
{
	ULONG until;
	UBYTE status;

	until = *_hz_200 + timeout;

#if defined(RAVEN)
    status = ide->asrdor;
    while (status & (1 << 7)) {
        status = ide->asrdor;
		if (*_hz_200 > until)
			return TIMEOUT;
    }
#else
	while (*GPIP & 0x20)
		if (*_hz_200 > until)
			return TIMEOUT;
	status = ide->srcr;
#endif

	if (status & (IDE_SERR | IDE_SDRQ))
		return status;
	else
		return 0;
}

/* Send identify command. Returns 0 on success */

static idestatus ide_identify(int device, void *data)
{
	IDEREGS *ide = (IDEREGS *) IDEDR;
	idestatus status;

	ide->sdh = ((device & 7) << 4) | 0xa0;
#if defined(RAVEN)
	ide->asrdor = (1 << 1);	/* no interrupts */
#else
	ide->asrdor = 0;	/* enable interrupt */
#endif
	ide->srcr = IDE_IDENTIFY;	/* send ATA command IDENTIFY DEVICE */

	status = wait_for_ready(ide, LONG_TIMEOUT);

	if (status < 0 || (status & IDE_SERR) || !(status & IDE_SDRQ))
		return status;					/* timeout or error or no data request */

	read_ide(ide, data);

	return 0;
}


idestatus IDEIdentify(unit device, IDE_IDENTIFICATION *data)
{
	idestatus result;

	result = ide_identify(device, data);

	return result;
}




/* Test for Target beging present. Returns 0 on success */

static idestatus ide_recalibrate(int device)
{
	IDEREGS *ide = (IDEREGS *) IDEDR;

	ide->sdh = ((device & 7) << 4) | 0xa0;
	ide->asrdor = 0;
	ide->srcr = IDE_RECALIBRATE; /* send ATA command RECALIBRATE */

	return wait_for_ready(ide, MEDIUM_TIMEOUT);
}


#if 0
idestatus IDERecalibrate(unit device)
{
	idestatus result;

	result = ide_recalibrate(device);
	
	return result;
}
#endif


/* Perform diagnostic */

static ideerror ide_diagnostic(void)
{
#if defined(RAVEN)
	IDEREGS *ide = (IDEREGS *) IDEDR;
    ide->sdh = 0xa0;
	ide->asrdor = 0;
	ide->srcr = IDE_DIAGNOSTIC; /* send ATA command EXECUTE DEVICE DIAGNOSTICS */
    wait_for_ready(ide, LONG_TIMEOUT);
	return ide->er;
#else
    IDEREGS *ide = (IDEREGS *) IDEDR;
	ULONG until;

	ide->sdh = 0xa0;
	ide->asrdor = 0;
	ide->srcr = IDE_DIAGNOSTIC; /* send ATA command EXECUTE DEVICE DIAGNOSTICS */

	until = *_hz_200 + LONG_TIMEOUT;

	while (*GPIP & 0x20)
		if (*_hz_200 > until)
			return TIMEOUT;

	return ide->er;
#endif
}

#if 0
ideerror IDEDiagnostic(void)
{
	ideerror result;

	result = ide_diagnostic ();
	
	return result;
}
#endif


/* Perform reset */

static LONG ide_reset(void)
{
	IDEREGS *ide = (IDEREGS *) IDEDR;

	ide->asrdor |= 4;
	ide_wait_ms(50);
	ide->asrdor &= ~4;
	ide_wait_ms(200);
	return 0;
}


void IDEReset(void)
{
	ide_reset();
}


/* Initialize drive with parameters from ideparm */

static idestatus ide_init_drive(int device, UWORD heads, UWORD spt, UWORD cylinders)
{
	IDEREGS *ide = (IDEREGS *) IDEDR;

	device &= 7;

	ideparm[device].heads = heads;
	ideparm[device].spt = spt;
	ideparm[device].cylinders = cylinders;
	ideparm[device].spc = heads * spt;

	ide->sdh = (device << 4) | 0xa0 | (heads - 1);
	ide->sc = spt;
	ide->asrdor = 0;
	ide->srcr = IDE_INIDRIVE; /* send ATA command INITIALIZE DEVICE PARAMETERS */

	return wait_for_ready(ide, LONG_TIMEOUT);
}


static idestatus ide_set_multiple(int device, WORD multi_sector)
{
	IDEREGS *ide = (IDEREGS *) IDEDR;

	device &= 7;

	ideparm[device].multi_sector = multi_sector;

	ide->sdh = (device << 4) | 0xa0 | 0;
	ide->sc = multi_sector;
	ide->asrdor = 0;
	ide->srcr = IDE_SETMULTIPLE; /* send ATA command SET MULTIPLE MODE */

	return wait_for_ready(ide, LONG_TIMEOUT);
}


idestatus IDEInitDrive(unit device, IDE_IDENTIFICATION *data)
{
	idestatus result;
#ifdef BETA
	int multi_sector = 1;
	int mult = 0;
#endif

	result = ide_init_drive(device, data->heads, data->sectors_per_track, data->cylinders);
#ifdef BETA
	if (multi_sector >= 1)
		mult = 1;
	if (multi_sector >= 2)
		mult = 2;
	if (multi_sector >= 4)
		mult = 4;
	if (multi_sector >= 8)
		mult = 8;
/*	if (multi_sector >= 16) mult = 16;
	if (multi_sector >= 32) mult = 32; */
	if (ide_set_multiple(device, mult))
		ide_set_multiple(device, 0);
#endif

	return result;
}


/* Read sectors */

static idestatus ide_read(int device, ULONG sector, UWORD count, UBYTE *data)
{
	IDEREGS *ide = (IDEREGS *) IDEDR;
	idestatus status;
	UWORD spt;
	ULONG cylinder;
	ULONG spc;
	UWORD abs_sec;

	device &= 7;
	spt = ideparm[device].spt;
	spc = ideparm[device].spc;
	cylinder = sector / spc;
	abs_sec = (UWORD) (sector % spc);

	ide->cl = cylinder;
	ide->ch = cylinder >> 8;

	ide->sdh = (device << 4) | 0xa0 | (abs_sec / spt);
	ide->sn = 1 + (abs_sec % spt);
	ide->sc = count;
	ide->asrdor = 0;
	ide->srcr = IDE_READ; /* send ATA command READ SECTORS */

	while (count)
	{
		status = wait_for_ready(ide, LONG_TIMEOUT);
		if (status < 0 || (status & IDE_SERR) || !(status & IDE_SDRQ))
			return status;				/* timeout or error or no data request */

		read_ide(ide, data);
		data += SECTOR_SIZE;
		count -= 1;
	}

	return 0;
}


idestatus IDERead(unit device, ULONG sector, UWORD count, void *data, LONG *jiffies)
{
	idestatus result = 0;
	ULONG merk;

	merk = *_hz_200;

#ifdef BETA
	if (ideparm[device & 7].multi_sector > 1)
		result = ide_read_multiple(device, sector, count, data);
	else
#endif
		result = ide_read(device, sector, count, data);

	if (jiffies)
		*jiffies = *_hz_200 - merk;

	return result;
}


/* Write sectors */

static idestatus ide_write(int device, ULONG sector, UWORD count, const UBYTE *data)
{
	IDEREGS *ide = (IDEREGS *) IDEDR;
	idestatus status;
	UWORD spt;
	ULONG cylinder;
	ULONG spc;

	device &= 7;
	spt = ideparm[device].spt;
	spc = ideparm[device].spc;
	cylinder = sector / spc;
	sector %= spc;

	ide->cl = cylinder;
	ide->ch = cylinder >> 8;

	ide->sdh = (device << 4) | 0xa0 | (sector / spt);
	ide->sn = 1 + (sector % spt);
	ide->sc = count;
	ide->asrdor = 0;
	ide->srcr = IDE_WRITE;

	while (count)
	{
		while (!(ide->asrdor & IDE_SDRQ))	/* DRQ bit */
			;

		write_ide(ide, data);
		data += SECTOR_SIZE;

		status = wait_for_ready(ide, LONG_TIMEOUT);
		if (status < 0 || (status & IDE_SERR))
			return status;				/* timeout or error */
		if (!(status & IDE_SDRQ))
			return status;				/* XXX */

		count -= 1;
	}

	return 0;
}


idestatus IDEWrite(unit device, ULONG sector, UWORD count, const void *data)
{
	idestatus result;

	result = ide_write(device, sector, count, data);
	if (result)
		result = ide_write(device, sector, count, data);

	return result;
}

#if 0

/* Read error-register */

static LONG ide_error(void)
{
	return *IDEER;
}

ideerror IDEError(void)
{
	return (WORD) ide_error();
}

#endif
