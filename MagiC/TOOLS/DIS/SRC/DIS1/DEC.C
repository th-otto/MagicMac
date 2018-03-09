/**********************************************************
*
*                 DECODE():
* Dekodiert einen Maschinenbefehl im Feld char cdatei[] ab
* Adresse <adr> und sucht nach bra, bsr, bcc, dbcc sowie
* "lbl(PC)" und lbl(PC,Rn)- Adressierung.
* Die adressierte relative Adresse wird in die Labeltabelle
* eingetragen.
* FÅr die m-Option (aus dem Speicher disassemblieren) werden
* auch die Langwort- Adressen in die Labeltabelle aufgenommen,
* sofern sie sich im disassemblierten Bereich befinden.
*
**********************************************************/

#include <tos.h>
#define FALSE (0)
#define TRUE  (1)
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
#define MOD_SPEC  7      /* zusÑtzliche Adressierungsarten: */
#define REG_ABSH  0      /* absolute short              xxxx      */
#define REG_ABLO  1      /* absolute long               xxxxxxxx  */
#define REG_RELA  2      /* PC- relativ             xxxx(PC)      */
#define REG_RIDX  3      /* PC- relativ mit Index     xx(PC,Rn.f) */
#define REG_IMME  4      /* unmittelbar (immediate)    #xxxxxxxx  */

extern long	adr;		/* Adresse des NéCHSTEN Codeworts */
extern int	add_tab(long lbl);
extern int	*datei;
extern int	iserror;
extern int	isobj;
extern int	is30;
extern int	prg_file;
extern long	relo_pos, stk_len;
extern int	ismem;
extern long	m_beg,m_end;


static int  befehl, reg, mode, opmode, reg1, format, cindex;
static int  code[6];
static int  isturbo = FALSE;
static long endcopyr;


static void write_pcrel( void )
{
	unsigned int puffer;
	long pos;


	if	(isobj)
		{
		pos = relo_pos + adr - 2L;
		if	(pos != Fseek(pos, prg_file,0))
			goto err;
		if	(2L != Fread(prg_file, 2L, &puffer))
			{
			err:
			iserror = 1;
			return;
			}
		if	(6 == (puffer & 7))		/* Symboltabelle schon durchsucht */
			return;
		}
	iserror = add_tab(adr - 2L + code[cindex]);
}


static void write_pcrel_short( void )
{
	register long displ;


	displ = adr + ((long) ( (char) (code[cindex] & 255)));
	if	(cindex != 0)		/* kein short branch */
		displ -= 2L;
	iserror = add_tab(displ);
}


static void write_pcrel_long( void )
{
	register long displ;

	displ = adr - 4L + *( (long *) (code + cindex - 1) );
	iserror = add_tab(displ);
}


void getcode(void)
{
	cindex++;
	code[cindex] = datei[adr >> 1L];     /* hole Wort */
	adr += 2L;
}


void zuweisung(void)
    /* Weist Befehlsteile den globalen Variablen zu. */
{
      reg    =  befehl & 7;
      mode   =  (befehl >> 3) & 7;
      opmode =  (befehl >> 6) & 7;
      reg1   =  (befehl >> 9) & 7;
}


void adressierung(void)
{
      switch (mode) {
        case 5:   /* Adressregister indirekt mit Verschiebung */
        case 6:   /* Adressregister indirekt mit Index und Verschiedung */
               getcode();
               break;
        case 7:   /* Spezielle Adressierungsarten */
               getcode();
			switch (reg) {
			  case 3:       /* ProgrammzÑhler mit Index und Verschiebung */
			  	    write_pcrel_short();
			  	    break;
			  	    
			  case 1:       /* ABSOLUTE LANGADRESSE */
			         getcode();
			         if	(ismem)
			         		{
			         		long l;

						l = *((long *) (code+cindex-1));
						if	(l >= m_beg && l < m_end)
							iserror = add_tab(l - m_beg);
			         		}
			         break;
			  case 2:       /* PROGRAMMZéHLER MIT VERSCHIEBUNG */
			  	    write_pcrel();
			         break;
			  case 4:       /* unmittelbare Adressierung */
			         if (format == 2)    /* Langwort */
			            getcode();
			         break;
			  }
        }
}


void decode0(void)
{
	zuweisung();
	if	(is30 && reg1 == 7 && opmode <= 2)		/* MOVES */
		{
		format = opmode;
		getcode();
		if	((code[cindex] & 0x7ff) != 0)
			return;						/* Fehler */
		adressierung();
		return;
		}

	if	(is30 && (opmode == 3) && (reg1 <= 2))	/* CHK2,CMP2 */
		{
		getcode();					/* Zusatzwort */
		if	((code[cindex] & 0x7ff) != 0)
			return;					/* Fehler */
		format = reg1;
		adressierung();
		return;
		}

	if	(is30 && (opmode == 3) && (reg1 >= 5))	/* CAS,CAS2 */
		{
		format = (reg1 & 3) - 1;
		if	(reg == 4 && mode == 7)		/* CAS2 */
			{
			getcode();
			if	(code[cindex] & 0xe38)
				return;				/* Fehler */
			getcode();
			}
		else	{						/* CAS */
			getcode();				/* Zusatzwort */
			if	(code[cindex] & 0xfe38)
				return;				/* Fehler */
			adressierung();
			}
		return;
		}

	if	(mode == 1)     /* MOVEP */
		{
		if	(opmode >= 4)
			getcode();
		}
	else	{
		if	( ((befehl & 0x01bf) == 0x003c) &&	/* > CCR, >SR */
                 ( (reg1 == 0) || (reg1 == 1) || (reg1 == 5) ) )
               getcode();
          else {
               if   ( (opmode & 4) || (reg1 == 4) ) {
                                     /* BCHG,BCLR,BSET,BTST */
                    if  (reg1 == 4)       /* direkte Daten */
                        getcode();
                    adressierung();
                    }
               else {
                    if  ( (reg1 <= 6) && (reg1 != 4) && (opmode <= 2) ) {
                               /* ADDI,ANDI,CMPI,EORI,SUBI */
                        getcode();
                        format = opmode;
                        if (opmode == 2)
                           getcode();
                        adressierung();
                        }
                    }
               }
          }
}

void move(int nibble)
{
     if  ((format = nibble - 1) != 0)   /* nibble=1 => format = 0 */
         format ^= 3;              	/* nibble=2 => format = 2 */
     zuweisung();                  	/* nibble=3 => format = 1 */
     adressierung();     /* erster  Operand */
     mode  = opmode;     /* zweiter Operand */
     reg   = reg1;
     adressierung();
}

void decode4(void)
{
     zuweisung();
	if	((reg1 == 6) && (opmode <= 1) && is30)	/* MULX.L,DIVX.L */
		{
		getcode();
		if	(code[cindex] & 0x83f8)
			return;				/* Fehler */

		/* Die Codierung von divx(l).l ist widersprÅchlich, hier */
		/* widersprechen sich pasm/masm/bug/pd gegenseitig, die  */
		/* korrekte Codierung ist nicht zu erkennen			  */

		format = FMT_LONG;
		adressierung();
		return;
		}

	format = 1;
     if   ( (reg1 == 7) && (opmode == 1) ) { /* LINK,MOVE USP,TRAP,UNLK */
                                     /* NOP,RESET,RTE,RTR,RTD,RTS,STOP,TRAPV*/
          if   ( (mode == 2) || ( (mode == 6) && ((reg == 2) || (is30 && (reg == 4)) ) ||
          	  (is30 && ((reg == 2) || (reg == 3))) ))
               getcode();
          }
     else {
     	if	((opmode == 4) && is30)	/* chk.l */
     		{
     		format = FMT_LONG;
     		adressierung();
     		return;
     		}
		if	((mode == 0) && (opmode == 7) && is30)
			return;	/* EXTB.L */
          if   (opmode & 4) {
               if ( (opmode == 6)  || (opmode == 7) ) /* CHK / LEA */
                  adressierung();
               }
          else {
               if  (opmode >= 4) return;
               switch (reg1) {
                 case  5:
                 case  3: format = 1;  /* move.w ea,sr */
                 case  0:
                 case  2: if   (opmode <= 2) {
                               format = opmode;
                               }
                          adressierung();
                          break;
                 case  1: if  (opmode < 3) {   /* CLR */
                              format = opmode;
                              adressierung();
                              }
                          else if	((opmode ==3) && is30)
                          		{		/* MOVE CCR,<ea> */
                          		format = FMT_WORD;
                          		adressierung();
                          		}
                          break;
                 case  4:
                 case  6:
					if	(opmode == 0)
						{
						if	((mode == 1) && (reg1 == 4) && is30)
							{	/* LINK.L */
							getcode();
							getcode();
							return;
							}
							if	(reg1 !=6)
								adressierung();
						}
					else {
						if   (opmode == 1)
							{	/* PEA */
							if	( (reg1 != 6) && (mode != 0) )
								adressierung();
							}
						else	{
							if	(mode != 0)
								{
								format = (opmode == 2) ? 1 : 2;
								/*  opmode == 2  => .w */
								/*  sonst        => .l */
								getcode();
								adressierung();  /* movem */
								}
						 	}
                               }
                          break;
                 case  7: if  (opmode > 1)          /* JMP,JSR */
                              adressierung();
                          break;
                 }
               }
          }
}


/* Bearbeitet DBcc, Scc, ADDQ und SUBQ */
void decode5(void)
{
     reg    = befehl & 7;
     mode   = (befehl >> 3) & 7;
     format = (befehl >> 6) & 7;
	if	(is30 && (mode == 7) && (reg >=2) && (reg <= 4))	/* Trapcc */
		{
		if	(reg == 4)
			return;
		format = (reg == 3) ? FMT_LONG : FMT_WORD;
		mode = MOD_SPEC;
		reg = REG_IMME;
		adressierung();
		return;
		}

     if    ( (format == 3) || (format == 7) ) {
          if  (mode == 1) {     /* DBcc */
              getcode();
              write_pcrel();
              }
          else adressierung();               /* Scc */
          }
     else {                                  /* Subq, Addq */
          format &= 3;
          adressierung();
          }
}

/* Bearbeitet alle relativen Sprungbefehle */
void branch(void)
{
	if	(is30 && ((befehl & 0xff) == 0xff))
		{	/* long branch (68030) */
		getcode();
		getcode();
		write_pcrel_long();
		return;
		}

	if	(befehl & 255)				/* short branch */
		write_pcrel_short();
	else {						/* long Branch */
		getcode();
		write_pcrel();
		}
}


/* Bearbeitet DIVS, DIVU, MULS, MULU, AND, OR, EXG, ABCD und SBCD */

void decode8C(void)
{
     zuweisung();
	if	(((befehl & 0xf000) == 0x8000) &&
		 is30 && (mode <= 1) && ((opmode == 5) || opmode == 6))
		{	/* PACK,UNPK */
		getcode();
		return;
		}
     if   ((opmode & 3) == 3) { /* DIVS,DIVU,MULS,MULU */
          format = 1;   /* .w */
          adressierung();
          }
     else {
          if  ( (opmode <= 6) && (opmode != 3) ) {
              format = opmode & 3;
              adressierung();
              }
          }
}


/* Bearbeitet ADD, ADDA, ADDX, SUB, SUBA und SUBX */
void addsub(void)
{
     zuweisung();
     if   ((opmode & 3) == 3) {      /* ADDA,SUBA */
          format = (opmode & 4) ? 2 : 1;    /* .l  bzw. .w */
          adressierung();
          }
     else {                        /* ADD,ADDX,SUB,SUBX */
          if  (mode > 1) {         /* ADD, SUB */
              format = opmode & 3;
              adressierung();
              }
          }
}


/* Bearbeitet CMP, CMPA, CMPM und EOR */
void decodeB(void)
{
     zuweisung();
     format = opmode & 3;
     switch (opmode) {
       case 0:
       case 1:
       case 2: adressierung();
               break;
       case 3:
       case 7: format = (opmode == 3) ? 1 : 2; /* .w  bzw.  .l */
               adressierung();
               break;
       case 4:
       case 5:
       case 6: if  (mode != 1)
                    adressierung();      /* EOR */
               break;
       }
}


/* Bearbeitet alle Schiebe- und Rotationsbefehle */
void shiftrot(void)
{
	if	(((befehl & 0x8c0) == 0x8c0) && is30)	/* Bit field */
		{
		zuweisung();
		getcode();
		if	(code[cindex] & 0x8000)
			return;
		adressierung();
		return;
		}

     reg    = befehl & 7;
     mode   = (befehl >> 3) & 7;
     format = (befehl >> 6) & 3;
     if (format > 2)
        adressierung();
}


/***************************************************
* Bearbeitet alle Coprozessorbefehle (Line-F)
***************************************************/

void copro(void)
{
	int c;
	int fc,d,is_ea;


	if	(!is30)
		return;
	zuweisung();
	if	((opmode == 0) && (reg1 == 0))		/* PFLUSH */
		{
		getcode();
		c = code[cindex];
		if	((c & 0xf600) != 0x3000)
			return;
		d = c & 7;
		c >>= 3;
		fc = c & 3;
		c >>= 8;
		is_ea = c & 1;
		if	((fc == 3) ||
			 (fc == 0 && d > 1) ||
			 (!is_ea && (mode != 0 || reg != 0))
			)
			return;
		if	(is_ea)
			adressierung();
		return;
		}

	return;
}


void decode(void)
{
	register int nibble;
	register long befehlsadresse;


	befehlsadresse = adr;
	cindex = -1;
	getcode();
	befehl = code[0];

	if	(befehlsadresse == 0L &&
		 stk_len != 0L &&
		 (befehl & 0xff00) == 0x6000)
		{
		isturbo = TRUE;
		endcopyr = (befehl & 0xff) + 2L;
		}

	/* Reloziertes Langwort oder die Stackgrîûe von Turbo */
	if	(isturbo && befehlsadresse == 2L)
		{
		getcode();
		return;
		}

	if	(isturbo && befehlsadresse > 4 && befehlsadresse < endcopyr)
		return;

    nibble = (befehl >> 12) & 15;
    switch(nibble) {
      case  0: decode0(); break;  /* BCHG,BCLR,BSET,BTST,MOVEP
                        00,ORI
                        02,ANDI
                        04,SUBI
                        06,ADDI
                        0A,EORI
                        0C,CMPI  */
      case  1:                           /* .b */
      case  2:                           /* .l */
      case  3: move(nibble); break;      /* .w */
      case  4: decode4(); break;         /* CHK,LEA,MOVEM
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
      case  5: decode5(); break;    /* ADDQ,DBcc,Scc,SUBQ */
      case  6: branch(); break;     /* Bcc,BRA,BSR */
      case  7:                      /* MOVEQ */
      case 10: break;               /* Line-A */
      case  8:                      /* DIVS,DIVU,OR,SBCD */
      case 12: decode8C(); break;   /* ABCD,AND,EXG,MULS,MULU */
      case  9:                      /* SUB,SUBX */
      case 13: addsub(); break;     /* ADD/ADDX */
      case 11: decodeB(); break;    /* CMP,CMPM,EOR */
      case 14: shiftrot(); break;   /* ASL,ASR,LSL,LSR,ROL,ROR,ROXL,ROXR */
      case 15: copro(); break;	 /* PMMU,FP */
      }
}
