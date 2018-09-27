/****************************************************************
*
* MGFORMAT
* ========
*
* Beginn der Programmierung:	2.6.93	(vorher: MAGXDESK)
* letzte Žnderung:		1.6.98
*
* Modul zum Formatieren und Kopieren von Disketten.
* Implementation wie zum MultiTOS beschrieben, MultiTOS sucht
*  eine Env-Variable DESKFMT, die einen Programmnamen enth„lt.
* Dieses wird aufgerufen mit:
*
* -f  A:		zum Formatieren
* -fh C:		zum "Formatieren" von Harddisks (nur MAGXDESK)
* -f A: B:	zum Kopieren von Disketten
*
****************************************************************/

#include <tos.h>
#include <aes.h>
#include <mt_aes.h>
#include <string.h>
#include <stdlib.h>
#include <tosdefs.h>
#include "mgformat.h"
#include "gemut_mt.h"
#include "toserror.h"
#include "globals.h"


#define MIN(a,b) ((a < b) ? a : b)
#define MAX(a,b) ((a > b) ? a : b)
#define ABS(X) ((X>0) ? X : -X)
#define VA_START 0x4711


enum actioncode {FORMAT, INIT, COPY, BOTH};

extern OBJECT *adr_format;
extern OBJECT *adr_cpydsk;
extern OBJECT *adr_fmtopt;
/* DIALOG-Strukturen */

DIALOG *d_cpydsk;
DIALOG *d_format;
DIALOG *d_fmtopt;

FMT_DEFAULTS prefs;

OBJECT *adr_iconified;

int	gl_hhbox, gl_hwbox, gl_hhchar, gl_hwchar;
GRECT scrg;
int	ap_id;
WORD global[15];


/****************************************************************
*
* Rechnet Koordinaten linear um. Der Wert <wert> wurde bei
* Bildschirmgr”že <old> abgespeichert, jetzt ist die
* Bildschirmgr”že <new>.
*
* Liegt das Fenster links aus dem Bildschirm heraus, wird
* nichts umgerechnet. Hier sollte aber sichergestellt werden,
* daž man an das Fenster noch herankommt, d.h.:
*	x+w > k > 0.
*
****************************************************************/

static void recalc(int *wert, int old, int new)
{
	unsigned long tmp;

	if	(*wert > 0)
		{
		tmp    = (unsigned long) *wert;
		tmp   *= new;
		tmp   /= old;
		*wert  = (int) tmp;
		}
}


/****************************************************************
*
* Lese INF-Datei
*
****************************************************************/

static char infpath[128];

void read_inf( void )
{
	char buf[512];
	long len;
	int hdl;
	char *s,*t;
	int oldwh[2];


	prefs.tmpdrv		= 0;
	prefs.sides		= 2;
	prefs.tracks		= 80;
	prefs.sectors		= 9;
	prefs.interlv		= 1;
	prefs.trkincr		= 2;
	prefs.sidincr		= 2;
	prefs.clustsize	= 2;

	s = getenv("HOME");
	if	(s)
		{
		strcpy(infpath, s);
		t = infpath+strlen(s);
		if	(t[-1] != '\\')
			*t++ = '\\';
		}
	else	t = infpath;
	strcpy(t, "MGFORMAT.INF");

	if	((s) || (shel_find(infpath)))
		{
		hdl = (int) Fopen(infpath, O_RDONLY);
		if	(hdl < 0)
			return;
		len = Fread(hdl, 511L, buf);
		Fclose(hdl);
		if	(len < E_OK)
			return;
		buf[len] = EOS;

		/* erste Zeile berlesen */

		for	(s = buf; (*s) && (*s != '\n'); s++)
			;

		if	(*s == '\n')
			s++;

		/* andere Zeilen auswerten */

		while(*s)
			{
			if	(!strncmp(s, "SCREENSIZE ", 11))
				{
				s += 11;
				scan_values(&s, 2, oldwh);
				goto weiter;
				}

			if	(!strncmp(s, "WINDOW FORMAT ", 14))
				{
				s += 14;
				scan_values(&s, 4, (int *) &prefs.format_win);
				}

			if	(!strncmp(s, "TMPDRV ", 7))
				{
				s += 7;
				prefs.tmpdrv = (*s++) - 'A';
				}

			if	(!strncmp(s, "SIDES ", 6))
				{
				s += 6;
				scan_values(&s, 1, &prefs.sides);
				}

			if	(!strncmp(s, "TRACKS ", 7))
				{
				s += 7;
				scan_values(&s, 1, &prefs.tracks);
				}

			if	(!strncmp(s, "SECTORS ", 8))
				{
				s += 8;
				scan_values(&s, 1, &prefs.sectors);
				}

			if	(!strncmp(s, "INTERLEAVE ", 11))
				{
				s += 11;
				scan_values(&s, 1, &prefs.interlv);
				}

			if	(!strncmp(s, "TRACK-INCREMENT ", 16))
				{
				s += 16;
				scan_values(&s, 1, &prefs.trkincr);
				}

			if	(!strncmp(s, "SIDE-INCREMENT ", 15))
				{
				s += 15;
				scan_values(&s, 1, &prefs.sidincr);
				}

			if	(!strncmp(s, "CLUSTERSIZE ", 12))
				{
				s += 12;
				scan_values(&s, 1, &prefs.clustsize);
				}

			weiter:

			while((*s) && (*s != '\n'))
				s++;

			if	(*s == '\n')
				s++;
			}


		if	(oldwh[0] != scrg.g_w)
			{
			recalc(&(prefs.format_win.g_x), oldwh[0], scrg.g_w);
			recalc(&(prefs.format_win.g_w), oldwh[0], scrg.g_w);
			}
		if	(oldwh[1] != scrg.g_h)
			{
			recalc(&(prefs.format_win.g_y), oldwh[1], scrg.g_h);
			recalc(&(prefs.format_win.g_h), oldwh[1], scrg.g_h);
			}
		prefs.format_win.g_x += scrg.g_x;
		prefs.format_win.g_y += scrg.g_y;
		}
}


/****************************************************************
*
* Schreibe Fensterposition aufl”sungsunabh„ngig in
* Zeichenkette.
*
****************************************************************/

static void print_winpos(char *s, GRECT *g, int n)
{
	g->g_x -= scrg.g_x;
	g->g_y -= scrg.g_y;
	print_values(s, n, (int *) g);
	g->g_x += scrg.g_x;
	g->g_y += scrg.g_y;
}


/****************************************************************
*
* Schreibe INF-Datei
*
****************************************************************/

void write_inf( void )
{
	int hdl;
	char buf[512];
	int scrwh[2];
	char tmpdrvs[2] = "@";



	if	(d_format)
		{
		prefs.format_win.g_x = adr_format->ob_x;
		prefs.format_win.g_y = adr_format->ob_y;
		}

	hdl = (int) Fcreate(infpath, 0);
	if	(hdl < 0)
		return;
	strcpy(buf, "[MGFORMAT Header V 1.0]\r\n"
					"SCREENSIZE ");
	scrwh[0] = scrg.g_w;
	scrwh[1] = scrg.g_h;
	print_values(buf+strlen(buf), 2, scrwh);

	strcat(buf, "\r\nWINDOW FORMAT ");
	print_winpos(buf + strlen(buf), &prefs.format_win, 4);

	tmpdrvs[0] = prefs.tmpdrv + 'A';
	strcat(buf, "\r\nTMPDRV ");
	strcat(buf, tmpdrvs);

	strcat(buf, "\r\nSIDES ");
	print_values(buf + strlen(buf), 1, &(prefs.sides));

	strcat(buf, "\r\nTRACKS ");
	print_values(buf + strlen(buf), 1, &(prefs.tracks));

	strcat(buf, "\r\nSECTORS ");
	print_values(buf + strlen(buf), 1, &(prefs.sectors));

	strcat(buf, "\r\nINTERLEAVE ");
	print_values(buf + strlen(buf), 1, &(prefs.interlv));

	strcat(buf, "\r\nTRACK-INCREMENT ");
	print_values(buf + strlen(buf), 1, &(prefs.trkincr));

	strcat(buf, "\r\nSIDE-INCREMENT ");
	print_values(buf + strlen(buf), 1, &(prefs.sidincr));

	strcat(buf, "\r\nCLUSTERSIZE ");
	print_values(buf + strlen(buf), 1, &(prefs.clustsize));

	Fwrite(hdl, strlen(buf), buf);
	Fclose(hdl);
}



/*************************************************/
/**************** HAUPTPROGRAMM ******************/
/*************************************************/

int main( int argc, char *argv[] )
{
	int	tmp;
	char	*arg;
	EVNT w_ev;
	WORD whdl_format,whdl_diskcopy;
	int	src_dev;
	int	dst_dev;
	enum actioncode action;


	/* Kommandozeile auswerten */
	/* ----------------------- */

	action = BOTH;
	src_dev = dst_dev = -1;

	(void)argc;
	for	(argv++; *argv; argv++)		/* argv[argc] ist NULL */
		{
		arg = *argv;
		if	(!stricmp(arg, "-f"))
			action = FORMAT;
		else
		if	(!stricmp(arg, "-fh"))
			action = INIT;
		else
		if	(!stricmp(arg, "-c"))
			action = COPY;
		else	{
			tmp = (*arg++ & 0x5f) - 'A';	/* ->devno */
			if	(tmp < 0 || tmp > 31)
				return(-1);
			if	(*arg++ != ':' || *arg)
				return(-1);		/* Fehler */
			if	(src_dev >= 0)
				dst_dev = tmp;
			else src_dev = tmp;
			}
		}

	if	(src_dev == -1)
		src_dev = 0;
	if	(dst_dev == -1)
		dst_dev = 0;

	if ((ap_id = mt_appl_init(global)) < 0)
		Pterm(-1);
	graf_handle(&gl_hwchar, &gl_hhchar, &gl_hwbox, &gl_hhbox);
	wind_get_grect(SCREEN, WF_WORKXYWH, &scrg);
	Mrsrc_load("mgformat.rsc", global);

	mt_rsrc_gaddr(0, T_ICONIF, &adr_iconified, global);
	adr_iconified[1].ob_width  = 72;
	adr_iconified[1].ob_height = (adr_iconified[1].ob_spec.iconblk->ib_hicon)+8;

	read_inf();

	fmt_dial_init_rsc(src_dev, (action == INIT),
			(action == FORMAT));
	cpy_dial_init_rsc(src_dev, dst_dev);


	Mgraf_mouse(ARROW);

	if	((action == FORMAT) || (action == INIT) || (action == BOTH))
		{
		d_format = wdlg_create(hdl_format,
							adr_format,
							NULL,
							0,
							NULL,
							0);
		if	(!d_format)
			goto fehler;

		whdl_format = wdlg_open( d_format,
							"DISKFORMAT",
							NAME+CLOSER+MOVER+SMALLER,
							-1,-1,
							0,
							NULL );
		if	(!whdl_format)
			goto fehler;

		}
	if	((action == COPY) || (action == BOTH))
		{
		d_cpydsk = wdlg_create(hdl_cpydsk,
							adr_cpydsk,
							NULL,
							0,
							NULL,
							0);

		if	(!d_cpydsk)
			goto fehler;

		whdl_diskcopy = wdlg_open( d_cpydsk,
							"DISKCOPY",
							NAME+CLOSER+MOVER+SMALLER,
							-1,-1,
							0,
							NULL );
		if	(!whdl_diskcopy)
			goto fehler;
		}

	for (;;)
	{
		w_ev.mwhich = evnt_multi(MU_KEYBD+MU_BUTTON+MU_MESAG,
					  2,			/* Doppelklicks erkennen 	*/
					  1,			/* nur linke Maustaste		*/
					  1,			/* linke Maustaste gedrckt	*/
					  0,0,0,0,0,		/* kein 1. Rechteck			*/
					  0,0,0,0,0,		/* kein 2. Rechteck			*/
					  w_ev.msg,
					  0L,	/* ms */
					  &w_ev.mx,
					  &w_ev.my,
					  &w_ev.mbutton,
					  &w_ev.kstate,
					  &w_ev.key,
					  &w_ev.mclicks
					  );

		if	(d_fmtopt && !wdlg_evnt(d_fmtopt, &w_ev))
		{
			wdlg_close(d_fmtopt, NULL, NULL);
			wdlg_delete(d_fmtopt);
			d_fmtopt = NULL;
		}
		if	(d_format && !wdlg_evnt(d_format, &w_ev))
			break;
		if	(d_cpydsk && !wdlg_evnt(d_cpydsk, &w_ev))
			break;

		if	(w_ev.mwhich & MU_MESAG)
		{
			if	(w_ev.msg[0] == AP_TERM)
				break;
			if	(w_ev.msg[0] == THR_EXIT)
				{
				fmt_id = -1;
				}
			if	(w_ev.msg[0] >= 1040)
			{
				struct HNDL_OBJ_args args;
				
				args.events = &w_ev;
				args.obj = HNDL_MESG;
				args.clicks = 0;
				args.data = w_ev.msg;
				if	(d_format && w_ev.msg[3] == whdl_format)
				{
					args.dialog = d_format;
					hdl_format(args);
				} else if (d_cpydsk && w_ev.msg[3] == whdl_diskcopy)
				{
					args.dialog = d_cpydsk;
					hdl_cpydsk(args);
				}
			}
		}
	}

	fehler:
	appl_exit();
	return(0);
}


char *err_file;

long err_alert(long e)
{
	form_xerr(e, err_file);
	err_file = NULL;
	return(e);
}


/*********************************************************************
*
* Setzt einen Laufwerk-Buchstaben in eine Schablone ein.
*
*********************************************************************/

void drv_to_str(char *s, char c)
{
	while(*s)
		{
		if	(s[1] == ':')		/* n„chstes Zeichen ist ':' */
			{
			*s = c;
			break;
			}
		s++;
		}
}
