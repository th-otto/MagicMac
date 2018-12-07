/*******************************************************************
*
*                          CRASHDMP		14.7.87
*                          ========
*
*					  letzte Aenderung:	3.12.88
*
*
* Zweck:  Die Daten der letzten Exception (Bomben) dekodieren und
*		lesbar nach stdout schreiben.
*
* Syntax: CRASHDMP
*
*******************************************************************/


#include <tos.h>
#include <stddef.h>


#define P_COOKIES	((unsigned long *) 0x5a0)
#define proc_lives	((unsigned long *) 0x380L)
#define PROC_MAGIC	0x12345678L
#define proc_regs	((unsigned long *) 0x384L)
#define proc_pc		((unsigned long *) 0x3c4L)
#define proc_usp	((unsigned long *) 0x3c8L)
#define proc_stk	((unsigned short *) 0x3ccL)
#define proc_bp		((unsigned long *) 0x3ecL)

#define EN_BUS		2
#define EN_ADDR	3
#define EN_ILLEGAL	4
#define EN_DIV0	5
#define EN_CHK		6
#define EN_TRAPV	7
#define EN_PRIV	8
#define EN_TRACE	9
#define EN_LINEA	10
#define EN_LINEF	11
#define EN_COPROT	13					/* 68030 */
#define EN_FORMAT	14					/* 68030 */
#define EN_TRAP0	32
#define EN_TRAP15	47
#define EN_MMUCNF	56					/* 68030 */



#define FALSE             0
#define TRUE              1
#define EOS               '\0'
#define CRLF              "\r\n"


static char ausgabe[] = "  XX = 00000000";

static short cpu = 0;

/**************************************************************
*
* Rechnet Wort in <len> - stellige Hex- Zahl um und gibt die
* Anfangsadresse des Strings zurueck.
*
**************************************************************/

static void setint(char *adresse, unsigned short wert)
{
	register int i, j;

	for (i = 0; i < 4; i++)
	{
		j = (int) (wert & 15);			/* 4 Bit fuer Hex- Ziffer isolieren */
		wert >>= 4;
		adresse[4 - 1 - i] = (j < 10) ? ('0' + (char) j) : ('a' + (char) (j - 10));
	}
}



/**************************************************************
*
* Rechnet Langwort in <len> - stellige Hex- Zahl um und gibt die
* Anfangsadresse des Strings zurueck.
*
**************************************************************/

static void setlong(char *adresse, unsigned long wert)
{
	register int i, j;

	for (i = 0; i < 8; i++)
	{
		j = (int) (wert & 15);			/* 4 Bit fuer Hex- Ziffer isolieren */
		wert >>= 4;
		adresse[8 - 1 - i] = (j < 10) ? ('0' + (char) j) : ('a' + (char) (j - 10));
	}
}




/**************************************************************
*
* Gibt den Inhalt des PC aus.
*
**************************************************************/

static void print_pc(unsigned long pc)
{
	Cconws("PC on exception:               ");
	setlong(ausgabe + 7, pc);
	Cconws(ausgabe + 7);
	Cconws(CRLF);
}


/**************************************************************
*
* Prints the value the BASEPAGE (MagiC extension)
*
**************************************************************/

static void print_bp(unsigned long bp)
{
	Cconws("BP on exception:               ");
	setlong(ausgabe + 7, bp);
	Cconws(ausgabe + 7);
	Cconws(CRLF);
}


/**************************************************************
*
* Gibt Opcode als Hexzahl aus.
*
**************************************************************/

static void print_op(unsigned short op)
{
	Cconws("Opcode causing exception:      ");
	setlong(ausgabe + 7, op);
	Cconws(ausgabe + 7 + 4);
	Cconws(CRLF);
}


/**************************************************************
*
* Dekodiert Prozessorinternes Statuswort (FC0,FC1,FC2,RW)
*
**************************************************************/

static void print_xt(unsigned short xt, unsigned short rw)
{
	static const char *const status[] = {
		"indetermined",
		"Usermode data",
		"Usermode program",
		"indetermined",
		"indetermined",
		"Supervisor data",
		"Supervisor program",
		"Interrupt acknowledge"
	};

	Cconws("Prozessor state:               ");
	Cconws(status[xt & 7]);
	Cconws(xt & rw ? ", Read \r\n" : ", Write\r\n");
}


/**************************************************************
*
* Gibt den Inhalt von <st> aus, als Prozessor - Status dekodiert
*
**************************************************************/

static void print_sr(unsigned short st)
{
	char *s;

	Cconws("SR on exception:              ");
	if (st & (1 << 15))
		Cconws(" TR");
	if (st & (1 << 13))
		Cconws(" SUP");
	if (st & (1 << 4))
		Cconws(" EXT");
	if (st & (1 << 3))
		Cconws(" NEG");
	if (st & (1 << 2))
		Cconws(" ZER");
	if (st & (1 << 1))
		Cconws(" OVF");
	if (st & 1)
		Cconws(" CRY");
	s = " INT =  \r\n";
	s[7] = '0' + (char) ((st >> 8) & 7);
	Cconws(s);
}


/**************************************************************
*
* Gibt fehlerhafte Adresse aus.
*
**************************************************************/

static void print_ad(unsigned long ad)
{
	Cconws("Error while accessing address: ");
	setlong(ausgabe + 7, ad);
	Cconws(ausgabe + 7);
	Cconws(CRLF);
}

/*************************************************************
*
* Cookie holen
*
*************************************************************/

static long get_cookie(unsigned long typ)
{
	unsigned long *p_cookies;

	p_cookies = (unsigned long *) (*P_COOKIES);
	while (p_cookies && *p_cookies)
	{
		if (*p_cookies == typ)
		{
			p_cookies++;
			return *p_cookies;
		}
		p_cookies += 2;
	}
	return 0;
}


int main(void)
{
	long usp;
	register int i;
	register unsigned char c;
	char *fehler;

	usp = Super(0L);					/* Supervisormodus */
	cpu = (short) get_cookie(0x5F435055UL); /* '_CPU' */

	if (*proc_lives != PROC_MAGIC)
	{
		Super((void *) usp);			/* Usermodus */
		return 0;
	}

	/* Fehlertyp ausgeben */
	/* ------------------ */

	c = *((unsigned char *) proc_pc);	/* Fehlernummer */
	if (c >= EN_TRAP0 && c <= EN_TRAP15)
	{
		fehler = "Trap #$0";
		fehler[7] = c - EN_TRAP0 + '0';
		if (fehler[7] > '9')
			fehler[7] += 'a' - '9';
	} else
	{
		switch (c)
		{
		case EN_BUS:
			fehler = "bus error";
			break;
		case EN_ADDR:
			fehler = "address error";
			break;
		case EN_ILLEGAL:
			fehler = "illegal";
			break;
		case EN_DIV0:
			fehler = "div. by 0";
			break;
		case EN_CHK:
			fehler = "CHK";
			break;
		case EN_TRAPV:
			fehler = "TRAPV";
			break;
		case EN_PRIV:
			fehler = "privilege violation";
			break;
		case EN_TRACE:
			fehler = "TRACE";
			break;
		case EN_LINEA:
			fehler = "Line - A";
			break;
		case EN_LINEF:
			fehler = "Line - F";
			break;
		case EN_COPROT:
			fehler = "Coprozessor protocol";
			break;
		case EN_FORMAT:
			fehler = "Format";
			break;
		case EN_MMUCNF:
			fehler = "MMU configuration";
			break;
		default:
			fehler = "        ";
			setlong(fehler, c);
			break;
		}
	}
	Cconws("Error : ");
	Cconws(fehler);
	Cconws(CRLF);
	Cconws(CRLF);

	/* Register ausgeben */
	/* ----------------- */

	for (i = 0; i < 8; i++)
	{
		ausgabe[3] = '0' + (char) i;
		ausgabe[2] = 'd';
		setlong(ausgabe + 7, proc_regs[i]);
		Cconws(ausgabe);
		Cconws("                    ");
		ausgabe[2] = 'a';
		setlong(ausgabe + 7, proc_regs[i + 8]);
		if (i < 7)
		{
			Cconws(ausgabe);
		} else
		{
			Cconws(" ssp");
			Cconws(ausgabe + 4);
		}
		Cconws(CRLF);
	}

	/* USP ausgeben */
	/* ------------ */

	Cconws("                                    usp");
	setlong(ausgabe + 7, *proc_usp);
	Cconws(ausgabe + 4);
	Cconws(CRLF);
	Cconws(CRLF);

	if (c == EN_BUS || c == EN_ADDR)
	{
		if (cpu > 0)
		{
			unsigned short format = (proc_stk[3] & 0xf000) >> 12;
			
			print_pc(*((unsigned long *) (proc_stk + 1)));
			print_sr(proc_stk[0]);
			switch (format)
			{
			case 8: /* 68010 access error frame */
				print_ad(*((unsigned long *) (proc_stk + 5)));
				print_xt(proc_stk[4], 0x800);
				break;
			case 2: /* address error */
			case 3:
				print_ad(*((unsigned long *) (proc_stk + 4)));
				break;
			case 7: /* 68040 access error */
				print_ad(*((unsigned long *) (proc_stk + 4)));
				print_xt(proc_stk[6], 0x100);
				break;
			case 4: /* 68060 access error */
				print_ad(*((unsigned long *) (proc_stk + 4)));
				print_xt(proc_stk[6], 0x100);
				break;
			default: /* hopefully format 11: 68020/30 access error */
				print_ad(*((unsigned long *) (proc_stk + 8)));
				print_xt(proc_stk[5], 0x40);
				break;
			}
		} else
		{
			print_pc(*((unsigned long *) (proc_stk + 5)));
			print_sr(proc_stk[4]);
			print_ad(*((unsigned long *) (proc_stk + 1)));
			print_op(proc_stk[3]);
			print_xt(proc_stk[0], 0x10);
		}
	} else
	{
		print_pc(*((unsigned long *) (proc_stk + 1)));
		print_sr(proc_stk[0]);
	}

	if (*proc_bp)
		print_bp(*proc_bp);

	/* Stack ausgeben */
	/* -------------- */

	ausgabe[11] = '\0';
	Cconws("\r\nStack:\r\n");
	for (i = 0; i < 16; i++)
	{
		ausgabe[3] = '0' + (char) i % 10;
		ausgabe[2] = '0' + (char) i / 10;
		ausgabe[1] = 's';
		setint(ausgabe + 7, proc_stk[i]);
		Cconws(ausgabe);
		Cconws((i % 2) ? CRLF : "   ");
	}

	Super((void *) usp);				/* Usermodus */
	return 0;
}
