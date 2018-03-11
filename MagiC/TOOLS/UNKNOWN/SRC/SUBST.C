/*
 * grep -- print lines matching (or not matching) a pattern
 *
 *      status returns:
 *              0 - ok, and some matches
 *              1 - ok, but no matches
 *              2 - some error
 */

#include <stdio.h>
#include <ctype.h>

/*#include <sys/param.h>*/

#define BSIZE   512
#define CBRA    1
#define CCHR    2
#define CDOT    4
#define CCL     6
#define NCCL    8
#define CDOL    10
#define CEOF    11
#define CKET    12
#define CBACK   18
#define STAR    01
#define LBSIZE  1024
#define ESIZE   2048
#define NBRA    9


char    expbuf[ESIZE];
char    linebuf[LBSIZE+1];
char    ybuf[ESIZE];
int     bflag;
int     lflag;
int     nflag;
int     cflag;
int     vflag;
int     hflag   = 1;
int     sflag;
int     yflag;
int     circf;
int     nsucc;
char    *braslist[NBRA];
char    *braelist[NBRA];
char    bittab[] = {1, 2, 4, 8, 16, 32, 64, 128 };
char    *ersatz;            /* Zeigt auf Ersatz- String */


main(argc, argv)
int  argc;
char *argv[];
{
     while (--argc > 0 && (++argv)[0][0]=='-')
                switch (argv[0][1]) {
                case 'y':
                        yflag++;
                        continue;
                case 'h':
                        hflag = 0;
                        continue;
                case 's':
                        sflag++;
                        continue;
                case 'v':
                        vflag++;
                        continue;
                case 'b':
                        bflag++;
                        continue;
                case 'l':
                        lflag++;
                        continue;
                case 'c':
                        cflag++;
                        continue;
                case 'n':
                        nflag++;
                        continue;
                case 'e':
                        --argc;
                        ++argv;
                        goto out;
                default:
                        errexit("grep: unknown flag\n", (char *)NULL);
                        continue;
                }
out:
     if   (argc <= 0)
          exit(2);
     if   (yflag) {
          register char *p, *s;

          for  (s = ybuf, p = *argv; *p;) {
               if   (*p == '\\') {
                    *s++ = *p++;
                    if   (*p)
                         *s++ = *p++;
                    }
               else if   (*p == '[') {
                         while (*p != '\0' && *p != ']')
                               *s++ = *p++;
                         }
                    else if   (islower(*p)) {
                               *s++ = '[';
                               *s++ = toupper(*p);
                               *s++ = *p++;
                               *s++ = ']';
                               }
                         else  *s++ = *p++;
                         if   (s >= ybuf+ESIZE-5)
                              errexit("grep: argument too long\n", (char *)NULL);
               } /* END FOR */

          *s = '\0';  /* EOS setzen */
          *argv = ybuf;
          } /* END IF */

     compile(*argv);          /* Ausdruck nach expbuf Åbersetzen */

     if   (argc <= 1) {
          fprintf(stderr,"Kein Ersatz-String angegeben!\n");
          exit(2);
          }
     else ersatz = argv[1];

     execute();

     exit(nsucc == 0);
}


/********************************************************************
*
* "Compiliert" einen regulaeren Ausdruck <astr>
*
********************************************************************/

compile(astr)
char *astr;
{
     register unsigned char c;
     register char *ep, *sp;
              char *cstart;
              char *lastep;
              int  cclcnt;
              char bracket[NBRA], *bracketp;
              int  closed;
              char numbra;
              char neg;


     ep       = expbuf;
     sp       = astr;
     lastep   = NULL;
     bracketp = bracket;
     closed   = numbra = 0;

     if   (*sp == '^') {
          circf++;
          sp++;
          }

     for  (;;) {
          if   (ep >= &expbuf[ESIZE])        /* Ausdruck zu lang */
               goto cerror;
          if   ((c = *sp++) != '*')
               lastep = ep;
          switch (c) {
            case '\0':
                    *ep++ = CEOF;
                    return;
            case '.':
                    *ep++ = CDOT;
                    continue;
            case '*':
                    if   (lastep==0 || *lastep==CBRA || *lastep==CKET)
                         goto defchar;
                    *lastep |= STAR;
                    continue;
            case '$':
                    if   (*sp != '\0')
                         goto defchar;
                    *ep++ = CDOL;
                    continue;
            case '[':
                    if   (&ep[17] >= &expbuf[ESIZE])
                         goto cerror;
                    *ep++ = CCL;
                    neg = 0;
                    if   ((c = *sp++) == '^') {
                         neg = 1;
                         c = *sp++;
                         }
                    cstart = sp;
                    do   {
                         if   (c == '\0')  /* EOS vor schliessender Klammer */
                              goto cerror;
                         if   (c == '-' && sp > cstart && *sp != ']') {
                              for  (c = sp[-2]; c < *sp; c++)
                                   ep[c >> 3] |= bittab[c&07];
                              sp++;
                              }
                         ep[c >> 3] |= bittab[c&07];
                         }
                    while((c = *sp++) != ']');
                    if   (neg) {
                         for  (cclcnt = 0; cclcnt < 16; cclcnt++)
                              ep[cclcnt] ^= -1;
                         ep[0] &= 0xfe;
                         }
                    ep += 16;
                    continue;
            case '\\':
                    if   ((c = *sp++) == '(') {
                         if   (numbra >= NBRA)  /* Zuviele Klammern */
                              goto cerror;
                         *bracketp++ = numbra;
                         *ep++ = CBRA;
                         *ep++ = numbra++;
                         continue;
                         }
                    if   (c == ')') {
                         if   (bracketp <= bracket)
                              goto cerror;
                         *ep++ = CKET;
                         *ep++ = *--bracketp;  /* Nummer der Klammer */
                         closed++;
                         continue;
                         }
                    if   (c >= '1' && c <= '9') {
                         if   ((c -= '1') >= closed)
                              goto cerror;
                              *ep++ = CBACK;
                              *ep++ = c;
                              continue;
                         }
            default:
            defchar:
                    *ep++ = CCHR;
                    *ep++ = c;

            } /* END SWITCH*/

         } /* END FOR */

    cerror:
        errexit("grep: RE error\n", (char *)NULL);
}


/********************************************************************
*
* Hauptteil: Bearbeitet eine Datei vom Standard- Input
*
********************************************************************/

execute()
{
     register char *p1, *p2;
     register char c;
              char *endofmatch;
     extern   char *advance();


     while  (NULL != gets(linebuf)) {
          p1 = linebuf;
          p2 = expbuf;

          if   (circf) {      /* expr beginnt mit '^' */
               if   (NULL != (endofmatch = advance(p1, p2))) {
                    printf(ersatz);
                    printf(endofmatch);
                    }
               else printf(p1);
               }

                /* fast check for first character */

          else {
               if   (*p2 == CCHR) {  /* expr beginnt mit normalem Zeichen */
                    c = p2[1];
                    while(*p1 != '\0') {
                         if   (*p1 != c)
                              putchar(*p1++);
                         else break;
                         }
                    }

               /* regular algorithm */

               while(*p1 != '\0') {
                    if   (NULL != (endofmatch = advance(p1, p2))) {
                         printf(ersatz);
                         p1 = endofmatch;
                         }
                    else putchar(*p1++);
                    }

               } /* END ELSE */

          putchar('\n');

          } /* END WHILE */

     return;
}


/********************************************************************
*
* PrÅft, ob ab lp[] ein "Match" vorliegt.
* Wenn ja, wird der Zeiger hinter das letzte Zeichen des 
* Matchs zurÅckgegeben, sonst NULL.
*
********************************************************************/

char *advance(lp, ep)
register char *lp, *ep;
{
     register char *curlp;
     char c;
     char *bbeg;
     int  ct;
     char *zeiger;


     for  (;;)
          switch(*ep++) {
            case CCHR:                       /* normales Zeichen */
                    if   (*ep++ == *lp++)
                         continue;
                    return(NULL);
            case CDOT:                       /* Punkt '.' */
                    if   (*lp++)
                         continue;
                    return(NULL);
            case CDOL:                       /* Zeilenende '$' */
                    if   (*lp == '\0')
                         continue;
                    return(NULL);
            case CEOF:                       /* Ende von expr */
                    return(lp);
            case CCL:                        /* [...] Ausdruck */
                    c = *lp++ & 0x7f;
                    if   (ep[c >> 3] & bittab[c & 07]) {
                         ep += 16;
                         continue;
                         }
                    return(NULL);
            case CBRA:                       /* Klammer auf */
                    braslist[*ep++] = lp;
                    continue;
            case CKET:                       /* Klammer zu */
                    braelist[*ep++] = lp;
                    continue;
            case CBACK:
                    bbeg = braslist[*ep];
                    if   (braelist[*ep] == NULL)
                         return(NULL);
                    ct = braelist[*ep++] - bbeg;
                    if   (ecmp(bbeg, lp, ct)) {
                         lp += ct;
                         continue;
                         }
                    return(NULL);
            case CBACK|STAR:
                    bbeg = braslist[*ep];
                    if   (braelist[*ep] == NULL)
                         return(NULL);
                    ct = braelist[*ep++] - bbeg;
                    curlp = lp;
                    while(ecmp(bbeg, lp, ct))
                         lp += ct;
                    while(lp >= curlp) {
                         if   (NULL != (zeiger = advance(lp, ep)))
                              return(zeiger);
                         lp -= ct;
                         }
                    return(NULL);
            case CDOT|STAR:
                    curlp = lp;
                    while (*lp++);
                    goto star;
            case CCHR|STAR:
                    curlp = lp;
                    while (*lp++ == *ep);
                    ep++;
                    goto star;
            case CCL|STAR:
                    curlp = lp;
                    do   {
                         c = *lp++ & 0177;
                         }
                    while(ep[c>>3] & bittab[c & 07]);
                    ep += 16;
                    goto star;
              star:
                    if   (--lp == curlp) {
                         continue;
                         }
                    if   (*ep == CCHR) {
                         c = ep[1];
                         do   {
                              if   (*lp != c)
                                   continue;
                              if   (NULL != (zeiger = advance(lp, ep)))
                                   return(zeiger);
                              }
                         while(lp-- > curlp);
                         return(NULL);
                         }
                    do   {
                         if   (NULL != (zeiger = advance(lp, ep)))
                              return(zeiger);
                         }
                    while(lp-- > curlp);
                    return(NULL);
            default:
                    errexit("grep RE botch\n", (char *)NULL);

        } /* END FOR */
}


/********************************************************************
*
* Vergleicht genau <count> Zeichen in den Strings a[] und b[]
*
********************************************************************/

ecmp(a, b, count)
char *a, *b;
int  count;
{
     register cc = count;

     while(cc--)
          if   (*a++ != *b++)
               return(0);
     return(1);
}


/********************************************************************
*
* Fehlerbehandlung: Gibt Fehlerursache aus und beendet Programm
*
********************************************************************/

errexit(s, f)
char *s, *f;
{
     if   (s != NULL)
          fprintf(stderr, s, f);
     exit(2);
}
