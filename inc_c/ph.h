typedef struct {
   short ph_branch;        /* 0x00: always == 0x601a */
   long ph_tlen;          /* 0x02: length of TEXT segment */
   long ph_dlen;          /* 0x06: length of DATA segment */
   long ph_blen;          /* 0x0a: length of BSS segment */
   long ph_slen;          /* 0x0e: length of symbol table   */
   long ph_res1;          /* 0x12: unused, must be zero */
   long ph_res2;          /* 0x16: different flags */
   short ph_flag;         /* 0x1a: if not zero, neither relocate nor clear BSS */
} PH;

#define PH_MAGIC	0x601a					/* value of PH.branch */
#define PHFLAG_DONT_CLEAR_HEAP	0x00000001	/* PH.flags */
#define PHFLAG_LOAD_TO_FASTRAM	0x00000002	/* PH.flags */
#define PHFLAG_MALLOC_FROM_FASTRAM	0x00000004	/* PH.flags */
#define PHFLAG_MINIMAL_RAM		0x00000008	/* PH.flags (MagiC 5.20) */
#define PHFLAG_MEMPROT			0x000000f0	/* PH.flags (MiNT) */
#define PHFLAG_SHARED_TEXT		0x00000800	/* PH.flags (MiNT) */
#define PHFLAG_TPA_SIZE			0xf0000000	/* PH.flags */


