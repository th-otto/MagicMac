#include "drivers.h"
#include "mxvdi.h"

#if NEW_SETUP_API
DRVR_HEADER *load_MAC_driver(VDI_DISPLAY *display, const char *driver_dir);
#else
DRVR_HEADER *load_MAC_driver(MXVDI_PIXMAP *pixmap, const char *driver_dir);
#endif
DRVR_HEADER *load_ATARI_driver(WORD shiftmode, WORD modecode, const char *driver_dir);
