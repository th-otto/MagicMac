#define NULL        ( ( void * ) 0L )
#define TRUE   1
#define FALSE  0
#define EOS    '\0'

#define MAXDIM 16
#define ANZMAT 10                   /* Anzahl der Matrizen */
#define EPSILON (1e-11)
#define MIN(a,b) ((a < b) ? a : b)
#define MAX(a,b) ((a > b) ? a : b)
#define ABS(X) ((X>0) ? X : -X)

typedef struct matrix__
{
   double   m[MAXDIM][MAXDIM];      /* Daten */
   int      xdim;                   /* Spaltenzahl */
   int      ydim;                   /* Zeilenzahl  */
} MATRIXTYP;

typedef struct doppelmatrix__       /* doppelte x-Gr”že */
{
   double   m[MAXDIM][2 * MAXDIM];  /* Daten */
   int      xdim;                   /* Spaltenzahl */
   int      ydim;                   /* Zeilenzahl  */
} DOPPELMTYP;

extern MATRIXTYP mtx[ANZMAT];

#define ANZFENSTER (5+1)    /* 5 Matrizen + Edit-Fenster */
#define VOR        5
#define NACH       10
#define EDBUFLEN   (VOR+NACH+2)
