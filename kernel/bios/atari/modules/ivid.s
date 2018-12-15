/*
*
* Video-Initialisierung fuer ST/TT/Falcon
*
*/

pal_tab:
 DC.W     $0fff,$0f00,$00f0,$0ff0  ; fuer STe, der ST ignoriert Bits 3/7/11
 DC.W     $000f,$0f0f,$00ff,$0555
 DC.W     $0333,$0f33,$03f3,$0ff3
 DC.W     $033f,$0f3f,$03ff,$0000

boot_init_video:
 cmpi.b   #4,machine_type               ;Falcon?
 bne      boot_iv_st_tt

 move.b   MON_ID.w,d1
 lsr.w    #6,d1
 and.w    #3,d1                              
 move.w   d1,monitor.w                  ;Monitortyp

 move.w   #STMODES+COL80+BPS1,d0        ;ST-hoch
 move.b   #2,sshiftmd.w                 ;ST-hoch
 cmp.w    #MONO_MON,d1                  ;SM 124?
 beq.s    boot_iv_flc
 cmp.w    #VGA_MON,d1                   ;VGA-Monitor?
 beq.s    boot_iv_flc
 move.w   #STMODES+COL80+BPS2,d0        ;ST-mittel
 move.b   #1,sshiftmd.w                 ;ST-mittel

boot_iv_flc:
 bsr      falcon_vmode                  ;ST-Hoch oder ST-Mittel setzen

 lea      $ffff9800.w,a1                ;Zeiger auf die Falcon-Palette
 move.l   #$ffffffff,(a1)+              ;Farbe 0: weiss
 clr.l    (a1)+                         ;Farbe 1: schwarz

 bra.b    boot_iv_l1
     
boot_iv_st_tt: 
 moveq    #1,d1                         ; ST-Syncmode fuer TT (intern)
 cmpi.b   #3,machine_type
 beq.b    boot_iv_l2                     ; TT
 move.w   syshdr+os_palmode(pc),d0      ; wegen MAS- Fehler
 btst     #0,d0
 beq.b    boot_iv_l1                     ; NTSC
 bsr      delay_special_b
 moveq    #2,d1
boot_iv_l2:
 move.b   d1,$ffff820a                  ; ST:50 Hz/PAL TT:Sync intern

* Farbpalette setzen

boot_iv_l1:
 lea      $ffff8240,a1
 moveq    #$f,d0
 lea      pal_tab(pc),a0
boot_iv_loop:
 move.w   (a0)+,(a1)+
 dbf      d0,boot_iv_loop

* Bildschirmspeicher 32 k bzw. 155k unter phystop setzen und loeschen
* <phystop>,<scrbuf_adr> und <scrbuf_len> muessen long-aligned sein

 move.l   #$8000,d0                ; STs und Falcon: 32K fuer Bildschirm
 cmpi.b   #3,machine_type
 bne.b    vmems_st
 move.l   #$25900,d0               ; TT: ~155K fuer Bildschirm
vmems_st:
 movea.l  phystop,a0
 move.l   a0,a1                    ; bis phystop loeschen
 suba.l   d0,a0                    ; ab (phystop - d0)
 move.l   a0,_v_bas_ad
     IFNE FALCON
 move.l   a0,scrbuf_adr
 move.l   d0,scrbuf_len
     ENDIF
 move.l   a0,_memtop
 jsr      fast_clrmem
 move.b   _v_bas_ad+1,$ffff8201
 move.b   _v_bas_ad+2,$ffff8203
 move.b   _v_bas_ad+3,$ffff820d    ; STe
 rts
