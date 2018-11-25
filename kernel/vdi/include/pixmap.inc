                    OFFSET 0
R_top:              DS.W    1               ;   WORD    top;
R_left:             DS.W    1               ;   WORD    left;
R_bottom:           DS.W    1               ;   WORD    bottom;
R_right:            DS.W    1
sizeof_Rect:

/* MXVDI_PIXMAP/PixMap in Carbon */
                    OFFSET 0
PM_baseAddr:        DS.L    1               ;   BYTE            *baseAddr;
PM_rowBytes:        DS.W    1               ;   WORD            rowBytes;
PM_bounds:          DS.B    sizeof_Rect
PM_pmVersion:       DS.W    1               ;   WORD            pmVersion;
PM_packType:        DS.W    1               ;   WORD            packType;
PM_packSize:        DS.L    1               ;   LONG            packSize;
PM_Res:             DS.L    1               ;   Fixed           Res;
PM_vRes:            DS.L    1               ;   Fixed           vRes;
PM_pixelType:       DS.W    1               ;   WORD            pixelType;
PM_pixelSize:       DS.W    1               ;   WORD            pixelSize;
PM_cmpCount:        DS.W    1               ;   WORD            cmpCount;
PM_cmpSize:         DS.W    1               ;   WORD            cmpSize;
PM_planeBytes:      DS.L    1               ;   LONG            planeBytes;
PM_pmTable:         DS.L    1               ;   CTabHandle  pmTable;
PM_pmReserved:      DS.L    1               ;   LONG            pmReserved;
