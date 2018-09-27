/*********************************************************************
*
* Dieses Modul enthÑlt alle Aktionen im Editierfenster.
*
*********************************************************************/


#include <aes.h>
#include <vdi.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "m.h"

#define FENSTERTYP (NAME+CLOSER+FULLER+MOVER+SIZER+UPARROW+DNARROW+VSLIDE+HSLIDE+LFARROW+RTARROW)

/* Externals aus "shell.c " */
extern void  redraw	 (int whdl,int neu_x,int neu_y,int neu_b,int neu_h);
extern void  m_update(int nr, int edflag, double neu_zahl);
extern char  *dtoa(double z, int vorkomma, int nachkomma, int breite);
extern void  topped	 (int whdl);
extern void  gr_schieber(int n);
extern int   hdl_to_fnr(int whdl);
extern void  bel( void );
extern int   breite(int n);

extern int   vdi_handle, gl_hhbox, gl_hwbox,
		   gl_hhchar, gl_hwchar, zell_hoch;
extern int   scr_x, scr_y, scr_w, scr_h;
extern GRECT fenster[ANZFENSTER];  /* aktuelle Fenster- Koordinaten */
extern int   fensterh[ANZFENSTER],
		   mfenster[ANZFENSTER],
		   sxfenster[ANZFENSTER],
		   syfenster[ANZFENSTER];
extern char format[ANZMAT][2];			/* Anzahl der Vor.-/Nachkommastellen  */
extern char ist_symm[ANZMAT];				/* Zeigt, ob Mtx. symmetrisch ist */

/* Externals aus "klick.c" */
extern void  gr_schieber(int n);

/* Externals aus "msg.c" */
extern void anzahl(int n, int *nr, int *x, int *y, int *ax, int *ay);

/* Externals aus "arith.c" */
extern int   scan_float (char *eingabe, double *z, char **endptr);

int 	is_edit;			/* Flag fÅr "Editieren in Aktion */
char edbuf[EDBUFLEN+1];
int	edx,edy,cur_pos,vedx,vedy;


/*******************************************************************
*
* Der Editierpuffer wird gelîscht, d.h. mit Leerstellen
* Åberschrieben, und der _-Cursor auf die erste Position gesetzt.
*
*******************************************************************/

void clr_edbuf(void)
{
	memset(edbuf, ' ', EDBUFLEN);
	cur_pos = 0;
}


/*******************************************************************
*
* Der Name des Editierfensters wird gesetzt.
*
*******************************************************************/

void edfenstername(void)
{
	static   char edname[] = " edit X(00,00) \0\0";
	register char *s;


	clr_edbuf();
	s = edname+6;
	*s++ = mfenster[0] + 'A';
	s++;
	itoa(edy+1, s++, 10);
	while(*s)
		s++;
	*s++ = ',';
	itoa(edx+1, s, 10);
	while(*s)
		s++;
	*s++ = ')';
	*s++ = ' ';
	*s++ = EOS;
	*s 	= EOS;
	wind_set_str(fensterh[0],WF_NAME,edname);
}


/*******************************************************************
*
* Das Editierfenster wird geîffnet.
* Editiert wird die Matrix <mtx[idx]> bei Position (ex,ey).
*
*******************************************************************/

void openedit(int matrixnr, int ex, int ey)
{
	int justiere(int drawflag);


	if	(matrixnr >= 0)
		{
		fensterh[0] = wind_create(FENSTERTYP, scr_x, scr_y, scr_w, scr_h);
		if	(fensterh[0] < 0)
			{
			form_alert(1, "[3][Alle Fenster sind belegt.|"
						   "Kann Editierfenster nicht îffnen.][ABBRUCH]");
			return;
			}
		edx = ex; edy = ey;
		mfenster[0] = matrixnr;
		sxfenster[0] = syfenster[0] = 0;
		edfenstername();
		wind_open(fensterh[0],fenster[0].g_x,fenster[0].g_y,
						  fenster[0].g_w,fenster[0].g_h);
		gr_schieber(0);
		justiere(FALSE);
		is_edit = FALSE;
		}
}


/****************************************************************
*
* Der Bediener hat das Fenster mit dem Handle <whdl> angeklickt,
* und zwar mit einem <anz_klick>- fach- Mausklick bei Bildschirm-
* Position (x,y).
* Ist das Editierfenster noch nicht geîffnet, muû dies sofort
* geschehen. Dann wird der Cursor auf die zu editierende Position
* gesetzt.
*
****************************************************************/

void edit(int whdl, int anz_klick, int x, int y)
{
	int n,nr,tmp,zell_breit,wx,wy,dummy,thdl;


	/* Wir behandeln nur Doppelklicks und nur unsere Fenster */
	/* ----------------------------------------------------- */

	if	((anz_klick != 2) || ((n = hdl_to_fnr(whdl)) < 0))
		return;

	nr = mfenster[n];	 		/* Matrixnummer 0..ANZMAT-1 */
	zell_breit = breite(n);

	/* Fensterposition ermitteln und Index des angeklickten */
	/* Matrixelements (x,y) berechnen					 */
	/* ---------------------------------------------------- */

	wind_get(fensterh[n],WF_WORKXYWH,&wx,&wy,&dummy,&dummy);
	y = syfenster[n] + (y - wy	)/zell_hoch;
	x = sxfenster[n] + (x - wx - 2)/zell_breit;

	/* Ist die Matrix (teil-) symmetrisch und wurde ein	 */
	/* Element der unteren (Teil-) Matrix angeklickt, so	 */
	/* das entsprechende, obere Element auswÑhlen		 */
	/* ---------------------------------------------------- */

	if	(ist_symm[nr] && (y > x) && (y < mtx[nr].xdim))
		{
		tmp = x;
		x	 = y;
		y	 = tmp;
		}

	/* Wenn das angewÑhlte Matrixelement nicht existiert,	 */
	/* brauchen wir nichts zu tun 					 */
	/* ---------------------------------------------------- */

	if	((x < 0) || (x >= mtx[nr].xdim) || (y < 0) || (y >= mtx[nr].ydim))
		return;

	/* 1. Fall: Das Editierfenster ist noch nicht geîffnet  */
	/*		  Also an entsprechender Stelle îffnen		 */
	/* ---------------------------------------------------  */

	if	(mfenster[0] < 0)
		openedit(mfenster[n],x,y);

	/* 2. Fall: Das Editierfenster ist schon geîffnet 	 */
	/*		  Also editierte Matrix und Position Ñndern	 */
	/*		  ggf. Editierfenster nach oben bringen 	 */
	/* ---------------------------------------------------  */

	else {
		mfenster[0] = mfenster[n];
		edx = x; edy = y;
		edfenstername();gr_schieber(0);
		if	(!justiere(TRUE))
			redraw(fensterh[0],scr_x,scr_y,scr_w,scr_h);
		wind_get(0,WF_TOP,&thdl,&dummy,&dummy,&dummy);
		if	(thdl != fensterh[0])
			topped(fensterh[0]);
		}
}


/*******************************************************************
*
* Lîscht an Bildschirmposition (x,y) einen Bildschirmbereich, d.h.
* malt ein weiûes Rechteck der Grîûe des Editierfeldes.
*
*******************************************************************/

void loesche(int x, int y)
{
	int pxy[4];


	/* Koordinaten der oberen, linken Ecke	 */
	/* ------------------------------------- */

	pxy[0]= x;
	pxy[1]= y - gl_hhchar + 3;

	/* Koordinaten der unteren, rechten Ecke */
	/* ------------------------------------- */

	pxy[2]= x - 1 + breite(0);
	pxy[3]= y + 2;

	vr_recfl(vdi_handle,pxy);
}


/*******************************************************************
*
* Gibt an Bildschirmposition (x,y) das Editierfeld aus.
*
*******************************************************************/

void drucke_edbuf(int x, int y)
{
	loesche(x,y);
	vswr_mode(vdi_handle,MD_ERASE);
	v_gtext(vdi_handle, x, y, edbuf);				/* Puffer invers drucken */
	vswr_mode(vdi_handle,MD_XOR);
	v_gtext(vdi_handle, x+gl_hwchar*cur_pos, y, "_"); /* '_'-Cursor */
	vswr_mode(vdi_handle,MD_REPLACE);				/* wieder replace- Mode	*/
}


/*******************************************************************
*
* An Bildschirmposition (x,y) wird die <zahl> im Editierfenster
* ausgegeben, nachdem der Cursor diese Stelle verlassen hat.
*
*******************************************************************/

void drucke_zahl(int x, int y, double z)
{
	char *zahl;
	int	zell_breit;


	loesche(x,y);
	zell_breit = breite(0);
	zahl = dtoa(z, VOR, NACH, VOR+NACH+2);
	v_gtext(vdi_handle,zell_breit-gl_hwchar*((int) strlen(zahl)+1)+x,y,zahl);
}


/*******************************************************************
*
* Der Cursor soll im Editierfenster auf dem Matrixelement (edx,edy)
*  stehen.
* Falls diese Position auûerhalb der Matrix liegt, wird sie
*  korrigiert.
* Es wird festgestellt, ob der Cursor im Editierfenster im sichtbaren
*  Teil des Fensters ist.
* Wenn nicht und auûerdem <drawflag> = TRUE, wird das Fenster
*  gescrollt und neu aufgebaut.
* In beiden FÑllen wird die absolute Cursor- Position (in Pixel-
*  koordinaten des Bildschirms) (vedx,vedy) gesetzt.
* RÅckgabe TRUE, wenn das Fenster wegen Scrolling neu gezeichnet
*			  wurde oder worden wÑre, falls drawflag = TRUE.
*
*******************************************************************/

int justiere(int drawflag)
{
	int flag,wx,wy,nr,ax,ay,zell_breit;


	flag = FALSE;

	/* Absolute Fensterposition:	  (wx,wy) */
	/* Anz. darstellbarer Elemente: (ax,ay) */
	/* Matrixnummer:			  nr 	*/
	/* ------------------------------------ */

	anzahl(0,&nr,&wx,&wy,&ax,&ay);
	if	(edx < 0) 		  {edx = 0;		    flag = TRUE;}
	if	(edx >= mtx[nr].xdim) {edx = mtx[nr].xdim-1;flag = TRUE;}
	if	(edy < 0 )		  {edy = 0;		    flag = TRUE;}
	if	(edy >= mtx[nr].ydim) {edy = mtx[nr].ydim-1;flag = TRUE;}
	zell_breit = breite(0);
	vedx = wx + (edx - sxfenster[0]) * zell_breit;
	vedy = wy + (edy - syfenster[0]) * zell_hoch;
	if	((edx < sxfenster[0]) || (edx > sxfenster[0] + ax - 1)) {
		sxfenster[0] = edx; flag = TRUE;
		}
	if	((edy < syfenster[0]) || (edy > syfenster[0] + ay - 1)) {
		syfenster[0] = edy; flag = TRUE;
		}
	if	(flag) {
		gr_schieber(0);
		cur_pos = 0;
		edfenstername();
		if	(drawflag)
			redraw(fensterh[0],scr_x,scr_y,scr_w,scr_h);
		vedx = wx + (edx - sxfenster[0]) * zell_breit;
		vedy = wy + (edy - syfenster[0]) * zell_hoch;
		}
	return(flag);
}


/*******************************************************************
*
* Diese Routine wird ausgefÅhrt, wenn die UNDO- Taste betÑtigt
* wurde: Das ursprÅngliche Matrixelement wird in den Editier-
* puffer geschrieben.
*
*******************************************************************/

void undo_edbuf(void)
{
	register int i;


	cur_pos = 0;
	strcpy(edbuf, dtoa(mtx[mfenster[0]].m[edy][edx],
			    -32767, NACH, VOR+NACH+2));
	for	(i = -1; edbuf[++i];)
		;
	for	(; i < EDBUFLEN;)
		edbuf[i++] = ' ';
}


/*******************************************************************
*
* FÅhrt die Zuweisung "matrixelement := editierpuffer" aus.
* Form:	<zahl>
*		<zahl> <operator>
*		<operator> <zahl>
*		<zahl> <operator> <zahl>
* RÅckgabe TRUE, wenn OK
*
*******************************************************************/

int zuweisung(int nr, int x, int y)
{
	char	  *s;
	double zahl1,zahl2;
	char   operator;
	void skip_space(char *(string[]));


	s = edbuf;
	zahl1 = zahl2 = mtx[nr].m[y][x];
	scan_float(s, &zahl1, &s);
	skip_space(&s);
	operator = *s++;
	if	(operator != EOS)
		{
		scan_float(s, &zahl2, &s);
		skip_space(&s);
		if	(*s != EOS)
			return(FALSE);
		}

	switch (operator) {
		case '\0':   break;
		case  '+': zahl1 += zahl2; break;
		case  '-': zahl1 -= zahl2; break;
		case  '*': zahl1 *= zahl2; break;
		case  '/': zahl1 /= zahl2; break;
		case  'w':
		case  'W': zahl1  = sqrt(zahl2); break;
		case  's':
		case  'S': zahl1  = sin(zahl2); break;
		default  : return(FALSE);
		}
	mtx[nr].m[y][x] = zahl1;
	if	(ist_symm[nr])
		mtx[nr].m[x][y] = zahl1;
	return(TRUE);
}


/****************************************************************
*
* Bearbeitet einen Tastendruck bei geîffnetem Editierfenster.
* Eingabewert:   Tastaturcode
*
****************************************************************/

#include <scancode.h>

void drucke(int taste)
{
	int altedx,altedy,altvedx,altvedy,nr;
	int pxy[4];


	graf_mouse(M_OFF, NULL);
	wind_get(fensterh[0],WF_WORKXYWH,&(pxy[0]),&(pxy[1]),&(pxy[2]),&(pxy[3]));
	pxy[2] += pxy[0] - 1;
	pxy[3] += pxy[1] - 1;
	vs_clip(vdi_handle,1,pxy);		/* Clipping ein */
	nr = mfenster[0];	 			/* Nummer der editierten Matrix */
	justiere(TRUE);
	altvedx = vedx; altvedy = vedy;
	altedx  =  edx; altedy  =  edy;

	switch(taste) {

		case CUR_LEFT:		/* Cursor nach links */
			if ((!edx) && (!edy)) goto err;   /* links oben */
			edx--;
			if	((ist_symm[nr] && (edy > edx) && (edy < mtx[nr].xdim)) || (edx < 0)) {
				edx = mtx[nr].xdim - 1; edy--;
				}
			neues_feld: clr_edbuf();
				  is_edit = FALSE;
				  if (!justiere(TRUE))
				  	{

					/* An vorheriger Cursorposition normale Zahl */
					/* ----------------------------------------- */

					drucke_zahl(altvedx, altvedy,mtx[nr].m[altedy][altedx]);

					/* An neuer Cursorposition inverse Zahl 	*/
					/* ----------------------------------------- */

					vswr_mode(vdi_handle,MD_XOR);
					loesche(vedx, vedy);
					vswr_mode(vdi_handle,MD_REPLACE);
					}
				  edfenstername();
				  break;

		case CUR_RIGHT:	/* Cursor nach rechts */
			nach_rechts:
			if ((edx == mtx[nr].xdim - 1) && (edy == mtx[nr].ydim - 1)) goto err;
			edx++;
			if	(edx >= mtx[nr].xdim)
				{
				edx = 0;
				edy++;
				}
			if	(ist_symm[nr] && (edy > edx) && (edy < mtx[nr].xdim))
				edx = edy;
			goto neues_feld;

		case CUR_UP:		/* Cursor nach oben */
			if	(edy != 0) {
				edy--;
				if	(ist_symm[nr] && (edy > edx) && (edy < mtx[nr].xdim)) {
					edy++;
					goto err;
					}
				goto neues_feld;
				}
			else goto err;

		case CUR_DOWN:		/* Cursor nach unten */
			if	(edy < mtx[nr].ydim-1)
				{
				edy++;
				if	(ist_symm[nr] && (edy > edx) && (edy < mtx[nr].xdim))
					{
					edy--;
					goto err;
					}
				goto neues_feld;
				}
			else goto err;

		case HOME:	/* HOME */
			edx = edy = 0; 
			goto neues_feld;

		case UNDO: 	/* Undo */
			undo_edbuf();
			goto neues_zeichen;

		case ENTER:	/* Enter  */
		case RETURN:	/* RETURN */
			if	(zuweisung(nr,edx,edy))
				{
				m_update(nr,FALSE,mtx[nr].m[edy][edx]);
				vs_clip(vdi_handle,1,pxy);	   /* Clipping ein */
				if	((edx < mtx[nr].xdim-1) || (edy < mtx[nr].ydim-1))
					goto nach_rechts;
				else goto neues_feld;
				}
			else err: bel();
			break;

		case ESC:		/* Esc */
			clr_edbuf();
			neues_zeichen:
			is_edit = TRUE;
			drucke_edbuf(vedx,vedy);
			break;

		case BACKSPACE:	/* BS  */
		case DELETE: 		/* DEL */
			if	(cur_pos > 0) {
				edbuf[--cur_pos] = ' ';
				goto neues_zeichen;
				}
			else goto err;

		default:
			if	((taste &= 0xff) && (cur_pos < EDBUFLEN))
				{
				edbuf[cur_pos++] = taste;
				goto neues_zeichen;
				}
			else goto err;
		}
	graf_mouse(M_ON,NULL);
}
