/*********************************************************************
*
* Dieses Modul enthÑlt die Bearbeitung aller Mausklicks, also 
* Verschiebung und Aktivierung von Icons, Doppelklicks in Fenster usw.
*
*********************************************************************/


/****************************************************************
*
* Der Benutzer hat an der Bildschirmposition (x_koor,y_koor) mit
* dem <knopf> einen <anzahl>- fachen Mausklick ausgefÅhrt.
*
****************************************************************/

void mausknopf(int anzahl , int y_koor, int x_koor, int knopf)
{
	static char kopiers[] =
	   "[2][   KOPIEREN.| |von  Matrix:   X|nach Matrix:   Y][OK|ABBRUCH]";
	static char loeschs[] =
	   "[2][Matrix X lîschen.][OK|ABBRUCH]";
	static char drucks[] =
	   "[2][Matrix X ausdrucken.][OK|ABBRUCH]";
	int von,dummy,i,nach;
	void icon_malen(int index, GRECT *neu);
	void oeffne_fenster(int icon_nr);
	void lprint(int nr);
	void s_kill(int nr);
	void s_kopiere(int von, int nach);
	extern void edit(int whdl, int anz_klick, int x, int y);
	int   move_icon(int quelle,
                int *gr_dfinishx, int *gr_dfinishy,
                int *wind, int *icn);



	/* PrÅfen, welcher Mausknopf betÑtigt wurde				   */
	/* ----------------------------------------------------------- */

	knopf &= 1;			/* nur linken Mausknopf abfragen */
	if	(!knopf)
		return;

	/* von := Objektnummer des angeklickten Icons, falls vorhanden */
	/* ----------------------------------------------------------- */

	von = objc_find(adr_icons,0,1,x_koor,y_koor);

	/* i := Handle des angeklickten Fensters, falls vorhanden	   */
	/* ----------------------------------------------------------- */

	i = wind_find(x_koor,y_koor);

	/* 1. Fall: Ein Fenster ist angeklickt worden */
	/*		  Das Editierprozeû wird begonnen	 */
	/* ------------------------------------------ */

	if	(i) {
		edit(i,anzahl,x_koor,y_koor);
		return;
		}

	/* 2. Fall: Weder ein Fenster noch ein Matrixicon */
	/*		  Es ist also nichts zu tun			*/
	/* ---------------------------------------------- */

	if	(von <= 0)
		return;

	/* 3. Fall: Der Mausklick fand auf dem Objekt mit */
	/*		  der Nummer <von> statt 			*/

	/* Falls es sich um eine Matrix handelt, selektieren */
	/* ------------------------------------------------- */

	if	((!selected(adr_icons,von)) &&
		 (von >= A_MATRIX) && (von <= J_MATRIX) && (von != E_MATRIX))
		for	(i = A_MATRIX; i <= J_MATRIX; i++) {
			if	(i == von) {
				ob_sel(adr_icons,von);
				icon_malen(von, NULL);
				}
			else if	(selected(adr_icons,i)) {
					ob_dsel(adr_icons, i);
					icon_malen(i, NULL);
					}
			}

	/* Doppelklick auf Icon. Neues Fenster îffnen */
	/* ------------------------------------------ */

	if	((anzahl == 2) && (von > 0)) 
		oeffne_fenster(von);

	else {
		graf_mkstate(&x_koor,&y_koor,&i,&dummy);

		/* Ein Icon wurde angewÑhlt. Die linke Maustaste */
		/*  ist noch gedrÅckt. Icon wird verschoben	    */
		/* --------------------------------------------- */

		if	((i & 1) && (von > 0))
			{
			move_icon(von, &x_koor, &y_koor, &i, &nach);

			/* (x_koor,y_koor) : Endposition der "dragbox"   */
			/* i               : ggf. Zielwindow- Handle	    */
			/* nach            : ggf. Zielicon-   Objektnr.  */
			/* --------------------------------------------- */


			/* 1. Fall: Das Icon wurde in ein Fenster geschoben */
			/*		  Falls das Fenster eine andere Matrix	  */
			/*		  enthÑlt, kopiere <von> -> <nach> 	  */
			/* ------------------------------------------------ */

			if	(i)
				{
				nach = A_MATRIX + mfenster[hdl_to_fnr(i)];
				if	(nach == von)
					return;
				}

			/* 1. Fall: Das Icon ist in ein Fenster oder auf ein */
			/*		  anderes Icon geschoben worden		   */
			/*		  Also kopieren/lîschen/drucken		   */
			/* ------------------------------------------------- */

			if	((nach > 0) && (nach !=von)) {	  /* kopieren */
				if	((von == MIST) || (von == DRUCKER)) {
					form_alert(1, "[3][Drucker oder Papierkorb|lassen sich nicht kopieren.][ABBRUCH]");
					return;
					}
				if	((nach == E_MATRIX) ||
					 ((von == E_MATRIX) && ((nach == DRUCKER) || (nach == MIST)))) {
					form_alert(1,"[3][Die Einheitsmatrix|ist fest definiert.][ABBRUCH]");
					return;
					}
				if	(nach == DRUCKER) {
					drucks[11] = 'A'+von-A_MATRIX;
					if	(form_alert(1,drucks) == 1) {
						graf_mouse(HOURGLASS, NULL);
						lprint(von - A_MATRIX);
						graf_mouse(ARROW, NULL);
						}
					return;
					}
				if	(nach == MIST	 ) {
					loeschs[11] = 'A' + von - A_MATRIX;
					if	(form_alert(2,loeschs) == 1)
						s_kill(von - A_MATRIX);
					return;
					}
				kopiers[34] = 'A' + von	- A_MATRIX;
				kopiers[51] = 'A' + nach - A_MATRIX;
				if	(form_alert(1,kopiers) == 1)
					s_kopiere(von - A_MATRIX,nach - A_MATRIX);
				}

			/* 2. Fall: Das Icon ist nicht auf irgendein anderes	 */
			/*		  Objekt (Fenster oder Icon) geschoben worden */
			/*		  Also nur Icon verschieben				 */
			/* ---------------------------------------------------- */

			else {
				GRECT icn;

				icn.g_x = (adr_icons+von)->ob_x;
				icn.g_y = (adr_icons+von)->ob_y; /* alte Koordinaten */
				icn.g_w = (adr_icons+von)->ob_width;
				icn.g_h = (adr_icons+von)->ob_height;
				(adr_icons+von)->ob_x = (x_koor +8) & ~15;
				(adr_icons+von)->ob_y = (y_koor +8) & ~15;
				/* an alter Position lîschen */
				icon_malen(0, &icn);
				/* an neuer Position malen */
				icon_malen(von, NULL);
				}
			}
		}
}


/****************************************************************
*
* Das Icon mit der Objektnummer <index> wird neu gemalt.
* Falls es sich nicht um das "Parent"- Objekt, also das Hinter-
*  grundmuster handelt, ist nur der Ausschnitt
*	 neu_x,neu_y,neu_b,neu_h
*  neu zu malen.
*
****************************************************************/

void icon_malen(int index, GRECT *neu)
{
	GRECT icn,list;


	if	(!neu)		/* NULL- Pointer */
		{
		neu = &icn;	/* Pointer "erden" */
		neu->g_x = (adr_icons+index)->ob_x;
		neu->g_y = (adr_icons+index)->ob_y;
		neu->g_w = (adr_icons+index)->ob_width;
		neu->g_h = (adr_icons+index)->ob_height;
		}
	wind_get(SCREEN,WF_FIRSTXYWH,&list.g_x,&list.g_y,
						    &list.g_w,&list.g_h);
	do	{
		if	(rc_intersect(neu,&list))
			objc_draw(adr_icons,index,1,list.g_x,list.g_y,
								   list.g_w,list.g_h);
		wind_get(SCREEN,WF_NEXTXYWH,&list.g_x,&list.g_y,
							   &list.g_w,&list.g_h);
		}
	while(list.g_w > 0);
}


/****************************************************************
*
* Schreibt ein Zeichen auf den Drucker.
* CTRL-C	bricht den Druckvorgang sofort ab.
* Bei anderer Taste wird gefragt, ob abgebrochen werden soll.
* RÅckgabe: FALSE	OK
*		  TRUE	Abbruch
*
****************************************************************/

#define CON		2	   /* BIOS- Nummer der Tastatur */
#define CTRL_C 	0x03

int lprintc(char c)
{
	do	{
		if	(Bconstat(CON)) {	/* Wenn Taste gedrÅckt */
			while(Bconstat(CON))
				if	(CTRL_C == (0xff & Bconin(CON)))
					return(TRUE);
			if	(1 == form_alert(2,"[2][Druckvorgang abbrechen ?][ABBRUCH|WEITER]"))
				return(TRUE);
			}
		}
	while(!Cprnos());			/* solange Drucker nicht verfÅgbar */
	Cprnout(c);
	return(FALSE);
}


/****************************************************************
*
* Die Zeichenkette <zkette> wird auf den Drucker ausgegeben.
* Die Ausgabe erfolgt rechtsbÅndig in einem <breite> breiten Feld.
*
****************************************************************/

int lprint_string(char *zkette, int breite)
{
	register int i;


	for	(i = 0; i < breite-strlen(zkette); i++)
		if	(lprintc(' '))
			goto err;
	for	(i = 0; zkette[i];)
		if	(lprintc(zkette[i++]))
			goto err;
	return(0);
	err: return(1);
}


/************************************************************
*
* Druckt die Matrix mit der Nummer <nr> aus (mtx[nr]).
*
************************************************************/

#define	SI	   0x0f		/* ASCII fÅr Shift-In (Schmalschrift) */
#define	DC2	   0x12		/* ASCII fÅr Schmalschrift aus */

void lprint(int nr)
{
	register int	 ix,iy;
		    int	 vor_stellen,nach_stellen,spal_breite;
		    char   *zahl;
		    double z;


	vor_stellen = format[nr][0]; nach_stellen = format[nr][1];
	if	((spal_breite = vor_stellen + nach_stellen + 2) * mtx[nr].xdim > 80)
		lprintc(SI);					/* Schmalschrift */
	for	(iy = 0; iy < mtx[nr].ydim; iy++)
		{
		for	(ix = 0; ix < mtx[nr].xdim; ix++)
			{
			z = mtx[nr].m[iy][ix];
			zahl = dtoa(z,vor_stellen,nach_stellen,
					  vor_stellen+nach_stellen+2);
			if	(lprint_string(zahl,spal_breite))
				return;
			}
		lprintc(0x0d);lprintc(0x0a);		/* Zeilenende */
		}
	lprintc(DC2);						/* Schmalschrift aus */
	lprintc(0x0d);Cprnout(0x0a);			/* Eine Leerzeile */
}


/****************************************************************
*
* Die Matrix <nr> wird gelîscht.
*
****************************************************************/

void s_kill(int nr)
{
	extern void kill(MATRIXTYP *matrix);

	kill(&mtx[nr]);
	m_update(nr,TRUE,0.0);
}


/****************************************************************
*
* Matrizen kopieren: <von> -> <nach>
* Alle Fenster der Zielmatrix werden aktualisiert.
*
****************************************************************/

void s_kopiere(int von, int nach)
{
	int xdim,ydim;


	xdim = mtx[nach].xdim; ydim = mtx[nach].ydim;
	mtx[nach] = mtx[von];
	if	(von == ('E'-'A'))
		{
		mtx[nach].xdim = xdim;
		mtx[nach].ydim = ydim;
		}
	m_update(nach,TRUE,0.0);
}


/****************************************************************
*
* Ein Fenster wird geîffnet, das die Matrix darstellt, deren
* Icon die Nummer <icon_nr> hat.
*
****************************************************************/

void oeffne_fenster(int icon_nr)
{
	register int i;
	static char name[] = {' ','A',' ',0,0, ' ','B',' ',0,0, ' ','C',' ',0,0,
					  ' ','D',' ',0,0, ' ','E',' ',0,0, ' ','F',' ',0,0,
					  ' ','G',' ',0,0, ' ','H',' ',0,0, ' ','I',' ',0,0,
					  ' ','J',' ',0,0};


	for	(i = 1; i < ANZFENSTER; i++)
		{
		if	(fensterh[i] < 0)		/* existiert noch nicht */
			goto ok;
		}
	enwnd:
	form_alert(1, "[3][Keine Fenster mehr.][ABBRUCH]");
	return;

	ok:
	if	((icon_nr == MIST) || (icon_nr == DRUCKER) || (icon_nr == E_MATRIX))
		form_alert(1, "[3][Dieses Icon lÑût sich|nicht îffnen.][ABBRUCH]");
	else {
		if	(0 > (fensterh[i] = wind_create(FENSTERTYP, scr_x, scr_y, scr_w, scr_h)))
			goto enwnd;
		mfenster[i] = icon_nr - A_MATRIX;
		graf_growbox((adr_icons+icon_nr)->ob_x,     (adr_icons+icon_nr)->ob_y,
				   (adr_icons+icon_nr)->ob_width, (adr_icons+icon_nr)->ob_height,
				   fenster[i].g_x,fenster[i].g_y,fenster[i].g_w,fenster[i].g_h);
		wind_set(fensterh[i],WF_NAME,name+5*(icon_nr-A_MATRIX));
		wind_open(fensterh[i],fenster[i].g_x,fenster[i].g_y,fenster[i].g_w,fenster[i].g_h);
		sxfenster[i] = syfenster[i] = 0;
		gr_schieber(i);
		}
}


/****************************************************************
*
* Verschiebt ein Icon auf dem Desktop.
* Eingabe: gr_dstartx,gr_dstarty,gr_dwidth,gr_dheight
*		 (Position und Grîûe des Anfangsrechtecks)
* Ausgabe: *gr_dfinishx
*		 *gr_dfinishy
*		 (Position des Endrechtecks, Anklickpunkt)
*		 *wind
*		 (Handle des Zielfensters oder <=0)
*		 *icn
*		 (Objektnummer des Zielicons oder <=0)
*
* ZurÅckgegeben wird TRUE, wenn ein Ziel (Icon oder Fenster)
* erkannt wurde.
*
****************************************************************/

int   move_icon(int quelle,
                int *gr_dfinishx, int *gr_dfinishy,
                int *wind, int *icn)
{
	int x_koor,y_koor;		/* Anklickpunkt */
	int mouse_x,mouse_y;
	int old_x,old_y;
	int mstat,dummy;
	int pxy[10];
	int altziel = 0;
	int sel = icsel();		/* selektierte Matrix */


	vs_clip(vdi_handle, FALSE, pxy);
	vswr_mode(vdi_handle, MD_XOR);
	*wind = *icn = 0;

	graf_mouse(M_OFF, NULL);
	graf_mouse(FLAT_HAND, NULL);
	x_koor = mouse_x = *gr_dfinishx;
	y_koor = mouse_y = *gr_dfinishy;
	do	{
		pxy[0] = pxy[8] = (adr_icons+quelle)->ob_x + mouse_x-x_koor;
		pxy[1] = pxy[9] = (adr_icons+quelle)->ob_y + mouse_y-y_koor;

		if	(pxy[0] < scr_x)
			pxy[0] = scr_x;
		if	(pxy[1] < scr_y)
			pxy[1] = scr_y;
		if	(pxy[0]+(adr_icons+quelle)->ob_width > scr_x+scr_w)
			pxy[0] = scr_x+scr_w-(adr_icons+quelle)->ob_width;
		if	(pxy[1]+(adr_icons+quelle)->ob_height > scr_y+scr_h)
			pxy[1] = scr_y+scr_h-(adr_icons+quelle)->ob_height;

		pxy[8] = pxy[0];
		pxy[9] = pxy[1];

		pxy[2] = pxy[0] + (adr_icons+quelle)->ob_width;
		pxy[3] = pxy[1];

		pxy[4] = pxy[0] + (adr_icons+quelle)->ob_width;
		pxy[5] = pxy[1] + (adr_icons+quelle)->ob_height;

		pxy[6] = pxy[0];
		pxy[7] = pxy[1] + (adr_icons+quelle)->ob_height;

		v_pline(vdi_handle,5,pxy);		/* Rechteck malen */
		graf_mouse(M_ON, NULL);

		old_x = mouse_x;
		old_y = mouse_y;
		do	{
			graf_mkstate(&mouse_x, &mouse_y, &mstat, &dummy);
			}
		while(mouse_x == old_x && mouse_y == old_y && (mstat & 1));

		graf_mouse(M_OFF, NULL);
		v_pline(vdi_handle,5,pxy);		/* Recheck lîschen */
		*icn = objc_find(adr_icons,0,1,mouse_x,mouse_y);
		if	((0 != (*wind = wind_find(mouse_x, mouse_y))) ||
			 (*icn == quelle))
			*icn = 0;
		if	(*icn >= 0 && *icn != altziel)
			{
			if	(altziel != 0 && altziel != sel)
				{
				ob_dsel(adr_icons,altziel);
				icon_malen(altziel, NULL);
				}
			if	(*icn != 0)
				{
				ob_sel(adr_icons,*icn);
				icon_malen(*icn, NULL);
				}
			altziel = *icn;
			}
		}
	while(mstat & 1);

	if	(*icn > 0 && *icn != sel)
		{
		ob_dsel(adr_icons,*icn);
		icon_malen(*icn, NULL);
		}
	graf_mouse(ARROW, NULL);
	graf_mouse(M_ON, NULL);
	*gr_dfinishx = pxy[0];
	*gr_dfinishy = pxy[1];
	return((*wind > 0) || (*icn > 0));
}
