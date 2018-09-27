/* ----------- Schnittstellen-Nachrichten -------------------------------------*/

#define KOBOLD_JOB 0x2F10          /* Speicherjob starten                      */
#define KOBOLD_JOB_NO_WINDOW 0x2F11/* Dito, ohne Hauptdialog                   */

#define KOBOLD_ANSWER 0x2F12       /* Antwort vom KOBOLD mit Status in Wort 3  */
                                   /* und Zeile in Wort 4                      */

#define KOBOLD_CONFIG 0x2F13       /* Konfiguration erfragen. Dazu muû in Wort */
                                   /* 3 & 4 ein Zeiger auf eine KOBOLD_CONFIGU-*/
                                   /* RATION Struktur Åbergeben werden.        */

#define KOBOLD_FIRST_SLCT 0x2F14   /* Erfragt die aktuelle Selektion im Quell- */
#define KOBOLD_NEXT_SLCT 0x2F15    /* fenster. Mit ..FIRST.. erhÑlt man das    */
                                   /* erste Objekt, mit ..NEXT.. alle weiteren.*/
                                   /* In Wort 3 & 4 muû ein Zeiger auf einen   */
                                   /* 128 Bytes langen Speicherbereich Åber-   */
                                   /* geben werden (unter MultiTos als 'global'*/
                                   /* alloziert!), in den der komplette Pfad   */
                                   /* geschrieben wird. In der KOBOLD_ANSWER   */
                                   /* steht in Wort 3:                         */
                                   /*      -1: Keine weiteren Objekte          */
                                   /*       0: Objekt ist eine Datei           */
                                   /*       1: Objekt ist ein Ordner           */

#define KOBOLD_CLOSE 0x2F16        /* Dient zum expliziten Schlieûen des       */
                                   /* KOBOLD, falls Antwortstatus != FINISHED  */

#define KOBOLD_FREE_DRIVES 0x2F17   /* Gibt evt. belegte Laufwerke frei und     */
                                    /* lîscht eingelesene Verzeichnisse         */

/*-----------------------------------------------------------------------------*/
/* Ein Zeiger auf die folgende Struktur muû dem Kobold in Wort 3+4 des
Message-Puffers fÅr den Code KOBOLD_CONFIG Åbergeben werden. Die entsprechende
Speicherstruktur muû unter MultiTos fÅr andere Prozesse als beschreibbar
('global') alloziert werden (Mxalloc(size,0x1mode)). Kobold fÅllt dann die
Daten auf und teilt mit einer KOBOLD_ANSWER Message die Beendigung mit.      */

typedef struct
{
    unsigned int 
        version,                    /* Version, z.B. 0x205 fÅr version 2.05     */
        reserved[8],                /* Reserviert                               */
                        
        buffer,         /* Freier Dateipuffer zum Zeitpunkt der Abfrage         */
        
        kobold_active,  /* 1 = KOBOLD aktiv, 0 = KOBOLD inaktiv                 */
        kobold_dialog,  /* 0 = keine Hauptdialoganzeige, 1 = Hauptformular offen*/
                
        no_of_files,    /* Anzahl der im Quellaufwerk selektierten Dateien      */
        no_of_folders,  /* Anzahl der im Quellaufwerk selektierten Ordner       */
        total_kb;       /* Auswahlumfang in Kilobytes                           */

    int source_drive,   /* Quellaufwerk, -1 = Keins                             */
        dest_drive;     /* Ziellaufwerk, -1 = Keins                             */

    unsigned long 
        gemdos_mode;    /* Bitvektor: Bit 0: Laufwerk A usw.                    */
                        /* Bit gesetzt = GEMDOS-Modus                           */
} KOBOLD_CONFIGURATION;


/* -----------------  Fehlercodes in der Antwort  ---------------------------- */

#define FINISHED            -1   /* KOBOLD wurde beendet */
#define OK                  0    /* Job abgeschlossen, aber
                                    KOBOLD noch aktiv */
#define KOBOLD_ERROR        1
#define NO_MEMORY           2
#define USER_BREAK          3
#define INVALID_POINTER     4
#define LOW_BUFFER          5
#define WRONG_DRIVE         6
#define WRONG_PARAMETER     7
#define UNEXPECTED_COMMAND  8
#define INVALID_MEMSIZE     9
#define NO_SUCH_OBJECT      10
#define NO_DRIVE_SELECTED   11
#define NO_FOLDER_CREATION  12
#define WRITE_PROTECTION    13
#define LOW_SPACE           14
#define LOW_ROOT            15
#define INVALID_PATH        16
#define BUFFER_IN_USE       17
#define BAD_BPB             18
#define BAD_READ            19
#define BAD_WRITE           20
#define UNKNOWN_COMMAND     21
#define NO_WINDOW           22
#define TOO_MANY_GOSUBS     23
#define TOO_MANY_RETURNS    24
#define LABEL_NOT_FOUND     25
#define NO_SUCH_FOLDER      26
#define REORGANIZED_MEMORY  27
#define NO_SELECTION_MODE   28
#define DRIVEVAR_NOT_SPECIFIED 29
#define MULTIPLE_LABEL      30
#define EXEC_ERROR          31

/* ---------------  Job Kommandos --------------------------------------------*/

#define _SRC_SELECT         0
#define _DST_SELECT         1
#define _DIALOG_LEVEL       2
#define _KEEP_FLAGS         3
#define _IGNORE_WP          4
#define _ALERT              5
#define _PAUSE              6
#define _NEW_FOLDER         7
#define _CHOOSE             8
#define _RESET_STATUS       9
#define _READ_INTO_BUFFER   10
#define _WRITE_BUFFER       11
#define _COPY               12
#define _MOVE               13
#define _DELETE             14
#define _QUIT               15
#define _GOTO               16
#define _GOSUB              17
#define _RETURN             18
#define _PERMANENT          19
#define _VERIFY             21
#define _DATE               22
#define _ARCHIVE_TREATMENT  23
#define _GEMDOS_MODE        24
#define _FORMAT_PARAMETER   25
#define _FORMAT             26
#define _SOFT_FORMAT        27
#define _OFF                28
#define _ON                 29
#define _EVER_OFF           30
#define _EVER_ON            31
#define _CONSIDER_PATHS     32
#define _ON_LEVEL           33
#define _EXTENSIONS         34
#define _ARCHIVE            35
#define _FILE               36
#define _KEEP_SEQUENCE      37
#define _RESET_ARCHIVES     38
#define _OPEN_FOLDERS       39
#define _CURRENT            40
#define _KEEP               41
#define _SET                42
#define _CLEAR              43
#define _CLEARED            44
#define _SI                 45
#define _SE                 46
#define _DI                 47
#define _DE                 48
#define _CLEAR_BUFFER       51
#define _SOURCE_TREATMENT   52
#define _DIALOG_WINDOWS     53
#define _RENAME             54
#define _BUFFER             55
#define _BING               56
#define _SWAP               57
#define _DATE_DIFFERENT     58
#define _DATE_EQUAL         59
#define _DATE_YOUNGER       60
#define _DATE_OLDER         61
#define _DATE_ARBITRARY     62
#define _SIZE_DIFFERENT     63
#define _SIZE_EQUAL         64
#define _SIZE_LARGER        65
#define _SIZE_SMALLER       66
#define _SIZE_ARBITRARY     67
#define _FILE_ATTRIBUTES    68
#define _SELECT_DRIVE       69
#define _BRANCH_ON_DRIVE    70
#define _EXECUTE            71
#define _SET_DRIVE          72
#define _NEXT_DRIVE         73
#define _EXIT               74
