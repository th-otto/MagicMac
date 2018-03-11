/*********************************************************************
*
* Dieses Modul enthÑlt die Hauptsteuerung von MATRIX, also die
* event_multi - Schleife.
*
*********************************************************************/

#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include <math.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include "matrix.h"
#include "m.h"

#define SCREEN     0
#define FENSTERTYP (NAME+CLOSER+FULLER+MOVER+SIZER+UPARROW+DNARROW+VSLIDE+HSLIDE+LFARROW+RTARROW)

#define MINBREITE  160
#define ANFDIM     4                /* Default- Dimension */

MATRIXTYP mtx[ANZMAT];
char format[ANZMAT][2];			 /* Anzahl der Vor.-/Nachkommastellen  */
static char neu_format[ANZMAT];     /* Zeigt, ob Mtx. neu format. werden muû */
char ist_symm[ANZMAT];			 /* Zeigt, ob Mtx. symmetrisch ist */

int message[16];
int work_out[57],work_in [12];	 /* VDI- Felder fÅr v_opnvwk() */


GRECT fenster[ANZFENSTER];   /* aktuelle Fenster- Koordinaten 		 */
int fensterh[ANZFENSTER],    /* Handle bzw. neg. bei "nicht existent"  */
    mfenster[ANZFENSTER],    /* Matrixnummer bzw. -1, wenn geschlossen */
    sxfenster[ANZFENSTER],   /* x - Nr. der links oben dargest. Zelle  */
    syfenster[ANZFENSTER];   /* y - Nr. der links oben dargest. Zelle  */


int ap_id;
int vdi_handle, gl_hhbox, gl_hwbox, gl_hhchar, gl_hwchar, zell_hoch;
int scr_x, scr_y, scr_w, scr_h;

OBJECT *adr_icons;
OBJECT *adr_hauptmenu;


void anfang	 (void);
void zeige_info (void);
void datei_menu (void);
void edit_menu	 (void);
void versch_menu(void);
void umwand_menu(void);
void redraw	 (int whdl,int neu_x,int neu_y,int neu_b,int neu_h);
void topped	 (int whdl);
void closed	 (int whdl);
void fulled	 (int whdl);
void arrowed	 (int whdl, int code);
void h_vslid	 (int whdl, int ishor, int pos);
void siz_moved	 (int whdl, GRECT *g);
void newtop	 (int whdl);
void tastatur	 (int code);
void mausknopf	 (int anzahl , int y_koor, int x_koor, int knopf);
void zeichne	 (int whdl, int x, int y, int b, int h);
void gr_schieber(int n);
int	selected	 (OBJECT *tree, int which);
void loesche	 (int x, int y);
int	scan_float (char *eingabe, double *z, char **endptr);
char *dtoa(double z, int vorkomma, int nachkomma, int breite);

/* Externals aus "edit.c" */
extern int edx,edy;


void main()
{
	int  ev_mwich, ev_mbreturn, ev_mkreturn, ev_mmokstate,
		ev_mmobutton, ev_mmoy, ev_mmox;


	anfang();
	graf_mouse(ARROW, NULL);
	for  (;;)
		{
		ev_mwich = evnt_multi(MU_KEYBD+MU_BUTTON+MU_MESAG,
						  2, 3, 1, 0,0,0,0,0,0,0,0,0,0,message,0,0,
						  &ev_mmox, &ev_mmoy, &ev_mmobutton,
						  &ev_mmokstate, &ev_mkreturn, &ev_mbreturn);

		wind_update(BEG_UPDATE);

		/* Abfrage auf Nachricht im Nachrichtenpuffer */
		/* ------------------------------------------ */

		if	(ev_mwich & MU_MESAG)
			{
			if	(message[0] == MN_SELECTED)
				{
			     switch(message[3]) {
			          case        3:  zeige_info();break;
			          case DATEIMEN:  datei_menu();break;
			          case EDITMEN:    edit_menu();break;
			          case VERSCMEN: versch_menu();break;
			          case UMWANMEN: umwand_menu();break;
			          }
			     menu_tnormal(adr_hauptmenu,message[3],1);
			     }
			else {
				switch(message[0]) {
				     case WM_REDRAW:   redraw(message[3],message[4],
				                              message[5],message[6],
				                              message[7]);
				                       break;
				     case WM_TOPPED:   topped(message[3]);break;
				     case WM_CLOSED:   closed(message[3]);break;
				     case WM_FULLED:   fulled(message[3]);break;
				     case WM_ARROWED: arrowed(message[3],
				     					message[4]);
				     			break;
				     case WM_HSLID:
				     case WM_VSLID:   h_vslid(message[3],
				     					message[0] == WM_HSLID,
				     					message[4]);
				     			break;
				     case WM_SIZED:
				     case WM_MOVED: siz_moved(message[3],
				     					(GRECT *) (message+4));
				     			break;
				     case WM_NEWTOP:   newtop(message[3]);break;
				     }
				}
			}

		/* Abfrage auf BetÑtigung eines Mausknopfs */
		/* --------------------------------------- */

		if	(ev_mwich & MU_BUTTON)
			mausknopf(ev_mbreturn,ev_mmoy,ev_mmox,ev_mmobutton);

		/* Abfrage auf BetÑtigung einer Taste */
		/* ---------------------------------- */

		if	(ev_mwich & MU_KEYBD)
			{
			tastatur(ev_mkreturn);
			}

		wind_update(END_UPDATE);
		} /* END FOREVER */
}


/****************************************************************
*
* Bestimmt die Schnittmenge zwischen zwei Rechtecken
*
****************************************************************/

int rc_intersect(GRECT *p1, GRECT *p2)
{
	int	tx, ty, tw, th;

	tw = MIN(p2->g_x + p2->g_w, p1->g_x + p1->g_w);
	th = MIN(p2->g_y + p2->g_h, p1->g_y + p1->g_h);
	tx = MAX(p2->g_x, p1->g_x);
	ty = MAX(p2->g_y, p1->g_y);
	p2->g_x = tx;
	p2->g_y = ty;
	p2->g_w = tw - tx;
	p2->g_h = th - ty;
	return( (tw > tx) && (th > ty) );
}


/****************************************************************
*
* Malt das Fenster mit Handle <whdl> im Bereich
* neu_x,neu_y,neu_b,neu_h  nach.
*
****************************************************************/

void redraw(int whdl, int neu_x, int neu_y, int neu_b, int neu_h)
{
	GRECT w,n;


	n.g_x = neu_x;
	n.g_y = neu_y;
	n.g_w = neu_b;
	n.g_h = neu_h;
	graf_mouse(M_OFF,NULL);
	vsf_color(vdi_handle,0);               /* FÅllfarbe weiû */
	vswr_mode(vdi_handle,MD_REPLACE);
	wind_get(whdl,WF_FIRSTXYWH,&(w.g_x),&(w.g_y),&(w.g_w),&(w.g_h));
	do	{
		if	(rc_intersect(&n,&w))
			zeichne(whdl,w.g_x, w.g_y, w.g_w, w.g_h);
		wind_get(whdl,WF_NEXTXYWH,&(w.g_x),&(w.g_y),&(w.g_w),&(w.g_h));
		}
	while(w.g_w > 0);                      /* bis Rechteckliste vollstÑndig */
	graf_mouse(M_ON, NULL);
}


/****************************************************************
*
* Schickt einen Redraw fÅr Fenster <n>.
*
****************************************************************/

void send_redraw(int nr)
{
	int msg[8];


	msg[0] = WM_REDRAW;
	msg[1] = ap_id;
	msg[2] = 0;
	msg[3] = fensterh[nr];
	msg[4] = fenster[nr].g_x;
	msg[5] = fenster[nr].g_y;
	msg[6] = fenster[nr].g_w;
	msg[7] = fenster[nr].g_h;
	appl_write(ap_id, 16, msg);
}


/****************************************************************
*
* Zeichnet alle Fenster, die die Matrix <nr> darstellen, neu und
*  korrigiert das Format, d.h. die Anzahl der Vorkommastellen in
*  format[nr][0]
*
* Es gilt:  mindestens 1   Vorkommastelle
*		  maximal    VOR Vorkommastellen
*
* edflag == 1 : Das Editierfenster auch, wenn nîtig, neu malen.
* edflag ==-1 : Das Editierfenster nicht neu malen
* edflag == 0 : Die <neu_zahl> ist eingegeben worden, also das
*               Editierfenster nicht neu malen.
*
****************************************************************/

void m_update(int nr, int edflag, double neu_zahl)
{
	double z;
	int max,breite;
	register int i,j;
	extern int is_edit;


	if   (!edflag)					/* Eingabe einer neuen Zahl */
		{
		max = format[nr][0];
		if	((z = ABS(neu_zahl)) >= 1.0)
			{
			breite = (int) (1.001 + log10(z));
			if   (breite > VOR) breite = VOR;
			if   (breite > max)	max = breite;
			}
		neu_format[nr] = TRUE;
		}
	else {						/* u.u. ganze Matrix verÑndert */
		max = 1;
		for	(i = 0; i < mtx[nr].xdim; i++)
			for	(j = 0; j < mtx[nr].ydim; j++)
		     	{
				if   ((z = ABS(mtx[nr].m[j][i])) < 1.0) continue;
				breite = (int) (1.001 + log10(z));
				if   (breite > VOR) breite = VOR;
				if   (breite > max) max = breite;
				}
		neu_format[nr] = FALSE;
		}

	format[nr][0] = max;
	for	(i = (edflag == 1) ? 0 : 1; i < ANZFENSTER; i++)
		if	(mfenster[i] == nr)
			{
			gr_schieber(i);
			if   (i == 0)
				is_edit = FALSE;

			/* Der Redraw wird nicht direkt ausgefÅhrt, sondern schickt */
			/* eine Nachricht an die Applikation, um Kollisionen mit    */
			/* von AES erzeugten Redraws zu vermeiden                   */
			/* -------------------------------------------------------- */

			send_redraw(i);
			}
}


/****************************************************************
*
* gibt Nummer des selektierten Icons zurÅck
*
****************************************************************/

int icsel(void)   
{
	register int i;

	for	(i = A_MATRIX; i <= J_MATRIX; i++)
		if	(selected(adr_icons,i))
			return(i);
	return(0);
}


/****************************************************************
*
* Rechnet window_handle <whdl> in Fensternummer um
*
****************************************************************/

int hdl_to_fnr(int whdl)
{
	register int i;

	for  (i = 0; i < ANZFENSTER; i++)
		if	(fensterh[i] == whdl)
			return(i);
	return(-1);
}


/****************************************************************
*
* Gibt einen Ton fÅr eine Fehlermeldung aus.
*
****************************************************************/

void bel( void )
{
	Bconout(2,'\7');
}


/****************************************************************
*
* Berechnet die Breite einer Ausgabezelle in Pixeln fÅr
* das Fenster mit der Nummer <n>.
*
****************************************************************/

int breite(int n)
{
	int zahllen,nr;


	nr = mfenster[n];
	/* Breite einer Zahl = Vorkomma + Nachkomma + Vorzeichen + '.' */
	zahllen = 2 + ((n) ? (format[nr][0]+format[nr][1]) : (VOR+NACH));
	/* Breite einer Zelle = (Leerstelle + Zahl) * Zeichenbreite */
	return((zahllen + 1) * gl_hwchar);
}


/****************************************************************
*
* Zeichnet den Ausschnitt x,y,b,h des Fensters mit Handle <whdl>
* neu.
*
****************************************************************/

void zeichne(int whdl, int x, int y, int b, int h)
{
	double z;
	int    wx,wy,wh,wb,zell_breit,anfx,anfy,endy,endx,iix,iiy,
		  vorkomma,nachkomma,zahllen;
	register char *zahl;
	int    pxyarray[4];
	register	int 	  ix,iy,n,nr;
	void   drucke_edbuf(int x, int y);



	if	((n = hdl_to_fnr(whdl)) < 0)
		return;                            /* Falsches Handle */
	wind_get(whdl,WF_WORKXYWH,&wx,&wy,&wb,&wh);

	/* Ausschnitt auf Fenstergrîûe reduzieren */
	/* -------------------------------------- */

	if   (b > (wx+wb-x)) b = wx+wb-x;
	if   (h > (wy+wh-y)) h = wy+wh-y;
	if   ((h <= 0) || (b <= 0))
	     return;                            /* Rechteck ist leer */
	nr = mfenster[n];            			/* Matrixnummer 0..ANZMAT-1 */

	/* Clipping- Ausschnitt setzen */
	/* --------------------------- */

	pxyarray[0] = x;     pxyarray[1] = y;
	pxyarray[2] = x+b-1; pxyarray[3] = y+h-1;
	vs_clip(vdi_handle,1,pxyarray);             /* Clipping- Ausschnitt */

	vr_recfl(vdi_handle,pxyarray);              /* Bereich lîschen */

	/* Formatstring mit Vor-, Nachkommastellen setzen */
	/* ---------------------------------------------- */

	if (!n) { vorkomma = VOR;           nachkomma = NACH;}
	else    { vorkomma = format[nr][0]; nachkomma = format[nr][1];}
	zahllen = vorkomma + nachkomma + 2;

	/* Breite eines Matrixelements auf dem Bildschirm bestimmen */
	/* und zu zeichnenden Ausschnitt der Matrix berechnen       */
	/* -------------------------------------------------------- */

	zell_breit = breite(n);
	anfx = (x - wx) / zell_breit; /* x-Index erster z.zchn. Zelle */
	endx = (x + b - wx + zell_breit-1) / zell_breit;
	anfy = (y - wy) / zell_hoch;
	endy = (y + h - wy + zell_hoch -1) / zell_hoch;
	wy += gl_hhchar;
	wx += 2;

	/* Alle neu zu zeichnenden Matrixelemente ausgeben */
	/* ----------------------------------------------- */

	for	(iy = anfy; iy <= endy; iy++)
		{
	     if	((iiy = iy + syfenster[n]) >= mtx[nr].ydim)
			break;
		for	(ix = anfx; ix <= endx; ix++)
			{
			if   ((iix = ix + sxfenster[n]) >= mtx[nr].xdim)
				break;
			z = mtx[nr].m[iiy][iix];

			/* 1. Fall: Es handelt sich um das Edit- Fenster */
			/* --------------------------------------------- */

			if	(!n)
				{

				/* 1. Fall: Es handelt sich um das Cursor- Feld */
				/* -------------------------------------------- */

				if	((iiy == edy) && (iix == edx))
					{
					if	(is_edit)
						drucke_edbuf(wx+ix*zell_breit, wy+iy*zell_hoch);
					else goto drucke;
					}

				/* 2. Fall: Sonst                               */
				/* -------------------------------------------- */

				else	{
					if   (ist_symm[nr] && (iiy > iix)
					                  && (iiy < mtx[nr].xdim))
					     continue;    /* unter Diagonaler nicht drucken */
					else goto drucke;
					}
				}

			/* 2. Fall: Sonst                                 */
			/* ---------------------------------------------- */

			else	{
				drucke:
				zahl = dtoa(z, vorkomma, nachkomma, zahllen);
				v_gtext(vdi_handle,zell_breit-gl_hwchar*((int) strlen(zahl)+1)+
				             wx+ix*(zell_breit),
				      wy+iy*(zell_hoch ), zahl);
				if	(!n && (iix == edx) && (iiy == edy))
					{
					vswr_mode(vdi_handle,MD_XOR);
					loesche(wx+ix*zell_breit, wy+iy*zell_hoch);
					vswr_mode(vdi_handle,MD_REPLACE);
					}
			     }
			}
          }
}

/*********************************************************************
*
* Umwandlung von "double" in ASCII. Die Adresse des Strings wird
* zurÅckgegeben. Der String ist <breite> Zeichen lang.
* Eine Stelle ist immer fÅr das Vorzeichen reserviert.
*
*********************************************************************/

char *dtoa(double z, int vorkomma, int nachkomma, int breite)
{
	register  char *s,*d;
	static	char ausg[100];
			char exps[20];			/* Exponent */
			int	dec,sign;


	d = ausg;
	if	(vorkomma < 0)				/* E- Format erzwingen */
		dec = breite - 2;
	else dec = vorkomma + nachkomma;
	s = ecvt (z, dec, &dec, &sign);
	breite--;
	*d++ = (sign) ? '-' : ' ';
	if	(dec > vorkomma)		/* E- Format */
		{
		*d++ = *s++;
		exps[0] = 'e';
		breite -= (int) strlen(itoa(dec-1, exps+1, 10)) + 2;
		if	(breite > 1)
			{
			*d++ = '.';
			*d   = EOS;
			strncat(d, s, breite - 1);
			d += strlen(d);
			}
		strcpy(d, exps);
		}

	else {						/* Festkomma- Format */
		if	(dec <= 0)
			{
			*d++ = '0';
			breite--;
			}
		else {
			strncpy(d, s, dec);
			breite -= dec;
			d += dec;
			s += dec;
			}
		if	(nachkomma > 0)
			{
			*d++= '.';
			if	(dec < 0)
				{
				if	(-dec > nachkomma)
					dec = -nachkomma;
				breite    += dec;
				nachkomma += dec;
				while(dec < 0)
					{
					*d++ = '0';
					dec++;
					}
				}
			strncpy(d, s, nachkomma);
			d += nachkomma;
			breite -= nachkomma + 1;
			}
		*d = EOS;
		}

	if	(breite < 0)
		{
		ovfl:
		ausg[0] = '?';
		ausg[1] = EOS;
		return(ausg);
		}
	return(ausg);
}


/*********************************************************************
*
* Dieses Modul enthÑlt die Initialisierung des AES/VDI, die Initiali-
* sierung von MATRIX sowie allgemeine Routinen.
*
*********************************************************************/

int do_dialog(OBJECT *dialog)
{
	int cx, cy, cw, ch;
	int exitbutton;


	form_center(dialog, &cx, &cy, &cw, &ch);
	form_dial(FMD_START, 0,0,0,0, cx, cy, cw, ch);
	objc_draw(dialog, ROOT, MAX_DEPTH, cx, cy, cw, ch);
	exitbutton = 0x7f & form_do(dialog, 0);
	form_dial(FMD_FINISH, 0,0,0,0,cx, cy, cw, ch);
	return(exitbutton);
}

/********** Objekt selektiert? *********/

int selected(OBJECT *tree, int which)

{ return( ((tree+which)->ob_state & SELECTED) ? 1 : 0 ); }


/******* Objekt deselektieren **********/

void ob_dsel(OBJECT *tree, int which)

{ (tree+which)->ob_state &= ~SELECTED; }

/***** Objekt selektieren **************/

void ob_sel(OBJECT *tree, int which)

{ (tree+which)->ob_state |= SELECTED; }

/***************************************/

void open_work(void)
{
	register int i;


	for  (i = 0; i < 10; work_in[i++] = 1)
		;
	work_in[10]=2;                     /* Rasterkoordinaten */
	v_opnvwk(work_in, &vdi_handle, work_out);
	vswr_mode(vdi_handle,MD_REPLACE);      /* Replace- Modus */
	vsf_color(vdi_handle,WHITE);           /* FÅllfarbe weiû */
	vsf_interior(vdi_handle,SOLID);        /* komplett ausfÅllen */
}

/***************************************/

void close_work(void)
{
	register int i;

	wind_set(SCREEN, WF_NEWDESK, NULL, 0);	/* Desktop- Hintergrund */
	for (i = 0; i < ANZFENSTER; i++)
		if	(fensterh[i] > 0)         /* wenn Fenster existiert... */
			{
			if	(mfenster[i] >= 0)		 /* ...und geîffnet   */
				wind_close(fensterh[i]);  /* ...dann schlieûen */
			wind_delete(fensterh[i]); /* ...und immer lîschen!  */
			}
	v_clsvwk(vdi_handle);
	rsrc_free();
	appl_exit();
	Pterm0();
}


/****************************************************************
*
* Initialisierung von MATRIX (AES,RSC,VDI,Fenster,Icons,MenÅ).
*
****************************************************************/

void anfang(void)
{
	static unsigned koor[] = {224,160,160,160,16,16,16,48,16,80,16,112,16,144,
	                                      80,16,80,48,80,80,80,112,80,144};
	register int i;
	OBJECT *norm_info;
	GRECT  scr_grect;
	extern void icon_malen(int index, GRECT *neu);


	/* Applikation beim AES anmelden */
	/* ----------------------------- */
	if   ((ap_id = appl_init()) < 0)
		Pterm(1);

	/* VDI - Bildschirmhandle holen */
	/* ---------------------------- */
	vdi_handle = graf_handle(&gl_hwchar, &gl_hhchar, &gl_hwbox, &gl_hhbox);
	zell_hoch = gl_hhchar + gl_hhchar/2;
	open_work();

	/* Resourcedatei laden */
	/* ------------------- */
	if	(!rsrc_load("matrix.rsc"))
		{
		form_alert(1, "[3][Kann \"MATRIX.RSC\" nicht finden][ABBRUCH]");
		close_work();
		}

	/* Niedrige Auflîsung abblocken */
	/* ---------------------------- */
	if   (Getrez() == 0)
		{
		form_alert(1, "[3][Nicht fÅr niedrige Auflîsung!][ABBRUCH]");
		close_work();
		}

     /* Cursor abschalten */
     /* ----------------- */
	Cursconf(0,0);

	/* Mauskontrolle abschalten, MenÅ installieren */
	/* ------------------------------------------- */
	wind_update(BEG_UPDATE);
	/*Bildschirm- Arbeitsbereich */
	wind_get(SCREEN, 4, &scr_x, &scr_y, &scr_w, &scr_h);
	rsrc_gaddr(0, HAUPTMEN, &adr_hauptmenu);
	menu_bar(adr_hauptmenu, TRUE);

	/* Icons als Desktop- Hintergrund installieren */
	/* ------------------------------------------- */

	rsrc_gaddr(0, BILDER, &adr_icons);
     adr_icons->ob_width  = scr_x + scr_w;
	adr_icons->ob_height = scr_y + scr_h;

	/* Icons anpassen und fÅr mittlere Auflîsung verschieben */
	/* ----------------------------------------------------- */

	for  (i = A_MATRIX; i <= J_MATRIX; i++)
		{
	     (adr_icons + i)->ob_width  = 47;
	     (adr_icons + i)->ob_height = 36;
	     }
	(adr_icons + E_MATRIX)->ob_width = 49;
	(adr_icons + MIST    )->ob_width = 50;
	(adr_icons + DRUCKER )->ob_width = 48;
	(adr_icons + MIST    )->ob_height = (adr_icons + DRUCKER)->ob_height = 41;

	if   (Getrez() == 1)
		{
		adr_icons->ob_spec.index = 0x173L;
		for  (i = 0; i <= J_MATRIX-MIST; i++)
			{
			(adr_icons + MIST +i)->ob_x = koor[i+i];
			(adr_icons + MIST +i)->ob_y = koor[i+i+1];
			}
		}

	/* Defaults setzen: Matrix A selektieren, ES- Norm */
	/* ----------------------------------------------- */

	ob_sel(adr_icons,A_MATRIX);
	rsrc_gaddr(0, NORMBOX, &norm_info);
	ob_sel(norm_info, NORM_ES);

	/* Icons malen und installieren */
	/* ---------------------------- */

	wind_set(SCREEN, WF_NEWDESK, adr_icons, 0);
	scr_grect.g_x = scr_x;
	scr_grect.g_y = scr_y;
	scr_grect.g_w = scr_w;
	scr_grect.g_h = scr_h;
	icon_malen(0, &scr_grect);

	/* Position und Grîûe der Fenster festlegen */
	/* ---------------------------------------- */
	for	(i = 0; i<ANZFENSTER; i++)
		{
		fensterh[i] = -1;		/* noch nicht geîffnet */
		mfenster[i] = -1;		/* noch nicht geîffnet */
		fenster[i].g_x = 140+20*i; fenster[i].g_y = scr_y+10*i;
		fenster[i].g_w = 300;      fenster[i].g_h = 10*gl_hhchar;
		sxfenster[i] = syfenster[i] = 0;
		}
	fenster[0].g_w = 400;
	fenster[0].g_x = scr_x;     /* Default fÅr Edit- Fenster */
	
	/* Matrizen auûer E auf 0 initialisieren */
	/* ------------------------------------- */
	for  (i = 0; i < ANZMAT; i++)
		{
		mtx[i].xdim = mtx[i].ydim = ANFDIM;  /* 4x4 0-Matrizen */
		format[i][0] = 1; format[i][1] = 5;
		}
	for  (i = 0; i < MAXDIM; i++)
		mtx['E'-'A'].m[i][i] = 1.0; /* E- Matrix */
	wind_update(END_UPDATE);
}


/***************************************/

#include "msg.c"

/***************************************/

#include "menus.c"

/***************************************/

#include "klick.c"

