/*
*
* Programm zur Manipulation des Bit 3 im Programmheader.
* MagiC benîtigt dieses Bit, das i.a. Null ist, dafÅr, um
* dem Programm nur den minimal notwendigen Speicher zuzuweisen,
* d.h. nur Basepage+Text+Daten+Symbol+Bss.
* Wird insbesondere fÅr alle SharedLibraries benîtigt.
*
* Andreas Kromke
* 25.10.97
*
*/

#include <portab.h>
#include <tos.h>
#include <toserror.h>
#include <stdio.h>

/* ProgramHeader, Programmkopf fÅr ausfÅhrbare Dateien                  */
/************************************************************************/

typedef struct {
 WORD ph_branch;     /* 0x00: must be 0x601a */
 LONG ph_tlen;       /* 0x02: length of TEXT - segment */
 LONG ph_dlen;       /* 0x06: length of DATA - segment */
 LONG ph_blen;       /* 0x0a: length of BSS  - segment */
 LONG ph_slen;       /* 0x0e: length of Symboltabelle */
 LONG ph_res1;       /* 0x12: von PureC benîtigt */
 LONG ph_flags;      /* 0x16: Bit 0: Fastload: don't clear heap */
                        /*    Bit 1: load to FastRAM */
                        /*    Bit 2: Malloc from FastRAM */
                        /*    Bit 3: only t+d+b+s (MagiC 5.20) */
                        /*    Bit 4,5,6,7: memory protection (MiNT) */
                        /*    Bit 8: unused */
                        /*    Bit 9: unused */
                        /*    Bit 10: unused */
                        /*    Bit 11: unused */
                        /*    Bit 12: SharedText (MiNT) */
                        /*    Bit 13: unused */
                        /*    Bit 14: unused */
                        /*    Bit 15: unused */
                        /*    Bits 31..28: TPA-Size */
                        /*     (mal 128k + 128k: Mindestgr. Heap */
 WORD ph_reloflag;      /* 0x1a: ungleich Null => nicht relozieren */
} PH;



WORD main( WORD argc, char *argv[] )
{
	PH ph;
	WORD ret = 0;
	LONG err;
	WORD f;

	for	(argc--,argv++; argc; argc--,argv++)
		{
		Cconws("Datei: ");
		Cconws(*argv);
		err = Fopen(*argv, O_RDWR);	/* zum Lesen+Schreiben îffnen */
		f = (WORD) err;	/* Datei-Handle */
		err = Fread(f, sizeof(PH), &ph);
		if	((err != sizeof(PH)) || (ph.ph_branch != 0x601a))
			{
			err = EPLFMT;
			goto nextone;
			}
		Fseek(0L, f, 0);		/* Dateizeiger an den Anfang */
		ph.ph_flags |= 8;		/* Bit 3 setzen */
		err = Fwrite(f, sizeof(PH), &ph);

	 nextone:
		if	(f > 0)
			Fclose(f);
		if	(err < 0)
			{
			printf(" => Fehler %ld", err);
			ret = (WORD) err;
			}
		Cconws("\r\n");
		}
	return(ret);
}
