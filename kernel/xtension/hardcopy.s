**********************************************************************
***************     Hardcopy            ******************************
**********************************************************************

Setprt_inq     EQU $0021ffff       ; xbios Setprt(-1)

     INCLUDE "osbind.inc"

     TEXT

 bra           install

     SUPER

**********************************************************************
*
* Routine, die normalerweise in scr_dump haengt
*

do_hardcopy:
 suba.w   #$1e,sp                  ; sizeof(PBDEF)

 move.l   #Setprt_inq,(sp)
 trap     #14                      ; xbios Setprt(-1)
 move.w   d0,d1                    ; pr_conf ermitteln

 lea      (sp),a0
 moveq    #1,d2
 pea      (a0)                     ; Parameter fuer _Prtblk
 move.l   _v_bas_ad,(a0)+          ; pb_scrptr, Zeiger auf Bildschirm
 clr.w    (a0)+                    ; pb_offset
 moveq    #0,d0
 move.b   sshiftmd,d0
 lea      lblFC0D8E(pc),a1
 add.w    d0,a1
 add.w    d0,a1                    ; fuer Wortzugriff
 move.w   (a1),(a0)+               ; pb_width, Bildschirmbreite in Pixeln
 move.w   6(a1),(a0)+              ; pb_height, Bildschirmhoehe  in Pixeln
 clr.l    (a0)+                    ; pb_left/pb_right
 move.w   d0,(a0)+                 ; pb_screz, Aufloesung (0,1,2)

;move.w   pr_conf,d1

 move.w   d1,d0
 lsr.w    #3,d0
 and.w    d2,d0
 move.w   d0,(a0)+                 ; pb_prrez, Qualitaet/Test
 move.l   #$ffff8240,(a0)+         ; pb_colptr, Zeiger auf Farbpalette
 move.w   d1,d0
 and.w    #7,d0
 move.b   lblFC0D9A(pc,d0.w),d0
 move.w   d0,(a0)+                 ; pb_prtype
 lsr.w    #4,d1
 and.w    d2,d1
 move.w   d1,(a0)+                 ; pb_prport
 clr.l    (a0)                     ; pb_mask, char *
 move.w   d2,_dumpflg
 bsr      _Prtblk
 move.w   #-1,_dumpflg
 adda.w   #(4+$1e),sp
 rts

lblFC0D8E:
 DC.W     320,640,640         ; horizontale Aufloesungen
 DC.W     200,200,400         ; vertikale Aufloesungen

lblFC0D9A:
 DC.B     $00,$02,$01,$ff,$03,$ff,$ff,$ff


**********************************************************************
*
* void MyPrtblk( ??? *par )
*

* sp[00..31]                  ; int _rgb[16]
* sp[32..63]                  ; int _commoncol[16]
* sp[64..95]                  ; int _druck_col[16]

MyPrtblk:
 movem.l    d3-d7/a3-a6,-(sp)
 move.l     (a0),-(sp)
 bsr.b      _Prtblk
 addq.l     #4,sp
 movem.l    (sp)+,d3-d7/a3-a6
 rte

_Prtblk:
* lblFC215C:
 movea.l  4(sp),a0
 movem.l  d3/d4/d5/d6/d7/a3/a4/a5/a6,-(sp)
 move.l   sp,prb_ruecksprung       ; fuer Fehlerbehandlung
 lea      -96(sp),sp               ; Platz fuer 16+16+16 Integers
 movea.l  a0,a5
 lea      32(sp),a4                ; int  prb_commoncol[16]
 lea      64(sp),a3                ; int  prb_druck_col[16]
 move.w   6(a5),d3                 ; p_width
 move.w   $c(a5),prb_p_right
 move.l   $1a(a5),prb_p_masks
 move.w   $18(a5),d0               ; p_port
 seq.b    prb_centronics
 cmpi.w   #1,d0
 bhi      prb_error
 move.w   8(a5),d4                 ; p_height
 bne.b    lblFC2200

* if (p_height == 0)

 move.l   (a5),a6                  ; p_blkptr
 bra.b    lblFC21E2
lblFC21B0:
 cmpi.w   #1,_dumpflg
 bne.b    lblFC21F2
 move.b   (a6)+,d0
 bsr      prtch
lblFC21E2:
 subq.w   #1,d3
 bcc.b    lblFC21B0                ; war vorher nicht 0
lblFC21F2:
 bra      ende_ok


lblFC2200:
 cmpi.w   #3,$16(a5)               ; p_type
 bhi      prb_error
 cmpi.w   #1,$10(a5)               ; p_destres
 bhi      prb_error
 cmpi.w   #7,4(a5)                 ; p_offset
 bhi      prb_error
 move.w   $e(a5),d0                ; p_srcres
 seq.b    prb_lowres
 cmpi.w   #2,d0
 bhi      prb_error
 subq.w   #1,d0
 seq.b    prb_medres
 subq.w   #1,d0
 seq.b    prb_hires
 tst.w    $10(a5)                  ; p_destres
 seq.b    prb_quality
 move.w   $16(a5),d0               ; p_type
 subq.w   #1,d0
 seq      prb_color_mp             ; Atari Matrix farbig
 subq.w   #1,d0
 beq      prb_error                ; kein Typenrad unterstuetzen
 subq.w   #1,d0
 seq.b    prb_epson                ; Epson
 bne.b    no_qualtest              ; kein Epson
 st       prb_quality
no_qualtest:
 tst.b    prb_lowres
 beq.b    lblFC235A
 cmpi.w   #$140,d3
 bls.b    lblFC235A
 move.w   d3,d0
 add.w    #$fec0,d0
 add.w    d0,prb_p_right
 move.w   #$140,d3
 bra.b    lblFC237C
lblFC235A:
 cmpi.w   #$280,d3
 bls.b    lblFC237C
 move.w   d3,d0
 add.w    #$fd80,d0
 add.w    d0,prb_p_right
 move.w   #$280,d3
lblFC237C:
 tst.l    prb_p_masks
 seq.b    prb_defmask
 bne.b    lblFC239E
 lea      lblFE8288(pc),a0
 move.l   a0,prb_p_masks
lblFC239E:
 movea.l  $12(a5),a0               ; p_colpal
 tst.b    prb_hires
 beq.b    lblFC23BC
 move.w   (a0),d0
 and.w    #1,d0
 move.w   d0,prb_sw_col
 bra      lblFC2648

* for i = 0..15

lblFC23BC:
 lea      (sp),a6                  ; prb_rgb
 move.l   a4,a1                    ; prb_commoncol
 move.l   a3,a2                    ; prb_druck_col
 moveq    #15,d2                   ; dbra- Zaehler
lblFC23C2:
 moveq    #8,d1                    ; Default fuer prb_commoncol
 move.w   (a0)+,d0
 and.w    #$777,d0
 cmpi.w   #$777,d0
 beq      lblFC2614
 move.w   d0,prb_blue
 andi.w   #7,prb_blue
 lsr.w    #4,d0
 move.w   d0,prb_green
 andi.w   #7,prb_green
 lsr.w    #4,d0
 andi.w   #7,d0
 move.w   d0,prb_red
 tst.b    prb_color_mp
 beq      lblFC25C2
 move.w   prb_red(pc),(a2)
 move.w   (a2),d0
 cmp.w    prb_green(pc),d0
 bge.b    lblFC2452
 move.w   prb_green(pc),(a2)
lblFC2452:
 move.w   (a2),d0
 cmp.w    prb_blue(pc),d0
 bge.b    lblFC248A
 move.w   prb_blue(pc),(a2)
lblFC248A:
 addq.w   #1,(a2)
 move.w   prb_red(pc),(a1)
 move.w   (a1),d0
 cmp.w    prb_green(pc),d0
 ble.b    lblFC24DE
 move.w   prb_green(pc),(a1)
lblFC24DE:
 move.w   (a1),d0
 cmp.w    prb_blue(pc),d0
 ble.b    lblFC2516
 move.w   prb_blue(pc),(a1)
lblFC2516:
 move.w   (a1),d1
 addq.w   #1,d1                    ; prb_commoncol[i] + 1
 move.w   prb_red(pc),d0
 clr.w    prb_red
 sub.w    d1,d0
 ble.b    lblFC254E
 move.w   #1,prb_red
lblFC254E:
 move.w   prb_green(pc),d0
 clr.w    prb_green
 sub.w    d1,d0
 ble.b    lblFC2572
 move.w   #1,prb_green
lblFC2572:
 move.w   prb_blue(pc),d0
 clr.w    prb_blue
 sub.w    d1,d0
 ble.b    lblFC2596
 move.w   #1,prb_blue
lblFC2596:
 move.w   prb_red(pc),d0
 lsl.w    #1,d0
 add.w    prb_green(pc),d0
 lsl.w    #1,d0
 add.w    prb_blue(pc),d0
 move.w   d0,(a6)+
 bra.b    lblFC2612
lblFC25C2:
 move.w   prb_red(pc),d1
 mulu     #$1e,d1
 move.w   prb_green(pc),d0
 mulu     #$3b,d0
 add.w    d0,d1
 move.w   prb_blue(pc),d0
 mulu     #$b,d0
 add.w    d0,d1
 ext.l    d1
 divu     #$64,d1
lblFC2614:
 move.w   d1,(a1)
 move.w   #7,(a6)+
 move.w   #8,(a2)
lblFC2612:
 addq.l   #2,a1
 addq.l   #2,a2
 dbra     d2,lblFC23C2



lblFC2648:
 lea      prb_msk(pc),a6
 tst.b    prb_lowres
 beq.b    lblFC2666
 moveq    #4,d5                    ; points
 move.w   d5,prb_fac
 move.w   d5,prb_l_height
 bra.b    lblFC269E
lblFC2666:
 tst.b    prb_medres
 beq.b    lblFC2686
 moveq    #2,d5                    ; points
 move.w   d5,prb_fac
 move.w   #4,prb_l_height
 bra.b    lblFC269E
lblFC2686:
 moveq    #1,d5                    ; points
 move.w   #8,prb_l_height
 move.w   #2,prb_fac
lblFC269E:
 tst.b    prb_epson
 beq.b    lblFC26AC
 lsr.w    prb_fac
lblFC26AC:
 move.w   $a(a5),d0                ; p_left
 add.w    d3,d0
 add.w    prb_p_right(pc),d0
 mulu     d5,d0                    ; points,d0
 lsr.w    #4,d0
 move.w   d0,prb_bildbreite
 mulu     prb_l_height(pc),d0
 move.w   d0,prb_worte_pro_d
 move.l   (a5),d1                  ; p_blkptr
 bclr     #0,d1
 move.l   d1,prb_startadr
 move.w   4(a5),d0                 ; p_offset
 cmp.l    (a5),d1                  ; p_blkptr
 beq.b    lblFC2722
 addq.w   #8,d0
lblFC2722:
 move.w   d0,prb_pix_offset
 st.b     prb_b2
 clr.w    prb_line
 bra      lblFC309E
lblFC273A:
 cmpi.w   #1,_dumpflg
 bne      lblFC30AE
 tst.b    prb_defmask
 beq      lblFC28D4
 st.b     prb_leer
 move.w   d3,d0
 mulu     d5,d0                    ; points,d0
 lsr.w    #4,d0
 sub.w    d5,d0                    ; points,d0
 lsl.w    #1,d0
 swap     d0
 clr.w    d0
 swap     d0
 add.l    prb_startadr(pc),d0
 move.l   d0,prb_aktadr
 moveq    #$f,d0
 move.w   d3,d1
 and.w    d0,d1
 sub.w    d1,d0
 move.w   d0,prb_rl
 move.w   d3,prb_width
 bra      lblFC28C8
lblFC27A2:
 move.w   d4,d0                    ; p_height
 sub.w    prb_line(pc),d0
 moveq    #0,d1
 move.w   d0,d1
 divu     prb_l_height(pc),d1
 beq.b    lblFC27D0
 move.w   prb_l_height(pc),d0
lblFC27D0:
 move.w   d0,d6
 move.l   prb_aktadr(pc),prb_aktbyte


 clr.w    d7
 bra      lblFC288A
lblFC27E6:
 bsr      best_byte
 tst.b    prb_hires
 beq.b    lblFC285C
 move.w   prb_bitbild(pc),d0
 move.w   prb_sw_col(pc),d1
 eor.w    d1,d0
 bne.b    lblFC2878
 clr.b    prb_leer
 bra.b    lblFC2894
lblFC285C:
 movea.w  prb_bitbild(pc),a0
 adda.l   a0,a0
 cmpi.w   #8,0(a4,a0.l)            ; prb_commoncol[prb_bitbild]
 beq.b    lblFC2878
 clr.b    prb_leer
 bra.b    lblFC2894
lblFC2878:
 move.w   prb_bildbreite(pc),d0
 lsl.w    #1,d0
 ext.l    d0
 add.l    d0,prb_aktbyte
 addq.w   #1,d7
lblFC288A:
 cmp.w    d6,d7
 blt      lblFC27E6


lblFC2894:
 tst.b    prb_leer
 beq.b    lblFC28D2
 subq.w   #1,prb_rl
 bge.b    lblFC28C2
 move.w   d5,d0                    ; points,d0
 asl.w    #1,d0
 ext.l    d0
 sub.l    d0,prb_aktadr
 move.w   #$f,prb_rl
lblFC28C2:
 subq.w   #1,prb_width
lblFC28C8:
 tst.w    prb_width
 bgt      lblFC27A2
lblFC28D2:
 bra.b    lblFC28DE
lblFC28D4:
 move.w   d3,prb_width
lblFC28DE:
 move.w   prb_width(pc),d7
 mulu     prb_fac(pc),d7
 tst.b    prb_epson
 beq.b    lblFC28FC
 move.w   d7,d0
 lsr.w    #1,d0
 add.w    d0,d7
lblFC28FC:
 move.w   d7,prb_anz_hilo         ; gleich beide Bytes
 clr.w    prb_k
 bra      lblFC2F74
lblFC2928:
 clr.w    prb_c_plane
 bra      lblFC2F18
lblFC2932:
 tst.b    prb_color_mp
 beq      lblFC29B0
 tst.b    prb_hires
 bne      lblFC29B0
 tst.w    prb_c_plane
 bne.b    lblFC296C
 moveq    #lblFE829A-lblFE829A,d0
 bsr      prtstr
 bra.b    lblFC29B0
lblFC296C:
 cmpi.w   #1,prb_c_plane
 bne.b    lblFC2994
 moveq    #lblFE829F-lblFE829A,d0
 bsr      prtstr
 bra.b    lblFC29B0
lblFC2994:
 moveq    #lblFE82A4-lblFE829A,d0
 bsr      prtstr
lblFC29B0:
 tst.b    prb_epson
 beq.b    lblFC29C0
 moveq    #lblFE82A9-lblFE829A,d0
 bra.b    lblFC29C6
lblFC29C0:
 moveq    #lblFE82AD-lblFE829A,d0
lblFC29C6:
 bsr      prtstr
 move.b   prb_anz_lo(pc),d0
 bsr      prtch
 move.b   prb_anz_hi(pc),d0
 bsr      prtch
 st.b     prb_alt_flg
 move.l   prb_startadr(pc),prb_aktadr
 move.w   prb_pix_offset(pc),prb_rl
 clr.w    prb_l
 bra      lblFC2EE8
lblFC2A42:
 lea      (a6),a0                  ; prb_msk
 clr.l    (a0)+
 clr.l    (a0)                     ; 8 Bytes loeschen
 lea      prb_cix(pc),a0
 lea      prb_acht(pc),a1
 moveq    #3,d1
setca_loop:
 move.w   #7,(a0)+
 move.w   #8,(a1)+
 dbra     d1,setca_loop
 move.w   d4,d0                    ; p_height
 sub.w    prb_line,d0
 swap     d0
 clr.w    d0
 swap     d0
 divu     prb_l_height(pc),d0
 beq.b    lblFC2AA2
 move.w   prb_l_height(pc),d0
 bra.b    lblFC2AAE
lblFC2AA2:
 move.w   d4,d0                    ; p_height
 sub.w    prb_line(pc),d0
lblFC2AAE:
 move.w   d0,d6
 move.w   d4,d0                    ; p_height
 sub.w    prb_line(pc),d0
 swap     d0
 clr.w    d0
 swap     d0
 divu     prb_l_height(pc),d0
 beq.b    lblFC2ADA
 move.w   prb_l_height(pc),d6
 bra.b    lblFC2AF2
lblFC2ADA:
 move.w   d4,d0                    ; p_height
 sub.w    prb_line(pc),d0
 move.w   d0,d6
 clr.b    prb_b2
lblFC2AF2:
 move.l   prb_aktadr(pc),prb_aktbyte


 clr.w    d7
 bra      lblFC2C1C
lblFC2B02:
 bsr      best_byte
 lea      (a6),a2                  ; prb_msk
 adda.w   d7,a2                    ; a2 = prb_msk+i
 tst.b    prb_hires
 beq.b    lblFC2B8A
* hires
 move.w   prb_bitbild(pc),d0
 move.w   prb_sw_col(pc),d1
 eor.w    d1,d0
 bne.b    lblFC2B7A
 movea.l  prb_p_masks(pc),a0
 move.b   (a0),d0
 ext.w    d0
 bra.b    lblFC2B7C
lblFC2B7A:
 clr.w    d0
lblFC2B7C:
 move.b   d0,(a2)
 bra      lblFC2C0A
* else
lblFC2B8A:
 adda.w   d7,a2                    ; a2 = prb_msk+i+i
 move.w   prb_bitbild(pc),d0
 add.w    d0,d0
 movea.w  0(a4,d0.w),a1            ; prb_commoncol[prb_bitbild]
 adda.w   a1,a1
 adda.l   prb_p_masks(pc),a1
 move.b   (a1)+,(a2)+              ; a2 = prb_msk+i+i+1
 move.b   (a1),(a2)
 lea      prb_cix(pc),a0
 adda.w   d7,a0
 adda.w   d7,a0                    ; 2*i fuer int- Zugriff
 move.w   d0,a1                    ; 2*prb_bitbild fuer int- Zugriff
 move.w   0(sp,a1.w),(a0)
 move.w   64(sp,a1),prb_acht-prb_cix(a0)   ; prb_druck_col[prb_bitbild]


lblFC2C0A:
 moveq    #0,d0
 move.w   prb_bildbreite(pc),d0
 lsl.l    #1,d0
 add.l    d0,prb_aktbyte
 addq.w   #1,d7
lblFC2C1C:
 cmp.w    d6,d7
 blt      lblFC2B02


 tst.b    prb_color_mp
 beq      lblFC2DEC
 tst.b    prb_hires
 bne      lblFC2DEC


 clr.w    d7
 bra      lblFC2DE2
lblFC2C40:
 clr.b    prb_mit_grndfrbe
 movea.w  d7,a0
 adda.l   a0,a0
 adda.l   #prb_cix,a0
 move.w   (a0),d0                  ; d0 = prb_cix[i]
 tst.w    prb_c_plane
 bne.b    lblFC2C74
 btst     #0,d0
 beq.b    lblFC2C70
 st.b     prb_mit_grndfrbe
lblFC2C70:
 bra      lblFC2D62
lblFC2C74:
 cmpi.w   #1,prb_c_plane
 bne      lblFC2D0A
 cmpi.w   #6,d0
 bne.b    lblFC2CC0
 adda.w   #prb_acht-prb_cix,a0     ; prb_acht[i]
 cmpi.w   #8,(a0)
 bge.b    lblFC2CC0
 adda.w   #prb_msk-prb_acht,a0     ; prb_msk[i]
 andi.b   #1,(a0)
 andi.b   #4,1(a0)
 bra.b    lblFC2D08
lblFC2CC0:
 movea.w  d7,a0
 adda.l   a0,a0
 adda.l   #prb_cix,a0
 cmpi.w   #2,(a0)
 beq.b    lblFC2D00
 cmpi.w   #3,(a0)
 beq.b    lblFC2D00
 cmpi.w   #6,(a0)
 beq.b    lblFC2D00
 cmpi.w   #7,(a0)
 bne.b    lblFC2D08
lblFC2D00:
 st.b     prb_mit_grndfrbe
lblFC2D08:
 bra.b    lblFC2D62
lblFC2D0A:
 movea.w  d7,a0
 adda.l   a0,a0
 adda.l   #prb_cix,a0                  ; prb_cix[i]
 cmpi.w   #6,(a0)
 bne.b    lblFC2D4A
 adda.w   #prb_acht-prb_cix,a0         ; prb_acht[i]
 cmpi.w   #8,(a0)
 bge.b    lblFC2D4A
 adda.w   #prb_msk-prb_acht,a0         ; prb_msk[i]
 andi.b   #4,(a0)+
 andi.b   #1,(a0)
 bra.b    lblFC2D62
lblFC2D4A:
 movea.w  d7,a0
 adda.l   a0,a0
 adda.l   #prb_cix,a0
 cmpi.w   #3,(a0)
 ble.b    lblFC2D62
 st.b     prb_mit_grndfrbe
lblFC2D62:
 movea.w  d7,a0
 adda.w   a0,a0
 lea      prb_acht(pc),a1
 adda.l   a0,a1                    ; a1 = &prb_acht[i]
 adda.l   a6,a0                    ; a0 = &prb_msk[2*i]
 tst.b    prb_mit_grndfrbe
 beq.b    lblFC2D84
 clr.b    (a0)
 clr.b    1(a0)
lblFC2D84:
 move.w   (a1),a1                  ; prb_acht[i]
 adda.w   a1,a1                    ; 2*prb_acht[i]
 adda.l   prb_p_masks(pc),a1       ; &prb_p_masks[2*prb_acht[i]]
 move.b   (a1)+,d0                 ; &prb_p_masks[2*prb_acht[i]+1]
 or.b     d0,(a0)+                 ; prb_msk[2*i] = prb_p_masks[2*prb_acht[i]]
 move.b   (a1),d0
 or.b     d0,(a0)                  ; prb_msk[2*i+1] = prb_p_masks[2*prb_acht[i]+1]
 addq.w   #1,d7
lblFC2DE2:
 cmp.w    d6,d7
 blt      lblFC2C40


lblFC2DEC:
 moveq    #4,d7
 bra      lblFC2E7E
lblFC2DF2:
 clr.b    prb_ch
 move.w   #$80,prb_zpvo
 moveq    #7,d2                    ; dbra- Zaehler
 move.l   a6,a0
lblFC2E04:
 move.b   (a0)+,d0                 ; prb_msk
 ext.w    d0
 moveq    #7,d1
 sub.w    d7,d1
 lsr.w    d1,d0
 and.w    #1,d0
 mulu     prb_zpvo(pc),d0
 add.b    prb_ch,d0
 move.b   d0,prb_ch
 lsr.w    prb_zpvo
 dbra     d2,lblFC2E04
 move.b   prb_ch(pc),d0
 bsr      prtch
 not.b    prb_alt_flg
 addq.w   #1,d7
lblFC2E7E:
 move.w   prb_fac,d0
 addq.w   #4,d0
 cmp.w    d0,d7
 blt      lblFC2DF2


 tst.b    prb_epson
 beq.b    lblFC2EBC
 tst.b    prb_alt_flg
 beq.b    lblFC2EBC
 move.b   prb_ch,d0
 bsr      prtch
lblFC2EBC:
 addq.w   #1,prb_rl
 cmpi.w   #$f,prb_rl
 ble.b    lblFC2EE2
 move.w   d5,d0                    ; points,d0
 lsl.w    #1,d0
 ext.l    d0
 add.l    d0,prb_aktadr
 clr.w    prb_rl
lblFC2EE2:
 addq.w   #1,prb_l
lblFC2EE8:
 move.w   prb_l(pc),d0
 cmp.w    prb_width(pc),d0
 blt      lblFC2A42
 moveq    #$d,d0
 bsr      prtch
 addq.w   #1,prb_c_plane
lblFC2F18:
 tst.b    prb_color_mp
 beq.b    lblFC2F2C
 tst.b    prb_hires
 bne.b    lblFC2F2C
 moveq    #3,d0
 bra.b    lblFC2F2E
lblFC2F2C:
 moveq    #1,d0
lblFC2F2E:
 cmp.w    prb_c_plane(pc),d0
 bgt      lblFC2932
 moveq    #lblFE82B1-lblFE829A,d0
 bsr      prtstr
 bsr      lf
 addq.w   #1,prb_k
lblFC2F74:
 tst.b    prb_quality
 beq.b    lblFC2F80
 moveq    #1,d0
 bra.b    lblFC2F82
lblFC2F80:
 moveq    #2,d0
lblFC2F82:
 cmp.w    prb_k(pc),d0
 bgt      lblFC2928
 tst.b    prb_quality
 beq.b    lblFC2FE2
 clr.w    d7
 bra.b    lblFC2FD0
lblFC2F98:
 moveq    #lblFE82B1-lblFE829A,d0
 bsr      prtstr
 bsr      lf
 addq.w   #1,d7
lblFC2FD0:
 tst.b    prb_epson
 beq.b    lblFC2FDC
 moveq    #2,d0
 bra.b    lblFC2FDE
lblFC2FDC:
 moveq    #1,d0
lblFC2FDE:
 cmp.w    d0,d7
 blt.b    lblFC2F98
lblFC2FE2:
 tst.b    prb_b2
 beq.b    lblFC3022
 moveq    #lblFE82BB-lblFE829A,d0
 bsr      prtstr
 bsr      lf
 bra.b    lblFC3082
lblFC3022:
 clr.w    d7
 bra.b    lblFC305E
lblFC3026:
 moveq    #lblFE82B1-lblFE829A,d0
 bsr      prtstr
 bsr      lf
 addq.w   #1,d7
lblFC305E:
 tst.b    prb_epson
 beq.b    lblFC3074
 move.w   d6,d0
 mulu     #6,d0
 subq.w   #3,d0
 bra.b    lblFC307E
lblFC3074:
 move.w   d6,d0
 lsl.w    #2,d0
 subq.w   #2,d0
lblFC307E:
 cmp.w    d0,d7
 blt.b    lblFC3026
lblFC3082:
 move.w   prb_worte_pro_d(pc),d0
 asl.w    #1,d0
 ext.l    d0
 add.l    d0,prb_startadr
 move.w   prb_l_height(pc),d0
 add.w    d0,prb_line
lblFC309E:
 cmp.w    prb_line(pc),d4                  ; p_height
 bhi      lblFC273A
lblFC30AE:
 moveq    #lblFE82C4-lblFE829A,d0
 bsr      prtstr
 tst.b    prb_color_mp
 beq.b    ende_ok
 tst.b    prb_hires
 bne.b    ende_ok
 moveq    #lblFE82C8-lblFE829A,d0
 bsr.b    prtstr
ende_ok:
 moveq    #0,d0
lblFC30D2:
 move.l   prb_ruecksprung(pc),sp
 move.w   #-1,_dumpflg
 movem.l  (sp)+,a6/a5/a4/a3/d7/d6/d5/d4/d3
 rts
prb_error:
 moveq    #-1,d0
 bra.b    lblFC30D2


best_byte:
 clr.w    prb_bitbild
 move.w   #1,prb_zpvu
 move.l   prb_aktbyte(pc),a0
 move.w   d5,d2                    ; points,d2
 bra.b    lblFC2832
lblFC2802:
 move.w   (a0)+,d0
 moveq    #$f,d1
 sub.w    prb_rl,d1
 lsr.w    d1,d0
 and.w    #1,d0
 mulu     prb_zpvu(pc),d0
 add.w    d0,prb_bitbild
 lsl.w    prb_zpvu
lblFC2832:
 dbra     d2,lblFC2802
 rts


**********************************************************************
*
* void prtch(d0 = char c)
*
* Bricht bei Fehler sofort ueber longjmp ab.
*

lf:
 moveq    #$a,d0
prtch:
* lblFC30E4:
 move.l   d0,-(sp)
 tst.b    prb_centronics
 beq.b    prtch_aux
 bsr      centout
 addq.l   #4,sp
 tst.w    d0
 bne.b    prtch_end
 bra      prb_error                    ; LONGJMP
prtch_aux:
 bsr      auxout
 addq.l   #4,sp
prtch_end:
 rts


**********************************************************************
*
* void prtstr(d0 = int offset)
*

prtstr:
* lblFC3130:
 move.l   a5,-(sp)
 lea      lblFE829A(pc),a5
 adda.w   d0,a5
 bra.b    lblFC314E
lblFC3136:
 bsr.b    prtch
lblFC314E:
 move.b   (a5)+,d0
 cmpi.b   #$ff,d0
 bne.b    lblFC3136
prtstr_end:
 move.l   (sp)+,a5
 rts


**********************************************************************
*
* Druckerausgabe fuer die interne Hardcopyfunktion.
* Der 68030- Datencache ist bereits in int_vbl abgeschaltet worden
*

centout:
* lblFC1E96:
 move.w   6(sp),d0
 movem.l  d3/d4/d5/d6/d7/a3/a4/a5/a6,-(sp)
 move.w   d0,-(sp)
 move.w   d0,-(sp)
 suba.l   a5,a5
 movea.l  prv_lst,a0
 jsr      (a0)
 addq.w   #4,sp
 movem.l  (sp)+,a6/a5/a4/a3/d7/d6/d5/d4/d3
 rts


auxout:
* lblFC1EC4:
 move.w   6(sp),d0
 movem.l  d3/d4/d5/d6/d7/a3/a4/a5/a6,-(sp)
 move.w   d0,-(sp)
 move.w   d0,-(sp)
 suba.l   a5,a5
 movea.l  prv_aux,a0
 jsr      (a0)
 addq.w   #4,sp
 movem.l  (sp)+,a6/a5/a4/a3/d7/d6/d5/d4/d3
 rts



* DATA


lblFE8288: DC.B     $f,$f,$d,$6,$9,$6,$8,$6,$8,$2,$8,0,$8,0,$8,0,0,0
lblFE829A: DC.B     $1b,'X',6,-1
lblFE829F: DC.B     $1b,'X',5,-1
lblFE82A4: DC.B     $1b,'X',3,-1
lblFE82A9: DC.B     $1b,'L',-1
lblFE82AD: DC.B     $1b,'Y',-1
lblFE82B1: DC.B     $1b,'3',1,-1
lblFE82BB: DC.B     $1b,'A',7,-1   ; $1b,'1',-1
lblFE82C4: DC.B     $1b,'2',-1
lblFE82C8: DC.B     $1b,'X',0,-1

     EVEN

*    BSS

prb_centronics:     DS.B 1              /* char prb_centronics        */
prb_b2:             DS.B 1              /* char prb_b2                */
prb_ch:             DS.B 1              /* char prb_ch                */
prb_lowres:         DS.B 1              /* char prb_lowres            */
prb_blue:           DS.W 1              /* int  prb_blue              */
prb_leer:           DS.B 1              /* char prb_leer              */
prb_defmask:        DS.B 1              /* char prb_defmask           */
prb_quality:        DS.B 1              /* char prb_quality           */
     EVEN
prb_cix:            DS.W 6              /* int  prb_cix[6]            */
prb_width:          DS.W 1              /* int  prb_width             */
prb_worte_pro_d:    DS.W 1              /* int  prb_worte_pro_d       */
prb_anz_hilo:
prb_anz_hi:         DS.B 1              /* char prb_anz_hi            */
prb_anz_lo:         DS.B 1              /* char prb_anz_lo            */
prb_l_height:       DS.W 1              /* int  prb_l_height          */
prb_bildbreite:     DS.W 1              /* int  prb_bildbreite        */
prb_startadr:       DS.L 1              /* long prb_startadr          */
prb_pix_offset:     DS.W 1              /* int  prb_pix_offset        */
prb_k:              DS.W 1              /* int  prb_k                 */
prb_zpvo:           DS.W 1              /* int  prb_zpvo              */
prb_aktbyte:        DS.L 1              /* long prb_aktbyte           */
prb_green:          DS.W 1              /* int  prb_green             */
prb_aktadr:         DS.L 1              /* long prb_aktadr            */
prb_zpvu:           DS.W 1              /* int  prb_zpvu              */
prb_bitbild:        DS.W 1              /* int  prb_bitbild           */
prb_sw_col:         DS.W 1              /* int  prb_sw_col            */
prb_c_plane:        DS.W 1              /* int  prb_c_plane           */
prb_l:              DS.W 1              /* int  prb_l                 */
prb_red:            DS.W 1              /* int  prb_red               */
prb_p_masks:        DS.L 1              /* char *prb_p_masks          */
prb_line:           DS.W 1              /* int  prb_line              */
prb_p_right:        DS.W 1              /* int  prb_p_right           */
prb_ruecksprung:    DS.L 1              /* long prb_ruecksprung       */
prb_rl:             DS.W 1              /* int  prb_rl                */
prb_msk:            DS.B 8              /* char prb_msk[8]            */
prb_acht:           DS.W 4              /* int  prb_acht[4]           */
prb_mit_grndfrbe:   DS.B 1              /* char prb_mit_grndfrbe      */
prb_alt_flg:        DS.B 1              /* char prb_alt_flg           */
prb_fac:            DS.W 1              /* int  prb_fac               */
prb_hires:          DS.B 1              /* char prb_hires             */
prb_medres:         DS.B 1              /* char prb_medres            */
prb_epson:          DS.B 1              /* char prb_epson             */
prb_color_mp:       DS.B 1              /* char prb_color_mp          */

     EVEN

********************
*** Installation ***
********************

install:
 pea      get_sysvars(pc)
 xbios    Supexec
 addq.l   #6,sp
 tst.l    d0                  ; cookie da ?
 ble.b    exit

 pea      MyPrtblk(pc)
 clr.w    -(sp)               ; Unterfunktion #0
 clr.l    -(sp)               ; leerer Zeiger
 move.w   #Prtblk,-(sp)
 trap     #14
 lea      12(sp),sp
 tst.l    d0
 bmi.b    exit

 pea      setdump(pc)
 xbios    Supexec
 addq.l   #6,sp

 move.l   4(sp),a0            * Zeiger auf BP
 move.l   $c(a0),d7           * text
 add.l    $14(a0),d7          * +data
 add.l    $1c(a0),d7          * +bss
 add.l    #256,d7             * +BP
 move.l   d7,-(sp)
 gemdos   Ptermres

exit:
 move.w   #-1,-(sp)
 gemdos   Pterm


get_sysvars:
 move.l   _p_cookies,a0
 move.l   a0,d0
 beq.b    getsv_end                ; Zeiger ungueltig
getcookie_loop:
 move.l   (a0)+,d1                 ; Cookiename holen
 beq.b    getsv_end                ; Ende der Cookie- Liste
 move.l   (a0)+,d0                 ; Wert
 cmpi.l   #'MagX',d1
 bne.b    getcookie_loop
getsv_end:
 rts

setdump:
 move.l   #do_hardcopy,scr_dump
 rts

     END

