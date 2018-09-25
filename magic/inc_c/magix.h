/************************************************************************/
/*      MAGX.H      #defines for MAG!X Extensions                       */
/*              started 25/10/90 Andreas Kromke                         */
/*              last change 25/08/93 for Mag!X 2.00                     */
/*                                                                      */
/*     fÅr TURBO C                                                      */
/************************************************************************/

#if  !defined( __AES__ )
#define OBJECT void
#endif

/* ProgramHeader, Programmkopf fÅr ausfÅhrbare Dateien                  */
/************************************************************************/

typedef struct {
   int  ph_branch;        /* 0x00: always == 0x601a */
   long ph_tlen;          /* 0x02: length of TEXT segment */
   long ph_dlen;          /* 0x06: length of DATA segment */
   long ph_blen;          /* 0x0a: length of BSS segment */
   long ph_slen;          /* 0x0e: length of symbol table   */
   long ph_res1;          /* 0x12: unused, must be zero */
   long ph_res2;          /* 0x16: different flags */
   int  ph_flag;          /* 0x1a: if not zero, neither relocate nor clear BSS */
} PH;

#define PH_MAGIC	0x601a					/* value of PH.branch */
#define PHFLAG_DONT_CLEAR_HEAP	0x00000001	/* PH.flags */
#define PHFLAG_LOAD_TO_FASTRAM	0x00000002	/* PH.flags */
#define PHFLAG_MALLOC_FROM_FASTRAM	0x00000004	/* PH.flags */
#define PHFLAG_MINIMAL_RAM		0x00000008	/* PH.flags (MagiC 5.20) */
#define PHFLAG_MEMPROT			0x000000f0	/* PH.flags (MiNT) */
#define PHFLAG_SHARED_TEXT		0x00000800	/* PH.flags (MiNT) */
#define PHFLAG_TPA_SIZE			0xf0000000	/* PH.flags */


/* Kernel evnt_sem Modes (Mag!X 2.1) */

#define SEM_FREE    0
#define SEM_SET     1
#define SEM_TEST    2
#define SEM_CSET    3
#define SEM_GET     4
#define SEM_CREATE  5
#define SEM_DEL     6

typedef struct _appl {
     struct _appl *ap_next;   /* Verkettungszeiger                    */
     int       ap_id;         /* Application-Id                       */
     int       ap_parent;     /* ap_id der parent- Applikation        */
     OBJECT    *ap_menutree;  /* MenÅleiste                           */
     OBJECT    *ap_desktree;  /* Desktop- Hintergrundbaum             */
     int       ap_1stob;      /*  dazu erstes Objekt                  */
     char      ap_dummy1[2];  /* zwei Leerzeichen vor ap_name         */
     char      ap_name[8];    /* Applikationsname                     */
     char      ap_dummy2[2];  /* Leerstelle und ggf. Ausblendzeichen  */
     char      ap_dummy3;     /* Nullbyte fÅr EOS                     */
     char      ap_status;     /* 0=ready 1=waiting 2=outtime 3=zombie */
} APPL;

typedef struct {
     long xaesmagic;          /* Wert ist 'XAES'                      */
     APPL *act_appl;          /* aktive Applikation                   */
     int  ap_pd_offs;         /* Offset Basepage in APPL-Struktur     */
     int  appln;              /* Anzahl geladener Applikationen       */
     int  maxappln;           /* Anzahl ladbarer Applikationen        */
     APPL *applx[];           /* Applikationstabelle, LÑnge maxappln  */
} DOSMAGIC;

/* Mag!X- Dateideskriptor (ab V2.01) */

typedef struct {
     void *fd_link;           /* 0x00: Zeiger auf FDs im selben Verzeichn. */
     int  fd_dirch;           /* 0x04: Bit0: "dirty"                       */
     int  fd_time;            /* 0x06: Zeit  (8086)                        */
     int  fd_date;            /* 0x08: Datum (8086)                        */
     int  res1;               /* 0x0a: Start- Cluster (68000)              */
     long fd_len;             /* 0x0c: DateilÑnge in Bytes                 */
     void *fd_dmd;            /* 0x10: Zeiger auf DMD                      */
     void *fd_dirdd;          /* 0x14: Zeiger auf DD des zug. Directories  */
     void *fd_dirfd;          /* 0x18: Zeiger auf FD des zug. Directories  */
     long fd_dirpos;          /* 0x1c: Pos. des zug. Eintrags im Directory */
     long fd_fpos;            /* 0x20: Position des Dateizeigers           */
     void *fd_xdata;
     int  usr1;               /* 0x28:  Offset zum Clusteranfang oder dev  */
     int  fd_xftype;          /* 0x2a: (wie dir_xftype)                    */
     void *fd_multi;          /* 0x2c: Zeiger auf FD derselben Datei       */
     int  fd_mode;            /* 0x30: Open- Modus (0,1,2)                 */
} MAGX_FD;

/* Mag!X GerÑtetreiber (ab 2.01) */

#define DEV_M_INSTALL 0xcd00

typedef struct _m_u {
     void (*unsel_unsel) (struct _m_u *unsel);
     long param;
} MAGX_UNSEL;

typedef struct {
     void *act_pd;
     APPL *act_appl;
     APPL *keyb_app;
     void (*appl_yield)       ( void );
     void (*appl_suspend)     ( void );
     long (*evnt_IO)          ( long ticks_50hz, void *unsel );
     void (*evnt_mIO)         ( long ticks_50hz, void *unsel, int cnt );
     void (*evnt_emIO)        ( APPL *ap );
     long (*evnt_sem)         ( int mode, void *sem, long timeout );
     void (*appl_IOcomplete)  ( APPL *ap );
     void (*Pfree)            ( void *pd );
} MAGX_KERNEL;

/* os_magic -> */

typedef struct
     {
     /* Dies ist die Variable, auf die das Cookie und auch der   */
     /* osheader zeigen. Die ersten drei Variablen sind in jedem */
     /* TOS vorhanden.                                           */
     long magic;                   /* muû $87654321 sein         */
     void *membot;                 /* Ende der AES- Variablen    */
     void *aes_start;              /* Startadresse               */
     /* KAOS */
     long magic2;                  /* ist 'MAGX' oder 'KAOS'     */
     long date;                    /* Erstelldatum, $ddmmyyyy    */
     /* Mit <res> und <txt> kann man die Angaben in magx.inf     */
     /* Åberladen, <txt> ist die Fonthîhe fÅr den groûen AES-    */
     /* Font, und zwar in Pixeln. <txt> = 0 Åbernimmt den Wert   */
     /* aus magx.inf                                             */
     void (*chgres)(int res, int txt);  /* Auflîsung Ñndern      */
     /* Hier klinkt sich magxdesk.app ein.                       */
     long (**shel_vector)(void);   /* ROM- Desktop               */
     /* Dies ist das Bootlaufwerk, auf dem magx.inf liegt        */
     char *aes_bootdrv;            /* Hierhin kommt DESKTOP.INF  */
     int  *vdi_device;             /* vom AES benutzter Treiber  */
     void **nvdi_workstation;      /* vom AES benutzte Workst.   */
     /* Die folgenden beiden Variablen waren fÅr KAOSDESK, um    */
     /* festzustellen, ob das gestartete Programm seinerseits    */
     /* einen shel_write() gemacht hatte.                        */
     int  *shelw_doex;             /* letztes <doex> fÅr App #0  */
     int  *shelw_isgr;             /* letztes <isgr> fÅr App #0  */
     /* MAG!X */
     int  version;                 /* etwa $0200 fÅr V 2.0       */
     int  release;                 /* 0=‡ 1=· 2=‚ 3=release      */
     void *_basepage;              /* Basepage des AES           */
     /* Der ZÑhler zeigt, ob AES die Maus aus- oder eingeschal-  */
     /* tet hat. Bei einem Wert von 0 ist die Maus sichtbar      */
     int  *moff_cnt;               /* globaler MauszeigerzÑhler  */
     /* den folgenden Wert erhÑlt man auch mit shel_get(-1)      */
     long shel_buf_len;            /* LÑnge des Shell- Puffers   */
     void *shel_buf;               /* Zeiger auf Shell- Puffer   */
     /* Liste der wartenden Applikationen. Die suspend_list,     */
     /* die erst ab Mag!X 2.0 existiert, ist leider noch nicht   */
     /* von auûen zugÑnglich. Die suspend_list enthÑlt die       */
     /* Programme, die ihre Rechenzeit verbraucht haben.         */
     APPL **notready_list;         /* wartende Applikationen     */
     APPL **menu_app;              /* menÅbesitzende Applikation */
     OBJECT **menutree;            /* aktiver MenÅbaum           */
     OBJECT **desktree;            /* aktiver Desktophintergrund */
     int  *desktree_1stob;         /*  dessen erstes Objekt      */
     DOSMAGIC *dos_magic;          /* öbergabestruktur fÅrs DOS  */
     /* Zeiger auf folgende Struktur:                            */
     /*   int  maxwindn;      Anzahl mîglicher Fenster           */
     /*   int  topwhdl;       Handle des aktiven Fensters        */
     /*   int  whdlx[maxwindn];    Fensterliste, oben->unten     */
     /*        negative Handles gehîren eingefrorenen Apps.      */
     /*   WINDOWS *windx;     Zeiger auf die Fenstertabelle      */
     void *windowinfo;             /* versch. Fensterinfos       */
     /* Installationsvektor fÅr alternative Dateiauswahl,        */
     /* wird von Selectric verwendet. Kein TRAP nîtig!           */
     int  (**p_fsel)(char *pth, char *name, int *but, char *title);
     /* Umschaltung des prÑemptiven Multitaskings, Parameter:    */
     /*   d0.lo     Ticks fÅr Scheibe                            */
     /*   d0.hi     Hintergrund- PrioritÑt, z.B. 32 => 1:32      */
     /* d0 = -1L deaktiviert das prÑemptive Multitasking         */
     /* d0.lo <= -2 oder d0.hi <= -2 Ñndert den Wert nicht       */
     /* Der alte Wert wird zurÅckgegeben.                        */
     long (*ctrl_timeslice) (long settings);
     APPL **topwind_app;           /* App. des obersten Fensters */
     APPL **mouse_app;             /* menÅbesitzende Applikation */
     APPL **keyb_app;              /* tastaturbesitzende Appl.   */
     long dummy;
     } AESVARS;

/* Cookie MagX --> */

typedef struct
     {
     long    config_status;
     DOSVARS *dosvars;
     AESVARS *aesvars;
     } MAGX_COOKIE;

/* tail for default shell */

typedef struct
     {
     int  dummy;                   /* ein Nullwort               */
     long magic;                   /* 'SHEL', wenn ist Shell     */
     int  isfirst;                 /* erster Aufruf der Shell    */
     long lasterr;                 /* letzter Fehler             */
     int  wasgr;                   /* Programm war Grafikapp.    */
     } SHELTAIL;

/* shel_write modes (Parameter isover bzw. iscr) */

#define SHW_IMMED        0                                  /* PC-GEM 2.x  */
#define SHW_CHAIN        1                                  /* TOS         */
#define SHW_DOS          2                                  /* PC-GEM 2.x  */
#define SHW_PARALLEL     100                                /* MAG!X       */
#define SHW_SINGLE       101                                /* MAG!X       */

/* menu_bar modes */

#define MENU_HIDE        0                                  /* TOS         */
#define MENU_SHOW        1                                  /* TOS         */
#define MENU_INSTL       100                                /* MAG!X       */

/* objc_edit definition */

#define ED_CRSR          100                                /* MAG!X       */
#define ED_DRAW          103                                /* MAG!X 2.00  */

/* Event definition */

#define WM_UNTOPPED      30                                 /* GEM  2.x    */
#define SH_WDRAW         72                                 /* MultiTOS    */
#define SM_M_SPECIAL     101                                /* MAG!X       */
#define WM_BOTTOMED      33                                 /* AES 4.1     */
#define WM_ICONIFY       34                                 /* AES 4.1     */
#define WM_UNICONIFY     35                                 /* AES 4.1     */
#define WM_ALLICONIFY    36                                 /* AES 4.1     */

/* Screnmgr Function codes */

#define SMC_TIDY_UP      0                                  /* MAG!X       */
#define SMC_TERMINATE    1                                  /* MAG!X       */
#define SMC_SWITCH       2                                  /* MAG!X       */
#define SMC_FREEZE       3                                  /* MAG!X       */
#define SMC_UNFREEZE     4                                  /* MAG!X       */

/* AES wind_get()- Modes */

#define WF_M_OWNER       101                                /* Mag!X       */
#define WF_M_WINDLIST    102                                /* Mag!X       */

/* AES wind_set()- Mode */

#define WF_ICONIFY       26                                 /* AES 4.1     */
#define WF_UNICONIFY     27                                 /* AES 4.1     */
#define WF_UNICONIFYXYWH 28                                 /* AES 4.1     */
#define WF_M_BACKDROP    100                                /* KAOS 1.4    */

/* Window definition */

#define HOTCLOSEBOX      0x1000                             /* GEM 2.x     */
#define BACKDROP         0x2000                             /* KAOS 1.4    */
#define SMALLER          0x4000                             /* AES 4.1     */

/* Object types  */

#define G_SWBUTTON       34                                 /* MAG!X       */
#define G_POPUP          35                                 /* MAG!X       */

typedef struct {
     char *string;                 /* etwa "TOS|KAOS|MAG!X"                */
     int  num;                     /* Nr. der aktuellen Zeichenkette       */
     int  maxnum;                  /* maximal erlaubtes <num>              */
     } SWINFO;

typedef struct {
     OBJECT *tree;                 /* Popup- MenÅ                          */
     int  obnum;                   /* aktuelles Objekt von <tree>          */
     } POPINFO;

/* Object states */

#define WHITEBAK         0x40                               /* TOS         */
#define DRAW3D           0x80                               /* GEM 2.x     */

/* form_xdo definitions */

typedef struct {
     char scancode;
     char nclicks;
     int  objnr;
     } SCANX;

typedef struct {
     SCANX *unsh;
     SCANX *shift;
     SCANX *ctrl;
     SCANX *alt;
     int  (*filter)(int evtypes, OBJECT *tree, int *evnt_data);
     } XDO_INF;

/* AES function prototypes */

int  vq_aes         ( void );                               /* TOS         */
void appl_yield     ( void );                               /* GEM 2.x     */
void appl_bvset     ( int  disks,  int harddisks );         /* GEM 2.x     */
void shel_rdef      ( char *cmd, char *dir );               /* GEM 2.x     */
void shel_wdef      ( char *cmd, char *dir );               /* GEM 2.x     */
int  menu_unregister( int menu_id );                        /* GEM 2.x     */
int  scrp_clear     ( void );                               /* GEM 2.x     */
int  xgrf_stepcalc  (                                       /* GEM 2.x     */
                      int orgw, int orgh,
                      int xc, int yc, int w, int h,
                      int *cx, int *cy,
                      int *stepcnt, int *xstep, int *ystep
                    );
int  xgrf_2box      (                                       /* GEM 2.x     */
                      int xc, int yc, int w, int h,
                      int corners, int stepcnt,
                      int xstep, int ystep, int doubled
                    );
int  menu_click     ( int val, int setit );                 /* GEM 3.x     */
int  form_popup     ( OBJECT *tree, int x, int y );         /* MAG!X       */
int  form_xerr      ( long errcode, char *errfile );        /* MAG!X       */
int  form_xdo       (                                       /* MAG!X       */
                      OBJECT *tree, int startob,
                      int *lastcrsr, XDO_INF *tabs,
                      void *flydial
                    );
int  form_xdial     (                                       /* MAG!X       */
                      int flag,
                      int ltx, int lty, int ltw, int lth,
                      int bgx, int bgy, int bgw, int bgh,
                      void **flydial
                    );
int graf_xhandle    (                                       /* KAOS 1.4    */
                      int *wchar, int *hchar,
                      int *wbox, int *hbox, int *dev
                    );

int appl_getinfo    (                                       /* MTOS        */
                      int type,
                      int *out1, int *out2,
                      int *out3, int *gout4
                    );

/*
int rsrc_rcfix      (                                       /* MTOS        */
                    void *header
                    );
*/

int objc_sysvar     (                                       /* MTOS        */
                    int mode, int which,
                    int ival1, int ival2,
                    int *oval1, int *oval2
                    );
