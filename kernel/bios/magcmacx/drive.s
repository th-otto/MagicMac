**********************************************************************
***************     DMA- und Floppy- Bootroutinen   ******************
**********************************************************************
**********************************************************************

; Alle Dummy-Routinen

**********************************************************************
*
* void dummy_hdv_init( void )
*

dummy_hdv_init:
 rts


**********************************************************************
*
* long dummy_rwabs(int flag, void *buf, int count, int recno, int dev)
*

dummy_rwabs:
 moveq    #EUNDEV,d0
 rts


**********************************************************************
*
* long dummy_getbpb(int drv)
*

dummy_getbpb:
 moveq    #0,d0          ; NULL-Zeiger, d.h. BPB ist ungueltig
 rts


**********************************************************************
*
* long dummy_mediach(int drive)
*

dummy_mediach:
 moveq    #EUNDEV,d0
 rts


**********************************************************************
*
* long dummy_boot()
*

dummy_boot:
 moveq    #1,d0
 rts
