/*
*
* Assemblerteil von VFAT.C
*
*/

XDEF      p_fread
XDEF      p_fwrite
XDEF      p_fseek
XDEF      vf_d2i
XDEF      p_extfd
XDEF      vf_chksum

     INCLUDE "errno.inc"
     INCLUDE "kernel.inc"
     INCLUDE "structs.inc"

**********************************************************************
*
* long p_fread(a0 = FD *file, d0 = long count, a1 = char *buffer)
*  Ist <buffer> == NULL, bekommt man einen Zeiger auf die
*  gelesenen Bytes.
*

p_fread:
 move.l   a2,-(sp)
 move.l   fd_dev(a0),a2
 move.l   dev_read(a2),a2
 jsr      (a2)
 move.l   (sp)+,a2
 rts


**********************************************************************
*
* long p_fwrite(a0 = FD *file, d0 = long count, a1 = char *data)
*

p_fwrite:
 move.l   a2,-(sp)
 move.l   fd_dev(a0),a2
 move.l   dev_write(a2),a2
 jsr      (a2)
 move.l   (sp)+,a2
 rts


**********************************************************************
*
* long p_fseek( a0 = FD *file, d0 = long offs)
*

p_fseek:
 move.l   a2,-(sp)
 move.l   fd_dev(a0),a2
 move.l   dev_seek(a2),a2
 moveq    #0,d1               ; immer absolut
;move.l   d0,d0
;move.l   a0,a0
 jsr      (a2)
 move.l   (sp)+,a2
 rts


**********************************************************************
*
* void vf_d2i( FD *file, DIR *dir, char *dst)
*

vf_d2i:
 move.l   a2,-(sp)
;move.l   a1,a1                    ; DIR *
;move.l   a0,a0                    ; FD *
 move.l   fd_dmd(a0),a2
 move.l   d_dfs(a2),a2
 move.l   dfs_dir2index(a2),a2
 jsr      (a2)                     ; -> index
 move.l   d0,-(sp)
 move.l   sp,a0
 move.l   12(sp),a1                ; dst
 move.b   (a0)+,(a1)+
 move.b   (a0)+,(a1)+
 move.b   (a0)+,(a1)+
 move.b   (a0)+,(a1)               ; wegen ungerader Adresse (Unsinn!!)
 addq.l   #4,sp
 move.l   (sp)+,a2
 rts

**********************************************************************
*
* void p_extfd( FD *file)
*

p_extfd:
 move.l   a2,-(sp)
 move.l   fd_dmd(a0),a2
 move.l   d_dfs(a2),a2
 move.l   dfs_ext_fd(a2),a2
;move.l   a0,a0                    ; FD *  (ist garantiert ein Prototyp)
 jsr      (a2)
 move.l   (sp)+,a2
 rts

**********************************************************************
*
* char vf_chksum( char dosname[11] )
*
* Berechnet die Pruefsumme eines 8+3-Namens im internen Format.
* Die Pruefsumme steht in jedem zugehoerigen LDIR-Eintrag.
*

vf_chksum:
 moveq    #0,d0          ; Checksum
 moveq    #11-1,d1       ; Zaehler
vfchk_loop:
 ror.b    #1,d0
 add.b    (a0)+,d0
 dbra     d1,vfchk_loop
 rts
