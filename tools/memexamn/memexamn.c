/*********************************************************************
*
*  MEMEXAMN			17.08.91
*  ========
*
*  letzte énderung		18.05.96 (shared blocks)
*
*  SchlÅsselt die Speicheraufteilung von Mag!X auf.
*  Untersucht wahlweise eine Post-mortem-dump Datei oder den
*  aktuellen Speicherinhalt.
*
* Projektdatei: TTP.PRJ
*
*********************************************************************/

#include <tos.h>
#include <magix.h>
#include <tosdefs.h>
#include <stdio.h>
#include <string.h>
#include <country.h>
#include <mint/sysvars.h>
#include <toserror.h>
#include <mgx_dos.h>

char *nat_str(char *s);

void p_read (void *buf, void *pos, long count);
long	meminfo (void);
void memstruct(void);
void own_name(long own, long mem, char **name, char **info);

int file;
long flen;
char *buf;
void *mem_root = NULL;
long ur_pd = 0L;
SYSHDR _sh;
AESVARS _av;
long  aes_bp;


int main(int argc, char *argv[])
{
	long errcode;
	char	*name = "x:\\_sys_.$$$";


	Cconws(nat_str(
		"\1\8\xff" "MagiC- Speicheruntersuchung, Ω 1991-96 Andreas Kromke\r\n\0"
		"\2\xff"   "MAGiC - VÇrification de mÇmoire, Ω 1991-96 Andreas Kromke\r\n\0"
		"\xff"     "MagiC- MEMEXAMN, Ω 1991-96 Andreas Kromke\r\n"
		));

	if	(NULL == (buf = Malloc(65536L)))
		return((int) ENSMEM);
	if	(argc < 2)
		*name = '\0';
	else	if	(argc == 2)
		*name = argv[1][0];
	else {
		Cconws("Syntax: MEMEXAMN [drv]\r\n");
		return(1);
		}

	if	(*name)
		{
		file = (int) Fopen(name, O_RDONLY);
		if	(file < 0)
			return(file);
		flen = Fseek(0L, file, SEEK_END);
		if	(flen < 0L)
			return((int) flen);
		}
	else file = 0;

	errcode = meminfo();
	Fclose(file);
	return((int) errcode);
}

long meminfo( void )
{
	char **roots;
	char *startadr;
	char	*name, *info;
	int	i,t;
	MCB	mcb;

	memstruct();
	roots = mem_root;
	if	(!roots)
		return((long) ERROR);

	printf(nat_str(
			"\1\8\xff" "Adresse des Speicherzeigers: %8lx\n\n\0"
			"\2\xff"   "Adresse du pointeur mÇmoire: %8lx\n\n\0"
			"\xff"	 "Address of memory pointer: %8lx\n\n"
		), roots);
	for	(t = 0; *roots; roots++,t++)
		{
		startadr = *roots;
		if	((long) startadr == 0xffffffffL )
			continue;
		i = 1;
		printf(nat_str(
			"\1\8\xff" "Tabelle %d\n\0"
			"\2\xff"   "Tableau %d\n\0"
			"\xff" 	 "Table %d\n\0"
			), t);
		printf("  Nr      Adr magic      len      own                     prev\n");
		printf("--------------------------------------------------------------\n");
		do	{
			p_read(&mcb, startadr, sizeof(MCB));
			own_name(mcb.mcb_owner & 0x7fffffffL,
				    ((long) startadr) + sizeof(MCB), &name, &info);

			printf("%4d %8lx  %4s %8lx %8lx%c %15s %8lx    %s\n",
				  i,startadr,&(mcb.mcb_magic),mcb.mcb_len,
				  mcb.mcb_owner & 0x7fffffffL,
				  (mcb,mcb.mcb_owner & 0x80000000L) ? 'p' : ' ',
				  name, mcb.mcb_prev, info);
			startadr += mcb.mcb_len + sizeof(MCB);
			i++;
			}
		while (mcb.mcb_magic == 'ANDR');
		}
	return(0L);
}

void memstruct(void)
{
	AESVARS *av;
	void *l;


	if	(file)
		{
		p_read(&mem_root, 0L, 4L);
		p_read(&ur_pd, (void *) 4L, 4L);
		}
	else	{
		DOSVARS *dv;

		dv = (DOSVARS *) Sconfig(SC_VARS, 0L);
		if	((long) dv <= 0L)
			{
			errm:
			Cconws(nat_str(
				"\1\8\xff" "Fehler: Kein MagiC\r\n\0"
				"\2\xff"   "Erreur: Pas de MagiC\r\n\0"
				"\xff"     "Error: No MagiC\r\n"
				));
			return;
			}
		if	(dv->memlist)
			goto errm;
		mem_root = dv->mem_root;
		ur_pd = (long) (dv->ur_pd);
		}

	p_read(&l, (void *) 0x4f2L, 4L);
	p_read(&_sh, l, sizeof(SYSHDR));

	av = (AESVARS *) _sh.os_magic;
	p_read(&_av, av, sizeof(AESVARS));
	p_read(&aes_bp, (void *) _av._basepage, 4L);
}

void p_read(void *buf, void *pos, long count)
{
	long err;

	if	(file && ((long) pos < flen))
		{
		err = Fseek((long) pos, file, 0);
		if	(err < 0L)
			Pterm((int) err);
		if	(err != (long) pos)
			Pterm(-1);
		err = Fread(file, count, buf);
		if	(err < 0L)
			Pterm((int) err);
		if	(err != count)
			Pterm(-1);
		}
	else	{				/* > flen: mem statt file */
		err = Super(0L);
		memcpy(buf, pos, count);
		Super((void *) err);
		}
}


/********************************************************************
*
* Bestimmt zu einem Speicherblock an Adresse <mem>, dessen Eigner den
* PD <own> hat, den Programmnamen <name> und den Typ des
* Speicherblocks <info>
*
********************************************************************/

void own_name(long own, long mem, char **name, char **info)
{
	static char nam[130];
	BASPAG bp;
	char	*s;


	*name = *info = "";				/* noch unbekannt */
	if	(!own)
		{
		*name = nat_str(
				"\1\8\xff" "frei\0"
				"\2\xff"   "libre\0"
				"\xff"     "free"
				);
		}

	else
	if	(own < 0x1000)
		{
		*name = "shared";
		*info = "";
		return;
		}

	if	(own == ur_pd)
		*name = "boot";

	if	(own == mem)				/* Speicherblock gehîrt sich */
		*info = "Basepage";

	if	(own == aes_bp)
		*name = "AES";

	p_read(&bp, (void *) own, sizeof(BASPAG));
	if	(!**name)
		{
		if	(bp.p_env == NULL && bp.p_parent == NULL && bp.p_tlen == 0L)
			{
/*
			printf("lowtpa: %ld\n", bp.p_lowtpa);
		     printf("hitpa:  %ld\n", bp.p_hitpa);
		     printf("tbase:  %ld\n", bp.p_tbase);
		     printf("tlen:   %ld\n", bp.p_tlen);
		     printf("dbase:  %ld\n", bp.p_dbase);
		     printf("dlen:   %ld\n", bp.p_dlen);
		     printf("bbase:  %ld\n", bp.p_bbase);
		     printf("blen:   %ld\n", bp.p_blen);
		     printf("dta:    %ld\n", bp.p_dta);
		     printf("parent: %ld\n", bp.p_parent);
		     printf("env:    %ld\n", bp.p_env);
			printf("cmd:       \n",  bp.p_cmdlin[0]);
*/
			*name = "aes";
			}
		}

	if	(file)
		{
		if	(bp.p_env)
			{
			p_read(buf, bp.p_env, 65534L);
			buf[65534L] = '\0';
			buf[65535L] = '\0';
			s = buf;
			}
		}
	else	{
		s = bp.p_env;
		}

	if	((long) bp.p_env == mem)
		*info = "Environment";

	if	(bp.p_env)
		{
		while(*s)
			{
			if	(!strncmp(s, "_PNAM=", 6))
				{
				strcpy(nam, s+6);
				*name = nam;
				}
			s += strlen(s) + 1;
			}
	}
}


/****************************************************************
*
* Ermittelt die NationalitÑt und wÑhlt Zeichenketten aus.
* Aufbau einer Zeichenkette:
*
* Nat1,Nat2,..,-1
*	string1
* Nat3,Nat4,..,-1
*	string2
* ...
* -1
*	Default-String
*
****************************************************************/

#define _SYSBASE	((long *)			0x4f2)

char *nat_str(char *s)
{
	static int nat = -1;
	char	c;

	if	(nat < 0)
		{
		long oldssp;
		SYSHDR *syshdr;

		/* NationalitÑt ermitteln */

		oldssp    = Super(0L);
		syshdr    = (SYSHDR *)  (* _SYSBASE);
		syshdr	= syshdr->os_base;	/* fÅr AUTO- Ordner */
		nat		= (syshdr->os_palmode) >> 1;
		Super((char *) oldssp);
		}

	while(*s != -1)
		{
		do	{
			c = *s++;
			if	(c == nat)		/* NationalitÑt gefunden */
				{
				while(*s != -1)	/* andere NationalitÑten */
					s++;			/*  Åberspringen */
				return(s+1);
				}
			}
		while(c != -1);
		while(*s)
			s++;
		s++;
		}
	return(s+1);		/* Default- String */
}
