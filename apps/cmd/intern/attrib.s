DTA       SET  8
DATEINAME SET  4

* int attr(char *dateiname, DTA *)
* char *dateiname;
*  Setzt/Lîscht oder zeigt Attribute an

attr:
 lea      d+attrplus(pc),a0
 lea      d+attrminus(pc),a1
 move.l   DTA(sp),a2
 clr.w    d2
 move.b   $15(a2),d2          * Attribut
 move.b   (a0),d0
 or.b     (a1),d0
 beq.b    attr_10             * nur anzeigen
 or.b     (a0),d2             * Bits setzen
 move.b   (a1),d0
 not.b    d0
 and.b    d0,d2               * Bits lîschen
 cmp.b    $15(a2),d2          * hat sich Attribut geÑndert
 beq      attr_99             * nein => Ende
 move.w   d2,-(sp)
 move.w   #1,-(sp)
 move.l   DATEINAME+2+2(a7),-(sp)
 gemdos   Fattrib
 adda.w   #$a,sp
 move.l   d0,d2
 bge.b    attr_10
 bsr      print_err
 lea      auf_s(pc),a0
 bsr      get_country_str
 bsr      strcon
 bra.b    attr_20
attr_10:
 move.w   d2,d0
 bsr      print_attr
attr_20:
 move.l   DATEINAME(sp),a0
 bsr      strstdout
 bsr      crlf_stdout
attr_99:
 clr.w    d0
 rts


*
*
*
attrib_com:
 move.l   a5,-(sp)
 bsr      crlf_con
 lea      d+attrplus(pc),a0
 clr.b    (a0)
 clr.b    attrminus-attrplus(a0)
 subq     #1,SP_ARGC+4(sp)
* Attribute holen
atcom_3:
 subq     #1,SP_ARGC+4(sp)
 bcs      atcom_50
 addq.l   #4,SP_ARGV+4(sp)
 move.l   SP_ARGV+4(sp),a5
 move.l   (a5),a5
 move.l   a0,a1
 cmpi.b   #'+',(a5)
 beq.b    atcom_1
 lea      d+attrminus(pc),a1
 cmpi.b   #'-',(a5)
 bne.b    atcom_20
atcom_1:
 addq.l   #1,a5
 move.b   (a5),d0
 beq.b    atcom_3
 bsr      d0_upper
 moveq    #1,d1
 cmpi.b   #'R',d0
 beq.b    atcom_2
 moveq    #2,d1
 cmpi.b   #'H',d0
 beq.b    atcom_2
 moveq    #4,d1
 cmpi.b   #'S',d0
 beq.b    atcom_2
 moveq    #32,d1
 cmpi.b   #'A',d0
 bne.b    atcom_50
atcom_2:
 or.b     d1,(a1)
 bra.b    atcom_1
* Dateinamen holen
atcom_20:
 lea      attr(pc),a1    * auszufÅhrende Routine
 moveq    #6,d0          * Dateityp = alle auûer Subdir
 move.l   a5,a0          * Dateiname(nsmuster)
 bsr      for_all
 bne.b    atcom_21
 move.l   a5,a0
 bsr      strcon
 lea      not_founds(pc),a0
 bsr      get_country_str
 bsr      strcon
 bsr      inc_errlv
atcom_21:
 addq.l   #4,SP_ARGV+4(sp)
 move.l   SP_ARGV+4(sp),a5
 move.l   (a5),a5
 subq.w   #1,SP_ARGC+4(sp)
 bcc.b    atcom_20
 bra.b    atcom_end
atcom_50:
 lea      syntaxattrs(pc),a0
 bsr      get_country_str
 bsr      strcon              * Fehlermeldung ausgeben und Ende
 bsr      inc_errlv
atcom_end:
 move.l   (sp)+,a5
 rts
