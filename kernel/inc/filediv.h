char *Malloc_sys(long size);
void Mfree_sys(void *buf);
void Mshrink_sys(void *buf, long size);

unsigned char *load_file(const char *filename, long *size);
long read_file(const char *filename, void *buf, long offset, long size);
