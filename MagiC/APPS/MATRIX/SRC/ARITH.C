/*********************************************************************
*
* Dieses Modul enthÑlt die Auswertung und AusfÅhrung einer arithmeti-
* schen Anweisung mit den Objekten:
*
*  1) Matrizen A..J
*  2) Reelle Zahlen (auch BrÅche)
*  3) Operatoren "+","-","*","/" (/ fÅr Multiplikation mit der Inversen)
*  4) Klammern "(",")"
*
*********************************************************************/


#include "m.h"
#include <ctype.h>
#include <stdlib.h>
#include <stddef.h>

#define  EMATRIX		4

#define  TOK_MATRIX 	1
#define  TOK_ZAHL		2
#define  TOK_OPERATOR	3
#define  TOK_KLAMMER	4
#define  TOK_EOS		0
#define  TOK_ERROR		-1


/* Externals aus "m.c" */
extern void	kill	 (MATRIXTYP *matrix);
extern void	neg	 (MATRIXTYP *m);
extern void	transp(MATRIXTYP *m);
extern double	det	 (MATRIXTYP a);
extern int	inv	 (MATRIXTYP *a);
extern void	adde	 (MATRIXTYP *nachmatrix, double r);
extern int	add	 (MATRIXTYP *nachmatrix, double r, MATRIXTYP *matrix);
extern int	mult	 (MATRIXTYP *nachmatrix, MATRIXTYP *matrix1, MATRIXTYP *matrix2);

/* Externals aus "shell.c" */
extern void 	m_update	(int nr, int edflag, double neu_zahl);


/****************************************************************
*
* FÅhrt den Befehl aus. RÅckgabe 0, wenn OK.
* Der Befehl besteht aus der Zeichenkette <pgm>.
*
* <zuweisung>	:= <matrixname> = <expression>
* <expression> := <operand> [ <operator> <operand> ]
*
****************************************************************/

int arith_exec(char pgm[100])
{
	int		ziel;
	char 	operator;
	MATRIXTYP m1,m2,m3;
	MATRIXTYP *quellmatrixp;
	int 		matrix_nummer(char c);
	void 	skip_space(char *(string[]));
	int		operand(char *(zkette[]), MATRIXTYP *m);


	if	(pgm[0] == EOS)
		return(0);

	/* Ziel der Zuweisung feststellen */
	/* ------------------------------ */

	if	(((ziel = matrix_nummer(pgm[0])) < 0) || ziel == EMATRIX)
		return(1);
	pgm++;
	quellmatrixp = &m1;

	/* Ersten Operanden einlesen */
	/* ------------------------- */

	m1.xdim = m2.xdim = mtx[EMATRIX].xdim = mtx[ziel].xdim;
	m1.ydim = m2.ydim = mtx[EMATRIX].ydim = mtx[ziel].ydim;
	if	(operand(&pgm,&m1))
		return(-1);
	skip_space(&pgm);

	/* Operator einlesen */
	/* ----------------- */

	operator = pgm[0]; pgm++;

	/* Wenn Operator existiert, zweiten Operanden einlesen */
	/* --------------------------------------------------- */

	if	(operator != EOS)
		{
		if	(operand(&pgm,&m2))
			return(-1);

		/* Operation ausfÅhren */
		/* ------------------- */

		switch (operator) {
			case '-': neg(&m2);
			case '+': if	(add(&m1,1.0,&m2))	return(-1);
					else break;
			case '/': if	(inv(&m2))		return(-1);
			case '*': if	(mult(&m3,&m1,&m2)) return(-1);
					else quellmatrixp = &m3;
					break;
			default : 					return(-1);
			}
		}

	/* Zuweisung und Update der Fenster */
	/* -------------------------------- */

	mtx[ziel] = *quellmatrixp;
	m_update(ziel,TRUE,0.0);
	return(0);
}


/****************************************************************
*
* öberspringt Leerstellen im <string>.
*
****************************************************************/

void skip_space(char *(string[]))
{
	while((**string == ' ') && (**string != EOS))
		(*string)++;
}


/****************************************************************
*
*	lexikalischer Scanner.
* Eingabe: <zkette> 	zu untersuchende Zeichenkette
* Ausgabe: <wert>		Wert der Flieûkommazahl, falls vorhanden
*		 <zeichen>	Zeichen der Matrix bzw. des Operators
*					 bzw. der Klammer
* RÅckgabe: Art des Tokens (Matrix, Zahl, Operator, Klammer)
*		   oder TOK_ERROR oder TOK_EOS
*
* <matrix>   := A | a | B | b | ... | Z | z
* <zahl>	   := .....
* <operator> := + | - | * | /
* <klammer>  := ( | )
*
****************************************************************/

int token(char *(zkette[]), double *wert, char *zeichen)
{
	register char c;
	int scan_float(char *eingabe, double *z, char **endptr);



	skip_space(zkette);
	c = **zkette;

	/* 1. Fall: MATRIX */
	/* --------------- */

	if	 ((*zeichen = matrix_nummer(c)) >= 0)
		{
		(*zkette)++;
		return(TOK_MATRIX);
		}

	/* 2. Fall: ZAHL */
	/* ------------- */

	if	 (0 == scan_float(*zkette, wert, zkette))
		return(TOK_ZAHL);

	/* 3. Fall: OPERATOR, KLAMMER */
	/* -------------------------- */

	*zeichen = c;
	(*zkette)++;
	switch (c) {
		case '+':
		case '-':
		case '*':
		case '/': return(TOK_OPERATOR);
		case '(':
		case ')': return(TOK_KLAMMER);
		case EOS: return(TOK_EOS);
	}
	return(TOK_ERROR);
}


/****************************************************************
*
* <operand> := <zahl>  |  [ <zahl> * ] <matrix>
*
* Eingabe:	<zkette> wird durchsucht
* Ausgabe:	m	    enthÑlt die eingelesene Matrix
* RÅckgabewert : 0 fÅr OK, sonst -1
*
****************************************************************/

int operand(char *(zkette[]), MATRIXTYP *m)
{
	int	  n;
	double zahl;
	char   operator;
	char   *zeiger;


	n = token(zkette,&zahl,&operator);
	switch(n) {

		/* 1. Fall: Kein oder falsches Token */
		/* --------------------------------- */

		case TOK_EOS:
		case TOK_ERROR:
		case TOK_OPERATOR:
		case TOK_KLAMMER:  return(-1);

		/* 2. Fall: <matrix>			  */
		/* --------------------------------- */

		case TOK_MATRIX: *m = mtx[(int) operator];
					  return(0);

		/* 3. Fall: <zahl> [ * <matrix> ]	  */
		/* --------------------------------- */

		case TOK_ZAHL: kill(m);
				skip_space(zkette);

				/* 1. Fall: <zahl>			*/
				/*		  m := zahl * E	*/
				/* -------------------------- */

				if	((operator = *(zkette[0])) != '*')
					{
					nur_zahl: adde(m,zahl);
					return(0);
					}

				/* 2. Fall: <zahl> * <matrix> */
				/* -------------------------- */

				else {
					zeiger = (*zkette);
					(*zkette)++;
					skip_space(zkette);
					if	((n = matrix_nummer(*(zkette[0]))) >= 0)
						{
						(*zkette)++;
						return(add(m,zahl,&mtx[n]));
						}
					else {
						(*zkette) = zeiger;
						goto nur_zahl;
						}
					}
		}
	return(0);
}


/****************************************************************
*
* Rechnet das Zeichen <c> in eine Matrixnummer (0..ANZMAT-1) um
* und gibt diese zurÅck.
* Bei Fehler: RÅckgabe -1
*
****************************************************************/

static int matrix_nummer(char c)
{
	c = toupper(c);
	if	((c < 'A') || (c > 'J'))
		return (-1);
	else return(c - 'A');
}


/****************************************************************
*
* Ersatz fÅr die ungenaue Funktion "strtod".
* Untersucht einen String, ob er eine Flieûkommazahl enthÑlt, und
* gibt diese ggf. zurÅck.
* Bei Fehler: RÅckgabe -1, *endptr unverÑndert
*
****************************************************************/

int scan_float(char *eingabe, double *z, char **endptr)
{
	register char *s;


	/* Spaces Åberlesen */
	/* ---------------- */
	skip_space(&eingabe);
	s = eingabe;

	/* optionales Vorzeichen Åberlesen */
	/* ------------------------------- */
	if	(*s == '+' || *s == '-')
		s++;

	/* erstes Zeichen muû Ziffer oder Punkt sein */
	/* ----------------------------------------- */
	if	(isdigit(*s))
		{
		do
			s++;
		while(isdigit(*s));
		}
	else {
		if	(*s != '.')
			return(-1);
		}

	/* falls ein Punkt folgt, mÅssen Ziffer folgen */
	/* ------------------------------------------- */
	if	(*s == '.')
		{
		if	(!isdigit(*++s))
			return(-1);
		do
			s++;
		while(isdigit(*s));
		}

	/* falls eine 'e' oder 'E' folgt, muû Zahl folgen */
	/* ---------------------------------------------- */
	if	(toupper(*s) == 'E')
		{
		s++;
		
		/* optionales exp- Vorzeichen Åberlesen */
		/* ------------------------------------ */
		if	(*s == '+' || *s == '-')
			s++;

		/* es muû mindestens eine Ziffer kommen */
		/* ------------------------------------ */
		if	(!isdigit(*s))
			return(-1);
		do
			s++;
		while(isdigit(*s));
		}
	*endptr = s;
	*z = strtod(eingabe, NULL);
	return(0);			/* kein Fehler */
}
			
