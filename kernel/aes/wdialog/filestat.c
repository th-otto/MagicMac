#include "wdlgmain.h"
#include "filestat.h"
#include <sys/stat.h>


static void translate_xattr(DTA *dta, XATTR *xattr, WORD drv);


long filestat(WORD nofollowlinks, const char *name, XATTR *xattr)
{
	LONG ret;
	WORD drv;
	DTA dta;
	DTA *olddta;
	
	ret = Fxattr(nofollowlinks, name, xattr);
	if (ret == -32) /* ENOSYS */
	{
		olddta = Fgetdta();
		Fsetdta(&dta);
		ret = Fsfirst(name, FA_RDONLY|FA_HIDDEN|FA_SYSTEM|FA_DIR|FA_CHANGED);
		if (ret == 0)
		{
			if (name[1] == ':')
			{
				drv = name[0];
				if (drv >= 'A' && drv <= 'Z')
					drv -= 'A';
				else if (drv >= 'a' && drv <= 'z')
					drv -= 'a';
				else
					drv = Dgetdrv();
			} else
			{
				drv = Dgetdrv();
			}
			translate_xattr(&dta, xattr, drv);
		} else
		{
			ret = -33; /* ENOENT */
		}
		Fsetdta(olddta);
	}
	return ret;
}


static unsigned short translate_attr(unsigned short attr)
{
	unsigned short mode = S_IRUSR | S_IRGRP | S_IROTH;
	if (!(attr & FA_RDONLY))
		mode |= S_IWUSR | S_IWGRP | S_IWOTH;
	if (attr & FA_DIR)
		mode |= S_IXUSR | S_IXGRP | S_IXOTH | S_IFDIR;
	else
		mode |= S_IFREG;
	return mode;
}


static void translate_xattr(DTA *dta, XATTR *xattr, WORD drv)
{
	xattr->st_mode = translate_attr((unsigned char)dta->d_attrib);
	xattr->st_ino = 0;
	xattr->st_dev = drv;
	xattr->st_nlink = 1;
	xattr->st_uid = 0;
	xattr->st_gid = 0;
	xattr->st_size = dta->d_length;
	xattr->st_blksize = 1024;
	xattr->st_blocks = (xattr->st_size + 1023) >> 10;
	xattr->st_mtim.u.d.time = dta->d_time;
	xattr->st_mtim.u.d.date = dta->d_date;
	xattr->st_atim.u.d.time = dta->d_time;
	xattr->st_atim.u.d.date = dta->d_date;
	xattr->st_ctim.u.d.time = dta->d_time;
	xattr->st_ctim.u.d.date = dta->d_date;
	xattr->st_attr = (unsigned char)dta->d_attrib;
}
