*    OFFSET $29f0
__a_dos        EQU  $2900

N_STDPATHS     EQU  40             ; Anzahl der Standardpfade
LASTDRIVE      EQU  'Z'-'A'        ; hoechste Laufwerknummer

     XDEF  __a_dos

     OFFSET __a_dos

otimer:        DS.L 1              ; alte etv_timer Routine
otrap2:        DS.L 1              ; alte Trap #2- Routine
last_ms:       DS.W 1              ; ms seit letztem Stellen der Uhr
dos_time:      DS.W 1              ; Zeit im DOS- Format
dos_date:      DS.W 1              ; Wort mit Datum im DOS- Format
xaes_appls:    DS.L 1              ; hier haengt sich XAES ein
mem_root:      DS.L 16             ; 16 Speicherlisten (ST-RAM, TT-RAM, ...)
               DS.L 16             ; Endadressen fuer vorherige Bloecke
_mifl_unused:
undo_buf:      DS.B 320            ; fuer Zeileneditor
     EVEN

imbx:          DS.L 1              ; Zeiger auf IMB- Kette

dev_fds:       DS.L -MIN_FHANDLE   ; FDs fuer Handles -4/-3/-2/-1

dskchg_drvs:   DS.L 1              ; Bitvektor der zu wechselnden Disks
dskchg_sem:    DS.B bl_sizeof      ; Semaphore fuer den Diskwechsel
pexec_sem:     DS.B bl_sizeof      ; Semaphore fuer Pexec
fat12_sem:     DS.B bl_sizeof      ; Semaphore fuer 12-Bit-FAT

bufl:          DS.L 2              ; neue Mag!X- Sektor-Pufferlisten
bufl_size:     DS.L 1              ; Groesse der installierten Puffer
bufl_timer:    DS.L LASTDRIVE+1    ; fuer Writeback (letzter Zugriff)
bufl_wback:    DS.L 1              ; PD *, initiiert writeback
p_doslimits:   DS.L 1              ; Zeiger auf DOSLIMIT-Struktur

act_pd:        DS.L 1              ; aktueller PD
pathx:         DS.L N_STDPATHS     ; Tabelle der 40 Standard- DDs
pathcntx:      DS.B N_STDPATHS     ; Referenzzaehler fuer pathx
dmdx:          DS.L LASTDRIVE+1    ; Tabelle der DMDs
dlockx:        DS.L LASTDRIVE+1    ; Laufwerk- Sperren
nxt_procid:    DS.W 1              ; naechste freie Prozess-ID
procx:         DS.L 1              ; Tabelle der Prozesse
xfs_list:      DS.L 1              ; Tabelle der Dateisysteme
lslb_list:     DS.L 1              ; Liste der geladenen SharedLibs

/* Variablen fuers DOS-XFS */

dfs_list:      DS.L 1              ; Tabelle der DOS- Dateisysteme
dfs_longnames: DS.L 1              ; Bitvektor drv <-> lange Dateinamen

/* Variablen fuers Laufwerk U: */

udrv_drvs:     DS.L 1              ; eingetragene Laufwerk A,B,..
udrv_root:     DS.L 1
udrv_shmdir:   DS.L 1
udrv_devdir:   DS.L 1
udrv_pipedir:  DS.L 1
udrv_procdir:  DS.L 1

ur_pd:         DS.B 256            ; Ur-PD
__e_dos:

