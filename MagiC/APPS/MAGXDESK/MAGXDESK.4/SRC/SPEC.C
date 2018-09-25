/*********************************************************************
*
* Dieses Modul enth„lt TOS- Spezifisches
*
*********************************************************************/


#include <mgx_dos.h>
#include "k.h"
#include <vdi.h>
#include <string.h>


/*********************************************************************
*
* Merkt Zeiger auf Betriebssystemheader und die Betriebssystemversion.
* Muž bei Initialisierung von KAOSDESK aufgerufen werden.
* TOS 1.4- Versionen, die nicht vom 6.4.89 sind, werden als TOS 1.5
* angesehen.
* Aužerdem wird ein Zeiger auf den aktuellen Applikationsnamen
* gemerkt, da die Funktion menu_register(-1, name) unter GEM 2.x nicht
* mehr untersttzt wird.
*
*********************************************************************/

char *os_ver_s = "MagiC v__.__  vom __.__.____";
static AESVARS *aesvars;

void get_syshdr( void )
{
	aesvars = *((AESVARS **) (aes_global+11));
	if	(aesvars->magic2 != 'MAGX')
		Pterm(-1);
	inf_name[0] = *(aesvars->aes_bootdrv) + 'A';

	os_ver_s[ 7] = (((aesvars->version) >> 12)     ) + '0';
	os_ver_s[ 8] = (((aesvars->version) >> 8) & 0xf) +'0';
	os_ver_s[10] = (((aesvars->version) >> 4) & 0xf) +'0';
	os_ver_s[11] = (((aesvars->version)     ) & 0xf) +'0';

	if	(aesvars->release < 3)
		os_ver_s[12] = *("àáâ" + (aesvars->release));

	os_ver_s[18] = (((aesvars->date) >> 28)      ) + '0';
	os_ver_s[19] = (((aesvars->date) >> 24) & 0xf) + '0';
	os_ver_s[21] = (((aesvars->date) >> 20) & 0xf) + '0';
	os_ver_s[22] = (((aesvars->date) >> 16) & 0xf) + '0';
	os_ver_s[24] = (((aesvars->date) >> 12) & 0xf) + '0';
	os_ver_s[25] = (((aesvars->date) >>  8) & 0xf) + '0';
	os_ver_s[26] = (((aesvars->date) >>  4) & 0xf) + '0';
	os_ver_s[27] = (((aesvars->date)      ) & 0xf) + '0';
}


/****************************************************************
*
* Žndert die Aufl”sung
*
****************************************************************/

/*
int change_res(int dev, int txt)
{
	if	(!aesvars)
		return(0);
#if		COUNTRY==FRG
	if	(1 != form_alert(1, "[2][Aufl”sungswechsel ?][ OK | Abbruch ]"))
		return(0);
#elif	COUNTRY==USA
	if	(1 != form_alert(1, "[2][Change resolution ?][ OK | Cancel ]"))
		return(0);
#endif
	aesvars->chgres(dev, txt);
	return(1);
}
*/


/*********************************************************************
*
* Rechnet einen Alt-Tastencode in ASCII um.
*
*********************************************************************/

int alt_keycode_2_ascii(int keycode)
{
	return((int) xbios(39, 'AnKr', 1, keycode));
}


/*********************************************************************
*
* Ermittelt einen Cookie
*
*********************************************************************/

COOKIE *getcookie(long key)
{
	return((COOKIE *) xbios(39, 'AnKr', 4, key));
}


/*********************************************************************
*
* Untersucht den Bootsektor eines Mediums.
*
*********************************************************************/

long read_bootsec(int lw, long *ser, int *bps, int *spc,
						int *res,	int *nfats, int *ndirs, int *nsects,
						int *media, int *spf, int *spt, int *nsides,
						int *nhid, int *exec)
{
	long doserr;
	unsigned char *s;
	unsigned int  *sw;


	if	(NULL == (s = Malloc(512L)))
		return(ENSMEM);
	doserr = Rwabs(0, s, 1, 0, lw);
/*
	if	(lw == 0 || lw == 1)
		doserr = M_Floprd(s, NULL, lw, 1, 0, 0, 1);
	else doserr = Rwabs(0, s, 1, 0, lw);
*/
	if	(doserr == E_OK)
		{
		*ser    = s[10] + 256 * s[ 9] + 65536L * s[8];
		*bps    = s[11] + 256 * s[12];
		*spc    = s[13];
		*res    = s[14] + 256 * s[15];
		*nfats  = s[16];
		*ndirs  = s[17] + 256 * s[18];
		*nsects = s[19] + 256 * s[20];
		*media  = s[21];
		*spf	   = s[22] + 256 * s[23];
		*spt	   = s[24] + 256 * s[25];
		*nsides = s[26] + 256 * s[27];
		*nhid   = s[28] + 256 * s[29];
		*exec   = 0;
		for	(sw = (unsigned int *) s; (unsigned char *) sw < s+512; sw++)
			*exec += *sw;
		*exec = (*exec == 0x1234);
		}
	Mfree(s);
	return(doserr);
}


/*********************************************************************
*
* MAGXDESK zum Programmstart verlassen.
*
*********************************************************************/

static void *rsc_block;

long restart( void )
{
	extern   BASPAG *_BasPag;

	*(aesvars->shel_vector) = NULL;
	*((void **) (aes_global+7)) = rsc_block;
	rsc_block = NULL;
	return(Pexec(EXE_EXFR, "", _BasPag, NULL));
}
void res_exec( void )
{
	rsc_block = *((void **) (aes_global+7));
	*((void **) (aes_global+7)) = NULL;
	appl_exit();
	*(aesvars->shel_vector) = restart;
	Ptermres(-1L, 0);		/* allen Speicher behalten */
}
