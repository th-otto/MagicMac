/*******************************************************************
*
*                Hauptteil von dis2
*                ==================
*
* Disassembliert eine Datei mit handle prg_file auf eine Text- Datei
*  mit Hilfe der Prozedur outws(char *string).
*
* externals:
*    int  notexe:                      Datei ist nicht ausfÅhrbar
*    long text_len,data_len,bss_len:   SegmentlÑngen
*    long range_from,range_to:         Zu disassemblierender Bereich
*    long rlo_tab[], lbl_tab[]:        Relocation- und Labeltabellen
*
*******************************************************************/


#include <tos.h>
#include <string.h>
#include <limits.h>


#define FALSE             (0)
#define TRUE              (1)
#define MAXLONG           2147483647L
#define EOS               '\0'
#define CRLF              "\r\n"
#define MIN(a,b)          ((a < b) ?  a : b)
#define ABS(a)            ((a < 0) ? -a : a)
#define STDERR            -1         /* 'CON:' */

#define COD_POS           1          /* Linker Rand vor Opcode- Feld   */
#define OPR_POS          10          /* Position des Operanden- Felds  */
#define CMT_POS          30          /* Anfangsposition des Kommentars */
#define DCMT_POS         40          /* dito im DATA- Segment */


struct header {
  int  type;
  long textlen;
  long datalen;
  long bsslen;
  long symlen;
  long res1;
  long res2;
  int  res3;
};
#define HEADER_LEN ( (long) sizeof(struct header) )

struct symbol {
  char symname[8];
  int  symtype;
  long symvalue;
  };
#define SLEN ( (long) sizeof(struct symbol) ) 


/* Externals aus "dis2.c" */

extern int  prg_file;
extern long *rlo_tab;              /* Relocation- Tabelle */
extern int  rlo_max;			/* TabellenlÑnge */
extern long *lbl_tab;              /* Label- Tabelle, lbl_tab[0] ist LÑnge */
extern unsigned *rlo_obj;		/* bei Objektdatei: alle Reloc.daten	*/
extern struct symbol *symboltab;	/* Symboltabelle */
extern int  sym_max;			/* TabellenlÑnge */
extern int  isobj;				/* Flag, ob .o - Datei */
extern int  notexe;                /* Flag, ob Datei ausfÅhrbar */
extern int  iscode;                /* Flag fÅr Code mit angeben */
extern int  isadr;                 /* Flag fÅr Adresse mit angeben */
extern int  isasc;                 /* Flag fÅr ASCII mit angeben */
extern int  ismem;                 /* Flag fÅr Speicher disassemblieren */
extern int  no0007;				/* Flag: 0007 nicht testen bei ".o" */
extern int  ismas;
extern long range_from, range_to;  /* Zu disassemblierender Bereich */
extern long text_len, data_len, bss_len, stk_len;
extern long origin;                /* Absolute Adresse der nichtexe-Datei */
extern long m_beg;				/* Beginn des zu disass. Speichers */
extern void cerrws(char *string);	/* Zeichenkette nach STDERR		*/
extern void outws(char *string);	/* Zeichenkette nach Quelltext */

/* Externals aus "disass.c" */

extern long befehlsadresse;
extern int  cindex, code[];
extern void comment(int tab_pos, int do_code, int do_asc);

/* Globals  */

static long memadr;				/* fÅr m-Option */
long adr;                          /* gerade zu disassemblierende Adresse */
char ausgabe[200];                 /* Ausgabe- String */
int  eof;                          /* Datei- Ende */
void writestr(char *string);
char *long_to_hex(long wert, int len, char c);
void writepos(int pos);
void write16(unsigned zahl);
void write8(int zahl);
int	reloc_search(long adresse, int is_kill);
int	label_search(long adresse, int is_kill);
void writelbl(long label);
void writesym(int i, long offs);
void write_all_lbls(long adr);
long next_label(long adresse);
long next_reloc(long adresse);
void write16s(int zahl);
void writechr(char c);
void write32(long zahl);
void write32s(long zahl);


/*******************************************************************
*
*   Initialisierung und Anfang. Dieses Unterprogramm wird von
*   dis2 aus aufgerufen.
*
*******************************************************************/

void dis(char *dateiname)
{
	register	long anzahl;
			void dis_text( void );
			void dis_data( void );
			void dis_bss ( void );
			void write_errors( void );
			void write_xdefs ( void );
			void write_equs  ( void );



	memadr = m_beg;
	eof = FALSE;
	if	(notexe || (range_from < text_len+data_len))
		{
		anzahl  = (notexe) ? 0L : HEADER_LEN;
		anzahl += range_from;
		if	(anzahl > 0L)
			if	(anzahl != Fseek(anzahl, prg_file, 0))
				{
				cerrws("Out of Range\r\n");  /* Dateiende bereits erreicht */
				return;
				}
		}
	adr = range_from;

	/* Titelmeldung und Segmentgrîûen angeben */
	/* -------------------------------------- */

	outws("* GEMDOSø Disassembler, Ω 22.12.88 Andreas Kromke\r\n\r\n* ");
	if	(ismem)
		outws("Speicherauszug");
	else {
		outws("Datei:  ");
		outws(dateiname);
		}
	outws("\r\n\r\n");
	if	(!notexe)
		{
		writestr("\r\n* TEXT :   $");
		writestr(long_to_hex(text_len,6,'a'));
		writestr("\r\n* DATA :   $");
		writestr(long_to_hex(data_len,6,'a'));
		writestr("\r\n* BSS  :   $");
		writestr(long_to_hex(bss_len ,6,'a'));
		if	(stk_len)
			{
			writestr("\r\n* STACK:   $");
			writestr(long_to_hex(stk_len,6,'a'));
			}
		writestr("\r\n\r\n");
		outws(ausgabe);
		if	(isobj)
			write_xdefs();
		if	(!notexe || isobj)
			write_equs();
		}
	if	(origin != 0L)
		{
		writestr(" ORG      $");
		writestr(long_to_hex(origin,6,'a'));
		writestr("\r\n\r\n");
		outws(ausgabe);
		}


	if	(text_len > 0L)
		{
		if	( (adr <= 0) && (adr < range_to) )
			outws("\r\n        TEXT\r\n\r\n");
		while( (!eof) && (adr < text_len) && (adr < range_to))
			{
			dis_text();
			if	(!ismem && (adr > text_len))
				{
				outws("\r\n* Last Instruction too long. Correcting File Pointer.\r\n");
				Fseek(HEADER_LEN + text_len, prg_file, 0);
				adr = text_len;   /* Pointer auf Beginn des Datensegments */
				}
			}
		}

	if	(data_len > 0L)
		{
		if	( (adr <= text_len) && (adr < range_to) )
			outws("\r\n        DATA\r\n\r\n");
		while( (!eof) && (adr <= range_to) && (adr < text_len + data_len) )
			dis_data();
		}

	if	(bss_len > 0L)
		{
		if	( (adr <= text_len + data_len) && (adr < range_to) )
			outws("\r\n        BSS\r\n\r\n");
		while((adr < range_to) && (adr < text_len + data_len + bss_len))
			dis_bss();
		}

	if	(adr >= text_len + data_len + bss_len)
		outws("\r\n        END\r\n");

	write_errors();   /* Nicht gefundene Labels, Relocation- Daten usw. */
}


/**************************************************************
*
* Holt ein Wort aus der Datei bzw. aus dem Speicher
* in das Feld code[]
*
**************************************************************/

void getcode(void)
{
	if (eof)
	  return;

	cindex++;
	if	(ismem)
		{
		code[cindex] = *((int *) memadr);
		memadr += 2;
		}
	else	eof = (2L != Fread(prg_file, 2L, code+cindex));
	adr += 2L;
}


/**************************************************************
*
* Disassembliert exakt einen Befehl aus Datei prg_file an
* Adresse adr.
* Der Assemblerbefehl wird in den String ausgabe[] und dann
* sofort in die Datei geschrieben.
*
**************************************************************/

void dis_text()
{
		  int  is_opcode;
	extern void disass(int is_opcode);


    	write_all_lbls(adr);
	writepos(COD_POS);
	if	(label_search(adr+1, FALSE))
		{
		int alt_iscode,alt_isasc,bytes;

		alt_iscode = iscode;
		alt_isasc  = isasc;
		iscode = FALSE;
		isasc  = TRUE;
		befehlsadresse = adr;
		cindex = -1;
		getcode();			/* Wort holen */
		cindex = -1;			/* Marke, daû es ein Byte ist */
		adr--;				/* FÅr Byte korrigieren */
		bytes = code[0];
		code[0] = (bytes >> 8);
		writestr("DC.B");
		writepos(OPR_POS);
		write8(code[0]);		/* Hi- Byte */
		comment(CMT_POS, FALSE, TRUE);
		writestr(CRLF);
		outws(ausgabe);
		write_all_lbls(adr);
		writepos(COD_POS);
		code[0] = (int) ((char) bytes);
		writestr("DC.B");
		writepos(OPR_POS);
		write8(code[0]);		/* Lo- Byte */
		comment(CMT_POS, FALSE, TRUE);
		adr++;					/* ganzes Wort abgearbeitet */
		iscode = alt_iscode;
		isasc  = alt_isasc;
		}
	else {
		if	(isobj)
			is_opcode = (no0007 || (rlo_obj[adr >> 1] == 0x0007));
		else is_opcode = TRUE;
		disass(is_opcode);
		if	((code[0] == 0x4e75) || (code[0] == 0x4e73)) /* RTS oder RTE */
		if	(is_opcode)
			writestr(CRLF);
		}
	writestr(CRLF);
	outws(ausgabe);
}


/**************************************************************
*
* Disassembliert einen Teil des DATA- Segments aus prg_file ab
* Adresse adr.
* Der Assemblerbefehl (DC.x ... ) wird erst in den String
* ausgabe[] und dann auf die Datei geschrieben.
* Maximal stehen 3 Langworte in einer Zeile.
*
**************************************************************/

void dis_data()
{
	extern void write_long(void);
              char byte;
     register long naechste;
     register int  i;


	write_all_lbls(adr);
	writepos(COD_POS);
	befehlsadresse = adr;
	cindex = -1;

	if   (adr & 1L)    /* Adresse ungerade */
		naechste = adr + 1L;
	else {
		if	(reloc_search(befehlsadresse, FALSE))
			{
			getcode();
			writestr("DC.L");
			writepos(OPR_POS);
			write_long();
			comment(DCMT_POS, FALSE, FALSE);
			writestr(CRLF);
			outws(ausgabe);
			return;
			}
		naechste = MIN (text_len+data_len,next_label(adr));
		naechste = MIN (naechste,next_reloc(adr));
		naechste = MIN (naechste,range_to);
	     }

	if   (naechste - adr > 3L)         /* Platz fÅr Langworte */
		{
		writestr("DC.L");
		writepos(OPR_POS);
		for	(i = 0; i < 3; i++)
			{
			if	(i > 0)
				writechr(',');
			getcode();             /* Hi- Word holen */
			if	(eof)
				break;
			write_long();         /* LoWord holen und alles drucken */
			if	(naechste - adr <= 3L)
				break;
			}
	     }
	else {
		if   (naechste - adr > 1L) {       /* Platz fÅr Wort */
			writestr("DC.W");
			writepos(OPR_POS);
			getcode();           /* Wort holen */
			write16s(code[0]);
			}
		else {                            /* Platz fÅr Bytes */
			writestr("DC.B");
			writepos(OPR_POS);
			if	(ismem)
				{
				byte = *((char *) memadr);
				memadr += 1;
				}
			else eof = (1L != Fread(prg_file, 1L, &byte)); /* Byte holen */
			code[0] = (int) byte;
			adr++;
			write8(byte);
			}
		}
          
	comment(DCMT_POS, iscode, TRUE);
	writestr(CRLF);
	outws(ausgabe);
}


/**************************************************************
*
* Disassembliert einen Teil des BSS- Segments mit Hilfe der
* Label- Tabelle an Adresse adr.
* Der Assemblerbefehl (DS.x ... ) wird erst in den String
* ausgabe[] und dann auf die Datei geschrieben.
*
**************************************************************/

void dis_bss()
{
	register long naechste;
	extern   long next_label();


	befehlsadresse = adr;
	write_all_lbls(adr);
	writepos(COD_POS);
	naechste = MIN (text_len+data_len+bss_len,next_label(adr));
	writestr("DS.B");
	writepos(OPR_POS);
	write32(naechste - adr);
	comment(DCMT_POS, FALSE, FALSE);
	writestr(CRLF);
	outws(ausgabe);
	adr = naechste;
}


/**************************************************************
*
* Schreibt externe Labels, die in anderen Modulen vom Linker
*  gesucht werden mÅssen.
* Wird nur bei Objektdateien aufgerufen.
*
**************************************************************/

void write_xdefs( void )
{
	register	int  i, gesamt, is, type;


	gesamt = is = 0;
	for	(i = 0; i < sym_max; i++)
		{
		type = symboltab[i].symtype;
		if	(type & 0x0800)				/* xref */
			{
			is = TRUE;
			outws((gesamt) ? "," : "\r\n        XREF  ");
			gesamt++;
			gesamt %= 6;
			writesym(i,0);
			outws(ausgabe);
			}
		}
	if	(is)
		outws("\r\n\r\n");

	gesamt = is = 0;
	for	(i = 0; i < sym_max; i++)
		{
		type = symboltab[i].symtype;
		if	(!(type & 0x0800) &&					/* !xref */
/*			  (type & 0x0700) &&		  text or data or bss */
			  (type & 0x2000)					    /* global */
			)
			{
			is = TRUE;
			outws((gesamt) ? "," : "\r\n        XDEF  ");
			gesamt++;
			gesamt %= 6;
			writesym(i,0);
			outws(ausgabe);
			}
		}
	outws((is) ? "\r\n\r\n\r\n": "\r\n");
}


/**************************************************************
*
* Schreibt alle konstanten Symbole (als "symbol EQU wert")
*
**************************************************************/

void write_equs( void )
{
	register	int  i, is, type;
	register	long val;
	extern	void write_dreg(int nummer);
	extern	void write_areg(int nummer);



	is = FALSE;
	for	(i = 0; i < sym_max; i++)
		{
		val  = symboltab[i].symvalue;
		type = symboltab[i].symtype;
		if	(type & 0x4000)
			{
			outws((is) ? "\r\n" : "\r\n\r\n");
			is = TRUE;
			writesym(i,0);
			writepos(10);
			if	((type & 0x1000) && 	/* equreg */
				 (val >= 0) && (val < 16))
				{
				writestr((ismas) ? "EQU  " : "EQUR ");
	          	if	(val < 8)
     	     		write_dreg((int) val);
          		else write_areg((int) (val - 8));
				}
			else {
				writestr("EQU  ");
				write32s(val);
				}
			outws(ausgabe);
			}
		}
	if	(is)
		outws("\r\n\r\n");
}


/**************************************************************
*
* Schreibt alle Labels und Relocation- Adressen, die beim
* Disassemblieren nicht berÅcksichtigt werden konnten,
* in die Ausgabe- Datei (als ASCII).
*
**************************************************************/

void write_errors( void )
{
	register int  i,is;
	register long adr;


	is = FALSE;
	if	(isobj)
		{
		for	(adr = range_from;
			 adr < range_to && adr < text_len+data_len; adr+=2)
			{
			if	(rlo_obj[adr     >> 1] == 0x0005 &&
				 rlo_obj[(adr+2) >> 1] != 0)
				{
				if	(!is)
					{
					outws("\r\n\r\n");
					is = TRUE;
					}
		     	writestr("* relocate ");
				write32(adr+origin);
				writestr(CRLF);
				outws(ausgabe);
				}
			else	{
				if	(6 == (rlo_obj[adr >> 1] & 7))
					{
					if	(!is)
						{
						outws("\r\n\r\n");
						is = TRUE;
						}
			     	writestr("* link word ");
					write32(adr+origin);
					writestr(CRLF);
					outws(ausgabe);
					}
				}
			}
		}
	else	{
		for	(i = 0; i < rlo_max; i++)
			if	( (rlo_tab[i] != -1L)  &&
		     	  (rlo_tab[i] >= range_from) &&
		     	  (rlo_tab[i] < range_to  ) )
		     	{
				if	(!is)
					{
					outws("\r\n\r\n");
					is = TRUE;
					}
		     	writestr("* relocate ");
				write32(rlo_tab[i]+origin);
				writestr(CRLF);
				outws(ausgabe);
				}
		}
	for	(i = 1; i <= lbl_tab[0]; i++)
		if	( (lbl_tab[i] != -1L) &&
			(((lbl_tab[i] >= range_from) && (lbl_tab[i] < range_to)) ||
			(lbl_tab[i] < 0L) ||
			(lbl_tab[i] > text_len+data_len+bss_len)
	          ) )
	          {
			if	(!is)
				{
				outws("\r\n\r\n");
				is = TRUE;
				}
			writestr("* set label ");
			write32(lbl_tab[i]+origin);
			writestr(CRLF);
			outws(ausgabe);
			}

	if	(!is)
		outws(CRLF);
}


/**************************************************************
*
* Rechnet Langwort in <len> - stellige Hex- Zahl um und gibt die
* Anfangsadresse des Strings zurÅck.
* c = 'A' Hex- Zahl aus Groûbuchstaben.
* c = 'a'               Kleinbuchstaben
*
**************************************************************/

char *long_to_hex(wert, len,c)
long wert;
int  len;
char c;
{
	register int  i,j;
	static   char string[10];


	string[len] = EOS;
	for	(i = 0; i < len; i++)
		{
		j      = (int) (wert & 15);     /* 4 Bit fÅr Hex- Ziffer isolieren */
		wert >>= 4;
		string[len-1-i] =  (j < 10) ? ('0'+(char) j) : (c+(char) (j-10));
		}
	return(string);    
}


/**************************************************************
*
* HÑngt einen String <string> an die Zeichenkette <ausgabe> an.
*
**************************************************************/

void writestr(char *string)
{
	strcat(ausgabe,string);
}


/**************************************************************
*
* HÑngt ein Zeichen <c> an die Zeichenkette <ausgabe> an.
*
**************************************************************/

void writechr(char c)
{
	register int len;


	len = (int) strlen(ausgabe);
	ausgabe[len] = c;
	ausgabe[len+1] = EOS;
}


/**************************************************************
*
* Setzt das String- Ende von ausgabe[] an Position <pos>.
*
**************************************************************/

void writepos(int pos)
{
	while(strlen(ausgabe) < pos)
		writechr(' ');
}


/**************************************************************
*
* HÑngt den Namen des Labels mit Wert long <label> an die
* Zeichenkette <ausgabe> an.
*
**************************************************************/

void writelbl(long label)
{
	register 	char *hexzahl;
	register	int  i,typ;
	register  long wert;


	for	(i = 0; i < sym_max; i++)
		{
		typ = (symboltab[i]).symtype;
		if	(0 == (typ &0x0800) && (typ & 0x0700))
			{
			wert = (symboltab[i]).symvalue;
			if	(typ & 1)
				wert += data_len;
			if	(typ & 5)
				wert += text_len;
			if	(wert == label)
				{
				writesym(i,0);
				return;
				}
			}
		}

	writestr("lbl");
	hexzahl = long_to_hex(label+origin, 8, 'A');
	while((*hexzahl == '0') && (*(hexzahl+1) != EOS))
		hexzahl++;          /* FÅhrende Nullen unterdrÅcken */
	writestr(hexzahl);
}


/**************************************************************
*
* Schreibt die Namen aller Labels, die bei Adresse <adr>
* liegen.
*
**************************************************************/

void write_all_lbls(long adr)
{
	register	int  i, geschrieben, typ;
	register  long wert;


	if	(!label_search(adr, TRUE))
		return;
	geschrieben = FALSE;
	for	(i = 0; i < sym_max; i++)
		{
		typ = (symboltab[i]).symtype;
		if	(0 == (typ &0x0800) && (typ & 0x0700))
			{
			wert = (symboltab[i]).symvalue;
			if	(typ & 0x0100)
				wert += data_len;
			if	(typ & 0x0500)
				wert += text_len;
			if	(wert == adr)
				{
				writesym(i,0);
				writestr(":\r\n");
				outws(ausgabe);
				geschrieben = TRUE;
				}
			}
		}
	if	(!geschrieben)
		{
		writelbl(adr);
		writestr(":\r\n");
		outws(ausgabe);
		}
}


/**************************************************************
*
* Schreibt den Namen des Symbols mit der Nummer <i> mit einem
*  Offset <offs>.
*
**************************************************************/

void writesym(int i, long offs)
{
	char	name[9];


	name[8] = EOS;
	strncpy(name, (symboltab[i]).symname, 8);
	writestr(name);
	if	(offs > 0)
		writechr('+');
	if	(offs)
		write32s(offs);
}


/**************************************************************
*
* HÑngt die hexadezimale Schreibweise des 32Bit- Wertes <zahl>
* an die Zeichenkette <ausgabe> an.
* Sind nur 8 Bit signifikant, wird die Zahl als vorzeichen-
* behaftet interpretiert.
*
**************************************************************/

void write32(long zahl)
{
	register char *hexzahl;


	if	(zahl != LONG_MIN && zahl == (long) ( (char) zahl))
		if	(zahl < 0L)
			{
			writechr('-');
			zahl = -zahl;
			}
	if	(zahl == LONG_MIN || ABS(zahl) > 9L)
		writechr('$');
	hexzahl = long_to_hex(zahl, 8, 'a');
	while((*hexzahl == '0') && (*(hexzahl+1) != EOS))
		hexzahl++;          /* FÅhrende Nullen unterdrÅcken */
	writestr(hexzahl);
}


/**************************************************************
*
* HÑngt die hexadezimale Schreibweise des 32Bit- Wertes <zahl>
* an die Zeichenkette <ausgabe> an.
* Die Zahl wird als vorzeichenbehaftet interpretiert.
*
**************************************************************/

void write32s(long zahl)
{
	if	(zahl != LONG_MIN && zahl < 0L)
		{
		writechr('-');
		zahl = -zahl;
		}
	write32(zahl);
}


/**************************************************************
*
* HÑngt die hexadezimale Schreibweise des 16Bit- Wertes <zahl>
* an die Zeichenkette <ausgabe> an.
*
**************************************************************/

void write16(unsigned zahl)
{
	register char *hexzahl;
	
	
	if	(zahl > 9)
		writechr('$');
	hexzahl = long_to_hex((long) zahl, 4, 'a');
	while((*hexzahl == '0') && (*(hexzahl+1) != EOS))
		hexzahl++;          /* FÅhrende Nullen unterdrÅcken */
	writestr(hexzahl);
}


/**************************************************************
*
* HÑngt die hexadezimale Schreibweise des 16Bit- Wertes <zahl>
* an die Zeichenkette <ausgabe> an.
* Im Gegensatz zu oben wird die Zahl als vorzeichenbehaftet
* interpretiert (z.B. bei Adressierung xxxx(An) ).
*
**************************************************************/

void write16s(int zahl)
{
	register char *hexzahl;


	if	(zahl != INT_MIN && zahl < 0)
		{
		writechr('-');
		zahl = -zahl;
		}

	if	(zahl == INT_MIN || zahl > 9)
		writechr('$');
	hexzahl = long_to_hex((long) zahl, 4, 'a');
	while((*hexzahl == '0') && (*(hexzahl+1) != EOS))
		hexzahl++;          /* FÅhrende Nullen unterdrÅcken */
	writestr(hexzahl);
}


/**************************************************************
*
* HÑngt die hexadezimale Schreibweise des 8Bit- Wertes <zahl>
* an die Zeichenkette <ausgabe> an.
*
**************************************************************/

void write8(int zahl)
{
	register char *hexzahl;


	zahl &= 0xff;
	if	(zahl > 9)
		writechr('$');
	hexzahl = long_to_hex((long) zahl, 2, 'a');
	while((*hexzahl == '0') && (*(hexzahl+1) != EOS))
		hexzahl++;          /* FÅhrende Nullen unterdrÅcken */
	writestr(hexzahl);
}


/***************************************************
* PrÅft, ob die <adresse> in der Reloc.-Tab. ist.
* Wenn ja,   wird TRUE  zurÅckgegeben, und der
* Eintrag in der Tabelle = -1 gesetzt, falls is_kill = TRUE;
* da <adresse> in aufsteigender Reihenfolge abgefragt
* wird, wird dann jew. beim letzten Eintrag weitergesucht.
***************************************************/

static long last_reloc = 0L;    /* zeigt auf nÑchste Relocation- Adresse */

int reloc_search(long adresse, int is_kill)
{
	register int i;


	if	(isobj)
		{
		if	(rlo_obj[adresse >> 1] == 0x0005)
			{
			if	(is_kill)
				{
				rlo_obj[adresse >> 1] = -1;
				last_reloc = adresse + 4L;
				}
			return(TRUE);
			}
		}
	else	{
		for	(i = (int) last_reloc;
			 (i < rlo_max) && (adresse >= rlo_tab[i]); i++)
			if	(adresse == rlo_tab[i])
				{
				if	(is_kill)
					{
					rlo_tab[i] = -1L;
					last_reloc = i + 1L;
					}
				return(TRUE);
				}
		}
	return(FALSE);
}


/***************************************************
* Sucht die nÑchste zu relozierende Adresse nach
* <adresse>.
* Wird keine gefunden, wird MAXLONG zurÅckgegeben.
***************************************************/

long next_reloc(long adresse)
{
	register long i;


	if	(isobj)
		{
		for	(i = last_reloc;
			 (i < text_len+data_len &&
			  adresse >= i && rlo_obj[i>>1] != 0x0005); i+=2)
			;
		return( (i < text_len+data_len) ? MAXLONG : i);
		}
	else	{
		for	(i = last_reloc;
			 (i < rlo_max) && (adresse >= rlo_tab[i]); i++)
			;
		return( (i >= rlo_max) ? MAXLONG : rlo_tab[i]);
		}
}


/***************************************************
* PrÅft, ob die <adresse> in der Label-Tab. ist.
* Wenn ja,   wird TRUE  zurÅckgegeben, und der
* Eintrag in der Tabelle = -1 gesetzt.
* Da <adresse> in aufsteigender Reihenfolge abgefragt
* wird, wird jew. beim letzten Eintrag weitergesucht.
***************************************************/

static   long last_lbl = 1L;   /* zeigt auf nÑchstes Label */

int label_search(long adresse, int is_kill)
{
	register long i;


	for	(i = last_lbl; (adresse >= lbl_tab[i]) && (i <= lbl_tab[0]); i++)
		if	(adresse == lbl_tab[i])
			{
			if	(is_kill)
				{
				lbl_tab[i] = -1L;
				last_lbl = i + 1L;
				}
			return(TRUE);
			}
	return(FALSE);
}


/***************************************************
* Sucht das nÑchste Label in der Liste.
* Wird keins gefunden, wird MAXLONG zurÅckgegeben.
***************************************************/

long next_label(long adresse)
{
	register long i;


	for	(i = last_lbl; (adresse >= lbl_tab[i]) && (i <= lbl_tab[0]); i++)
		;
	return( (i > lbl_tab[0]) ? MAXLONG : lbl_tab[i]);
}
