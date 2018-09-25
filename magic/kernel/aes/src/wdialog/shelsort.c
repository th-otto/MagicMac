/*******************************************************************
*
*                          SHELSORT.O		8.1.89
*                          ==========
*
*         letzte Modifikation:			29.10.95
*
* MODUL fÅr Shellsort- Algorithmus.
* Syntax wie bei QSORT.
* Der Algorithmus ist NICHT rekursiv, funktioniert daher
*  auch bei kleinem Stack.
* Der Algorithmus ist bestmîglich optimiert, indem:
*
* 1) AUSSCHLIEûLICH register- Variablen benutzt werden
* 2) nicht mit Indizes, sondern mit Zeigern gerechnet wird,
*	damit alle Multiplikationen auûerhalb der inneren Schleifen
*	ausgefÅhrt werden
* 3) FÅr long oder void * wird eine besonders schnelle Vertauschung
*    von Elementen durchgefÅhrt
*
* NEU:	<udata> wird an die Vergleichsfunktion Åbergeben, um
*		z.B. Sortiermodi zu ermîglichen.
*
* Verbesserungsmîglichkeit: assembleroptimierte memxchg- Funktion
*
*******************************************************************/

#include <string.h>

static void longxchg(char *s1, char *s2, long count)
#pragma warn -par
{
	long tmp;

	tmp = *( (long *) s1);
	*( (long *) s1) = *( (long *) s2);
	*( (long *) s2) = tmp;
}
#pragma warn +par


static void memxchg(char *s1, char *s2, long count)
{
	register char c;


	while(count)
		{
		c = *s1;
		*s1++ = *s2;
		*s2++ = c;
		count--;
		}
}


void shelsort(char *base, long count, long size,
		    int (*compar)(void *s1, void *s2, void *udata),
		    void *udata)
{
	register int (*vgl)(void *s1, void *s2, void *udata) = compar;
	register char *j;
	register long k2,k,i;
	register void (*xchg)(char *s1, char *s2, long count) = memxchg;



	k2 = count / 2;				/* k2 = ElementzÑhler */
	count *= size;					/* count: max-Byte */
	if	(0 == (((long) base) & 1) && size == 4L)
		xchg = longxchg;
	while(k2 > 0)
		{
		k = k2 * size;				/* k = BytezÑhler */
		for	(i = k; i < count; i += size)
			{
			j = base + i - k;
			while((j >= base) && ((*vgl)(j,j+k, udata)) > 0)
				{
				(*xchg)(j, j + k, size);
				j -= k;
				}
			}
		k2 >>= 1;
		}
}
