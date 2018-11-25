BAT_MAGIC       EQU 'BAT_'

                OFFSET 0

                                ;typedef    struct NODE_tag
                                ;{
NODE_parent:    DS.L    1       ;   struct NODE_tag *parent;    /* Zeiger auf den Vater */
NODE_left:      DS.L    1       ;   struct NODE_tag *left;      /* Zeiger auf den linken (kleineren) Knoten */
NODE_right:     DS.L    1       ;   struct NODE_tag *right;     /* Zeiger auf den rechten (groesseren) Knoten */
                                ;}NODE;

                OFFSET 0

                                ;typedef struct
                                ;{
KPO_index1:     DS.W    1       ;   UWORD   index1;
KPO_index2:     DS.W    1       ;   UWORD   index2;
KPO_offset:     DS.W    1       ;   WORD    offset;
                                ;} KERN_PAIR_ORU;

                OFFSET

/* Kerning Cache Block */
                                ;typedef struct kcb
                                ;{
KCB_old:        DS.L    1       ;   struct kcb  *old;           /* Zeiger auf den vor diesem Block benutzten Block  */
KCB_young:      DS.L    1       ;   struct kcb  *young;         /* Zeiger auf den nach diesem Block benutzten Block */
KCB_font:       DS.L    1       ;   struct FONT_tag *font;
KCB_kern_pair:                  ;   KERN_PAIR_ORU   kern_pair[];
                                ;} KCB;

                OFFSET 0
                                ;typedef struct
                                ;{
WIDTH_width:    DS.W    1       ;   WORD            width;
WIDTH_xmin:     DS.W    1       ;   WORD            xmin;
WIDTH_xmax:     DS.W    1       ;   WORD            xmax;
                                ;} WIDTH;

                OFFSET 0
                                ;/* Width Cache Block */
                                ;typedef struct WCB_tag
                                ;{
WCB_old:        DS.L    1       ;   struct WCB_tag  *old;       /* Zeiger auf den vor diesem Block benutzten Block  */
WCB_young:      DS.L    1       ;   struct WCB_tag  *young;     /* Zeiger auf den nach diesem Block benutzten Block */

WCB_font:       DS.L    1       ;   struct FONT_tag *font;
WCB_width:                      ;   WIDTH           width[];
                                ;} WCB;


                OFFSET 0
/* Pair Kerning Block */
                                ;typedef struct
                                ;{
KP_index2:      DS.W    1       ;   UWORD   index2;
KP_offset:      DS.L    1       ;   LONG    offset;
                                ;} KERN_PAIR;

                OFFSET 0
                                    ;/* Bitmap Index Node   */
                                    ;typedef struct BIN_tag
                                    ;{
BIN_NODE:           DS.L    3       ;   NODE                node;

BIN_attributes:     DS.L    1       ;   struct BAT_tag  *attributes;

BIN_old:            DS.L    1       ;   struct BIN_tag  *old;   /* Zeiger auf den vor diesem Block benutzten Block  */
BIN_young:          DS.L    1       ;   struct BIN_tag  *young; /* Zeiger auf den nach diesem Block benutzten Block */
BIN_remove:         DS.L    1       ;   ULONG (*remove)( struct BIN_tag *blk ); /* Zeiger auf eine Aufraeumroutine */
    
BIN_index:          DS.W    1       ;   UWORD index;            /*  Zeichen-Index   */
    
BIN_x_adv:          DS.L    1       ;   LONG x_adv;             /* Breite in 1/65536 Pixeln */
BIN_y_adv:          DS.L    1       ;   LONG y_adv;
    
BIN_ox:             DS.L    1       ;   LONG ox;                /* Verschiebung der Bitmap nach rechts in 1/65536 Pixeln */
BIN_oy:             DS.L    1       ;   LONG oy;                /* Verschiebung der Bitmap nach unten in 1/65536 Pixeln */
BIN_dx:             DS.W    1       ;   UWORD dx;               /* Breite der Bitmap - 1 */
BIN_dy:             DS.W    1       ;   UWORD dy;               /* Hoehe der Bitmap - 1 */
BIN_line_width:     DS.W    1       ;   UWORD line_width;       /* Breite einer Bitmap-Zeile in Bytes   */
BIN_addr:           DS.L    1       ;   UWORD *addr;
BIN_mode:           DS.W    1       ;   WORD mode;
    
BIN_no_kern:        DS.W    1       ;   UWORD no_kern;
BIN_kern_pair:                      ;   KERN_PAIR kern_pair[];
                                    ;} BIN;
    
                    OFFSET 0
                                    ;/* Attribute Cache Table */
                                    ;typedef struct ACT_tag
                                    ;{
ACT_attributes:     DS.L    1       ;   struct BAT_tag  *attributes;
ACT_no_bin:         DS.W    1       ;   UWORD no_bin;
ACT_bin:            DS.L    1       ;   BIN *bin[];
                                    ;} ACT;

                    OFFSET 0
                                    ;/* Bitmap Attribute Table */
                                    ;typedef struct BAT_tag
                                    ;{
BAT_magic:          DS.L    1       ;   ULONG magic;
    
BAT_prev:           DS.L    1       ;   struct BAT_tag *prev;
BAT_next:           DS.L    1       ;   struct BAT_tag *next;
    
BAT_count:          DS.L    1       ;   LONG count;             /* Benutzungshaeufigkeit */

BAT_font:           DS.L    1       ;   struct FONT_tag *font;

BAT_width:          DS.L    1       ;   LONG width;             /* Breite in 1/65536 Pixeln */
BAT_height:         DS.L    1       ;   LONG height;            /* Hoehe in 1/65536 Pixeln */
BAT_rotation:       DS.W    1       ;   WORD rotation;          /* Drehung */
BAT_skew:           DS.W    1       ;   WORD skew;              /* Schraegstellung */
BAT_effects:        DS.W    1       ;   WORD effects;           /* Texteffekte */
    
BAT_bin_root:       DS.L    3       ;   NODE bin_root;          /* Wurzel fuer den Index-Baum */
BAT_bin_table:      DS.L    1       ;   ACT  *bin_table;        /* Zeiger auf eine Attribut-Cache-Tabelle oder 0L */
BAT_used:           DS.W    1       ;   WORD used;
                                    ;} BAT;

FONT_BITMAP EQU 0
FONT_SPEEDO EQU 1
FONT_TRUETYPE EQU 2
WIDTH_FILE EQU 0x01
MONOSPACE EQU 0x02

MONOSPACE_BIT   EQU 1

                    OFFSET 0
    
                                    ;typedef    struct FONT_tag
                                    ;{
FONT_next:          DS.L    1       ;   struct FONT_tag *next;
    
FONT_font_id:       DS.W    1       ;   UWORD   font_id;
FONT_font_name:     DS.B    32      ;   BYTE    font_name[32];
FONT_point_sizes:   DS.B    16      ;   BYTE    point_sizes[16];

FONT_orus:          DS.W    1       ;   WORD    orus;
FONT_metric_orus:   DS.W    1       ;   WORD    metric_orus;
FONT_fxmin:         DS.W    1       ;   WORD    fxmin;
FONT_fymin:         DS.W    1       ;   WORD    fymin;
FONT_fxmax:         DS.W    1       ;   WORD    fxmax;
FONT_fymax:         DS.W    1       ;   WORD    fymax;
FONT_thicken:       DS.W    1       ;   WORD    thicken;        /* Verbreiterung in ORUs bei Fettschrift */
FONT_ul_pos:        DS.W    1       ;   WORD    ul_pos;
FONT_ul_thick:      DS.W    1       ;   WORD    ul_thick;
FONT_skew:          DS.W    1       ;   WORD    skew;
FONT_skew_left:     DS.W    1       ;   WORD    skew_left;      /* linker Offset durch Kursivschrift in ORUs    */
FONT_skew_width:    DS.W    1       ;   WORD    skew_width;     /* Verbreiterung durch Kursivschrift in ORUs    */
FONT_mono_width:    DS.W    1       ;   WORD    mono_width;     /* Advance-Vektor fuer aequidistante Fonts in ORUs */

FONT_flags:         DS.W    1       ;   UWORD   flags;          /* u.a. monospace */
    
FONT_no_width:      DS.W    1       ;   UWORD   no_width;       /* Anzahl der Eintraege in width_table  */
FONT_no_kern:       DS.W    1       ;   UWORD   no_kern;        /* Anzahl der Eintraege in kern_table   */
FONT_no_track:      DS.W    1       ;   UWORD   no_track;       /* Anzahl der Eintraege in track_table  */
    
FONT_asc_map:       DS.L    1       ;   UWORD   *asc_map;
FONT_first_index:   DS.W    1       ;   UWORD   first_index;    
FONT_no_chars:      DS.W    1       ;   UWORD   no_chars;

FONT_width_table:   DS.L    1       ;   WCB *width_table;
FONT_kern_table:    DS.L    1       ;   KCB *kern_table;
    
FONT_font_vendor:   DS.L    1       ;   ULONG   font_vendor;    /* Fonthersteller */
FONT_font_format:   DS.W    1       ;   UWORD   font_format;
start_of_scaler:

                                    ;   union
                                    ;   {
                                    ;       struct
                                    ;       {
FONT_t_min_mem:     DS.L    1       ;           ULONG   min_mem;            /* Mindestgroesse des Speichers fuer den Scaler */
FONT_t_platform:    DS.W    1       ;           UWORD   platform;           /* platform */
FONT_t_id:          DS.W    1       ;           UWORD   id;                 /* platform specific id */
FONT_kern_offset:   DS.L    1       ;           ULONG   kern_offset;        /* Abstand der Kerning-Daten vom Dateianfang */
FONT_i_to_loca:     DS.W    1       ;           WORD    indexToLocFormat;   /* Format der loca-Tablle */
FONT_loca_offset:   DS.L    1       ;           ULONG   loca_offset;        /* Abstand der loca-Tabelle vom Dateianfang */
FONT_glyf_offset:   DS.L    1       ;           ULONG   glyf_offset;        /* Abstand der glyf-Tabelle vom Dateianfang */
sizeof_truetype:                    ;       }truetype;

                    OFFSET  start_of_scaler

                                    ;       struct
                                    ;       {
FONT_s_min_mem:     DS.L    1       ;           ULONG   min_mem;            /* Mindestgroesse des Speichers fuer den Scaler */
FONT_fbuf_size:     DS.L    1       ;           ULONG   fbuf_size;          /* Groesse des Buffers fuer den Fontheader */
FONT_cbuf_size:     DS.L    1       ;           ULONG   cbuf_size;          /* Groesse des Buffers fuer Zeichendaten */
FONT_pchar_dir:     DS.L    1       ;           ULONG   pchar_dir;          /* Abstand des Character-Directories vom Dateianfang */
FONT_dir_format:    DS.W    1       ;           UWORD   dir_format;         /* Format des Charater-Directories */
FONT_key32:         DS.W    1       ;           UWORD   key32;              /* Schluessel fuer ein 16-Bit-Wort */
FONT_key4:          DS.B    1       ;           UBYTE   key4;               /* Schluessl fuer das mittlere Byte eines 24-Bit-Wortes */
FONT_key6:          DS.B    1       ;           UBYTE   key6;               /* Schluessel fuer das niederwertigste Byte eines 24-Bit-Wortes */
sizeof_speedo:                      ;       }speedo;
                                    ;   }scaler;

                        IF sizeof_speedo > sizeof_truetype
                            OFFSET  sizeof_speedo
                        ELSE
                            OFFSET  sizeof_truetype
    
FONT_fif_name:      DS.B    16      ;   BYTE    fif_name[16];               /* Name des FIF */
FONT_fif_path:      DS.L    1       ;   BYTE    *fif_path;                  /* Pfad des FIF */
FONT_asc_preset:    DS.W    1       ;   WORD    asc_preset;                 /* gibt an, ob es sich um eine vorbesetzte ASCII-Map handelt */
FONT_wtab_offset:   DS.L    1       ;   LONG    wtab_offset;                /* Abstand der Weitentabelle vom Anfang des FIF */
FONT_ktab_offset:   DS.L    1       ;   LONG    ktab_offset;                /* Abstand der Kerningtabelle vom Anfang des FIF */
    
FONT_file_name:     DS.B    16      ;   BYTE    file_name[16];              /* Dateiname */
FONT_file_size:     DS.L    1       ;   ULONG   file_size;                  /* Dateilaenge */
FONT_file_time:     DS.L    1       ;   ULONG   file_time;                  /* Dateizeit */
FONT_file_path:     DS.L    1       ;   BYTE    *file_path;                 /* Pfad */

FONT_first_blk:     DS.W    13      ;   FCB first_blk;
FONT_last_blk:      DS.W    13      ;   FCB last_blk;
                                        
FONT_first_bat:     DS.L    1       ;   BAT *first_bat;
FONT_last_bat:      DS.L    1       ;   BAT *last_bat;
                                            
                                    ;} FONT;

                    OFFSET 0
                                    ;typedef struct
                                    ;{
SI_scaler:          DS.W    1       ;   WORD scaler;            /* gibt an, ob ein Speedo- oder TrueType-Font bearbeitet wird */
SI_scaler_mode:     DS.W    1       ;   WORD scaler_mode;       /* gibt an, welches Ausgabemodul benutzt werden soll */

SI_font:            DS.L    1       ;   FONT *font;             /* Zeiger auf die Font-Struktur */
SI_width:           DS.L    1       ;   LONG width;             /* Breite in 1/65536 Pixeln */
SI_height:          DS.L    1       ;   LONG height;            /* Hoehe in 1/65536 Pixeln */
SI_skew:            DS.W    1       ;   WORD skew;              /* Neigung in 1/10-Grad entgegen dem Uhrzeigersinn */
SI_rotation:        DS.W    1       ;   WORD rotation;          /* Rotation in 1/10-Grad entgegen dem Uhrzeigersinn */

SI_index:           DS.W    1       ;   WORD index;             /* Index des zu erzeugenden Zeichens */
SI_bitmap:          DS.L    1       ;   BIN *bitmap;            /* Zeiger auf die Bitmap-Info des zu erzeugenden Zeichens */
SI_ymin:            DS.W    1       ;   WORD ymin;              /* Startzeile der Bitmap    */
SI_dy:              DS.W    1       ;   WORD dy;                /* Hoehe der Bitmap in Zeilen - 1 */
SI_line_width:      DS.W    1       ;   UWORD line_width;       /* Breite einer Bitmap-Zeile in Bytes   */
SI_addr:            DS.L    1       ;   UWORD *addr;            /* Zeiger auf die Bitmap */

SI_sp_gbl_ptr:      DS.L    1       ;   SPEEDO_GLOBALS *sp_global_ptr;  /* Zeiger auf die Speedo-Scaler-Struktur */
SI_fptr:            DS.L    1       ;   ufix8 *fptr;            /* Zeiger auf den Speedo-Font-Buffer */
SI_fbuf:            DS.L    2       ;   buff_t fbuf;            /* Buffer-Struktur fuer den Font-Buffer */
SI_cptr:            DS.L    1       ;   UBYTE *cptr;            /* Zeiger auf den Speedo-Character-Buffer */
SI_cbuf:            DS.L    2       ;   buff_t cbuf;            /* Buffer-Struktur fuer den Character-Buffer */

ds.l 10
sizeof_SCALER_INFO:
                                    ;} SCALER_INFO;


