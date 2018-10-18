/* Menuemanager */
/* (Entspricht MultiTOS Feb. 1993) */

#include <portab.h>
#include <tos.h>
#include "std.h"
#define DEBUG8

#define   imax( i1, i2)  ((i1 > i2) ? i1 : i2)
#define   imin( i1, i2)  ((i1 < i2) ? i1 : i2)


#define SPECIAL_ACCMENU  0

#define NOOBJECT (-1)
#define NOWINDOW (-1)

typedef struct
{
     WORD g_x;
     WORD g_y;
     WORD g_w;
     WORD g_h;
} GRECT;


/* Object structures */

struct __parmblk;

#ifndef __STDC__
typedef struct
{
        int cdecl (*ub_code)(struct __parmblk *parmblock);
        long      ub_parm;
} USERBLK;
#endif

typedef struct
{
        char            *te_ptext;      /* ptr to text (must be 1st)    */
        char            *te_ptmplt;     /* ptr to template              */
        char            *te_pvalid;     /* ptr to validation            */
        int             te_font;        /* font                         */
        int             te_junk1;       /* junk int                     */
        int             te_just;        /* justification: left, right...*/
        int             te_color;       /* color information            */
        int             te_junk2;       /* junk int                     */
        int             te_thickness;   /* border thickness             */
        int             te_txtlen;      /* text string length           */
        int             te_tmplen;      /* template string length       */
} TEDINFO;


typedef struct
{
        int     *ib_pmask;
        int     *ib_pdata;
        char    *ib_ptext;
        int     ib_char;
        int     ib_xchar;
        int     ib_ychar;
        int     ib_xicon;
        int     ib_yicon;
        int     ib_wicon;
        int     ib_hicon;
        int     ib_xtext;
        int     ib_ytext;
        int     ib_wtext;
        int     ib_htext;
} ICONBLK;


typedef struct cicon_data {
    int    num_planes;            /* number of planes in the following data */
    int    *col_data;             /* pointer to color bitmap in standard form */
    int    *col_mask;             /* pointer to single plane mask of col_data */
    int    *sel_data;             /* pointer to color bitmap of selected icon */
    int    *sel_mask;             /* pointer to single plane mask of selected icon */
    struct cicon_data *next_res;  /* pointer to next icon for a different resolution */
} CICON;

typedef struct cicon_blk {
    ICONBLK monoblk;               /* default monochrome icon */
    CICON *mainlist;               /* list of color icons for different resolutions */
} CICONBLK;

typedef struct
{
        int     *bi_pdata;              /* ptr to bit forms data        */
        int     bi_wb;                  /* width of form in bytes       */
        int     bi_hl;                  /* height in lines              */
        int     bi_x;                   /* source x in bit form         */
        int     bi_y;                   /* source y in bit form         */
        int     bi_color;               /* foreground color             */
} BITBLK;

typedef struct
{
        unsigned character   :  8;
        signed   framesize   :  8;
        unsigned framecol    :  4;
        unsigned textcol     :  4;
        unsigned textmode    :  1;
        unsigned fillpattern :  3;
        unsigned interiorcol :  4;
} bfobspec;

typedef union obspecptr
{
        long     index;
        union obspecptr *indirect;
        bfobspec obspec;
        TEDINFO  *tedinfo;
        ICONBLK  *iconblk;
        CICONBLK *ciconblk;
        BITBLK   *bitblk;
#ifndef __STDC__
        USERBLK *userblk;
#endif
        char    *free_string;
} OBSPEC;

typedef struct
{
        int             ob_next;        /* -> object's next sibling     */
        int             ob_head;        /* -> head of object's children */
        int             ob_tail;        /* -> tail of object's children */
        unsigned int    ob_type;        /* object type: BOX, CHAR,...   */
        unsigned int    ob_flags;       /* object flags                 */
        unsigned int    ob_state;       /* state: SELECTED, OPEN, ...   */
        OBSPEC          ob_spec;        /* "out": -> anything else      */
        int             ob_x;           /* upper left corner of object  */
        int             ob_y;           /* upper left corner of object  */
        int             ob_width;       /* object width                 */
        int             ob_height;      /* object height                */
} OBJECT;

typedef struct __parmblk
{
        OBJECT  *pb_tree;
        int     pb_obj;
        int     pb_prevstate;
        int     pb_currstate;
        int     pb_x, pb_y, pb_w, pb_h;
        int     pb_xc, pb_yc, pb_wc, pb_hc;
        long    pb_parm;
} PARMBLK;

typedef struct
{
        OBJECT  *mn_tree;               /* Objektbaum */
        int     mn_menu;                /* Parent der Menü-Objekte */
        int     mn_item;                /* Startobjekt */
        int     mn_scroll;              /* Flag "scrolling" */
        int     mn_keystate;
} MENU;


typedef struct
{
        long   Display;
        long   Drag;
        long   Delay;
        long   Speed;
        int    Height;
} MN_SET;

#define MU_KEYBD        0x0001
#define MU_BUTTON       0x0002
#define MU_M1           0x0004
#define MU_M2           0x0008
#define MU_MESAG        0x0010
#define MU_TIMER        0x0020

#define END_UPDATE 0                    /* update flags */
#define BEG_UPDATE 1
#define END_MCTRL  2
#define BEG_MCTRL  3

#define G_BOX            20
#define G_TEXT           21
#define G_BOXTEXT        22
#define G_IMAGE          23
#define G_USERDEF        24
#define G_IBOX           25
#define G_BUTTON         26
#define G_BOXCHAR        27
#define G_STRING         28
#define G_FTEXT          29
#define G_FBOXTEXT       30
#define G_ICON           31
#define G_TITLE          32
#define G_CICON          33
#define G_SWBUTTON       34                                 /* MAG!X       */
#define G_POPUP          35                                 /* MAG!X       */
#define G_RESVD1         36                                 /* MagiC 3.1   */

/* Object flags */

#define NONE            0x0000
#define SELECTABLE      0x0001
#define DEFAULT         0x0002
#define EXIT            0x0004
#define EDITABLE        0x0008
#define RBUTTON         0x0010
#define LASTOB          0x0020
#define TOUCHEXIT       0x0040
#define HIDETREE        0x0080
#define INDIRECT        0x0100

#ifndef FL3DMASK
#define FL3DMASK     0x0600
#define FL3DNONE     0x0000
#define FL3DIND      0x0200   /* 3D Indicator                 AES 4.0      */
#define FL3DBAK      0x0400   /* 3D Background                AES 4.0      */
#define FL3DACT      0x0600   /* 3D Activator                 AES 4.0      */
#endif

/* Object states */

#define NORMAL          0x00
#define SELECTED        0x01
#define CROSSED         0x02
#define CHECKED         0x04
#define DISABLED        0x08
#define OUTLINED        0x10
#define SHADOWED        0x20
#define WHITEBAK         0x40                               /* TOS         */
#define DRAW3D           0x80                               /* GEM 2.x     */

#define ROOT             0
#define MAX_LEN         81              /* max string length */
#define MAX_DEPTH        8              /* max depth of search or draw */


#define IBM             3               /* font types */
#define SMALL           5


#define TE_LEFT         0               /* editable text justification */
#define TE_RIGHT        1
#define TE_CNTR         2

#define ED_START        0               /* editable text field definitions */
#define ED_INIT         1
#define ED_CHAR         2
#define ED_END          3
#define ED_CRSR          100                                /* MAG!X       */
#define ED_DRAW          103                                /* MAG!X 2.00  */


#if SPECIAL_ACCMENU
/* Baum für ACC/APP- Menü */
extern OBJECT *gem_acaptree;
/* Objektnummer des ersten Menüs, hier gem_acaptree einsetzen */
extern int B4650E;
#endif

typedef struct {
  int m_out;
  GRECT g;
} MOBLK2;

typedef struct
{
     WORD x;
     WORD y;
     WORD bstate;
     WORD kstate;
} EVNTDATA;

typedef struct
{
     EVNTDATA evd;
     WORD key;
     WORD nclicks;
} EVNT_MULTI_DATA;

struct domenuret {
     int title;
     int menu_obj;
     OBJECT *tree;
     int pmenu;
};

/*** durch mn_attach() erzeugte Beschreibung eines Popups ***/
typedef struct {
  /* 04 */  OBJECT *at_tree;   /* Objektbaum des Popups */
  /* 08 */  int at_root;       /* Wurzel des Popups */
  /* 0A */  int at_start;      /* Startobjekt des Popups */
  /* 0C */  int at_scroll;     /* TRUE, Popup kann gescrollt werden */
  /* 0E */  int at_count;      /* Anzahl der Aufrufe mit gleichem Popup */
} /* 10 */ attachS;

/*** Beschreibung eines Popups in Bearbeitung ***/
typedef struct _popupS {
  /* 02 */  OBJECT *pu_tree;
  /* 06 */  int pu_dflt_istart;
  /* 08 */  int pu_items;      /* Die Anzahl aller Menueeintraege */
  /* 0A */  GRECT pu_rect;     /* Ausmaße des Basisobjekts */
  /* 12 */  int pu_curr_istart;
  /* 14 */  int pu_root;       /* Objekt, das Menueeintraege enthält */
  /* 16 */  int pu_head;       /* Erster Menueeintrag in <imenu> */
  /* 18 */  int pu_tail;       /* Letzter Menueeintrag in <imenu> */
  /* 1A */  int pu_lastob;     /* != 0, falls <itail> LASTOB ist */

  /* 1C */  int pu_shead;               /* UP-Scrollelement */
  /* 1E */  int pu_shstate;
  /* 20 */  char pu_shtext[ 128];

  /* A0 */  int pu_stail;               /* DN-Scrollelement */
  /* A2 */  int pu_ststate;
  /* A4 */  char pu_sttext[ 128];

  /*124 */  void *pu_scrbuf;       /* geretteter Bildschirminhalt */
  /*128 */  struct _popupS *pu_parent;
  /*12C */  struct _popupS *pu_child;
  /*130 */  int pu_scroll;
} /*132 */ popupS;

/*** DATA ***/
static char smn_uptext[] = "  \x01";
static char smn_dntext[] = "  \x02";

/* importierte Funktionen aus dem Kernel */

extern WORD wind_update( WORD mode );
extern void obj_to_g( OBJECT *tree, WORD objnr, GRECT *g);
extern int objc_offset(OBJECT *tree, WORD objnr, WORD *x, WORD *y);
extern void _objc_draw(OBJECT *tree, WORD startob, WORD depth);
extern void set_clip_grect( GRECT *g );
extern WORD menu_modify( OBJECT *tree, WORD objnr, WORD statemask,
                    WORD active, WORD do_draw, WORD not_disabled);
extern WORD _objc_find( OBJECT *tree, WORD startob, WORD depth, LONG xy );
extern int objc_delete( OBJECT *tree, WORD objnr);
extern int objc_add( OBJECT *tree, WORD parent, WORD child);
extern WORD cdecl _evnt_multi(WORD mtypes, MOBLK2 *mm1, MOBLK2 *mm2, LONG ms,
                         LONG but, WORD mbuf[8], EVNT_MULTI_DATA *ev);
extern void _graf_mkstate( EVNTDATA *ev );
extern WORD appl_yield( void );
extern LONG smalloc( ULONG size);
extern void smfree( void *memblk );
extern WORD grects_intersect( const GRECT *srcg, GRECT *dstg);
extern WORD xy_in_grect( WORD x, WORD y, GRECT *g );
extern attachS *mn_at_get( OBJECT *ob, void *app );
extern void fast_save_scr( GRECT *g );
extern int scrg_sav( GRECT *g, void **pbuf);
extern void scrg_rst( void **pbuf );
extern void cdecl blitcopy_rectangle(int src_x, int src_y,
                          int dst_x, int dst_y, int w, int h);
extern WORD big_hchar,big_wchar;
extern MN_SET vmn_set;
extern GRECT desk_g,full_g;
extern popupS *pop_list;   /* Popup in Bearbeitung */

/* exportierte Funktionen */

int do_menu( struct domenuret *retval, void *menu_app );
int smn_popup( int xpos, int ypos,
                    MENU *mdesc,
                    MENU *resmdesc,
                    void *app,
                    OBJECT *smn_mgrttree, GRECT *smn_mgrmrect,
                    popupS *smn_mgrpopup);

/* lokale Funktionen */

static void smn_evobject( void *app, popupS *A5, int obj, int ignobj,
                         popupS *A12, int *A16, int *A1A, int *events,
                         int *A22, MOBLK2 *m1, MOBLK2 *m2, EVNT_MULTI_DATA *mkb,
                         OBJECT *smn_mgrttree, long *smn_timer, int desel);
static int smn_isupdn( popupS *popup, int iobj);
static int smn_doupdn( popupS *popup, int obj);
static void smn_dragmin( GRECT *A5, int mx, int my, GRECT *A4);
static int smn_obfind( EVNT_MULTI_DATA *A5, popupS *A4);
static int smn_ismstate( int W08, EVNT_MULTI_DATA *mkb);
#if SPECIAL_ACCMENU
static int smn_get_menu_obj( OBJECT *A08, int W0C, OBJECT **A0E);
#else
static int smn_get_menu_obj( OBJECT *titletree, int titleobj);
#endif
static void smn_obdraw( OBJECT *tree, int obj, GRECT *rect);
static void smn_rctoxy( GRECT *rect, int *xy);
static popupS *smn_punew( OBJECT *tree, int imenu, int istart);
static void smn_pudelete( popupS *popup );
static void smn_trset( popupS *popup);
static int smn_tritems( popupS *popup);
static void smn_trreset( popupS *popup);
static void smn_trxy( popupS *popup, int xpos, int ypos, GRECT *rect,
                    int alignx, int aligny);
static void smn_trudchange( popupS *popup, int obj);
static void smn_trudinsert( popupS *popup);
static void smn_truddelete( popupS *popup);
static int smn_isattach( void *app, OBJECT *itree, int iobj, popupS *x);
static popupS *smn_puopen( void *app, OBJECT *itree, int iobj);
static void smn_puclose( popupS *popup);
static int popup_depth( void);


#ifdef DEBUG
extern void putch( char c );
extern void hexl(long l);

void DEBUGSTR (char *s)
{
     while(*s)
          {
          putch(*s);
          s++;
          }
}
void DEBUGNUM (long n)
{
     putch(' ');
     if   (n < 0)
          {
          putch('-');
          n = -n;
          }
     if   (!n)
          {
          putch('0');
          return;
          }
     hexl(n);
}
#endif


/*****************************************************************
*
* Warte auf Loslassen der Mausknöpfe
*
*****************************************************************/

static void wait_until_mbuttons_released( void )
{
     EVNTDATA ev;

     do   {
          appl_yield();
          _graf_mkstate( &ev );
          }
     while(ev.bstate);
}


/*****************************************************************
*
* Ändert den Status des Objektes <obj> vom Baum <tree>.
* Ist <addit> TRUE, wird <newobstate> ge-OR-t, sonst entfernt.
* ist <drawit> TRUE, wird gezeichnet, wenn sich der Status
* geändert hat (per objc_change)
*
*****************************************************************/

static int smn_ichange( OBJECT *tree, int obj, int addit)
{
     return menu_modify( tree,          /* Menübaum */
                         obj,           /* Objektnummer */
                         SELECTED,      /* statemask */
                         addit,         /* active */
                         2,             /* immer (!!!) zeichnen */
                         TRUE);         /* DISABLE-te Objekte nicht */
}


/**********************************************************************
*
* Wenn <tree[obj]> gültig und nicht <ignobj> ist, wird das Objekt
* selektiert (addit == TRUE) bzw. deselektiert (addit == FALSE).
*
**********************************************************************/

static int smn_iselect( OBJECT *tree, int obj, int ignobj, int addit)
{
     if   ((obj != NOOBJECT) && (obj != ignobj))
          return( smn_ichange( tree, obj, addit ));
     return( FALSE);
}


/***********************************************************************
*
* Die eigentliche Popup-Behandlung.
* Wird nur von smn_popup und rekursiv aufgerufen.
*
* smn_mgrmrect:  Menuemanager: Rechteck der Menuezeile
*         Rückgabe -1,   wenn ungültiges Objekt angeklickt
*                        oder Maus in Menüzeile bewegt
*                        oder außerhalb des Menüs geklickt
*
***********************************************************************/

static int smn_dopopup( void *app, popupS *popup, popupS **popup_res,
                         OBJECT *smn_mgrttree, GRECT *smn_mgrmrect,
                         MENU *menu_result)
{
  /* 70 */  long butmask;
  /* 5C */  int W5C;
  /* 5A */  int W5A;
  /* 58 */  int events;
  /* 56 */  MOBLK2 m2;
  /* 4C */  MOBLK2 m1;
  /* 3E */  int which;
  /* 3C */  int quit;
  /* 3A */  int popres;       /* Objektnummer oder -1 oder -2 */
  /* 36 */  EVNT_MULTI_DATA mkb;
  /* 2E */  int openpop;    /* TRUE, mobj kann Submenue oeffnen */
  /* 2C */  int popisopen;  /* TRUE, Submenu wurde geoeffnet */
  /* 2A */  int popobj;     /* Objekt, dessen Submenue geoeffnet werden soll */
  /* 28 */  GRECT dragrect; /* Minimumrechteck zwichen Maus und Submenue */
                            /* wird laufend an die Mausposition angepasst */
  /* 18 */  GRECT parentrect;
  /* 10 */  popupS *popparent;
  /* 0C */  GRECT poprect;
  /* 04 */  int lastmobj; /* letztes Objekt */
  /* 02 */  int mobj;     /* Objekt unter dem Mauszeiger */
  /* 00 */
  /* A4 */  OBJECT *itree;
  /* A3 */  popupS *popchild;
     int smn_dragver;
     int smn_dragx;
     int smn_dragy;
     long smn_dragtime;
     long smn_timer;
     int smn_dragstoped;
     unsigned int smn_reqmstate;  /* erwarteter Maustastenstatus */


#ifdef DEBUG3
DEBUGSTR("enter smn_dopopup ");
#endif

     popres = -1;
     lastmobj = NOOBJECT;
     quit = FALSE;
     popobj = NOOBJECT;
     popchild = NULL;
     itree = popup->pu_tree;
     dragrect = popup->pu_rect;

     openpop = popisopen = FALSE;
     events = MU_M1|MU_BUTTON;

     _graf_mkstate( &mkb.evd );

     /* erwarteter Maustastenstatus:              */
     /* beim Menü Änderung der linken Maustaste   */
     /* sonst "linke Maustaste gedrückt"          */
     /* ----------------------------------------- */

     if   (smn_mgrttree)
          {
          smn_reqmstate = (mkb.evd.bstate & 1) ? 0x0 : 0x1;
          }
     else {
          smn_reqmstate = 0x1;
          }

     mobj = smn_obfind( &mkb, popup);
     smn_evobject( app, popup, mobj, lastmobj, popchild, &openpop,
                    &popisopen, &events, &popobj, &m1, &m2, &mkb,
                    smn_mgrttree, &smn_timer, FALSE);

     do   {

          menu_result->mn_keystate = 0;
          butmask = (long)(smn_reqmstate | 0x100) | 0x10000L;

          which = _evnt_multi( events, &m1, &m2, smn_timer, butmask, NULL, &mkb);

#ifdef DEBUG2
DEBUGSTR("lastmobj = mobj =");
DEBUGNUM(mobj);
#endif
          lastmobj = mobj;                   /* vorheriges Objekt */
          mobj = smn_obfind( &mkb, popup);   /* neues Objekt */

          /* Rootobjekt betreten oder Item verlassen */

          if   (!quit && (which & MU_M1))
               {
               if   (openpop)      /* kann Submenü öffnen */
                    {
                    openpop = popisopen = FALSE;
                    events = MU_M1|MU_BUTTON;
                    }
     
               if   (popisopen)    /* Submenue geöffnet, aber Maus noch außerhalb */
                    {
                    
                    if   (events != (MU_TIMER|MU_M2|MU_M1|MU_BUTTON))
                         {
                         events = (MU_TIMER|MU_M2|MU_M1|MU_BUTTON);
                         smn_timer = 150;
                         smn_dragtime = 0;
                         smn_dragmin( &dragrect, mkb.evd.x, mkb.evd.y, &poprect);
                         m2.m_out = 0;
                         m2.g = poprect;
                         m1.m_out = 1;
                         m1.g.g_x = mkb.evd.x - 1;
                         m1.g.g_y = mkb.evd.y - 1;
                         m1.g.g_w = m1.g.g_h = 2;
                         smn_dragstoped = FALSE;
                         smn_dragver = FALSE;
                         smn_dragx = mkb.evd.x;
                         smn_dragy = mkb.evd.y;
                         popobj = lastmobj;
                         if   (!xy_in_grect( mkb.evd.x, mkb.evd.y, &dragrect))
                              {
                              openpop = popisopen = FALSE;
                              events = MU_M1|MU_BUTTON;
                              lastmobj = popobj;
                              };
                         }
                    else {
                         if   (xy_in_grect( mkb.evd.x, mkb.evd.y, &dragrect))
                              {
                              smn_dragmin( &dragrect, mkb.evd.x, mkb.evd.y, &poprect);
                              m1.g.g_x = mkb.evd.x - 1;
                              m1.g.g_y = mkb.evd.y - 1;
                              }
                         else {
                              openpop = popisopen = FALSE;
                              events = MU_M1|MU_BUTTON;
                              lastmobj = popobj;
                              }
                         }
                    }

               if   (!popisopen)        /* kein Popup ist geöffnet */
                    {
                    if   (popchild)
                         {
                         smn_puclose( popchild);
                         popchild = NULL;
                         openpop = FALSE;
                         popisopen = FALSE;
                         }
                    smn_evobject( app, popup, mobj, lastmobj, popchild,
                              &openpop, &popisopen, &events, &popobj, &m1, &m2, &mkb,
                              smn_mgrttree, &smn_timer, TRUE);
                    if   ((which & MU_TIMER) && openpop)
                         which = 0;
                    if   ((which & MU_M2) && openpop)
                         which = 0;
                    }
               }    /* ENDIF (Rootobjekt betreten oder Item verlassen) */

          /* Subpopup betreten oder Maus bewegt, während Subpop offen */

          if   (!quit && (which & MU_M2))
               {

               if   (smn_ismstate( smn_reqmstate, &mkb))
                    goto _xyz;

               /* Subpopup betreten */
               if   (openpop || popisopen)
                    {
                    openpop = popisopen = FALSE;
                    events = MU_M1|MU_BUTTON;
                    if   ((popchild != NULL) && xy_in_grect( mkb.evd.x, mkb.evd.y,
                                                            &poprect))
                         {
                         popchild->pu_parent = popup;
#ifdef DEBUG2
DEBUGSTR("mobj =");
DEBUGNUM(mobj);
DEBUGSTR(" lastmobj =");
DEBUGNUM(lastmobj);
DEBUGSTR(" popobj =");
DEBUGNUM(popobj);
#endif
if   ((popobj > 0) && (popup->pu_tree[popobj]).ob_state & SELECTED)
     lastmobj = popobj;

                         /* Rekursion */

                         popres = smn_dopopup( app, popchild, popup_res,
                                             smn_mgrttree, smn_mgrmrect,
                                             menu_result);
                         if   ((popres == -1) || (popres != -2))
                              {
                              mobj = NOOBJECT;
                              quit = TRUE;
                              which = 0;
                              }
                         else {
                              _graf_mkstate( &mkb.evd );
                              mobj = smn_obfind( &mkb, popup);
                              }
                         if   (popchild != NULL)
                              {
                              smn_puclose( popchild);
                              popchild = NULL;
                              }
                         if   ((mobj == NOOBJECT) && !quit)
                              {
                              popparent = popup->pu_parent;
                              while(popparent != NULL)
                                   {
                                   parentrect = popparent->pu_rect;
                                   if   (xy_in_grect( mkb.evd.x, mkb.evd.y, &parentrect))
                                        {
                                        if   (popchild != NULL)
                                             {
                                             smn_puclose( popchild);
                                             popchild = NULL;
                                             }
                                        quit = TRUE;
                                        popres = -2;
                                        which = 0;
                                        break;
                                        }
                                   popparent = popparent->pu_parent;
                                   }
                              }
                         else if   ((mobj != NOOBJECT) && !quit)
                              {
#ifdef DEBUG2
DEBUGSTR("EVC ");
/* Manchmal ist <lastmobj> um 1 zu groß */
DEBUGNUM(lastmobj);
DEBUGNUM(mobj);
#endif
                              /* lastmobj deselekt., falls ungleich mobj */
                              smn_evobject( app, popup, mobj, lastmobj,
                                             popchild, &openpop,
                                             &popisopen, &events, &popobj,
                                             &m1, &m2, &mkb, smn_mgrttree,
                                             &smn_timer, TRUE);
                              }
                         }
                    }
      
     /* Maus bewegt */

               else {

_uvw:
                    if   ((smn_mgrttree) && xy_in_grect( mkb.evd.x,
                                                  mkb.evd.y, smn_mgrmrect))
                         {
                         W5A = _objc_find( smn_mgrttree, 2, 1,
                                             *((long *) &mkb.evd.x));
                         if   (W5A != NOOBJECT)
                              {
                              W5C = smn_mgrttree[ W5A].ob_state;
                              if   (W5C != 0)
                                   {
                                   events = (MU_M2|MU_M1|MU_BUTTON);
                                   m1.m_out = 0;
                                   obj_to_g( popup->pu_tree, popup->pu_root, &m1.g);
                                   m2.m_out = 1;
                                   obj_to_g( smn_mgrttree, W5A, &m2.g);
                                   continue;
                                   }
                              }
                         if   (popchild != NULL)
                              {
                              smn_puclose( popchild);
                              popchild = NULL;
                              }
                         openpop = FALSE;
                         popisopen = FALSE;
                         quit = TRUE;
                         popres = -1;
                         goto _finish;
                         }
                    if   (which != 0)
                         {
                         m2.g.g_x = mkb.evd.x - 1;
                         m2.g.g_y = mkb.evd.y - 1;
                         }
      
                    if   (smn_ismstate( smn_reqmstate, &mkb))
                         goto _xyz;
      
                    for  (popparent = popup->pu_parent; popparent != NULL;
                              popparent = popparent->pu_parent)
                         {

                         if   (smn_ismstate( smn_reqmstate, &mkb))
                              goto _xyz;

                         parentrect = popparent->pu_rect;
                         if   (xy_in_grect( mkb.evd.x, mkb.evd.y, &parentrect))
                              {
                              if   (popchild != NULL)
                                   {
                                   smn_puclose( popchild);
                                   popchild = NULL;
                                   }
                              quit = TRUE;
                              popres = -2;
                              which = 0;
                              events = (MU_M1|MU_BUTTON);
                              break;
                              }

                         }
                    }
               }
    
          if   (!quit && ((which & MU_BUTTON) || smn_ismstate( smn_reqmstate, &mkb)))
               {
               smn_reqmstate = 0x1;
_xyz:
               if   (openpop || popisopen)
                    {
                    if   (popisopen)
                         {
                         mobj = popobj;
                         }
                    openpop = popisopen = FALSE;
                    events = MU_M1|MU_BUTTON;
                    }

               if   (smn_isupdn( popup, mobj))
                    {
                    smn_doupdn( popup, mobj);
                    _graf_mkstate( &mkb.evd );
                    mobj = smn_obfind( &mkb, popup);
                    lastmobj = NOOBJECT;
                    smn_evobject( app, popup, mobj, lastmobj, popchild,
                                   &openpop, &popisopen, &events, &popobj,
                                   &m1, &m2, &mkb, smn_mgrttree,
                                   &smn_timer, FALSE);
                    if   (mobj == NOOBJECT)
                         {
                         which = 0;
                         goto _uvw;
                         }
                    }
               else {
                    if   (popchild != NULL)
                         {
                         smn_puclose( popchild);
                         popchild = NULL;
                         openpop = FALSE;
                         popisopen = FALSE;
                         }
                    menu_result->mn_tree = popup->pu_tree;
                    menu_result->mn_menu = popup->pu_root;
                    menu_result->mn_item = mobj;
                    menu_result->mn_scroll = popup->pu_scroll;
                    menu_result->mn_keystate = mkb.evd.kstate;
                    popres = (mobj == NOOBJECT) ? -1 : 0;
                    goto _finish;
                    }
               }

          if   (!quit && (which & MU_TIMER))
               {
               
               if   (openpop)
                    {
                    openpop = popisopen = FALSE;
                    events = MU_M1|MU_BUTTON;
                    if   (popobj == mobj)
                         {
                         if   ((popchild = smn_puopen( app, popup->pu_tree, mobj)) != NULL)
                              {
                              popisopen = TRUE;
                              poprect = popchild->pu_rect;
                              popobj = mobj;
                              events = (MU_M2|MU_M1|MU_BUTTON);
                              m2.m_out = 0;
                              m2.g = poprect;
                              }
                         }
                    else {
                         popobj = NOOBJECT;
                         }
                    }
               
               else if   (popisopen)
                    {
                    smn_dragtime += 150;
                    if   (smn_dragtime < vmn_set.Drag)
                         {
                         smn_dragstoped = (mkb.evd.x == smn_dragx) && (mkb.evd.y == smn_dragy);
                         smn_dragver = ((mkb.evd.x == smn_dragx) || 
                              ((smn_dragx - 4 <= mkb.evd.x) &&
                                             (smn_dragx + 4 >= mkb.evd.x))) && 
                              (mkb.evd.y != smn_dragy);
                         smn_dragx = mkb.evd.x;
                         smn_dragy = mkb.evd.y;
                         if   (!smn_dragstoped && !smn_dragver)
                              continue;
                         }
                    openpop = popisopen = FALSE;
                    events = MU_M1|MU_BUTTON;
                    lastmobj = popobj;
                    if   (popchild != NULL)
                         {
                         smn_puclose( popchild);
                         popchild = NULL;
                         openpop = FALSE;
                         popisopen = FALSE;
                         }
                    smn_evobject( app, popup, mobj, lastmobj, popchild,
                              &openpop, &popisopen, &events, &popobj,
                              &m1, &m2, &mkb,
                              smn_mgrttree, &smn_timer, TRUE);
                    }
               }
    
          }
     while(!quit);

_finish:
     if   ((mobj != NOOBJECT) && (popup->pu_root != mobj) && 
               (popres != -1) && (popres != -2))
          {
          if   (!(itree[ mobj].ob_state & DISABLED))
               {
               *popup_res = popup;
               popres = mobj;
               }
          else {
               popres = -1;
               }
          }
#ifdef DEBUG
DEBUGSTR(" smn_dopopup => ");
DEBUGNUM(popres);
DEBUGSTR("\r\n");
#endif

     return( popres);
} /* smn_dopopup */


/***************************************************************************
*
* Initialisiert die Events für die Bearbeitung eines Popup.
*
* Der Mauszeiger steht über <obj>, wobei <obj> auch NOOBJECT sein kann.
* Ist <desel> = TRUE, wird lastobj deselektiert, falls ungleich obj
*
* Wenn <obj> gültig ist, wird nur auf das Verlassen des Objekts
* gewartet, (MU_M1).
* Wenn dabei das Objekt auf ein Popup verweist und noch keines geöffnet
* ist oder werden soll (openpop == FALSE) wird:
*
*    openpop = TRUE
*    popisopen = FALSE
*    popobj = obj
*
* Wenn <obj> ungültig ist, wird in MU_M1 auf das Betreten des Wurzelobjekts
* gewartet.
* Bei einem Menü erster Ebene zusätzlich auf das Betreten der Menüzeile (MU_M2).
* Wenn das Popup einen parent hat und dieser parent nicht ein normales
* Menü ist, wird weiterhin auf eine minimale Mausbewegung gewartet (MU_M2).
*
***************************************************************************/

static void smn_evobject( void *app, popupS *popup, int obj, int ignobj,
                         popupS *popchild, int *openpop, int *popisopen,
                         int *events, int *popobj, MOBLK2 *m1, MOBLK2 *m2,
                         EVNT_MULTI_DATA *mkb, OBJECT *smn_mgrttree,
                         long *smn_timer, int desel)
{
     *events = MU_M1|MU_BUTTON;



     /* lastobj deselektieren, falls ungleich obj */
     /* ----------------------------------------- */

     if   (desel)
          smn_iselect( popup->pu_tree, ignobj, obj, FALSE);

     if   (obj != NOOBJECT)
          {

          /* Wenn <obj> ein Scrollpfeil ist */
          /* ------------------------------ */

          if   (smn_isupdn( popup, obj))
               {
               /* <obj> deselektieren, wenn obj != ignobj */
               smn_iselect( popup->pu_tree, obj, ignobj, FALSE);
               }

          /* sonst */
          /* ----- */

          else {
               smn_iselect( popup->pu_tree, obj, ignobj, TRUE);
               if   (!*openpop)
                    {
                    if   (smn_isattach( app, popup->pu_tree, obj, popchild))
                         {
                         *events = MU_TIMER|MU_M1|MU_BUTTON;
                         *smn_timer = vmn_set.Display;
                         *openpop = TRUE;
                         *popisopen = FALSE;
                         *popobj = obj;
                         }
                    }
               }

          m1->m_out = 1;      /* Event bei Verlassen des Rechtecks */
          }

     else {

          /* Unter-Popup: Warte auf minimale Mausbewegung */
          /* -------------------------------------------- */

          if   (popup->pu_parent)
               {
               m2->m_out = 1;      /* Event bei Verlassen */
               m2->g.g_x = mkb->evd.x - 1;
               m2->g.g_y = mkb->evd.y - 1;
               m2->g.g_w = m2->g.g_h = 2;
               *events = MU_M2|MU_M1|MU_BUTTON;
               }

          /* Menü erster Ebene: Warte auf Betreten der Menüzeile */
          /* --------------------------------------------------- */

          if   (smn_mgrttree)
               {
               if   (!popup->pu_parent)
                    {
                    m2->m_out= 0;  /* Event bei Betreten */
                    obj_to_g( smn_mgrttree, 2, &m2->g);
                    *events = MU_M2|MU_M1|MU_BUTTON;
                    }
               }

          m1->m_out = 0;      /* Event bei Betreten des Wurzelobjekts */
          obj = popup->pu_root;
          }

     obj_to_g( popup->pu_tree, obj, &m1->g);

} /* smn_evobject */


/*******************************************************************
*
* rettet/restauriert den Bildschirmhintergrund eines Popup- Menüs
*
* <restore> = 0: retten
* sonst          restaurieren
*
* RÜckgabe FALSE, wenn Fehler
*
*******************************************************************/

static int smn_savescr( popupS *popup, int restore)
{
     GRECT rect;

  
#ifdef DEBUG2
DEBUGSTR("enter smn_savescr ");
#endif

     /* Puffer anlegen */
     /* -------------- */

     if   (!restore)
          {

          /* GRECT berechnen */
          /* --------------- */

          rect = popup->pu_rect;                  /* Außenabmessungen */
          rect.g_x -= 1;
          rect.g_y -= 1;
          rect.g_w += 4;
          rect.g_h += 4;                     /* Schatten ???? */
          grects_intersect( &desk_g, &rect);      /* mit Bildschirm ohne Menü schneiden */
          if   (!scrg_sav(&rect, &popup->pu_scrbuf))
               return(FALSE);                /* zuwenig Speicher */
          }

     else {

          if   (!popup->pu_scrbuf)
               return( FALSE);
          scrg_rst(&popup->pu_scrbuf);
          }

/*   full_clip( );  */                            /* Clipping restaurieren */

#ifdef DEBUG2
DEBUGSTR("exit smn_savescr\r\n");
#endif

     return( TRUE);
} /* smn_savescr */


/*******************************************************************************
*
* Liefert TRUE, wenn <itree[item]> eines der beiden Menü-Scrollobjekte ist,
* d.h. mit Pfeil hoch oder Pfeil runter
*
*******************************************************************************/

static int smn_isupdn( popupS *popup, int item)
{
     OBJECT *ob;
     char *testtext = NULL;


     if   (item == NOOBJECT)
          return(FALSE);

     ob = popup->pu_tree + item;

     if   ((ob->ob_type & 0xFF) == G_STRING)
          {

          if   (item == popup->pu_shead)
               testtext = smn_uptext;
          else
          if   (item == popup->pu_stail)
               testtext = smn_dntext;

          if   ((testtext) && (!strcmp( ob->ob_spec.free_string, testtext)))
               return( TRUE);
          }
     return( FALSE);
}


/*
*
* Bearbeitet die Scrollpfeile eines scrollenden Menüs
*
*/

static int smn_doupdn( popupS *popup, int obj)
{
     long butmask;
     long timerhl;
     int events;
     MOBLK2 m1;
     int which;
     int quit;
     int delayit;
     int was_dnarrow;
     int was_uparrow;
     EVNT_MULTI_DATA mkb;
     GRECT source_g,dest_g;
     OBJECT *ob;
     int offs;
     int  smn_reqmstate = 0x0;          /* warte auf Loslassen der Maus */


     delayit = TRUE;
     quit = FALSE;
     m1.m_out = 1;       /* Warte auf Verlassen */
     obj_to_g( popup->pu_tree, obj, &m1.g);       /* angeklicktes Objekt */
     events = MU_TIMER|MU_M1|MU_BUTTON;

     do   {

          offs = 0;      /* kein Scrolling */

          /* Testen, ob die Pfeile da sind. Das kann man daran sehen, daß
             sich Anfang bzw. Ende verschieben */

          was_uparrow = (popup->pu_shead != popup->pu_head);
          was_dnarrow = (popup->pu_stail != popup->pu_tail);

          /* Scrollpfeil nach oben betätigt */
          if   (was_uparrow && (popup->pu_shead == obj))
               {
               popup->pu_curr_istart -= 1;
               offs = big_hchar;
               }
          /* Scrollpfeil nach unten betätigt */
          if   (was_dnarrow && (popup->pu_stail == obj))
               {
               popup->pu_curr_istart += 1;
               offs = -big_hchar;
               }

         if    (offs)
               {
               ob = popup->pu_tree + popup->pu_shead;  /* irgendein Objekt */
               source_g.g_w = ob->ob_width;            /* alle Breiten sind gleich */
               source_g.g_h = ob->ob_height;           /* Höhe einer Zeile */
               objc_offset( popup->pu_tree, popup->pu_root, &source_g.g_x, &source_g.g_y);
               source_g.g_y += source_g.g_h;           /* 1 Zeile frei */
               if   (offs < 0)
                    source_g.g_y += source_g.g_h;
               source_g.g_h *= (vmn_set.Height-3); /* * Anz. Zeilen */
               grects_intersect( &desk_g, &source_g);
               dest_g = source_g;

               dest_g.g_y += offs;

               grects_intersect( &desk_g, &dest_g);
               set_clip_grect( &desk_g );
               blitcopy_rectangle(
                              source_g.g_x, source_g.g_y,
                              dest_g.g_x, dest_g.g_y,
                              dest_g.g_w, dest_g.g_h
                              );

               smn_trudchange( popup, popup->pu_curr_istart);

               if   (offs > 0)
                    { /* UP, der Pfeil nach oben war also da! */
                    if   (!was_dnarrow && (popup->pu_stail != popup->pu_tail))
                         {    /* Pfeil nach unten ist dazugekommen */
                         obj_to_g( popup->pu_tree, popup->pu_stail, &source_g);
                         popup->pu_tree[ popup->pu_stail].ob_state = NORMAL;
                         smn_obdraw( popup->pu_tree, popup->pu_root, &source_g);
                         }
                    /* erster Menüeintrag */
                    obj_to_g( popup->pu_tree, popup->pu_shead, &source_g);
                    if   (popup->pu_shead == popup->pu_head)
                         {    /* ist kein Pfeil mehr */
                         source_g.g_h += big_hchar;
                         }
                    else {    /* ist noch Pfeil */
                         source_g.g_y += big_hchar;
                         }
                    }
               else { /* DN, der Pfeil nach unten war also da! */
                    if   (!was_uparrow && (popup->pu_shead != popup->pu_head))
                         {    /* Pfeil nach oben ist dazugekommen */
                         popup->pu_tree[ popup->pu_shead].ob_state = NORMAL;
                         obj_to_g( popup->pu_tree, popup->pu_shead, &source_g);
                         smn_obdraw( popup->pu_tree, popup->pu_root, &source_g);
                         }
                    /* letzter Menüeintrag */
                    obj_to_g( popup->pu_tree, popup->pu_stail, &source_g);
                    source_g.g_y -= big_hchar;
                    if   (popup->pu_stail == popup->pu_tail)
                         {    /* ist kein Pfeil mehr */
                         source_g.g_h += big_hchar;
                         }
                    }

               smn_obdraw( popup->pu_tree, popup->pu_root, &source_g);

               if   (!delayit)
                    timerhl = vmn_set.Speed;
               }

          /* !scroll */

         else  {
               events = (MU_M1|MU_BUTTON);
               timerhl = 0;
               }


          if   (delayit)
               {
               timerhl = vmn_set.Delay;
               delayit = FALSE;
               }

          butmask = (long)(smn_reqmstate | 0x100) | 0x10000L;

          which = _evnt_multi( events, &m1, NULL, timerhl,
                         butmask, NULL, &mkb);
          
          
          if   (which & MU_BUTTON)      /* Maustaste losgelassen */
               quit = TRUE;
     
          if   (which & MU_M1)          /* Objekt verlassen */
               {
               quit = TRUE;
               wait_until_mbuttons_released();
               }
          if   (which & MU_TIMER)
               {

               obj = _objc_find( popup->pu_tree, popup->pu_root,
                              1, *((long *) &mkb.evd.x));
               if   ((obj == ROOT) || (obj == popup->pu_root))
                    obj = NOOBJECT;

               }

          }
     while (!quit);

     return( 1);      
} /* smn_doupdn */


static void smn_dragmin( GRECT *A5, int mx, int my, GRECT *poprect)
{
  if (poprect->g_x >= mx) {
    A5->g_x = imin( mx, poprect->g_x);
    A5->g_w = poprect->g_x + poprect->g_w - 1 - A5->g_x + 1;
  }
  else {
    A5->g_x = poprect->g_x;
    A5->g_w = imax( mx - poprect->g_x, poprect->g_w) + 1;
  };
  if (poprect->g_y >= my) {
    A5->g_y = imin( my, poprect->g_y);
    A5->g_h = poprect->g_y + poprect->g_h - 1 - A5->g_y + 1;
  }
  else {
    A5->g_y = poprect->g_y;
    A5->g_h = imax( my - poprect->g_y, poprect->g_h) + 1;
  };
} /* smn_dragmin */


static int smn_obfind( EVNT_MULTI_DATA *mkb, popupS *popup)
{
  /* D7 */  int obj;
  
  obj = _objc_find( popup->pu_tree, popup->pu_root, 1, *((long *) &mkb->evd.x));
  if ((obj == ROOT) || (obj == popup->pu_root)) obj = NOOBJECT;
  return( obj);
} /* smn_obfind */


static int smn_ismstate( int reqmstate, EVNT_MULTI_DATA *mkb)
{
     _graf_mkstate( &mkb->evd );
  return( ((reqmstate == 0) && (mkb->evd.bstate == 0)) || 
          ((reqmstate != 0) && (mkb->evd.bstate != 0)));
} /* smn_ismstate */


/**********
*
* Mauszeiger retten+umschalten bzw. restaurieren
*
**********/

#if 0
static void smn_mouse( int saveit)
{
  if (saveit) {
    scr_gr_mouse( 0x102, NULL);
    scr_gr_mouse( ARROW, NULL);
  }
  else {
    scr_gr_mouse( 0x103, NULL);
  };
} /* smn_mouse */
#endif


void smn_moblk( OBJECT *tree, MOBLK2 *mob, int obj, int out)
{
     obj_to_g( tree, obj, &mob->g);
     mob->m_out = out;
}


/********************
*
* Entspricht "sav_rst_menu" in MagiC
* Für die Menüs. Benutzt den festen Bildschirmpuffer
*
********************/

static void smn_mnsave( OBJECT *tree, int obj)
{
     GRECT rect;

     obj_to_g( tree, obj, &rect);
     rect.g_x -= 1;
     rect.g_y -= 1;
     rect.g_w += 2;
     rect.g_h += 2;
/*   gh_setclip( &noclip_rect);    */
     fast_save_scr( &rect);
}

static void smn_mnrestore( void )
{
/*   gh_setclip( &noclip_rect);    */
     scrg_rst( (void **) (-1L));
}


/*
*
* Berechnet Parent (G_BOX) des Menüs mit Titelobjekt <W0C>
*
* Aufbau eines Menüs:
*
*    Objekt 0       IBOX      umfaßt Bildschirm und Menüleiste
*     Objekt 1      BOX       weiße Box, Menüleiste
*     Objekt 2      IBOX      Parent für alle Menütitel
*      Objekt 3...n TITLE     Menütitel
*     Objekt n+1    IBOX      Bildschirm ohne Menüleiste, Parent für Menüs
*
*/

#if SPECIAL_ACCMENU
static int smn_get_menu_obj( OBJECT *tree, int W0C, OBJECT **A0E)
{
  /* 0A */  int W0A;
  /* 08 */  OBJECT *A08;
  /* 04 */  int W04;
  /* 02 */  int W02;
  /* 00 */
  
  W02 = tree[ tree[ ROOT].ob_tail].ob_head;
  for (W04 = W0C - 2; W04 > 1; W04--) {
    W02 = tree[ W02].ob_next;           /* !##! */
  };
  A08 = tree;
  W0A = W02;

  if (W02 == B4650E) {
    A08 = gem_acaptree;
    W0A = 0;
  };

  *A0E = A08;
  return( W0A);
}
#else
static int smn_get_menu_obj( OBJECT *titletree, int titleobj )
{
     int menu_obj;
  
     menu_obj = titletree[ titletree[ ROOT].ob_tail].ob_head;    /* erstes Menü */
     for  (titleobj -= 3; titleobj > 0; titleobj--)
          menu_obj = titletree[menu_obj].ob_next;
     return(menu_obj);
}
#endif


/*
*
* Hintergrund in den festen Puffer retten und Menü zeichnen
*
* <title> ist die Objektnummer des Menütitels.
* Gibt die Objektnummer des Menüs zurück.
* 
*/

#if SPECIAL_ACCMENU
static int smn_draw_menu( OBJECT *titletree, int titleobj, OBJECT **menutree)
{
     int menu_obj;

     menu_obj = smn_get_menu_obj( titletree, int titleobj, menutree );
     if   (smn_ichange( titletree, title, TRUE ))
          {
          smn_mnsave( *menutree, menu_obj);
          mn_obdraw( *menutree, menu_obj, &full_g);
          }
     return( menu_obj );
}
#else
static int smn_draw_menu( OBJECT *titletree, int titleobj )
{
     int menu_obj;

     menu_obj = smn_get_menu_obj( titletree, titleobj );
     if   (smn_ichange( titletree, titleobj, TRUE ))
          {
          smn_mnsave( titletree, menu_obj);
          smn_obdraw( titletree, menu_obj, &full_g);
          }
     return( menu_obj );
}
#endif


/******************************************************************
*
* zeigt ein Menü
*
******************************************************************/

static void open_mainmenu( OBJECT *titletree, int title, int lasttitle,
                         OBJECT *menutree, popupS **popup, int *m2obj )
{
     popupS *p;

     if   (smn_iselect( titletree, title, lasttitle, TRUE))
          {
#if SPECIAL_ACCMENU
          *m2obj = smn_get_menu_obj( titletree, title, &menutree);
#else
          *m2obj = smn_get_menu_obj( titletree, title );
#endif
          p = *popup = smn_punew( menutree, *m2obj, 0);
          if   (p)
               {
               p->pu_rect.g_w = titletree[ p->pu_root].ob_width;
               p->pu_rect.g_h = titletree[ p->pu_root].ob_height;
               if   (menutree == titletree)
                    {
                    objc_offset( p->pu_tree, p->pu_root,
                              &p->pu_rect.g_x, &p->pu_rect.g_y);
                    }
               else {
                    p->pu_rect.g_x = menutree[ ROOT].ob_x;
                    p->pu_rect.g_y = menutree[ ROOT].ob_y;
                    }
#if SPECIAL_ACCMENU
               smn_draw_menu( titletree, title, &menutree);
#else
               smn_draw_menu( titletree, title );
#endif
               }
          }
}


/******************************************************************
*
* Hauptroutine: Anzeigen eines Menüs.
*
* retval->tree enthält bei Aufruf den Menübaum
*
* Rückgabe 0, wenn Menü abgebrochen, d.h. nichts angewählt,
* sonst != 0
*
* RÜckgabewerte:
*    retvals        int       titel
*    retvals+2      int       Menüeintrag
*    retvals+4      OBJECT *  Objektbaum (ggf. Submenü)
*    retvals+8      int       Parentobjekt des Menüs
*
* Aufbau eines Menüs:
*    Objekt 0       IBOX      umfaßt Bildschirm und Menüleiste
*    Objekt 1       BOX       weiße Box, Menüleiste
*    Objekt 2       IBOX      Parent für alle Menütitel
*    Objekt 3...n   TITLE     Menütitel
*    Objekt n+1     IBOX      Bildschirm ohne Menüleiste, Parent
*                             für Menüs
*
******************************************************************/

/*
static int smn_mgr( int *ptitle, OBJECT **ptree, int *pmenu, int *pitem,
          int *pkstate)
*/
int do_menu( struct domenuret *retval, void *menu_app )
{
     int obj;
     EVNT_MULTI_DATA mkb;
     MOBLK2 m2;
     MOBLK2 m1;
     int which;
     int events;
     int xtitle;
     int dobj;
     OBJECT *menutree;
     int popupdone;           /* TRUE, falls Popup-Eintrag ausgewählt */
     int res;                 /* Rückgabewert (1 = OK, 0 = nix gewählt) */
     int quit;
     int lasttitle;
     int m2obj;               /* Menuebox */
     int tstate;              /* Status des Titelobjekts */
     int title;
     int m1obj;
     int mode;
     OBJECT *titletree;
     MENU outmenu;
     MENU inmenu;
     popupS *popup;           /* heruntergefallenes Menü */
     GRECT smn_mgrmrect;      /* Menuemanager: Rechteck der Menuezeile */
     unsigned int smn_reqmstate;   /* erwarteter Maustastenstatus */


#ifdef DEBUG2
DEBUGSTR("enter smn_mgr ");
#endif

     mode = 1;
     popup = NULL;                      /* kein heruntergefallenes Menü */
     title = tstate = m2obj = NOOBJECT;
     xtitle = lasttitle = NOOBJECT;
     res = quit = FALSE;
     titletree = retval->tree;          /* aktuelles Menü */
     menutree = titletree;
     smn_reqmstate = 0x1;
#if 0
	wind_update(BEG_MCTRL);
#endif
#if 0
     smn_mouse( TRUE);                  /* Mauszeiger retten und ARROW */
#endif

     /* Objekt 2 ist Parent für alle Menütitel, dessen Ausmaße */
     /* werden in smn_mgrmrect gemerkt */

     obj_to_g( titletree, 2, &smn_mgrmrect);
     _graf_mkstate( &mkb.evd );

     /* xtitle = title = Objekt unter dem Mauszeiger */
     /* Dabei nur Kinder von Objekt 2 (d.h. Titel) absuchen */

     xtitle = title = _objc_find( titletree, 2, 1, *((long *) &mkb.evd.x));
     if   ((title != NOOBJECT) && !(titletree[title].ob_state & DISABLED))
          {

          /*** Alle noch selektierten Titelobjekte deselektieren ***/

          for  (obj = titletree[ 2].ob_head; obj != 2;
               obj = titletree[ obj].ob_next)
               {
               if   (titletree[ obj].ob_state & SELECTED)
                    smn_ichange( titletree, obj, FALSE );
               }

          tstate = titletree[ title].ob_state;

          /* Menütitel selektieren und Menü herunterklappen */
          /* ---------------------------------------------- */

          open_mainmenu( titletree, title, lasttitle, menutree, &popup, &m2obj );

          while(!quit)
               {

               /*** Ereignisanforderungen zusammenstellen ***/

               events = (MU_M1|MU_BUTTON);
               popupdone = FALSE;

               switch(mode)
                    {
                    case 0:
                    m1obj = 1;
                    if   (title != NOOBJECT)
                         {
                         if   (!(titletree[ title].ob_state & DISABLED))
                              {
                              events = (MU_M2|MU_M1|MU_BUTTON);
                              smn_moblk( menutree, &m2, m2obj, 0);
                              }
                         }
                    break;

                    /* Mauszeiger über Menütitel            */
                    /* warte auf 1. Verlassen des Titels    */
                    /*           2. Betreten des Menüs      */
                    /* ------------------------------------ */

                    case 1:
                    m1obj = xtitle;
                    if   (title != NOOBJECT)
                         {
                         if   (!(titletree[title].ob_state & DISABLED))
                              {
                              events = (MU_M2|MU_M1|MU_BUTTON);
                              /* Betreten des Menüs */
                              smn_moblk( menutree, &m2, m2obj, 0);
                              }
                         }
                    break;
                    }

               smn_moblk( menutree, &m1, m1obj, mode);
      
               /*   Ereignisse anfordern     */
               /* -------------------------- */

               which = _evnt_multi( events,
                              &m1,
                              &m2,
                              0L,
                              (0x10100L | smn_reqmstate),
                              NULL,
                              &mkb);

               /* Mausklick */
               /* --------- */

               if   (which & MU_BUTTON)
                    {

                    /* Bei der Suche nicht Gesamtobjekt und Menüleiste */
                    /* berücksichtigen */
                    dobj = _objc_find( titletree, 2, 1, *((long *) &mkb.evd.x));

                    /* Klick auf kein oder auf ungültiges Objekt */

                    if   ((dobj == NOOBJECT) ||
                         (dobj != NOOBJECT) && (titletree[ dobj].ob_state & DISABLED))
                         {
                         /* Tastaturstatus beim Auslösen des Menüs merken */
/*                       *pkstate = mkb.kstate;        */
                         quit = TRUE;
                         }
                    else {
                         /* ??? */
                         smn_reqmstate ^= 1;
                         continue;
                         };
                    };
        
               /* M2 eingetroffen, und Menü war offen */
               /* ----------------------------------- */

               if   (!quit && (which & MU_M2) && (popup))
                    {

                    /* heruntergefallenes Menü bearbeiten */
                    /* ---------------------------------- */

                    inmenu.mn_tree = menutree;
                    inmenu.mn_menu = m2obj;
                    inmenu.mn_item = 0;
                    inmenu.mn_scroll = FALSE;
                    popupdone = smn_popup( menutree[ m2obj].ob_x,
                                             menutree[ m2obj].ob_y, &inmenu, &outmenu,
                                             menu_app,
                                             titletree, &smn_mgrmrect, popup);

                    if   (popupdone)
                         {
                         _graf_mkstate( &mkb.evd );
                         dobj = _objc_find( titletree, 2, 1, *((long *) &mkb.evd.x));
                         if   ((dobj == NOOBJECT) ||
                               (dobj != NOOBJECT) && (titletree[dobj].ob_state & DISABLED))
                              {
                              quit = TRUE;
                              }
                         }
                    else {
                         /*
                         popupdone = FALSE;       ist schon FALSE
                         */
                         which = MU_M1;
                         _graf_mkstate( &mkb.evd );
                         }
                    }

               if   (!quit && (which & MU_M1))
                    {
        
                    /*** Titel und Modus neu bestimmen ***/
                    
                    lasttitle = title;
                    xtitle = title = _objc_find( titletree, 2, 1, *((long *) &mkb.evd.x));
                    tstate = (title != NOOBJECT) ? titletree[ title].ob_state : NORMAL;
                    if   ((title != NOOBJECT) && (tstate != DISABLED))
                         {
                         mode = 1;
                         }
                    else {
                         if   (title != NOOBJECT)
                              {
                              mode = 1;
                              }
                         else {
                              mode = 0;
                              };
                         title = lasttitle;
                         }

                    /*** Letztes Menue wieder einklappen ***/
                    if   (smn_iselect( titletree, lasttitle, title, FALSE) && (popup))
                         {
                         smn_mnrestore();
                         smn_pudelete( popup );
                         popup = NULL;
                         }
     
                    /*** Neues Menue aufklappen ***/

                    open_mainmenu( titletree, title, lasttitle, menutree, &popup, &m2obj );

                    } /* (which && MU_M1) */
     
               } /* while (!quit) */


          if   (title != NOOBJECT)
               {

               /*** Noch offenes Menu einklappen ***/

               if   (popup)
                    {
                    /* Bildschirm restaurieren */
                    smn_mnrestore();
                    smn_pudelete( popup );
                    popup = NULL;
                    }

               if   (popupdone && (outmenu.mn_item != NOOBJECT))
                    {
                    res = TRUE;
                    retval->title = title;             /* Objektnummer des Menütitels */
                    retval->tree = outmenu.mn_tree;    /* Baum des Menüs */
                    retval->pmenu = outmenu.mn_menu;   /* Wurzel des Menüs */
                    retval->menu_obj = outmenu.mn_item;     /* ausgewähltes Objekt */

#if SPECIAL_ACCMENU
                    if   (*ptree == gem_acaptree)
                         {
                         *ptree = gem_mn_tree();
                         *pmenu = titletree[ titletree[ ROOT].ob_tail].ob_head;
                         for  (obj = *ptitle - 2; obj > 1; obj--)
                              *pmenu = titletree[ *pmenu].ob_next;
                         }
#endif

                    }
               else smn_ichange( titletree, title, FALSE );      /* Titel deselektieren */

               /*
               *pkstate = outmenu.mn_keystate;
               */
               }
          }

/*   
     smn_mouse( FALSE);
*/
/*   wind_update(END_MCTRL);  */
#ifdef DEBUG2
DEBUGSTR("exit smn_mgr\r\n");
#endif
     return( res);
} /* smn_mgr */


/*********************************************************************
*
* menu_popup
*
* Allows an application to display a popup menu anywhere on the
* screen. The popup menu may also have submenus. If the number of
* menu items exceed the menu scroll height, the menu may also be set
* to scroll.  menu_settings can be used to set the height at which
* all menus will start to scroll.
*
* This call will also display a drop-down list anywhere on the screen.
* The drop-down list may NOT have submenus.  The height of the
* drop-down list is set to eight (8) menu items.  If the number of
* menu items is greater than eight, the menu will be set to scroll.
* If the menu has fewer than eight menu items, the menu will be
* displayed as a popup menu. Set the field 'mn_scroll' to negative
* one (-1) to display a drop-down list.
*
*    me_xpos - the left edge of where the starting menu item will be
*              displayed
*
*    me_ypos - the top edge of where the starting menu item will be
*              displayed
*
*    me_return - a coded return message
*    
*                 0 - FAILURE: The data returned by me_mdata is invalid
*                 1 - SUCCESS: The data returned by me_data is valid
*
*    FAILURE is returned if the user did not click on an enabled
*    menu item
*
*    me_menu  -     pointer to the pop-up MENU structure.  The
*                structure must be initialized with the object tree
*                of the pop-up menu, the menu object, the starting
*                menu item and the scroll field status.
*
*    me_mdata -     pointer to the data MENU structure.  If
*                menu_popup returns TRUE,  me_mdata will contain
*                information about the submenu that the user
*                selected.  This includes the object tree of the
*                submenu, the menu object, the menu item selected
*                and the scroll field status for this submenu.
*
************************************************************************/

int smn_popup( int xpos, int ypos,
               MENU *mdesc,
               MENU *resmdesc,
               void *app,
               OBJECT *smn_mgrttree, GRECT *smn_mgrmrect,
               popupS *smn_mgrpopup )
{
     int res;
     GRECT rect;
     int popres;
     popupS *popup;
     popupS *res_popup;

  
#ifdef DEBUG3
DEBUGSTR("enter smn_popup ");
#endif

     res = 0;
     popres = -1;

     /* kein Menü-Popup, sondern ein User-Popup */
     /* --------------------------------------- */

     if   (!smn_mgrttree)
          {
          wait_until_mbuttons_released();
          wind_update(BEG_MCTRL);

          if   ((popup = smn_punew( mdesc->mn_tree, mdesc->mn_menu,
                                   mdesc->mn_item)) != NULL)
               {
               popup->pu_scroll = mdesc->mn_scroll;
               if   (mdesc->mn_scroll)
                    smn_trset( popup);
               smn_trxy( popup, xpos, ypos, &rect, FALSE, TRUE);
               if   (smn_savescr( popup, FALSE))
                    {
                    smn_obdraw( mdesc->mn_tree, popup->pu_root, &desk_g);
                    popres = smn_dopopup( app, popup, &res_popup,
                                        NULL, NULL,
                                        resmdesc);
                    smn_savescr( popup, TRUE);
                    }
               else popres = -2;
               smn_pudelete( popup );
               }

          wait_until_mbuttons_released();
          wind_update(END_MCTRL);
          }

     /* Menü-Popup */
     /* ---------- */

     else {
          popres = smn_dopopup( app, smn_mgrpopup, &res_popup,
                              smn_mgrttree, smn_mgrmrect,
                              resmdesc);
          if   (popres == -1)
               res = 1;
          }


     /* Bei Fehler nur Nullen zurückgeben */
     /* --------------------------------- */

     if   (popres < 0)
          {
          resmdesc->mn_tree = NULL;
          resmdesc->mn_menu = NOOBJECT;
          resmdesc->mn_item = NOOBJECT;
          resmdesc->mn_scroll = 0;
          }
     else res = 1;

#ifdef DEBUG
DEBUGSTR(" smn_popup => ");
DEBUGNUM(res);
DEBUGSTR("\r\n");
#endif
     return( res);
} /* smn_popup */


static void smn_obdraw( OBJECT *tree, int obj, GRECT *rect)
{
  set_clip_grect( rect);
  _objc_draw( tree, obj, MAX_DEPTH);
} /* smn_obdraw */


static void smn_rctoxy( GRECT *rect, int *xy)
{
  *((GRECT *) xy) = *rect;    /* !##! (statt &xy) */
  xy[ 2] += rect->g_x - 1;
  xy[ 3] += rect->g_y - 1;
} /* smn_rctoxy */


/*
*
* Erzeugt ein neues popupS, hängt es in die verkettete
* Liste <smn_popuplist> ein und gibt eine neues popup
* zurück.
*
*/

static popupS *smn_punew( OBJECT *tree, int root, int istart)
{
     popupS *popup, *tpopup;


     popup = (void *) smalloc( sizeof(popupS));
     if   (!popup)
          return(NULL);
     tpopup = pop_list;
     if   (!tpopup)
          pop_list = popup;
     else {
          while(tpopup->pu_child)
               tpopup = tpopup->pu_child;
          tpopup->pu_child = popup;
          }
     popup->pu_child = NULL;       /* hinten in die Liste */

     popup->pu_tree = tree;
     popup->pu_root = root;
     popup->pu_head = tree[ root].ob_head;
     popup->pu_tail = tree[ root].ob_tail;
     popup->pu_lastob = tree[ tree[ root].ob_tail].ob_flags;
  
     popup->pu_rect = *((GRECT *)&tree[root].ob_x);
     istart = imin( istart, popup->pu_tail);
     popup->pu_dflt_istart = imax( popup->pu_head, istart);
     popup->pu_curr_istart = popup->pu_dflt_istart;
     popup->pu_items = smn_tritems( popup);  /* tail-head+1 */

     popup->pu_shead = popup->pu_head;       /* UP- Scrollelement */
     popup->pu_shstate = tree[ popup->pu_head].ob_state;
     popup->pu_shtext[ 0] = '\0';

     popup->pu_stail = popup->pu_tail;       /* DOWN- Scrollelement */
     popup->pu_ststate = tree[ popup->pu_tail].ob_state;
     popup->pu_sttext[ 0] = '\0';

     popup->pu_scrbuf = NULL;
     popup->pu_parent = NULL;
     popup->pu_scroll = FALSE;

     return( popup );
}


/*
*
* puid freigeben.
* d.h. popupS freigeben, ggf. pu_scrbuf freigeben
*
*/

static void smn_pudelete( popupS *popup )
{
     popupS *tpopup;



     smn_trreset( popup);

     if   (popup->pu_scrbuf)
          {
          smfree( popup->pu_scrbuf);
          popup->pu_scrbuf = NULL;
          }

     tpopup = pop_list;
     if   (popup == tpopup)
          {
          pop_list = tpopup->pu_child;
          smfree( tpopup);
          }
     else {
          while((tpopup != NULL) && (tpopup->pu_child != popup))
               tpopup = tpopup->pu_child;
          if   (popup == tpopup->pu_child)
               {
               tpopup->pu_child = popup->pu_child;
               smfree( popup);
               }
          }
}


static void smn_trset( popupS *popup)
{
     OBJECT *ob,*tree;
     int W06;
     int obj,shobj;
     int newshead;
     int root;
     int smn_vHeight;
     int *rootheight;


     ob = popup->pu_tree + popup->pu_root;
     popup->pu_items = smn_tritems( popup );
     popup->pu_rect.g_w = ob->ob_width;
     popup->pu_rect.g_h = ob->ob_height;
     if   (popup->pu_items > vmn_set.Height)
          {
          shobj = popup->pu_dflt_istart;
          smn_vHeight = vmn_set.Height;  
          tree = popup->pu_tree;
          root = popup->pu_root;
          rootheight = &(tree[ root].ob_height);
          newshead = shobj;

          newshead = (shobj - root +
                         ((popup->pu_items <= smn_vHeight) ? 0 : 1))
                                        / smn_vHeight + popup->pu_head;
          if   (popup->pu_head != newshead)
               {
               newshead = shobj - 1;
               W06 = popup->pu_items - smn_vHeight + popup->pu_head;
               if   (newshead >= W06)
                    newshead = W06;
               }

               /*** Alle Objekte vor den sichtbaren aushaengen ***/
               for  (obj = popup->pu_head; obj < newshead; obj++)
                    {
                    *rootheight -= tree[ obj].ob_height;
                    objc_delete( tree, obj);
                    }

               /*** Sichtbare Objekte neu im Menue positionieren ***/
               for  (obj = newshead; obj <= popup->pu_tail; obj++)
                    {
                    tree[ obj].ob_y = (obj - newshead) * tree[ obj].ob_height;
                    }

               /*** Alle Objekte hinter den sichtbaren aushaengen ***/
               for  (obj = popup->pu_tail; obj > newshead + smn_vHeight - 1; obj--)
                    {
                    *rootheight -= tree[ obj].ob_height;
                    objc_delete( tree, obj);
                    }

               popup->pu_shead = newshead;
               popup->pu_stail = imin( popup->pu_tail, newshead  + smn_vHeight - 1);
               if   (popup->pu_lastob)
                    tree[ popup->pu_stail].ob_flags = LASTOB;

               smn_trudinsert( popup); /* Pfeile einfuegen */

               popup->pu_curr_istart = newshead;
               popup->pu_rect.g_h = *rootheight;
               }
}


/*
*
* Liefert die Anzahl der Menueeintrage, die momentan ueber das
* Wurzelobjekt des Menues erreicht werden.
* D.h. einfach root.tail-root.head+1
*
*/

static int smn_tritems( popupS *popup)
{
  /* 02 */  int nrofitems;
  /* 00 */
  /* A4 */  OBJECT *itree;
  /* D7 */  int imenu;

  itree = popup->pu_tree;
  imenu = popup->pu_root;
  nrofitems = itree[ imenu].ob_tail - itree[ imenu].ob_head + 1;
  return( nrofitems);
} /* smn_tritems */


/*
*
* Entfernt Scrollobjekte aus dem Menue und stellt die urspruengliche
* Objektverkettung wieder her.
*
*/

static void smn_trreset( popupS *popup)
{
  /* 04 */  int visitems;
  /* 02 */  int imenu;
  /* 00 */
  /* A4 */  OBJECT *itree;
  /* D7 */  int obj;
     OBJECT *ob,*ob2;

  
     itree = popup->pu_tree;
     imenu = popup->pu_root;
     ob = itree+imenu;
     visitems = smn_tritems( popup);

     /*** Alle Eintraege im Menue verkettet ***/

     if   (popup->pu_items == visitems)
          {
          for  (obj = popup->pu_head; obj <= popup->pu_tail; obj++)
               itree[ obj].ob_state &= ~SELECTED;

          ob->ob_state &= ~SELECTED;
          }

     /*** Nicht alle Eintraege im Menue verkettet ***/

     else {
          smn_truddelete( popup);  /* Pfeile entfernen */

          /*** Alle sichtbaren Eintraege aushaengen ***/
          for  (obj = popup->pu_shead; obj <= popup->pu_stail; obj++)
               {
               objc_delete( itree, obj);
               ob->ob_height -= itree[ obj].ob_height;
               }

          /*** und wieder alle Eintraege einhaengen ***/

          for  (obj = popup->pu_head; obj <= popup->pu_tail; obj++)
               {
               objc_add( itree, imenu, obj);
               ob2 = itree+obj;
               ob2->ob_state &= ~SELECTED;
               ob->ob_height += big_hchar;
               ob2->ob_flags = NONE;
               ob2->ob_y = (obj - popup->pu_head) * itree[ popup->pu_head].ob_height;
               }

          if   (popup->pu_lastob)
               itree[ popup->pu_tail].ob_flags = LASTOB;
          popup->pu_rect.g_h = ob->ob_height;
          }
} /* smn_trreset */


static void smn_trxy( popupS *popup, int xpos, int ypos, GRECT *rect,
                    int alignx, int aligny)
{
  /* 04 */  int W04;
  /* 02 */  int W02;
  /* 00 */
     OBJECT *ob;

  
     ob = popup->pu_tree+popup->pu_root;

     if   (alignx)
          {
          if   (xpos + ob->ob_width - 1 >
                    desk_g.g_x + desk_g.g_w - big_wchar/2 - 1)
               xpos = rect->g_x - ob->ob_width;

          while(xpos < big_wchar)
               xpos += big_wchar;

          xpos = ((xpos + 7) / 8) << 3;
          }

     if   (aligny)
          {
          if   ((popup->pu_curr_istart > 0) &&
                (popup->pu_curr_istart != popup->pu_root))
               ypos -= popup->pu_tree[popup->pu_curr_istart].ob_y;

          while(ypos < desk_g.g_y)
               ypos += big_hchar;

          W02 = desk_g.g_y + desk_g.g_h - big_hchar/2 - 1;
          W04 = ypos + ob->ob_height - 1;
          while(W04 > W02)
               {
               ypos -= big_hchar;
               W04 = ypos + ob->ob_height - 1;
               }
          }

     popup->pu_rect.g_x = ob->ob_x = xpos;
     popup->pu_rect.g_y = ob->ob_y = ypos;
} /* smn_trxy */


/************************************************************************
*
* Erzeugt die Objekte eines Scrollmenues fur einen bestimmten Ausschnitt
*
************************************************************************/

static void smn_trudchange( popupS *popup, int W0C)
{
     int W04;
     register int i;
     int smn_vHeight;
     OBJECT *ob;


     smn_vHeight = vmn_set.Height;  
     W04 = W0C + smn_vHeight - 1;

     smn_truddelete( popup);       /* Scrollpfeile entfernen */

     /* sichtbaren Ausschnitt verschieben */

     if   (W0C < popup->pu_shead)
          {
          for  (i = W0C; i < popup->pu_shead; i++)
               objc_add( popup->pu_tree, popup->pu_root, i);
          for  (i = W04 + 1; i <= popup->pu_stail; i++)
               objc_delete( popup->pu_tree, i);
          }
     else {
          for  (i = popup->pu_shead; i < W0C; i++)
               objc_delete( popup->pu_tree, i);
          for  (i = popup->pu_stail + 1; i <= W04; i++)
               objc_add( popup->pu_tree, popup->pu_root, i);
          }
     popup->pu_shead = W0C;
     popup->pu_stail = W04;

     /* Objekte des jetzt sichtbaren Ausschnitts saeubern */

     for  (i = popup->pu_shead; i <= popup->pu_stail; i++)
          {
          ob = popup->pu_tree+i;
          ob->ob_state &= ~SELECTED;
          ob->ob_y = (i - popup->pu_shead) *
                              popup->pu_tree[ popup->pu_shead].ob_height;
          ob->ob_flags = NONE;
          }
     if   (popup->pu_lastob)
          popup->pu_tree[ popup->pu_stail].ob_flags = LASTOB;
     
     smn_trudinsert( popup);       /* Scrollpfeile wieder einfügen */
     popup->pu_curr_istart = W0C;
}


/**********************************************************************
*
* Setzt Pfeile anstelle der Texte in das erste und das letzte Objekt
* eines Scrollmenüs, wenn dies nötig ist.
*
**********************************************************************/

static void smn_trudinsert( popupS *popup)
{
     int item;
     OBJECT *ob;
     char *s;


     item = popup->pu_shead;
     ob = popup->pu_tree+item;
     popup->pu_shstate = ob->ob_state;
     if   (item != popup->pu_head)
          {
          ob->ob_state = NORMAL;
          /* Inhalt retten */
          s = ob->ob_spec.free_string;
          vstrcpy( popup->pu_shtext, s );
          /* Pfeil nach oben einsetzen */
          vstrcpy( s, smn_uptext );
          }

     item = popup->pu_stail;
     ob = popup->pu_tree+item;
     popup->pu_ststate = ob->ob_state;
     if   (item != popup->pu_tail)
          {
          ob->ob_state = NORMAL;
          if   (popup->pu_lastob)
               ob->ob_flags = LASTOB;
          /* Inhalt retten */
          s = ob->ob_spec.free_string;
          vstrcpy( popup->pu_sttext, s );
          /* Pfeil nach unten einsetzen */
          vstrcpy( s, smn_dntext );
          }
}


/***********************************************************************
* 
* Restauriert das erste und das letzte Objekt eines Scrollmenüs
*
***********************************************************************/

static void smn_truddelete( popupS *popup)
{
     int item;
     OBJECT *ob;

     item = popup->pu_shead;
     if   (item != popup->pu_head)
          {
          ob = popup->pu_tree+item;
          vstrcpy( ob->ob_spec.free_string, popup->pu_shtext );
          ob->ob_state = popup->pu_shstate;
          }

     item = popup->pu_stail;
     if   (item != popup->pu_tail)
          {
          ob = popup->pu_tree+item;
          ob->ob_flags = NONE;
          vstrcpy( ob->ob_spec.free_string, popup->pu_sttext );
          ob->ob_state = popup->pu_ststate;
          }
}


static int smn_isattach( void *app, OBJECT *itree, int iobj, popupS *A10)
{
     if   (A10)
          return(FALSE);                /* ??? */
     if   (itree[ iobj].ob_state & DISABLED)
          return(FALSE);                /* Objekt DISABLED */
     if   (!popup_depth)
          return(FALSE);                /* Popup-Verschachtelung zu tief */
     return(NULL != mn_at_get(itree+iobj, app));
} /* smn_isattach */


static popupS *smn_puopen( void *app, OBJECT *itree, int item)
{
     int x,y;
     GRECT rect;
     attachS *pat;
     popupS *popup = NULL;


#ifdef DEBUG3
DEBUGSTR("enter smn_puopen ");
#endif

     if   ((item != NOOBJECT) && ((itree[ item].ob_type & 0xFF) == G_STRING))
          {
          pat = mn_at_get( itree+item, app);
          if   (pat)
               {
               obj_to_g( itree, item, &rect);
               x = ((rect.g_x + rect.g_w - 1 - big_wchar + 7) / 8) << 3;
               y = rect.g_y;

               if   ((popup = smn_punew( pat->at_tree, pat->at_root, pat->at_start)) != NULL)
                    {
                    itree = popup->pu_tree;       /* == pat->at_tree */
                    itree[ popup->pu_root].ob_x = x;
                    itree[ popup->pu_root].ob_y = y;
                    popup->pu_scroll = pat->at_scroll;
                    if   (pat->at_scroll)
                         smn_trset( popup);
                    smn_trxy( popup, x, y, &rect, TRUE, TRUE);
                    if   (!smn_savescr( popup, FALSE))
                         {
                         smn_pudelete( popup );
                         popup = NULL;
                         }
                    else smn_obdraw( itree, popup->pu_root, &desk_g);
                    }

               }
          }

#ifdef DEBUG3
DEBUGSTR("exit smn_puopen ");
#endif

     return( popup);
}



static void smn_puclose( popupS *popup)
{
#ifdef DEBUG3
DEBUGSTR("smn_puclose ");
#endif

     if   (popup)
          {
          smn_savescr( popup, TRUE);
          smn_pudelete( popup );
          }
}


static int popup_depth( void)
{
  /* 06 */  popupS *popup;
  /* 02 */  int depth;
  /* 00 */

  depth = 0;
  for (popup = pop_list; popup != NULL; popup = popup->pu_child) {
    depth++;
  };
  return( depth < 4);
}
