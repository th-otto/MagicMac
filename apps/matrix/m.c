/*********************************************************************
*
* Dieses Modul enthÑlt den mathematischen Teil von MATRIX, also die
* Algorithmen zur Matrix- Manipulation.
*
*********************************************************************/

#include <string.h>
#include <aes.h>
#include <math.h>
#include "m.h"

#define ERR_OK 		0
#define ERR_SING	    -1	/* die Matrix ist singulÑr */
#define ERR_QUAD	    -2	/* die Matrix ist nicht quadratisch */
#define ERR_DIM	    -3	/* die Dimensionen stimmen nicht Åberein */

#define ERR_POSDEF	    -4	/* nicht positiv definit ist			    */
#define ERR_SYMM	    -5	/* nicht symmetrisch ist 			    */
#define ERR_TRI	    -6	/* nicht tridiagonal ist 			    */
#define ERR_KONV	    -7	/* kein Konvergenzkriterium erfÅllt ist     */
#define ERR_ITER	    -8	/* die maximale Anzahl von Iterationen	    */
						/* Åberschritten ist				    */

extern void m_update(int nr, int edflag, double neu_zahl);

void d_dia(DOPPELMTYP *dm);


/****************************************************************
*
* Gibt Meldungen fÅr Fehlercode aus und den Fehlercode weiter.
*
****************************************************************/

int err_alert(int err)
{
	register char *errstr = "";
		    char alertstring[200];


	switch(err) {
		case ERR_SING : errstr = "Die Matrix ist singulÑr";
					 break;
		case ERR_QUAD : errstr = "Die Matrix ist nicht|quadratisch";
					 break;
		case ERR_DIM  : errstr = "Die Dimension stimmt|nicht Åberein";
					 break;
		}

	strcpy(alertstring,"[3][");
	strcat(alertstring, errstr);
	strcat(alertstring,"!][ABBRUCH]");

	form_alert(1,alertstring);
	return(err);
}


/****************************************************************
*
* Lîscht die Matrix <matrix>, d.h setzt alle Elemente auf 0.
* Die Dimension bleibt unverÑndert.
*
****************************************************************/

void kill(MATRIXTYP *matrix)
{
	register int x,y;


	for	(y = 0; y < MAXDIM; y++)
		for	(x = 0; x < MAXDIM; x++)
			matrix->m[y][x] = 0.0;
}


/****************************************************************
*
* Kopiert die Matrix <von> in die Doppelmatrix <nach>.
* Die zusÑtzlichen Elemente in <nach> bleiben unverÑndert.
*
****************************************************************/

void mtyp_to_dmtyp(MATRIXTYP *von, DOPPELMTYP *nach)
{
 register int x,y;


	for	(y = 0;y < MAXDIM; y++)
		for	(x = 0; x < MAXDIM; x++)
			nach->m[y][x] = von->m[y][x];
	nach->xdim = von->xdim;
	nach->ydim = von->ydim;
}


/****************************************************************
*
* Kopiert die Doppelmatrix <von> in die Matrix <nach>.
* Die zusÑtzlichen Elemente in <von> werden ignoriert.
*
****************************************************************/

void dmtyp_to_mtyp(DOPPELMTYP *von, MATRIXTYP *nach)
{
	register int x,y;

	for	(y = 0; y < MAXDIM; y++)
		for	(x = 0; x < MAXDIM; x++)
			nach->m[y][x] = von->m[y][x];
	nach->xdim = von->xdim;
	nach->ydim = von->ydim;
}


/****************************************************************
*
* Vertauscht in der Matrix mtx[<nr>] die Zeilen <z1> und <z2>.
*
****************************************************************/

void zei_exc(int nr, int z1, int z2)
{
	register int i;
	double temp;


	for	(i = 0; i < mtx[nr].xdim; i++) {
		temp = mtx[nr].m[z1][i];
		mtx[nr].m[z1][i] = mtx[nr].m[z2][i];
		mtx[nr].m[z2][i] = temp;
		}
}


/****************************************************************
*
* Vertauscht in der Matrix mtx[<nr>] die Spalten <s1> und <s2>.
*
****************************************************************/

void spal_exc(int nr, int s1, int s2)
{
	register int i;
	double temp;


	for	(i = 0; i < mtx[nr].ydim; i++) {
		temp = mtx[nr].m[i][s1];
		mtx[nr].m[i][s1] = mtx[nr].m[i][s2];
		mtx[nr].m[i][s2] = temp;
		}
}


/****************************************************************
*
* Wandelt die Matrix <m> mit Gauss- Verfahren in eine Diagonal-
* matrix, soweit mîglich.
*
****************************************************************/

void lgs(MATRIXTYP *m)
{
	DOPPELMTYP dm;


	mtyp_to_dmtyp(m,&dm);
	d_dia(&dm);
	dmtyp_to_mtyp(&dm,m);
}


/****************************************************************
*
* Negiert die Matrix <m>, d.h. negiert jedes Element
*
****************************************************************/

void neg(MATRIXTYP *m)
{
	register int i,j;

	for	(i = 0; i < m->ydim; i++)
		for	(j = 0; j < m->xdim;)
			m->m[i][j++] *= -1;
}


/****************************************************************
*
* Rundet die Matrix <m>, d.h. setzt alle Elemente < EPSILON = 0
*
****************************************************************/

void rund(MATRIXTYP *m)
{
	register int i,j;


	for	(i = 0; i < MAXDIM; i++)
		for	(j = 0; j < MAXDIM; j++)
			if	(fabs(m->m[i][j]) < EPSILON)
				m->m[i][j] = 0.0;
}


/****************************************************************
*
* Transponiert die Matrix <m>.
*
****************************************************************/

void transp(MATRIXTYP *m)
{
	register int i,j;
	double b[MAXDIM][MAXDIM];


	for	(i = 0; i < m->ydim; i++)
		for	(j = 0; j < m->xdim;)
			b[j++][i] = m->m[i][j];

	i = m->xdim;
	m->xdim = m->ydim;
	m->ydim = i;

	for	(i = 0; i < m->ydim; i++)
		for	(j = 0; j < m->xdim;)
			m->m[i][j++] = b[i][j];
}


/****************************************************************
*
*
* OBDREIECK() :
*  Wandelt die Matrix <m> mit Gauss- Verfahren in eine obere
*  Dreiecksmatrix und gibt +/-1 fÅr die Determinante aus.
* D_OBDREIECK() :
*  Dito fÅr eine Doppelmatrix.
*
****************************************************************/

int d_obdreieck(DOPPELMTYP *dm)
{
	register int i,j,s,t,n,m;
	double	   temp;
	int		   vz_det;


	vz_det = 1;
	n = dm->ydim; m = dm->xdim;
	s = 0;		    /* Suche 1. Stufe  s=Zeile/t=Spalte */

	for	(t = 0; t < m; t++) {
		for	(j = s,i = n,temp = 0.0; j < n; j++)	/* Pivot- Wahl */
			if	(fabs(dm->m[j][t]) > temp) {
				temp = fabs(dm->m[j][t]);
				i = j;
				}
		if	(i < n) { 						/* Spalte<>0 */
			if	(i != s) {					/* Zeile vertauschen */
				for	(j = 0; j < m; j++) {
					temp = (*dm).m[s][j];
					dm->m[s][j] = dm->m[i][j];
					dm->m[i][j] = temp;
					}
				vz_det = -vz_det;				/* Vorz. f. Determ. */
				}
			for	(i = s+1; i < n; i++) {
				if	(dm->m[i][t]) {
					temp = -dm->m[i][t]/dm->m[s][t];
					for	(j = 0; j < m; j++) {
						dm->m[i][j] += temp * dm->m[s][j];
/* runden: */				if	(fabs(dm->m[i][j]) < 1e-14 * MIN( fabs(temp), fabs(dm->m[s][j])))
							dm->m[i][j] = 0.0;
						}
					dm->m[i][t] = 0.0;
					}
				}
			s++;
			}
		}
	return(vz_det);
}

int obdreieck(MATRIXTYP *m)
{
	register int vz_det;
	DOPPELMTYP dm;


	mtyp_to_dmtyp(m,&dm);
	vz_det = d_obdreieck(&dm);
	dmtyp_to_mtyp(&dm,m);
	return(vz_det);
}


/****************************************************************
*
* Wandelt die Matrix <m> mit Wilkinson- Verfahren in eine
* Hessenberg- Form mit nur 1en und 0en auf der Subdiagonalen.
*
****************************************************************/

int hessenb(MATRIXTYP *m)
{
	register int i,j,k,n;
	double r, c[MAXDIM];


	if	((n = m->xdim) != m->ydim)
		return(err_alert(ERR_QUAD));

	for	(k = 0; k < n-2; k++) {
		j = k+1;
		for	(i = k+2; i < n; i++)
			if	(fabs(m->m[i][k]) > fabs(m->m[j][k]))
				j = i;		/* Pivotelement suchen */
		if	(j > k+1) {
			for	(i = 0; i < n; i++) {
				r = m->m[k+1][i];
				m->m[k+1][i] = m->m[j][i];
				m->m[j]  [i] = r;
				}
			for	(i = 0; i < n; i++) {
				r = m->m[i][k+1];
				m->m[i][k+1] = m->m[i][j];
				m->m[i]  [j] = r;	   /* Zle/Spl- Tausch*/
				}
			}

		if	(m->m[k+1][k] != 0) {
			for	(i = k+2; i < n; i++) {
				c[i] = m->m[i][k]/m->m[k+1][k];
				m->m[i][k] = 0;
				}
			for	(i = k+2; i < n; i++)
				for	(j = k+1; j < n; j++)
					m->m[i][j]   -= c[i]*m->m[k+1][j];
			for	(i = k+2; i < n; i++)
				for	(j = 0; j < n; j++)
					m->m[j][k+1] += c[i]*m->m[j]	[i];
			} /* END IF (!= 0) */

		} /* END FOR k */

	c[0] = 1.0;			  /* 1en und 0en auf Subdiagonale */
	for	(i = 1; i < n; i++)
		c[i] = (m->m[i][i-1]) ? c[i-1]/m->m[i][i-1] : 1.0;
	for	(i = 0; i < n; i++)
		for	(j = 0; j < n; j++)
			m->m[i][j] *= c[i]/c[j];
	return(ERR_OK);
}



/****************************************************************
*
* Bestimmt die Determinante der Matrix <a>.
*
****************************************************************/

double det(MATRIXTYP a)
{
	register int i,n;
	double   r;


	n = MIN( a.ydim, a.xdim );
	for (r = 1.0 * obdreieck(&a), i = 0; i < n;)
	    r *= a.m[i++][i];
	return(r);
}


/****************************************************************
*
* Bestimmt im <vektor[]> das charakteristische Polynom der
* Matrix <m>.
* In <vektor[i]> wird der Koeffizient  a  geschrieben.
*								i
****************************************************************/

int charpol(MATRIXTYP m, double vektor[MAXDIM+1])
{
	register int i,j,k,n;
	double f[MAXDIM+1][MAXDIM];


	if	(hessenb(&m)) return(1); 	  /* Matrix nicht quadratisch */
	else {
		 n = m.xdim;
		 for (i = 0; i < n; i++)
			for (j = 0; j < n; j++) {
			    m.m[i][j] *= -1.0;
			    f[i][j] = (double) (i == j);
			    }

		 for (i = 1; i < n; i++)
			if (m.m[i][i-1] == 0.0)
			   for (j = 0; j < i; j++)	/* Kromke - Verfahren */
				  m.m[j][i] = 0.0;

		 for (j = 0; j < n; j++) {
			f[n][j] = 0.0;
			for (i = j+1; i < n+1; i++) {
			    for (k = j; k <= i-1; k++)
				   f[i][j] += m.m[k][i-1]*f[k][j];
			    if (j > 0) f[i][j] += f[i-1][j-1];
			    }
			}
		 for (j = 0; j < n; j++) vektor[j] = f[n][j];
		 vektor[n] = 1.0;
		 return(ERR_OK);
		}	 /* vektor[i] ist Koeffizient von x^i */
}


/****************************************************************
*
* Die Doppelmatrix <dm> wird, soweit mîglich, auf Diagonalform
* gebracht.
*								i
****************************************************************/

void d_dia(DOPPELMTYP *dm)
{
	register int n,m,i,j,k,l;


	m = dm->xdim;
	n = MIN(dm->xdim,dm->ydim);
	d_obdreieck(dm);
	for	(i = n - 1; i >= 0; i--) {
		j = i;
		while((dm->m[i][j] == 0) && (j++ < n))
			;
		if	(j < n) {
			for	(k = m - 1; k >= j; k--)
				dm->m[i][k] /= dm->m[i][j];
			for	(k = i - 1; k >= 0; k--)
				for	(l = m - 1; l >= j; l--)
					dm->m[k][l] -=dm->m[k][j]/dm->m[i][j]*dm->m[i][l];
			} /* END IF */
		}   /* END FOR i */
}


/****************************************************************
*
* Die Matrix <a> wird invertiert.
*
****************************************************************/

int inv(MATRIXTYP *a)
{
	DOPPELMTYP ma;
	register int i,j,n;
	double det;


	if	((n = a->xdim) != a->ydim)
		return(err_alert(ERR_QUAD));

	mtyp_to_dmtyp(a,&ma);
	for	(i = 0; i < n; i++)
		for	(j = n; j < n+n; j++)
			ma.m[i][j] = (double)(i == j-n);
	ma.xdim = n+n;
	d_dia(&ma);

	for	(det = 1.0, i = 0; i < n;)
		det *= ma.m[i++][i];

	if	(det == 0.0)
		return(err_alert(ERR_SING));
	else {
		for	(i = 0; i < n; i++)
			for	(j = 0; j < n; j++)
				a->m[i][j] = ma.m[i][j+n];
		}
	return(ERR_OK);
}


/****************************************************************
*
* Berechnet die Matrixnorm von Matrix <a>.
* <typ>  =	'E'	Erhard-Schmidt-Norm (ES)
*			'S'	Spaltensummen-Norm	(SS)
*			'Z'	Zeilensummen-Norm	(ZS)
*
****************************************************************/

double matrix_norm(MATRIXTYP m, char typ)
{
	register int i,j;
	extern double sqrt();
	double   r,max;


	max = 0.0;
	switch (typ) {
		  case 'E': for (i = 0; i < m.xdim; i++)
					 for (j = 0; j < m.ydim; j++)
						max += m.m[i][j]*m.m[i][j];
				  max = sqrt(max);
				  break;
		  case 'S': for (j = 0; j < m.ydim; j++) {
					 r = 0.0;
					 for (i = 0; i < m.ydim; i++)
						r += fabs(m.m[i][j]);
					 max = MAX(max,r);
					 }
				  break;
		  case 'Z': for (i = 0; i < m.xdim; i++) {
					 r = 0.0;
					 for (j = 0; j < m.ydim; j++)
						r += fabs(m.m[i][j]);
					 max = MAX(max,r);
					 }
				  break;
		  }
	return(max);
}


/****************************************************************
*
* Berechnet die Konditionszahl von Matrix <a>.
* <typ>  =	'E'	Erhard-Schmidt (ES)
*			'S'	Spaltensummen	(SS)
*			'Z'	Zeilensummen	(ZS)
*
****************************************************************/

double kond_zahl(MATRIXTYP m, char typ)
{
	MATRIXTYP ma;

	ma = m;
	inv(&ma);
	return(matrix_norm(m,typ) * matrix_norm(ma,typ));
}


/****************************************************************
*
* nachmatrix := nachmatrix + r * E
*
****************************************************************/

void adde(MATRIXTYP *nachmatrix, double r)
{
	register int i;


	for	(i = 0; i < MIN(nachmatrix->ydim,nachmatrix->xdim); i++)
		nachmatrix->m[i][i] += r;
}


/****************************************************************
*
* nachmatrix := nachmatrix + r * matrix
*
****************************************************************/

int add(MATRIXTYP *nachmatrix, double r, MATRIXTYP *matrix)
{
	register int i,j;


	if	((nachmatrix->xdim == matrix->xdim) &&
		 (nachmatrix->ydim == matrix->ydim)) {
		for	(i = 0; i < nachmatrix->ydim; i++)
			for (j = 0; j < nachmatrix->xdim; j++)
				nachmatrix->m[i][j] += r * matrix->m[i][j];
		return(ERR_OK);
		}
	else return(err_alert(ERR_DIM));
}


/****************************************************************
*
* nachmatrix := matrix1 * matrix2
*
****************************************************************/

int mult(MATRIXTYP *nachmatrix,MATRIXTYP *matrix1,MATRIXTYP *matrix2)
{
	register int i,j,k;


	if	(matrix1->xdim == matrix2->ydim) {
		nachmatrix->xdim = matrix2->xdim;
		nachmatrix->ydim = matrix1->ydim;
		for	(i = 0; i < nachmatrix->ydim; i++)
			for	(j = 0; j < nachmatrix->xdim; j++) {
				nachmatrix->m[i][j] = 0.0;
				for	(k = 0; k < matrix1->xdim; k++)
					nachmatrix->m[i][j] += matrix1->m[i][k] * matrix2->m[k][j];
				}
		return(ERR_OK);
		}
	else return(err_alert(ERR_DIM));
}