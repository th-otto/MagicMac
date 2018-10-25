
;OSHEADER structure
os_version     EQU  2
os_start       EQU  4
os_base        EQU  8
os_membot      EQU  $c
os_shell       EQU  $10
os_magic       EQU  $14
os_gendat      EQU  $18
os_palmode     EQU  $1c
os_gendatg     EQU  $1e
os_root        EQU  $20
os_kbshift     EQU  $24
os_run         EQU  $28

;IOREC structure
ibuf              EQU 0
ibufsiz           EQU 4
ibufhd            EQU 6
ibuftl            EQU 8
ibuflow           EQU 10
ibufhi            EQU 12

;Funktionsnummern
FLOPRD         EQU  8
FLOPWR         EQU  9
FLOPFMT        EQU  10
FLOPVER        EQU  19
FLOPRATE       EQU  41
DMAREAD        EQU  42
DMAWRITE       EQU  43

;--------------------------------------------------------------
;
; BIOS- Variablen:

deflt_env           EQU  $840           /* char deflt_env[40]         */
ext_scsidrivr       EQU  $868           ; (L) Init-Zeiger auf SE-SCSI-Treiber
                                        ; belegt die unteren vier Bytes
                                        ; der savptr_area!
;
; saveptr_area bleibt aus Kompatiblitaetsgruenden (Matrix Grafiksoft.) bestehen,
; wird aber von (X)Bios nicht benutzt
savptr_area         EQU  $93a           /* int  savptr_area[105],ende */

jmpcode             EQU  $93a           /* int  jmpcode[3]            */
ram_syshdr          EQU  $940           /* SYSHDR ram_syshdr          */

* ## unbenutzt. Ab <clear_area> werden beim Warmstart 64 kB geloescht
*               im Original- TOS ab $980

xaes_area           EQU  $980           /* long xaes_area[3]          */
/* p_vt52_winlst zeigt auf das Array WINDOW *app_window[128].         */
/* Ist unter der Applikationsnummer id ein TOS-Programm im VT52 am    */
/* Laufen, so zeigt app_window[id] auf die zugehoerige Fensterstruktur */
/* Andernfalls enthaelt app_window[id] NULL.                           */
/* Die nachfolgenden Variablen werden im VT52.PRG in der Funktion     */
/* <void set_vec()> initialisiert.                                    */
p_vt52_winlst       EQU $98c            /* WINDOW   **p_vt52_winlst;  */
p_vt_interior_off   EQU $990            /* Offset zur Variable INTERIOR interior  */
p_vt_columns_off    EQU $992            /* Offset zur Variable WORD columns       */
p_vt_rows_off       EQU $994            /* Offset zur Variable WORD rows */
p_vt_visible_off    EQU $996            /* Offset zur Variable WORD visible_rows  */
p_vt_x_off          EQU $998            /* Offset zur Variable WORD x */
p_vt_y_off          EQU $99a            /* Offset zur Variable WORD y */
p_vt_sout           EQU $99c            /* Adresse der cooked_str_to_con-Routine */
p_vt_cin            EQU $9a0            /* Adresse der c_in_cooked-Routine */

