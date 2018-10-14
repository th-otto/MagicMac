/*******************************************************************
*
*                          DIS2           27.3.87
*                          ====
*
* letzte Modifikation:				06.06.92
*
* Pass 2  des GEMDOS- Disassemblers.
*
* Kommando- Argumente:        1) Flags. z.B.   -tscad
*                                 e: keine EXE- Datei
*                                 t: Ausgabe auf stdout
*                                 d: Datei als DATA- Segment betrachten
*                                 c: jew. Code fÅr Befehle angeben
*                                 a: jew. Adressen angeben
*                                 z: ASCII angeben
*                                 i: Tmp- Dateien RLO und LBL lîschen
*						    n: bei ".o" keine 0007 testen
*						    m: MAS-68K (bra.b und ; Kommentar)
*						    g: Bei abs.Adr. Grîûe angeben
*						    3: 68030 Code
*                             2) -oh: h ist Origin (bei nicht- exe)
*                             3) -mhex1-hex2 fÅr Speicher disassemblieren
*                             4) Zu disassemblierender Bereich:
*                                xxxxx-xxxxx  (Hex- Zahlen)
*                             5) Zu disassemblierende Programmdatei
*                                mit Extension. Z.B.      "filename.prg"
*
* Liest (von Pass 1)  Relocation- Tabelle "filename.rlo"
*                     Label- Tabelle      "filename.lbl"
*
* erstellt            Source- Code        "filename.s"
* 
*  rlo- Datei beginnt mit 5 Langworten:
*		l_text, l_data, l_bss, l_sym, l_stk (optional fÅr Turbo)
*
*  lbl- Datei enthÑlt zunÑchst ein Langwort mit der TabellenlÑnge.
*  (Anzahl der Tabellen- EintrÑge).
*
*******************************************************************/


#include <tos.h>
#include <toserror.h>
#include <string.h>
#include <stdlib.h>
#include <stddef.h>
#include <ctype.h>
#include <magix.h>
#include <ph.h>

#undef HDL_CON
#define HDL_CON 1
#define STDERR -1

#define FALSE             (0)
#define TRUE              (1)
#define EOS               '\0'
#define CRLF              "\15\12"
#define STDOUT             1
#define MAXLONG           2147483647L

struct symbol {
  char symname[8];
  int  symtype;
  long symvalue;
  };
#define SLEN ( (long) sizeof(struct symbol) ) 

int  prg_file, s_file;
long *rlo_tab;                /* Relocation- Tabelle */
int	rlo_max;				/* TabellenlÑnge */
unsigned *rlo_obj;			/* bei Objektdatei: alle Reloc.daten	*/
long *lbl_tab;                /* Label- Tabelle, lbl_tab[0] ist LÑnge */
struct symbol *symboltab;	/* Symboltabelle */
int  sym_max;				/* TabellenlÑnge */
int  iserror;
int  isobj   = FALSE;		/* Objektdatei */
int  notexe  = FALSE;         /* Flag, ob Datei ausfÅhrbar            */
int  isstd   = FALSE;         /* Flag, ob Ausgabe auf 'stdout'        */
int  isdata  = FALSE;         /* Datei nur als DATA behandeln         */
int  iscode  = FALSE;         /* Maschinencode in hex mit angeben     */
int  isadr   = FALSE;         /* Adresse fÅr jeden Befehl angeben     */
int  isasc   = FALSE;         /* ASCII- Code mit angeben ?            */
int  ismem   = FALSE;         /* Speicher disassemblieren             */
int  killtmp = FALSE;         /* .LBL, .RLO lîschen, wenn TRUE        */
int  no0007  = FALSE;		/* per Default 0007 bei ".o" testen	*/
int	ismas   = FALSE;		/* per Default "bra.s" und '*' Kommentar*/
int	issize  = FALSE;		/* per Default kein .w/.l			*/
int	is30	   = FALSE;		/* kein 68030-Code					*/
long m_beg,m_end;             /* zu disass.Speicherbereich            */
long range_from = 0L;
long range_to   = MAXLONG;    /* Zu disassemblierender Bereich        */
long origin     = 0L;         /* Abs. Anf.adr. bei nicht-exe-Datei    */
long text_len, data_len, bss_len, sym_len, stk_len;
long relo_pos;				/* Dateipos. der Relocation- Daten */
long sym_pos;				/* Dateipos. der Symboltabelle */

void cerrws(char *string);
void outws (char *string);
int  check_args(int argc, char *argv[]);
void makenam(char *inpath, char *name);
void makepath(char *outpath, char *inpath, char *name);
void makeext(char *name, char *ext);
int  load_lbl(char *name);
int  load_rlo(char *name, DTA *dtabuf);
int  load_sym( void );


void main (int argc, char *argv[])
{
	extern	void	dis(char *dateiname);
	register	long	retcode;
			DTA	dtabuf;
			char	path[130], name[20], quelle[20];
	register	char	*argname;


	Fwrite(HDL_CON, 58L, "GEMDOS\277 Disassembler (Phase 2), \275 1987-92 Andreas Kromke\r\n");

	if   (argc < 2)                        /* Kommandozeile prÅfen */
		{
		cerrws("\r\nUsage: dis2 [from[-to]] {-etdcazinus3} [-oOrigin] [-mfrom-to] filename.ext\r\n\r\n");
		cerrws("          -e   Not executable\r\n"
			  "          -t   Write output to STDOUT\r\n"
			  "          -d   Treat as DATA\r\n"
			  "          -c   Include code information\r\n"
			  "          -a   Include address information\r\n"
			  "          -z   Include ascii information\r\n"
			  "          -i   Delete temporary files\r\n"
			  "          -n   Don't use opcode- information (in '.o')\r\n"
			  "          -u   Create input for MAS-68K\r\n"
			  "          -s   Include .w/.l for absolute addressing mode\r\n"
			  "          -3   Generate 68030 Code");
		goto newline;
		}
	if   (check_args(argc, argv))          /* Flags und Bereich aus...     */
		{
		cerrws("Syntax error(s) in arguments"); /* ...Kmdzeile holen */
		goto newline;
		}

	argname = argv[argc-1];                /* Dateiname = letzter Param. */
	if   (!ismem) {
		Fsetdta(&dtabuf);
		if   (0L > (retcode = Fsfirst(argname, 0)))
			{
			cerrws("No match for ");     /* Dateiname in Dir. suchen */
			cerrws(argname);
			newline: cerrws(CRLF);
			Pterm(1);
			}
		}
	else makenam(argname, dtabuf.d_fname);


	makepath(path, argname, dtabuf.d_fname);  /* Pfad und Name zusammensetzen */
	if   (!ismem) {
		if   (0L > (retcode = Fopen(path, 0))) {        /* Datei îffnen */
			cerrws("Cannot open ");
			cerrws(path);
			goto newline;
			}
		prg_file = (int) retcode;
		isobj = (strlen(path) > 1 &&
			    path[strlen(path) - 2] == '.' &&
			    path[strlen(path) - 1] == 'O');
		}

	strcpy(name,dtabuf.d_fname);
	strcpy(quelle,name);
	makeext(name,".lbl");                        /* Label- Tabelle einlesen */
	if   ( (load_lbl(name))  && !notexe)
		{
		err1: cerrws("Cannot open workfile(s)");
		err:  Fclose(prg_file);
		goto newline;
		}

	makeext(name,".rlo");
	if   (load_rlo(name, &dtabuf)  && !notexe)
		goto err1;

	if	(load_sym() && !notexe)
		goto err;

	if   (!isstd)
		{
		makeext(name,".s");
		if   (0L > (retcode = Fcreate(name,0)))
		     goto err1;
		s_file = (int) retcode;
		}
	else s_file = STDOUT;

	if   (isdata)
		{
		data_len += text_len;
		text_len  = 0L;
		}

	dis(quelle);               		/* Disassembliere    */
	if   (!ismem) Fclose(prg_file);
	outws(NULL);					/* Schreibpuffer leermachen */
	if	(!isstd)
		Fclose(s_file);
	Pterm0();
}


/**************************************************************
*
* Gibt einen <string> nach stderr aus, d.h. nach Handle 4,
* falls vorhanden. Sonst nach Handle -1.
*
**************************************************************/

void cerrws(char *string)
{
	extern BASPAG *_BasPag;


	Fwrite( STDERR,
		  strlen(string), string);
}


/**************************************************************
*
* Schreibt einen String <string> auf die Quelltext- Datei mit
* dem handle <s_file> und lîscht den ausgabe[] - Puffer.
* Tritt ein Schreibfehler auf, wird das Programm ABGEBROCHEN.
*
**************************************************************/

#define BSIZE 10240			/* 10 kB Ausgabepuffer */

static void _out(char *buf, long len)
{
	if	(len > 0L && len != Fwrite(s_file, len, buf))   /* nicht alles geschrieben */
		{
		if	(len >= 0L)
			{
			cerrws("Disk full\r\n");
			len = -1L;
			}
		else	cerrws("Write error\r\n");
	 	Pterm((int) len);                    /* abbrechen */
	 	}
	return;
}

void outws(char *string)
{
	static 	char	buf[BSIZE];
	static	long	bufp = 0L;
	register	long len;
	extern	char ausgabe[];


	if	(string == NULL)		/* flush buffer */
		len = 0L;
	else len = strlen(string);
	if	(isstd)				/* STDOUT nicht puffern */
		{
		_out(string, len);
		ausgabe[0] = EOS;
		return;
		}
	if	(len > BSIZE)
		return;
	if	(!string || len + bufp > BSIZE)		/* Puffer voll */
		{
		_out(buf, bufp);
		bufp = 0L;
		}
	if	(string)
		{
		strcpy(buf + bufp, string);
		bufp += len;
		ausgabe[0] = EOS;
		}
	return;
}


/**************************************************************
*
* Isoliert aus <inpath> den Pfadnamen und kopiert ihn vor
* den Dateinamen <name> nach <outpath>.
*
**************************************************************/

void makepath(outpath, inpath, name)
char outpath[],inpath[],name[];
{
	register int i,j;

	for	(i = (int) strlen(inpath) - 1; i >= 0; i--)
		if	( (inpath[i] == ':') || (inpath[i] == '\\') )
			break;

	for	(j = 0; j <= i; j++)
		outpath[j] = inpath[j];

	strcpy(outpath + j, name);
}


/**************************************************************
*
* Isoliert aus <inpath> den Dateinamen und kopiert ihn nach
* nach <name>.
*
**************************************************************/

void makenam(inpath, name)
char inpath[],name[];
{
	register int i;

	for	(i = (int) strlen(inpath) - 1; i >= 0; i--)
		if	( (inpath[i] == ':') || (inpath[i] == '\\') )
			break;
	strncpy(name,inpath+i+1,12);
}


/**************************************************************
*
* Tauscht im Dateinamen <name> die Extension durch <ext> aus.
* Hat <name> noch keine Extension, wird sie angehÑngt.
* <ext> muû mit Punkt angegeben werden!
*
**************************************************************/

void makeext(name,ext)
char name[],ext[];
{
	register char *s;

	/* name hinter das letzte '\' setzen */
	s = strrchr(name, '\\');
	if	(s != NULL)
		name = s + 1;
	/* s auf die Extension oder hinter den String */
	s = strchr(name, '.');
	if	(s == NULL)
		s = name + strlen(name);
     strcpy(s, ext);
}


/**************************************************************
*
* Liest die Argumente der Kommandozeile und initialisiert
* Bereich und Flags.
* Es wird genau dann TRUE zurÅckgegeben, wenn ein Fehler
* aufgetreten ist.
*
**************************************************************/

int strsrch(char string[], char c)
{
	register int i;

	for	(i = 0; string[i] != EOS; i++)
		{
		if	(toupper(string[i]) == c)
			return(TRUE);
		}
	return(FALSE);
}

/* Liest zwei irgendwie getrennte Hexzahlen in z1 und z2 ein */
int xscan(char *string, long *z1, long *z2)
{
	register int i;

	*z1 = *z2 = 0L;
	i = 0;
	while ( ( (string[i] >= '0') && (string[i] <= '9') ) ||
	        ( (string[i] >= 'a') && (string[i] <= 'f') ) ||
	        ( (string[i] >= 'A') && (string[i] <= 'F') ) ) {
	      if  ( (string[i] -= '0') > '\11')
	          if  ( (string[i] -= 'A'-'0'-'\12') > '\17')
	              string[i] -= 'a'-'A';
	      *z1 <<= 4;
	      *z1 += (long) string[i];
	      i++;
	      }
	if    (string[i] != EOS) {
	      i++;
	      while ( ( (string[i] >= '0') && (string[i] <= '9') ) ||
	              ( (string[i] >= 'a') && (string[i] <= 'f') ) ||
	              ( (string[i] >= 'A') && (string[i] <= 'F') ) ) {
	            if  ( (string[i] -= '0') > '\11')
	                if  ( (string[i] -= 'A'-'0'-'\12') > '\17')
	                    string[i] -= 'a'-'A';
	            *z2 <<= 4;
	            *z2 += (long) string[i];
	            i++;
	            }
	      }
	if (*z2 == 0L)
	   *z2 = MAXLONG;
	return( (string[i] == EOS) ? FALSE : TRUE);
}


int check_args(argc, argv)
int   argc;
char *argv[];
{
	long dummy;

	for	(argc -= 2; argc > 0; argc--) {  /* Parameter 1..argc-2 testen */
	     if   (argv[argc][0] == '-') {
	          if   (toupper(argv[argc][1]) == 'O') {
	               if   (xscan(argv[argc]+2, &origin, &dummy))
	                    return(TRUE);
	               }
	          else {
	               if   (toupper(argv[argc][1]) == 'M') {
	                    if   (xscan(argv[argc]+2, &m_beg, &m_end))
	                         return(TRUE);
	                    m_beg &= (~1L);      /* gerade Anfangs- Adresse */
	                    m_end &= (~1L);      /* gerade End-     Adresse */
	                    if   (m_beg > m_end)
	                         return(TRUE);
	                    ismem = notexe = TRUE;
	                    }
	               else {
					notexe  |=  strsrch(argv[argc],'E');
					isstd   |=  strsrch(argv[argc],'T');
					isdata  |=  strsrch(argv[argc],'D');
					iscode  |=  strsrch(argv[argc],'C');
					isadr   |=  strsrch(argv[argc],'A');
					isasc   |=  strsrch(argv[argc],'Z');
					killtmp |=  strsrch(argv[argc],'I');
					no0007  |=  strsrch(argv[argc],'N');
					ismas   |=  strsrch(argv[argc],'U');
					issize  |=  strsrch(argv[argc],'S');
					is30    |=  strsrch(argv[argc],'3');
					}
	               }     
	          }
	     else if   (xscan(argv[argc], &range_from, &range_to))
	               return(TRUE);
	     }
	
	range_from &= (~1L);      /* gerade Anfangs- Adresse */
	return(FALSE);
}


/**************************************************************
*
* Liest die Label- Tabelle ein.
* RÅckgabe FALSE : ok
*              1 : Datei nicht vorhanden
*              2 : Datei lÑût sich nicht lesen
*              3 : Zuwenig Speicher vorhanden
*
**************************************************************/

int load_lbl(char *name)
{
              long tabsize, retcode;
     register int  handle, errcode;


     if   (0L > (retcode = Fopen(name, 0))) {
          errcode = 1;         /* Datei nicht vorhanden */
          error:
          lbl_tab = (long *) Malloc(8L);
          lbl_tab[0] = 0L;
          return(errcode);
          }
     handle = (int) retcode;

     if   (4L != Fread(handle, 4L, &tabsize)) {  /* TabellenlÑnge einlesen */
          errcode = 2;   /* Lesefehler */
          Fclose(handle);
          goto error;
          }

     lbl_tab = (long *) Malloc(100L + 4L * tabsize);
     if   (lbl_tab == (long *) 0L) {
          Fclose(handle);
          return(3);  /* Zuwenig Speicher */
          }
                                         /* Tabelle einlesen */
     if   ((4L*tabsize) != Fread(handle, 4L*tabsize, lbl_tab+1)) {
          lbl_tab[0] = 0L;
          Fclose(handle);
          return(2);    /* Lesefehler */
          }

     Fclose(handle);
     lbl_tab[0] = tabsize;
     if   (killtmp)
          Fdelete(name);                /* Labeldatei lîschen */
     return(FALSE);
}


/**************************************************************
*
* Liest die Relocation- Tabelle ein.
* RÅckgabe FALSE : ok
*              1 : Datei nicht vorhanden
*              2 : Datei lÑût sich nicht îffnen oder lesen
*              3 : Zuwenig Speicher vorhanden
*
**************************************************************/

int load_rlo(char *name, DTA *dtabuf)
{
              long retcode;
     register int  handle, errcode;


	rlo_max = 0;
     if   (notexe || (0L < Fsfirst(name,0))) {
          errcode = 1;         /* Datei nicht vorhanden */
          error:
          rlo_tab = (long *) Malloc(8L);
          error2:
          text_len = (ismem) ? (m_end-m_beg) : MAXLONG;
          data_len = bss_len = sym_len = 0L;
          return(errcode);
          }

     if   (0L > (retcode = Fopen(name, 0))) {
          errcode = 2;         /* Datei kann nicht geîffnet werden */
          goto error;
          }
     handle = (int) retcode;

     rlo_tab = (long *) Malloc(100L + (*dtabuf).d_length);
     if   (rlo_tab == NULL) {
          Fclose(handle);
          return(3);  /* Zuwenig Speicher */
          }

     if   ((*dtabuf).d_length != Fread(handle, (*dtabuf).d_length, rlo_tab)) {
          errcode = 2;    /* Lesefehler */
          Fclose(handle);
          goto error2;
          }

     Fclose(handle);
     text_len = *rlo_tab++;
     data_len = *rlo_tab++;
     bss_len  = *rlo_tab++;
     sym_len  = *rlo_tab++;
     stk_len  = *rlo_tab++;
	relo_pos = text_len+data_len+sym_len+sizeof(PH);
	sym_pos  = relo_pos - sym_len;
     rlo_max  = (int) ((*dtabuf).d_length/sizeof(long) - 5);
	if	(isobj)
		{
		rlo_obj = (unsigned *) Malloc(text_len+data_len);
		if	(rlo_obj == NULL)
			return(3);
		if	(relo_pos != Fseek(relo_pos, prg_file, 0))
			return(2);
		if	(text_len + data_len !=
			 Fread(prg_file,text_len+data_len, rlo_obj))
			return(3);
		}
     if   (killtmp)
          Fdelete(name);                /* Relocationdatei lîschen */
     return(FALSE);
}


/**************************************************************
*
* Liest die Symbol- Tabelle ein.
* RÅckgabe FALSE : ok
*              1 : Datei nicht vorhanden
*              2 : Datei lÑût sich nicht îffnen oder lesen
*              3 : Zuwenig Speicher vorhanden
*
**************************************************************/

int load_sym( void )
{
	if	(!notexe)
		{
		if	(sym_pos != Fseek(sym_pos, prg_file, 0))
			return(2);
		if	(NULL == (symboltab = (struct symbol *) Malloc(sym_len)))
			return(3);
		if	(sym_len != Fread(prg_file, sym_len, symboltab))
			return(3);
		sym_max = (int) (sym_len / SLEN);
		if	(0L != Fseek(0L, prg_file, 0))
			return(2);
		}
	else sym_max = 0;
	return(FALSE);
}