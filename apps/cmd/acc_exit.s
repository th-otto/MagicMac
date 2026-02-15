* Zuallererst Cursor ausschalten
 clr.w    -(sp)
 xbios    Cursconf
 addq.l   #4,sp
* Oberste Interrupt- Stack- Werte rÅcksetzen
* (AES - Fehler korrigieren)
 move.b   d+isxaes(pc),d0
 bne.b    ini_isxaes3
 move.w   intssp(pc),a1
 moveq    #20-1,d0
 lea      d+evnt_ret(pc),a0
ini_menurett:
 move.l   (a0)+,-(a1)
 dbra     d0,ini_menurett
* Bildschirmspeicher (MenÅleiste) restaurieren
ini_isxaes3:
err3:
 xbios    Physbase
 addq.l   #2,sp
 move.l   d0,a0
 lea      d+screenbuf(pc),a1
 move.w   #ZEILEN*20-1,d0
ini_menurst:
 move.l   (a1)+,(a0)+
 dbra     d0,ini_menurst


** wind_close(whdl);
err2:
 lea      d+intin(pc),a0
 move.w   d+whdl(pc),(a0)
 M_wind_close

** wind_delete(whdl);
err1:
 lea      d+intin(pc),a0
 move.w   d+whdl(pc),(a0)
 M_wind_delete

** wind_update(FALSE);
err:
 lea      d+intin(pc),a0
 clr.w    (a0)
 M_wind_update

* Maus einschalten
 bsr      mouse

* Wir melden uns als aktueller Prozeû wieder ab
 move.b   d+isxaes(pc),d0
 bne.b    ini_isxaes4
 move.l   _run(pc),a0
 lea      _base+$24(pc),a1
 move.l   (a1),(a0)                * Hauptapp als aktueller Prozeû
 clr.l    (a1)                     * kein Elter
ini_isxaes4:
 bra      again
