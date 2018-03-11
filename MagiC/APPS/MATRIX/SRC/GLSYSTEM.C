/*-------------------------------------------------------+
|                                                        |
|                LINEARE GLEICHUNGSSYSTEME               |
|                -------------------------               |
|                                                        |
|        1)   GAUSS Elimination (skalierte Pivotsuche)   |
|        2)   GAUSS-JORDAN Elimination                   |
|        3)   GAUSS-SEIDEL Iteration                     |
|        4)   HOUSEHOLDER Orthogonalisierung             |
|        5)   CHOLESKY-Verfahren                         |
|        6)   Tridiagonale Matrizen                      |
|                                                        |
+-------------------------------------------------------*/

#define EPSILON         0.0000001
#define MAXDIM          10
#define MAX_LOOPS       50
#define REAL            double
#define SQUARE(x)       (x*x)
#define MAX(x,y)        (((x) > y)  ? (x) : (y))
#define ABS(x)          (((x) >= 0) ? (x) : -(x))

#define OKAY            0     /* Lîsung berechnet                         */
#define DET_POS         1     /* ... und die Determinante ist positiv     */
#define DET_NEG         2     /* ... und die Determinante ist negativ     */
   
                              /* Lîsung kann nicht berechnet werden, weil */
#define ERR_SING        -1    /* die Matrix singulÑr ist                  */
#define ERR_POSDEF      -2    /* nicht positiv definit ist                */
#define ERR_SYMM        -3    /* nicht symmetrisch ist                    */
#define ERR_TRI         -4    /* nicht tridiagonal ist                    */
#define ERR_KONV        -5    /* kein Konvergenzkriterium erfÅllt ist     */
#define ERR_ITER        -6    /* die maximale Anzahl von Iterationen      */
                              /* Åberschritten ist                        */

int pivotarr[MAXDIM];         /* Array fÅr das Umspeichern der Pivotzeilen*/

/*-------------------------------------------------------+
|            Berechne den Betrag einer REAL-Zahl         |
+-------------------------------------------------------*/

extern REAL _fpreg0;          /* Floating-Point-Register fÅr Megamax-C    */

REAL fabs(x)                
REAL x;
{
   asm{
        move.l   x(A6),D0               ; Zahl holen
        and.l    #0x7fffffff,D0         ; Vorzeichenbit lîschen
        move.l   D0,_fpreg0(A4)         ; RÅckgabewerte setzen
        move.l   x+4(A6),_fpreg0+4(A4)
      }
}

/*-------------------------------------------------------+
|                         Pivotsuche                     |
|                                                        |
|         Eingabe:   startzeile  1. Zeile fÅr Pivotsuche |
|                    dim         Matrixdimension         |
|                    mat[][]     Matrix                  |
|         Ausgabe:   OKAY        alles OK                |
|                    ERR_SING    Matrix ist singulÑr     |
+-------------------------------------------------------*/

pivotsuche(startzeile,dim,mat)
int startzeile,dim;
REAL mat[][MAXDIM+1];
{
   int j,k,zeile;
   REAL pivot;

   pivot = fabs(mat[startzeile][startzeile]);/* Pivotsuche ab Zeile ...   */
   for (k=startzeile+1, zeile=startzeile; k<dim; k++)
   {
      if (fabs(mat[k][startzeile]) > pivot)  /* maximales Element suchen  */
      {
         pivot = fabs(mat[k][startzeile]);   /* Pivotelement und          */  
         zeile = k;                          /* Pivotzeile merken         */
      }
   }
   if (pivot < EPSILON)  return(ERR_SING);   /* Matrix ist singulÑr       */   
   if (zeile != startzeile)
   {
      for (j=startzeile; j<=dim; j++)        /* Zeilen vertauschen        */
      {
         pivot = mat[startzeile][j];
         mat[startzeile][j] = mat[zeile][j];
         mat[zeile][j]  = pivot;
      }
   }
   return(OKAY);
}

/*-------------------------------------------------------+
|                    RÅckwÑrtselimation                  |
+-------------------------------------------------------*/

rueckwaerts(dim,mat)         
int dim;
REAL mat[][MAXDIM+1];
{
   int i,j;

   for (i=dim-1; i>=0; i--)
   {
      for (j=dim-1; j>i; j--) mat[i][dim] -= mat[i][j] * mat[j][dim];
      mat[i][dim] /= mat[i][i];
   }
}

/*-------------------------------------------------------+
|                                                        |
|                GAUSS - Dreieckserlegung                |
|           nach dem Eliminationsverfahren mit           |
|                mit skalierter Pivotsuche               |
|                                                        |
|     Eingabe:   dim           Anzahl der Dimensionen    |
|                mat[][]       Matrix                    |
|     Ausgabe:   DET_POS       gerade Anzahl von         |      
|                              Zeilenvertauschungen, d.h |
|                              positive Determinante     |
|                DET_NEG       ungerade Anzahl (negativ) |
|                ERR_SING      Matrix ist singulÑr       |  
|                                                        |
+-------------------------------------------------------*/

gauss_zerlegung(dim,mat)
int dim;
REAL mat[][MAXDIM+1];
{
   int i,j,k,ipvt;
   int vorz_det = 1;
   REAL pivot, merke, skal[MAXDIM];

   for (i=0; i<dim; i++) 
   {
      pivotarr[i] = i;                    /* Pivotzeilen durchnumerieren  */
      merke = 0.0;
      for (j=0; j<dim; j++)               /* Skalierungsfaktor suchen     */ 
         merke = MAX(merke,fabs(mat[i][j]));
      if (merke == 0.0)
      {
         vorz_det = 0;
         merke = 1.0;
      }
      skal[i] = merke;
   }
   
   for (k=0; k<dim-1; k++)                /* Faktorisierung             */
   {
      pivot = fabs(mat[k][k]) / skal[k];  /* Pivotzeile bestimmen       */
      ipvt = k;                           /* Startzeile merken          */   
      for (i=k+1; i<dim; i++)             /* alle weiteren Zeilen       */
      {                                   /* absuchen:                  */
         merke = fabs(mat[i][k]) / skal[i];
         if (merke > pivot)               /* wenn grîûeres Element vh.: */  
         {
            pivot = merke;                /* als Pivotelement nehmen    */
            ipvt = i;                     /* und die Zeile merken       */
         }  
      }
      if (pivot == 0.0)                   /* Pivotelement ist Null:     */
         return(ERR_SING);                /* Matrix ist singulÑr, es    */
                                          /* gibt keine Lîsungen        */
      if (ipvt != k)                      /* Zeilenvertauschung:        */
      {
         vorz_det = -vorz_det;            /* gerade - ungerade anpassen */
         i = pivotarr[ipvt];              /* Zeilennumerierung anpassen */
         pivotarr[ipvt] = pivotarr[k];
         pivotarr[k] = i;
         merke = skal[ipvt];              /* Skalierungsfaktor auch     */
         skal[ipvt] = skal[k];
         skal[k] = merke;  
         for (j=0; j<dim; j++)            /* Zeilen vertauschen         */
         {
            merke = mat[ipvt][j];
            mat[ipvt][j] = mat[k][j];
            mat[k][j] = merke;
         }
      }
      
      for (i=k+1; i<dim; i++)             /* Eliminationsschritt        */
      {
         mat[i][k] /= mat[k][k];
         merke = mat[i][k];
         for (j=k+1; j<dim; j++) mat[i][j] -= merke * mat[k][j];
      }
   }

   if (mat[dim-1][dim-1] == 0.0) return(ERR_SING);
   return((vorz_det == 1) ? DET_POS : DET_NEG); 
}

gauss_loesung(dim,mat)
int dim;
REAL mat[][MAXDIM+1];
{
   int i,j;
   REAL sum,lsg[MAXDIM];

   lsg[0] = mat[pivotarr[0]][dim];           /* VorwÑrtselimination       */
   for (i=1; i<dim; i++)
   {
      sum = 0.0;
      for (j=0; j<i; j++) sum += mat[i][j] * lsg[j];
      lsg[i] = mat[pivotarr[i]][dim] - sum;
   }
   for (i=0; i<dim; i++) mat[i][dim] = lsg[i];
   
   rueckwaerts(dim,mat);                     /* RÅckwÑrtselimination      */
}

gauss(dim,mat)
int dim;
REAL mat[][MAXDIM+1];
{
   int ret;
   
   if ((ret=gauss_zerlegung(dim,mat)) != ERR_SING)
      gauss_loesung(dim,mat);
   return(ret);
}


/*-------------------------------------------------------+
|                                                        |
|          GAUSS-JORDAN Algorithmus mit Pivotsuche       |
|                                                        |
|     Eingabe:   dim           Anzahl der Dimensionen    |
|                mat[][]       Matrix                    |
|     Ausgabe:   OKAY          Lîsung existiert          |
|                ERR_SING      Matrix ist singulÑr       |  
|                                                        |
+-------------------------------------------------------*/

gauss_jordan(dim,mat)
int dim;
REAL mat[][MAXDIM+1];
{
   int i, j, k;
   REAL merke;

   if (pivotsuche(0,dim,mat) == ERR_SING) return(ERR_SING);
   for (k=1; k<dim; k++)                     /* 1. Eliminationsschritt    */
   {
      if (mat[k][0])                            
      {
         merke = -mat[0][0] / mat[k][0];
         for (j=0; j<=dim; j++)
            mat[k][j] = merke * mat[k][j] + mat[0][j];
      }
   }
                                                
   for (i=1; i<dim; i++)                     /* Jordan - Schritt          */
   {
      if (pivotsuche(i,dim,mat) == ERR_SING) return(ERR_SING);
      for (k=0; k<dim; k++)
      {
         if (k != i)
         {
            merke = -mat[k][i] / mat[i][i];
            for (j=i+1; j<=dim; j++) mat[k][j] += merke * mat[i][j];
         }
     }
   }

   for (i=0; i<dim; i++)  mat[i][dim] /= mat[i][i];
   return(OKAY);
}

/*-------------------------------------------------------+
|                                                        |
|                  GAUSS-SEIDEL Iteration                |
|                                                        |
|     Eingabe:   dim           Anzahl der Dimensionen    |
|                mat[][]       Matrix                    |
|     Ausgabe:   OKAY          Lîsung existiert          |
|                ERR_SING      Matrix ist singulÑr       |
|                ERR_KONV      Konvergenzkriterium ist   |
|                              nicht erfÅllt             |
|                ERR_ITER      maximale Iterationszahl   |
|                              wurde Åberschritten       |  
|                                                        | 
+-------------------------------------------------------*/

gauss_seidel(dim,mat)
int dim;
REAL mat[][MAXDIM+1];
{
   REAL x0[MAXDIM],x1[MAXDIM];
   int i,j,k,iteration;
   REAL abw,sum,maxsum;

   for (i=0; i<dim; i++) x0[i] = x1[i] = 0.0;/* Startwerte                */
   for (i=0; i<dim; i++)                     /* Matrix normieren          */
   {
      mat[i][dim] /= mat[i][i];
      for (j=0; j<dim; j++) if (i != j) mat[i][j] /= -mat[i][i];
      mat[i][i] = 0.0;
   }
   
   maxsum= -1.0;                             /* Zeilensummenkriterium     */    
   for (i=0; i<dim; i++)                      
   {
      sum = 0.0;
      for (j=0; j<dim; j++)  sum += fabs(mat[i][j]);
      if (sum > maxsum) maxsum = sum;                  
   }
   if (maxsum > 1.0)                         /* wenn nicht erfÅllt:       */
   {
      maxsum = -1.0;                         /* Spaltensummenkriterium    */
      for (j=0; j<dim; j++)                     
      {
         sum = 0.0;
         for (i=0; i<dim; i++) sum += fabs(mat[i][j]);
         if (sum > maxsum) maxsum = sum;                  
      }
      if (maxsum > 1.0)                      /* wenn auch nicht erfÅllt:  */
      {
         maxsum = -1.0;                      /* Kriterium v. Schmidt-Mises */
         sum = 0.0;
         for (i=0; i<dim; i++)
            for (j=0; j<dim; j++) sum += mat[i][j] * mat[i][j];
         if (sum > 1.0) return (ERR_KONV);
      }
   }
   
   for (iteration=1; iteration<MAX_LOOPS; iteration++)
   {
      for (i=0; i<dim; i++)                  /* Iterationsschritt im      */
      {                                      /* Einzelschrittverfahren    */
         x1[i] = mat[i][dim];
         for (j=0; j<dim; j++) x1[i] += mat[i][j] * x1[j];
      }

      abw = -1.0;                            /* maximalen Unterschied der */
      for (i=0; i<dim; i++)                  /* letzten Lîsungsvektoren   */
      {                                      /* feststellen               */    
         abw = MAX(abw,ABS(fabs(x1[i]-x0[i])));
         x0[i] = x1[i];
      }
      if (abw < EPSILON)                     /* wenn Genauigkeit erreicht */
      {                                      /* Iterationen abbrechen     */
         for (i=0; i<dim; i++) mat[i][dim] = x0[i];
         return(OKAY);
      }
   }
   return(ERR_ITER);                         /* maximale Anzahl von       */
}                                            /* Iterationen Åberschritten */

/*-------------------------------------------------------+
|                                                        |
|              HOUSEHOLDER - Orthogonalisierung          |
|                                                        |
|     Eingabe:   dim           Anzahl der Dimensionen    |
|                mat[][]       Matrix                    |
|     Ausgabe:   OKAY          Lîsung existiert          |
|                ERR_SING      Matrix ist singulÑr       |
|                                                        |
+-------------------------------------------------------*/

householder(dim,mat)
int dim;
REAL mat[][MAXDIM+1];
{
   int i, j, k;
   REAL a[MAXDIM];                           /* Hilfsarray               */
   REAL beta, summe, wurzel;

   for (j=0; j<dim; j++)                        /* Dreieckstransformation  */
   {
      summe = 0.0;
      for (i=j; i<dim; i++)
         summe += SQUARE(mat[i][j]);
      if (fabs(summe) < EPSILON)  return(ERR_SING);
      wurzel = (mat[j][j] < 0.0) ? sqrt(summe) : -sqrt(summe);
      a[j]   = wurzel;
      beta   = 1.0 / (wurzel * mat[j][j] - summe);
      mat[j][j] -= wurzel;
      for (k=j+1; k<=dim; k++)
      {
         summe = 0.0;
         for (i=j; i<dim; i++) summe = summe + mat[i][j] * mat[i][k];
         summe *= beta;
         for (i=j; i<dim; i++) mat[i][k] = mat[i][k] + mat[i][j] * summe;
      }
   }

   for (i=dim-1; i>=0; i--)  mat[i][i] = a[i];
   rueckwaerts(dim,mat);
   return(OKAY);
}

/*-------------------------------------------------------+
|                                                        |
|                   CHOLESKY - Verfahren                 |
|      fÅr symmetrische, positiv definite Matrizen       |
|                                                        |
|     Eingabe:   dim           Anzahl der Dimensionen    |
|                mat[][]       Matrix                    |
|     Ausgabe:   OKAY          Lîsung existiert          |
|                ERR_SING      Matrix ist singulÑr       |
|                ERR_SYMM      Matrix nicht symmetrisch  |
|                ERR_POSDEF    ... nicht positiv definit |
|                                                        |
+-------------------------------------------------------*/

cholesky(dim,mat)
int dim;
REAL mat[][MAXDIM+1];
{
   int i,j,k;
   REAL x,p[MAXDIM];
   
   for (i=0; i<dim-1; i++)              
      for (j=i+1; j<dim; j++)
         if (mat[i][j] != mat[j][i]) return(ERR_SYMM);
          
   for (i=0; i<dim; i++)
   {
      for (j=i; j<=dim; j++)
      {
         x = mat[i][j];
         for (k=i-1; k>=0; k--) x -= mat[k][j] * mat[k][i];
         if (i == j)
         {
            if (x <= 0.0) return(ERR_POSDEF);
            p[i] = sqrt(x);
         }
         else mat[i][j] = x / p[i];
      }
   }

   for (i=0; i<dim; i++)  mat[i][i] = p[i];
   rueckwaerts(dim,mat);
   return(OKAY);
}

/*-------------------------------------------------------+
|                                                        |
|            Verfahren fÅr tridiagonale Matrizen         |
|                                                        |
|     Eingabe:   dim           Anzahl der Dimensionen    |
|                mat[][]       Matrix                    |
|     Ausgabe:   OKAY          Lîsung existiert          |
|                ERR_SING      Matrix ist singulÑr       |
|                ERR_TRI       Matrix ist nicht          |
|                              tridiagonal               |
|                                                        |
+-------------------------------------------------------*/

tridiagonal(dim,mat)
int dim;
REAL mat[][MAXDIM+1];
{
   int i,j,delta;
   
   for (i=0; i<dim; i++)
   for (j=0; j<dim; j++)
   {
      delta = j - i;
      if (delta < 0) delta = -delta;
      if (delta>1  &&  mat[i][j]!=0.0) return(ERR_TRI);
   }
          
   for (i=0; i<dim-1; i++)
   {
      if (mat[i][i] == 0.0) return(ERR_SING);
      mat[i][i+1] /= mat[i][i];              
      mat[i+1][i+1] -= mat[i+1][i] * mat[i][i+1];
   }
   if (mat[dim-1][dim-1] == 0.0) return(ERR_SING);
   
   mat[0][dim] /= mat[0][0];
   for (i=1; i<dim; i++)
      mat[i][dim] = (mat[i][dim] - mat[i][i-1] * mat[i-1][dim]) / mat[i][i];
   for (i=dim-2; i>=0; i--)
      mat[i][dim] -= mat[i][i+1] * mat[i+1][dim];
      
   return(OKAY);
}        
               

