#include "drivers.h"

DRV_SYS *load_MAC_driver(MXVDI_PIXMAP *pixmap, const char *driver_dir);
DRV_SYS *load_ATARI_driver(WORD shiftmode, WORD modecode, const char *driver_dir);
