AESVARS_magic           EQU 0           ;muss $87654321 sein
AESVARS_membot          EQU 4           ;Ende der AES- Variablen
AESVARS_aes_start       EQU 8           ;Startadresse
AESVARS_magic2          EQU 12          ;ist 'MAGX' oder 'KAOS'
AESVARS_date            EQU 16          ;Erstelldatum
AESVARS_chgres          EQU 20          ;Aufloesung aendern
AESVARS_shel_vector     EQU 24          ;ROM- Desktop
AESVARS_aes_bootdrv     EQU 28          ;Hierhin kommt DESKTOP.INF
AESVARS_vdi_device      EQU 32          ;vom AES benutzter Treiber
AESVARS_nvdi_wstation   EQU 36          ;vom AES benutzte Workstation
AESVARS_shelw_doex      EQU 40
AESVARS_shelw_isgr      EQU 44
AESVARS_version         EQU 48          ;Versionsnummer
AESVARS_release         EQU 50
AESVARS_basepage        EQU 52
AESVARS_moff_cnt        EQU 56
AESVARS_shel_buf_len    EQU 60
AESVARS_shel_buf        EQU 64
AESVARS_notready_list   EQU 68
AESVARS_menu_app        EQU 72
AESVARS_menutree        EQU 76
AESVARS_desktree        EQU 80
AESVARS_desktree_1stob  EQU 84
AESVARS_dos_magic       EQU 88
AESVARS_maxwindn        EQU 92
AESVARS_p_fsel          EQU 96
AESVARS_ctrl_timeslice  EQU 100
AESVARS_idrive          EQU 120         ;Installationslaufwerk (fuer Treiber un GEMSYS)

