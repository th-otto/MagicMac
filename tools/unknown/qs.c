/**************************************************************
*
*                 QUICKSORT
*                 =========
*
* Sortiert die Elemente <links> bis <rechts> des Feldes <feld>.
* Teilfelder mit einer L„nge <= 8 werden mit sisort() behandelt.
* Der "Zerlegungsalgorithmus" ist in divide() enthalten.
*
**************************************************************/

#define DATENTYP long

static long lstack[50], rstack[50], pstack;

quicksort(links,rechts,feld)
long links,rechts;
DATENTYP feld[];
{
     lstack[1L] = links;
     rstack[1L] = rechts;
     pstack     = 1L;
     while (pstack > 0L) {
           if   ((rstack[pstack] - lstack[pstack]) > 7L)
                divide(feld);
           else sisort(feld);
           }
}


/***********************************************************
*
* Die Routine zerlegt nach dem bekannten QUICKSORT-
* Algorithmus die oberste Teilfolge des Stack.
* Als Kandidat wird das erste Element der Teilfolge gew„hlt.
*
***********************************************************/

divide(feld)
DATENTYP feld[];
{
     register long     l,r,ipos,l1,l2;
              DATENTYP kand;

     ipos = lstack[pstack];
     r    = rstack[pstack] + 1L;
     l    = ipos;
     kand = feld[l];

     while (l < r) {
           while (r > l) {
                 r--;
                 if (r == ipos)
                    break;
                 if (feld[r] < kand) {
                    feld[ipos] = feld[r];
                    ipos       = r;
                    break;
                    }
                 }
           while (l < r) {
                 l++;
                 if (l == ipos)
                    break;
                 if (feld[l] > kand) {
                    feld[ipos] = feld[l];
                    ipos = l;
                    break;
                    }
                 }
           }
     feld[ipos] = kand;
     l1 = ipos - lstack[pstack];
     l2 = rstack[pstack] - ipos;
     if   (l1 < l2) {
          lstack[pstack+1L] = lstack[pstack];
          lstack[pstack]    = ipos + 1L;
          pstack++;
          rstack[pstack]    = ipos - 1L;
          }
     else {
          rstack[pstack+1L] = rstack[pstack];
          rstack[pstack]    = ipos - 1L;
          pstack++;
          lstack[pstack]    = ipos + 1L;
          }
}


/***********************************************************
*
* Die Routine sortiert die Teilfolge von lstack[pstack] bis
* rstack[pstack] des Feldes <feld> nach dem "straight
* insertation sort" - Verfahren.
*
***********************************************************/

sisort(feld)
DATENTYP feld[];
{
     register long     i,j,von,bis;
              DATENTYP kand;

     von = lstack[pstack];
     bis = rstack[pstack];
     for (i = von + 1L; i <= bis; i++) {
         kand = feld[i];
         j    = i - 1L;
         while ( (j >= von) && (kand < feld[j]) ) {
               feld[j+1L] = feld[j];
               j--;
               }
         feld[j+1L] = kand;
         }
     pstack--;
}

