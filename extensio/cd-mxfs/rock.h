/* SPDX-License-Identifier: GPL-2.0 */
/*
 * These structs are used by the system-use-sharing protocol, in which the
 * Rock Ridge extensions are embedded.  It is quite possible that other
 * extensions are present on the disk, and this is fine as long as they
 * all use SUSP
 */

/* Continuation Area */
struct SU_CE_s {
	unsigned char extent[8];
	unsigned char offset[8];
	unsigned char size[8];
};

/* Padding Field */
struct SU_PD_s {
	char empty[1]; /* actually zero size */
};

/* System Use Sharing Protocol Indicator */
struct SU_SP_s {
	unsigned char magic[2];
	unsigned char skip;
};

/* System Use Sharing Protocol Terminator */
struct SU_ST_s {
	char empty[1]; /* actually zero size */
};

/* Extensions Reference */
struct SU_ER_s {
	unsigned char len_id;
	unsigned char len_des;
	unsigned char len_src;
	unsigned char ext_ver;
	unsigned char data[0];
};

/* Extensions Sequence */
struct SU_ES_s {
	unsigned char sequence;
};

struct RR_RR_s {
	unsigned char flags[1];
};

/* POSIX file attributes */
struct RR_PX_s {
	unsigned char mode[8];
	unsigned char n_links[8];
	unsigned char uid[8];
	unsigned char gid[8];
};

/* POSIX device number */
struct RR_PN_s {
	unsigned char dev_high[8];
	unsigned char dev_low[8];
};

struct SL_component {
	unsigned char flags;
	unsigned char len;
	unsigned char text[0];
};

/* Symbolic link */
struct RR_SL_s {
	unsigned char flags;
	struct SL_component link;
};

/* Alternate name */
struct RR_NM_s {
	unsigned char flags;
	char name[0];
};

/* Child link */
struct RR_CL_s {
	unsigned char location[8];
};

/* Parent link */
struct RR_PL_s {
	unsigned char location[8];
};

struct stamp {
	unsigned char time[7];		/* actually 6 unsigned, 1 signed */
};

/* Time Stamp(s) for a file */
struct RR_TF_s {
	unsigned char flags;
	struct stamp times[0];	/* Variable number of these beasts */
};

/* Linux-specific extension for transparent decompression */
struct RR_ZF_s {
	unsigned char algorithm[2];
	unsigned char parms[2];
	unsigned char real_size[8];
};

/* Apple-specific extensions */
union RR_AA_s {
	struct {
		unsigned char file_type;
		unsigned char aux_type[2]; /* 16bit little-endian */
	} prodos; /* version == 1 */
	struct {
		unsigned char fileType[4]; /* 32bit big-endian */
		unsigned char fileCreator[4]; /* 32bit big-endian */
		unsigned char finderFlags[2]; /* 16bit big-endian */
	} hfs; /* version == 2 */
};

/*
 * These are the bits and their meanings for flags in the TF structure.
 */
#define TF_CREATION   0x01
#define TF_MODIFY     0x02
#define TF_ACCESS     0x04
#define TF_ATTRIBUTES 0x08
#define TF_BACKUP     0x10
#define TF_EXPIRATION 0x20
#define TF_EFFECTIVE  0x40
#define TF_LONG_FORM  0x80

/*
 * These are the bits and their meanings for flags in the RR structure.
 */
#define RR_PX 1			/* POSIX attributes */
#define RR_PN 2			/* POSIX devices */
#define RR_SL 4			/* Symbolic link */
#define RR_NM 8			/* Alternate Name */
#define RR_CL 16		/* Child link */
#define RR_PL 32		/* Parent link */
#define RR_RE 64		/* Relocation directory */
#define RR_TF 128		/* Timestamps */

/*
 * These are the bits and their meanings for flags in the SL structure.
 */
#define SL_CONTINUE 0x01
#define SL_CURRENT  0x02
#define SL_PARENT   0x04
#define SL_ROOT     0x08

/*
 * These are the bits and their meanings for flags in the NM structure.
 */
#define NM_CONTINUE 0x01
#define NM_CURRENT  0x02
#define NM_PARENT   0x04


struct rock_ridge {
	unsigned char signature[2];
	unsigned char len;
	unsigned char version;
	union {
		struct SU_CE_s CE;
		struct SU_PD_s PD;
		struct SU_SP_s SP;
		struct SU_ST_s ST;
		struct SU_ER_s ER;
		struct SU_ES_s ES;
		struct RR_RR_s RR;
		struct RR_PX_s PX;
		struct RR_PN_s PN;
		struct RR_SL_s SL;
		struct RR_NM_s NM;
		struct RR_CL_s CL;
		struct RR_PL_s PL;
		struct RR_TF_s TF;
		struct RR_ZF_s ZF;
		union RR_AA_s AA;
	} u;
};

