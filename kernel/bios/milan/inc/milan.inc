;
; Milan-spezifische Header-Datei
; Andreas Kromke, 1999
;

MILAN_ROM      EQU  $e00000

     OFFSET

osh_shortbranch:         DS.W 1
osh_version:             DS.W 1
osh_startadr:            DS.L 1
osh_syshdr:              DS.L 1
osh_begin_ram:           DS.L 1
osh_ptr:                 DS.L 1
osh_gem_magics:          DS.L 1
osh_us_date_bcd:         DS.L 1
osh_countrycode_palflag: DS.W 1
osh_gemdos_date:         DS.W 1
osh_mifl:                DS.L 1
osh_pkbshift:            DS.L 1
osh_pact_pd:             DS.L 1
osh_zero:                DS.L 1
/* notwendig, damit jmp MILAN_ROM funktioniert */
osh_milan_resvd:         DS.W 4
/* Ab hier die Erweiterung: */
osh_milan_magic:         DS.L 1    /* Muss z.B. 'Miln' sein */
osh_milan_os:            DS.L 1    /* Zeiger auf die Uebergabestruktur */

     OFFSET

milh_version:            DS.L 1    /* zunaechst 0 */
milh_meminfo:            DS.L 1    /* Informationen ueber Speicherbloecke */
milh_bios_fnx:           DS.L 1    /* Tabelle der BIOS-Funktionen */
milh_xbios_fnx:          DS.L 1    /* Tabelle der XBIOS-Funktionen */
milh_devvecs:            DS.L 1    /* Tabelle der Geraetevektoren */
milh_ihdvvecs:           DS.L 1    /* hdv_xxx initialisieren */
milh_iexcvecs:           DS.L 1    /* HBL/VBL initialisieren */
milh_iperiph:            DS.L 1    /* Peripherie/-vektoren initialisieren */
milh_dmaboot:            DS.L 1    /* von HD booten */
milh_coldboot:           DS.L 1    /* Kaltstart */
milh_init_maptab:        DS.L 1    /* fuer Bconmap */
milh_prn_wrts:           DS.L 1    /* mehrere Zeichen auf Prn */
milh_hdl_pling:          DS.L 1    /* "Hook" fuer Glocke */
milh_hdl_klick:          DS.L 1    /* "Hook" fuer Tastaturklick */
milh_pncookies:          DS.L 1    /* Anzahl maschinenspez. Cookies */
milh_inst_cookies:       DS.L 1    /* machinenspez. Cookies installieren */
milh_get_cpu:            DS.L 1    /* CPU-Typ ermitteln */
milh_get_fpu:            DS.L 1    /* FPU-Typ ermitteln */
milh_gethtime:           DS.L 1    /* Urzeit/Datum ermitteln */
milh_vblhook:            DS.L 1    /* Fuer MagiC-VBL-Interrupt */
milh_iinit_hz200:        DS.L 1    /* Fuer MagiC-Interrupt hz_200 */
milh_exit_hz200:         DS.L 1
milh_iinit_ikbd:         DS.L 1    /* Fuer MagiC-Interrupt IKBD */
milh_exit_ikbd:          DS.L 1
milh_dosound:            DS.L 1    /* wird mit 50Hz aufgerufen */
milh_autopacks:          DS.L 1    /* PKGs im Flash starten */
milh_init_cpu1:          DS.L 1    /* CPU-"Roh"-Initialisierung */
milh_init_cpu2:          DS.L 1    /* CPU-"Fein"-Initialisierung (cache an) */
milh_gsx_entry:          DS.L 1    /* VDI-Einsprung */
milh_frb_adr:            DS.L 1    /* Adresse der FRB-Adresse */
milh_prtbombs:           DS.L 1    /* Parameter: (a3 = sp, a4 = PD *) */
milh_caps_led:           DS.L 1    /* Parameter: d0 = kbshift */
milh_reserved:           DS.L 19   /* alle NULL */

     OFFSET

meminfo_len:             DS.W 1    /* Laenge der folgenden Tabelle */
meminfo_memadr:          DS.L 1
meminfo_memlen:          DS.L 1

     TEXT
