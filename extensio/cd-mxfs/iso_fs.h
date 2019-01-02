/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
#ifndef _ISOFS_FS_H
#define _ISOFS_FS_H

/*
 * The isofs filesystem constants/structures
 */

#define ISOFS_BLOCK_BITS 11
#define ISOFS_BLOCK_SIZE 2048

#define HS_STANDARD_ID "CDROM"
#define ISO_STANDARD_ID "CD001"

struct iso_volume_descriptor {
	unsigned char type;
	char id[5];
	unsigned char version;
	unsigned char data[ISOFS_BLOCK_SIZE - 7];
};

/* volume descriptor types */
#define ISO_VD_PRIMARY 1
#define ISO_VD_SUPPLEMENTARY 2
#define ISO_VD_END 255


/* high sierra is identical to iso, except that the date is only 6 bytes, and
   there is an extra reserved byte after the flags */

struct iso_directory_record {
	unsigned char length;
	unsigned char ext_attr_length;
	unsigned char extent[8]; /* 32bit little-endian/big-endian */
	unsigned char size[8]; /* 32bit little-endian/big-endian */
	unsigned char date[7];
	unsigned char flags;
	unsigned char file_unit_size;
	unsigned char interleave;
	unsigned char volume_sequence_number[4]; /* 16bit little-endian/big-endian */
	unsigned char name_len;
	char name[1];
};

struct iso_primary_descriptor {
	unsigned char type;
	char id[5];
	unsigned char version;
	unsigned char unused1;
	char system_id[32]; /* achars */
	char volume_id[32]; /* dchars */
	unsigned char unused2[8];
	unsigned char volume_space_size[8]; /* 32bit little-endian/big-endian */
	unsigned char unused3[32];
	unsigned char volume_set_size[4]; /* 16bit little-endian/big-endian */
	unsigned char volume_sequence_number[4]; /* 16bit little-endian/big-endian */
	unsigned char logical_block_size[4]; /* 16bit little-endian/big-endian */
	unsigned char path_table_size[8]; /* 32bit little-endian/big-endian */
	unsigned char type_l_path_table[4]; /* 32bit little-endian */
	unsigned char opt_type_l_path_table[4]; /* 32bit little-endian */
	unsigned char type_m_path_table[4]; /* 32bit big-endian */
	unsigned char opt_type_m_path_table[4]; /* 32bit big-endian */
	struct iso_directory_record root_directory_record; /* 9.1 */
	char volume_set_id[128]; /* dchars */
	char publisher_id[128]; /* achars */
	char preparer_id[128]; /* achars */
	char application_id[128]; /* achars */
	char copyright_file_id[37]; /* 7.5 dchars */
	char abstract_file_id[37]; /* 7.5 dchars */
	char bibliographic_file_id[37]; /* 7.5 dchars */
	unsigned char creation_date[17]; /* 8.4.26.1 */
	unsigned char modification_date[17]; /* 8.4.26.1 */
	unsigned char expiration_date[17]; /* 8.4.26.1 */
	unsigned char effective_date[17]; /* 8.4.26.1 */
	unsigned char file_structure_version;
	unsigned char unused4;
	unsigned char application_data[512];
	unsigned char unused5[652];
};

/* Almost the same as the primary descriptor but two fields are specified */
struct iso_supplementary_descriptor {
	unsigned char type;
	char id[5];
	unsigned char version;
	unsigned char flags;
	char system_id[32]; /* achars */
	char volume_id[32]; /* dchars */
	unsigned char unused2[8];
	unsigned char volume_space_size[8]; /* 32bit little-endian/big-endian */
	unsigned char escape[32]; /* 856 */
	unsigned char volume_set_size[4]; /* 16bit little-endian/big-endian */
	unsigned char volume_sequence_number[4]; /* 16bit little-endian/big-endian */
	unsigned char logical_block_size[4]; /* 16bit little-endian/big-endian */
	unsigned char path_table_size[8]; /* 32bit little-endian/big-endian */
	unsigned char type_l_path_table[4]; /* 32bit little-endian */
	unsigned char opt_type_l_path_table[4]; /* 32bit little-endian */
	unsigned char type_m_path_table[4]; /* 32bit big-endian */
	unsigned char opt_type_m_path_table[4]; /* 32bit big-endian */
	struct iso_directory_record root_directory_record; /* 9.1 */
	char volume_set_id[128]; /* dchars */
	char publisher_id[128]; /* achars */
	char preparer_id[128]; /* achars */
	char application_id[128]; /* achars */
	char copyright_file_id[37]; /* 7.5 dchars */
	char abstract_file_id[37]; /* 7.5 dchars */
	char bibliographic_file_id[37]; /* 7.5 dchars */
	unsigned char creation_date[17]; /* 8.4.26.1 */
	unsigned char modification_date[17]; /* 8.4.26.1 */
	unsigned char expiration_date[17]; /* 8.4.26.1 */
	unsigned char effective_date[17]; /* 8.4.26.1 */
	unsigned char file_structure_version;
	unsigned char unused4;
	unsigned char application_data[512];
	unsigned char unused5[652];
};


struct hs_volume_descriptor {
	unsigned char foo[8]; /* 32bit little-endian/big-endian */
	unsigned char type;
	char id[5];
	unsigned char version;
	unsigned char data[ISOFS_BLOCK_SIZE - 15];
};


struct hs_primary_descriptor {
	unsigned char foo[8]; /* 32bit little-endian/big-endian */
	unsigned char type;
	char id[5];
	unsigned char version;
	unsigned char unused1;
	char system_id[32]; /* achars */
	char volume_id[32]; /* dchars */
	unsigned char unused2[8]; /* 32bit little-endian/big-endian */
	unsigned char volume_space_size[8]; /* 32bit little-endian/big-endian */
	unsigned char unused3[32];
	unsigned char volume_set_size[4]; /* 16bit little-endian/big-endian */
	unsigned char volume_sequence_number[4]; /* 16bit little-endian/big-endian */
	unsigned char logical_block_size[4]; /* 16bit little-endian/big-endian */
	unsigned char path_table_size[8]; /* 32bit little-endian/big-endian */
	unsigned char type_l_path_table[4]; /* 32bit little-endian */
	unsigned char unused4[28];
	struct iso_directory_record root_directory_record; /* 9.1 */
};

/* We use this to help us look up the parent inode numbers. */

struct iso_path_table {
	unsigned char name_len[2];	/* 16bit little-endian */
	unsigned char extent[4];	/* 32bit little-endian */
	unsigned char parent[2];	/* 16bit little-endian */
	char name[1];
};

/*
 * These are the bits and their meanings for flags in the directory structure.
 */
#define DE_EXISTENCE    0x01
#define DE_DIRECTORY    0x02
#define DE_FILE         0x04
#define DE_RECORD       0x08
#define DE_PROTECTION   0x10
#define DE_MULTI_EXTENT 0x80

#endif /* _ISOFS_FS_H */
