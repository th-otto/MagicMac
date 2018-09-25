/*******************************************************************
*
*                          DIS1			20.3.87
*                          ====
*
*         letzte Modifikation:			
*									01.07.90
*									07.06.92
*
* Pass 1  des GEMDOS- Disassemblers.
*
* Kommando- Argumente:
*        zu disassemblierende Programmdatei, z.B. "filename.prg"
*        oder Objektdatei im GEMDOS- Format, z.B. "filename.o"
*		(im zweiten Fall muû die Extension ".o" sein!
*        Optional das Argument "-mhex1-hex2", falls ein Speicherbereich
*         anstelle der Datei disassembliert werden soll.
*
* Erstellt:           Relocation- Tabelle "filename.rlo"
*                     Label- Tabelle      "filename.lbl"
*    wenn vorhanden:  Symbol-Tabelle      "filename.sym"
* 
*  rlo- Datei beginnt mit 5 Langworten:
*     l_text, l_data, l_bss, l_sym, l_stk (fÅr Turbo-C)
*  Die rlo- Datei wird nicht erstellt, wenn entweder die Programmdatei nicht
*   ausfÅhrbar ist oder der Speicher disassembliert werden soll.
*  Im Fall "Objektdatei" enthÑlt die rlo- Datei nur die oben genannten
*   5 Langworte.
*
*  lbl- Datei enthÑlt zunÑchst ein Langwort mit der TabellenlÑnge.
*  (Anzahl der Tabellen- EintrÑge).
*
*  Wertet Optionen m (Speicher disassemblieren) 
*   und n (bei ".o" keine 0007 testen) aus.
*
*******************************************************************/

#include <tos.h>
#include <stdlib.h>
#include <string.h>
#include <tosdefs.h>
#include <magix.h>
#include <stddef.h>

#define FALSE             (0)
#define TRUE              (1)
#define EOS               '\0'
#define CRLF              "\15\12"

struct symbol {
  char symname[8];
  int  symtype;
  long symvalue;
  };
#define SLEN ( (long) sizeof(struct symbol) ) 



int  prg_file,rlo_file,lbl_file;
long *tab;                    /* Relocation- und Label- Tabelle */
long tab_max;                 /* TabellenlÑnge */
struct symbol *symboltab;	/* Symboltabelle */
int	sym_max;				/* TabellenlÑnge */
int  *datei;
long adr;                     /* gerade zu disassemblierende Adresse */
int  isexe;                   /* Programm ist ausfÅhrbar */
int  isobj;				/* Objektdatei */
int	is0007;				/* Opcode- Flag auswerten */
int  iserror;
int  ismem;                   /* Flag, falls Speicher disassemblieren */
int	is30;				/* Flag, falls 68030- Opcodes erwÅnscht	*/
long m_beg,m_end;             /* Bereich bei Option m */
long text_len;				/* LÑnge des Textsegments */
long data_len;				/* LÑnge des Datensegments */
long bss_len;				/* LÑnge des BSS- Segments */
long sym_len;				/* LÑnge der Symboltabelle */
long stk_len;				/* LÑnge des Stacks (Turbo-C) */
long relo_pos;				/* Dateipos. der Relocation- Daten */
long sym_pos;				/* Dateipos. der Symboltabelle */

void cerrws(char *string);
int  fws(int file, char *string);
void makepath(char *outpath, char *inpath, char *name);
void makeext(char *name, char *ext);
void makenam(char *inpath, char *name);
int  xscan(char *string, long *z1, long *z2);
int 	lies_header( void );
int 	symtab_write(long symtablen, char *name);
int 	label_init( void );
int  reloc_init( void );
char *long_to_hex(long wert);
void printtype(int file, int i);
int 	add_tab(long lbl);
extern void decode(void);
extern void shelsort(void *base, size_t count, size_t size, int (*compar)());


void main (argc, argv)
int   argc;
char *argv[];
{
     register long retcode, flength;
     register char *argname;
     DTA  dta;
     char path[130];
     long puffer[5];



     fws(HDL_CON,"GEMDOS\277 Disassembler (Phase 1), \275 1987-92 Andreas Kromke\r\n");
     isexe = is0007 = TRUE;
     isobj = is30 = FALSE;

     /* PrÅfen, ob genug Argumente Åbergeben wurden */
     /* ------------------------------------------- */
     if   (argc < 2) {
          usage:
          cerrws("\r\nUsage: dis1 ... [-mhex1-hex2] [-n] ... filename.ext\r\n\r\n");
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
			  "          -3   68030 Opcodes");
          goto newline;
          }

     /* PrÅfen, ob die Option m gewÅnscht wurde */
     /* PrÅfen, ob die Option n gewÅnscht wurde */
     /* PrÅfen, ob die Option 3 gewÅnscht wurde */
     /* --------------------------------------- */

     ismem = FALSE;
     argname = argv[--argc];
     for  (argc-- ;argc > 0; argc--)
          if   (argv[argc][0] == '-')
          	{
          	if	(((argv[argc][1] == 'm') || (argv[argc][1] == 'M')))
          		{
               	if   (xscan(argv[argc]+2, &m_beg, &m_end))
                    	goto usage;
               	m_beg &= (~1L);      /* gerade Anfangs- Adresse */
               	m_end &= (~1L);      /* gerade End-     Adresse */
               	if   (m_beg > m_end)
                    	goto usage;
               	ismem = TRUE;
               	isexe = FALSE;
               	}
               else if	( (strchr(argv[argc], 'n')) ||
               		  (strchr(argv[argc], 'N'))  )
          			is0007 = FALSE;
               else if	( (strchr(argv[argc], '3')) )
          			is30 = TRUE;
		}

     /* PrÅfen, ob die zu disassemblierende Datei existiert */
     /* --------------------------------------------------- */

     if   (!ismem) {
          Fsetdta(&dta);
          if   (0L > (retcode = Fsfirst(argname, 0))) {
               cerrws("No match for ");
               cerrws(argname);
               newline: cerrws(CRLF);
               Pterm(1);
               }
          flength =  dta.d_length;     /* DateilÑnge ermitteln */
          makepath(path, argname, dta.d_fname);   /* Pfad und Name zusammensetzen */
          if   (0L > (retcode = Fopen(path, RMODE_RD))) {        /* Datei îffnen */
               cerrws("Cannot open ");
               cerrws(path);
               goto newline;
               }
          prg_file = (int) retcode;


          /* Wenn Datei ausfÅhrbar, ProgrammlÑnge aus Segmentangaben holen */
          /* Sonst DateilÑnge verwenden */

          if   (lies_header())
          	{
               fws(HDL_CON,dta.d_fname);                   /* GEMDOS- Header prÅfen */
               fws(HDL_CON," is not a program file\r\n");
               isexe = FALSE;
               data_len = bss_len = sym_len = 0L;
               text_len = flength;
               }
		else {
			/* PrÅfen, ob es sich um eine GEMDOS- Objektdatei handelt */
			isobj = (strlen(path) > 1 &&
				   path[strlen(path) - 2] == '.' &&
				   path[strlen(path) - 1] == 'O');
			}
		} /* ENDIF !ismem */

     else {
          data_len = bss_len = sym_len = 0L;
          text_len = flength = m_end-m_beg;
          strcpy(path,argname);
          /* Dateiname aus dem Argument isolieren */
          makenam(path,dta.d_fname);
          }

     /* Speicher fÅr Tabellen holen */
     /* --------------------------- */

     if   (ismem)
          datei = (int *) m_beg;
     else {
     	if   (0L == (datei = (int *)  Malloc(text_len+data_len+100L)))
     		{
               memerr: cerrws("Not enough Memory");
               goto err;
               }
		if	(isobj)
			if	(NULL == (symboltab = (struct symbol *) Malloc(sym_len)))
				goto memerr;
			else sym_max = (int) (sym_len / SLEN);
		}

     retcode = (long) Malloc(-1L);
     tab_max = (retcode >> 2);      /* statt "/4" */
     if   (tab_max > (flength-text_len-data_len-sym_len)) {
          tab     = (long *) Malloc(retcode);
          if   (tab == (long *) 0L)
               goto memerr;
          }
     else goto memerr;
     tab[0] = 0L;			/* Tabelle ist leer! */

     /* Text- und Datensegment der Datei einlesen */
     /* ----------------------------------------- */

     if   (!ismem &&
           (text_len+data_len != Fread(prg_file, text_len+data_len, datei)))
          {
		read_err: cerrws("Read error");
          goto err;
          }

     /* Falls Objektdatei, Symboltabelle einlesen */
     /* ----------------------------------------- */

	if	(!ismem && isobj &&
		 sym_len != Fread(prg_file, sym_len, symboltab))
		goto read_err;

     makeext(dta.d_fname,".sym");
     symtab_write(sym_len,dta.d_fname);          /* Symboldatei schreiben */

     makeext(dta.d_fname,".lbl");                 /* Workfiles erîffnen */
     if   (0L > (retcode  = Fcreate(dta.d_fname, 0))) {
          err1: cerrws("Cannot create workfiles");
          err:  if  (!ismem) Fclose(prg_file);
          goto newline;
          }
     lbl_file = (int) retcode;

     if   (isexe) {
          makeext(dta.d_fname,".rlo");
          if   (0L > (retcode  = Fcreate(dta.d_fname, 0)))
          	{
               Fclose(lbl_file);
               goto err1;
               }
          rlo_file = (int) retcode;

          puffer[0] = text_len;            /* SegmentlÑngen auf rlo- Datei */
          puffer[1] = data_len;            /* ...schreiben */
          puffer[2] = bss_len;
          puffer[3] = sym_len;
          puffer[4] = stk_len;
          if   (0L > Fwrite(rlo_file, 20L, puffer)) {
               cerrws("Write error");
               goto err2;
               }
                                            /* Relocation- Daten schreiben */
                                            /* und -Tabelle initialisieren */
          if   (reloc_init())
          	{
               cerrws("Cannot read Relocation Data");
               err2: Fclose(lbl_file);
               Fclose(rlo_file);
               goto err;
               }
          }
                                             /* Label- Tabelle erstellen */
     if   (label_init())					/* und abspeichern */
     	{
     	Fclose(lbl_file);
          cerrws("Illegal Labels");
          goto newline;
          }

     if   (!ismem)
          Fclose(prg_file);

     Fclose(lbl_file);
     Pterm0();
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

     for (i = (int) strlen(inpath) - 1; i >= 0; i--)
         if ( (inpath[i] == ':') || (inpath[i] == '\\') )
            break;

     for (j = 0; j <= i; j++)
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

     for (i = (int) strlen(inpath) - 1; i >= 0; i--)
         if ( (inpath[i] == ':') || (inpath[i] == '\\') )
            break;
     strncpy(name,inpath+i+1,12);
}


/**************************************************************
*
* Liest zwei irgendwie getrennte Hexzahlen in z1 und z2 ein
*
**************************************************************/

int xscan(string, z1, z2)
register char *string;
long *z1, *z2;
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
        *z2 = 2147483647L;
     return( (string[i] == EOS) ? FALSE : TRUE);
}


/**************************************************************
*
* Rechnet Langwort in 8stellige Hex- Zahl um und gibt die
* Anfangsadresse des Strings zurÅck.
*
**************************************************************/

char *long_to_hex(wert)
long wert;
{
     register int  i,j;
     static   char string[10];

     string[8] = string[9] = EOS;
     for (i = 0; i < 8; i++) {
         j      = (int) (wert & 15);     /* 4 Bit fÅr Hex- Ziffer isolieren */
         wert >>= 4;
         string[7-i] =  (j < 10) ? ('0'+(char) j) : ('a'+(char) (j-10));
         }
     return(string);    
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
     char *s;

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
* Liest den GEMDOS- Header der Eingabedatei und die Grîûen der
* Programm- Segmente.
* RÅckgabe TRUE, wenn Fehler.
*
**************************************************************/

int lies_header( void )
{
     PH pgmkopf;

     if   ((sizeof(PH) == (Fread(prg_file, sizeof(PH),&pgmkopf))) &&
           (pgmkopf.ph_branch == 0x601a)) {
          text_len = pgmkopf.ph_tlen;
          data_len = pgmkopf.ph_dlen;
          bss_len  = pgmkopf.ph_blen;
          sym_len  = pgmkopf.ph_slen;
          stk_len  = pgmkopf.ph_res1;
          if   (pgmkopf.ph_flag)
               fws(HDL_CON,"NOT RELOCATABLE\r\n");
          if	(pgmkopf.ph_res1)
          	{
          	fws(HDL_CON,"Turbo C Stack Segment: ");
          	fws(HDL_CON,long_to_hex(pgmkopf.ph_res1));
          	fws(HDL_CON,"\r\n");
          	}
		relo_pos = text_len+data_len+sym_len+sizeof(PH);
		sym_pos  = relo_pos - sym_len;
          return(FALSE);
          }
     else {
          Fseek(0L,prg_file,0);         /* Dateipointer zurÅckstellen */
          relo_pos = -1L;
          return(TRUE);
          }
}


/**************************************************************
*
* Liest und dekodiert die Relocation- Informationen aus der
* Eingabedatei und weist sie der tabelle long reloc_tab[] zu.
* Die Tabelle wird mit 0L abgeschlossen und in die Datei
* "filename.rlo" geschrieben, die dann geschlossen wird.
*
**************************************************************/

int reloc_init( void )
{
	int prgrelo( void );
	long fpos;


	if	(!isobj)
		{
		if	(0L > Fseek(relo_pos, prg_file, 0))
			return(TRUE);
		if	(prgrelo())
			return(TRUE);
     	fpos = Fwrite(rlo_file, tab[0]*4L, tab+1);  /* bis auf 1. Element */
	     Fclose(rlo_file);                      	    /* auf Datei schreiben */
	     if   (fpos < 0L)
			return(TRUE);
		}
	else Fclose(rlo_file);
	return(FALSE);
}


int prgrelo( void )
{
	register long i;
	unsigned char puffer[5];
	register long offset;


	i = 1L;                   /* ein Langwort freilassen */
	if	(4L == Fread(prg_file, 4L, puffer))
		{
		if	(0L != (offset = ( (long *) puffer)[0]))
			{
			tab[i++] = offset;
			do	{
              		if	(1L != Fread(prg_file, 1L, puffer))
					puffer[0] = '\0';
				else {
					switch(puffer[0]) {
						case '\0':  break;
						case '\1':  offset += 254L;break;
						default:    offset += puffer[0];
								  tab[i++] = offset;
						}
					}
				}
			while(puffer[0] != '\0');
			}
		}
	tab[0] = i - 1;
	return(FALSE);
}


/*
int objrelo( void )
{
	register 	long 	i;
			int 		puffer;
	register 	long 	offset;


     i = 1L;
     offset = 0L;
     while(offset < text_len + data_len)
     	{
		if	(2L != Fread(prg_file, 4L, &puffer))
			return(TRUE);
		if	(i > tab_max)
			return(TRUE);
		if	(puffer == 0x0005)
			{
			tab[i++] = offset;
			if	(2L != Fread(prg_file, 4L, &puffer))
				return(TRUE);
			offset += 2;
			}
		offset += 2;
		}
	tab[0] = i;
     tab[i++] = 0L;
	return(FALSE);
}
*/

/**************************************************************
*
* Schreibt einen String <string> auf die Datei mit dem handle
* <file>. 
* Es wird genau dann TRUE zurÅckgegeben, wenn ein Fehler
* aufgetreten ist.
*
**************************************************************/

int fws(file, string)
int  file;
char string[];
{
      return( (0L > Fwrite(file,(long) strlen(string),string)) ? TRUE : FALSE);
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


	Fwrite( (_BasPag->p_stdfh[STDERR]) ? STDERR : HDL_CON,
		  strlen(string), string);
}


/**************************************************************
*
* Liest und dekodiert die Symboltabelle aus der Eingabedatei,
* auf die der Filepointer bereits zeigt.
* Falls die Symboltabelle existiert, wird sie unter dem Namen
* <name> abgespeichert (als ASCII- Datei).
* Es wird genau dann TRUE zurÅckgegeben, wenn ein Fehler
* aufgetreten ist.
*
**************************************************************/

void printtype(int file, int i)
{
	char	ausgabe[100];

	ausgabe[0] = EOS;
	if	(i & 0x8800)	/* definiert UND undefiniert */
		i &= ~0x8000;
     if	(i & 0x0100)	strcat(ausgabe, "bss  ");
     if	(i & 0x0200)	strcat(ausgabe, "text ");
     if	(i & 0x0400)	strcat(ausgabe, "data ");
     if	(i & 0x0800)	strcat(ausgabe, "XREF ");
     if	(i & 0x1000)	strcat(ausgabe, "equreg ");
     if	(i & 0x2000)	strcat(ausgabe, "global ");
     if	(i & 0x4000)	strcat(ausgabe, "equated ");
     if	(i & 0x8000)	strcat(ausgabe, "defined ");
     if	(i == 0)		strcat(ausgabe, "Weiû der Geier");
	/* rechtsbÅndige Leerstellen entfernen */
	while(ausgabe[0] != EOS &&
		 ausgabe[strlen(ausgabe) - 1] == ' ')
		ausgabe[strlen(ausgabe) - 1] = EOS;
	strcat(ausgabe, CRLF);
     fws(file, ausgabe);
}


int symtab_write(long symtablen, char *name)
{
	long          retcode;
	register int  sym_file, typ;
	struct symbol symboleintrag;
	register int  i;


	/* Existiert Åberhaupt eine Symboltabelle ? */
	if	(symtablen <= 0L)
		return(FALSE);

	/* richtige Position in der Datei ansteuern */
	if	(sym_pos != Fseek(sym_pos, prg_file, 0))
		return(TRUE);

	/* Symboltabellendatei erstellen */
	if   (0L > (retcode  = Fcreate(name, 0)))
		return(TRUE);
	sym_file = (int) retcode;

	/* Titelzeile erzeugen */
	fws(sym_file,"* Name:        Wert:        Typ:\r\n\r\n");

	/* alle Symbole schreiben */
	for	(retcode = 0L; retcode < symtablen; retcode += SLEN)
		{
		if	(SLEN != Fread(prg_file, SLEN, &symboleintrag))
			{
			Fclose(sym_file);
			return(TRUE);
			}
		fws (sym_file, "* ");
		typ = symboleintrag.symtype;
		symboleintrag.symtype = 0; /* symname mit '\0' abschlieûen */
		for (i = 0; i < 8; i++)    /* auf 8 Stellen erweitern */
			if	(symboleintrag.symname[i] == EOS)
		 		symboleintrag.symname[i]  =  ' ';

		fws (sym_file, symboleintrag.symname);
		if	(typ & 0x0800)		/* XDEF */
			fws (sym_file, "              ");
		else	{
			fws (sym_file, "  =  $");
			fws (sym_file, long_to_hex(symboleintrag.symvalue));
			}
		fws (sym_file, "    ");
		printtype(sym_file, typ);
		} /* END FOR */

	Fclose(sym_file);
	return(FALSE);
}


/**************************************************************
*
* Versucht, mîglichst alle Adressen des Programms ausfindig zu
* machen, auf die irgendwo im Programm Bezug genommen wird.
* Dazu werden zunÑchst alle relokatiblen Adressen betrachtet
* (aus Relocation- Tabelle in tab[]), dann alle relativ mit
* "bsr", "bra", "bcc", "dbcc" oder "offset(PC)" adressierten
* Labels im Text- Segment gesucht.
* Anschlieûend wird die Tabelle sortiert und abgespeichert.
* (jedes Label als Langwort seines Adressenwerts).
* Die maximale TabellenlÑnge long tab_max ist global.
* Es wird genau dann TRUE zurÅckgegeben, wenn ein Fehler
* aufgetreten ist.
*
**************************************************************/

int vergl(long *lbl1, long *lbl2)
{
	if	(*lbl1 == *lbl2)
		return(0);
	if	(*lbl1 > *lbl2)
		return(1);
	return(-1);
}


void ordne(void)
{
     register long i,j,k;


     shelsort(tab+1, tab[0], sizeof(long), vergl);
     for (i = 1L; i < tab[0]; i++) {
         for (j = i+1L; (j <= tab[0]) && (tab[i] == tab[j]); j++)
             ;
         if (j > i+1L) {
            for (k = j; k <= tab[0]; k++)
                tab[i+1L+k-j] = tab[k];
            tab[0] -= j-i-1L;
            }
         }

}


int label_init( void )
{
	void label_prg( void );
	void label_obj( void );


	iserror = FALSE;
	if	(isobj)
		label_obj();
	else	label_prg();
	Fwrite(lbl_file, 4L*(1L + tab[0]), tab);   /* Tabelle abspeichern  */
     return(iserror);                           /* ..mit erstem Element */
}


void label_prg( void )
{
     register long i;


	for	(i = 1L; i <= tab[0]; i++)
		{ 					/* tab[0] enthÑlt akt. TabellenlÑnge */
         	if	( (tab[i] & 1L) ||                   /* ungerade Adresse */
                (tab[i] > text_len+data_len) ||    /* out of ... */
                (tab[i] < 0L) ) {                  /* ... range  */
			iserror = TRUE;
			tab[i]  = 0L;
			}
		else tab[i]  = ( (long *) (datei+(tab[i] >> 1)) )[0];
		}

                                 /* Tabelle ordnen, doppelte Elemente... */
     ordne();                    /* ...entfernen und LÑnge setzen */

     adr = 0L;
     while (adr < text_len)
           decode();             /* Befehl dekodieren und ggf. Label... */
                                 /* ...in Tabelle einfÅgen */
}


void label_obj( void )
{
     register	long i;
			int 		puffer;
	register 	long 	offset;


	tab[0] = 0L;

	/* Labels aus Relocation- Tabelle holen */
	/* ------------------------------------ */

	if	(0L > Fseek(relo_pos, prg_file,0))
		{
		err:
		iserror = TRUE;
		return;
		}

     i = 1L;                   /* ein Langwort freilassen */
     offset = 0L;
     while(offset < text_len + data_len)
     	{
		if	(2L != Fread(prg_file, 2L, &puffer))
			goto err;
		if	(i > tab_max)
			goto err;
		if	(puffer == 0x0005)
			{
			if	(2L != Fread(prg_file, 2L, &puffer))
				goto err;
			tab[i] = 0L;
			switch(puffer)
				{
				case 3:	tab[i]   += data_len;	/* in BSS  */
				case 1:	tab[i]   += text_len;	/* in DATA */
				case 2:	tab[i++] += *( (long *) (datei+(offset >> 1)) );
						break;
				}
			offset += 2;
			}
		offset += 2;
		}
     tab[0] = i - 1L;			/* aktuelle TabellenlÑnge setzen */
							/* Tabelle ordnen, doppelte Elemente... */
	ordne();					/* ...entfernen und LÑnge setzen */

	/* Labels aus Symbol- Tabelle holen */
	/* -------------------------------- */

	for	(i = 0; i < sym_max; i++)
		{
		puffer = (symboltab[i]).symtype;
		if	((0 == (puffer & 0x0800)) && (puffer & 0x0700))
			{
			adr = (symboltab[i]).symvalue;
			if	(puffer & 0x0500)
				{
				adr += text_len;
				if	(puffer & 0x0100)
					adr += data_len;
				}
			add_tab(adr);
			}
		}

	/* Labels aus dem Programm direkt holen */
	/* ------------------------------------ */

	adr = 0L;
	while(adr < text_len)
		{
		if	(is0007)
			{
			if	(relo_pos + adr != Fseek(relo_pos + adr, prg_file,0))
				goto err;
			if	(2L != Fread(prg_file, 2L, &puffer))
				goto err;
			if	(puffer == 0x0007)
				decode();	/* Labelreferenzen suchen */
			else	adr += 2;
			}
		else	decode();
		}
}


/***********************************
*
* FÅgt ein Label zur Tabelle zu.
*  RÅckgabe: TRUE     Tabelle voll
*     sonst  FALSE
*
***********************************/

int add_tab(long lbl)
{
     register long links,rechts,mitte;
              long pos;


     links  = 1L;
     rechts = tab[0];

     while(TRUE) {
          if   (links > rechts) {
               pos = links;
               if (tab[0] >= tab_max)   /* bei pos einfÅgen */
                  return(TRUE);         /* öberlauf */
               for (links = tab[0]+1L; links > pos; links--)
                   tab[links] = tab[links - 1L];
               tab[links] = lbl;
               (tab[0])++;              /* Tabelle ist lÑnger geworden */
               return(FALSE);
               }
          mitte = (rechts + links) >> 1L;
          if   (tab[mitte] == lbl) {
               pos = mitte;
               return(FALSE);            /* gefunden */
               }
          else if   (tab[mitte] < lbl)
                    links  = mitte + 1L;
               else rechts = mitte - 1L;
         }
}
