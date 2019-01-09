;Standardformat ins geraeteabhaengige Format wandeln
;Tabulatorgroesse: 3
;Anmerkung: .b statt .s verwenden wg. MAS, 8 relevante Zeichen fuer Labels
;06.04.95:  Am Ende von ip_4_to_8 fehlte das moveq #1,d0, daher wurde
;           manchmal das farbige und manchmal das sw-Icon gezeichnet

                     .EXPORT  srchEdDI

                     .EXPORT  xp_tab
                     .EXPORT  xp_ptr

                     .EXPORT  xp_raster

                     .EXPORT  xp_ip_4
                     .EXPORT  xp_ip_8
                     .EXPORT  xp_pp_4
                     .EXPORT  xp_pp_8
                     .EXPORT  xp_pp_16
                     .EXPORT  xp_pp_24
                     .EXPORT  xp_pp_32
                     .EXPORT  xp_unknown
                     .EXPORT  xp_dummy

                     .EXPORT  W_mul_L
                     .EXPORT  L_div_W

                     .TEXT

p_cookies            EQU   $05a0                ;Zeiger auf den Cookie-Jar

;Standardformat in geraeteabhaengiges Format wandeln
;Vorgaben:
;Register d0-d7/a0-a6 koennen veraendert werden
;Eingaben:
;d0.l Anzahl der zu wandelnden Worte (pro Ebene)
;d1.l Laenge einer Ebene in Bytes
;d2.w Anzahl der Ebenen des Quellrasters
;a0.l Quellraster im Standardformat
;a1.l Zielraster
;Ausgaben:
;d0.w 0: Raster kann nicht gewandelt werden 1: Raster wurde gewandelt
xp_raster:        move.l   d0,d4
                  subq.l   #1,d4                ;Anzahl  der Worte - 1
                  move.l   d1,d6
                  add.l    d6,d6
                  add.l    d6,d6                ;Laenge von 4 Quellebenen in Bytes

                  movea.l  a1,a4                ;Zeiger auf das Zielraster
                  lea      (a0,d1.l),a1         ;Zeiger auf Quellebene 1
                  lea      (a1,d1.l),a2         ;Zeiger auf Quellebene 2
                  lea      (a2,d1.l),a3         ;Zeiger auf Quellebene 3

                  movea.l  xp_ptr,a5            ;Wandlungsroutine aufrufen
                  jmp      (a5)

;Quellraster zu 4 Ebenen mit Interleaved Planes wandeln
;Eingaben:
;d2.w Anzahl der Ebenen des Quellrasters
;d4.l Anzahl der Worte - 1
;d6.l Laenge von 4 Quellebenen in Bytes
;a0.l Zeiger auf Quellebene 0
;a1.l Zeiger auf Quellebene 1
;a2.l Zeiger auf Quellebene 2
;a3.l Zeiger auf Quellebene 3
;a4.l Zeiger auf das Zielraster
;Ausgaben:
;d0.w 0: Raster kann nicht gewandelt werden 1: Raster wurde gewandelt
xp_ip_4:          subq.w   #2,d2                ;Quellraster mit 2 Ebenen?
                  beq.b    ip_2_to_4
                  subq.w   #2,d2                ;Quellraster mit 4 Ebenen?
                  beq.b    ip_4_to_4
                  moveq    #0,d0                ;Raster ist nicht wandelbar
                  rts

;2 Ebenen im Standardformat zu 4 Ebenen mit Interleaved Planes wandeln
;Eingaben:
;d4.l Anzahl der Worte - 1
;a0.l Zeiger auf Quellebene 0
;a1.l Zeiger auf Quellebene 1
;a4.l Zeiger auf das Zielraster
;Ausgaben:
;d0.w 1: Raster wurde gewandelt
ip_2_to_4:        move.w   (a0)+,d0
                  move.w   (a1)+,d1

                  move.w   d0,(a4)+
                  move.w   d1,(a4)+

                  and.w    d1,d0                ;Schwarz-Anteil
                  move.w   d0,(a4)+
                  move.w   d0,(a4)+

                  subq.l   #1,d4
                  bpl.b    ip_2_to_4
                  moveq    #1,d0                ;Raster wurde gewandelt
                  rts

;4 Ebenen im Standardformat zu 4 Ebenen mit Interleaved Planes wandeln
;Eingaben:
;d4.l Anzahl der Worte - 1
;a0.l Zeiger auf Quellebene 0
;a1.l Zeiger auf Quellebene 1
;a2.l Zeiger auf Quellebene 2
;a3.l Zeiger auf Quellebene 3
;a4.l Zeiger auf das Zielraster
;Ausgaben:
;d0.w 1: Raster wurde gewandelt
ip_4_to_4:        move.w   (a0)+,(a4)+
                  move.w   (a1)+,(a4)+
                  move.w   (a2)+,(a4)+
                  move.w   (a3)+,(a4)+

                  subq.l   #1,d4
                  bpl.b    ip_4_to_4
                  moveq    #1,d0                ;Raster wurde gewandelt
                  rts

;Quellraster zu 8 Ebenen mit Interleaved Planes wandeln
;Eingaben:
;d2.w Anzahl der Ebenen des Quellrasters
;d4.l Anzahl der Worte - 1
;d6.l Laenge von 4 Quellebenen in Bytes
;a0.l Zeiger auf Quellebene 0
;a1.l Zeiger auf Quellebene 1
;a2.l Zeiger auf Quellebene 2
;a3.l Zeiger auf Quellebene 3
;a4.l Zeiger auf das Zielraster
;Ausgaben:
;d0.w 0: Raster kann nicht gewandelt werden 1: Raster wurde gewandelt
xp_ip_8:          subq.w   #2,d2                ;Quellraster mit 2 Ebenen?
                  beq.b    ip_2_to_8
                  subq.w   #2,d2                ;Quellraster mit 4 Ebenen?
                  beq.b    ip_4_to_8
                  subq.w   #4,d2                ;Quellraster mit 8 Ebenen?
                  beq.b    ip_8_to_8
                  moveq    #0,d0                ;Raster ist nicht wandelbar
                  rts

;2 Ebenen im Standardformat zu 8 Ebenen mit Interleaved Planes wandeln
;Eingaben:
;d4.l Anzahl der Worte - 1
;a0.l Zeiger auf Quellebene 0
;a1.l Zeiger auf Quellebene 1
;a4.l Zeiger auf das Zielraster
;Ausgaben:
;d0.w 1: Raster wurde gewandelt
ip_2_to_8:        move.w   (a0)+,d0             ;Quellebene 0
                  move.w   (a1)+,d1             ;Quellebene 1

                  move.w   d0,(a4)+
                  move.w   d1,(a4)+

                  and.w    d1,d0
                  move.w   d0,(a4)+
                  move.w   d0,(a4)+
                  move.w   d0,(a4)+
                  move.w   d0,(a4)+
                  move.w   d0,(a4)+
                  move.w   d0,(a4)+

                  subq.l   #1,d4
                  bpl.b    ip_2_to_8
                  moveq    #1,d0                ;Raster wurde gewandelt
                  rts

;4 Ebenen im Standardformat zu 8 Ebenen mit Interleaved Planes wandeln
;Eingaben:
;d4.l Anzahl der Worte - 1
;a0.l Zeiger auf Quellebene 0
;a1.l Zeiger auf Quellebene 1
;a2.l Zeiger auf Quellebene 2
;a3.l Zeiger auf Quellebene 3
;a4.l Zeiger auf das Zielraster
;Ausgaben:
;d0.w 1: Raster wurde gewandelt
ip_4_to_8:        move.w   (a0)+,d0             ;Quellebene 0
                  move.w   (a1)+,d1             ;Quellebene 1
                  move.w   (a2)+,d2             ;Quellebene 2
                  move.w   (a3)+,d3             ;Quellebene 3

                  move.w   d0,(a4)+
                  move.w   d1,(a4)+
                  move.w   d2,(a4)+
                  move.w   d3,(a4)+

                  and.w    d1,d0
                  and.w    d2,d0
                  and.w    d3,d0
                  move.w   d0,(a4)+
                  move.w   d0,(a4)+
                  move.w   d0,(a4)+
                  move.w   d0,(a4)+

                  subq.l   #1,d4
                  bpl.b    ip_4_to_8
                  moveq    #1,d0                ;Raster wurde gewandelt
                  rts

;8 Ebenen im Standardformat zu 8 Ebenen mit Interleaved Planes wandeln
;Eingaben:
;d4.l Anzahl der Worte - 1
;d6.l Laenge von 4 Quellebenen in Bytes
;a0.l Zeiger auf Quellebene 0
;a1.l Zeiger auf Quellebene 1
;a2.l Zeiger auf Quellebene 2
;a3.l Zeiger auf Quellebene 3
;a4.l Zeiger auf das Zielraster
;Ausgaben:
;d0.w 1: Raster wurde gewandelt
ip_8_to_8:        move.w   (a0)+,(a4)+
                  move.w   (a1)+,(a4)+
                  move.w   (a2)+,(a4)+
                  move.w   (a3)+,(a4)+
                  move.w   -2(a0,d6.l),(a4)+
                  move.w   -2(a1,d6.l),(a4)+
                  move.w   -2(a2,d6.l),(a4)+
                  move.w   -2(a3,d6.l),(a4)+

                  subq.l   #1,d4
                  bpl.b    ip_8_to_8
                  moveq    #1,d0                ;Raster wurde gewandelt
                  rts

;Quellraster zu 4 Bit Packed Pixels wandeln
;Eingaben:
;d2.w Anzahl der Ebenen des Quellrasters
;d4.l Anzahl der Worte - 1
;d6.l Laenge von 4 Quellebenen in Bytes
;a0.l Zeiger auf Quellebene 0
;a1.l Zeiger auf Quellebene 1
;a2.l Zeiger auf Quellebene 2
;a3.l Zeiger auf Quellebene 3
;a4.l Zeiger auf das Zielraster
;Ausgaben:
;d0.w 0: Raster kann nicht gewandelt werden 1: Raster wurde gewandelt
xp_pp_4:          subq.w   #2,d2                ;Quellraster mit 2 Ebenen?
                  beq.b    pp_2_to_4
                  subq.w   #2,d2                ;Quellraster mit 4 Ebenen?
                  beq.b    pp_4_to_4
                  moveq    #0,d0                ;Raster ist nicht wandelbar
                  rts

;2 Ebenen im Standardformat zu 4 Bit mit Packed Pixels wandeln
;Eingaben:
;d4.l Anzahl der Worte - 1
;a0.l Zeiger auf Quellebene 0
;a1.l Zeiger auf Quellebene 1
;a4.l Zeiger auf das Zielraster
;Ausgaben:
;d0.w 1: Raster wurde gewandelt
pp_2_to_4:        move.w   (a0)+,d0             ;Quellebene 0
                  move.w   (a1)+,d1             ;Quellebene 1

                  moveq    #15,d5
pp_2_to_4_exp:    moveq    #0,d6
                  add.w    d1,d1
                  addx.w   d6,d6
                  add.w    d0,d0
                  addx.w   d6,d6
                  cmp.b    #3,d6                ;schwarz?
                  bne.b    pp_2_to_4_nibble
                  move.w   #15,d6
pp_2_to_4_nibble: btst     #0,d5                ;oberes oder unteres Nibble?
                  beq.b    pp_2_to_4_or
                  lsl.w    #4,d6
                  move.b   d6,(a4)              ;oberes Nibble setzen und unteres loeschen
                  bra.b    pp_2_to_4_next
pp_2_to_4_or:     or.b     d6,(a4)+             ;unteres Nibble setzen und ein Byte weiter
pp_2_to_4_next:   dbra     d5,pp_2_to_4_exp

                  subq.l   #1,d4
                  bpl.b    pp_2_to_4
                  moveq    #1,d0                ;Raster wurde gewandelt
                  rts

;4 Ebenen im Standardformat zu 4 Bit mit Packed Pixels wandeln
;Eingaben:
;d4.l Anzahl der Worte - 1
;a0.l Zeiger auf Quellebene 0
;a1.l Zeiger auf Quellebene 1
;a2.l Zeiger auf Quellebene 2
;a3.l Zeiger auf Quellebene 3
;a4.l Zeiger auf das Zielraster
;Ausgaben:
;d0.w 1: Raster wurde gewandelt
pp_4_to_4:        move.w   (a0)+,d0             ;Quellebene 0
                  move.w   (a1)+,d1             ;Quellebene 1
                  move.w   (a2)+,d2             ;Quellebene 2
                  move.w   (a3)+,d3             ;Quellebene 3

                  moveq    #15,d5
pp_4_to_4_exp:    moveq    #0,d6
                  add.w    d3,d3
                  addx.w   d6,d6
                  add.w    d2,d2
                  addx.w   d6,d6
                  add.w    d1,d1
                  addx.w   d6,d6
                  add.w    d0,d0
                  addx.w   d6,d6
                  btst     #0,d5                ;oberes oder unteres Nibble?
                  beq.b    pp_4_to_4_or
                  lsl.l    #4,d6
                  move.b   d6,(a4)              ;oberes Nibble setzen und unteres loeschen
                  bra.b    pp_4_to_4_next
pp_4_to_4_or:     or.b     d6,(a4)+             ;unteres Nibble setzen und ein Byte weiter
pp_4_to_4_next:   dbra     d5,pp_4_to_4_exp

                  subq.l   #1,d4
                  bpl.b    pp_4_to_4
                  moveq    #1,d0                ;Raster wurde gewandelt
                  rts

;Quellraster zu 8 Bit Packed Pixels wandeln
;Eingaben:
;d2.w Anzahl der Ebenen des Quellrasters
;d4.l Anzahl der Worte - 1
;d6.l Laenge von 4 Quellebenen in Bytes
;a0.l Zeiger auf Quellebene 0
;a1.l Zeiger auf Quellebene 1
;a2.l Zeiger auf Quellebene 2
;a3.l Zeiger auf Quellebene 3
;a4.l Zeiger auf das Zielraster
;Ausgaben:
;d0.w 0: Raster kann nicht gewandelt werden 1: Raster wurde gewandelt
xp_pp_8:          subq.w   #2,d2                ;Quellraster mit 2 Ebenen?
                  beq.b    pp_2_to_8
                  subq.w   #2,d2                ;Quellraster mit 4 Ebenen?
                  beq.b    pp_4_to_8
                  subq.w   #4,d2                ;Quellraster mit 8 Ebenen?
                  beq.b    pp_8_to_8
                  moveq    #0,d0                ;Raster ist nicht wandelbar
                  rts

;2 Ebenen im Standardformat zu 8 Bit mit Packed Pixels wandeln
;Eingaben:
;d4.l Anzahl der Worte - 1
;a0.l Zeiger auf Quellebene 0
;a1.l Zeiger auf Quellebene 1
;a4.l Zeiger auf das Zielraster
;Ausgaben:
;d0.w 1: Raster wurde gewandelt
pp_2_to_8:        move.w   (a0)+,d0             ;Quellebene 0
                  move.w   (a1)+,d1             ;Quellebene 1

                  moveq    #15,d5
pp_2_to_8_exp:    moveq    #0,d6
                  add.w    d1,d1
                  addx.w   d6,d6
                  add.w    d0,d0
                  addx.w   d6,d6
                  cmp.b    #3,d6                ;schwarz?
                  bne.b    pp_2_to_8_byte
                  moveq    #$ffffffff,d6
pp_2_to_8_byte:   move.b   d6,(a4)+
                  dbra     d5,pp_2_to_8_exp

                  subq.l   #1,d4
                  bpl.b    pp_2_to_8
                  moveq    #1,d0                ;Raster wurde gewandelt
                  rts

;4 Ebenen im Standardformat zu 8 Bit mit Packed Pixels wandeln
;Eingaben:
;d4.l Anzahl der Worte - 1
;a0.l Zeiger auf Quellebene 0
;a1.l Zeiger auf Quellebene 1
;a2.l Zeiger auf Quellebene 2
;a3.l Zeiger auf Quellebene 3
;a4.l Zeiger auf das Zielraster
;Ausgaben:
;d0.w 1: Raster wurde gewandelt
pp_4_to_8:        move.w   (a0)+,d0             ;Quellebene 0
                  move.w   (a1)+,d1             ;Quellebene 1
                  move.w   (a2)+,d2             ;Quellebene 2
                  move.w   (a3)+,d3             ;Quellebene 3

                  moveq    #15,d5
pp_4_to_8_exp:    moveq    #0,d6
                  add.w    d3,d3
                  addx.w   d6,d6
                  add.w    d2,d2
                  addx.w   d6,d6
                  add.w    d1,d1
                  addx.w   d6,d6
                  add.w    d0,d0
                  addx.w   d6,d6
                  cmp.b    #15,d6               ;schwarz?
                  bne.b    pp_4_to_8_byte
                  moveq    #$ffffffff,d6
pp_4_to_8_byte:   move.b   d6,(a4)+
                  dbra     d5,pp_4_to_8_exp

                  subq.l   #1,d4
                  bpl.b    pp_4_to_8
                  moveq    #1,d0                ;Raster wurde gewandelt
                  rts

;8 Ebenen im Standardformat zu 8 Bit mit Packed Pixels wandeln
;Eingaben:
;d4.l Anzahl der Worte - 1
;d6.l Laenge von 4 Quellebenen in Bytes
;a0.l Zeiger auf Quellebene 0
;a1.l Zeiger auf Quellebene 1
;a2.l Zeiger auf Quellebene 2
;a3.l Zeiger auf Quellebene 3
;a4.l Zeiger auf das Zielraster
;Ausgaben:
;d0.w 1: Raster wurde gewandelt
pp_8_to_8:        move.l   d4,-(sp)
                  move.l   d6,-(sp)

                  move.w   (a0)+,d0             ;Quellebene 0
                  move.w   (a1)+,d1             ;Quellebene 1
                  move.w   (a2)+,d2             ;Quellebene 2
                  move.w   (a3)+,d3             ;Quellebene 3
                  move.w   -2(a0,d6.l),d4       ;Quellebene 4
                  move.w   -2(a1,d6.l),d5       ;Quellebene 5
                  move.w   -2(a3,d6.l),d7       ;Quellebene 7
                  move.w   -2(a2,d6.l),d6       ;Quellebene 6

                  swap     d0
                  swap     d5
                  move.w   #15,d5
pp_8_to_8_exp:    swap     d5
                  clr.w    d0
                  add.w    d7,d7
                  addx.w   d0,d0
                  add.w    d6,d6
                  addx.w   d0,d0
                  add.w    d5,d5
                  addx.w   d0,d0
                  add.w    d4,d4
                  addx.w   d0,d0
                  add.w    d3,d3
                  addx.w   d0,d0
                  add.w    d2,d2
                  addx.w   d0,d0
                  add.w    d1,d1
                  addx.w   d0,d0
                  swap     d0
                  add.w    d0,d0
                  swap     d0
                  addx.w   d0,d0
                  move.b   d0,(a4)+
                  swap     d5
                  dbra     d5,pp_8_to_8_exp

                  move.l   (sp)+,d6
                  move.l   (sp)+,d4
                  subq.l   #1,d4
                  bpl.b    pp_8_to_8
                  moveq    #1,d0                ;Raster wurde gewandelt
                  rts

;Quellraster zu 16 Bit Packed Pixels wandeln
;Eingaben:
;d2.w Anzahl der Ebenen des Quellrasters
;d4.l Anzahl der Worte - 1
;d6.l Laenge von 4 Quellebenen in Bytes
;a0.l Zeiger auf Quellebene 0
;a1.l Zeiger auf Quellebene 1
;a2.l Zeiger auf Quellebene 2
;a3.l Zeiger auf Quellebene 3
;a4.l Zeiger auf das Zielraster
;Ausgaben:
;d0.w 0: Raster kann nicht gewandelt werden 1: Raster wurde gewandelt
xp_pp_16:         movea.l  xp_tab,a5            ;Zeiger auf Expandiertabelle mit 256 Eintraegen
                  subq.w   #2,d2                ;Quellraster mit 2 Ebenen?
                  beq.b    pp_2_to_16
                  subq.w   #2,d2                ;Quellraster mit 4 Ebenen?
                  beq.b    pp_4_to_16
                  subq.w   #4,d2                ;Quellraster mit 8 Ebenen?
                  beq.b    pp_8_to_16
                  moveq    #0,d0                ;Raster ist nicht wandelbar
                  rts

;2 Ebenen im Standardformat zu 16 Bit mit Packed Pixels wandeln
;Eingaben:
;d4.l Anzahl der Worte - 1
;a0.l Zeiger auf Quellebene 0
;a1.l Zeiger auf Quellebene 1
;a4.l Zeiger auf das Zielraster
;a5.l Zeiger auf die Expandiertabelle
;Ausgaben:
;d0.w 1: Raster wurde gewandelt
pp_2_to_16:       move.w   (a0)+,d0             ;Quellebene 0
                  move.w   (a1)+,d1             ;Quellebene 1

                  moveq    #15,d5
pp_2_to_16_exp:   moveq    #0,d6
                  add.w    d1,d1
                  addx.w   d6,d6
                  add.w    d0,d0
                  addx.w   d6,d6
                  cmp.b    #3,d6                ;schwarz?
                  bne.b    pp_2_to_16_word
                  move.w   #255,d6
pp_2_to_16_word:  add.w    d6,d6
                  move.w   (a5,d6.w),(a4)+
                  dbra     d5,pp_2_to_16_exp

                  subq.l   #1,d4
                  bpl.b    pp_2_to_16
                  moveq    #1,d0                ;Raster wurde gewandelt
                  rts

;4 Ebenen im Standardformat zu 16 Bit mit Packed Pixels wandeln
;Eingaben:
;d4.l Anzahl der Worte - 1
;a0.l Zeiger auf Quellebene 0
;a1.l Zeiger auf Quellebene 1
;a2.l Zeiger auf Quellebene 2
;a3.l Zeiger auf Quellebene 3
;a4.l Zeiger auf das Zielraster
;a5.l Zeiger auf die Expandiertabelle
;Ausgaben:
;d0.w 1: Raster wurde gewandelt
pp_4_to_16:       move.w   (a0)+,d0             ;Quellebene 0
                  move.w   (a1)+,d1             ;Quellebene 1
                  move.w   (a2)+,d2             ;Quellebene 2
                  move.w   (a3)+,d3             ;Quellebene 3

                  moveq    #15,d5
pp_4_to_16_exp:   moveq    #0,d6
                  add.w    d3,d3
                  addx.w   d6,d6
                  add.w    d2,d2
                  addx.w   d6,d6
                  add.w    d1,d1
                  addx.w   d6,d6
                  add.w    d0,d0
                  addx.w   d6,d6
                  cmp.b    #15,d6               ;schwarz?
                  bne.b    pp_4_to_16_word
                  move.w   #255,d6
pp_4_to_16_word:  add.w    d6,d6
                  move.w   (a5,d6.w),(a4)+
                  dbra     d5,pp_4_to_16_exp

                  subq.l   #1,d4
                  bpl.b    pp_4_to_16
                  moveq    #1,d0                ;Raster wurde gewandelt
                  rts

;8 Ebenen im Standardformat zu 16 Bit mit Packed Pixels wandeln
;Eingaben:
;d4.l Anzahl der Worte - 1
;d6.l Laenge von 4 Quellebenen in Bytes
;a0.l Zeiger auf Quellebene 0
;a1.l Zeiger auf Quellebene 1
;a2.l Zeiger auf Quellebene 2
;a3.l Zeiger auf Quellebene 3
;a4.l Zeiger auf das Zielraster
;a5.l Zeiger auf die Expandiertabelle
;Ausgaben:
;d0.w 1: Raster wurde gewandelt
pp_8_to_16:       move.l   d4,-(sp)
                  move.l   d6,-(sp)

                  move.w   (a0)+,d0             ;Quellebene 0
                  move.w   (a1)+,d1             ;Quellebene 1
                  move.w   (a2)+,d2             ;Quellebene 2
                  move.w   (a3)+,d3             ;Quellebene 3
                  move.w   -2(a0,d6.l),d4       ;Quellebene 4
                  move.w   -2(a1,d6.l),d5       ;Quellebene 5
                  move.w   -2(a3,d6.l),d7       ;Quellebene 7
                  move.w   -2(a2,d6.l),d6       ;Quellebene 6

                  swap     d0
                  swap     d5
                  move.w   #15,d5
pp_8_to_16_exp:   swap     d5
                  clr.w    d0
                  add.w    d7,d7
                  addx.w   d0,d0
                  add.w    d6,d6
                  addx.w   d0,d0
                  add.w    d5,d5
                  addx.w   d0,d0
                  add.w    d4,d4
                  addx.w   d0,d0
                  add.w    d3,d3
                  addx.w   d0,d0
                  add.w    d2,d2
                  addx.w   d0,d0
                  add.w    d1,d1
                  addx.w   d0,d0
                  swap     d0
                  add.w    d0,d0
                  swap     d0
                  addx.w   d0,d0
                  add.w    d0,d0
                  move.w   (a5,d0.w),(a4)+
                  swap     d5
                  dbra     d5,pp_8_to_16_exp

                  move.l   (sp)+,d6
                  move.l   (sp)+,d4
                  subq.l   #1,d4
                  bpl.b    pp_8_to_16
                  moveq    #1,d0                ;Raster wurde gewandelt
                  rts

;Quellraster zu 24 Bit Packed Pixels wandeln
;Eingaben:
;d2.w Anzahl der Ebenen des Quellrasters
;d4.l Anzahl der Worte - 1
;d6.l Laenge von 4 Quellebenen in Bytes
;a0.l Zeiger auf Quellebene 0
;a1.l Zeiger auf Quellebene 1
;a2.l Zeiger auf Quellebene 2
;a3.l Zeiger auf Quellebene 3
;a4.l Zeiger auf das Zielraster
;a5.l Zeiger auf die Expandiertabelle
;Ausgaben:
;d0.w 0: Raster kann nicht gewandelt werden 1: Raster wurde gewandelt
xp_pp_24:         movea.l  xp_tab,a5            ;Zeiger auf Expandiertabelle mit 256 Eintraegen
                  subq.w   #2,d2                ;Quellraster mit 2 Ebenen?
                  beq.b    pp_2_to_24
                  subq.w   #2,d2                ;Quellraster mit 4 Ebenen?
                  beq.b    pp_4_to_24
                  subq.w   #4,d2                ;Quellraster mit 8 Ebenen?
                  beq.b    pp_8_to_24
                  moveq    #0,d0                ;Raster ist nicht wandelbar
                  rts

;2 Ebenen im Standardformat zu 24 Bit mit Packed Pixels wandeln
;Eingaben:
;d4.l Anzahl der Worte - 1
;a0.l Zeiger auf Quellebene 0
;a1.l Zeiger auf Quellebene 1
;a4.l Zeiger auf das Zielraster
;a5.l Zeiger auf die Expandiertabelle
;Ausgaben:
;d0.w 1: Raster wurde gewandelt
pp_2_to_24:       move.w   (a0)+,d0             ;Quellebene 0
                  move.w   (a1)+,d1             ;Quellebene 1

                  moveq    #15,d5
pp_2_to_24_exp:   moveq    #0,d6
                  add.w    d1,d1
                  addx.w   d6,d6
                  add.w    d0,d0
                  addx.w   d6,d6
                  cmp.b    #3,d6                ;schwarz?
                  bne.b    pp_2_to_24_bbb
                  move.w   #255,d6
pp_2_to_24_bbb:   add.w    d6,d6
                  add.w    d6,d6
                  lea      1(a5,d6.w),a6
                  move.b   (a6)+,(a4)+
                  move.b   (a6)+,(a4)+
                  move.b   (a6)+,(a4)+
                  dbra     d5,pp_2_to_24_exp

                  subq.l   #1,d4
                  bpl.b    pp_2_to_24
                  moveq    #1,d0                ;Raster wurde gewandelt
                  rts

;4 Ebenen im Standardformat zu 24 Bit mit Packed Pixels wandeln
;Eingaben:
;d4.l Anzahl der Worte - 1
;a0.l Zeiger auf Quellebene 0
;a1.l Zeiger auf Quellebene 1
;a2.l Zeiger auf Quellebene 2
;a3.l Zeiger auf Quellebene 3
;a4.l Zeiger auf das Zielraster
;a5.l Zeiger auf die Expandiertabelle
;Ausgaben:
;d0.w 1: Raster wurde gewandelt
pp_4_to_24:       move.w   (a0)+,d0             ;Quellebene 0
                  move.w   (a1)+,d1             ;Quellebene 1
                  move.w   (a2)+,d2             ;Quellebene 2
                  move.w   (a3)+,d3             ;Quellebene 3

                  moveq    #15,d5
pp_4_to_24_exp:   moveq    #0,d6
                  add.w    d3,d3
                  addx.w   d6,d6
                  add.w    d2,d2
                  addx.w   d6,d6
                  add.w    d1,d1
                  addx.w   d6,d6
                  add.w    d0,d0
                  addx.w   d6,d6
                  cmp.b    #15,d6               ;schwarz?
                  bne.b    pp_4_to_24_bbb
                  move.w   #255,d6
pp_4_to_24_bbb:   add.w    d6,d6
                  add.w    d6,d6
                  lea      1(a5,d6.w),a6
                  move.b   (a6)+,(a4)+
                  move.b   (a6)+,(a4)+
                  move.b   (a6)+,(a4)+
                  dbra     d5,pp_4_to_24_exp

                  subq.l   #1,d4
                  bpl.b    pp_4_to_24
                  moveq    #1,d0                ;Raster wurde gewandelt
                  rts

;8 Ebenen im Standardformat zu 24 Bit mit Packed Pixels wandeln
;Eingaben:
;d4.l Anzahl der Worte - 1
;d6.l Laenge von 4 Quellebenen in Bytes
;a0.l Zeiger auf Quellebene 0
;a1.l Zeiger auf Quellebene 1
;a2.l Zeiger auf Quellebene 2
;a3.l Zeiger auf Quellebene 3
;a4.l Zeiger auf das Zielraster
;a5.l Zeiger auf die Expandiertabelle
;Ausgaben:
;d0.w 1: Raster wurde gewandelt
pp_8_to_24:       move.l   d4,-(sp)
                  move.l   d6,-(sp)

                  move.w   (a0)+,d0             ;Quellebene 0
                  move.w   (a1)+,d1             ;Quellebene 1
                  move.w   (a2)+,d2             ;Quellebene 2
                  move.w   (a3)+,d3             ;Quellebene 3
                  move.w   -2(a0,d6.l),d4       ;Quellebene 4
                  move.w   -2(a1,d6.l),d5       ;Quellebene 5
                  move.w   -2(a3,d6.l),d7       ;Quellebene 7
                  move.w   -2(a2,d6.l),d6       ;Quellebene 6

                  swap     d0
                  swap     d5
                  move.w   #15,d5
pp_8_to_24_exp:   swap     d5
                  clr.w    d0
                  add.w    d7,d7
                  addx.w   d0,d0
                  add.w    d6,d6
                  addx.w   d0,d0
                  add.w    d5,d5
                  addx.w   d0,d0
                  add.w    d4,d4
                  addx.w   d0,d0
                  add.w    d3,d3
                  addx.w   d0,d0
                  add.w    d2,d2
                  addx.w   d0,d0
                  add.w    d1,d1
                  addx.w   d0,d0
                  swap     d0
                  add.w    d0,d0
                  swap     d0
                  addx.w   d0,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  lea      1(a5,d0.w),a6
                  move.b   (a6)+,(a4)+
                  move.b   (a6)+,(a4)+
                  move.b   (a6)+,(a4)+
                  swap     d5
                  dbra     d5,pp_8_to_24_exp

                  move.l   (sp)+,d6
                  move.l   (sp)+,d4
                  subq.l   #1,d4
                  bpl.b    pp_8_to_24
                  moveq    #1,d0                ;Raster wurde gewandelt
                  rts

;Quellraster zu 32 Bit Packed Pixels wandeln
;Eingaben:
;d2.w Anzahl der Ebenen des Quellrasters
;d4.l Anzahl der Worte - 1
;d6.l Laenge von 4 Quellebenen in Bytes
;a0.l Zeiger auf Quellebene 0
;a1.l Zeiger auf Quellebene 1
;a2.l Zeiger auf Quellebene 2
;a3.l Zeiger auf Quellebene 3
;a4.l Zeiger auf das Zielraster
;Ausgaben:
;d0.w 0: Raster kann nicht gewandelt werden 1: Raster wurde gewandelt
xp_pp_32:         movea.l  xp_tab,a5            ;Zeiger auf Expandiertabelle mit 256 Eintraegen
                  subq.w   #2,d2                ;Quellraster mit 2 Ebenen?
                  beq.b    pp_2_to_32
                  subq.w   #2,d2                ;Quellraster mit 4 Ebenen?
                  beq.b    pp_4_to_32
                  subq.w   #4,d2                ;Quellraster mit 8 Ebenen?
                  beq.b    pp_8_to_32
                  moveq    #0,d0                ;Raster ist nicht wandelbar
                  rts

;2 Ebenen im Standardformat zu 32 Bit mit Packed Pixels wandeln
;Eingaben:
;d4.l Anzahl der Worte - 1
;a0.l Zeiger auf Quellebene 0
;a1.l Zeiger auf Quellebene 1
;a4.l Zeiger auf das Zielraster
;a5.l Zeiger auf die Expandiertabelle
;Ausgaben:
;d0.w 1: Raster wurde gewandelt
pp_2_to_32:       move.w   (a0)+,d0             ;Quellebene 0
                  move.w   (a1)+,d1             ;Quellebene 1

                  moveq    #15,d5
pp_2_to_32_exp:   moveq    #0,d6
                  add.w    d1,d1
                  addx.w   d6,d6
                  add.w    d0,d0
                  addx.w   d6,d6
                  cmp.b    #3,d6                ;schwarz?
                  bne.b    pp_2_to_32_long
                  move.w   #255,d6
pp_2_to_32_long:  add.w    d6,d6
                  add.w    d6,d6
                  move.l   (a5,d6.w),(a4)+
                  dbra     d5,pp_2_to_32_exp

                  subq.l   #1,d4
                  bpl.b    pp_2_to_32
                  moveq    #1,d0                ;Raster wurde gewandelt
                  rts

;4 Ebenen im Standardformat zu 32 Bit mit Packed Pixels wandeln
;Eingaben:
;d4.l Anzahl der Worte - 1
;a0.l Zeiger auf Quellebene 0
;a1.l Zeiger auf Quellebene 1
;a2.l Zeiger auf Quellebene 2
;a3.l Zeiger auf Quellebene 3
;a4.l Zeiger auf das Zielraster
;a5.l Zeiger auf die Expandiertabelle
;Ausgaben:
;d0.w 1: Raster wurde gewandelt
pp_4_to_32:       move.w   (a0)+,d0             ;Quellebene 0
                  move.w   (a1)+,d1             ;Quellebene 1
                  move.w   (a2)+,d2             ;Quellebene 2
                  move.w   (a3)+,d3             ;Quellebene 3

                  moveq    #15,d5
pp_4_to_32_exp:   moveq    #0,d6
                  add.w    d3,d3
                  addx.w   d6,d6
                  add.w    d2,d2
                  addx.w   d6,d6
                  add.w    d1,d1
                  addx.w   d6,d6
                  add.w    d0,d0
                  addx.w   d6,d6
                  cmp.b    #15,d6               ;schwarz?
                  bne.b    pp_4_to_32_long
                  move.w   #255,d6
pp_4_to_32_long:  add.w    d6,d6
                  add.w    d6,d6
                  move.l   (a5,d6.w),(a4)+
                  dbra     d5,pp_4_to_32_exp

                  subq.l   #1,d4
                  bpl.b    pp_4_to_32
                  moveq    #1,d0                ;Raster wurde gewandelt
                  rts

;8 Ebenen im Standardformat zu 32 Bit mit Packed Pixels wandeln
;Eingaben:
;d4.l Anzahl der Worte - 1
;d6.l Laenge von 4 Quellebenen in Bytes
;a0.l Zeiger auf Quellebene 0
;a1.l Zeiger auf Quellebene 1
;a2.l Zeiger auf Quellebene 2
;a3.l Zeiger auf Quellebene 3
;a4.l Zeiger auf das Zielraster
;a5.l Zeiger auf die Expandiertabelle
;Ausgaben:
;d0.w 1: Raster wurde gewandelt
pp_8_to_32:       move.l   d4,-(sp)
                  move.l   d6,-(sp)

                  move.w   (a0)+,d0             ;Quellebene 0
                  move.w   (a1)+,d1             ;Quellebene 1
                  move.w   (a2)+,d2             ;Quellebene 2
                  move.w   (a3)+,d3             ;Quellebene 3
                  move.w   -2(a0,d6.l),d4       ;Quellebene 4
                  move.w   -2(a1,d6.l),d5       ;Quellebene 5
                  move.w   -2(a3,d6.l),d7       ;Quellebene 7
                  move.w   -2(a2,d6.l),d6       ;Quellebene 6

                  swap     d0
                  swap     d5
                  move.w   #15,d5               ;16 Pixel bearbeiten
pp_8_to_32_exp:   swap     d5
                  clr.w    d0
                  add.w    d7,d7
                  addx.w   d0,d0
                  add.w    d6,d6
                  addx.w   d0,d0
                  add.w    d5,d5
                  addx.w   d0,d0
                  add.w    d4,d4
                  addx.w   d0,d0
                  add.w    d3,d3
                  addx.w   d0,d0
                  add.w    d2,d2
                  addx.w   d0,d0
                  add.w    d1,d1
                  addx.w   d0,d0
                  swap     d0
                  add.w    d0,d0
                  swap     d0
                  addx.w   d0,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   (a5,d0.w),(a4)+
                  swap     d5
                  dbra     d5,pp_8_to_32_exp

                  move.l   (sp)+,d6
                  move.l   (sp)+,d4
                  subq.l   #1,d4
                  bpl.b    pp_8_to_32
xp_dummy:
                  moveq    #1,d0                ;Raster wurde gewandelt
                  rts

xp_unknown:       moveq    #0,d0                ;Raster ist nicht wandelbar
                  rts


;EdDI-Cookie suchen
;Vorgaben:
;Register d0-d2/a0-a1 koennen veraendert werden
;Eingaben:
;-
;Ausgaben:
;d0.w 0: kein Cookie 1: EdDI-Cookie vorhanden
srchEdDI:         move.l   #'EdDI',d0
                  bsr.b    search_cookie
                  tst.l    d0
                  beq.b    search_EdDI_err

                  moveq    #1,d0                ;Cookie gefunden
                  rts

search_EdDI_err:  moveq    #0,d0                ;Cookie nicht gefunden
                  rts

;Cookie suchen
;Vorgaben:
;Register d0-d2/a0 werden veraendert
;Eingaben:
;d0.l Cookie-ID
;Ausgaben:
;d0.l Cookie-ID oder 0 (Suche fehlgeschlagen)
;d1.l Cookie-Daten oder 0 (Suche fehlgeschlagen)
search_cookie:    move.l   p_cookies.w,d2       ;Zeiger auf die Cookies
                  beq.b    search_ck_err        ;keine Cookies?
                  movea.l  d2,a0
search_ck_loop:   move.l   (a0)+,d2             ;Cookie-ID
                  beq.b    search_ck_err
                  move.l   (a0)+,d1             ;Daten
                  cmp.l    d0,d2                ;gefunden?
                  bne.b    search_ck_loop
                  rts
search_ck_err:    clr.l    d0                   ;keine Cookies
                  clr.l    d1
                  rts


;LONG    W_mul_L( UWORD a, UWORD b );
W_mul_L:          mulu     d1,d0
                  rts

;WORD    L_div_W( ULONG a, UWORD b );
L_div_W:          divu     d1,d0
                  rts

