#ifndef __VDI_META_H__
#define __VDI_META_H__

/*	Metafile-Header-Struktur */
typedef struct
{
	WORD	mf_header;
	WORD	mf_length;
	WORD	mf_version;
	WORD	mf_ndcrcfl;
	WORD	mf_extents[4];
	WORD	mf_pagesz[2];
	WORD	mf_coords[4];
	WORD	mf_imgflag;
	WORD	mf_resvd[9];
} METAHDR;

typedef struct
{
	BYTE	tag1;
	BYTE	tag2;
	BYTE	tag3;
	BYTE	count;
} VERTICAL_REPEAT;
	
typedef struct
{
	BYTE	tag;
} SOLID_RUN;

typedef struct
{
	BYTE	tag;
	BYTE	length;
	BYTE	pattern[];
} PATTERN_RUN;

typedef struct
{
	BYTE	tag;
	BYTE	length;
	WORD	pattern;
} PATTERN_RUN2;

typedef struct
{
	BYTE	tag;
	BYTE	length;
	BYTE	uncompressed[];
} BIT_STRING;

/*	IMG-Header-Struktur */
typedef struct
{
	WORD	version;
	WORD	length;
	WORD	planes;
	WORD	pattern_length;
	WORD	pixw;
	WORD	pixh;
	WORD	w;
	WORD	h;
} IMGHDR;

#endif /* __VDI_META_H__ */
