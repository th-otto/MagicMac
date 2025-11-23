**********************************************************************
***************     DMA- und Floppy- Bootroutinen   ******************
**********************************************************************
**********************************************************************

; Werden nach MagicOnLinux weitergereicht

**********************************************************************
*
* void host_hdv_init( void )
*

host_hdv_init:
 move.w	#1,-(sp)
 lea		(sp),a1					; a1 = Parameter
 lea		MSysX+MacSysX_BlockDev(pc),a0	; PPC-Adresse
 MACPPC							; Mac anspringen
 addq.l	#2,sp
 rts


**********************************************************************
*
* long host_hdv_rwabs(int flag, void *buf, int count, int recno, int dev)
*

host_hdv_rwabs:
 move.w	#2,-(sp)
 lea		(sp),a1					; a1 = Parameter
 lea		MSysX+MacSysX_BlockDev(pc),a0	; PPC-Adresse
 MACPPC							; Mac anspringen
 addq.l	#2,sp
 rts


**********************************************************************
*
* long host_hdv_getbpb(int drv)
*
* Röckgabe NULL fÅr ungÅltigen BPB
*

host_hdv_getbpb:
 move.w   4(sp),d0                      ; d0 = drv
 mulu     #fbpb_sizeof,d0
 lea      bpbx,a0
 add.w    d0,a0                         ; a0 = &bpbx[drv]
 move.l   a0,-(sp)
 move.l   _dskbufp,-(sp)
 move.w	#3,-(sp)
 lea		(sp),a1					; a1 = Parameter
 lea		MSysX+MacSysX_BlockDev(pc),a0	; PPC-Adresse
 MACPPC							; Mac anspringen
 adda.w	#10,sp
 rts


**********************************************************************
*
* long host_hdv_mediach(int drive)
*
* RÅckgabe EUNDEV fÅr unbekanntes Laufwerk
*

host_hdv_mediach:
 move.w	#4,-(sp)
 lea		(sp),a1					; a1 = Parameter
 lea		MSysX+MacSysX_BlockDev(pc),a0	; PPC-Adresse
 MACPPC							; Mac anspringen
 addq.l	#2,sp
 rts


**********************************************************************
*
* long host_hdv_boot()
*
* RÅckgabewert wird derzeit ignoriert.
*

host_hdv_boot:
 move.w	#5,-(sp)
 lea		(sp),a1					; a1 = Parameter
 lea		MSysX+MacSysX_BlockDev(pc),a0	; PPC-Adresse
 MACPPC							; Mac anspringen
 addq.l	#2,sp
 rts
