* VDI-Substitut für MagiX MAC
* ***************************

     XDEF      vdi_conout          ; VDI: Bconout(CON)
     XDEF      vdi_rawout          ; VDI: Bconout(RAWCON)
     XDEF      vdi_cursor          ; VDI: Cursorblinken
     XDEF      int_linea           ; VDI: LineA- Interrupt
     XDEF      Blitmode            ; VDI
     XDEF      vt_seq_e            ; VDI: Cursor ein
     XDEF      vt_seq_f            ; VDI: Cursor aus
     XDEF      vdi_init            ; VDI: initialisieren (für MXVDI)
     XDEF      vdi_blinit          ; VDI: Blitterstatus initialisieren (d0)
     XDEF      vt52_init           ; VDI: VT52 initialisieren
     XDEF      __e_vdi             ; VDI: Ende der Variablen

     XDEF      vdi_entry           ; nach DOS
     XREF      Mac_oltrap2         ; vom BIOS

     SUPER
     TEXT

__e_vdi   EQU  $28d6

vdi_entry:
 rts

vdi_conout:
 lea      6(sp),a0
 rts

vdi_rawout:
 lea      6(sp),a0
 rts

vdi_cursor:
 rts

int_linea:
 rte

Blitmode:
 moveq    #0,d0
 rte

vt_seq_e:
vt_seq_f:
 rts

*
* wird VOR dos_init aufgerufen
*

vdi_blinit:
 move.l   $88,Mac_oltrap2          ; Trap #2 retten
 rts

vt52_init:
 rts

*
* wird NACH dos_init aufgerufen
*

vdi_init:
 move.l   Mac_oltrap2,$88          ; Trap #2 zurück
 rts

     END

