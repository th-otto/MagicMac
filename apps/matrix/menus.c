/*********************************************************************
*
* Dieses Modul enthÑlt alle Reaktionen auf Anklicken von MenÅpunkten.
*
*********************************************************************/


/****************************************************************
*
* Der Eintrag "Åber matrix.rsc..." ist angewÑhlt worden.
*
****************************************************************/

void zeige_info(void)
{
	OBJECT *adr_info;

	rsrc_gaddr(0, INFOBOX, &adr_info);
	do_dialog(adr_info);
	ob_dsel(adr_info, INFO_OK);
}


/****************************************************************
*
* Das MenÅ "Datei" ist angewÑhlt werden.
*
****************************************************************/

int lesen(int handle)
{
	if	((Fread(handle,4L*(2L+2L+MAXDIM*MAXDIM*8L),mtx)) !=
					4L*(2L+2L+MAXDIM*MAXDIM*8L))
		return(TRUE);
	if	((Fread(handle,4L*(1L+1L),format)) !=
					4L*(1L+1L))
		return(TRUE);
	return(FALSE);
}

int schreibe(int handle)
{
	if	((Fwrite(handle,4L*(2L+2L+MAXDIM*MAXDIM*8L),mtx)) !=
					 4L*(2L+2L+MAXDIM*MAXDIM*8L))
		return(TRUE);
	if	((Fwrite(handle,4L*(1L+1L),format)) !=
					 4L*(1L+1L))
		return(TRUE);
	return(FALSE);
}

void datei_menu(void)
{
	register int i;
	extern int  oeffnen (int (*lesen)(),	 char *dateityp);
	extern int  saveas	(int (*schreibe)(), char *dateityp);
	extern void schliess(int (*schreibe)(), char *dateityp);


	switch (message[4]) {
	  case ABBRUCH:	if	(form_alert(2, "[2][Programm verlassen.][JA|NEIN]") == 1)
	  					wind_update(END_UPDATE);
						close_work();
						wind_update(BEG_UPDATE);
					break;
	  case OEFFNEN:	if	(!oeffnen(lesen, "MTX")) {
						for	(i = 0; i < 4; i++)
							m_update(i,TRUE,0.0);
						menu_ienable(adr_hauptmenu,SCHLIESS,TRUE);
						}
					break;
	  case SCHLIESS:	schliess(schreibe, "MTX");
					break;
	  case SPEI_ALS:	saveas (schreibe, "MTX");
	}
}


/****************************************************************
*
* FÅhrt den Dialog fÅr die Eingabe einer neuen x- oder y-
* Dimension sowie fÅr das Attribut "symmetrisch" als Eingabehilfe.
* Eingabeparameter:  idx = Objekt-Index der aktivierten Matrix
*
*****************************************************************/

void dim_chg(int idx)
{
	OBJECT 	*dim_info;
	char 	hori_s[3], vert_s[3];
	int 		nr,hor,ver;


	nr = idx - A_MATRIX;
	rsrc_gaddr(0, DIMBOX, &dim_info);
	if	 (ist_symm[nr])
		ob_sel (dim_info, SYMM);
	else ob_dsel(dim_info, SYMM);

	do	{
		itoa(mtx[nr].xdim, hori_s, 10);
		itoa(mtx[nr].ydim, vert_s, 10);
		((dim_info + DIMNAME)->ob_spec.free_string)[21] = 'A' + nr; /* Matrix - Name */
		(dim_info[DIM_HORI].ob_spec.tedinfo)->te_ptext  = hori_s;
		(dim_info[DIM_HORI].ob_spec.tedinfo)->te_txtlen = 3;
		(dim_info[DIM_VERT].ob_spec.tedinfo)->te_ptext  = vert_s;
		(dim_info[DIM_VERT].ob_spec.tedinfo)->te_txtlen = 3;
		ob_dsel(dim_info, DIM_OK);
		ob_dsel(dim_info, DIM_AB);
		if   (DIM_AB == do_dialog(dim_info))
			return;	   /* Abbruch */
		 }
	while ((0 == (hor = atoi(hori_s))) || (hor > MAXDIM) ||
		  (0 == (ver = atoi(vert_s))) || (ver > MAXDIM) );

	ist_symm[nr] = selected(dim_info, SYMM);
	mtx[nr].xdim = hor; mtx[nr].ydim = ver;
	if	 (nr == mfenster[0])  /* geÑnderte Matrix wird editiert */
		edx = edy = 0;
	m_update(nr,TRUE,0.0);
}


/****************************************************************
*
* FÅhrt den Dialog fÅr die Eingabe der Nachkommastellen.
* Dimension sowie fÅr das Attribut "symmetrisch" als Eingabehilfe.
* Eingabeparameter:  idx = Objekt-Index der aktivierten Matrix
*
*****************************************************************/

void nachkom(int idx)
{
	OBJECT *nach_info;
	char   nach_s[3];
	int    nr,nach;


	nr = idx - A_MATRIX;
	rsrc_gaddr(0, NACHBOX, &nach_info);

	do	{
		itoa(format[nr][1], nach_s, 10);
		((nach_info + NACHNAME)->ob_spec.free_string)[7] = 'A' + nr;  /* Matrix - Name */
		(nach_info[NSTELLEN].ob_spec.tedinfo)->te_ptext  = nach_s;
		(nach_info[NSTELLEN].ob_spec.tedinfo)->te_txtlen = 3;
		ob_dsel(nach_info, NACH_OK);
		ob_dsel(nach_info, NACH_AB);
		if   (NACH_AB == do_dialog(nach_info))
			return;							/* Abbruch */
		}
	while (!isdigit(nach_s[0]) || ((nach = atoi(nach_s)) > 15));

	format[nr][1] = nach;
	m_update(nr,TRUE,0.0);
}


/****************************************************************
*
* Das MenÅ "Editieren" ist angewÑhlt werden.
*
****************************************************************/

void edit_menu(void)
{
	OBJECT *norm_info;


	switch (message[4]) {
		case DIMENSIO: dim_chg(icsel());break;
		case NACHKOMM: nachkom(icsel());break;
		case MNORMEN : rsrc_gaddr(0, NORMBOX, &norm_info);
					ob_dsel(norm_info, NORM_OK);
					do_dialog(norm_info);
					break;
		}
}


/****************************************************************
*
* Die Flieûkomma- <zahl> wird in den <string> umgewandelt.
*
****************************************************************/

char *zahl_in_string(double zahl)
{
	int    v;


	v = ((zahl != 0) && (ABS(zahl) < 1e-10)) ? -32767 : 4;
	return(dtoa(zahl, v, 15, 4+15+2));
}


/****************************************************************
*
* Das MenÅ "Verschiedenes" ist angewÑhlt werden.
*
****************************************************************/

void versch_menu(void)
{
	int nr,i,button;
	extern double det		(MATRIXTYP a);
	extern int	charpol	 (MATRIXTYP m, double vektor[MAXDIM+1]);
	extern double matrix_norm(MATRIXTYP m, char typ);
	extern double kond_zahl  (MATRIXTYP m, char typ);
	char   zkette[200],*zahl_string,typ;
	double vektor[MAXDIM+1];
	OBJECT *norm_info;


	nr = icsel()-A_MATRIX;
	switch (message[4]) {
		case DETERMIN:
			zahl_string = zahl_in_string(det(mtx[nr]));
			strcpy(zkette, "[1][Determinante von Matrix X:| |   ");
			zkette[28] = nr+'A';
			strcat(zkette, zahl_string);
			strcat(zkette, "][OK]");
			form_alert(1,zkette);
			break;
		case CHARPOL:
			if	(!charpol(mtx[nr],vektor))
				{
				i = 0;
				do	{
					zahl_string = zahl_in_string(vektor[i]);
					strcpy(zkette, "[1][charakt. Polynom von Matrix X|Koeffizient ");
					zkette[32] = nr+'A';
					itoa(i, zkette+strlen(zkette), 10);
					strcat(zkette, ":| |");
					strcat(zkette, zahl_string);
					strcat(zkette, "][WEITER|ZURöCK|ENDE]");
					button = form_alert(1,zkette);
					if	(button == 1)
						i++;
					else i--;
					if	(i < 0)			i = 0;
					if	(i > mtx[nr].xdim)	i--;
					}
				while (button != 3);
				}
			break;
		case MNORM:
		case KONDZAHL:
			rsrc_gaddr(0, NORMBOX, &norm_info);
			if	(selected(norm_info, NORM_ZS)) typ = 'Z';
			else if (selected(norm_info, NORM_SS)) typ = 'S';
			else typ = 'E';
			strcpy(zkette, "[1][_S-");
			zkette[4] = typ;
			if	(message[4] == MNORM)
				{
				strcat(zkette, "Norm");
				zahl_string = zahl_in_string(matrix_norm(mtx[nr],typ));
				}
			else {
				strcat(zkette, "Konditionszahl");
				zahl_string = zahl_in_string(kond_zahl(mtx[nr],typ));
				}
			strcat(zkette, " von Matrix X:| |");
			zkette[strlen(zkette)-5] = nr+'A';
			strcat(zkette, zahl_string);
			strcat(zkette, "][OK]");
			form_alert(1,zkette);break;

		}
}


/****************************************************************
*
* FÅhrt den Dialog fÅr "Zeilen/Spaltentausch".
*
****************************************************************/

void vertausche(int idx)
{
	OBJECT *vert_info;
	char   vert_s[5];
	char	  vert_1[3],vert_2[3];
	int    schranke,nr,n1,n2;
	char   *zkette;
	extern void zei_exc (int nr, int z1, int z2);
	extern void spal_exc(int nr, int s1, int s2);



	rsrc_gaddr(0, VERTBOX, &vert_info);	 /* Dialog- Box		 */
	nr = idx - A_MATRIX;				 /* Matrixnr. 0..ANZMAT-1 */
	((vert_info + VERTNAME)->ob_spec.free_string)[19] = 'A' + nr;

	/* Der Dialog, d.h. das "Object" Dialogbox wird fÅr die zwei */
	/* FÑlle "Spalten vertauschen" und "Zeilen vertauschen	  */
	/* angepaût.										  */
	/* --------------------------------------------------------- */

	if	 (message[4] == SPA_VERT)
		{
		zkette	 = "Spalten";
		schranke = mtx[nr].xdim;
		}
	else {
		zkette	 = "Zeilen ";
		schranke = mtx[nr].ydim;
		}
	strncpy((vert_info + VERTNAME)->ob_spec.free_string, zkette, 7);
	vert_s[0] = vert_1[2] = vert_2[2] = EOS;

	do	{
		(vert_info[VERTZAHL].ob_spec.tedinfo)->te_ptext  = vert_s;
		(vert_info[VERTZAHL].ob_spec.tedinfo)->te_txtlen = 5;
		ob_dsel(vert_info, VERT_OK);
		ob_dsel(vert_info, VERT_AB);
		if   (VERT_AB == do_dialog(vert_info))
			return;							/* Abbruch */
		if	(strlen(vert_s) < 3)
			continue;
		vert_1[0] = vert_s[0];
		vert_1[1] = vert_s[1];
		vert_2[0] = vert_s[2];
		vert_2[1] = vert_s[3];
		}
	while((0 == (n1 = atoi(vert_1))) ||
		 (0 == (n2 = atoi(vert_2))) ||
		 (n1 > schranke) || (n2 > schranke));

	if	 (message[4] == SPA_VERT) spal_exc(nr,--n1,--n2);
	else					  zei_exc(nr,--n1,--n2);

	m_update(nr,TRUE,0.0);
}


/****************************************************************
*
* FÅhrt den Dialog fÅr "Arithmetik".
*
****************************************************************/

#define ANZ_FORMELN 	7

void arith(void)
{
		    OBJECT *arith_info;
	static   char	 eingabe[ANZ_FORMELN][60] = {'A'};
	static   char	 fehler[] = "[3][Fehler in Zeile _!][ABBRUCH]";
	register int	 eingabezeile, error;
		    int	 cx, cy, cw, ch;
	extern	int	  arith_exec(char *pgm);


	rsrc_gaddr(0, ARITHBOX, &arith_info);

	/* Die Eingabe in der Dialogbox soll direkt in das Feld */
	/* <eingabe[]> erfolgen							 */
	/* ---------------------------------------------------- */

	for	(eingabezeile = 0; eingabezeile < ANZ_FORMELN;eingabezeile++) {
		(arith_info[FORMEL1+eingabezeile].ob_spec.tedinfo)
		->te_ptext  = eingabe[eingabezeile];
		(arith_info[FORMEL1+eingabezeile].ob_spec.tedinfo)
		->te_txtlen = 40;
		}
	form_center(arith_info, &cx, &cy, &cw, &ch);
	form_dial(FMD_START, 0,0,0,0, cx, cy, cw, ch);
	objc_draw(arith_info, ROOT, MAX_DEPTH, cx, cy, cw, ch);
	do	{							/* Wiederhole Eingabe ... */
		error = FALSE;
		if	(ARITH_AB == form_do(arith_info,FORMEL1)) {
			ob_dsel(arith_info, ARITH_AB);
			break;					/* Abbruch- Feld */
			}
		ob_dsel(arith_info, ARITH_OK);
		for	(eingabezeile = 0; eingabezeile < ANZ_FORMELN;
			 eingabezeile++)
			if	(arith_exec(eingabe[eingabezeile])) {
				fehler[20] = '1' + eingabezeile;
				form_alert(1,fehler);
				error = TRUE;
				objc_draw(arith_info, ARITH_OK, 1, cx, cy, cw, ch);
				break;
				}
		}
		while(error);					  /* solange ein Fehler auftrat */
	form_dial(FMD_FINISH, 0,0,0,0,cx, cy, cw, ch);
}


/****************************************************************
*
* Das MenÅ "Umwandlungen" ist angewÑhlt werden.
*
****************************************************************/

void umwand_menu(void)
{
	int idx,nr;
	extern int  obdreieck(MATRIXTYP *m);
	extern int  hessenb  (MATRIXTYP *m);
	extern void lgs	 (MATRIXTYP *m);
	extern void transp	 (MATRIXTYP *m);
	extern int  inv	 (MATRIXTYP *a);
	extern void neg	 (MATRIXTYP *m);
	extern void rund	 (MATRIXTYP *m);


	idx = icsel();
	nr = idx - A_MATRIX;
	switch(message[4]) {
		case ZEI_VERT:
		case SPA_VERT: vertausche(idx);break;
		case ARITHMET: arith();break;
		case OBDIAGON: obdreieck(&mtx[nr]);
					label: m_update(nr,TRUE,0.0);break;
		case HESSFORM: hessenb(&mtx[nr]);goto label;
		case LGSLOES:	lgs(&mtx[nr]);goto label;
		case TRANSPON: transp(&mtx[nr]);goto label;
		case INVERT:	inv(&mtx[nr]);goto label;
		case NEG: 	neg(&mtx[nr]);goto label;
		case RUNDEN:	rund(&mtx[nr]);goto label;
		}
}
