#include <tos.h>
#include <stdlib.h>
#include <ctype.h>
#include <stdio.h>
#include <string.h>


#define DATESEP 	'-'
#define TIMESEP	':'

/* file types */
#define S_IFMT 0170000        /* mask to select file type */
#define S_IFCHR     0020000        /* BIOS special file */
#define S_IFDIR     0040000        /* directory file */
#define S_IFREG 0100000       /* regular file */
#define S_IFIFO 0120000       /* FIFO */
#define S_IMEM 0140000        /* memory region or process */
#define S_IFLNK     0160000        /* symbolic link */

/* special bits: setuid, setgid, sticky bit */
#define S_ISUID     04000
#define S_ISGID 02000
#define S_ISVTX     01000

/* file access modes for user, group, and other*/
#define S_IRUSR     0400
#define S_IWUSR 0200
#define S_IXUSR 0100
#define S_IRGRP 0040
#define S_IWGRP     0020
#define S_IXGRP     0010
#define S_IROTH     0004
#define S_IWOTH     0002
#define S_IXOTH     0001
#define DEFAULT_DIRMODE (0777)
#define DEFAULT_MODE     (0666)

char * date_to_str(unsigned int date);
char * time_to_str(unsigned int time);
void readline(char *s, int len);
void show_xattr(XATTR *xattr);


#define Dxreaddir(a,b,c,d,e) gemdos(0x142,a,b,c,d,e)

int main(int argc, char *argv[])
{
	register int i;
	char path[256] = "";
	char name[256];
	XATTR xattr;
	long dirhandle,ret,retf;
	int tosflag = 0;


	if	(argc == 1)
		printf(	"\r\n"
				"Syntax: dxrddir [-t] [path]\r\n"
			  	"         -t  im TOS-Modus lesen\r\n\n");

	for	(i = 1; i < argc; i++)
		{
		if	(argv[i][0] == '-')
			{
			if	(toupper(argv[i][1]) == 'T')
				tosflag = 1;
			}
		else	strcpy(path, argv[i]);
		}

	ret = Dopendir(path, tosflag);
	printf("\r\nDopendir => %ld\n", ret);
	dirhandle = ret;

	while(ret >= 0)
		{
		ret = Dxreaddir(256, dirhandle, name, &xattr, &retf);
		printf("\r\nDxreaddir => %ld, %ld\n", ret, retf);
		if	(ret >= 0)
			{
			printf("Dateiname: \"%s\"\n", (tosflag) ? (name) : (name+4));
			if	(retf >= 0)
				show_xattr(&xattr);
			}
		}
	if	(dirhandle >= 0)
		printf("\r\nDclosedir => %ld\n", Dclosedir(dirhandle));
	return((int) ret);
}



/*********************************************************************
*
* Zeigt ein XATTR
*
*********************************************************************/

void show_xattr(XATTR *xattr)
{
	char s[256];
	int typ,spec,acs;


	/* mode */
	typ  = ((xattr->st_mode) >> 12) & 15;
	spec = ((xattr->st_mode) >> 9) & 7;
	acs  = (xattr->st_mode) & 511;
	switch(typ)
		{
		case 2:	strcpy(s, "BIOS special file");break;
		case 4:	strcpy(s, "directory file");break;
		case 8:	strcpy(s, "regular file");break;
		case 10:	strcpy(s, "fifo");break;
		case 12:	strcpy(s, "mem or proc");break;
		case 14:	strcpy(s, "symlink");break;
		default:	strcpy(s, "???????");break;
		}
	printf("MODE: typ = %d (%s) spec = %d ", typ, s, spec);
	printf(((acs >> 8) & 1) ? "R" : "r");
	printf(((acs >> 7) & 1) ? "W" : "w");
	printf(((acs >> 6) & 1) ? "X" : "x");
	printf(((acs >> 5) & 1) ? "R" : "r");
	printf(((acs >> 4) & 1) ? "W" : "w");
	printf(((acs >> 3) & 1) ? "X" : "x");
	printf(((acs >> 2) & 1) ? "R" : "r");
	printf(((acs >> 1) & 1) ? "W" : "w");
	printf(( acs       & 1) ? "X" : "x");
	printf("\n");

	printf("index   : $%08lx\n", xattr->st_ino);
	printf("dev     : %d\n", xattr->st_dev);
	printf("rdev    : %d\n", xattr->st_rdev);
	printf("nlink   : %d\n", xattr->st_nlink);
	printf("uid     : %d\n", xattr->st_uid);
	printf("gid     : %d\n", xattr->st_gid);
	printf("size    : %ld\n", xattr->st_size);
	printf("blksize : %ld\n", xattr->st_blksize);
	printf("nblocks : %ld\n", xattr->st_blocks);
	printf("mtime   : %s\n", time_to_str(xattr->st_mtim.u.d.time));
	printf("mdate   : %s\n", date_to_str(xattr->st_mtim.u.d.date));
	printf("atime   : %s\n", time_to_str(xattr->st_atim.u.d.time));
	printf("adate   : %s\n", date_to_str(xattr->st_atim.u.d.date));
	printf("ctime   : %s\n", time_to_str(xattr->st_ctim.u.d.time));
	printf("cdate   : %s\n", date_to_str(xattr->st_ctim.u.d.date));
	printf("attr    : $%02x\n", xattr->st_attr);
}


/*********************************************************************
*
* Wandelt DOS- Datum in eine Zeichenkette um.
*
*********************************************************************/

char * date_to_str(unsigned int date)
{
	static char u[20];
	register char *s;
	int t,m;

	s = u;
	t = date & 31;
	date >>= 5;
	m = date & 15;
	date >>= 4;
	date += 80;
	date %=100;
	*s++ = t/10 + '0';
	*s++ = t%10 + '0';
	*s++ = DATESEP;
	*s++ = m/10 + '0';
	*s++ = m%10 + '0';
	*s++ = DATESEP;
	*s++ = date/10 + '0';
	*s++ = date%10 + '0';
	*s = '\0';
	return(u);
}


/*********************************************************************
*
* Wandelt DOS- Zeit in eine Zeichenkette um.
*
*********************************************************************/

char * time_to_str(unsigned int time)
{
	static char u[20];
	register char *s;
	int min,sec;

	s = u;
	sec = 2 * (time & 31);
	time >>= 5;
	min = time & 63;
	time >>= 6;
	*s++ = time/10 + '0';
	*s++ = time%10 + '0';
	*s++ = TIMESEP;
	*s++ = min/10 + '0';
	*s++ = min%10 + '0';
	*s++ = TIMESEP;
	*s++ = sec/10 + '0';
	*s++ = sec%10 + '0';
	*s = '\0';
	return(u);
}


/*********************************************************************
*
* Wandelt DOS- Datum in eine Zeichenkette um.
*
*********************************************************************/

void readline(char *s, int len)
{
	long ret;

	ret = Fread(0, (long) len, s);
	if	(ret < 0)
		exit((int) ret);
	s[ret] = '\0';
}

