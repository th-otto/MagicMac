#include "hostfs.h"
#include "util.h"
#include <ctype.h>


WORD (*p_Pdomain)(void);
/*
 * we should always be able to use Non-ASCII filenames;
 * the emulator part will convert them to the hosts
 * character set
 */
int eight_bit = TRUE;

static char const xext[][5] = {
	"sot.",
	"ptt.",
	"grp.",
	"ppa.",
	"ptg.",
	"cca."
};


void strcpy_name(char *dest, const char *src)
{
	WORD i = 0;
	
	while (*src && i < HOSTFS_NAMEMAX)
	{
		*dest++ = *src++;
		i++;
	}
	*dest = '\0';
}


/*
 * check_dd
 *
 * Check a directory descriptor for validity.
 *
 * inputs:
 * dd: DD to check.
 *
 * returns:
 * E_OK: no error
 * EDRIVE: DD does not belong to us
 * EPTHNF: DD does not refer a directory
 */
LONG check_dd(HOSTXFS_DD *dd)
{
	HOSTXFS_DD *root_dd;
	
#if PARANOIA
	if (dd == NULL)
	{
		DEBUGPRINTF(("check_dd: NULL dd\n"));
		return EIMBA;
	}
	if (dd->dd.dd_dmd == NULL)
	{
		DEBUGPRINTF(("check_dd: NULL dd_dmd\n"));
		return EIMBA;
	}
#endif
	if ((root_dd = get_root_dd(dd->dd.dd_dmd->d_drive)) == NULL)
		return EDRIVE;
#if PARANOIA
	if (dd->dd_magic != DD_MAGIC)
	{
		DEBUGPRINTF(("check_dd: dd %08lx is not a DD\n", (unsigned long)dd));
		return EDRIVE;
	}
#endif
	if (dd->dd.dd_dmd != root_dd->dd.dd_dmd)
		return EDRIVE;
	if (!S_ISDIR(dd->st_mode))
		return EPTHNF;
	return E_OK;
}


/*
 * check_fd
 *
 * Like check_dd, but for file descriptors
 *
 * inputs:
 * fd: FD to check.
 *
 * returns:
 * E_OK: no error
 * EDRIVE: FD does not belong to us
 * EFILNF: FD does not refer a file
 */
LONG check_fd(HOSTXFS_FD *fd)
{
	HOSTXFS_DD *root_dd;
	
#if PARANOIA
	if (fd == NULL)
	{
		DEBUGPRINTF(("check_fd: NULL dd\n"));
		return EIMBA;
	}
	if (fd->fd.fd_dmd == NULL)
	{
		DEBUGPRINTF(("check_fd: NULL fd_dmd\n"));
		return EIMBA;
	}
#endif
	if ((root_dd = get_root_dd(fd->fd.fd_dmd->d_drive)) == NULL)
		return EDRIVE;
#if PARANOIA
	if (fd->fd_magic != FD_MAGIC)
	{
		DEBUGPRINTF(("check_fd: fd %08lx is not a FD\n", (unsigned long)fd));
		return EDRIVE;
	}
#endif
	if (fd->fd.fd_dmd != root_dd->dd.dd_dmd)
		return EDRIVE;
	if (!S_ISREG(fd->st_mode))
	{
		if (S_ISCHR(fd->st_mode) || S_ISBLK(fd->st_mode))
			return ENODEV;
		if (S_ISDIR(fd->st_mode))
			return EISDIR;
		return EFILNF;
	}
	return E_OK;
}


LONG check_dhd(HOSTXFS_DHD *dhd)
{
#if PARANOIA
	if (dhd == NULL)
	{
		DEBUGPRINTF(("check_dhd: NULL dhd\n"));
		return EIMBA;
	}
	if (dhd->dhd.dhd_dmd == NULL)
	{
		DEBUGPRINTF(("check_dhd: NULL dhd_dmd\n"));
		return EIMBA;
	}
#endif
	if (get_root_dd(dhd->dhd.dhd_dmd->d_drive) == NULL)
		return EDRIVE;
#if PARANOIA
	if (dhd->dhd_magic != DHD_MAGIC)
	{
		DEBUGPRINTF(("check_dhd: dhd %08lx is not a DHD\n", (unsigned long)dhd));
		return EDRIVE;
	}
#endif
	return E_OK;
}


static long xfs_lookup(fcookie *dir, const char *name, fcookie *fc)
{
	return nf_call(HOSTFS(XFS_LOOKUP), dir, name, fc);
}


HOSTXFS_DD *new_dd(HOSTXFS_DD *dir, const char *name, fcookie *fc)
{
	HOSTXFS_DD *dd;
	XATTR xattr;
	
	UNUSED(name);
	dd = kernel_int_malloc();
	if (dd == NULL)
		return dd;
	dd->dd.dd_dmd = dir->dd.dd_dmd;
	dd->dd.dd_refcnt = 1;
	dd->dd_mode = 0;
	dd->dd_dev = 0;
#if PARANOIA
	dd->dd_magic = DD_MAGIC;
#endif
	dd->st_mode = S_IFREG|S_IRUSR|S_IWUSR|S_IRGRP|S_IWGRP|S_IROTH|S_IWOTH;
	dd->dd_parent = dir;
	dd->dd_symlink = 0;
	if (fc)
	{
		dd->fc = *fc;
		if (nf_call(HOSTFS(XFS_GETXATTR), fc, &xattr) == 0)
			dd->st_mode = xattr.st_mode;
	}
	return dd;
}


HOSTXFS_FD *new_fd(HOSTXFS_DD *dd)
{
	HOSTXFS_FD *fd;
	
	fd = kernel_int_malloc();
	if (fd == NULL)
		return fd;
	fd->fd.fd_dmd = dd->dd.dd_dmd;
	fd->fd.fd_refcnt = 1;
	fd->fd.fd_mode = 0;
	fd->fd.fd_dev = &hostdev;
#if PARANOIA
	fd->fd_magic = FD_MAGIC;
#endif
	fd->st_mode = dd->st_mode;
	return fd;
}


void tostrunc(char *dest, const char *src, WORD wildcards)
{
	WORD	i;
	char	*lastdot;
	char temp[2];
	
	static char const allowed_chars[] = "_!@#$%^&()+-=~`;\'\",<>|[]{}";
	
	/* copy "." und ".." unmodified */
	if (is_dot(src) || is_dotdot(src))
	{
		strcpy(dest, src);
		return;
	}
	/*
	 * Den letzten Punkt im Namen suchen. Ist er das erste oder letzte
	 * Zeichen des Namens, wird er "versteckt".
	 */
	lastdot = strrchr(src, '.');
	if (lastdot != NULL)
	{
		if (lastdot == src || lastdot[1] == '\0')
			lastdot = NULL;
	}
	/*
	 * Den Zielstring vorbereiten und die ersten acht Zeichen vor dem
	 * letzten Punkt einsetzen
	 */
	strcpy(dest, "");
	temp[1] = '\0';
	for (i = 0; i < 8; i++)
	{
		if (*src == '\0' || src == lastdot)
			break;
		/* Punkte als Kommas eintragen */
		if (*src == '.')
		{
			strcat(dest, ",");
		} else
		{
			/*
			 * Unerlaubte Zeichen als "X" uebernehmen, alle anderen als
			 * Grossbuchstaben in den Zielstring einsetzen. "*" und "?" werden
			 * dabei in Abhaengigkeit des Parameters wildcard behandelt.
			 */
			if (strchr(allowed_chars, *src) ||
				isalnum(*src) ||
				(wildcards && (*src == '*' || *src == '?')))
			{
				temp[0] = kernel_toupper(*src);
				strcat(dest, temp);
			} else
			{
				strcat(dest, "X");
			}
		}
		src++;
	}
	/*
	 * Gab es einen letzten Punkt, wird er jetzt samt den ersten drei
	 * dahinter folgenden Zeichen (gewandelt wie oben) an den Zielstring
	 * angehaengt.
	 */
	if (lastdot)
	{
		strcat(dest, ".");
		src = lastdot;
		src++;
		for (i = 0; i < 3; i++)
		{
			if (*src == '\0')
				break;
			if (strchr(allowed_chars, *src) ||
				isalnum(*src) ||
				(wildcards && (*src == '*' || *src == '?')))
			{
				temp[0] = kernel_toupper(*src);
				strcat(dest, temp);
			} else
			{
				strcat(dest, "X");
			}
			src++;
		}
	}
}


HOSTXFS_DD *findfile(HOSTXFS_DD *dd, const char *name, int s_or_e, int maybe_dir)
{
	char temp[HOSTFS_NAMEMAX + 1];
	fcookie fc;
	WORD domain;
	
	/* safety check */
	if (!S_ISDIR(dd->st_mode))
		return NULL;
	/* an empty name means the current directory */
	if (name == NULL || *name == '\0')
	{
		if (maybe_dir)
		{
			increase_refcnts(dd);
			return dd;
		}
		return NULL;
	}
	/* the directory must be searchable */
	if (!xaccess(dd->st_mode))
		return NULL;

	strcpy_name(temp, name);
	
	/*
	 * Try to find an exact match if process is in MiNT domain,
	 * or we are searching for a directory entry
	 */
	domain = p_Pdomain();
	if (domain < 0 || domain == 1 || s_or_e == FF_SEARCH)
	{
		if (xfs_lookup(&dd->fc, temp, &fc) == 0)
			return new_dd(dd, temp, &fc);
	}
	/*
	 * if we had no match, return NULL when running
	 * in MiNT domain and checking for existance
	 */
	if ((domain < 0 || domain == 1) && s_or_e == FF_EXIST)
		return NULL;

	/*
	 * otherwise convert filename and try again
	 */
	if (domain == 0)
	{
		strlwr(temp);
		if (xfs_lookup(&dd->fc, temp, &fc) == 0)
			return new_dd(dd, temp, &fc);
		/*
		 * if we had still no match, return NULL when
		 * checking for existance
		 */
		if (s_or_e == FF_EXIST)
			return NULL;
	}
	
	/*
	 * try again with truncated filename
	 */
	tostrunc(temp, name, 0);
	if (xfs_lookup(&dd->fc, temp, &fc) == 0)
		return new_dd(dd, temp, &fc);
	/* no match */
	return NULL;
}



static long get_jarptr(void)
{
	return *((long *)0x5a0);
}


WORD get_cookie(ULONG cookie, ULONG *value)
{
	LONG *jar;

	jar = (LONG *)Supexec(get_jarptr);

	if (jar == 0)
		return 0;

	while (jar[0])
	{
		if (jar[0] == cookie)
		{
			if (value != NULL)
				*value = jar[1];

			return 1;
		}
		jar += 2;
	}
	return 0;
}


WORD Pdomain_gemdos(void)
{
	LONG ret;
	
	ret = Pdomain(-1);
	return (WORD)ret;
}


WORD Pdomain_kernel(void)
{
	return (WORD)kernel_proc_info(1, *(KERNEL.act_pd));
}


WORD has_xext(const char *name)
{
	char temp[HOSTFS_NAMEMAX + 1];
	WORD i;

	if (p_Pdomain() == 1)
		return 0;
	strcpy_name(temp, name);
	strrev(temp);
	for (i = 0; i < (sizeof(xext) / sizeof(xext[0])); i++)
	{
		if (strnicmp(temp, xext[i], 4) == 0)
			return 1;
	}
	return 0;
}


/*
 * check_name
 *
 * Check for valid filename.
 * We allow all ASCII character in range 32 to 127/255,
 * except for slash/backslash.
 */
WORD check_name(const char *name)
{
	WORD i;
	unsigned short max;
	unsigned short check;

	/* empty filename are not allowed */
	if (name == NULL || name[0] == '\0')
		return FALSE;
	max = eight_bit ? 255 : 127;
	for (i = 0; name[i] != '\0'; i++)
	{
		check = (unsigned char)name[i];
		if (check < 0x20 || check > max ||
			check == '\\' || check == '/')
		{
			return FALSE;
		}
	}
	return TRUE;
}
