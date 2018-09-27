* Bibliotheksmodul fÅr MAGIX.LIB


     INCLUDE   "MAGILIB.INC"

        XREF   __aes


        XDEF   appl_yield               ; GEM 2.x
        XDEF   vq_aes
        XDEF   appl_getinfo
        XDEF   objc_sysvar
        XDEF   rsrc_rcfix



**********************************************************************
*
* int appl_yield (void )
*

appl_yield:
 move.l   #$11000100,d0
 bra      __aes


*********************************************************************
*
* int vq_aes ( void )
*

vq_aes:
 move.w   #$c9,d0
 trap     #2
 cmpi.w   #$c9,d0
 sne      d0
 ext.w    d0
 rts


**********************************************************************
*
* int appl_getinfo( int type, int *c1, int *c2, int *c3, int *c4 )
*

appl_getinfo:
 move.l   a1,-(sp)                 ; &c2
 move.l   a0,-(sp)                 ; &c1
 move.w   d0,_GemParB+INTIN        ; type
 move.l   #$82010500,d0
 bsr      __aes
 movea.l  (sp)+,a1
 move.w   (a0)+,(a1)               ; *c1 = intout[1]
 movea.l  (sp)+,a1
 move.w   (a0)+,(a1)               ; *c2 = intout[2]
 movea.l  4(sp),a1
 move.w   (a0)+,(a1)               ; *c3 = intout[3]
 movea.l  8(sp),a1
 move.w   (a0),(a1)                ; *c4 = intout[4]
 rts


**********************************************************************
*
* int objc_sysvar( d0 = int mode, d1 = int which, d2 = int i1, int i2,
*                  a0 = int *o1, a1 = int *o2 )
*

objc_sysvar:
 move.l   a1,-(sp)                 ; &c2
 move.l   a0,-(sp)                 ; &c1
 lea      _GemParB+INTIN,a0
 move.w   d0,(a0)+                 ; mode
 move.w   d1,(a0)+                 ; which
 move.w   d2,(a0)+                 ; i1
 move.w   4(sp),(a0)               ; i2
 move.l   #$30040300,d0
 bsr      __aes
 movea.l  (sp)+,a1
 move.w   (a0)+,(a1)               ; *c1 = intout[1]
 movea.l  (sp)+,a1
 move.w   (a0),(a1)                ; *c2 = intout[2]
 rts


**********************************************************************
*
* int rsrc_rcfix( a0 = void *header )
*

rsrc_rcfix:
 move.l   a0,_GemParB+ADDRIN
 move.l   #$73000101,d0
 bra      __aes

        END

