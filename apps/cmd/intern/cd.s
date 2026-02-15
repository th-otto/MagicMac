PUFFER    SET  -200

cd_com:
 link     a6,#PUFFER
 movem.l  d6/d7/a5,-(sp)
 movea.l  ARGV(a6),a0
 movea.l  4(a0),a5
 move.l   a5,a0
 bsr      str_to_drive
 move.w   d0,d7
 blt.b    cdcom_50              * ungÅltiges Laufwerk

 cmpi.w   #1,ARGC(a6)
 ble.b    cdcom_4               * kein Parameter
 move.l   a5,a0
 bsr      is_newdrive
 tst.w    d0
 bge.b    cdcom_4               * Eingabe:  "CD X:"

 move.l   a5,-(sp)
 gemdos   Dsetpath              * Pfad setzen
 addq.l   #6,sp
 move.w   d0,d7                 * RÅckgabewert in d7 merken

 beq.b    cdcom_end
 bsr      crprint_err
cdcom_50:
 bsr      inc_errlv             * ungÅltiger Pfad
 bra.b    cdcom_end
cdcom_4:
 bsr      crlf_stdout
 lea      PUFFER(a6),a0
 move.w   d7,d0
 bsr      drive_to_defpath
 lea      PUFFER(a6),a0
 bsr      strstdout
 bsr      crlf_stdout
cdcom_end:
 movem.l  (sp)+,a5/d7/d6
 unlk     a6
 rts
