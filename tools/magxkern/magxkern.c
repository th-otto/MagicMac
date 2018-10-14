/*
*
* Gibt MagiC-Kernel-Informationen aus
*
*/

#include <stdio.h>
#include <string.h>
#include <mgx_dos.h>


#define	INT16	int
#define	INT32	long
#define	KER_GETINFO	0x0100
#define	SC_DOSVARS	2


/*   Struktur APPLICATION                                                  */
/***************************************************************************/

typedef struct {
     INT32     ap_next;       /* 0x00: Verkettungszeiger (APPL *)          */
     int       ap_id;         /* 0x04: Application-Id                      */
     int       ap_parent;     /* ap_id der parent- Applikation             */
     int       ap_parent2;    /* -1 oder ap_id des vt52  				*/
     int		ap_type;		/* 0=Main Thread/1=Thread/2=Signal			*/
	long		ap_oldsigmask;	/* Alte Signalmaske (fÅr Signal-Handler)	*/
	INT32	ap_sigthr;	/* Haupt-Thread: Zeiger auf aktiven Signalhandler	*/
						/* Signalhandler: Zeiger auf vorherigen oder NULL */
						/* (APPL *) */
	int		ap_srchflg;	/* fÅr appl_search						*/
     INT32     ap_menutree;   /* 0x06: MenÅleiste (OBJECT *)               */
	INT32	ap_attached;	/* 0x0a: NULL oder Liste fÅr menu_attach() (POPUP *) */
     INT32     ap_desktree;   /* 0x0e: Desktop- Hintergrundbaum (OBJECT *) */
     int       ap_1stob;      /* 0x10:  dazu erstes Objekt                 */
     char      ap_dummy1[2];  /* 0x14: zwei Leerzeichen vor ap_name        */
     char      ap_name[8];    /* 0x16: Applikationsname                    */
     char      ap_dummy2[2];  /* 0x1e: Leerstelle und ggf. Ausblendzeichen */
     char      ap_dummy3;     /* 0x20: Nullbyte fÅr EOS                    */
     char      ap_status;     /* 0x21: 0=ready 1=waiting 2=susp 3=zombie   */
     int       ap_hbits;      /* 0x22: eingetroffene EVENTs                */
     int       ap_rbits;      /* 0x24: erwartete EVENTs                    */
     INT32     ap_evparm;     /* 0x26: fÅr evnt_mesag/etv_timer (EVPARM *) */
     long      *ap_nxttim;    /* 0x2a: nÑchster Timerwert                  */
     long      ap_ms;         /* 0x2e: fÅr evnt_timer                      */
	INT32	ap_nxtalrm;	/* NÑchste auf Alarm wartende APP */
	INT32	ap_alrmms;	/* Alarm */
	INT16	ap_isalarm;	/* Flag */
     long      ap_nxtsem;     /* 0x32: nÑchster blockierter                */
     INT32     ap_semaph;     /* 0x36: fÅr wind_update/evnt_sem (SEMAPHORE *) */
     int       ap_unselcnt;   /* LÑnge der Tabelle ap_unselx               */
     long      *ap_unselx;    /* Tabelle fÅr evnt_(m)IO                    */
     INT32     ap_evbut;      /*       fÅr evnt_button (EVBUTTON)          */
     INT32	ap_mgrect1;    /*       fÅr evnt_mouse (MGRECT *)           */
     INT32     ap_mgrect2;    /*       fÅr evnt_mouse (MGRECT *)           */
     int       ap_kbbuf[8];   /*       Puffer fÅr 8 Tasten                 */
     int       ap_kbhead;     /*       NÑchstes zu lesendes Zeichen        */
     int       ap_kbtail;     /*       NÑchstes zu schreibendes Zeichen    */
     int       ap_kbcnt;      /*       Anzahl Zeichen im Puffer            */
     int       ap_len;        /*       Message- PufferlÑnge                */
     char      ap_buf[0x300];   /*       Message- Puffer (768 Bytes)         */
     int       ap_critic;     /* ZÑhler fÅr "kritische Phase"              */
	char		ap_crit_act;	/* Bit 0: killed						*/
						/* Bit 1: stopped						*/
						/* Bit 2: Signale testen					*/
	char		ap_stpsig;	/* Flag "durch Signal gestoppt"			*/
     long      ap_sigfreeze;  /* Signalhandler fÅr SIGFREEZE               */
     int       ap_recogn;     /* Bit 0: versteht AP_TERM                   */
	long		ap_flags;		/* Bit 0: will keinen prop. AES-Zeichensatz	*/
     int       ap_doex;       /*        !=0, wenn starten                  */
     int       ap_isgr;       /*        im Grafikmodus starten             */
     int       ap_wasgr;      /*        aktueller Bildschirmmodus          */
     int       ap_isover;     /*        =0:sofort,=1:normal,=100:parallel  */
	INT32	ap_ldpd;		/* PD des Loader-Prozesses */
     char      *ap_env;       /* Environment oder NULL                     */
     char      *ap_xtail;     /* Erw. Kommandozeile (> 128 Bytes) od. NULL */
     char		*ap_thr_usp;	/* usp fÅr Threads						*/
     long      ap_memlimit;
     long      ap_nice;
     char      ap_cmd[0x80];  /*        Programmpfad                       */
     char      ap_tail[0x80]; /*        Programmparameter                  */

     int       ap_mhidecnt;   /* lokaler Maus-Hide-Counter                 */
     int       ap_svd_mouse[37];   /* x/y/planes/bg/fg/msk[32]/moff_cnt    */
     int       ap_prv_mouse[37];
     int       ap_act_mouse[37];

     long      ap_ssp;        /* 0x262: geretteter ssp (a7)                */
     long      ap_pd;         /* 0x266: geretteter PD                      */
     long      ap_etvterm;    /* 0x26a: geretteter etv_term                */
     long      ap_stkchk;     /* magisches Wort fÅr StackÅberprÅfung       */
     char      ap_stack[1]; /* 0x26e: Stack, verschieden groû            */
} APPL;

struct mgx_procdata
{
	INT32	pr_magic;			/* magischer Wert, Ñhnlich wie bei MiNT		*/
	INT16	pr_ruid;			/* "real user ID" */
	INT16	pr_rgid;			/* "real group ID" */
	INT16	pr_euid;			/* "effective user ID" */
	INT16	pr_egid;			/* "effective group ID" */
	INT16	pr_suid;			/* "saved user ID" */
	INT16	pr_sgid;			/* "saved group ID" */
	INT16	pr_auid;			/* "audit user ID" */
	INT16	pr_pri;			/* "base process priority" (nur dummy) */
	INT32	pr_sigpending;		/* wartende Signale						*/
	INT32	pr_sigmask;		/* Signalmaske							*/
	char		pr_sigdata[32*10];
	INT32	pr_usrval;		/* "User"-Wert (ab 9/96)					*/
	INT32	pr_memlist;		/* Tabelle der "shared memory blocks"		*/
	char		pr_fname[128];		/* Pfad der zugehîrigen PRG-Datei			*/
	char		pr_cmdlin[128];	/* UrsprÅngliche Kommandozeile			*/
	INT16	pr_flags;			/* Bit 0: kein Eintrag in u:\proc			*/
							/* Bit 1: durch Pfork() erzeugt			*/
	char		pr_procname[10];	/* Prozeûname fÅr u:\proc\ ohne Ext.		*/
	INT16	pr_bconmap;		/* z.Zt. unbenutzt						*/
	char		pr_hndm6[6];		/* Handle -6: unbenutzt */
	char		pr_hndm5[6];		/* Handle -5: unbenutzt */
	char		pr_hndm4[6];		/* Handle -4: standardmÑûig NUL: */
	char		pr_hndm3[6];		/* Handle -3: standardmÑûig PRN: */
	char		pr_hndm2[6];		/* Handle -2: standardmÑûig AUX: */
	char		pr_hndm1[6];		/* Handle -1: standardmÑûig CON: */
	char		pr_handle[32*6];	/* Handles 0..31 */
};

struct mgx_pd
{
	INT32	p_lowtpa;		/* 0x00: Beginn TPA, des BP selbst           */
	INT32	p_hitpa;		/* 0x04: zeigt 1 Byte hinter TPA             */
	INT32	p_tbase;		/* 0x08: Beginn des TEXT - Segments          */
	INT32	p_tlen;		/* 0x0c: LÑnge  des TEXT - Segments          */
	INT32	p_dbase;		/* 0x10: Beginn des DATA - Segments          */
	INT32	p_dlen;		/* 0x14: LÑnge  des DATA - Segments          */
	INT32	p_bbase;		/* 0x18: Beginn des BSS  - Segments          */
	INT32	p_blen;		/* 0x1c: LÑnge  des BSS  - Segments          */
	INT32	p_dta;		/* 0x20: Aktueller DTA- Puffer               */
	INT32	p_parent;		/* 0x24: Zeiger auf BP des Parent            */
	INT16	p_procid;		/* 0x28: Prozeû- ID                          */
	INT16	p_status;		/* 0x2a: ab MagiC 5.04                       */
	INT32	p_env;		/* 0x2c: Zeiger auf Environment              */
	char		p_devx[6];	/* 0x30: std-Handle <=> phs. Handle          */
	char		p_flags;		/* 0x36: Bit 0: Pdomain (MiNT:1/TOS:0)		*/
	char		p_defdrv;		/* 0x37: Default- Laufwerk                   */
	char		p_res3[8];	/* 0x38: Terminierungskontext fÅr ACC        */
	char		p_drvx[32];	/* 0x40: Tabelle: Default-Path-Hdl.          */
	INT32	p_procdata;	/* 0x60: Zeiger auf PROCDATA				*/
	INT16	p_umask;		/* 0x64: umask fÅr Unix-Dateisysteme		*/
	INT16	p_procgroup;	/* 0x66: Prozeûgruppe (ab 6.10.96)			*/
	INT32	p_mem;		/* 0x68: soviel Speicher darf ich holen      */
	INT32	p_context;	/* 0x6c: unter MAGIX statt p_reg benutzt     */
	INT32	p_mflags;		/* 0x70: Bit 2: Malloc aus AltRAM erlaubt    */
	INT32	p_app;		/* 0x74: APPL, die den Prozeû gestartet	hat (main thread)	*/
	INT32	p_ssp;		/* 0x78: ssp bei Start des Prozesses		*/
	INT32	p_reg;		/* 0x7c: fÅr KompatibilitÑt mit TOS          */
	char		p_cmdlin[128];	/* 0x80: Kommandozeile                       */
};

struct mgx_dos_kernel_inf
{
 INT16	m_Version;		/* Versionsnummer (4) */
 INT32	fast_clrmem;
 INT32	toupper;
 INT32	_sprintf;
 INT32	act_pd;
 INT32	act_appl;
 INT32	keyb_app;
 INT32	pe_slice;
 INT32	pe_timer;
 INT32	appl_yield;
 INT32	appl_suspend;
 INT32	appl_begcritic;
 INT32	appl_endcritic;
 INT32	evnt_IO;
 INT32	evnt_mIO;
 INT32	evnt_emIO;
 INT32	appl_IOcomplete;
 INT32	evnt_sem;
 INT32	Pfree;
 INT16	FDSIZE;			/* LÑnge eines internen Speicherblocks */
 INT32	int_malloc;
 INT32	int_mfree;
 INT32	resv_intmem;
 INT32	diskchange;
 INT32	DMD_rdevinit;		/* ab 3.6.95 */
 INT32	proc_info;		/* ab 14.11.95 */
 INT32	ker_mxalloc;		/* ab 15.6.96 */
 INT32	ker_mfree;		/* ab 15.6.96 */
 INT32	ker_mshrink;		/* ab 15.6.96 */
};

struct mgx_xaes_appls
{
 INT32	dos_magic;		/* 'XAES'	*/
 INT32	act_appl;			/* APPL *	*/
 INT16	ap_pd_offs;		/* Offset fÅr ap_pd	*/
 INT16	appln;			/* Anzahl der APPLs */
 INT16	maxappln;			/* TabellenlÑnge */
 INT32	applx;			/* APPL *applx[16] */
};

struct mgx_dosvars
{
 INT32	res1;			/*   0: immer 0 */
 INT32	dos_time;			/*   4: Adresse des Zeitfeldes */
 INT32	dos_date;			/*   8: Adresse des Datumfeldes */
 INT32	res2;			/*  $c: immer 0 */
 INT32	res3;			/* $10: immer 0 */
 INT32	res4;			/* $14: immer 0 */
 INT32	act_pd;			/* $18: Laufendes Programm */
 INT32	res5;			/* $1c: Dateien */
 INT16	res6;			/* $20: immer 0 */
 INT32	dmdx;			/* $22: DMDs */
 INT32	imbx;			/* $26: interner DOS- Speicher */
 INT32	resv_intmem;		/* $2a: Adresse der Speichererweiterungsroutine */
 INT32	etv_critic;		/* $2e: Adresse des Event-Critic-Managers */
 INT32	err_to_str;		/* $32: Adresse der Fehler->Klartext Routine */
 INT32	xaes_appls;		/* $36: hier darf sich XAES einhÑngen */
 INT32	mem_root;			/* $3a: MAGIX- Speicherlisten */
 INT32	ur_pd;			/* $3e: Ur- Prozeû */
};

int main(void)
{
	long ret;
	struct mgx_dos_kernel_inf *ki;
	struct mgx_dosvars *dv;
	struct mgx_xaes_appls *xa;
	APPL *appl;
	struct mgx_pd *pd;
	struct mgx_procdata *pr;
	APPL **applx;
	register int i;
	char str[130];
	unsigned char n;
	char *s1,*s2;


/*
	appl = NULL;
	printf("offs ap_pd = 0x%08lx\n", &appl->ap_pd);
*/

	/* DOS-KERNEL */

	ret = Dcntl(KER_GETINFO, (char *) NULL, 0);
	if	(ret < 0)
		return((int) ret);
	ki = (struct mgx_dos_kernel_inf *) ret;

	printf("DOS-Kernel:\n");
	printf(" Version = %d\n", ki->m_Version);
	printf(" act_pd = 0x%08lx\n", ki->act_pd);
	printf("\n");

	/* DOSVARS */

	ret = Sconfig(SC_DOSVARS, 0);
	if	(ret < 0)
		return((int) ret);
	dv = (struct mgx_dosvars *) ret;

	xa = *((struct mgx_xaes_appls **) dv->xaes_appls);
	applx = (APPL **) &(xa->applx);

	printf("XAES-Struktur fÅr DOS:\n");
	printf(" Magic = 0x%08lx\n", xa->dos_magic);
	printf(" act_appl = 0x%08lx\n", xa->act_appl);
	printf(" ap_pd_offs = 0x%04x\n", xa->ap_pd_offs);
	printf(" appln = %d\n", xa->appln);
	printf(" maxappln = %d\n", xa->maxappln);
	printf(" applx = 0x%08lx\n", xa->applx);
	printf("\n");

	/* APPLX */

	printf("Applikationen:\n");
	for	(i = 0; i < xa->appln; i++)
	{
		printf(" slot %d\n", i);
		appl = *applx++;
		if	(!appl)
			continue;		/* Slot ist leer */

		printf(" appl = 0x%08lx\n", appl);
		if	((INT32) appl & 0x80000000L)
		{
			printf(" eingefroren\n");
			appl = (APPL *) ((INT32) appl &= ~0x80000000L);
		}
		printf(" ap_id = %d\n", appl->ap_id);
		str[8] = '\0';
		memcpy(str, appl->ap_name, 8);
		printf(" ap_name = %s\n", str);
		printf(" ap_pd = 0x%08lx\n", appl->ap_pd);

		pd = (struct mgx_pd *) (appl->ap_pd);
		if	(pd)
			printf("\n");

		while(pd)
		{
			printf("  pd = 0x%08lx\n", pd);
			printf("  procid = %d\n", pd->p_procid);
			pr = (struct mgx_procdata *) pd->p_procdata;
			if	(pr)
			{
				s1 = (pr->pr_flags & 1) ? "(kein Eintrag in U:\PROC)" : "";
				s2 = (pr->pr_flags & 2) ? "(durch Pfork() erzeugt)" : "";
				printf("  pr_flags = 0x%04x %s %s\n", pr->pr_flags, s1, s2);
				printf("  pr_procname = %s\n", pr->pr_procname);
				printf("  pr_fname = %s\n", pr->pr_fname);
				n = pr->pr_cmdlin[0];
				if	(n > 127)
					n = 127;
				memcpy(str, pr->pr_cmdlin + 1, n);
				str[n] = '\0';
				printf("  pr_cmdlin = %s\n", str);
			}
			printf("\n");
			pd = (struct mgx_pd *) pd->p_parent;
		}

		printf("\n");
	}

	return(0);
}