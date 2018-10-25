/*
*
* Headerdaten fuer die VFAT-Erweiterung des DOS_XFS.
*
*/

#ifndef NULL
#define NULL ((char*)0)
#endif
#ifndef EOS
#define EOS    '\0'
#endif

typedef struct {
 char          name[11];      /* 0x00: Dateiname                      */
 char          attr;          /* 0x0b: Attribut                       */
 WORD          xftype;        /* 0x0c: Pseudodatei- Typ               */
 LONG          xdata;         /* 0x0e: Datenblock                     */
 char          dummy[4];
 WORD          time;          /* 0x16: Zeit  der letzten Aenderung     */
 WORD          date;          /* 0x18: Datum der letzten Aenderung     */
 WORD          stcl;          /* 0x1a: erster Cluster                 */
 LONG          flen;          /* 0x1c: Dateilaenge                     */
} DIR;

typedef struct {
 char          head;          /* Bit 0..4: Nummer, Bit 6: Endofname   */
 unsigned char name1[10];     /* 5 Unicode- Zeichen                   */
 char          attr;          /* Attribut (0x0f)                      */
 char          unused;
 char          chksum;        /* Checksumme                           */
 unsigned char name2[12];     /* 6 Unicode- Zeichen                   */
 WORD          stcl;          /* erster Cluster (0)                   */
 unsigned char name3[4];      /* 2 Unicode-Zeichen                    */
} LDIR;

#include "std.h"

/* Aus VFAT.S */

extern LONG p_fread( MX_DOSFD *file, LONG count, void *buf);
extern LONG p_fwrite( MX_DOSFD *file, LONG count, void *buf);
extern LONG p_fseek( MX_DOSFD *file, LONG offs);
extern void vf_d2i( MX_DOSFD *file, DIR *dir, char *dst);
extern LONG p_extfd( MX_DOSFD *file );
extern char vf_chksum( char dosname[11] );

/* Aus XFS_DOS */

extern LONG _xattr( MX_DOSFD *d, DIR *dir, LONG p_xattr, WORD mode );
extern LONG reopen_FD( MX_DOSFD *fd, WORD omode);
extern LONG close_DD( MX_DOSFD *fd);
extern LONG get_DD( MX_DOSFD *dir, DIR *subdir, LONG dirpos,
               char *longname, void **link);
