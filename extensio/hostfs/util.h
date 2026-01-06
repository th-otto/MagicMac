#include <sys/stat.h>

#define waccess(mode)		((mode) & S_IWUSR)
#define raccess(mode)		((mode) & S_IRUSR)
#define xaccess(mode)		((mode) & S_IXUSR)

/*
 * FIXME: check refcnt for overflow here
 */
#define increase_refcnts(dd) (dd)->dd.dd_refcnt++

#define is_dot(p) (p[0] == '.' && p[1] == '\0')
#define is_dotdot(p) (p[0] == '.' && p[1] == '.' && p[2] == '\0')

#define FF_SEARCH	0
#define FF_EXIST	1

extern WORD (*p_Pdomain)(void);
WORD Pdomain_gemdos(void);
WORD Pdomain_kernel(void);

LONG check_fd(HOSTXFS_FD *fd);
LONG check_dd(HOSTXFS_DD *dd);
LONG check_dhd(HOSTXFS_DHD *dhd);
HOSTXFS_DD *findfile(HOSTXFS_DD *dd, const char *name, int s_or_e, int maybe_dir);
HOSTXFS_DD *new_dd(HOSTXFS_DD *dir, const char *name, fcookie *fc);
HOSTXFS_FD *new_fd(HOSTXFS_DD *dd);

void strcpy_name(char *dest, const char *src);
void tostrunc(char *dest, const char *src, WORD wildcards);
WORD has_xext(const char *name);
WORD check_name(const char *name);

WORD get_cookie(ULONG cookie, ULONG *value);
