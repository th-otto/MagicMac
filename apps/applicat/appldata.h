/*
*
* Diese Datei beschreibt den Aufbau der Datei APPLICAT.DAT
* fÅr die Zuweisung von Icons und Eigenschaften an Programme
* und Dateitypen.
*
*/

/* Flags fÅr APPLICAT */
#define PGMT_ISGEM		1		/* Benutzt GEM (PRG, APP) */
#define PGMT_TP		2		/* Nimmt Parameter (GTP, TTP) */
#define PGMT_SINGLE		4		/* single mode */
#define PGMT_WINPATH	8		/* Pfad = oberstes Fenster */
#define PGMT_NVASTART	16		/* Programm versteht kein VA_START */
#define PGMT_ACC		32		/* Accessory */
#define PGMT_NO_PROPFNT	64		/* kein prop. AES-Zeichensatz */
/* weitere Flags */
#define PGMT_BATCH		256		/* BTP oder BAT */
#define PGMT_NOEXE		-1		/* nicht ausfÅhrbar */


/* fÅr Icondatei: */

struct ico_head {
	long magic;                   /* ist 'AnKr' */
	long version;                 /* ist z.Zt. 1L */
	long n_ap2ic;                 /* LÑnge der Tabelle ap2ic */
	long p_ap2ic;                 /* Zeiger auf Tabelle ap2ic */
	long n_da2ic;                 /* LÑnge der Tabelle da2ic */
	long p_da2ic;                 /* Zeiger auf Tabelle da2ic */
	long	n_pa2ic;				/* LÑnge der Tabelle pa2ic */
	long	p_pa2ic;				/* Zeiger Tabelle pa2ic */
	long	n_sp2ic;				/* LÑnge der Tabelle sp2ic */
	long	p_sp2ic;				/* Zeiger Tabelle sp2ic */
	long n_icn;                   /* Anzahl CICONBLKs */
	long p_icn;                   /* Zeiger auf Tabelle icn */
};


/* in Datei */
/* -------- */

struct ico_ap {
     long apname;             /* Zeiger auf Name ohne Extension */
     long path;               /* -1L oder Zeiger auf Pfad */
     int  config;             /* -1 oder Konfigurationsbits */
	long memlimit;
     long icon_nr;            /* 0..n_icn-1 */
};

struct ico_dat {
     long daname;             /* Zeiger auf Dateityp */
     long ap;                 /* Index der App. oder -1L ("frei") */
     long icon_nr;            /* 0..n_icn-1 */
};

struct ico_path {
	long	pathname;			/* Pfad, z.B. A: oder c:\auto */
	long	icon_nr;
};

struct ico_spec {
	long	key;				/* 'APPS','DATS','BTCH','DEVC' */
						/* 'FLDR','DRVS','TRSH','PRNT' */
	long	icon_nr;
};


/* im Speicher */
/* ----------- */

typedef struct {
	char *apname;
	char *path;
	int	config;
	long memlimit;
	CICONBLK *icon;
} APPLICATION;

typedef struct {
	char *daname;
	APPLICATION *ap;
	CICONBLK *icon;
} DATAFILE;

typedef struct {
	char	*path;
	CICONBLK *icon;
} PATHNAME;

typedef struct {
	long	key;
	CICONBLK *icon;
} SPECIALOBJECT;
