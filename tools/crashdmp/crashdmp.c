/*******************************************************************
*
*                          CRASHDMP		14.7.87
*                          ========
*
*					  letzte énderung:	3.12.88
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


#define P_COOKIES	((long *) 0x5a0)
#define proc_lives	((long *) 0x380L)
#define PROC_MAGIC	0x12345678L
#define proc_regs	((long *) 0x384L)
#define proc_pc	((long *) 0x3c4L)
#define proc_usp	((long *) 0x3c8L)
#define proc_stk	((int  *) 0x3ccL)

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
#define EN_COPROT	13	/* 68030 */
#define EN_FORMAT	14	/* 68030 */
#define EN_TRAP0	32
#define EN_TRAP15	47
#define EN_MMUCNF	56	/* 68030 */



#define FALSE             0
#define TRUE              1
#define EOS               '\0'
#define CRLF              "\r\n"


char ausgabe[] = "  XX = 00000000";

long get_cookie( long typ );
void setint(char *adresse, unsigned int wert);
void setlong(char *adresse, unsigned long wert);
void print_sr(int  st);
void print_pc(long pc);
void print_op(int  op);
void print_ad(long ad);
void print_xt(int  xt);
int  cpu = 0;

void main()
{
              long usp;
     register int  i;
     register unsigned char c;
              char *fehler;



     usp = Super(0L);						/* Supervisormodus */
     cpu = (int) get_cookie('_CPU');

     if   (*proc_lives != PROC_MAGIC)
     	{
     	Super((int *) usp);					/* Usermodus */
     	Pterm0();
     	}

	/* Fehlertyp ausgeben */
	/* ------------------ */

     c = *((unsigned char *) proc_pc);			/* Fehlernummer */
     if	(c >= EN_TRAP0 && c <= EN_TRAP15)
     	{
     	fehler = "Trap #$0";
     	fehler[7] = c - EN_TRAP0 + '0';
     	if	(fehler[7] > '9')
     		fehler[7] += 'a'-'9';
     	}
     else	{
     	switch (c) {
      		case  EN_BUS:		fehler = "Busfehler"   ; break;
      		case  EN_ADDR: 	fehler = "Adressfehler"; break;
	          case  EN_ILLEGAL:	fehler = "Illegal"     ; break;
	          case  EN_DIV0: 	fehler = "Div. durch 0"; break;
	          case  EN_CHK:		fehler = "CHK"         ; break;
	          case  EN_TRAPV: 	fehler = "TRAPV"       ; break;
	          case  EN_PRIV:		fehler = "Priv. Befehl"; break;
	          case  EN_TRACE:	fehler = "TRACE"       ; break;
	          case  EN_LINEA:	fehler = "Line - A"    ; break;
	          case  EN_LINEF:	fehler = "Line - F"    ; break;
			case  EN_COPROT:	fehler = "Koprozessor-Protokoll"; break;
			case	 EN_FORMAT:	fehler = "Format";break;
			case  EN_MMUCNF:	fehler = "MMU-Konfiguration"; break;
	          default: 			fehler = "        ";
	                    		setlong(fehler, c)	   ;	break;
      		}
      	}
     Cconws("Fehler : ");
     Cconws(fehler);
     Cconws(CRLF);
     Cconws(CRLF);

	/* Register ausgeben */
	/* ----------------- */

	for	(i = 0; i < 8; i++)
		{
          ausgabe[3] = '0' + (char) i;
          ausgabe[2] = 'd';
          setlong(ausgabe+7, proc_regs[i]);
          Cconws(ausgabe);
          Cconws("                    ");
          ausgabe[2] = 'a';
          setlong(ausgabe+7, proc_regs[i+8]);
          if	(i < 7)
          	Cconws(ausgabe);
          else	{
          	Cconws(" ssp");
          	Cconws(ausgabe+4);
          	}
          Cconws(CRLF);
		}

	/* USP ausgeben */
	/* ------------ */

     Cconws("                                    usp");
     setlong(ausgabe+7, *proc_usp);
     Cconws(ausgabe+4);
     Cconws(CRLF);
     Cconws(CRLF);

	if	(c == EN_BUS || c == EN_ADDR)
		{
		if	(cpu > 0)
			{
			print_pc(* ((long *) (proc_stk+1)) );
			print_sr(proc_stk[0]);
			print_ad(* ((long *) (proc_stk+8)) );
			print_xt(proc_stk[5]);
			}
		else	{
			print_pc(* ((long *) (proc_stk+5)) );
			print_sr(proc_stk[4]);
			print_ad(* ((long *) (proc_stk+1)) );
			print_op(proc_stk[3]);
			print_xt(proc_stk[0]);
			}
		}
	else	{
		print_pc(* ((long *) (proc_stk+1)) );
		print_sr(proc_stk[1]);
		}

	/* Stack ausgeben */
	/* -------------- */

	ausgabe[11] = '\0';
	Cconws("\r\nStack:\r\n");
	for	(i = 0; i < 16; i++)
		{
          ausgabe[3] = '0' + (char) i%10;
          ausgabe[2] = '0' + (char) i/10;
          ausgabe[1] = 's';
          setint(ausgabe+7, proc_stk[i]);
          Cconws(ausgabe);
          Cconws((i % 2) ? CRLF : "   ");
		}

     Super((int *) usp);						/* Usermodus */
     Pterm0();
}


/**************************************************************
*
* Rechnet Wort in <len> - stellige Hex- Zahl um und gibt die
* Anfangsadresse des Strings zurÅck.
*
**************************************************************/

void setint(char *adresse, unsigned int wert)
{
     register int  i,j;


	for	(i = 0; i < 4; i++)
		{
		j      = (int) (wert & 15);     /* 4 Bit fÅr Hex- Ziffer isolieren */
		wert >>= 4;
		adresse[4-1-i] =  (j < 10) ? ('0'+(char) j) : ('a'+(char) (j-10));
		}
}


/**************************************************************
*
* Rechnet Langwort in <len> - stellige Hex- Zahl um und gibt die
* Anfangsadresse des Strings zurÅck.
*
**************************************************************/

void setlong(char *adresse, unsigned long wert)
{
     register int  i,j;


	for	(i = 0; i < 8; i++)
		{
		j      = (int) (wert & 15);     /* 4 Bit fÅr Hex- Ziffer isolieren */
		wert >>= 4;
		adresse[8-1-i] =  (j < 10) ? ('0'+(char) j) : ('a'+(char) (j-10));
		}
}


/**************************************************************
*
* Gibt den Inhalt von <st> aus, als Prozessor - Status dekodiert
*
**************************************************************/

void print_sr(int st)
{
	char *s;



	Cconws("SR bei Auftreten des Fehlers: ");
     if   (st < 0)
          Cconws(" TR");
     if   (st & (1 << 13))
          Cconws(" SUP");
     if   (st & (1 << 4))
          Cconws(" EXT");
     if   (st & (1 << 3))
          Cconws(" NEG");
     if   (st & (1 << 2))
          Cconws(" ZER");
     if   (st & (1 << 1))
          Cconws(" OVF");
     if   (st & 1)
          Cconws(" CRY");
     s = " INT =  \r\n";
     s[7] = '0' + (char) ( (st >> 8) & 7);
     Cconws(s);
}


/**************************************************************
*
* Gibt den Inhalt des PC aus.
*
**************************************************************/

void print_pc(long pc)
{
	Cconws("PC bei Auftreten des Fehlers:  ");
     setlong(ausgabe+7, pc);
     Cconws(ausgabe+7);
     Cconws(CRLF);
}


/**************************************************************
*
* Gibt Opcode als Hexzahl aus.
*
**************************************************************/

void print_op(int op)
{
	Cconws("Fehlerauslîsender Opcode:      ");
	setlong(ausgabe+7, (long) op);
	Cconws(ausgabe+7+4);
	Cconws(CRLF);
}


/**************************************************************
*
* Dekodiert Prozessorinternes Statuswort (FC0,FC1,FC2,RW)
*
**************************************************************/

void print_xt(int xt)
{
	static char *status[] = { "unbestimmt",
						 "Usermodus Datenzugriff",
						 "Usermodus Programm",
						 "unbestimmt",
						 "unbestimmt",
						 "Supervisor Datenzugriff",
						 "Supervisor Programm",
						 "InterruptbestÑtigung" };


	Cconws("Prozessorstatus:               ");
	Cconws(status[xt & 7]);
	Cconws((xt & 16) ? ", Lesen \r\n" : ", Schreiben\r\n");
}


/**************************************************************
*
* Gibt fehlerhafte Adresse aus.
*
**************************************************************/

void print_ad(long ad)
{
	Cconws("Fehler bei Zugriff auf:        ");
     setlong(ausgabe+7, ad);
     Cconws(ausgabe+7);
     Cconws(CRLF);
}

/*************************************************************
*
* Cookie holen
*
*************************************************************/

long get_cookie( long typ )
{
	register unsigned long *p_cookies;

	p_cookies = (unsigned long *) (* P_COOKIES);
	while(p_cookies && *p_cookies)
		{
		if	(*p_cookies == typ)
			{
			p_cookies++;
			return(*p_cookies);
			}
		p_cookies += 2;
		}
	return(0L);
}