#include "drivers.h"
#include "mxvdi.h"

DRVR_HEADER *load_MAC_driver(VDI_DISPLAY *display, const char *driver_dir);
DRVR_HEADER *load_ATARI_driver(WORD shiftmode, WORD modecode, const char *driver_dir);
