#define NPRIMES 48

long primes[]  = {2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,
                 71,73,79,83,89,97,101,103,107,109,113,127,131,137,139,
                 149,151,157,163,167,173,179,181,191,193,197,199,211,223};

main()
{
     register int  i;
     register long n,m;
              long a,b;
              long phi(),ggt(),pot();
     static   long bot[] = {48,82,19,1,135,42,72,112,106};

     for  (n = 0; n < 2000; n++) {
          printf("æ(%4ld) = %d\n", n, my(n));
          }
}


/*******************************************************************
*
* Die Eulersche í - Funktion
*
*******************************************************************/

long phi(n)
register long n;
{
     register  int i;
     register long m;

     m = n;
     for  (i = 0; i < NPRIMES; i++)
          if   (n % primes[i] == 0) {     /* Wenn n durch p teilbar */
               m *= primes[i] - 1;
               m /= primes[i];
               }
     return(m);
}


/*******************************************************************
*
* Prft, ob n eine Primzahl ist (sucht einfach in der Tabelle)
*
*******************************************************************/

int isprime(n)
register long n;
{
     register int i;

     for  (i = 0; i < NPRIMES; i++)
          if   (n == primes[i])
               return(1);
     return(0);
}


/*******************************************************************
*
* Berechnet den ggT von a und b
*
*******************************************************************/

long ggt(a,b)
long a,b;
{
     register long n;

     if   (a < b) {
          n = a;
          a = b;
          b = n;
          }
     while(n = a % b) {
          a = b;
          b = n;
          } 
     return(b);
}


/*******************************************************************
*
* Berechnet a^n modulo p
*
*******************************************************************/

long pot(a,n,p)
long a,n,p;
{
     register long erg;

     a %= p;
     for  (erg = 1L; n > 0; n--) {
          erg *= a;
          erg %= p;
          }
     return(erg);
}


/*******************************************************************
*
* M”bius' æ
*
*******************************************************************/

int my(n)
register long n;
{
     register  int i,ret;

     ret = 1;
     for  (i = 0; i < NPRIMES; i++)
          if   (n % primes[i] == 0) {     /* Wenn n durch p teilbar */
               n /= primes[i];            /* Dann teile             */
               ret = -ret;                /* Berechne Rckgabewert  */
               if   (n % primes[i] == 0)  /* Wenn n durch p*p teilbar... */
                    return(0);            /* ...ist Funktionswert 0      */
               }
     return(ret);
}

