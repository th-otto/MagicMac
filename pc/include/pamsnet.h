/*
 *        NETACTIVE version number, please check it for later releases
 */

/* Prototypen */

int Nactive( void );
int Nnodeid( void );
int Nlogged( int nn );
long Nlock( const char *file );
long Nunlock( const char *file );
long Nlocked(void );
long Nprinter( int nn, int kopf, int dd );
void Nreset( void );
int Nrecord( int handle, int mm, long offset, long leng );
int Nmsg( int rw, char *buf, char *id, int node, int leng );
int Nremote( int nn );
void Ndisable( void );
int Nenable( void );

#define NETACTIVE 100

#ifdef __GNUC__

#define Nactive()        ((short)trap_1_w(127))
#define Nnodeid()        ((short)trap_1_w(126))
#define Nlogged(a)       ((short)trap_1_ww(125,a))
#define Nlock(a)         trap_1_wl(124,a)
#define Nunlock(a)       trap_1_wl(123,a)
#define Nlocked()        trap_1_w(122)
#define Nprinter(a,b,c)  ((short)trap_1_wwww(121,a,b,c))
#define Nreset()         trap_1_w(120)
#define Nrecord(a,b,c,d) ((short)trap_1_wwwll(119,a,b,c,d))
#define Nmsg(a,b,c,d,e)  ((short)trap_1_wwllww(118,a,b,c,d,e))
#define Nremote(a)       ((short)trap_1_ww(117,a))
#define Ndisable()       trap_1_w(116)
#define Nenable()        trap_1_w(115)

#else

#ifdef USE_MACROS

#define Nactive()        ((int)gemdos(127))           /* Net-Driver install request  */
#define Nnodeid()        ((int)gemdos(126))           /* Nodeadapter ID request      */
#define Nlogged(a)       ((int)gemdos(125,a))         /* Nodeadapter install request */
#define Nlock(a)         gemdos(124,a)         /* Lock file                   */
#define Nunlock(a)       gemdos(123,a)         /* Unlock file                 */
#define Nlocked()        gemdos(122)           /* Lock-Error checking         */
#define Nprinter(a,b,c)  ((int)gemdos(121,a,b,c))     /* Net-Printer installation    */
#define Nreset()         gemdos(120)           /* System RESET                */
#define Nrecord(a,b,c,d) ((int)gemdos(119,a,b,c,d))   /* Record LOCKING              */
#define Nmsg(a,b,c,d,e)  ((int)gemdos(118,((_WORD)(a)),((_VOID *)(b)),((char *)(c)),((_WORD)(d)),((_WORD)(e)))) /* Net message pipe            */
#define Nremote(a)       ((int)gemdos(117,a))         /* Net-Multiuser/Multitasking  */
#define Ndisable()       gemdos(116)           /* disable Net-Driver          */
#define Nenable()        gemdos(115)           /* enable Net-Driver           */

#endif /* USE_MACROS */

#endif /* __GNUC__ */

/*** V 1.0 Beta ***/

#define NLOCK    1
#define NUNLOCK  0

/* rwabs extended rw-codes */

#define NGETMSG 4                  /* get message                          */
#define NSNDMSG 8                  /* send message                         */          
#define NSNDSCN 5                  /* send screen                          */
#define NGETSCN 9                  /* get screen                           */
#define NRCVSCN 6                  /* ? */
#define NDENIES 7                  /* ? */

/* Nmsg Macros */

#define NMSG_READ     0            /* read message                         */
#define NMSG_WRITE    1            /* send message                         */

/* NET ERROR */

#define NET_ERROR   -36

