/*********************************************************************
*
* Dieses Modul enthÑlt alle Reaktionen auf "Messages" des AES, also
* Fenster- Manipulationen.
*
*********************************************************************/


/****************************************************************
*
* Das Fenster mit Handle <whdl> wird nach oben gebracht.
*
****************************************************************/

void topped(int whdl)
{
	int matrixnr,fensternr;


	if	((fensternr = hdl_to_fnr(whdl)) >= 0)
		{
		wind_set(whdl,WF_TOP);
		matrixnr = mfenster[fensternr];
		if	(neu_format[matrixnr])
			m_update(matrixnr, -1, 0.0);
		}
}


/****************************************************************
*
* Das Fenster mit Handle <whdl> wird geschlossen.
*
****************************************************************/

void closed(int whdl)
{
	register int 	 n;
	register OBJECT *icn;


	if	((n = hdl_to_fnr(whdl)) >= 0)
		{
		icn = adr_icons + mfenster[n] + A_MATRIX;
		wind_close(whdl);
		wind_delete(whdl);
		fensterh[n] = -1;	/* Handle lîschen */
		mfenster[n] = -1;	/* Matrixnummer lîschen */
		graf_shrinkbox (icn->ob_x,
					 icn->ob_y,
					 icn->ob_width,
					 icn->ob_height,
					 fenster[n].g_x, fenster[n].g_y,
					 fenster[n].g_w, fenster[n].g_h);
		}
}


/****************************************************************
*
* Das Fenster mit Handle <whdl> wird auf Maximalgrîûe gebracht.
*
****************************************************************/

void fulled(int whdl)
{
	register int n;
	GRECT   prev, full;


	if	((n = hdl_to_fnr(whdl)) < 0)
		return;
	wind_get(whdl, WF_PREVXYWH, &prev.g_x, &prev.g_y, &prev.g_w, &prev.g_h);
	wind_get(whdl, WF_FULLXYWH, &full.g_x, &full.g_y, &full.g_w, &full.g_h);
 
	/* 1. Fall: Das Fenster hat bereits Maximalgrîûe	  */
	/*		  Also muû das Fenster verkleinert werden */
	/* ------------------------------------------------ */

	if	((fenster[n].g_x == full.g_x) && (fenster[n].g_y == full.g_y) &&
		 (fenster[n].g_w == full.g_w) && (fenster[n].g_h == full.g_h))
		{
		graf_shrinkbox(prev.g_x, prev.g_y, prev.g_w, prev.g_h,
					full.g_x, full.g_y, full.g_w, full.g_h);
		full = prev;
		}

	/* 2. Fall: Das Fenster hat nicht Maximalgrîûe	  */
	/*		  Also Grîûe auf Maximum 			  */
	/* ------------------------------------------------ */

	else {
		graf_growbox(fenster[n].g_x, fenster[n].g_y,
				   fenster[n].g_w, fenster[n].g_h,
				   full.g_x, full.g_y, full.g_w, full.g_h);
		}

	siz_moved(whdl, &full);
}


/****************************************************************
*
* FÅr Fenster Nr. <n> wird berechnet:
*  <nr>	Matrixnummer
*  <x>	x - Position der obersten linken Zelle im Fenster
*  <y>	y - Position der obersten linken Zelle im Fenster
*  <ax>	horizontale Anzahl darstellbarer Zellen
*  <ay>	vertikale   Anzahl darstellbarer Zellen
*
****************************************************************/

void anzahl(int n, int *nr, int *x, int *y, int *ax, int *ay)
{
	wind_get(fensterh[n],WF_WORKXYWH,x,y,ax,ay);
	*y += gl_hhchar;
	*x += 2;
	*nr = mfenster[n];			/* Matrixnummer 0..ANZMAT-1 */
	*ax += gl_hwchar-4; 		/* wahre Breite = Br. + Rand r - Rand l */
	*ay += gl_hhchar/4; 		/* unterer Rand */
	if	(n)
		*ax /= ((format[*nr][0]+format[*nr][1]+2) * gl_hwchar);
	else *ax /= ((VOR+NACH+2) * gl_hwchar);
	*ay /= zell_hoch;			/* wh/zell_hoch  */
}


/****************************************************************
*
* <ebene> = 0 : vertikaler Schieber geÑndert, sonst: horizontaler
* FÅr das Fenster Nr. <n> wird der entsprechende Schieber neu
* gezeichnet und das Fenster neu ausgegeben.
*
****************************************************************/

void pos_schieber(int n, int ebene, int diff)
{
	wind_set(fensterh[n],(ebene) ? WF_HSLIDE : WF_VSLIDE,
		    (1000 * ((ebene) ? sxfenster[n] : syfenster[n])) / diff);
	redraw(fensterh[n],scr_x,scr_y,scr_w,scr_h);
}


/****************************************************************
*
* Im Fenster mit Handle <whdl> ist einer der Scrollpfeile
* angeklickt worden.
*
****************************************************************/

void arrowed(int whdl, int code)
{
	int *sxy,ebene,beweg,diff,n,nr,axy,ax,dummy;


	if	((n = hdl_to_fnr(whdl)) < 0)
		return;
	ebene = code & 4;					/* horizontal = TRUE  */
	beweg = 2*(code & 1) - 1;			/* neg = -1, pos. = 1 */
	anzahl(n,&nr,&dummy,&dummy,&ax,&axy);
	if	(ebene)						/* Wenn vertikal...   */
		axy = ax; 					/* max darstellbare Zellen */
	if	(!(code & 2))	 			/* Wenn grauer Balken geklickt */
		beweg *= axy;
	diff = ((ebene) ? mtx[nr].xdim : mtx[nr].ydim) - axy;
	sxy = (ebene) ? sxfenster : syfenster;
		  /* um "diff" viele Positionen kann Åberhaupt geshiftet werden */
	ax = sxy[n];
	sxy[n] += beweg;
	if	(sxy[n] > diff) sxy[n] = diff;
	if	(sxy[n] < 0   ) sxy[n] = 0;
	if	(sxy[n] != ax)
		pos_schieber(n,ebene,diff);
}


/****************************************************************
*
* Die Schiebergrîûe des Fensters mit der Nummer <n> wird neu
* berechnet und die Position der Schieber korrigiert.
*
****************************************************************/

void gr_schieber(int n)
{
	int ax,ay,nr,schieb_breit,schieb_hoch,dummy;

	anzahl(n,&nr,&dummy,&dummy,&ax,&ay);
	schieb_breit = (1000 * ax)/mtx[nr].xdim;
	schieb_hoch  = (1000 * ay)/mtx[nr].ydim;
	if	(schieb_breit > 1000) schieb_breit = 1000;
	if	(schieb_hoch  > 1000) schieb_hoch	= 1000;
	wind_set(fensterh[n],WF_HSLSIZE,schieb_breit);
	wind_set(fensterh[n],WF_VSLSIZE,schieb_hoch);

	ax = mtx[nr].xdim - ax;	  /* um soviele Positionen kann geshiftet werden */
	ay = mtx[nr].ydim - ay;	  /* es kînnen auch ax oder ay negativ sein */
	if	(sxfenster[n] > ax) sxfenster[n] = ax;
	if	(syfenster[n] > ay) syfenster[n] = ay;
	if	(sxfenster[n] < 0 ) sxfenster[n] = 0;
	if	(syfenster[n] < 0 ) syfenster[n] = 0;
	if	(ax != 0)
		ax = (1000 * sxfenster[n]) / ax;
	if	(ay != 0)
		ay = (1000 * syfenster[n]) / ay;
	wind_set(fensterh[n],WF_HSLIDE,ax);
	wind_set(fensterh[n],WF_VSLIDE,ay);
}


/****************************************************************
*
* Im Fenster mit Handle <whdl> ist einer der Scrollbalken
* bewegt worden.
*
****************************************************************/

void h_vslid(int whdl, int ishor, int pos)
{
	int	*sxy,diff,n,nr,axy,ax;


	if	((n = hdl_to_fnr(whdl)) < 0)
		return;
	anzahl(n,&nr,&diff,&diff,&ax,&axy);	/* nr = matrixnummer */
	if	(ishor)
		axy = ax; 					/* max. darstellbare Zellen */
	diff = ((ishor) ? mtx[nr].xdim : mtx[nr].ydim) - axy;
	sxy = (ishor) ? sxfenster : syfenster;
		  /* um "diff" viele Positionen kann Åberhaupt geshiftet werden */
	ax = sxy[n];
	sxy[n] = (diff * pos + 500) / 1000;
	if	(sxy[n] != ax)
		pos_schieber(n, ishor, diff);
}


/****************************************************************
*
* Das Fenster mit Handle <whdl> ist in seiner Grîûe
* verÑndert oder verschoben worden. Die neue Position ist <*g>
*
****************************************************************/

void siz_moved(int whdl, GRECT *g)
{
	register int n,x,y,w,h;


	if	((n = hdl_to_fnr(whdl)) < 0)
		return;					/* Handle ungÅltig */
	if	(g->g_w < MINBREITE)
		g->g_w = MINBREITE;			/* Breite zu klein */
	if	(!memcmp(&fenster[n], g, sizeof(GRECT)))
		return;					/* keine énderung */
	x = sxfenster[n];
	y = syfenster[n];
	if	(wind_set(whdl, WF_CURRXYWH, *g))
		{
		w = fenster[n].g_w;
		h = fenster[n].g_h;
		fenster[n] = *g;
		if	(w != g->g_w || h != g->g_h)
			gr_schieber(n); /* Schieber neu berechnen */
		if	(x != sxfenster[n] || y != syfenster[n])
			send_redraw(n); /* Fenster hat gescrollt */
		}
}


/****************************************************************
*
* Die folgende "Message" tritt nicht auf und hat keine Bedeutung.
*
****************************************************************/

#pragma warn -par

void newtop(int whdl)
{
}

#pragma warn +par


/****************************************************************
*
* Die Taste mit <code> ist betÑtigt worden.
*
****************************************************************/

void tastatur(int code)
{
	int	thdl,dummy;
	void openedit(int matrixnr, int ex, int ey);
	int 	justiere(int drawflag);
	void drucke(int taste);


	/* Welches Fenster liegt oben ? */
	/* ---------------------------- */

	wind_get(0,WF_TOP,&thdl,&dummy,&dummy,&dummy);

	/* 1. Fall: Das Editierfenster ist noch nicht geîffnet */
	/*		  Also îffnen mit Cursor in (0,0) und der	*/
	/*		  selektierten Matrix					*/
	/* --------------------------------------------------- */

	if	(mfenster[0] < 0)
		openedit(icsel()-A_MATRIX,0,0);

	/* 2. Fall: Das Editierfenster ist schon geîffnet 	*/
	/* --------------------------------------------------- */

		/* 1. Fall: Das Editierfenster ist nicht das oberste */
		/*		  Also nach oben bringen und Cursor in den */
		/*		  sichtbaren Bereich				   */
		/* ------------------------------------------------- */

	else if	(thdl != fensterh[0]) {
			topped(fensterh[0]);
			justiere(TRUE);
			}

		/* 2. Fall: Das Editierfenster ist das oberste	*/
		/*		  Also Tastenbefehl ausfÅhren 		*/
		/* ---------------------------------------------- */

		else drucke(code);
}
