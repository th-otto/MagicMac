/***************************************************************
*
*             FSEL.C                                  20.10.95
*             ========
*
* geschrieben mit Pure C V1.1
*
* MagiC-Dateiauswahl.
*
* Aenderungen:
*
*    15.11.97            umgestellt auf prop.Fonts
*
****************************************************************/

#define DEBUG 0

#include <portab.h>
#include <country.h>
#define fsel_exinput     ____dummy1
#include <aes.h>
#undef fsel_exinput
#include <vdi.h>
#include <tos.h>
#include <mgx_dos.h>
#include <string.h>
#include <toserror.h>
#define form_xdo    ____dummy2
#undef form_xdo
#include "ger\fselx.h"
#include "..\wdialog\shelsort.h"
#include "std.h"
#include <sys/stat.h>

static unsigned char fselx[] = {
#if       COUNTRY==COUNTRY_DE
#include "ger\fselx.inc"
#elif     (COUNTRY==COUNTRY_US) || (COUNTRY==COUNTRY_UK)
#include "us\fselx.inc"
#elif     COUNTRY==COUNTRY_FR
#include "fra\fselx.inc"
#endif
};

#define fsel_rsc ((RSHDR *) fselx)
#define fsel_rslen sizeof(fselx)

/* Kram, der in AES.H fehlt */

#ifndef FL3DBAK
#define FL3DBAK      0x0400   /* 3D Background                AES 4.0      */
#endif
#ifndef FL3DMASK
#define FL3DMASK     0x0600
#endif

typedef struct _xted {
     char      *xte_ptmplt;
     char      *xte_pvalid;
     WORD      xte_vislen;
     WORD      xte_scroll;
} XTED;

/*----------------------------------------------------------------------------------------*/ 
/* Makros und Funktionsdefinitionen fuer Aufrufe an den MagiC-Kernel                       */
/*----------------------------------------------------------------------------------------*/ 

typedef   void *DIALOG;
typedef   WORD (cdecl *HNDL_OBJ)( DIALOG *dialog, EVNT *events, WORD obj, WORD clicks, void *data );

#define   HNDL_INIT -1                            /* Dialog initialisieren */
#define   HNDL_CLSD -3                            /* Dialogfenster wurde geschlossen */
#define   HNDL_OPEN -5                            /* Dialog-Initialisierung abschliessen (zweiter Aufruf am Ende von wdlg_init) */
#define   HNDL_EDIT -6                            /* Zeichen fuer ein Edit-Feld ueberpruefen */
#define   HNDL_EDDN -7                            /* Zeichen wurde ins Edit-Feld eingetragen */
#define   HNDL_EDCH -8                            /* Edit-Feld wurde gewechselt */
#define   HNDL_MOVE -9                            /* Dialog wurde verschoben */
#define   HNDL_TOPW -10                           /* Dialog-Fenster ist nach oben gekommen */
#define   HNDL_UNTP -11                           /* Dialog-Fenster ist nicht aktiv */

extern    void *wdlg_create( HNDL_OBJ handle_exit, OBJECT *tree, void *user_data, WORD code, void *data, WORD flags );
extern    WORD wdlg_open( DIALOG *dialog, BYTE *title, WORD kind, WORD x, WORD y, WORD code, void *data );
extern    WORD wdlg_set_edit( DIALOG *dialog, WORD obj );
extern    WORD wdlg_close( DIALOG *dialog, WORD *x, WORD *y );
extern    WORD wdlg_delete( DIALOG *dialog );
extern    WORD wdlg_evnt( DIALOG *dialog, EVNT *events );
extern    void wdlg_redraw( DIALOG *dialog, GRECT *rect, WORD obj, WORD depth );
extern    void *wdlg_get_udata( DIALOG *dialog );
extern    WORD wdlg_get_edit( DIALOG *dialog, WORD *cursor );
extern    WORD wdlg_get_tree( DIALOG *dialog, OBJECT **tree, GRECT *r );
extern    WORD wdlg_set_size( DIALOG *dialog, GRECT *size );

extern void graf_rbox( int x, int y, int minw, int minh,
                         int *neuw, int *neuh);

extern WORD lbox_set_bvis( void *lbox, WORD new);

#include "listbx_g.h"
#include "ker_bind.h"
#include "fsel.h"

#define   objc_draw( tree, obj, depth, clip ) \
               set_clip_grect( clip ); \
               _objc_draw( tree, obj, depth )

#define   form_xdial( flag, little, big, flyinf ) \
               frm_xdial( flag, little, big, flyinf )

#define   form_center( tree, rect ) \
               _form_center_grect( tree, rect )

#define   form_popup( tree, xy ) \
               _form_popup( tree, xy )

#define   objc_edit( tree, obj, c, x, kind, rect ) \
               _objc_edit( tree, obj, c, x, kind, rect )

#define   Malloc( size ) (smalloc( size ))

#define   Mfree( block ) smfree( block )

#define   Mshrink( dummy, block, size ) smshrink( block, size )

#define   Dgetdrv   dgetdrv

#define   Dpathconf dpathconf

#define   Dopendir  dopendir

#undef Dclosedir
#define   Dclosedir dclosedir

#define   Dxreaddir dxreaddir

#define   Fxattr    fxattr

#define   Dgetpath  dgetpath

#define   Drvmap    drvmap


#define FIXED_PATTLEN    256
#define MAXPATH          256

/* sichtbare Breiten der Objekte: */

#define PATTOBJLEN  7
#define NAMLEN      32
/* Soviele Extraspalten fuer einen Dateinamen: */
#define NAMDATALEN  26
#define NLINES      14
#define MAXEXTLEN   32             /* so lang darf Extension sein */

#define FIRSTMAXMEMBLK   0x20000L  /* Beginne mit 128k */
#define NEXTMEMBLK       0x20000L  /* Steigere 128k */
#define LASTMAXMEMBLK    0x200000L /* Ende mit 2M */
#define MINFREEBLK  4096L          /* soviel muss noch frei sein */

#ifndef NULL
#define NULL ((void *)0)
#endif
#define EOS '\0'

typedef struct _fi
{
     struct _fi *next;             /* Verkettung fuer scrollbox */
     WORD      sel;                /* selektiert */
     UWORD     number;             /* Eingangsreihenfolge */
     UWORD     time;
     UWORD     date;
     ULONG     size;
     UWORD     mode;               /* von XATTR */
     char      is_alias;
     char      dummy;              /* fuer name auf Wortgrenze */
     char      name[0];
} FILEINFO;


typedef struct
{
     LONG magic;              /* 'fsel' */

     void *dialog;            /* Zeiger auf die Dialog-Struktur oder 0L (Dialog nicht im Fenster) */
     void *lbox;              /* Scrollbox- Struktur */
     WORD whdl;               /* Handle des Fensters oder -1 */

     OBJECT *tree;            /* Zeiger auf den Objektbaum */
     OBJECT *sort_popup;      /* Objektbaum fuer Sortiermodus */
     int  sort_mode;
     CICONBLK *folder_icon;   /* Farbicon fuer Ordner */
     XTED xted;               /* Fuer scrollendes Eingabefeld */
     XTED xted_ext;           /*  dito fuer Eingabe der Extension */
     char input_ext[MAXEXTLEN+2];  /* Eingabepuffer fuer Ext. */
     char abbr_path[MAXPATH+2];    /* abgekuerzter Pfad */

     WORD editob;
     WORD cursorpos;          /* fuer select_item() */

     USERBLK userblk_clip_on;
     GRECT tmpclip;           /* Altes GRECT fuer USERDEF */
     USERBLK userblk_clip_off;
     USERBLK userblk_text;    /* Textausgabe bei prop.Font */

     char fname_dirty;
     char path_dirty;         /* Diese Objekte neu zeichnen! */
     char data_dirty;
     char drv_dirty;
     char patt_dirty;

     RSHDR *rshdr;            /* Zeiger auf den Resource-Header */

     char *patterns;          /* Moegliche Muster */
     WORD cdecl (*filter)
               (char *path,
               char *name,
               XATTR *xa);    /* statt Muster */
     char *paths;             /* Moegliche Pfade */
     char *pattern;           /* aktuelles Muster */

     char *memblk;            /* Block mit Verzeichnisdaten */
     FILEINFO **files;        /* Zeiger auf FILEINFOs */
     FILEINFO *next_selfile;  /* fuer Rueckgabe mehrerer Dateien */
     FILEINFO *last_selected; /* fuer Dialogbehandlung */
     FILEINFO *last_deselected;    /* fuer Dialogbehandlung */
     int  nfiles;             /* Anzahl Dateien */
     int  flags;              /* versch. Flags */
     int  max_name;           /* Laengster Dateiname: Anzahl Zeichen */

     WORD xtab_namelen;       /* Spaltenpositionen bei Prop.Fonts */
     WORD xtab_typelen;
     WORD xtab_timelen;
     WORD xtab_datelen;
     WORD xtab_sizelen;
     WORD spaltenabstand;

     char dos_mode;           /* Dateinamen sind 8+3 */
     char too_many_files;     /* Flag "Zuviele Dateien" */
     WORD button;             /* fuer Fenster-Dialogbehandlung */
     WORD pathlen;            /* max. Pfadlaenge inkl. EOS */
     WORD fnamelen;           /* max. Dateinamenlaenge inkl. EOS */
     char *fname;             /* fuers Editfeld */
     char *old_fname;         /* zum Testen auf Aenderung */
     char path[0];            /* Aktueller Pfad */
} FSEL_DIALOG;


static int objs[NLINES] =
     {
     FS_BOX0,FS_BOX1,FS_BOX2,FS_BOX3,FS_BOX4,
     FS_BOX5,FS_BOX6,FS_BOX7,FS_BOX8,FS_BOX9,
     FS_BOX10,FS_BOX11,FS_BOX12,FS_BOX13
     };

static void _resize_fs_tree( OBJECT *tree, WORD offset );

/*
     4.9.96: Feste Extensions, die demnaechst in der INF-Datei
     vorgegeben werden sollen.
*/

extern WORD fslx_dlm;         /* min. Dialogbreite in Pixeln */
extern WORD fslx_dlw;         /* Dialogbreite in Pixeln */
extern char fslx_exts[FIXED_PATTLEN];
extern (*fslx_d2s)(char *s, WORD mode);      /* DOS-Datum -> Zeichenkette */
extern int big_wchar, big_hchar;
extern int enable_3d;
extern char altcode_asc( WORD key );
extern char *fn_name( char *path );
extern GRECT desk_g;     /* Bildschirm ohne Menueleiste */


/*********************************************************************
*
* Gib die Extension eines Dateinamens
*
*********************************************************************/

static char *fnam2ext( char *fname )
{
     return(strrchr(fname, '.'));
}


/*********************************************************************
*
* Initialisiert das Scrolledit-Objekt
*
*********************************************************************/

static void init_xted(OBJECT *ob,
                         WORD maxnamelen, XTED *xted,
                         int is_8_3,
                         char *txt,
                         int vislen)
{
     register TEDINFO *t;
     static char *tmplt_8_3 = "________.___";


     t = ob->ob_spec.tedinfo;
     t->te_ptext = txt;
     if   (is_8_3)
          {
          t->te_txtlen = 12;
          t->te_ptmplt = tmplt_8_3;
          t->te_pvalid = "F";      /* "f" erlaubt nicht '*' und '?' */ 
          vislen = 13;
          }
     else {
          t->te_tmplen = t->te_txtlen = maxnamelen + 1;
          xted->xte_pvalid = "m";
          xted->xte_scroll = 0;
          xted->xte_ptmplt =  "_________________________________"
                              "_________________________________";
          t->te_ptmplt = NULL;
          t->te_pvalid = (void *) xted;
          xted->xte_vislen = maxnamelen;
          if   (xted->xte_vislen > vislen)
               xted->xte_vislen = vislen;
          }
     ob->ob_width = vislen*big_wchar;
}


/*********************************************************************
*
* Bearbeite durch EOS getrennte Zeichenketten.
*
* Rueckgabe:    Anzahl der benoetigten Bytes
*              *n = Anzahl der Zeichenketten
*              *maxlen = Laenge der laengsten Zeichenkette
*
*********************************************************************/

static long exam_strings( char *strings, long *n, long *maxlen )
{
     long l;
     register char *s;

     for  (s = strings,*maxlen = *n = 0; *s; (*n)++)
          {
          l = strlen(s);
          if   (l > *maxlen)
               *maxlen = l;
          s += l+1;
          }
     return(s - strings + 1);
}


/*********************************************************************
*
* Sucht eine Zeichenkette <newpattern> in zwei Listen <patterns1>
* und <patterns2>. Gibt einen Zeiger auf das gefundene <pattern>
* zurueck oder NULL.
*
*********************************************************************/

static char *srch_pattern( char *newpattern,
                         char *patterns1, char *patterns2 )
{
     register char *s;
     register int i;

     for  (s = patterns1,i = 0; i < 2; i++,s = patterns2)
          {
          while(*s)
               {
               if   (!stricmp(newpattern, s))
                    return(s);
               while(*s)
                    s++;
               s++;
               }
          }
     return(NULL);
}


/*********************************************************************
*
* Fuegt eine Zeichenkette <newpattern> in eine Liste <patterns>
* ein, und zwar an der Stelle <pos>. Ist <pos> == NULL, wird das
* <newpattern> angehaengt. Gibt einen Zeiger auf das eingefuegte
* pattern zurueck.
* <newpattern> kann auch leer sein.
*
*********************************************************************/

static char *insert_pattern(char *newpattern, char *patterns,
                    char *pos, int buflen)
{
     register char *s;
     register char *ende;
     int newlen;
     int oldlen;
     int freelen;


     newlen = (int) strlen(newpattern);
     if   (newlen)
          newlen++;

     /* erstmal das Ende suchen und freien Platz ermitteln */

     ende = patterns;
     while(*ende)
          {
          while(*ende)
               ende++;
          ende++;
          }
     ende++;
     freelen = (int) ((patterns+buflen) - ende);

     if   (pos)
          {
          /* Platz fuer neue Zeichenkette */
          s = pos;
          while(*s)
               s++;
          s++;      /* s hinter das alte EOS */
          oldlen = (int) (s - pos);
          }
     else {
          pos = ende - 1;
          pos[newlen] = '\0';      /* Neues Ende-Zeichen! */
          oldlen = 0;
          }

     if   (newlen - oldlen > freelen)
          {
          form_xerr(ENSMEM, NULL);
          return(NULL);
          }

     if   ((oldlen) && (oldlen != newlen))
          vmemcpy(pos+newlen, s, ende-s);


     if   (!newlen)
          {
          if   (oldlen)
               return(patterns);
          else return(NULL);
          }
     else {
          vmemcpy(pos, newpattern, newlen);
          return(pos);
          }
}


/*********************************************************************
*
* Bringt Pfad in Ordnung
*
*********************************************************************/

static void trim_path(char *spath, char *dpath)
{
     if   ((!*spath) || (spath[1] != ':'))
          {
          *dpath++ = Dgetdrv() + 'A';
          *dpath++ = ':';
          }
     else {
          *dpath++ = *spath++;
          *dpath++ = *spath++;
          }

     if   (*spath == '\\')
          {
          while(*spath)
               *dpath++ = *spath++;
          }
     else {
          Dgetpath(dpath, 0);
          dpath += strlen(dpath);
          if   (dpath[-1] != '\\')
               *dpath++ = '\\';
          while(*spath)
               *dpath++ = *spath++;
          }

     if   (dpath[-1] != '\\')
          *dpath++ = '\\';

     *dpath = EOS;
}


/*********************************************************************
*
* Wandelt eine Zeichenkette in Grossschrift um.
*
*********************************************************************/

#if 0 /* unused */
void upperstring( char *s )
{
     while(*s)
          *s++ = toupper(*s);
}
#endif


/*********************************************************************
*
* Wandelt DOS- Datum in eine Zeichenkette um.
*
*********************************************************************/

#define TIMESEP     ':'

static void date_to_str(char *s, unsigned int date)
{
     (*fslx_d2s)(s, date);
#if 0
#define DATESEP     '.'
     int t,m;

     t = date & 31;
     date >>= 5;
     m = date & 15;
     date >>= 4;
     date += 80;
     date %=100;
     *s++ = t/10 + '0';
     *s++ = t%10 + '0';
     *s++ = DATESEP;
     *s++ = m/10 + '0';
     *s++ = m%10 + '0';
     *s++ = DATESEP;
     *s++ = date/10 + '0';
     *s++ = date%10 + '0';
     *s = '\0';
#endif
}


/*********************************************************************
*
* Wandelt DOS- Zeit in eine Zeichenkette um.
*
*********************************************************************/

static void time_to_str(char *s, unsigned int time)
{
     int min /* ,sec */;

/*   sec = 2 * (time & 31);   */
     time >>= 5;
     min = time & 63;
     time >>= 6;
     *s++ = time/10 + '0';
     *s++ = time%10 + '0';
     *s++ = TIMESEP;
     *s++ = min/10 + '0';
     *s++ = min%10 + '0';
#if 0
     *s++ = TIMESEP;
     *s++ = sec/10 + '0';
     *s++ = sec%10 + '0';
#endif
     *s = '\0';
}


/*********************************************************************
*
* Pattern-Match-Routine.
* vollstaendige regulaere Ausdruecke mit Rekursion.
*
*********************************************************************/

static int pattern_match(char *pattern, char *fname)
{
     /* solange beide Zeichenketten nicht leer sind */

     while((*pattern) && (*fname))
          {
          if   (*pattern == '*')
               {
               /* erst unwahrscheinlicheren Fall als Rekursion */
               if   (pattern_match(pattern+1, fname))
                    return(TRUE);
               fname++;
               continue;
               }
          if   ((*pattern == '?') || (toupper(*fname) == toupper(*pattern)))
               {
               pattern++;
               fname++;
               continue;
               }
          return(FALSE);
          }

     /* jetzt ist mindesten eine Zeichenkette leer */

     if   ((*pattern) == (*fname))
          return(TRUE);       /* beide EOS */

     /* jetzt ist genau eine Zeichenkette leer */

     if   (*fname)
          return(FALSE);      /* pattern leer, fname nicht */

     /* jetzt ist pattern nicht leer, fname ist leer */

     while((*pattern) == '*')
          pattern++;
     return(!(*pattern));     /* OK, wenn nur '*'e uebrig */
}


/*********************************************************************
*
* Pattern-Match-Routine mit durch ',' getrennten Mustern,
* die als "oder" dienen.
*
*********************************************************************/

static int multi_pattern_match(char *pattern, char *fname)
{
     char *epattern;
     int res;

     while(*pattern)
          {
          epattern = strchr(pattern, ',');
          if   (!epattern)
               return(pattern_match(pattern, fname));
          *epattern = EOS;
          res = pattern_match(pattern, fname);
          *epattern = ',';
          if   (res)
               return(TRUE);
          pattern = epattern+1;
          }
     return(FALSE);
}


/*********************************************************************
*
* Fuehrt einen Popup-Dialog aus Zeichenketten durch.
* Das Popup erscheint ueber dem Objekt parent_tree[objnr].
* Die Zeichenketten sind durch EOS getrennt und durch EOS/EOS
* abgeschlossen.
* In <strings2> kann eine zweite Zeichenkettenliste oder NULL
* uebergeben werden.
*
*    Rueckgabe:      NULL  nix ausgewaehlt oder dasselbe nochmal
*                   ausgewaehlt oder zuwenig Speicher
*
*********************************************************************/

static char * do_popup( OBJECT *parent_tree, int objnr,
                    char *strings, char *strings2,
                    char *active_string )
{
     register char *s;
     OBJECT *tree;
     OBJECT *actobj;
     register OBJECT *o;
     register int i;
     long anzahl,maxwidth;
     int y,y_offs;

     long anzahl1,anzahl2,maxwidth2;



     if   (!strings)
          return(NULL);

     actobj = parent_tree+objnr;

     /* Anzahl der Zeilen und max. Zeilenbreite bestimmen */
     /* ------------------------------------------------- */

     exam_strings( strings, &anzahl1, &maxwidth );
     if   (strings2)
          {
          exam_strings( strings2, &anzahl2, &maxwidth2 );
          if   (maxwidth2 > maxwidth)
               maxwidth = maxwidth2;
          }
     else anzahl2 = 0L;

     anzahl = anzahl1 + anzahl2;

     /* Speicher allozieren */
     /* ------------------- */

     tree = (OBJECT *)Malloc(sizeof(OBJECT) * (anzahl+anzahl+1));
     if   (!tree)
          return(NULL);

     /* Baum erstellen */
     /* -------------- */

     maxwidth += 4;      /* wg. Rand links und rechts */
     maxwidth *= big_wchar;
     if   (maxwidth < actobj->ob_width)
          maxwidth = actobj->ob_width;

     /* Objekt der weissen Hintergrundbox */

     o = tree;
     o -> ob_next = -1;
     o -> ob_type = G_BOX;
     o -> ob_state = NORMAL;
     o -> ob_spec.index = 0x00ff1000L;
     o -> ob_flags = FL3DBAK;
     if   (anzahl > 0)
          {
/*        o -> ob_flags = NONE;    */
          o -> ob_head = 1;
          o -> ob_tail = (WORD) (anzahl+anzahl-1);
          }
     else {
          o -> ob_flags += LASTOB;
          o -> ob_head = o -> ob_tail = -1;
          }
     o -> ob_width =(WORD) maxwidth;
     o -> ob_height = (WORD) (anzahl * big_hchar);

     /* Objekte der Zeichenketten */

     y = 0;
     y_offs = -actobj->ob_height;
     for  (i = 1, s=strings; i <= anzahl; i++, s+=strlen(s)+1)
          {
          o++;
          if   (i == anzahl1+1)
               s = strings2;
          o -> ob_next = (i < anzahl) ? (i+i+1) : (0);
          o -> ob_head = o -> ob_tail = i+i;
          o -> ob_flags = SELECTABLE+FL3DBAK;
          o -> ob_type = G_IBOX;
          o -> ob_spec.index = 0x00000000L;
          o -> ob_state = NORMAL;

          o -> ob_width = (WORD) maxwidth;
          o -> ob_height = big_hchar;
          o -> ob_x = 0;
          o -> ob_y = y;

          if   (s == active_string)
               {
               y_offs = y;
               o -> ob_state += CHECKED;
               }

          o++;
          o -> ob_next = i+i-1;
          o -> ob_head = o -> ob_tail = -1;
          o -> ob_flags = NONE;
          if   (i == anzahl)
               o -> ob_flags += LASTOB;

          o -> ob_type = G_STRING;
          o -> ob_spec.free_string = s;

          o -> ob_state = NORMAL;

          o -> ob_width = 0;
          o -> ob_height = big_hchar;
          o -> ob_x = big_wchar + big_wchar;
          o -> ob_y = 0;

          y += big_hchar;
          }

     objc_offset(parent_tree, objnr, &tree[0].ob_x, &tree[0].ob_y);
     tree[0].ob_y -= y_offs;
     anzahl = form_popup(tree, 0L);
     if   (anzahl > 0)
          {
          s = tree[anzahl+1].ob_spec.free_string;
          if   (s == active_string)
               s = NULL;
          }
     else s = NULL;
     Mfree(tree);
     return(s);
}


/*********************************************************************
*
* Fuehrt einen Popup-Dialog mit einem Objektbaum durch.
* Das Popup erscheint ueber dem Objekt parent_tree[objnr].
*
*    Rueckgabe:      NULL  nix ausgewaehlt oder dasselbe nochmal
*                   ausgewaehlt oder zuwenig Speicher
*
*********************************************************************/

static int do_tree_popup( OBJECT *parent_tree, int objnr,
                    OBJECT *popup, int active_obj )
{
     int dummy,y_offs;

     if   (active_obj >= 0)
          {
          objc_offset(popup, active_obj, &dummy, &y_offs);
          y_offs -= popup[0].ob_y;
          popup[active_obj].ob_state |= CHECKED;
          }
     else y_offs = 0;
     objc_offset(parent_tree, objnr, &popup[0].ob_x, &popup[0].ob_y);
     popup[0].ob_y -= y_offs;
     dummy = form_popup(popup, 0L);
     if   (active_obj >= 0)
          popup[active_obj].ob_state &= ~CHECKED;
     return(dummy);
}


/*********************************************************************
*
* Kuerzt einen Pfadnamen sinnvoll ab.
* Der Pfad muss mit \ beginnen.
* Er wird, wenn er zu lang ist, auf
*
*    \...\lastdirs
*
* gekuerzt.
*
*********************************************************************/

static void abbrev_path_wo_drv(char *dst, char *src, int len )
{
     register char *t,*u;
     int l;

     if   ((l = (int) strlen(src)) < len)
          {
          vstrcpy(dst, src);
          return;
          }
     
     u = t = src + l - len + 4;
     while((*t) && (*t != '\\'))
          t++;
     *dst++ = *src++;    /* "\\" */
     *dst++ = '.';
     *dst++ = '.';
     *dst++ = '.';
     if   (!(*t) || !(t[1]))
          vstrcpy(dst, u);
     else vstrcpy(dst, t);
}


/*----------------------------------------------------------------------------------------*/ 
/* Handle des obersten Fenster zurueckliefern                                                                            */
/* Funktionsresultat:    Handle des Fanster oder -1 (kein Fenster der eigenen Applikation)     */
/*----------------------------------------------------------------------------------------*/ 
static WORD    top_whdl( void )
{
     WORD whdl;
     WORD buf[4];

     if ( _wind_get( 0, WF_TOP, buf ) == 0 )
          return( -1 );
     
     whdl = buf[0];                                                                       /* Handle des Fensters */

     if   ( whdl < 0 )                                                                    /* liegt ein Fenster einer anderen Applikation vorne? */
          return( -1 );

     return( whdl );                                                                      /* Handle des obersten Fensters */
}


/*----------------------------------------------------------------------------------------*/ 
/* Speicher fuer Resource anfordern und es kopieren                                        */
/* Funktionsergebnis:    Zeiger auf den Resource-Header oder 0L (Fehler)                  */
/*   rsc:                          Zeiger auf das zu kopierende Resource                  */
/*   len:                          Laenge des Resource                                     */
/*----------------------------------------------------------------------------------------*/ 
static RSHDR *copy_rsrc( RSHDR *rsc, LONG len )
{
     RSHDR *new;

     new = (RSHDR *)Malloc( len );
     
     if   ( new )
          {
          WORD dummyglobal[15];

          vmemcpy( new, rsc, len );   /* Resource kopieren */
          _rsrc_rcfix( dummyglobal, new );   /* Resource beim AES anmelden */
          }
     else form_xerr(ENSMEM, NULL);

     return( new );           /* Zeiger auf den Resource-Header */
}


/****************************************************************
*
* Sortiert die Dateien.
*
****************************************************************/

static int cmp_files(const void *ff1, const void *ff2, void *udata)
{
     int  r;
     long l;
     char *n1,*n2;
     const FILEINFO *f1;
     const FILEINFO *f2;
	FSEL_DIALOG *fsd = (FSEL_DIALOG *)udata;

     f1 = *((const FILEINFO **)ff1);
     f2 = *((const FILEINFO **)ff2);

     if   (fsd->sort_mode == SORTBYNONE)
          return(f1->number - f2->number);

     if   ((f1->mode & S_IFMT) == S_IFDIR)
          {
          if   (!((f2->mode & S_IFMT) == S_IFDIR))
               return(-1);
          else goto name;
          }
     if   ((f2->mode & S_IFMT) == S_IFDIR)
          return(1);

     switch(fsd->sort_mode)
          {
          case SORTBYNAME:
                         name:
                         return(stricmp(f1->name, f2->name));
          case SORTBYDATE:
                         l = ((unsigned long) f2->date) - ((unsigned long) f1->date);
                         if   (l == 0)
                              l = ((unsigned long) f2->time) - ((unsigned long) f1->time);
                         goto groe;
          case SORTBYSIZE:
                         l = f2->size - f1->size;
                         groe:
                         if   (l == 0)
                              goto name;
                         else return((l > 0) ? 1 : -1);
          case SORTBYTYPE:
                         n1 = fnam2ext(f1->name);
                         n2 = fnam2ext(f2->name);
                         if   (n1 == NULL && n2 == NULL)
                              goto name;
                         if   (n1 == NULL)
                              return(-1);
                         if   (n2 == NULL)
                              return(1);
                         r = stricmp(n1,n2);
                         if   (r == 0)
                              goto name;
                         return(r);
          }
     return(0);
}


/***************************************************************
*
* Liefert Icon/Text zu einer Zeile
*
****************************************************************/

static void get_icn_txt(OBJECT *tree, int boxobj,
               int *icn, int *txt)
{
     *icn = tree[tree[boxobj].ob_head].ob_next;
     *txt = tree[*icn].ob_next;
}


/***************************************************************
*
* next_selfile initialisieren
*
****************************************************************/

static int first_selfile( FSEL_DIALOG *fsd )
{
     register int i;
     FILEINFO *fi;

     fsd->next_selfile = NULL;
     i = 0;
     if   (fsd->files)
          {
          for  (fi = fsd->files[0], i = 0; (fi); fi=fi->next)
               {
               if   (fi->sel)
                    {
                    if   (!fsd->next_selfile)
                         fsd->next_selfile = fi;
                    i++;
                    }
               }
          }
     return(i);
}


static int next_selfile( FSEL_DIALOG *fsd )
{
     FILEINFO *fi;

     if   (fsd->next_selfile)
          {
          fi = fsd->next_selfile->next;
          while(fi)
               {
               if   (fi->sel)
                    {
                    fsd->next_selfile = fi;
                    return(TRUE);
                    }
               fi = fi->next;
               }
          fsd->next_selfile = NULL;
          }
     return(FALSE);
}


/***************************************************************
*
* Verzeichnis sortieren und Dateien verketten.
*
****************************************************************/

static void sort_and_cat( FSEL_DIALOG *fsd )
{
     FILEINFO **p_d;
     int anzahl;

     anzahl = fsd->nfiles;
     shelsort(fsd->files, (size_t) anzahl,
               sizeof(FILEINFO *), cmp_files, fsd);

     for  (p_d = fsd->files; anzahl > 0; anzahl--,p_d++)
          {
          p_d[0]->next = (anzahl == 1) ? NULL : p_d[1];
          }
}


/***************************************************************
*
* Verzeichnis einlesen und sortieren.
*
****************************************************************/

static long read_dir( FSEL_DIALOG *fsd )
{
     char path[512];          /* sollte reichen */
     long memblksize;
     char *epath;
     register int i;
     OBJECT *tree;
     int offs;
     register int anzahl;
     int maxnamelen;
     int maxmem_per_name;
     long err;
     XATTR xa;
     long err_xr;
     long dirhandle;
     char *ziele,*limit;
     FILEINFO *mdta,**p_d;
/*   int was_long_names = FALSE;   */


     /* Speicherblock allozieren */
     /* ------------------------ */

     if   (fsd->memblk)
          {
          Mfree(fsd->memblk);
          fsd->memblk = NULL;
          }
     memblksize = (long) Malloc(-1L);
     if   (memblksize > MINFREEBLK+MINFREEBLK)
           memblksize -= MINFREEBLK;
     if   (memblksize > FIRSTMAXMEMBLK)
          memblksize = FIRSTMAXMEMBLK;
     if   (memblksize < 512L)
          return(ENSMEM);               /* nix zu wollen */
#pragma warn -pia
     if   (!(fsd->memblk = (char *)Malloc(memblksize)))
#pragma warn .pia
          return(ENSMEM);

     vstrcpy(path, fsd->path);

     /* Verzeichnis oeffnen (Automounter!) */
     /* --------------------------------- */

     if   (fsd->flags & DOSMODE)
          {
          anzahl = 1;
          offs = 0;
          }
     else {
          anzahl = 0;
          offs = 4;                /* inode ueberlesen */
          }
     err = Dopendir(path, anzahl);
     if   (err < E_OK)
          {
          Mfree(fsd->memblk);
          fsd->memblk = NULL;
          return(err);
          }
     dirhandle = err;

     /* Dateinamenlaenge usw. ermitteln */
     /* ------------------------------ */

     fsd->dos_mode = TRUE;
     maxnamelen = 12;
     if   (!(fsd->flags & DOSMODE))
          {
          err = Dpathconf(path, DP_NAMEMAX);
          if   (err > 0L)
               {
               maxnamelen = (int) err;
               fsd->dos_mode = (Dpathconf(path, DP_TRUNC) == DP_DOSTRUNC);
               }
          }

     maxmem_per_name = (int) (sizeof(FILEINFO) + maxnamelen + 1 +
               sizeof(FILEINFO *) );
     if   (maxmem_per_name & 1)
          maxmem_per_name++;       /* auf WORD runden */

     /* Verzeichnis einlesen */
     /* -------------------- */

     epath = path+strlen(path);    /* hier Dateiname ansetzen */
     ziele = fsd->memblk;
     limit = ziele + memblksize - maxmem_per_name;
     /* Mono-Zeichensatz: Strings fuer den Text: */
     if   (finfo_big.fontmono)
          limit -= NLINES * (maxnamelen + NAMDATALEN + 1);

     anzahl = 0;

     err = err_xr = E_OK;
     while((err == E_OK) && (err_xr == E_OK))
          {
          if   (ziele >= limit)
               {
               long newsize = memblksize+NEXTMEMBLK;

               if   ((memblksize >= LASTMAXMEMBLK) ||
                     (memblksize < FIRSTMAXMEMBLK))
                    break;

               /* Versuche Blockvergroesserung */
               /* -------------------------- */

               if   (Mshrink(0, fsd->memblk,
                              memblksize+NEXTMEMBLK))
                    {
                    char *newblk;

                    newblk = (char *)Malloc(newsize);
                    if   (!newblk)
                         break;    /* Fehler */
                    vmemcpy(newblk, fsd->memblk, ziele - fsd->memblk);
                    limit = newblk + (limit - fsd->memblk);
                    ziele = newblk + (ziele - fsd->memblk);
                    Mfree(fsd->memblk);
                    fsd->memblk = newblk;
                    }
               limit += NEXTMEMBLK;
               memblksize = newsize;
               }

          mdta = (FILEINFO *) ziele;
          err = Dxreaddir(maxnamelen+offs+1, dirhandle,
                         mdta->name-offs,
                         &xa, &err_xr);
          if   (err == ERANGE)
               {
               err = err_xr = E_OK;
#if 0
             was_long_names = TRUE;
#endif
               continue;
               }

          if   (err || err_xr ||
                    (mdta->name[0] == '.') &&
                    ((!mdta->name[1]) ||
                     ((mdta->name[1] == '.') &&
                      (!mdta->name[2])
                     )
                    )
               )
               continue;

#if 0
          if   ((!status.show_all) &&
                (xa.attr & (FA_HIDDEN | FA_SYSTEM))
               )
               continue;      /* verst. Dateien! */
#endif
          /* ggf. Symlink behandeln */

          if   ((!(fsd->flags & NFOLLOWSLKS)) &&
                    (xa.st_mode & S_IFMT) == S_IFLNK)
               {
               XATTR xa2;

               mdta->is_alias = TRUE;
               vstrcpy(epath, mdta->name);
               err = Fxattr(0, path, &xa2);
               if   (!err)
                    xa = xa2;
               err = E_OK;
               }
          else mdta->is_alias = FALSE;

          /* ggf. filtern */
          /* ------------ */

          if   (fsd->filter)
               {
               *epath = EOS;
               if   (!fsd->filter(path, mdta->name, &xa))
                    continue;
               }

          /* Pattern-Matching */
          /* ---------------- */

          if   ((xa.st_mode & S_IFMT) != S_IFDIR)
               {
               if   (!multi_pattern_match(fsd->pattern, mdta->name))
                    continue;
               }

          mdta->sel      = FALSE;
          mdta->number = anzahl;
          mdta->time = xa.st_mtim.u.d.time;   /* Modif.zeit */
          mdta->date = xa.st_mtim.u.d.date;
          mdta->size = xa.st_size;
          mdta->mode = xa.st_mode;
          anzahl++;
          ziele += sizeof(FILEINFO)+strlen(mdta->name)+1;
          if   (((long) ziele) & 1)
               ziele++;       /* WORD align! */
          limit -= maxmem_per_name;
          }

     Dclosedir(dirhandle);

#if 0
     if   (was_long_names)
          {
          form_alert(1,"[1][Das Verzeichnis enth",$84,"lt ",$81,"berlange|"
                         "Dateinamen.][  OK  ]");
          }
#endif

     if   (err == E_OK)
          fsd->too_many_files = TRUE;
     else {
          fsd->too_many_files = FALSE;
          if   (err == EFILNF || err == ENMFIL)
               err = E_OK;
          }


     fsd->nfiles = anzahl;

     /* Zeiger aufbauen */
     /* --------------- */

     if   (fsd->dos_mode && (fslx_flags & SHOW8P3))
          fsd->max_name = 12;           /* 8.3 */
     else fsd->max_name = 0;            /* laengster Dateiname */
     if   (!finfo_big.fontmono)
          {
          /* Breite der Spalte "Dateiname" fuer Vektorfonts */
          fsd->xtab_namelen = 20;
          fsd->xtab_typelen = 8;
          }

     if   (anzahl)
          {
          fsd->files = (FILEINFO **) ziele;
          limit = (char *) (fsd->files + anzahl);
          for  (p_d = fsd->files,ziele = fsd->memblk;
                    anzahl > 0; anzahl--)
               {
               mdta = (FILEINFO *) ziele;
               maxnamelen = (WORD) strlen(mdta->name);
               if   (maxnamelen > fsd->max_name)
                    fsd->max_name = maxnamelen;
               if   (!finfo_big.fontmono)
                    {
                    char *s;
                    WORD len,tlen;

     #pragma warn -pia
                    if   (fsd->dos_mode && (fslx_flags & SHOW8P3) && 
                         (s = strchr(mdta->name, '.')))
     #pragma warn .pia
                         {
                         *s = EOS;
                         len = fs_xtnt(mdta->name);
                         *s++ = '.';
                         tlen = fs_xtnt(s);
                         if   (fsd->xtab_typelen < tlen)
                              fsd->xtab_typelen = tlen;
                         }
                    else {
                         len = fs_xtnt(mdta->name);
                         }
     
                    if   (fsd->xtab_namelen < len)
                         fsd->xtab_namelen = len;
                    }
               *p_d++ = mdta;
               ziele += sizeof(FILEINFO)+maxnamelen+1;
               if   (((long) ziele) & 1)
                    ziele++;       /* WORD align! */
               }

          /* ggfs. free_strings eintragen: */

          if   (finfo_big.fontmono)
               {
               tree = fsd->tree;
               for  (i = 0; i < NLINES; i++)
                    {
                    int icn,txt;
     
                    get_icn_txt(tree, objs[i], &icn, &txt);
                    tree[txt].ob_spec.free_string = limit;
                    limit += fsd->max_name+NAMDATALEN+1;
                    }
               }
          memblksize = limit - fsd->memblk;
          Mshrink(0, fsd->memblk, memblksize);
          }
     else {
          Mfree(fsd->memblk);
          fsd->memblk = NULL;
          fsd->files = NULL;
          }

     /* Sortieren! */
     /* ---------- */

     sort_and_cat(fsd);

     return(E_OK);
}


/***************************************************************
*
* Der Pfad hat sich geaendert, und der Dialog wird
* entsprechend modifiziert.
*
****************************************************************/

static void update_path(FSEL_DIALOG *fsd )
{
     char *drvs;

     fsd->path_dirty = TRUE;
     drvs = fsd->tree[FS_DRIVE].ob_spec.free_string;
     if   (*drvs != fsd->path[0])
          {
          *drvs = fsd->path[0];
          fsd->drv_dirty = TRUE;
          }
     abbrev_path_wo_drv(fsd->abbr_path,
               fsd->path+2,
               fsd->tree[FS_PATH].ob_width/big_wchar);
}


/***************************************************************
*
* Das Suchmuster hat sich geaendert, und der Dialog wird
* entsprechend modifiziert.
*
****************************************************************/

static void update_pattern(FSEL_DIALOG *fsd )
{
     strncpy(fsd->tree[FS_EXTENSION].ob_spec.free_string,
               fsd->pattern, PATTOBJLEN-1);
     fsd->patt_dirty = TRUE;
}


/***************************************************************
*
* Der Dateiname hat sich geaendert, und der Dialog wird
* entsprechend modifiziert.
* Falls sich der Cursor im Dateinamenfeld befunden hat, muss
* er vorher abgeschaltet werden.
*
****************************************************************/

static void dest_pathme(FSEL_DIALOG *fsd, char *name )
{
     if   ((fsd->editob == FPT_USER) && (!fsd->fname_dirty))
          {
          if   (fsd->dialog)
               wdlg_set_edit(fsd->dialog, 0);
          else
          if   (fsd->cursorpos >= 0)
               objc_edit(fsd->tree, fsd->editob, 0, &fsd->cursorpos, ED_END, NULL);
          }
     if   (fsd->flags & DOSMODE)
          int_8_3(fsd->fname, name);
     else strncpy(fsd->fname, name, fsd->fnamelen-1);
     fsd->fname[fsd->fnamelen-1] = EOS;
     fsd->fname_dirty = TRUE;
}


/***************************************************************
*
* Der Sortiermodus hat sich geaendert, und der Dialog wird
* entsprechend modifiziert.
*
****************************************************************/

static void update_sort(FSEL_DIALOG *fsd )
{
     if   (fsd->files)
          {
          sort_and_cat(fsd);
          lbox_set_items(fsd->lbox,
                    (fsd->files) ?
                    ((LBOX_ITEM *) fsd->files[0]): NULL);
          lbox_update(fsd->lbox, NULL);
          fsd->data_dirty = TRUE;
          }
     fsd->tree[OPTIONS].ob_spec.free_string =
          fsd->sort_popup[fsd->sort_mode+SORT_NAME].ob_spec.
                                        free_string+2;
}


/***************************************************************
*
* Das Verzeichnis wird eingelesen und die Scrollbox
* erstellt.
*
****************************************************************/

static void update_dir(FSEL_DIALOG *fsd )
{
     long retcode;

     /* Verzeichnis einlesen, bei Fehlern auf die root */
     /* bzw. auf Laufwerk U: umschalten                */
     /* ---------------------------------------------- */

     fsd->data_dirty = TRUE;
     retcode = read_dir(fsd);
     if   ((retcode == EDRIVE) || (retcode == EPTHNF))
          {
          if   (retcode == EPTHNF)
               fsd->path[3] = EOS;      /* -> root */
          else vstrcpy(fsd->path, "U:\\");
          update_path(fsd);
          read_dir(fsd);
          }
     else {
          if   (retcode < 0L)
               form_xerr(retcode, NULL);
          }
     lbox_set_items(fsd->lbox,
               (fsd->files) ? ((LBOX_ITEM *) fsd->files[0]):
                         NULL);
     lbox_set_asldr(fsd->lbox, 0, NULL);     /* vertikal */
     lbox_set_bentries( fsd->lbox, 4 +1+ fsd->max_name+25 );     /* inkl. Icon */
     lbox_set_bsldr(fsd->lbox, 0, NULL);     /* vertikal */
     lbox_update(fsd->lbox, NULL);
}


               
/***************************************************************
*
* Wechselt das Laufwerk
*
****************************************************************/

static void change_drive( FSEL_DIALOG *fsd, char drvname )
{
     long errcode;
     char olddrv;


     if   (drvname != fsd->path[0])
          {
          olddrv = fsd->path[0];        /* altes Laufwerk */
          fsd->path[0] = drvname;
          errcode = Dgetpath(fsd->path+2, drvname-'A'+1);
          if   (!errcode)
               {
               if   (fsd->path[strlen(fsd->path)-1] != '\\')
                    strcat(fsd->path, "\\");
               update_path(fsd);
               update_dir(fsd);
               }
          else {
               if   (errcode != EDRIVE)
                    form_xerr(errcode, NULL);
               fsd->path[0] = olddrv;
               fsd->path[2] = '\\';
               }
          }
}


/***************************************************************
*
* Geht eine Ebene zurueck
*
****************************************************************/

static void goto_parent( FSEL_DIALOG *fsd )
{
     int len;
     char *s;

     len = (WORD) strlen(fsd->path+3);
     if   (len)
          {
          fsd->path[len+2] = EOS;
          s = strrchr(fsd->path+2, '\\');
          if   (s)
               {
               s[1] = EOS;
               update_path(fsd);
               update_dir(fsd);
               }
          }
}


/***************************************************************
*
* Geht zum Wurzelverzeichnis
*
****************************************************************/

static void goto_root( FSEL_DIALOG *fsd )
{
     if   (fsd->path[3])
          {
          fsd->path[3] = EOS;
          update_path(fsd);
          update_dir(fsd);
          }
}


/***************************************************************
*
* Geht eine Ebene rauf
*
****************************************************************/

static void goto_subdir( FSEL_DIALOG *fsd, FILEINFO *fi )
{
     strcat(fsd->path, fi->name);
     strcat(fsd->path, "\\");
     update_path(fsd);
     update_dir(fsd);
}


/***************************************************************
*
* Rechnet Scrollbox-Indizes in Objektnummern um.
* Rueckgabe -1, wenn nicht sichtbar.
*
****************************************************************/

static int index2obj( FSEL_DIALOG *fsd, int index )
{
     index -= lbox_get_afirst(fsd->lbox);
     if   (index < 0)
          return(-1);         /* unsichtbar */
     if   (index >= NLINES)
          return(-1);         /* unsichtbar */
     return(objs[index]);
}


/***************************************************************
*
* Rechnet Unter-Objektnummern in Zeilennummern der sichtbaren
* Zeilen um (0..13).
* Rueckgabe -1, wenn nicht gueltig.
*
****************************************************************/

static WORD obj2line( WORD tstobj, OBJECT *tree )
{
     register int i;
     register int *o;
     int icn,txt;

     for  (i = 0,o=objs; i < NLINES; i++,o++)
          {
          get_icn_txt(tree, *o, &icn, &txt);
          if   ((icn == tstobj) || (txt == tstobj) ||
                (tree[*o].ob_tail == tstobj))
               return(i);
          }
     return(-1);
}


/***************************************************************
*
* Berechnet eine Ausgabezeile
*
****************************************************************/

static void fi2str( FSEL_DIALOG *fsd, FILEINFO *fi, char *buf )
{
     register char *s,*t;
     register char *fname = fi->name;
     register int i;
     char gr[10],*g;


     s = t = buf;

     if   (fsd->dos_mode && (fslx_flags & SHOW8P3))
          {
          while(*fname != '.' && (*fname))
               *s++ = *fname++;
          if   (*fname == '.')
               fname++;
          t += 9;
          while(s < t)
               *s++ = ' ';
          t += 3;
          }
     else {
          vstrcpy(s, fname);
          t += fsd->max_name;
          }

     while(*fname)
          *s++ = *fname++;
     while(s < t)
          *s++ = ' ';

     /* Groesse */
     /* ----- */

     *s++ = ' ';

     if   ((fi->mode & S_IFMT) == S_IFDIR)
          gr[0] = EOS;
     else {
          if   (fi->size > 9999999L)
               {
               _ltoa((fi->size) >> 10L, gr);
               strcat(gr, "k");
               }
          else _ltoa(fi->size, gr);
          }
     for  (i = 8 - (int) strlen(gr); i > 0; i--)
          *s++ = ' ';
     g = gr;
     while(*g)
     *s++ = *g++;

     /* Datum */
     /* ----- */

     *s++ = ' ';
     *s++ = ' ';
     date_to_str(s, fi->date);
     s += 8;

     /* Uhrzeit */
     /* ------- */

     *s++ = ' ';
     *s++ = ' ';
     time_to_str(s, fi->time);
     s += 5;
     *s = EOS;
}


/*********************************************************************
*
* Auswahl- und Setzroutinen fuer die Scrollbox
*
*********************************************************************/

#pragma warn -par

static void cdecl select_item( void *box, OBJECT *tree,
               LBOX_ITEM *item, void *user_data,
               WORD obj_index, WORD last_state )
{
     FILEINFO *fi = (FILEINFO *) item;
     FSEL_DIALOG *fsd = (FSEL_DIALOG *) user_data;

     if   (item->selected)
          {
          fsd->last_selected = fi;
          if   ((fi->mode & S_IFMT) != S_IFDIR)
               dest_pathme(fsd, fi->name);
          }
     else fsd->last_deselected = fi;
}

static WORD cdecl set_item( void *box, OBJECT *tree,
               LBOX_ITEM *item, WORD index,
               void *user_data, GRECT *rect, WORD offset )
{
     FILEINFO *fi = (FILEINFO *) item;
     FSEL_DIALOG *fsd = (FSEL_DIALOG *) user_data;
     OBJECT *dob;
     int icn,txt;


     get_icn_txt(tree, index, &icn, &txt);

     /* Icon */

     dob = tree+icn;
     dob->ob_state &= ~SELECTED;
     dob->ob_flags &= ~HIDETREE;

     if   ((item) && (offset < 4) && ((fi->mode & S_IFMT) == S_IFDIR))
          {
          dob->ob_x = -offset * big_wchar;
          if   (item->selected)
               {
               dob->ob_state |= SELECTED;
#if 0
             dob->ob_state &= ~WHITEBAK;
#endif
               }
          else {
#if 0
             dob->ob_state |= WHITEBAK;
#endif
               }

          if   (enable_3d)
               {
               dob -> ob_type = G_CICON;
               dob -> ob_spec.ciconblk = fsd->folder_icon;
               }
          else {
               dob -> ob_type = G_ICON;
               dob -> ob_spec.iconblk = &(fsd->folder_icon->monoblk);
               }
          }
     else dob->ob_flags |= HIDETREE;

     /* Text */

     dob = tree+txt;
     dob->ob_state &= ~SELECTED;
     dob->ob_flags &= ~HIDETREE;

     dob->ob_x = (4-offset) * big_wchar;
     dob->ob_width = tree[index].ob_width + (offset-4) * big_wchar;
#if 0
     dob->ob_width = (NAMLEN+1+offset) * big_wchar;
#endif
#if 0
hexl((long) dob->ob_width);
putstr("  \r");
#endif
#if 0

     if   (fsd->dialog)
          dob->ob_width += 2;
#endif
     if   (item)
          {
          if   (item->selected)
               dob->ob_state |= SELECTED;
          if   (dob->ob_type == G_STRING)
               fi2str(fsd, fi, dob->ob_spec.free_string);
#if 0
        buf[NAMLEN+1+offset] = EOS;
#endif
          }
     else dob->ob_flags |= HIDETREE;

     return(index);
}
#pragma warn .par


/***************************************************************
*
* Loescht die dirty-Flags
*
****************************************************************/

static void clr_dirty( FSEL_DIALOG *fsd)
{
     fsd->path_dirty = fsd->fname_dirty = fsd->data_dirty =
          fsd->drv_dirty = fsd->patt_dirty = FALSE;
}


/***************************************************************
*
* Gibt eine FSEL_DIALOG Struktur frei.
*
****************************************************************/

static void fsel_dialog_exit( FSEL_DIALOG *fsd )
{
     if   (fsd)
          {
          if   (fsd->files)
               Mfree(fsd->memblk);
          if   (fsd->memblk)
               lbox_delete(fsd->lbox);
          if   (fsd->rshdr)
               Mfree(fsd->rshdr);
          if   (fsd->dialog)
               {
               wdlg_close(fsd->dialog, NULL, NULL);
               wdlg_delete(fsd->dialog);
               }
          Mfree(fsd);
          }
}


/***************************************************************
*
* USERBLK-Funktionen fuer Clipping und Textausgabe
*
****************************************************************/

static int cdecl clip_on( PARMBLK *p )
{
     FSEL_DIALOG *fsd = (FSEL_DIALOG *) p->pb_parm;
     fsd->tmpclip = *((GRECT *) (&p->pb_xc));
     grects_intersect( (GRECT *) (&p->pb_xc), (GRECT *) (&p->pb_x));
     set_clip_grect((GRECT *) (&p->pb_x));
     return(0);
}

static int cdecl clip_off( PARMBLK *p )
{
     FSEL_DIALOG *fsd = (FSEL_DIALOG *) p->pb_parm;
     set_clip_grect(&fsd->tmpclip);
     return(0);
}

static int cdecl draw_fname( PARMBLK *p )
{
     char *t;
     FSEL_DIALOG *fsd = (FSEL_DIALOG *) p->pb_parm;
     WORD line;
     FILEINFO *fi;
     char buf[256];


     line = obj2line( p->pb_obj, p->pb_tree );
     if   (line < 0)
          return(0);               /* Zeile ungueltig */
     fi = (FILEINFO *) lbox_get_item(fsd->lbox,
                    line+lbox_get_afirst(fsd->lbox));

     if   (fi->is_alias)
          fs_effct(4);        /* kursiv */
     if   (fsd->dos_mode && (fslx_flags & SHOW8P3))
          {
          t = strchr(fi->name, '.');
          if   (t)
               *t = EOS;
          fs_txt( fi->name, (GRECT *) &(p->pb_x) );
          p->pb_x += 8 + fsd->xtab_namelen;
          if   (t)
               {
               *t++ = '.';
               fs_txt( t, (GRECT *) &(p->pb_x) );
               }
          p->pb_x += fsd->spaltenabstand + fsd->xtab_typelen;
          }
     else {
          fs_txt( fi->name, (GRECT *) &(p->pb_x) );
          p->pb_x += 8 + fsd->xtab_namelen;
          }

     p->pb_x += fsd->xtab_sizelen;
     if   ((fi->mode & S_IFMT) != S_IFDIR)
          {
          if   (fi->size > 9999999L)
               {
               _ltoa((fi->size) >> 10L, buf);
               strcat(buf, "k");
               }
          else _ltoa(fi->size, buf);
          fs_rtxt( buf, (GRECT *) &(p->pb_x) );        /* Ausrichtung rechts */
          }
     p->pb_x += fsd->spaltenabstand;

     date_to_str(buf, fi->date);
     fs_txt( buf, (GRECT *) &(p->pb_x) );
     p->pb_x += fsd->spaltenabstand + fsd->xtab_datelen;

     time_to_str(buf, fi->time);
     buf[5] = EOS;
     fs_txt( buf, (GRECT *) &(p->pb_x) );

     if   (fi->is_alias)
          fs_effct(0);        /* nicht mehr kursiv */
     return(p->pb_currstate);
}


/***************************************************************
*
* Legt an und initialisiert eine FSEL_DIALOG Struktur.
*
****************************************************************/

static void korr_tree( OBJECT *tree, int is_wdialog )
{
     int hc2 = big_hchar >> 1;


     tree->ob_width = fslx_dlw;    /* letzte Groesse */
     tree[POS_BOX].ob_width = tree->ob_width;
     tree[NAM_LABEL].ob_y += hc2 + 4;
     tree[FPT_USER].ob_y += hc2 + 4;

     tree[TITLE].ob_y -= hc2;
     tree[POS_BOX].ob_y -= hc2;
     tree[0].ob_height -= hc2;
     if   (tree[0].ob_height > desk_g.g_h - 6)
          tree[0].ob_height = desk_g.g_h - 6;
     tree[FS_ICONBACK].ob_y = tree[FS_BBOX].ob_y - tree[FS_ICONBACK].ob_height;
     tree[FS_DRIVE].ob_y = tree[FS_PATH].ob_y =
     tree[FS_EXTENSION].ob_y = tree[FS_INPUT_EXT].ob_y =
                         tree[FS_ICONBACK].ob_y + 1;

     tree[FS_INPUT_EXT].ob_flags |= HIDETREE;

     if   (is_wdialog)
          {
          tree[0].ob_height -= big_hchar;
          tree[0].ob_state &= ~OUTLINED;
          tree[FS_BBOX].ob_x = 0;
          tree[FS_LRBACK].ob_width += 2;
          tree[POS_BOX].ob_x = 0;
          tree[POS_BOX].ob_y -= big_hchar;

          tree[NAM_LABEL].ob_x -= 4;
          tree[FPT_USER].ob_x -= 5;
          tree[OPTIONS].ob_x += big_hchar >> 1;
          tree[TITLE].ob_flags |= HIDETREE;
          }
     else tree->ob_width += (big_wchar << 1);

     _resize_fs_tree( tree, 0 );
}


static FSEL_DIALOG *fsel_dialog_init(
               char *path, int pathlen,
               char *fname, int fnamelen,
               char *patterns,
               WORD cdecl (*filter)(char *path, char *name, XATTR *xa),
               char *paths,
               int sort_mode,
               int flags,
               int is_wdialog )
{
     register int i;
     static int ctrl_objs[9] =
          {
          FS_BBOX, FS_UP, FS_DOWN, FS_UDBACK, FS_UDSL,
          FS_LEFT, FS_RIGHT, FS_LRBACK, FS_LRSL
          };
     FSEL_DIALOG *fsd;
     OBJECT **tree_addr;
     OBJECT *tree;
     OBJECT *dob1,*dob2;


     fsd = (FSEL_DIALOG *)Malloc(sizeof(FSEL_DIALOG)+
               pathlen+fnamelen+fnamelen);
     if   (fsd)
          {
          if   (!patterns)
               patterns = "*\0";

          fsd->magic = 'fsel';
          fsd->pathlen = pathlen;
          fsd->fnamelen = fnamelen;
          fsd->fname = fsd->path+pathlen;
          fsd->old_fname = fsd->fname+fnamelen;
          fsd->rshdr = copy_rsrc(fsel_rsc, fsel_rslen);
          fsd->button = 0;
          if   (fsd->rshdr)
               {
               fsd->whdl = -1;
               fsd->dialog = NULL;
               fsd->next_selfile = NULL;
               fsd->sort_mode = sort_mode;
               fsd->flags = flags;
               tree_addr = (OBJECT **)(((UBYTE *)(fsd->rshdr)) + fsd->rshdr->rsh_trindex);     /* Zeiger auf die Objektbaumtabelle holen */
               fsd->tree = tree = tree_addr[FSEL];
               korr_tree( tree, is_wdialog );     /* RSC korrigieren */
               fsd->sort_popup = tree_addr[SORT_POPUP];
               fsd->folder_icon = tree_addr[FSEL_ICONS][FS_ICFOLDER].ob_spec.ciconblk;
               fsd->folder_icon->monoblk.ib_char &= 0xff00;
               tree[FS_ICONBACK].ob_spec.ciconblk->monoblk.ib_wtext = 0;
               tree[FS_PATH].ob_spec.free_string = fsd->abbr_path;

               init_xted(tree+FPT_USER, fnamelen-1,
                         &(fsd->xted),
                         (flags & DOSMODE),
                         fsd->fname,
                         32);

               init_xted(tree+FS_INPUT_EXT, MAXEXTLEN,
                         &(fsd->xted_ext),
                         FALSE,
                         fsd->input_ext,
                         PATTOBJLEN);

               fsd->userblk_clip_on.ub_parm =
                    fsd->userblk_clip_off.ub_parm =
                    fsd->userblk_text.ub_parm = (long) fsd;
               fsd->userblk_clip_on.ub_code = clip_on;
               fsd->userblk_clip_off.ub_code = clip_off;
               fsd->userblk_text.ub_code = draw_fname;

               fsd->spaltenabstand = fs_xtnt("M");
               fsd->xtab_sizelen = fs_xtnt("8888888");
               fsd->xtab_datelen = fs_xtnt("88-88-88");
               fsd->xtab_timelen = fs_xtnt("88:88");

               for  (i = 0; i < NLINES; i++)
                    {
                    dob1 = tree + tree[objs[i]].ob_head;    /* CLIP ON */
                    dob2 = tree + tree[objs[i]].ob_tail;    /* CLIP OFF */
                    dob2->ob_flags |= TOUCHEXIT;
                    dob1->ob_spec.userblk = &fsd->userblk_clip_on;
                    dob2->ob_spec.userblk = &fsd->userblk_clip_off;
                    dob1->ob_x = dob1->ob_y =
                         dob2->ob_x = dob2->ob_y = 0;
                    dob1->ob_height = dob2->ob_height = tree[FS_BOX0].ob_height;
                    if   (!finfo_big.fontmono)
                         {
                         dob1 = tree + dob1->ob_next;  /* Icon */
                         dob1 = tree + dob1->ob_next;  /* Text */
                         dob1->ob_type = G_USERDEF;
                         dob1->ob_spec.userblk = &fsd->userblk_text;
                         }
                    }

               if   (!enable_3d)
                    {

                    dob1 = tree+FS_ICONBACK;
                    if   (dob1->ob_type == G_CICON)
                         {
                         dob1->ob_type = G_ICON;
                         dob1->ob_spec.iconblk = &(dob1->ob_spec.ciconblk->monoblk);
                         }

                    tree[ctrl_objs[3]].ob_spec.obspec.fillpattern =
                    tree[ctrl_objs[7]].ob_spec.obspec.fillpattern = IP_1PATT;
                    for  (i = 1; i <= 8; i++)
                         tree[ctrl_objs[i]].ob_spec.obspec.framesize = 1;
                    }

               /* Scrollbox erstellen */
               /* ------------------- */
          
               fsd->lbox =
                    lbox_create(
                         fsd->tree,
                         select_item,
                         set_item,
                         NULL,     /* Items */
                         NLINES,   /* Anzahl sichtbarer Eintraege */
                         0,        /* erster sichtbarer Eintrag */
                         ctrl_objs,
                         objs,
                         (flags & GETMULTI) ?
                              (LBOX_VERT+LBOX_REAL+LBOX_SHFT+LBOX_2SLDRS+LBOX_AUTO):
                              (LBOX_VERT+LBOX_REAL+LBOX_SNGL+LBOX_SHFT+LBOX_2SLDRS+LBOX_AUTO),
                         20,       /* Scrollverzoegerung */
                         fsd,      /* user data */
                         NULL,     /* kein WDialog */
/* hslider: */
                         tree[FS_BOX0].ob_width/big_wchar,
                                   /* sichtbare Spalten fuer HSlider, inkl. Icon */
                         0,        /* H-Scrollposition */
                         NAMLEN,   /* Anzahl Spalten */
                         20        /* Scrollverzoegerung */
                         );
               if   (!fsd->lbox)
                    {
                    Mfree(fsd->rshdr);
                    goto free;
                    }

               fsd->memblk = NULL;
               fsd->files = NULL;
               update_sort(fsd);

               vstrcpy(fsd->path, path);
               fsd->filter = filter;
               fsd->patterns = patterns;
               fsd->paths = paths;
               fsd->pattern = fsd->patterns;      /* erstes Muster */
               update_path(fsd);
               update_pattern(fsd);
               update_dir(fsd);
               fsd->old_fname[0] = '\0';
               fsd->fname_dirty = TRUE; /* damit der Cursor bleibt */
               dest_pathme(fsd, fname);
               /* kein dirty, da noch nix zu sehen: */
               clr_dirty(fsd);
               }
          else {
                free:
               Mfree(fsd);
               fsd = NULL;
               }
          }
     else form_xerr(ENSMEM, NULL);

     return(fsd);
}


/***************************************************************
*
* Zeichnet ein geaendertes Objekt neu.
*
****************************************************************/

static void fsel_draw( FSEL_DIALOG *fsd, int obj )
{
     GRECT g;
     OBJECT *tree;


     tree = fsd->tree;
     if   (obj == FS_BBOX)
          {
          objc_offset(fsd->tree, obj, &g.g_x, &g.g_y);
          g.g_w = tree[obj].ob_width;
          g.g_h = tree[obj].ob_height;
          }
     else g = *((GRECT *) &tree->ob_x);

     if   (fsd->dialog)
          wdlg_redraw( fsd->dialog, &g, obj, MAX_DEPTH );
     else {
          objc_draw(fsd->tree, obj, MAX_DEPTH, &g);
          }
}


/***************************************************************
*
* Zeichnet geaenderte Objekte neu.
*
****************************************************************/

static void fsel_redraw( FSEL_DIALOG *fsd )
{
     if   (fsd->path_dirty)
          fsel_draw( fsd, FS_PATH );
     if   (fsd->fname_dirty)
          {

          fsel_draw( fsd, FPT_USER );

          /* Cursor wieder einschalten */
          if   (fsd->editob == FPT_USER)
               {
               if   (fsd->dialog)
                    wdlg_set_edit(fsd->dialog, FPT_USER);
               else 
               if   (fsd->cursorpos >= 0)
                    objc_edit(fsd->tree, fsd->editob, 0, &fsd->cursorpos, ED_INIT, NULL);
               }
          }
     if   (fsd->data_dirty)
          {
          fsel_draw( fsd, FS_BBOX );
          fsel_draw( fsd, FS_UDBACK );
          fsel_draw( fsd, FS_LRBACK );
          }
     if   (fsd->drv_dirty)
          fsel_draw( fsd, FS_DRIVE );
     if   (fsd->patt_dirty)
          fsel_draw( fsd, FS_EXTENSION );
     clr_dirty(fsd);
}


/***************************************************************
*
* Scrollt auf eine Zeile
*
****************************************************************/

static void scroll_to_obj( FSEL_DIALOG *fsd, int obj, int index)
{
     OBJECT *dob,*tree;
     int icn,txt;

     tree = fsd->tree;
     if   (obj >= 0)
          {
          get_icn_txt(tree, obj, &icn, &txt);
          dob = tree+icn;
          dob->ob_state |= SELECTED;
/*        dob->ob_state &= ~WHITEBAK;   */
          dob = tree+txt;
          dob->ob_state |= SELECTED;
          fsel_draw(fsd, obj);
          }
     else lbox_ascroll_to( fsd->lbox,
          index,
          (GRECT *) &tree->ob_x,
          (GRECT *) &tree->ob_x);
}


/***************************************************************
*
* Wechselt das selektierte Element
*
****************************************************************/

static void chg_sel( FSEL_DIALOG *fsd,
                    int update,
                    int selected_index,
                    int new_selected_index,
                    int offs )
{
     FILEINFO *fi;
     OBJECT *tree;
     OBJECT *dob;
     int obj;
     int icn,txt;


     if   (selected_index == new_selected_index)
          return;        /* keine Aenderung */
     tree = fsd->tree;

     /* alten Index deselektieren */
     /* ------------------------- */

     if   (selected_index >= 0)
          {
          fi = (FILEINFO *) lbox_get_item(fsd->lbox, selected_index);
          fi->sel = FALSE;
          obj = index2obj( fsd, selected_index );
          if   (obj >= 0)
               {
               get_icn_txt(tree, obj, &icn, &txt);
               dob = tree+icn;
               dob->ob_state &= ~SELECTED;
/*             dob->ob_state |= WHITEBAK;    */
               dob = tree+txt;
               dob->ob_state &= ~SELECTED;
               fsel_draw(fsd, obj);
               }
          }

     /* neuen Index selektieren */
     /* ----------------------- */

     if   (new_selected_index >= 0)
          {
          fi = (FILEINFO *) lbox_get_item(fsd->lbox, new_selected_index);
          fi->sel = TRUE;

          if   ((update) && ((fi->mode & S_IFMT) != S_IFDIR))
               {
               dest_pathme(fsd, fi->name);
               fsel_redraw(fsd);
               }

          obj = index2obj( fsd, new_selected_index );
          scroll_to_obj( fsd, obj, new_selected_index + offs);
          }
}


/***************************************************************
*
* Hauptroutine fuer Autolocator.
*
****************************************************************/

static void do_autolocate( FSEL_DIALOG *fsd )
{
     char patt[260];
     register int i;
     char *name;
     register FILEINFO *fi;
     int selected_index,new_selected_index;

     name = fsd->fname;
     if   (strcmp(name, fsd->old_fname))
          {
          vstrcpy(fsd->old_fname, name);
          selected_index = lbox_get_slct_idx(fsd->lbox);

          new_selected_index = -1;
          if   ((fsd->files) && (*name))
               {
               if   (fsd->flags & DOSMODE)
                    ext_8_3(patt, name);
               else vstrcpy(patt, name);
               strcat(patt, "*");
               for  (fi = fsd->files[0],i=0; (fi); fi=fi->next,i++)
                    {
                    if   (pattern_match(patt, fi->name))
                         {
                         new_selected_index = i;
                         break;
                         }
                    }
               }

          chg_sel( fsd, FALSE, selected_index, new_selected_index,0 );
          }

}


/***************************************************************
*
* Hauptroutine fuer Tastaturbedienung.
* Wird VOR Bearbeitung der Events durchgefuehrt
* Rueckgabe 1, wenn Taste verarbeitet.
*
****************************************************************/

static int do_key(FSEL_DIALOG *fsd, WORD key, WORD kstate)
{
     int selected_index,new_selected_index;
     int offs;
     FILEINFO *fi;
     char *s;
     int amount;


     if   (kstate & K_CTRL)
          {
          if   (key == 0x011b)     /* ^Esc */
               {
               update_dir(fsd);
               goto redraw;
               }
          if   (key == 0x0e08)     /* ^BS wie ^H */
               goto parent;
          }

     if   ((key & 0xff) == '\r')   /* Return */
          {

          if   (fsd->editob == FS_INPUT_EXT)
               {
               fsd->tree[FS_INPUT_EXT].ob_flags |= HIDETREE;
               fsd->tree[FS_EXTENSION].ob_flags &= ~HIDETREE;
               /* Cursor im Editfeld ausschalten: */
               if   (fsd->dialog)
                    wdlg_set_edit(fsd->dialog, 0);
               else objc_edit(fsd->tree, fsd->editob, 0,
                                   &fsd->cursorpos, ED_END, NULL);
               fsd->editob = FPT_USER;
               /* Cursor anmelden */
               if   (fsd->dialog)
                    wdlg_set_edit(fsd->dialog, FPT_USER);
               else objc_edit(fsd->tree, fsd->editob, 0,
                                   &fsd->cursorpos, ED_INIT, NULL);
               /* Extension suchen */
               s = srch_pattern(fsd->input_ext, fsd->patterns, fslx_exts);
               if   (s)  /* Extension existiert schon */
                    {
               new_pattern:
                    fsd->pattern = s;
                    update_pattern(fsd);
                    update_dir(fsd);
                    }
               else
                    {

                    /* Test, ob aendern oder anfuegen */
                    /* d.h. s = Einfuegeposition */

                    if   ((fsd->pattern >= fslx_exts) &&
                         (fsd->pattern < fslx_exts+FIXED_PATTLEN))
                         s = fsd->pattern;
                    /* else s = NULL */
                         
                    if   (NULL !=
                              (s = insert_pattern(fsd->input_ext,
                                                  fslx_exts,
                                                  s, FIXED_PATTLEN)))
                         goto new_pattern;
                    }
               fsel_draw( fsd, FS_EXTENSION );
               goto redraw;
               }
          else {
               selected_index = lbox_get_slct_idx(fsd->lbox);
               if   (selected_index >= 0)
                    {
                    fi = (FILEINFO *) lbox_get_item(fsd->lbox, selected_index);
                    if   ((fi->mode & S_IFMT) == S_IFDIR)
                         {
                         goto_subdir(fsd, fi);
                         if   (fsd->fname[0])
                              {
                              dest_pathme(fsd, "");
                              fsel_redraw(fsd);
                              }
                         goto redraw;
                         }
                    }
               }
          }

     offs = altcode_asc(key);

     if   ((char) key == '\x09')   /* Tab */
          return(1);               /* ignorieren! */

     if   ((offs >= 'A') && (offs <= 'Z'))
          {
          change_drive(fsd, offs);
          redraw:
          fsel_redraw(fsd);
          return(1);
          }

     if   (key == 0x2308)          /* Ctrl-H */
          {
          parent:
          goto_parent(fsd);
          goto redraw;
          }

     if   (key == 0x2004)          /* Ctrl-D */
          {
          while((selected_index = lbox_get_slct_idx(fsd->lbox)) >= 0)
               chg_sel( fsd, FALSE, selected_index,-1,0 );
          return(1);
          }


     if   (key == 0x4700)          /* Pos1 */
          amount = -10000;
     else
     if   (key == 0x4737)          /* SHIFT-Pos1 */
          amount = 10000;
     else
     if   (key == 0x4800)          /* Cursor hoch */
          amount = -1;
     else
     if   ((key == 0x4838) ||      /* SHIFT-Cursor hoch */
           (key == 0x4818))        /* SHIFT-Ctrl-Cursor hoch */
          amount = -NLINES;
     else
     if   (key == 0x5000)          /* Cursor runter */
          amount = 1;
     else
     if   ((key == 0x5032) ||      /* SHIFT-Cursor runter */
           (key == 0x5012))        /* SHIFT-Ctrl-Cursor runter */
          amount = NLINES;
     else return(0);

     /* Ctrl-Cursor scrollt */

     if   (kstate & K_CTRL)
          {
          new_selected_index = lbox_get_afirst(fsd->lbox);
          new_selected_index += amount;

          if   (new_selected_index > fsd->nfiles-1)
               new_selected_index = fsd->nfiles-1;
          if   (new_selected_index < 0)
               new_selected_index = 0;

          scroll_to_obj( fsd, -1, new_selected_index);
          }

     else {
          selected_index = lbox_get_slct_idx(fsd->lbox);
          if   (selected_index < 0)
               new_selected_index =
                    (amount < 0) ? fsd->nfiles-1 :
                                   lbox_get_afirst(fsd->lbox);
          else {
               offs = (amount < 0) ? 0 : -NLINES+1;
               new_selected_index = selected_index + amount;
               if   (new_selected_index > fsd->nfiles-1)
                    new_selected_index = fsd->nfiles-1;
               if   (new_selected_index < 0)
                    new_selected_index = 0;

               if   (new_selected_index == selected_index)
                    return(1);

               }
          if   ((new_selected_index >= 0) &&
                    (new_selected_index < fsd->nfiles ))
               {
               chg_sel( fsd, TRUE, selected_index,
                         new_selected_index, offs );
               vstrcpy(fsd->old_fname, fsd->fname);
               }
          }

     return(1);
}


/****************************************************************
*
* Bestimmt die Begrenzung eines Objekts
*
****************************************************************/

static void objc_visgrect(OBJECT *tree, int objn, GRECT *g)
{
     OBJECT *o;
     int x,y,nx,ny;

     o = tree + objn;
     objc_offset(tree, objn, &nx, &ny);
     if   (((o -> ob_type == G_BUTTON) || (o -> ob_type == G_FTEXT)) &&
           (o-> ob_flags & FL3DMASK))
          {
          x = o->ob_x;
          y = o->ob_y;
          _form_center_grect(o, g);
          g->g_x += nx - o->ob_x;
          g->g_y += ny - o->ob_y;
          o->ob_x = x;
          o->ob_y = y;
          }
     else {
          g -> g_x = nx;
          g -> g_y = ny;
          g -> g_w = o -> ob_width;
          g -> g_h = o -> ob_height;
          }
}


/****************************************************************
*
* Malt ein Unterobjekt eines Fensterdialogs
*
****************************************************************/

static void subobj_wdraw(DIALOG *d, int obj, int startob, int depth)
{
     GRECT g;
     OBJECT *tree;


     wdlg_get_tree( d, &tree, &g );
     objc_visgrect( tree, obj, &g);
     wdlg_redraw( d, &g, startob, depth );
}


/****************************************************************
*
* Groessenanpassung fuer Dialogfenster
*
****************************************************************/

static void _resize_fs_tree( OBJECT *tree, WORD offset )
{
     OBJECT *o,*o2;
     register int i;
     int pr,pr2;
     int index;
     int icn,txt;
     WORD tw;


     o = tree+FS_SIZER;
     o->ob_x = tree->ob_width - o->ob_width;
     o->ob_y = tree->ob_height - o->ob_height;

     tw = tree[POS_BOX].ob_width;

     o = tree+FS_CANCEL;
     o->ob_x = tw - o->ob_width;
     if   (tree[POS_BOX].ob_x)
          o->ob_x -= 2;            /* Dialog */
     else o->ob_x -= big_wchar;    /* Fenster */

     o2 = tree+FS_OK;
     o2->ob_x = o->ob_x - o2->ob_width - 2 * big_wchar;

     o = tree+FS_INPUT_EXT;
     o->ob_x = tw - o->ob_width - 1;

     o = tree+FS_EXTENSION;
     o->ob_x = tw - o->ob_width - 1;

     o2 = tree+FS_PATH;
     o2->ob_width = o->ob_x - o2->ob_x - 2;

     /* Position der vert. Scrollelemente: */
     tw -= tree[FS_BBOX].ob_x;
     pr = tw - tree[FS_UDBACK].ob_width + 1;

     tree[FS_UP].ob_x = tree[FS_DOWN].ob_x =
               tree[FS_UDBACK].ob_x = pr;

     /* Box mit allen Dateinamen */
     tree[FS_BBOX].ob_width = pr - tree[FS_BBOX].ob_x;
     pr2 = pr-tree[FS_BBOX].ob_x;
     for  (i = 0; i < NLINES; i++)
          {
          index = objs[i];         /* Box, enthaelt Icon+Text */
          o = tree+index;
          o->ob_width = pr2;
          tree[o->ob_head].ob_width =    /* CLIP ON */
          tree[o->ob_tail].ob_width = pr2; /* CLIP OFF */
          get_icn_txt(tree, index, &icn, &txt);
          tree[txt].ob_width = pr2 + (offset-4) * big_wchar;
          }

     /* Position Scrollpfeil rechts: */
     pr -= tree[FS_RIGHT].ob_width - 1;
     tree[FS_RIGHT].ob_x = pr;

     /* Breite horiz. Scrollbalken: */
     pr -= tree[FS_LEFT].ob_width - 4;
     tree[FS_LRBACK].ob_width = pr;
}


static void resize_fs_tree( FSEL_DIALOG *fsd, WORD newwidth )
{
     OBJECT *tree;
     DIALOG *d;
     int oldwidth;
/*
     int vislen;
     XTED *xted;
     TEDINFO *t;
*/
     int editob,cursorpos;
     int h_scrolloffs;
     register int *rp;
     static int repos_obj[] =
          {
          FS_SIZER,
          FS_CANCEL,
          FS_OK,
          FS_RIGHT,
          FS_LRBACK,
          FS_UDBACK,
          FS_EXTENSION,
          FS_PATH,
          FS_UP,
          FS_DOWN,
          0
          };


     d = fsd->dialog;
     editob = wdlg_get_edit(d, &cursorpos);
     if   (editob)
          {
          wdlg_set_edit(d, 0);          /* Cursor abmelden */
          wdlg_set_edit(d, editob);     /* Cursor anmelden */
          }

     /* umzusetzende Objekte an Originalposition loeschen */
     for  (rp = repos_obj; *rp; rp++)
          subobj_wdraw(d, *rp, 0, 0);

     tree = fsd->tree;
     oldwidth = tree->ob_width;
     h_scrolloffs = lbox_get_bfirst( fsd->lbox );
     tree->ob_width = tree[POS_BOX].ob_width = newwidth;

     _resize_fs_tree( tree, 0 );

     lbox_set_bvis( fsd->lbox, tree[FS_BOX0].ob_width/big_wchar);
     lbox_set_bsldr(fsd->lbox, 0, NULL);
     lbox_update(fsd->lbox, NULL);
     abbrev_path_wo_drv(fsd->abbr_path,
               fsd->path+2,
               fsd->tree[FS_PATH].ob_width/big_wchar);

/*
     if   (!ifd->is_8_3)
          {
          o = tree+FI_FILENAME;
          t = &ifd->fname_ted;
          xted = &ifd->fname_xted;
          vislen = ((tree->ob_width - o->ob_x) / gl_hwchar) - 2;
          if   (vislen > t->te_txtlen - 1)
               vislen = t->te_txtlen - 1;

          if   (xted->xte_vislen != vislen)
               {
               subobj_wdraw(d, FI_FILENAME, 0, 0);
               xted->xte_vislen = vislen;
               (tree+FI_FILENAME)->ob_width = vislen*gl_hwchar;
               subobj_wdraw(d, FI_FILENAME, 0, 1);
               }
          }

     o = tree+FI_ALIAS;
     if   (!(o->ob_flags & HIDETREE))
          {
          subobj_wdraw(d, FI_ALIAS, 0, 0);
          xted = &ifd->alias_xted;
          vislen = (tree->ob_width / gl_hwchar) - 4;
          xted->xte_vislen = vislen;
          (tree+FI_ALIAS)->ob_width = vislen*gl_hwchar;
          subobj_wdraw(d, FI_ALIAS, 0, 1);
          }
*/

     wdlg_set_size( d, (GRECT *) &tree->ob_x);

     if   (editob)
          wdlg_set_edit(d, editob);     /* Cursor anmelden */

     /* umzusetzende Objekte an neuer Position zeichnen */
     for  (rp = repos_obj; *rp; rp++)
          subobj_wdraw(d, *rp, 0, 8);

     /* Inneres neu zeichnen, wenn Scrolloffset veraendert */
     newwidth -= oldwidth;
     if   ((h_scrolloffs) || (newwidth > 0))
          {
          GRECT g;

          objc_visgrect( tree, FS_BBOX, &g);
          g.g_y -= 1;
          g.g_h += 1;
          if   (!h_scrolloffs)
               {
               g.g_x += g.g_w - newwidth;
               g.g_w = newwidth;
               }
          wdlg_redraw( fsd->dialog, &g, FS_BBOX, 8 );
          }
}


/***************************************************************
*
* Hauptroutine fuer Button-Aktionen
*
***************************************************************/

static int do_button(FSEL_DIALOG *fsd, int exitbutton,
                    int nclicks)
{
     char *s,*t;
     int line;
     OBJECT *tree;
     long drives;
     int desel;
     char drivestrs[26*3+1+5];
     int dummy;
     int newwidth;


     tree = fsd->tree;
     line = obj2line( exitbutton, tree );
     if   (line >= 0)
          exitbutton = objs[line];

     if   ((line >= 0) ||
           (exitbutton == FS_UP) ||
           (exitbutton == FS_DOWN) ||
           (exitbutton == FS_UDBACK) ||
           (exitbutton == FS_UDSL) ||
           (exitbutton == FS_LEFT) ||
           (exitbutton == FS_RIGHT) ||
           (exitbutton == FS_LRBACK) ||
           (exitbutton == FS_LRSL)
          )
          {
          fsd->last_selected =
          fsd->last_deselected = NULL;
          lbox_do(fsd->lbox, exitbutton);

          /* Doppelklick auf eine Datei      */
          /* Deselektieren wie selektieren   */
          /* -----------------------------   */

          if   (!(fsd->last_selected) && (fsd->last_deselected))
               fsd->last_selected = fsd->last_deselected;

          if   ((nclicks > 1) && (fsd->last_selected))
               {
               if   ((fsd->last_selected->mode & S_IFMT)
                         == S_IFDIR)
                    {
                    goto_subdir(fsd, fsd->last_selected);
                    return(0);
                    }
               else return(FS_OK); /* Datei zurueckgeben */
               }
          return(0);
          }

     switch(exitbutton)
          {
       case FS_ICONBACK:

          if   (nclicks > 1)
               goto_root(fsd);
          else goto_parent(fsd);
          desel = TRUE;
          break;

       case FS_PATH:

          s = do_popup(tree, FS_PATH, fsd->paths, NULL, NULL);
          if   (s)
               {
               vstrcpy(fsd->path, s);
               update_path(fsd);
               update_dir(fsd);
               }
          tree[FS_PATH].ob_state &= ~SELECTED;
/*             fsel_draw(fsd, FS_PATH); */
          break;

       case FS_EXTENSION:

          if   (nclicks == 1)
               {
               s = do_popup(tree, FS_EXTENSION, fsd->patterns,
                              fslx_exts,
                         fsd->pattern);
               if   (s)
                    {
                    fsd->pattern = s;
                    update_pattern(fsd);
                    update_dir(fsd);
                    }
               }
          /* Doppelklick auf Extension: Extension editieren */
          else {
               if   (fsd->editob != FS_INPUT_EXT)
                    {
                    strncpy(fsd->input_ext, fsd->pattern,
                                   MAXEXTLEN);
                    fsd->input_ext[MAXEXTLEN] = '\0';
                    tree[FS_EXTENSION].ob_flags |= HIDETREE;
                    tree[FS_INPUT_EXT].ob_flags &= ~HIDETREE;
                    fsel_draw(fsd, FS_INPUT_EXT);
                    fsd->editob = FS_INPUT_EXT;
                    }
               }

          break;

       case FS_DRIVE:

          s = drivestrs;
          t = NULL;
          for  (line = 0,drives = Drvmap();
                    (line < 'Z'-'A'+1) && (drives);
                    line++,drives >>= 1L)
               {
               if   (drives & 1L)
                    {
                    *s = line + 'A';
                    if   (*s == fsd->path[0])
                         t = s;         /* akt. Laufwerk */
                    s++;
                    *s++ = ':';
                    *s++ = '\0';
                    }
               }
          *s = '\0';

          s = do_popup(tree, FS_DRIVE, drivestrs, NULL, t);

          if   (s)
               change_drive(fsd, *s);

          tree[FS_DRIVE].ob_state &= ~SELECTED;
          fsd->drv_dirty = TRUE;
          break;

       case OPTIONS:

          line = do_tree_popup( tree, exitbutton,
               fsd->sort_popup, fsd->sort_mode+SORT_NAME );
          if   (line > 0)
               {
               line -= SORT_NAME;
               if   (line != fsd->sort_mode)
                    {
                    fsd->sort_mode = line;
                    update_sort(fsd);
                    }
               }
          break;
/*
       case  FS_LEFT:

          fsd->hscroll--;
          if   (fsd->hscroll < 0)
               fsd->hscroll = 0;
          else {
               update_sort(fsd);
               }
          break;

       case FS_RIGHT:

          fsd->hscroll++;
          if   (fsd->hscroll > fsd->max_name+25-NAMLEN)
               fsd->hscroll = fsd->max_name+25-NAMLEN;
          else {
               update_sort(fsd);
               }
          break;
*/
       case FS_OK:

          return(exitbutton);

       case FS_CANCEL:

          return(exitbutton);

       case FS_SIZER:

          graf_rbox(
                    tree->ob_x, tree->ob_y,
                    fslx_dlm, tree->ob_height,
                    &newwidth, &dummy
                    );
          if   (tree->ob_width != newwidth)
               resize_fs_tree( fsd, newwidth );
          break;
          }

     if   (desel)
          {
          tree[exitbutton].ob_state &= ~SELECTED;
          fsel_draw(fsd, exitbutton);
          }
     return(0);
}


/***************************************************************
*
* Callback fuer Autolocator
* Wird nur fuer die Dialog-Version verwendet. Wird zweimal
* aufgerufen: Einmal vor und einmal nach dem evnt_multi().
*
****************************************************************/

struct xxdoinf
     {
     XDO_INF   xdoinf;
     FSEL_DIALOG *fsd;
     };

#pragma warn -par
static int autoloc_callback(WORD events, OBJECT *tree,
                         WORD *evt_data, struct xxdoinf *info,
                         WORD *cursorpos, WORD *editob)
{
     FSEL_DIALOG *fsd;


     fsd = info->fsd;
     fsd->editob = *editob;
     fsd->cursorpos = *cursorpos;

     /* Post-Callback: evt_data enthaelt die Event-Daten von evnt_multi */

     if   (evt_data)
          {
          if   (events & MU_KEYBD)
               {

               if   (do_key( fsd, evt_data[4], evt_data[3]))
                    events &= ~MU_KEYBD;
               }
          *editob = fsd->editob;
          *cursorpos = fsd->cursorpos;
          return(events);
          }

     /* Pre-Callback: evt_data ist NULL */

     if   (*editob == FPT_USER)
          do_autolocate(fsd);
     *editob = fsd->editob;
     *cursorpos = fsd->cursorpos;
     return(0);
}
#pragma warn .par


/***************************************************************
*
* RUeckgabewerte setzen
*
***************************************************************/

static void give_return(
               FSEL_DIALOG * fsd,
               WORD *button,
               char **pattern,
               WORD *sort_mode,
               char *fname,
               char *path,
               WORD *nfiles)
{
     *button = (fsd->button == FS_OK) ? 1 : 0;
     *nfiles = 0;        /* initialisieren */
     if   (*button)
          {
          if   (pattern)
               *pattern = ((FSEL_DIALOG *)fsd)->pattern;

          if   (sort_mode)
               *sort_mode = ((FSEL_DIALOG *)fsd)->sort_mode;
     
          vstrcpy(path, fsd->path);

          *nfiles = first_selfile( (FSEL_DIALOG *) fsd );
          if   (*nfiles)
               {
               vstrcpy(fname, fsd->next_selfile->name);
               next_selfile(fsd);
               *nfiles--;
               }
          else {
               if   (fsd->flags & DOSMODE)
                    ext_8_3(fname, fsd->fname);
               else vstrcpy(fname, fsd->fname);
               }
          }
}


/***************************************************************
*
* Hauptfunktion fslx_do()
* =======================
*
* Die Eingabeargumente muessen, wenn sie von fsel_(ex)input()
* kommen, noch gehoerig korrigiert werden (Normalisierung des
* Pfades, Dateimuster usw.).
*
* Eingabe:
*
*    title          Formulartitel, darf NULL sein.
*    path           Pfadpuffer (Ein- und Ausgabe)
*                   Pfad beginnt mit "X:\\" und endet mit "\\"
*    pathlen        Laenge des Pfadpuffers inkl. EOS
*    fname          Dateiname (Ein- und Ausgabe)
*    fnamelen       Laenge des Dateinamenspuffers inkl. EOS
*    patterns       Durch EOS getrennte, durch EOS/EOS
*                   abgeschlossene Liste von regul. Ausdruecken
*                   Eine "oder"-Verknuepfung wird durch ein ','
*                   angegeben, daher kann nicht nach einem ','
*                   gesucht werden.
*                   Die Liste muss (!) ein "*" enthalten.
*    filter         Funktion, die fuer Dateien 1 oder 0 liefert
*                   und regelt, ob die Datei in der Auswahlbox
*                   sichtbar sein soll oder nicht.
*    paths          Durch EOS getrennte, durch EOS/EOS
*                   abgeschlossene Liste von Pfaden.
*                   Darf NULL sein
*
* Ausgabe:
*
*    fname          ausgewaehlter Dateiname (wenn *button = 1)
*    path           ausgewaehlter Pfad (wenn *button = 1)
*    *button        Betaetigter Button (0 oder 1)
*    *sort_mode     Sortiermodus
*    *pattern       (Zeiger darf NULL sein) Gewaehltes Muster
*    *nfiles        Anzahl zusaetzlicher Dateien
*
* Rueckgabe:
*
*    Zeiger         OK
*    NULL           Fehler, zuwenig Speicher
*
****************************************************************/

void *fslx_do( char *title,
               char *path, WORD pathlen,
               char *fname, WORD fnamelen,
               char *patterns,
               WORD cdecl (*filter)(char *path, char *name, XATTR *xa),
               char *paths,
               WORD *sort_mode,
               WORD flags,
               WORD *button,
               WORD *nfiles,
               char **pattern)
{
     GRECT c;
     int exitbutton;
     void *flyinf;
     void **p_flyinf;
     FSEL_DIALOG *fsd;
     struct xxdoinf xxdoinf;
     OBJECT *tree;
     char pathbuf[258];


     /* Pfad: Defaults einsetzen */
     trim_path(path, pathbuf);
     vstrcpy(path, pathbuf);

     /* Sortiermodus: Defaults einsetzen */
     if   (!sort_mode)
          sort_mode = &fslx_sortmode;

     fsd = fsel_dialog_init(
                    path, pathlen,
                    fname, fnamelen,
                    patterns,
                    filter,
                    paths,
                    *sort_mode, flags,
                    FALSE );
     if   (!fsd)
          return(NULL);            /* Zuwenig Speicher */
     flyinf = NULL;
     p_flyinf = &flyinf;
     tree = fsd->tree;
     if   (title)
          tree[TITLE].ob_spec.free_string = title;
     tree[FS_SIZER].ob_flags |= HIDETREE;    /* kein SIZER */

     xxdoinf.xdoinf.unsh =
     xxdoinf.xdoinf.shift =
     xxdoinf.xdoinf.ctrl =
     xxdoinf.xdoinf.alt = NULL;
     xxdoinf.xdoinf.resvd = autoloc_callback;
     xxdoinf.fsd = fsd;

     _form_center_grect(tree, &c);

     wind_update(BEG_MCTRL);
     graf_mouse(ARROW, NULL);
/*   graf_mouse(M_ON, NULL);  */
     form_xdial(FMD_START, &c, &c, p_flyinf);
     objc_draw(tree, ROOT, MAX_DEPTH, &c);

     fsd->editob = 0;
     do_autolocate(fsd);
     do   {
          fsel_redraw( fsd );
          vstrcpy(fsd->old_fname, fsd->fname);
          exitbutton = form_xdo(tree, fsd->editob, &fsd->editob,
                    &xxdoinf.xdoinf, flyinf);

          fsd->cursorpos = -1;     /* Cursor ausgeschaltet */
          exitbutton = do_button(fsd, exitbutton & 0x7fff,
                         (exitbutton < 0) ? 2 : 1);
          }
     while(!exitbutton);

     form_xdial(FMD_FINISH, &c, &c, p_flyinf);
     wind_update(END_MCTRL);

/*   fsd->tree[exitbutton].ob_state &= ~SELECTED; */
     fsd->button = exitbutton;

     /* Rueckgabewerte */
     /* ------------- */

     give_return((FSEL_DIALOG *) fsd,
               button,
               pattern,
               sort_mode,
               fname,
               path,
               nfiles);
     return(fsd);
}


/***************************************************************
*
* Funktionen fuer Dateiauswahl im Fenster
* ======================================
*
****************************************************************/
#pragma warn -par
static WORD cdecl do_xfsl( DIALOG *dialog, EVNT *events, WORD obj,
                         WORD clicks, void *data )
{
     FSEL_DIALOG    *fsd;
     int oldeditob;


     if   ( obj < 0 )                        /* Nachricht? */
          {
          if   ( obj == HNDL_CLSD )          /* Dialog geschlossen? */
               {
               fsd = (FSEL_DIALOG *) wdlg_get_udata( dialog );
               fsd->button = FS_CANCEL;
               return( 0 );
               }
          }
     else
          {
          fsd = (FSEL_DIALOG *) data;

          wind_update(BEG_UPDATE);
          fsd->editob = oldeditob = wdlg_get_edit(dialog, &fsd->cursorpos);
          fsd->button = do_button(fsd, obj, clicks);
          if   (fsd->editob != oldeditob)
               wdlg_set_edit(dialog, fsd->editob);
          fsel_redraw( fsd );
          wind_update(END_UPDATE);
          return( !fsd->button );
          }

     return( 1 );   
}
#pragma warn .par

void * fslx_open(
               char *title,
               WORD x, WORD y,
               WORD *handle,
               char *path, WORD pathlen,
               char *fname, WORD fnamelen,
               char *patterns,
               WORD cdecl (*filter)(char *path, char *name, XATTR *xa),
               char *paths,
               WORD sort_mode,
               WORD flags)
{
     FSEL_DIALOG *fsd;
     char pathbuf[258];


     /* Pfad: Defaults einsetzen */
     trim_path(path, pathbuf);
     vstrcpy(path, pathbuf);

     /* Sortiermodus: Defaults einsetzen */
     if   (sort_mode < 0)
          sort_mode = fslx_sortmode;

     fsd = fsel_dialog_init(
                    path, pathlen,
                    fname, fnamelen,
                    patterns, filter,
                    paths,
                    sort_mode, flags,
                    TRUE );
     if   (fsd)
          {
          fsd->dialog = wdlg_create( do_xfsl, fsd->tree, fsd,
                         0, NULL, 0 );
          if   ( fsd->dialog )
               {
               *handle = wdlg_open( fsd->dialog, title,
                         NAME + MOVER + CLOSER, x, y, 0, NULL );

               if   ( *handle )
                    {
                    fsd->whdl = *handle;
               /*   set_edit_obj( fsd, 0 );  */
                    fsd->editob = 0;
                    do_autolocate(fsd);

                    return( fsd );
                    }
               }
          fsel_dialog_exit(fsd);
          fsd = NULL;
          }
     return(fsd);
}


WORD fslx_evnt(
               void *fsd,
               EVNT *events,
               char *path,
               char *fname,
               WORD *button,
               WORD *nfiles,
               WORD *sort_mode,    /* ist immer != NULL */
               char **pattern )    /* ist immer != NULL */
{
     WORD cont;
     WORD topw;
     WORD waskey = FALSE;


     if   (events->mwhich & MU_KEYBD)
          {
          topw = top_whdl();       /* Handle des obersten Fensters */
          if   (((FSEL_DIALOG *) fsd)->whdl == topw)
               {

               /* Tasten, die ich an wdlg_evnt() vorbeimogeln muss */
               /* ----------------------------------------------- */

               ((FSEL_DIALOG *) fsd)->editob = wdlg_get_edit(((FSEL_DIALOG *) fsd)->dialog,
                                                  &((FSEL_DIALOG *) fsd)->cursorpos);

               if   (do_key(fsd, events->key, events->kstate))
                    {
                    events->mwhich &= ~MU_KEYBD;
                    return(1);
                    }

               /* Tasten, die moeglichweise hinterher den    */
               /* Autolocator ausloesen koennen               */
               /* ----------------------------------------- */

               waskey = TRUE;
               vstrcpy(((FSEL_DIALOG *) fsd)->old_fname,
                    ((FSEL_DIALOG *) fsd)->fname);
               }
          }
     cont = wdlg_evnt( ((FSEL_DIALOG *) fsd)->dialog, events );

     if   (cont && waskey)
          do_autolocate(fsd);

     /* Rueckgabewerte */
     /* ------------- */

     give_return((FSEL_DIALOG *) fsd,
               button,
               pattern,
               sort_mode,
               fname,
               path,
               nfiles);

     if   (*button)
          fslx_sortmode = *sort_mode;
     return( cont );
}


WORD fslx_getnxtfile( void *fsd, char *fname )
{
     if   (((FSEL_DIALOG *)fsd)->next_selfile)
          {
          vstrcpy(fname, ((FSEL_DIALOG *)fsd)->next_selfile->name);
          next_selfile(((FSEL_DIALOG *)fsd));
          return(1);
          }
     return(0);
}


WORD fslx_close( void *fsd )
{
     if   (((FSEL_DIALOG *)fsd)->dialog)
          fslx_dlw = (((FSEL_DIALOG *)fsd)->tree)->ob_width;     /* letzte Groesse merken */
     fsel_dialog_exit((FSEL_DIALOG *) fsd);
     return(1);
}


/*
*
* Setzt globale Einstellungen
*
*/

WORD fslx_set( WORD subfn, WORD flags, WORD *oldval )
{
     if   (subfn)
          return(0);     /* Falsche Subfunktion */
     *oldval = fslx_flags;
     fslx_flags = flags;
     return(1);
}


WORD cdecl fsel_exinput(
               char *path,
               char *fname,
               int *button,
               char *title )
{
     void *fsd;
     char *pattern;
     char *s;
     char rett;
     char pathbuf[128];
     char patterns[32];
/*   char fnambuf[32];   */
     int dummy,flags;
     int longnames;


     s = fn_name(path);
     vstrcpy(patterns, s);
     rett = *s;
     *s = EOS;
     trim_path(path, pathbuf);
     *s = rett;

     if   (!strcmp(patterns, "*.*"))
          {
          patterns[1] = patterns[2] = EOS;
          }
     else {
          s = patterns+strlen(patterns);
          if   (s != patterns)
               s++;
          *s++ = '*';
          *s++ = EOS;
          *s++ = EOS;
          }


     longnames = ((act_pd->p_res2) & 1) || (act_appl->ap_id == 1);

     if   (longnames)
          {
          flags = 0;
/*        strncpy(fnambuf, fname, 31);  */
/*        fnambuf[31] = EOS;  */
          }
     else {
          flags = DOSMODE;
/*        nameto_8_3(fname, fnambuf);   */
          }

     fsd = fslx_do(
               title,
               pathbuf, 128,
               /*fnambuf*/ fname,
               (flags & DOSMODE) ? 13 : 32,
               patterns,
               0L,
               NULL,
               &fslx_sortmode,
               flags,
               button,
               &dummy,
               &pattern);
     if   (fsd)
          {
          if   (*button)
               {
               vstrcpy(path, pathbuf);
               if   ((pattern[0] == '*') && (!pattern[1]))
                    strcat(path, "*.*");
               else strcat(path, pattern);
/*             if   (longnames)
                    vstrcpy(fname, fnambuf);
               else nameto_8_3(fnambuf, fname);   */
               }
          fslx_close( fsd );
          return(1);
          }
     else return(0);
}
