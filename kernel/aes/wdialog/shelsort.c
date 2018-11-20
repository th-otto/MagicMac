/*******************************************************************
*
*                          SHELSORT.O		8.1.89
*                          ==========
*
*         letzte Modifikation:			29.10.95
*
* MODUL fuer Shellsort- Algorithmus.
* Syntax wie bei QSORT.
* Der Algorithmus ist NICHT rekursiv, funktioniert daher
*  auch bei kleinem Stack.
* Der Algorithmus ist bestmoeglich optimiert, indem:
*
* 1) AUSSCHLIESSLICH register- Variablen benutzt werden
* 2) nicht mit Indizes, sondern mit Zeigern gerechnet wird,
*	damit alle Multiplikationen ausserhalb der inneren Schleifen
*	ausgefuehrt werden
* 3) Fuer long oder void * wird eine besonders schnelle Vertauschung
*    von Elementen durchgefuehrt
*
* NEU:	<udata> wird an die Vergleichsfunktion uebergeben, um
*		z.B. Sortiermodi zu ermoeglichen.
*
* Verbesserungsmoeglichkeit: assembleroptimierte memxchg- Funktion
*
*******************************************************************/

#include <portab.h>
#include <string.h>

static void longxchg(char *s1, char *s2, size_t count)
{
	long tmp;

	(void)count;
	tmp = *( (long *) s1);
	*( (long *) s1) = *( (long *) s2);
	*( (long *) s2) = tmp;
}


static void memxchg(char *s1, char *s2, size_t count)
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
		    int (*compar)(const void *s1, const void *s2, void *udata), void *udata)
{
	char *j;
	long k2,k,i;
	void (*xchg)(char *s1, char *s2, size_t count) = memxchg;


	k2 = count / 2;				/* k2 = Elementzaehler */
	count *= size;					/* count: max-Byte */
	if	(0 == (((long) base) & 1) && size == sizeof(long))
		xchg = longxchg;
	while(k2 > 0)
		{
		k = k2 * size;				/* k = Bytezaehler */
		for	(i = k; i < count; i += size)
			{
			j = base + i - k;
			while((j >= base) && ((*compar)(j,j+k, udata)) > 0)
				{
				(*xchg)(j, j + k, size);
				j -= k;
				}
			}
		k2 >>= 1;
		}
}
