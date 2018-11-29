/*
 * define this if the screen drivers support the new setup api.
 * see comments in mxvdi.h, and keep this setting in sync.
 */
NEW_SETUP_API EQU 0

                IFNE NEW_SETUP_API

                OFFSET 0

                                ;typedef struct VDI_DISPLAY
                                ;{
VDISPLAY_magic:     DS.l    1   ;   int32           magic;      /* Strukturkennung 'vdim' */
VDISPLAY_length:    DS.l    1   ;   int32           length;     /* Strukturlaenge */
VDISPAY_format:     DS.l    1   ;   int32           format;     /* Strukturformat (0) */
VDISPAY_reserved:   DS.l    1   ;   int32           reserved;   /* reserviert (0) */
                                ;
VDISPLAY_next:      DS.l    1   ;   struct VDI_DISPLAY  *next;  /* Zeiger auf naechste Bildschirmbeschreibung */
VDISPLAY_id:        DS.l    1   ;   int32           display_id; /* Monitorkennung (erstmal nur von 0 aufsteigend zaehlend) */
VDISPLAY_flags:     DS.l    1   ;   int32           flags;      /* VDI_DISPLAY_ACTIVE */
VDISPLAY_rsvd1:     DS.l    1   ;   int32           reserved1;  /* reserviert (0) */
                                ;
VDISPLAY_hdpi:      DS.l    1   ;   fixed           hdpi;
VDISPLAY_vdpi:      DS.l    1   ;   fixed           vdpi;
VDISPLAY_rsvd2:     DS.l    1   ;   int32           reserved2;  /* reserviert (0) */
VDISPLAY_rsvd3:     DS.l    1   ;   int32           reserved3;  /* reserviert (0) */
                                ;
VDISPLAY_rsvd4:     DS.l    1   ;   int32           reserved4;  /* reserviert (0) */
VDISPLAY_rsvd5:     DS.l    1   ;   int32           reserved5;  /* reserviert (0) */
VDISPLAY_rsvd6:     DS.l    1   ;   int32           reserved6;  /* reserviert (0) */
VDISPLAY_rsvd7:     DS.l    1   ;   int32           reserved7;  /* reserviert (0) */
                                ;
VDISPLAY_bm:                    ;   GCBITMAP    bm;             /* Beschreibung des Grafikspeichers */
                    DS.l    4   ;   {   magic, length, format, reserved
                                ;
VDISPLAY_addr:      DS.l    1   ;       uint8           *addr;
VDISPLAY_width:     DS.l    1   ;       int32           width;
VDISPLAY_bits:      DS.l    1   ;       int32           bits;
VDISPLAY_px_fmt:    DS.l    1   ;       uint32      px_format;
                                ;
VDISPLAY_xmin:      DS.l    1   ;       int32           xmin;
VDISPLAY_ymin:      DS.l    1   ;       int32           ymin;
VDISPLAY_xmax:      DS.l    1   ;       int32           xmax;
VDISPLAY_ymax:      DS.l    1   ;       int32           ymax;
                                ;
VDISPLAY_ctab:      DS.l    1   ;       CTAB_REF        ctab;
VDISPLAY_itab:      DS.l    1   ;       ITAB_REF        itab;
VDISPLAY_cspace:    DS.l    1   ;       int32           color_space;
                    DS.l    1   ;
                                ;   } GCBITMAP;
                                ;} VDI_DISPLAY;
sizeof_VDI_DISPLAY:

                     
                    OFFSET 0

                                ;typedef struct
                                ;{
VSD_magic:          DS.l    1   ;   int32           magic;      /* Strukturkennung 'vdii' */
VSD_length:         DS.l    1   ;   int32           length;     /* Strukturlaenge */
VSD_format:         DS.l    1   ;   int32           format;     /* Strukturformat (0) */
VSD_reserved:       DS.l    1   ;   int32           reserved;   /* reserviert (0) */
                                ;
VSD_displays:       DS.l    1   ;   VDI_DISPLAY *displays;      /* Liste der angeschlossenen Monitore */
VSD_report_error:   DS.l    1   ;   VDI_SETUP_TROUBLE *report_error;
VSD_reserved1:      DS.l    1   ;   int32           reserved1;  /* reserviert (0) */
VSD_reserved2:      DS.l    1   ;   int32           reserved2;  /* reserviert (0) */
                                ;} VDI_SETUP_DATA;
sizeof_VDI_SETUP:

                    ENDC
