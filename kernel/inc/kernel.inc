
     XREF act_appl
     XREF act_pd
     XREF appl_yield
     XREF appl_begcritic
     XREF appl_endcritic
     XREF evnt_sem
     XREF evnt_IO

SUPERSTACKLEN  EQU  8192           ; Supervisorstack pro Applikation
NDRVS          EQU  26             ; Anzahl logische Laufwerke
MIN_OPEN       EQU  6              ; 0..MIN_OPEN-1 sind reserviert
MAX_OPEN       EQU  32             ; Größte Handlenummer-1 (0..31)
MIN_FHANDLE    EQU  -4             ; kleinstes DateiHandle

     OFFSET

bl_cnt:        DS.W 1
bl_app:        DS.L 1
bl_waiting:    DS.L 1
bl_pd:         DS.L 1
bl_name:       DS.L 1
bl_next:       DS.L 1
bl_sizeof:

     TEXT

SEM_FREE       EQU  0
SEM_SET        EQU  1
SEM_TEST       EQU  2
SEM_CSET       EQU  3
SEM_GET        EQU  4
SEM_CREATE     EQU  5
SEM_DEL        EQU  6
SEM_FALL       EQU  7
SEM_FPD        EQU  8

/* Werte für p_status (ab MagiC 5.04) */

PROCSTATE_MAGIC     EQU  0    ; Prozeß nach Terminierung entfernen (MagiC)
PROCSTATE_MINT      EQU  1    ; Prozeß nach Terminierung halten, wenn der
                              ; parent existiert (MiNT). Wird bei
                              ; Pexec(100,104,106) verwendet.
PROCSTATE_ZOMBIE    EQU  2    ; Prozeß, der PROCSTATE_MINT war, ist
                              ; terminiert, aber der Parent hat noch kein
                              ; Pwaitpid() gemacht. Die Basepage (128 Bytes)
                              ; gehört dem Bootprozeß.
                              ; p_dta.w enthält den Exit-Code

     OFFSET

sa_handler:    DS.L      1    /* 0x00: Signalhandler */
sa_sigextra:   DS.L      1    /* 0x04: OR-Maske bei Ausführung des Signals */
sa_flags:      DS.W      1
sa_sizeof:

/* erweiterte Prozeßdaten (PROCDATA) */
     OFFSET

fh_fd:         DS.L      1
fh_flag:       DS.W      1
fh_sizeof:

     OFFSET

pr_magic:      DS.L      1    /* magischer Wert, ähnlich wie bei MiNT      */
pr_ruid:       DS.W      1    /* "real user ID" */
pr_rgid:       DS.W      1    /* "real group ID" */
pr_euid:       DS.W      1    /* "effective user ID" */
pr_egid:       DS.W      1    /* "effective group ID" */
pr_suid:       DS.W      1    /* "saved user ID" */
pr_sgid:       DS.W      1    /* "saved group ID" */
pr_auid:       DS.W      1    /* "audit user ID" */
pr_pri:        DS.W      1    /* "base process priority" (nur dummy) */
pr_sigpending: DS.L      1    /* wartende Signale                          */
pr_sigmask:    DS.L      1    /* Signalmaske                               */
pr_sigdata:    DS.B      32*sa_sizeof
pr_usrval:     DS.L      1    /* "User"-Wert (ab 9/96)                     */
pr_memlist:    DS.L      1    /* Tabelle der "shared memory blocks"        */
pr_fname:      DS.B      128  /* Pfad der zugehörigen PRG-Datei            */
pr_cmdlin:     DS.B      128  /* Ursprüngliche Kommandozeile               */
pr_flags:      DS.W      1    /* Bit 0: kein Eintrag in u:\proc            */
                              /* Bit 1: durch Pfork() erzeugt              */
pr_procname:   DS.B      10   /* Prozeßname für u:\proc\ ohne Ext.         */
pr_bconmap:    DS.W      1    /* z.Zt. unbenutzt                           */
pr_hndm6:      DS.B      fh_sizeof /* Handle -6: unbenutzt */
pr_hndm5:      DS.B      fh_sizeof /* Handle -5: unbenutzt */
pr_hndm4:      DS.B      fh_sizeof /* Handle -4: standardmäßig NUL: */
pr_hndm3:      DS.B      fh_sizeof /* Handle -3: standardmäßig PRN: */
pr_hndm2:      DS.B      fh_sizeof /* Handle -2: standardmäßig AUX: */
pr_hndm1:      DS.B      fh_sizeof /* Handle -1: standardmäßig CON: */
pr_handle:     DS.B      MAX_OPEN*fh_sizeof  /* Handles 0..31 */
pr_sizeof:

     TEXT

ap_buflen EQU  $300           ; 768 Bytes Messagepuffer (= 48 Nachrichten)

     OFFSET

ap_next:       DS.L 1         ; Verkettungszeiger
ap_id:         DS.W 1         ; Application-ID
ap_parent:     DS.W 1         ; tatsächliche parent-ID
ap_parent2:    DS.W 1         ; ggf. die ap_id des VT52, dorthin ->CH_EXIT
ap_type:       DS.W 1         ; 0 = Main Thread/1 = Thread/2 = Signal Handler
ap_oldsigmask: DS.L 1         ; Alte Signalmaske (für Signal-Handler)
ap_sigthr:     DS.L 1         ; Haupt-Thread: Zeiger auf aktiven Signalhandler
                              ; Signalhandler: Zeiger auf vorherigen oder NULL
ap_srchflg:    DS.W 1         ; für appl_search
ap_menutree:   DS.L 1         ; Menübaum
ap_attached:   DS.L 1         ; NULL oder Liste für menu_attach()
ap_desktree:   DS.L 1         ; Desktop-Hintergrund
ap_1stob:      DS.W 1         ;  dazu erstes Objekt
ap_dummy1:     DS.B 2         ; zwei Leerzeichen vor ap_name
ap_name:       DS.B 8         ; Name (8 Zeichen mit trailing blanks)
ap_dummy2:     DS.B 2         ; Leerstelle und ggf. Ausblendzeichen
ap_dummy3:     DS.B 1         ; Nullbyte für EOS
ap_status:     DS.B 1         ; APSTAT_...
ap_hbits:      DS.W 1         ; eingetroffene Events
ap_rbits:      DS.W 1         ; erwartete Events
ap_evparm:     DS.L 1         ; Event-Daten, z.B. <pid> oder msg-Puffer
ap_nxttim:     DS.L 1         ; Nächste auf Timer wartende APP
ap_ms:         DS.L 1         ; Timer
ap_nxtalrm:    DS.L 1         ; Nächste auf Alarm wartende APP
ap_alrmms:     DS.L 1         ; Alarm
ap_isalarm:    DS.W 1         ; Flag
ap_nxtsem:     DS.L 1         ; Nächste auf Semaphore wartende APP
ap_semaph:     DS.L 1         ; auf diese Semaphore warten wir
ap_unselcnt:   DS.W 1         ; Länge der Tabelle ap_unselx
ap_unselx:     DS.L 1         ; Tabelle für evnt_(m)IO
ap_evbut:      DS.L 1         ; für evnt_button
ap_mgrect1:    DS.L 1         ; für evnt_mouse
ap_mgrect2:    DS.L 1         ; für evnt_mouse
ap_kbbuf:      DS.W 8         ; Puffer für 8 Tasten
ap_kbhead:     DS.W 1         ; Nächstes zu lesendes Zeichen
ap_kbtail:     DS.W 1         ; Nächstes zu schreibendes Zeichen
ap_kbcnt:      DS.W 1         ; Anzahl Zeichen im Puffer
ap_len:        DS.W 1         ; Message- Pufferlänge
ap_buf:        DS.B ap_buflen ; Message- Puffer (256 Bytes)
ap_critic:     DS.W 1         ; Zähler für "kritische Phase"
ap_crit_act:   DS.B 1         ; Bit 0: killed
                              ; Bit 1: stopped
                              ; Bit 2: Signale testen
ap_stpsig:     DS.B 1         ; Flag "durch Signal gestoppt"
ap_sigfreeze:  DS.L 1         ; Signalhandler für SIGFREEZE
ap_recogn:     DS.W 1         ; Bit 0: verstehe AP_TERM
ap_flags:      DS.L 1         ; Bit 0: will keinen prop. AES-Zeichensatz
ap_doex:       DS.W 1
ap_isgr:       DS.W 1
ap_wasgr:      DS.W 1
ap_isover:     DS.W 1
ap_ldpd:       DS.L 1         ; PD des Loader-Prozesses
ap_env:        DS.L 1         ; Environment oder NULL
ap_xtail:      DS.L 1         ; Erw. Kommandozeile (> 128 Bytes) od. NULL
ap_thr_usp:    DS.L 1         ; usp für Threads
ap_memlimit:   DS.L 1
ap_nice:       DS.L 1         ; z.Zt. unbenutzt
ap_cmd:        DS.B 128       ; Programmpfad
ap_tail:       DS.B 128       ; Programmparameter

ap_mhidecnt:   DS.W 1         ; lokaler Maus-Hide-Counter
ap_svd_mouse:  DS.W 37        ; x/y/planes/bg/fg/msk[32]/moff_cnt
ap_prv_mouse:  DS.W 37
ap_act_mouse:  DS.W 37

ap_ssp:        DS.L 1
ap_pd:         DS.L 1
ap_etvterm:    DS.L 1
ap_stkchk:     DS.L 1              ; magisches Wort für Stacküberprüfung
ap_stack:

/* Werte für ap_status */

APSTAT_READY        EQU  0
APSTAT_WAITING      EQU  1
APSTAT_SUSPENDED    EQU  2
APSTAT_ZOMBIE       EQU  3
APSTAT_STOPPED      EQU  4

/* Für Psignal */

SIGFREEZE      EQU  100
SIG_DFL        EQU  0
SIG_IGN        EQU  1

SIGKILL        EQU  9         /* cannot be ignored */
SIGPIPE        EQU  13        /* broken pipe */
SIGALRM        EQU  14        /* eingetroffener Alarm */
SIGTERM        EQU  15        /* software termination signal */
SIGSTOP        EQU  17        /* stop signal not from terminal */
SIGTSTP        EQU  18        /* stop signal from terminal */
SIGCONT        EQU  19        /* continue stopped process */
SIGCHLD        EQU  20        /* child stopped or exited */
SIGTTIN        EQU  21        /* read by background process */
SIGTTOU        EQU  22        /* write by background process */

STOPSIGS       EQU  0x00660000     /* SIGTTIN, SIGTTOU, SIGTSTP, SIGSTOP */
UNMASKABLE     EQU  0x000a0201     /* SIGNULL, SIGKILL,SIGCONT,SIGSTOP */
MASKWHILESTOP  EQU  !(UNMASKABLE+0x8000)     /* SIGTERM nicht maskieren */

     TEXT
