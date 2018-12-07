/***************************************************************
*
*    Hauptteil des Disassemblers.
*     Disassembliert den Maschinencode in einen String.
*
*    letzte Modifikation: 29.4.90
*
***************************************************************/


#define FALSE             (0)
#define TRUE              (1)

#define COD_POS           1          /* Linker Rand vor Opcode- Feld   */
#define OPR_POS          10          /* Position des Operanden- Felds  */
#define CMT_POS          30          /* Anfangsposition des Kommentars */
#define DCMT_POS         40          /* dito im DATA- Segment */


#define FMT_BYTE  0
#define FMT_WORD  1
#define FMT_LONG  2

#define MOD_DDIR  0      /*  Datenregister   direkt     Dn        */
#define MOD_ADIR  1      /* Adressregister   direkt     An        */
#define MOD_AIND  2      /* Adressregister indirekt     (An)      */
#define MOD_POSI  3      /* Adr.ind. postincrement      (An)+     */
#define MOD_PRED  4      /* Adr.ind. predecrement      -(An)      */
#define MOD_OFFS  5      /* Adr.ind. mit Offset     xxxx(An)      */
#define MOD_INDX  6      /* Adr.ind. mit Index        xx(An,Rn.f) */
#define MOD_SPEC  7      /* zus„tzliche Adressierungsarten: */
#define REG_ABSH  0      /* absolute short              xxxx      */
#define REG_ABLO  1      /* absolute long               xxxxxxxx  */
#define REG_RELA  2      /* PC- relativ             xxxx(PC)      */
#define REG_RIDX  3      /* PC- relativ mit Index     xx(PC,Rn.f) */
#define REG_IMME  4      /* unmittelbar (immediate)    #xxxxxxxx  */

static char format_chr[] = "bwl";
static int  reg, mode, reg1, opmode, format, befehl, ill_opcode;
static int  isturbo = FALSE;		/* Flag: Turbo - C */
static long endcopyr;
static long mv_os_fnr_adr = 0L;	/* Adresse nach move.w #xx,-(sp)	*/
static int  os_fnr;				/* letzte m”gliche Funktionsnummer */
int    code[100];
int    cindex;
long   befehlsadresse;

extern long adr;				/* Adresse des NŽCHSTEN Codeworts */
extern long origin;
extern int  reloc_search(long adresse, int is_kill);
extern int  label_search(long adresse, int is_kill);
extern void writestr(char *string);
extern char *long_to_hex(long wert, int len, char c);
extern void writechr(char c);
extern void write8(int zahl);
extern void write16(unsigned zahl);
extern void write16s(int zahl);
extern void writepos(int pos);
extern void write32(long zahl);
extern void writelbl(long label);
extern void writesym(int i, long offs);
extern void getcode(void);
extern int  iscode, isasc, isadr, isobj, ismas, issize, is30;
extern int  ismem;
extern long m_beg,m_end;
extern unsigned *rlo_obj;	/* bei Objektdatei: alle Reloc.daten */
extern long text_len,data_len, stk_len;



/***************************************************
* Schreibt ein Langwort hexadezimal mit 8 Stellen.
* Falls es sich um ein verschiebbares Label handelt,
* wird "lblXXXXXX" ausgegeben.
***************************************************/

void write_long(void)
{
	long wert;
	int	i,w1,w2;


	getcode();
	wert = *( (long *) (code + cindex - 1) );
	if	(isobj)
		{
		i = (int) ((adr - 4L) >> 1);
		w1 = rlo_obj[i];
		w2 = rlo_obj[i+1];
		if	(w1 == 0x0005 && w2 != 0)
			{
			switch(w2)
				{
				case 3: wert += data_len;		/* in bss  */
				case 1: wert += text_len;		/* in data */
				case 2: writelbl (wert); break;	/* in text */
				default:						/* extern  */
						writesym((w2 - 4) / 8, wert);
						break;
				}
			rlo_obj[i] = -1;
			}
		else write32 (wert);
		}
	else	if	(reloc_search(adr-4L, TRUE))
			writelbl(wert);
		else write32 (wert);
}


/***************************************************
* Schreibt eine PC-relative Adresse (16 Bit) als Label.
***************************************************/

static void write_pcrel( void )
{
	long displ;
	int w;


	displ = adr - 2L + code[cindex];
	if	(!isobj)
		writelbl(displ);
	else {
		w = rlo_obj[(adr - 2L) >> 1];
		if	(6 == (w&7))		/* 16 Bit externe Referenz */
			{
			rlo_obj[(adr - 2L) >> 1] = -1;
			writesym((w - 6) / 8, code[cindex]);
			}
		else	writelbl(displ);
		}
}


/***************************************************
* Schreibt eine PC-relative Adresse (32 Bit) als Label (68030).
***************************************************/

static void write_pcrel_long( void )
{
	long displ;

	displ = adr - 4L + *( (long *) (code + cindex - 1) );
	writelbl(displ);
}


/***************************************************
* Schreibt eine PC-relative Adresse (8 Bit) als Label.
***************************************************/

static void write_pcrel_short( void )
{
	register long displ;


	displ = adr + ((long) ( (char) (code[cindex] & 255)));
	if	(cindex != 0)		/* kein short branch */
		displ -= 2L;
	writelbl(displ);
}


/***************************************************
* Schreibt (wenn jeweils durch Flags verlangt)
* alle gelesenen Code-Worte und Adressen heraus.
* Wenn cindex = -1 ist, wird angenommen, daž der
* Code aus einem Byte (auf code[0] erweitert) besteht.
***************************************************/

#define isprint(c)    ( (c >= 0x20) && (c != 0x7f) && (c != 0xff) )

void comment(int tab_pos, int do_code, int do_asc)
{
	register int  i;
	register unsigned char c;



	i = (befehlsadresse == mv_os_fnr_adr &&
		(befehl == 0x4e41 || befehl == 0x4e4d || befehl == 0x4e4e));

	if	(!i && !do_code && !isadr && !do_asc)
		return;

	writechr(' ');
	writepos(tab_pos);         /* Tabulator auf Kommentar- Anfang */
	writechr((ismas) ? ';' : '*');

	if	(i)
		{
		static char *gemdosnames[] = {
			"\x00" "Pterm0",			"\x01" "Cconin",
			"\x02" "Cconout",			"\x03" "Cauxin",
			"\x04" "Cauxout",			"\x05" "Cprnout",
			"\x06" "Crawio",			"\x07" "Crawcin",
			"\x08" "Cnecin",			"\x09" "Cconws",
			"\x0a" "Cconrs",			"\x0b" "Cconis",
			"\x0e" "Dsetdrv",			"\x10" "Cconos",
			"\x11" "Cprnos",			"\x12" "Cauxis",
			"\x13" "Cauxos",			"\x19" "Dgetdrv",
			"\x1a" "Fsetdta",			"\x20" "Super",
			"\x2a" "Tgetdate",			"\x2b" "Tsetdate",
			"\x2c" "Tgettime",			"\x2d" "Tsettime",
			"\x2f" "Fgetdta",			"\x30" "Sversion",
			"\x31" "Ptermres",			"\x36" "Dfree",
			"\x39" "Dcreate",			"\x3a" "Ddelete",
			"\x3b" "Dsetpath",			"\x3c" "Fcreate",
			"\x3d" "Fopen",			"\x3e" "Fclose",
			"\x3f" "Fread",			"\x40" "Fwrite",
			"\x41" "Fdelete",			"\x42" "Fseek",
			"\x43" "Fattrib",			"\x45" "Fdup",
			"\x46" "Fforce",			"\x47" "Dgetpath",
			"\x48" "Malloc",			"\x49" "Mfree",
			"\x4a" "Mshrink",			"\x4b" "Pexec",
			"\x4c" "Pterm",			"\x4e" "Fsfirst",
			"\x4f" "Fsnext",			"\x56" "Frename",
			"\x57" "Fdatime",
			"\xff"
			};
		static char *biosnames[] = {
			"\x00" "Getmpb",			"\x01" "Bconstat",
			"\x02" "Bconin",			"\x03" "Bconout",
			"\x04" "Rwabs",			"\x05" "Setexc",
			"\x06" "Tickcal",			"\x07" "Getbpb",
			"\x08" "Bcostat",			"\x09" "Mediach",
			"\x0a" "Drvmap",			"\x0b" "Kbshift",
			"\xff"
			};
		static char *xbiosnames[] = {
			"\x00" "Initmous",			"\x01" "Ssbrk",
			"\x02" "Physbase",			"\x03" "Logbase",
			"\x04" "Getrez",			"\x05" "Setscreen",
			"\x06" "Setpalette",		"\x07" "Setcolor",
			"\x08" "Floprd",			"\x09" "Flopwr",
			"\x0a" "Flopfmt",			"\x0c" "Midiws",
			"\x0d" "Mfpint",			"\x0e" "Iorec",
			"\x0f" "Rsconf",			"\x10" "Keytbl",
			"\x11" "Random",			"\x12" "Protobt",
			"\x13" "Flopver",			"\x14" "Scrdmp",
			"\x15" "Cursconf",			"\x16" "Settime",
			"\x17" "Gettime",			"\x18" "Bioskeys",
			"\x19" "Ikbdws",			"\x1a" "Jdisint",
			"\x1b" "Jenabint",			"\x1c" "Giaccess",
			"\x1d" "Offgibit",			"\x1e" "Ongibit",
			"\x1f" "Xbtimer",			"\x20" "Dosound",
			"\x21" "Setprt",			"\x22" "Kbdvbase",
			"\x23" "Kbrate",			"\x24" "Prtblk",
			"\x25" "Wvbl",				"\x26" "Supexec",
			"\x27" "Puntaes",			"\x40" "Blitmode",
			"\xff"
			};

		char *s;
		char **x;

		switch(befehl)
			{
			case 0x4e41: s = " gemdos ";x = gemdosnames;break;
			case 0x4e4d: s = " bios ";  x = biosnames;  break;
			case 0x4e4e: s = " xbios "; x = xbiosnames; break;
			}
		writestr(s);
		while(**x != '\xff' && **x < os_fnr)
			x++;
		if	(**x == os_fnr)
			writestr(*x + 1);
		else write16(os_fnr);
		if	(isadr || do_code || do_asc)
			writestr(" *");
		}

	if	(isadr)
		{
		writestr(long_to_hex((long) befehlsadresse+origin, 6, 'A'));
		if	(do_code || do_asc)
         		writechr('=');
		}

	if	(do_code)
		{
		if	(cindex == -1)
			writestr(long_to_hex( (long) (code[0] & 255), 2, 'a'));
		else	for (i = 0; i <= cindex; i++)
				writestr(long_to_hex((long) code[i], 4, 'a'));
		}

	if	(do_asc)
		{
		writechr('\'');
		if	(cindex == -1)
			{
			c = (unsigned char) (code[0] & 255);
			writechr( isprint(c) ? c : '.');
			}
		else	for (i = 0; i <= cindex; i++)
			{
			c = (unsigned char) (code[i] >> 8);    /* High- Byte */
			writechr( isprint(c) ? c : '.');
			c = (unsigned char) (code[i] & 255);   /* Low-  Byte */
			writechr( isprint(c) ? c : '.');
			}
		writechr('\'');
		}
}


/***************************************************
* šberprft die Zul„ssigkeit der
* Adressierungsarten fr alle Befehle.
* Rckgabe  TRUE fr Fehler.
***************************************************/

int adfehler(int tabelle)
{
      if ( (mode == MOD_SPEC)  && (reg > REG_IMME) )
         return(TRUE);
      if ( (mode == MOD_ADIR)  && (format == FMT_BYTE) )
         return(TRUE);

      switch (tabelle) {
                    /* Daten */
        case 1: return(mode == MOD_ADIR);
                    /* alle aužer unmittelbar */
        case 2: return ((mode == MOD_SPEC) && (reg == REG_IMME));
                    /* Daten ver„nderbar */
        case 3: return( (mode == MOD_ADIR) ||
                        ((mode == MOD_SPEC) && (reg > REG_ABLO)) );
                    /* Speicher ver„nderbar */
        case 4: return( (mode <  MOD_AIND) ||
                        ((mode == MOD_SPEC) && (reg > REG_ABLO)) );
                    /* ver„nderbar */
        case 5: return  ((mode == MOD_SPEC) && (reg > REG_ABLO));
                    /* Steuerung */
        case 6: return( ((mode <  MOD_OFFS) && (mode != MOD_AIND) ) ||
                        ((mode == MOD_SPEC) && (reg == REG_IMME)) );
                    /* Steuerung ver„nderbar oder -(An) */
        case 7: return( (mode < MOD_AIND) || (mode == MOD_POSI) ||
                        ((mode == MOD_SPEC) && (reg > REG_ABLO)) );
                    /* Steuerung oder (An)+ */
        case 8: return( (mode < MOD_AIND) || (mode == MOD_PRED) ||
                        ((mode == MOD_SPEC) && (reg == REG_IMME)) );
        default: return(FALSE);
        }
}


/***************************************************
* Dekodiert und schreibt die Operandengr”že.
***************************************************/

void write_format(void)
{
     writechr('.');
     writechr(format_chr[format]);
     writepos(OPR_POS);
}


/***************************************************
* Schreibt ein Datenregister
***************************************************/

void write_dreg(int nummer)
{
     writechr('d');
     writechr('0' + (char) nummer);
}


/***************************************************
* Schreibt ein Adressregister
***************************************************/

void write_areg(int nummer)
{
     if   (nummer == 7)
          writestr("sp");
     else {
          writechr('a');
          writechr('0' + (char) nummer);
          }
}


/***************************************************
*  Schreibt ein Adrež- oder Datenregister
***************************************************/

void write_adreg(int nummer)
{
	if   (nummer < 8)
		write_dreg(nummer&7);
	else	write_areg(nummer&7);
}


/***************************************************
*  Weist Befehlsteile an Variablen zu.
***************************************************/

void zuweisung(void)
{
     reg    = befehl & 7;
     mode   = (befehl >> 3) & 7;
     opmode = (befehl >> 6) & 7;
     reg1   = (befehl >> 9) & 7;
}


/***************************************************
*  Dekodiert Bedingungs- Codes fr DBcc, Bcc, Scc.
***************************************************/

char *bedingung(int cond)
{
     return("t\0\0f\0\0hi\0ls\0cc\0cs\0ne\0eq\0vc\0vs\0pl\0mi\0ge\0lt\0gt\0le"
            + 3 * cond);
}


/***************************************************
* Bearbeitet die Adressierungsarten
***************************************************/

/* Decodiert das bei d(An,Ri) zus„tzlich ben”tigte Wort. */
void indexregister(int ispc)
{
     register int nummer;


	if	(ispc)
		write_pcrel_short();
	else write32( (long) ( (char) (code[cindex] & 255)));     /* Displacement */
     writechr('(');
     if   (ispc)
          writestr("pc");
     else write_areg(reg);
     writechr(',');
     nummer =  (code[cindex] >> 12) & 7;  /* Regnummer */
     if   (0 > code[cindex])
          write_areg(nummer);
     else write_dreg(nummer);
     writechr('.');
     writechr((code[cindex] & 2048) ? 'l' : 'w');
     writechr(')');
}


void adressierung(void)
{
     writepos(OPR_POS);   /* Tabulatorposition fr Operandenfeld */
     switch (mode) {
       case MOD_DDIR:
             write_dreg(reg);
             break;

       case MOD_ADIR:
             write_areg(reg);
             break;

       case MOD_AIND:
             nrind: writechr('(');
             write_areg(reg);
             writechr(')');
             break;

       case MOD_POSI:
             writechr('(');
             write_areg(reg);
             writechr(')');
             writechr('+');
             break;

       case MOD_PRED:
             writechr('-');
             goto nrind;

       case MOD_OFFS:
             getcode();
             write16s(code[cindex]);
             goto nrind;

       case MOD_INDX:
       	   getcode();
             indexregister(FALSE);
             break;

       case MOD_SPEC:
             getcode();
             switch (reg) {
               case REG_ABSH:
                     write32((long) code[cindex]);
                     if	(issize)
                     	writestr(".w");
                     break;

               case REG_ABLO:
               	 if	(ismem)
               	 	{
               	 	long wert;

					getcode();
					wert = *( (long *) (code + cindex - 1) );
					if	(wert >= m_beg && wert < m_end)
						writelbl(wert - m_beg);
					else write32 (wert);
               	 	}
               	 else write_long();
               	 if	(issize)
               	 	writestr(".l");
                     break;

               case REG_RELA:
               	 write_pcrel();
                     writestr("(pc)");
                     break;

               case REG_RIDX:
                     indexregister(TRUE);
                     break;

               case REG_IMME:
                     switch (format) {
                       case FMT_BYTE:
                             writechr('#');
                             write8(code[cindex]);
                             break;

                       case FMT_WORD:
                             writechr('#');
                             write16(code[cindex]);
                             break;

                       case FMT_LONG:
                             writechr('#');
                             write_long();
                             break;

                       default: writestr("~~OPSIZE~~");

                       } /* END SWITCH format */
                     break;
               default: writestr("~~MODE~~"); /* unbek. Adressierungsart */

               } /* END SWITCH reg */

       } /* END SWITCH mode */
}


/***************************************************
* Ausgabefunktion, wenn erkannt wurde, daž kein
* gltiger Befehlscode vorliegt.
***************************************************/

void nocode( void )
{
	register int i;

	writestr("DC.W");
	writepos(OPR_POS);
	for	(i = 0; i <= cindex; i++)
		{
		if	(i)
			writechr(',');
		write16(code[i]);
		}
	comment(CMT_POS, FALSE, TRUE);
	ill_opcode = TRUE;
}

/***************************************************
* Dekodiert alle 00- Befehle
***************************************************/

int decode0(void)
{
     register char *prefix_str;
     register unsigned int w;
     

	zuweisung();
	if	(is30 && reg1 == 7 && opmode <= 2)		/* MOVES */
		{
		format = opmode;
		getcode();
		w = code[cindex];
		if	((w & 0x7ff) != 0)
			return(TRUE);
		writestr("moves");
		write_format();
		if	(w & 2048)			/* reg -> ea */
			{
			write_adreg(w >> 12);
			writechr(',');
			adressierung();
			}
		else	{					/* ea -> reg */
			adressierung();
			writechr(',');
			write_adreg(w >> 12);
			}
		return(FALSE);
		}

	if	(is30 && (opmode == 3) && (reg1 <= 2))	/* CHK2,CMP2 */
		{
		getcode();					/* Zusatzwort */
		w = code[cindex];
		if	((w & 0x7ff) != 0)
			return(TRUE);
		format = reg1;
		writestr((w & 0x800) ? "chk2" : "cmp2");
		write_format();
		adressierung();
		writechr(',');
		w >>= 12;
		write_adreg(w);
		return(FALSE);
		}

	if	(is30 && (opmode == 3) && (reg1 >= 5))	/* CAS,CAS2 */
		{
		format = (reg1 & 3) - 1;
		if	(reg == 4 && mode == 7)		/* CAS2 */
			{
			register int i,du[2],dc[2],r[2];

			for	(i = 0; i < 2; i++)
				{
				getcode();
				w = code[cindex];
				dc[i] = w & 7;
				w >>= 3;
				if	((w & 7) != 0)
					return(TRUE);
				w >>= 3;
				du[i] = w & 7;
				w >>= 3;
				if	((w & 7) != 0)
					return(TRUE);
				w >>= 3;
				r[i] = w & 15;
				}
			writestr("cas2");
			write_format();
			write_dreg(dc[0]);
			writechr(':');
			write_dreg(dc[1]);
			writechr(',');
			write_dreg(du[0]);
			writechr(':');
			write_dreg(du[1]);
			writestr(",(");
			write_adreg(r[0]);
			writestr("):(");
			write_adreg(r[1]);
			writechr(')');
			}
		else	{						/* CAS */
			register int dc,du;

			getcode();				/* Zusatzwort */
			w = code[cindex];
			dc = w & 7;
			w >>= 3;
			if	((w & 7) != 0)
				return(TRUE);
			w >>= 3;
			du = w & 7;
			w >>= 3;
			if	(w)
				return(TRUE);
			writestr("cas");
			write_format();
			write_dreg(dc);
			writechr(',');
			write_dreg(du);
			writechr(',');
			adressierung();
			}
		return(FALSE);
		}

	if	(mode == 1)	/* IF1,    MOVEP */
		{
		if   (opmode < 4)
			return(TRUE);
		format = (opmode & 1) ? FMT_LONG : FMT_WORD;
		writestr("movep");
		write_format();
		mode = MOD_OFFS;
		if   (opmode & 2)	/* Ziel: Adr.ind. mit Offset */
			{
			write_dreg(reg1);
			writechr(',');
			adressierung();
			}
		else { 			/* Ziel: Datenregister */
			adressierung();
			writechr(',');
			write_dreg(reg1);
			}
		} /* IF1 */
	else { /* ELSE1 */
		if   ( ( ((befehl & 511) == 60) || ((befehl & 511) == 124) ) &&
			  ( (reg1 == 0) || (reg1 == 1) || (reg1 == 5) ) )
			{
			/* IF4 */                              /* >CCR, >SR */
			if	(reg1 == 0)
				prefix_str = "ori";
			else prefix_str = (reg1 == 1) ? "andi" : "eori";
			writestr(prefix_str);
			getcode();
			writepos(OPR_POS);
			writechr('#');
			if   (opmode)	/* word >SR */
				{
			     write16(code[1]);
			     writestr(",sr");
				}
			else {		/* byte >CCR */
				write8((char) code[1]);
				writestr(",ccr");
				}
			} /*IF4 */
          else { /* ELSE4 */
			if	(adfehler(3 - 
				(((reg1 == 4) && (opmode == 0)) || (opmode == 4))
				))          /* BTEST => adfehler(2), sonst adfehler(3) */
				return(TRUE);
			if   ((opmode & 4) || (reg1 == 4)) { /* IF 7 */
			                         /* BCHG,BCLR,BSET,BTST */
				writestr("btst\0bchg\0bclr\0bset\0" + 5 * (opmode & 3));
				writepos(OPR_POS);
				if	(opmode & 4)	 	/* Bitnr. aus Datenregister */
					write_dreg(reg1);
				else {				/* direkte Daten */
					getcode();
					writechr('#');
					write8((char) code[1]);
					}
				writechr(',');
				adressierung();
				} /* IF7 */
			else { /* ELSE7 */
			     if   ( (reg1 > 6) || (reg1 == 4) || (opmode >= 3))
			     	return(TRUE);
								/* ADDI, ANDI,CMPI,EORI,SUBI */
		          getcode();
		          format = opmode;
		          writestr("ori\0\0andi\0subi\0addi\0mist\0eori\0cmpi" + 5 * reg1);
		          write_format();
		          writechr('#');
		          if   (format == FMT_BYTE)
		               write8((char) code[1]);
		          else if   (format == FMT_WORD)
		                    write16(code[1]);
		               else write_long();
		          writechr(',');
		          adressierung();
				} /* ELSE7 */
			} /* ELSE4 */
		} /* ELSE1 */
	return(FALSE);
}


/***************************************************
* Bearbeitet alle MOVE und MOVEA-Befehle
***************************************************/

int move(void)
{
	register int aderr1, modea, rega;


	zuweisung();
	aderr1 = adfehler(0);
	modea  = mode;
	rega   = reg;
	mode   = opmode;
	reg    = reg1;
	if	(aderr1 || (adfehler(3)  &&  (mode != MOD_ADIR) ))
		return(TRUE);
	writestr("move");
	if	(mode == MOD_ADIR)
		writechr('a');
	write_format();
	mode = modea;
	reg = rega;
	adressierung();
	writechr(',');
	mode = opmode;
	reg = reg1;
	adressierung();
	return(FALSE);
}


/***************************************************
* Bearbeitet alle 04-Befehle
***************************************************/

void movemreg(void)
{
#define ISREG(i) ((mode == MOD_PRED) ? ((regs << i) < 0) : ((regs >> i) & 1))

     register int i, regs, incr;
              int isnotfirst;

     isnotfirst = FALSE;
     writestr("movem");
     write_format();
     getcode();
     regs = code[1];
     if   (reg1 & 2) {    /* Speicher > Register */
          adressierung();
          writechr(',');
          i    = 15;
          incr = -1;
          }
     else {               /* Register > Speicher */
          i    = 0;
          incr = 1;
          }

     while((i >= 0) && (i < 16)) {      /* insgesamt 16 Register */
          if (ISREG(i)) {
             if   (isnotfirst)          /* erstes '/' unterdrcken */
                  writechr('/');
             isnotfirst = TRUE;
		   write_adreg(i);
             }
          i += incr;
          }

     if   (!(reg1 & 2)) {
          writechr(',');
          adressierung();
          }

}


int decode4(void)
{
     int dir;


     zuweisung();

	if	((reg1 == 6) && (opmode <= 1) && is30)	/* MULX.L,DIVX.L */
		{
		register int dq,dr;

		getcode();
		dir = code[cindex];
		if	((dir & 0x83f8) != 0)
			return(TRUE);
		dq = (dir >> 12) & 7;
		dr = dir & 7;
		writestr((opmode) ? "div" : "mul");
		writechr((dir & 0x800) ? 's' : 'u');

		/* Die Codierung von divx(l).l ist widersprchlich, hier */
		/* widersprechen sich pasm/masm/bug/pd gegenseitig, die  */
		/* korrekte Codierung ist nicht zu erkennen			  */

		if	(opmode && ((dir & 1024) == 0) && (dq != dr))
			writechr('l');
		format = FMT_LONG;
		write_format();
		adressierung();
		writechr(',');
		if	(((!opmode) && (dir & 1024)) || ((opmode) && (dr != dq)))
			{
			write_dreg(dr);
			writechr(':');
			}
		write_dreg((dir >> 12) & 7);	/* dq */
		return(FALSE);
		}

     if   ((reg1 == 7) && (opmode == 1)) /* LINK,MOVE USP,TRAP,UNLK */
          switch (mode) { /* SWITCH1 */  /* NOP,RESET,RTE,RTR,RTS,STOP,TRAPV */
            case 0:
            case 1: /* TRAP */
                  writestr("trap");
                  writepos(OPR_POS);
                  writechr('#');
                  write8((char) (befehl&15));
                  break;
            case 2: /* LINK */
                  writestr("link");
                  writepos(OPR_POS);
                  write_areg(reg);
                  writestr(",#");
                  getcode();
                  write16s(code[1]);
                  break;
            case 3: /* UNLK */
                  writestr("unlk");
                  writepos(OPR_POS);
                  areg: write_areg(reg);
                  break;
            case 4:
            case 5: /* MOVE USP */
                  writestr("move");
                  writepos(OPR_POS);
                  if (mode == 5) {
                     writestr("usp,");
                     goto areg;
                     }
                  write_areg(reg);
                  writestr(",usp");
                  break;
            case 6:
                  if   ((reg == 4) && (!is30))
                       return(TRUE);
                  writestr("reset\0nop\0\0\0stop\0\0rte\0\0\0rtd\0\0\0rts\0\0\0trapv\0rtr"+6*reg);
                  if ((reg == 2) || (reg == 4)){  /* STOP,RTD */
                     writepos(OPR_POS);
                     writechr('#');
                     getcode();
                     write16(code[1]);
                     }
                  break;
            case 7:
				if	(is30 && ((reg == 2) || (reg == 3)))	/* MOVEC */
					{
					int c,d;

					getcode();
					dir = code[cindex];
					c = dir & 0xfff;
					d = (dir >> 12) & 0xf;
					if	(c >= 0x800)
						{
						if	(c > 0x804)
							return(TRUE);
						c -= 0x800-3;
						}
					else	{
						if	(c > 2)
							return(TRUE);
						}
					writestr("movec");
					writepos(OPR_POS);
					if	(befehl & 1)
						{
						write_adreg(d);
						writechr(',');
						}
					writestr("sfc\0\0dfc\0\0cacr\0usp\0\0vbr\0\0caar\0msp\0\0isp" + c*5);
					if	(!(befehl & 1))
						{
						writechr(',');
						write_adreg(d);
						}
					return(FALSE);
					}
				return(TRUE);
            } /* SWITCH1 */
     else {   /* ELSE1, Rest */
     	if	((reg1 == 4) && (opmode == 7) && (mode == 0) && is30)
     		{	/* EXTB.L */
			writestr("extb");
			format = FMT_LONG;
			goto fmt;
     		}
          if   (opmode & 4) { /* IF2, CHK,LEA */
               if   ((opmode == 6) || ((opmode == 4) && is30)) 	/* IF3, CHK */
               	{		/* 68030 kann auch long */
                    if   (adfehler(1))
                         return(TRUE);
               	format = (opmode == 6) ? FMT_WORD : FMT_LONG;
                    writestr("chk");
                    write_format();
                    adressierung();
                    writechr(',');
                    write_dreg(reg1);
                    } /* IF3 */
               else { /* ELSE3, LEA */
                    if   ((opmode != 7) || adfehler(6))
                         return(TRUE);
                    writestr("lea");
                    adressierung();
                    writechr(',');
                    write_areg(reg1);
                    } /* ELSE3 */
               } /* IF2 */
          else { /* ELSE2, Rest */
               if   (opmode >= 4)
                    return(TRUE);
               switch (reg1) { /* SWITCH3 */
                 case 0:
                      if   (adfehler(3))
                           return(TRUE);
                      if   (opmode <= 2)	/* NEGX */
                      	  {
                           writestr("negx");
                           form: format = opmode;
                           write_format();
                           }
                      else {               /* MOVE SR> */
                           writestr("move");
                           writepos(OPR_POS);
                           writestr("sr,");
                           }
				  adr:
                      adressierung();
                      break; 
                 case 1:           /* CLR */
				  if	  (adfehler(3))
				  	  return(TRUE);
                      if   (opmode <= 2)
                      	  {
	                      writestr("clr");
     	                 goto form;
     	                 }
				  if	  ((opmode == 3) && is30)	/* MOVE ccr,<ea> */
				  	  {
				  	  format = FMT_WORD;
				  	  writestr("move");
				  	  writepos(OPR_POS);
				  	  writestr("ccr,");
				  	  goto adr;
				  	  }
				  else return(TRUE);
                 case 2:
                      if   (opmode <= 2)   /* NEG */
                      	  {
                           if   (adfehler(3))
                                return(TRUE);
                           writestr("neg");
                           goto form;
                           }
                      else {                   /* MOVE >CCR */
                           if   (adfehler(1))
                                return(TRUE);
                           writestr("move");
                           adressierung();
                           writestr(",ccr");
                           }
                      break;
                 case 3:
                      if   (opmode <= 2)    /* NOT */
                      	  {
                           if   (adfehler(3))
                                return(TRUE);
                           writestr("not");
                           goto form;
                           }
                      else {                   /* MOVE >SR */
                           if   (adfehler(1))
                                return(TRUE);
                           format = FMT_WORD;
                           writestr("move");
                           adressierung();
                           writestr(",sr");
                           }
                      break;  
                 case 4:
                 case 6:
                      switch (opmode) { /* switch4 */
                        case 0: /* NBCD,LINK.L */
						if	((mode == 1) && (reg1 == 4) && is30)
							{
							writestr("link");
							format = FMT_LONG;
							write_format();
							write_areg(reg);
							writestr(",#");
							getcode();
							write_long();
							return(FALSE);
							}
                             if   (adfehler(3) || (reg1 ==6 ))
                                  return(TRUE);
                             writestr("nbcd");
                             adressierung();
                             break;
                        case 1: /* PEA,SWAP */
                             if   (reg1 != 4)
                                  return(TRUE);
                        	    if   (mode == 0)	/* SWAP */
                        	    	    {
                                  writestr("swap");
                                  writepos(OPR_POS);
                                  dreg: write_dreg(reg);
                                  }
                             else
                             if   ((mode == 1) && is30)	/* BKPT */
                             	    {
                             	    writestr("bkpt");
                             	    writepos(OPR_POS);
                             	    writechr('#');
                             	    write16(reg);
                             	    }
                             else {              /* PEA */
                                  if   (adfehler(6))
                                       return(TRUE);
                                  writestr("pea");
                                  adressierung();
                                  }
                             break; 
                        default:  /* MOVEM,EXT */
                             if   (mode == 0)  /* EXT */
                                  {
                                  if   (reg1 == 6)
                                       return(TRUE);
                                  format = (opmode == 2) ? FMT_WORD : FMT_LONG;
                                  writestr("ext");
                                  fmt:
                                  write_format();
                                  goto dreg;
                                  }
                             else {     /* MOVEM */
                                  format = opmode - 1;
                                  dir = reg1 & 2;
                                  if   (((dir == 0) && adfehler(7)) ||
                                        ((dir == 1) && adfehler(8)))
                                       return(TRUE);
                                  movemreg();
                                  }
                             break;
                        } /* switch4 */
                      break;
                 case 5:
                      if   (befehl == 0x4afc)
                           writestr("illegal");
                      else {
                           if   (adfehler(3))
                                return(TRUE);
                           if   (opmode <= 2)   /* TST */
                           	  {
                                writestr("tst");
                                goto form;
                                }
                           else {               /* TAS */
                                writestr("tas");
                                adressierung();
                                }
                           }
                      break;
                 case 7:
                      if   ((opmode <= 1) || (adfehler(6)))
                           return(TRUE);
                                         /* JMP,JSR */
                      writestr((opmode == 2) ? "jsr" : "jmp");
                      adressierung();
                      break;
                 } /* SWITCH3 */
               } /* ELSE2 */
          } /* ELSE1 */
	return(FALSE);
}


/***************************************************
* Bearbeitet alle 05-Befehle (DBcc,Scc,ADDQ,SUBQ).
***************************************************/

int decode5(void)
{
	register int  data;
	register char *cond_str;
	extern   char *bedingung();


	reg    = befehl & 7;
	mode   = (befehl >> 3) & 7;
	format = (befehl >> 6) & 7;
	if	( (format & 3) == 3) { /* IF1, DBcc,Scc */
		cond_str = bedingung((befehl >> 8) & 15);
		if   (mode == 1)						/* DBcc */
			{
			getcode();
			writestr("db");
			writestr(cond_str);
			writepos(OPR_POS);
			write_dreg(reg);
			writechr(',');
			write_pcrel();
			}
		else
		if	(is30 && (mode == 7) && (reg >=2) && (reg <= 4))	/* Trapcc */
			{
			writestr("trap");
			writestr(cond_str);
			if	(reg == 4)
				return(FALSE);
			format = (reg == 3) ? FMT_LONG : FMT_WORD;
			write_format();
			mode = MOD_SPEC;
			reg = REG_IMME;
			adressierung();
			return(FALSE);
			}
		else {
			if	(adfehler(3))					/* Scc */
				return(TRUE);
			writechr('s');
			writestr(cond_str);
			adressierung();
			}
		} /* IF1 */
	else { /* ELSE1, ADDQ,SUBQ */
		if   (adfehler(5))
		     return(TRUE);
		data = (befehl >> 9) & 7;
		format &= 3;
		if   (format >= 3)
			return(TRUE);
		if	(data == 0)
			data = 8;
		writestr( (befehl & 256) ? "subq" : "addq");
		write_format();
		writechr('#');
		writechr('0' + (char) data);
		writechr(',');
		adressierung();
		} /* ELSE1 */
	return(FALSE);
}


/***************************************************
* Bearbeitet alle relativen Sprungbefehle.
***************************************************/

int branch(void)
{
	register int  cond;
	unsigned char displ;


	cond = (befehl >> 8) & 15;
	displ = befehl & 0xff;
	if   (cond == 0)
		writestr("bra");
	else if   (cond == 1)
			writestr("bsr");
		else {
			writechr('b');
			writestr(bedingung(cond));
			}

	if	(is30 && (displ == 0xff))
		{
		writestr(".l");		/* long branch (68030) */
		writepos(OPR_POS);
		getcode();
		getcode();
		write_pcrel_long();
		return(FALSE);
		}
	if   (befehl & 255)			/* IF1, short Branch */
		{
		writechr('.');
		writechr((ismas) ? 'b' : 's');
		writepos(OPR_POS);
		write_pcrel_short();
		}
	else { 					/* ELSE1, long Branch */
		getcode();
		writepos(OPR_POS);
		write_pcrel();
		}
	return(FALSE);
}


/***************************************************
* Bearbeitet ausschliežlich MOVEQ.
***************************************************/

int moveq(void)
{
     register int  reg, data;

	if   (befehl & 256)
		return(TRUE);
	data = (int) ((char) befehl); /* 8 Bit mit Vorzeichen */
	reg  = (befehl >> 9) & 7;
	writestr("moveq");
	writepos(OPR_POS);
	writechr('#');
	write16s(data);
	writechr(',');
	write_dreg(reg);
	return(FALSE);
}


/***************************************************
* Bearbeitet DIVS,DIVU,MULS,MULU,AND,OR,EXG,ABCD,SBCD
***************************************************/

int decode8C(int isdec8)
{
     zuweisung();
	if	(isdec8 && is30 && (mode <= 1) && ((opmode == 5) || opmode == 6))
		{
		writestr((opmode == 6) ? "unpk" : "pack");
		writepos(OPR_POS);
		if	(mode)
			{
			writestr("-(");
			write_areg(reg);
			writestr("),-(");
			write_areg(reg1);
			writechr(')');
			}
		else	{
			write_dreg(reg);
			writechr(',');
			write_dreg(reg1);
			}
		writestr(",#");
		getcode();
		write16s(code[cindex]);
		return(FALSE);
		}

     if   ((opmode & 3) == 3)		/* IF1, DIVS,DIVU,MULS,MULU */
		{
		if	(adfehler(1))
			return(TRUE);
		writestr( (isdec8) ? "div" : "mul");
		writechr( (opmode & 4) ? 's' : 'u');
		format = FMT_WORD;
		adressierung();
		writechr(',');
		write_dreg(reg1);
		}	/* IF1 */
	else {	/* ELSE1, OR,SBCD,AND,ABCD,EXG */
		if	(((opmode == 5) && (mode <= 1) ||
			  (opmode == 6) && (mode == 1)) && !isdec8)	/* IF3, EXG */
			{
			writestr("exg");
			writepos(OPR_POS);
			if   (mode && (opmode == 5))
			     write_areg(reg1);
			else write_dreg(reg1);
			writechr(',');
			if   (mode)
			     write_areg(reg);
			else write_dreg(reg);
               }	/* IF3 */
          else {	/* ELSE3, OR,SBCD,AND,ABCD */
               if   ((opmode == 4) && (mode <= 1))	/* IF6, SBCD,ABCD */
               	{
                    writestr( (isdec8) ? "sbcd" : "abcd");
                    writepos(OPR_POS);
                    if   (mode == 0) { /* IF7, Datenregister */
                         write_dreg(reg);
                         writechr(',');
                         write_dreg(reg1);
                         } /* IF7 */
                    else { /* ELSE7, Adressregister predekrement */
                         writestr("-(");
                         write_areg(reg);
                         writestr("),-(");
                         write_areg(reg1);
                         writechr(')');
                         } /* ELSE7 */
                    }	/* IF6 */
        		else {	/* ELSE6, OR,AND */
				int  to_memory;

				format = opmode & 3;
				to_memory = opmode & 4;	/* <dn> -> <ea> */
				if   ((opmode == 3) || adfehler((to_memory) ? 4 : 1))
					return(TRUE);
				writestr( (isdec8) ? "or" : "and");
				write_format();
				if	(to_memory)	/* Ziel: effektive Adresse */
					{
					write_dreg(reg1);
					writechr(',');
					adressierung();
					}
				else {			/* Ziel: Datenregister */
					adressierung();
					writechr(',');
					write_dreg(reg1);
					}
				} /* ELSE6 */
			} /* ELSE3 */
		} /* ELSE1 */
	return(FALSE);
}


/***************************************************
* Bearbeitet ADD, ADDA, ADDX, SUB, SUBA und SUBX
* Der String "add" bzw "sub" ist Parameter.
***************************************************/

int addsub(char prefix_str[])
{
     zuweisung();
     if   ((opmode & 3) == 3) { /* IF1, ADDA,SUBA */
          format = (opmode & 4) ? FMT_LONG : FMT_WORD;
          writestr(prefix_str);
          writechr('a');
          write_format();
          adressierung();
          writechr(',');
          write_areg(reg1);
          } /* IF1 */
     else { /* ELSE1, ADD,ADDX,SUB,SUBX */
          if   ((opmode & 4) && (mode <= 1)) {  /* IF3, ADDX,SUBX*/
               writestr(prefix_str);
               format = opmode & 3;
               writechr('x');
               write_format();
               if   (mode & 1) { /* IF4, Adressregister predekrement */
                    writestr("-(");
                    write_areg(reg);
                    writestr("),-(");
                    write_areg(reg1);
                    writechr(')');
                    } /* IF4 */
               else { /* ELSE4, Datenregister */
                    write_dreg(reg);
                    writechr(',');
                    write_dreg(reg1);
                    } /* ELSE4 */
               } /* IF3 */
          else { /* ELSE3, ADD,SUB */
               format = opmode & 3;
               if   (adfehler(opmode & 4))
                    return(TRUE);
               writestr(prefix_str);
               write_format();
               if   (opmode & 4) { /* IF6, Ziel: effektive Adresse */
                    write_dreg(reg1);
                    writechr(',');
                    adressierung();
                    } /* IF6 */
               else { /* ELSE6, Ziel: Datenregister */
                    adressierung();
                    writechr(',');
                    write_dreg(reg1);
                    } /* ELSE6 */
               } /* ELSE3 */
          } /* ELSE1 */
	return(FALSE);
}


/***************************************************
* Bearbeitet CMP, CMPA, CMPM und EOR.
***************************************************/

int decodeB(void)
{
	zuweisung();
	format = opmode & 3;
	switch (opmode)
		{
		case 0:
		case 1:
		case 2:	if	(adfehler(0))
					return(TRUE);
          				  /* CMP */
				writestr("cmp");
				print: write_format();
				adressierung();
				writechr(',');
				if   (opmode < 3)
				     write_dreg(reg1);
				else write_areg(reg1);
				break;
		case 3: 			/* CMPA.W */
				format = FMT_WORD;
				goto cmpa;
		case 7:			/* CMPA.L */
				format = FMT_LONG;
				cmpa:
				if	(adfehler(0))
					return(TRUE);
				writestr("cmpa");
				goto print;
		case 4:
		case 5: 
		case 6:	if   (mode == 1)		/* CMPM */
					{
					writestr("cmpm");
					write_format();
					writechr('(');
					write_areg(reg);
					writestr(")+,(");
					write_areg(reg1);
					writestr(")+");
					}
				else	{				/* EOR */
					if	(adfehler(3))
						return(TRUE);
					writestr("eor");
					write_format();
					write_dreg(reg1);
					writechr(',');
					adressierung();
					}
                    break;
		} /* switch1 */
	return(FALSE);
}


/***************************************************
* Bearbeitet alle Schiebe- und Rotationsbefehle
***************************************************/

int shiftrot(void)
{
	char *shtyp_str;
	int  dir, immreg,sh_typ,instr_typ;
	int  count;


	if	(((befehl & 0x8c0) == 0x8c0) && is30)	/* Bit field */
		{
		register int offs,width;

		instr_typ = (befehl >> 8) & 7;
		zuweisung();
		getcode();
		dir = code[cindex];
		if	(dir & 0x8000)
			return(TRUE);
		immreg = (dir >> 12) & 7;
		offs  = (dir >> 6) & 0x1f;
		width = dir & 0x1f;
		if	(((dir & 2048) && (offs > 7)) || ((dir & 32) && (width > 7)))
			return(TRUE);
		if	(instr_typ == 0 || instr_typ == 2 || instr_typ == 4 || instr_typ == 6)
			{
			if	(immreg)
				return(TRUE);
			immreg = -1;
			}
		writestr("bf");
		writestr("tst\0\0extu\0chg\0\0exts\0clr\0\0ffo\0\0set\0\0ins" + 5*instr_typ);
		writepos(OPR_POS);
		if	(instr_typ == 7)
			{
			write_dreg(immreg);
			writechr(',');
			immreg = -1;
			}
		adressierung();
		writechr('{');
		if	(dir & 2048)
			write_dreg(offs);
		else	write16(offs);
		writechr(':');
		if	(dir & 32)
			write_dreg(width);
		else	write16(width);
		writechr('}');
		if	(immreg >= 0)
			{
			writechr(',');
			write_dreg(immreg);
			}
		return(FALSE);
		}

	shtyp_str = "asr\0\0asl\0\0lsr\0\0lsl\0\0roxr\0roxl\0ror\0\0rol";
	reg    = befehl & 7;
	mode   = (befehl >> 3) & 7;
	format = (befehl >> 6) & 3;
	dir    = (befehl >> 8) & 1;
	count  = (befehl >> 9) & 7;
	if   (format < 3) { /* IF1, keine effektiven Adressen */
		instr_typ = (befehl >> 2) & 6;
		immreg    = (befehl >> 5) & 1;
		sh_typ    = instr_typ + dir;
		writestr(shtyp_str + 5 * sh_typ);
		write_format();
		if	(immreg)		/* IF2, Z„hler im Datenregister */
               write_dreg(count);
          else { /* ELSE2, Z„hler direkt */
               if (count == 0)
                  count = 8;
               writechr('#');
               write8((char) count);
               } /* ELSE2 */
          writechr(',');
          write_dreg(reg);
          } /* IF1 */
     else { /* ELSE1, effektive Adressen */
		if	((befehl & 2048) || (adfehler(4)))
			return(TRUE);
		instr_typ = (befehl >> 8) & 6;
		sh_typ    = instr_typ+dir;
		writestr(shtyp_str + 5 * sh_typ);
		format = FMT_WORD;
		write_format();
		adressierung();
		} /* ELSE1 */
	return(FALSE);
}


/***************************************************
* Bearbeitet alle FPU-Befehle (Line-F, cp_id = 1)
***************************************************/

int fpu(void)
{
	return(TRUE);		/* keine FPU */
}


/***************************************************
* Bearbeitet alle FPU-Befehle (Line-F, cp_id = 0)
***************************************************/

int pmmu(void)
{
	int c;
	int subf,is_ea,subf2,mask,fc,d;
	char *mn_s;


	if	(opmode)
		return(TRUE);			/* nur cpGEN */

	getcode();
	c = code[cindex];
	d = c & 7;				/* 3 Bit fr Datenregnr. oder #fc */
	c >>= 3;
	fc = c & 3;				/* 2 Bit fr fc-Typ (Dn,#,xfc) */
	c >>= 2;
	mask = c & 15;				/* 4 Bit fr Maske */
	c >>= 4;
	subf2 = c & 7;				/* 3 Bit fr Subfunktion2 */
	c >>= 3;
	subf = c & 15;				/* 4 Bit fr Subfunktion */

	switch(subf)
		{
		case 2:				/* PLOADR,PLOADW */
			if	((subf2 > 1) || mask)
				return(TRUE);
			mn_s = ((subf2) ? "ploadr" : "ploadw");
			mask = -1;
			is_ea = TRUE;
			break;
		case 3:				/* PFLUSH */
			if	((subf2 != 0) && (subf2 != 8))
				return(TRUE);
			mn_s = "pflush";
			is_ea = subf2 & 8;
			break;
		default:
			return(TRUE);
		}

	if	(!is_ea && (mode != 0 || reg != 0))
		return(TRUE);

	switch(fc)
		{
		case 0:
			if	(d > 1)
				return(TRUE);
			writestr(mn_s);
			writepos(OPR_POS);
			writestr((d) ? "dfc" : "sfc");
			break;
		case 1:
			writestr(mn_s);
			writepos(OPR_POS);
			write_dreg(d);
			break;
		case 2:
			writestr(mn_s);
			writepos(OPR_POS);
			writechr('#');
			write16(d);
			break;
		case 3:
			return(TRUE);
		}

	if	(mask >= 0)
		{
		writestr(",#");
		write16(mask);
		}
	if	(is_ea)
		{
		writechr(',');
		adressierung();
		}
	return(FALSE);
}


/***************************************************
* Bearbeitet alle Coprozessorbefehle (Line-F)
***************************************************/

int copro(void)
{
	if	(!is30)
		return(TRUE);
	zuweisung();
	if	(reg1 == 0)
		return(pmmu());
	else return(fpu());
}


/***************************************************
* HAUPT- UNTERPROGRAMM:
* Erkennt das erste Halbbyte eines Befehlswortes
* und verzweigt entsprechend.
***************************************************/

void disass(int is_opcode)
{
	int erste_stelle;
	int isnocode;

	befehlsadresse = adr;
	cindex = -1;
	ill_opcode = FALSE;
	getcode();
	befehl = code[0];

	if	(befehlsadresse == 0L &&
		 stk_len != 0L &&
		 (befehl & 0xff00) == 0x6000)
		{
		isturbo = TRUE;
		endcopyr = (befehl & 0xff) + 2L;
		}

	/* Reloziertes Langwort oder die Stackgr”že von Turbo */
	if	(reloc_search(befehlsadresse, FALSE) ||
		 (isturbo && befehlsadresse == 2L))
		{
		writestr("DC.L");
		writepos(OPR_POS);
		write_long();
		comment(CMT_POS, FALSE, FALSE);
		return;
		}

	if	(befehl == 0 && (befehlsadresse == text_len - 2L ||
					  reloc_search(befehlsadresse+2, FALSE) ||
					  label_search(befehlsadresse+2, FALSE) ||
					  label_search(befehlsadresse+3, FALSE)
					 ) ||
		 (isturbo && befehlsadresse > 4
				&& befehlsadresse < endcopyr)
		)
		is_opcode = FALSE;

	if	(!is_opcode)
		{
		nocode();
		return;
		}

	erste_stelle = (befehl >> 12) & 15;    /* Oberes Nibble */
	switch (erste_stelle) {
	  case  0: isnocode = decode0();break;
	          /* CHK2,CMP2,
	              BCHG,BCLR,BSET,BTST,MOVEP
	             00,ORI
	             02,ANDI
	             04,SUBI
	             06,ADDI
	             0A,EORI
	             0C,CMPI  */
	  case  1: format = FMT_BYTE; goto mov;			/* MOVE.B */
	  case  2: format = FMT_LONG; goto mov;			/* MOVE.L */
	  case  3: format = FMT_WORD;
	  		 mov: isnocode = move();break;		/* MOVE.W */
	  case  4: isnocode = decode4();break;			/* CHK,LEA,MOVEM,
	             40,NEGX,MOVE SR>
	             42,CLR,MOVE CCR>
	             44,NEG,MOVE >CCR,NBCD
	             46,NOT,MOVE >SR
	             48,EXT,PEA
	             484,SWAP
	             4A,TAS,TST
	             4E,JMP,JSR
	             4E4,TRAP
	             4E5,LINK,UNLK
	             4E6,MOVE USP
	             4E70,RESET
	             4E71,NOP
	             4E72,STOP
	             4E73,RTE
	             4E75,RTS
	             4E76,TRAPV
	             4E77,RTR  */
	  case  5: isnocode = decode5();break;			/* ADDQ,DBcc,Scc,SUBQ */
	  case  6: isnocode = branch();break;			/* Bcc,BRA,BSR */
	  case  7: isnocode = moveq();break;			/* MOVEQ */
	  case  8: isnocode = decode8C(TRUE);break;		/* DIVS,DIVU,OR,SBCD */
	  case  9: isnocode = addsub("sub");break;		/* SUB,SUBX */
	  case 10: isnocode = TRUE;break;				/* LINE-A */
	  case 11: isnocode = decodeB();break;			/* CMP,CMPM,EOR */
	  case 12: isnocode = decode8C(FALSE);break;		/* ABCD,AND,EXG,MULS,MULU */
	  case 13: isnocode = addsub("add");break;		/* ADD,ADDX */
	  case 14: isnocode = shiftrot();break;			/* ASL,ASR,LSL,LSR,ROL,ROR,ROXL,ROXR */
	  case 15: isnocode = copro();break;			/* LINE-F */
	  }

	if	(isnocode)
		{
		nocode();
		return;
		}

	/* Falls sp„ter ein Systemaufruf kommt, wird hier die	*/
	/* Funktionsnummer gemerkt						*/

	if	(befehl == 0x3f3c)	/* "MOVE.W #XX,-(SP)" */
		{
		mv_os_fnr_adr = befehlsadresse + 4;
		os_fnr = code[1];
		}
	if	(befehl == 0x4267)	/* "CLR.W -(SP)" */
		{
		mv_os_fnr_adr = befehlsadresse + 2;
		os_fnr = 0;
		}

	if	(!ill_opcode)
		comment(CMT_POS, iscode, isasc);
}
