/*******************************************************************
*
*                          EXE2BIN           29.12.87
*                          =======
*
*					  letzte énderung:	31.12.89
*
*
* Zweck:  Programmdateien, die "position independent" sind,
*         in eine Art COM - Format umzuwandeln
*		FÅr TOS 1.4 wird auûerdem das Fastload- Bit gesetzt
*
* Syntax: EXE2BIN prg1|pfad1 prg2|pfad2 ...
*
*******************************************************************/


#include <tos.h>
#include <kaos.h>
#include <stddef.h>
#include <string.h>
#include <tosdefs.h>
#include <structs.h>


#define FALSE             0
#define TRUE              1
#define EOS               '\0'

char *errmsg;
int	errcode;
int	lies_header(long *reloc_offs);
void screen(char *string);
char *get_name(char *path);
int	is_reloc(int handle);
int	exe2bin(char *program);


void main (int argc, char *argv[])
{
	DTA	dta;
	char	path[128];
	char	pgm[128];
	char	*ext,*end,*p;
	int	i,err;
	long	ret;


	if   (argc < 2)
		{
		screen("Syntax: EXE2BIN prg1|pfad1 prg2|pfad2 ...\r\n");
		Pterm(1);
		}
	Fsetdta(&dta);
     for  (argc--,argv++ ;argc > 0; argc--,argv++)
     	{
     	strcpy(path, *argv);
     	strupr(path);
     	p = get_name(path);
     	if	(*p == EOS)
     		{
     		*p++ = '*';
     		*p++ = EOS;
     		}
     	else if	(p[0] == '.' && ((p[1] == EOS) ||
     						  (p[1] == '.' && p[2] == EOS)
     						 )
     			)
     		strcat(p, "\\*");
     		
     	p = get_name(path);
     	ext = strrchr(path, '.');
     	if	(ext < p)
     		ext = NULL;		/* Extensions nur im Namen */
     	if	(ext == NULL)
     		{
     		i = 1;
     		end = path + strlen(path);
     		}
     	else i = 0;
		for	(; i >= 0; i--)
			{
			if	(ext == NULL)
				strcpy(end, (i) ? ".PRG" : ".TOS");
			ret = Fsfirst(path, 0x00);
			while(ret == E_OK)
				{
				strcpy(pgm, path);
				p = get_name(pgm);
				if	(*p)
					{
					strcpy(p, dta.d_fname);
					Cconws("EXE2BIN  ");
					Cconws(pgm);
					Cconws("\r\n");
					err = exe2bin(pgm);
					if	(err < 0)
						Pterm(err);
					}
				ret = Fsnext();
				}
			if	(ret != EFILNF && ret != ENMFIL)
				Pterm((int) ret);
			}     		
     	}
	Pterm0();
}


/**************************************************************
*
* Wandelt eine Datei <pgm> um
*
**************************************************************/

int exe2bin(char *program)
{
	int  prg_file;
	long err;
     long reloc_offs;
     PH	header;


     /* Datei îffnen          */
     /* --------------------- */

	err = Fopen(program, RMODE_RW);
	if	(err == EACCDN)
		{
		screen(" ==> Zugriff verweigert!\r\n");
		return(2);
		}

     if   (0 > (prg_file = (int) err))
     	return(prg_file);

     /* Dateiheader einlesen und DateilÑnge setzen */
     /* ------------------------------------------ */

	err = Fread(prg_file, sizeof(PH), &header);
	if	(err < 0L)
		return((int) err);
	if	(err != sizeof(PH) || header.ph_branch != 0x601a)
		return((int) EPLFMT);
	reloc_offs = sizeof(PH)  + header.ph_tlen
						+ header.ph_dlen
						+ header.ph_slen;
	if	(header.ph_flag && (header.ph_res2 & 1))
		{
		Fclose(prg_file);
		return(1);
		}

     /* Dateipointer auf die Relocation- Daten setzen */
     /* --------------------------------------------- */

     if   (reloc_offs != Fseek(reloc_offs, prg_file, 0))
     	return(-1);

     /* Programmheader modifizieren */
     /* --------------------------- */

	if	(!is_reloc(prg_file) && !header.ph_flag)
		{
		if   (offsetof(PH, ph_flag) != Fseek(offsetof(PH, ph_flag), prg_file, 0))
		     return(-1);
		if   (2L != Fwrite(prg_file, 2L, "\xff\xff"))
			return(-1);
	     if   (reloc_offs == Fseek(reloc_offs, prg_file, 0))
     	     Fshrink(prg_file);
		screen(" Relokationsdaten entfernt\r\n");
          }

	if	(!(header.ph_res2 & 1))
		{
	     DOSTIME  timedate;

		if   (offsetof(PH, ph_res2) != Fseek(offsetof(PH, ph_res2), prg_file, 0))
		     return(-1);
		header.ph_res2 |= 1;
		if	(Fdatime(&timedate, prg_file, RMODE_RD))
			return(-1);
		if   (4L != Fwrite(prg_file, 4L, &header.ph_res2))
			return(-1);
		if	(Fdatime(&timedate, prg_file, RMODE_WR))
			return(-1);
		screen(" Fastload- Flag gesetzt\r\n");
          }

     Fclose(prg_file);
     return(0);
}


/**************************************************************
*
* Liest die Relocation- Informationen aus der Eingabedatei
* RÅckgabe TRUE <=> Datei ist nicht "position independent".
*
**************************************************************/

int is_reloc( int handle )
{
     long  retcode;
     long  puffer[2];


     retcode = Fread(handle, 4L, puffer);
     if   (retcode < 0L)
     	Pterm((int) retcode);
     if   ((retcode == 4L) && (puffer[0] != 0L))
          return(TRUE);
     return(FALSE);
}


/*********************************************************************
*
*  Schreibt <string> auf den Bildschirm
*
*********************************************************************/

void screen(char *string)
{
     Fwrite(HDL_CON,(long) strlen(string), string);
}


/*********************************************************************
*
* Ermittelt zu einem vollen Pfadnamen den Zeiger auf den
* reinen Dateinamen
*
*********************************************************************/

char *get_name(char *path)
{
	register char *n;

	n = strrchr(path, '\\');
	if	(!n)
		{
		if	((*path) && (path[1] == ':'))
			path += 2;
		return(path);
		}
	return(n + 1);
}
