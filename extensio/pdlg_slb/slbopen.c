#include <portab.h>
#include <tos.h>
#include <aes.h>
#include <vdi.h>
#include <string.h>
#include "std.h"
#include "wdlgmain.h"
#include "pdlg_slb.h"

long cdecl _gemdos(short code, ...);

LONG Slbopen(const char *name, const char *path, long minver, SLB_HANDLE *handle, SLB_EXEC *exec)
{
	return _gemdos(22, name, path, minver, handle, exec);
}
