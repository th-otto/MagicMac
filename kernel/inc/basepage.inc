/* Basepage */
     OFFSET 0

p_lowtpa:      DS.L      1    /* 0x00: Beginn TPA, des BP selbst           */
p_hitpa:       DS.L      1    /* 0x04: zeigt 1 Byte hinter TPA             */
p_tbase:       DS.L      1    /* 0x08: Beginn des TEXT - Segments          */
p_tlen:        DS.L      1    /* 0x0c: Länge  des TEXT - Segments          */
p_dbase:       DS.L      1    /* 0x10: Beginn des DATA - Segments          */
p_dlen:        DS.L      1    /* 0x14: Länge  des DATA - Segments          */
p_bbase:       DS.L      1    /* 0x18: Beginn des BSS  - Segments          */
p_blen:        DS.L      1    /* 0x1c: Länge  des BSS  - Segments          */
p_dta:         DS.L      1    /* 0x20: Aktueller DTA- Puffer               */
p_parent:      DS.L      1    /* 0x24: Zeiger auf BP des Parent            */
p_procid:      DS.W      1    /* 0x28: Prozeß- ID                          */
p_status:      DS.W      1    /* 0x2a: ab MagiC 5.04                       */
p_env:         DS.L      1    /* 0x2c: Zeiger auf Environment              */
p_devx:        DS.B      6    /* 0x30: std-Handle <=> phs. Handle          */
p_flags:       DS.B      1    /* 0x36: Bit 0: Pdomain (MiNT:1/TOS:0)       */
p_defdrv:      DS.B      1    /* 0x37: Default- Laufwerk                   */
p_res3:        DS.B      8    /* 0x38: Terminierungskontext für ACC        */
p_drvx:        DS.B     32    /* 0x40: Tabelle: Default-Path-Hdl.          */
p_procdata:    DS.L      1    /* 0x60: Zeiger auf PROCDATA                 */
p_umask:       DS.W      1    /* 0x64: umask für Unix-Dateisysteme         */
p_procgroup:   DS.W      1    /* 0x66: Prozeßgruppe (ab 6.10.96)           */
p_mem:         DS.L      1    /* 0x68: soviel Speicher darf ich holen      */
p_context:     DS.L      1    /* 0x6c: unter MAGIX statt p_reg benutzt     */
p_mflags:      DS.L      1    /* 0x70: Bit 2: Malloc aus AltRAM erlaubt    */
p_app:         DS.L      1    /* 0x74: APPL, die den Prozeß gestartet hat (main thread)   */
p_ssp:         DS.L      1    /* 0x78: ssp bei Start des Prozesses         */
p_reg:         DS.L      1    /* 0x7c: für Kompatibilität mit TOS          */
p_cmdlin:      DS.B    128    /* 0x80: Kommandozeile                       */

