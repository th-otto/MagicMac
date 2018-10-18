char *Malloc_sys(long size);
void Mfree_sys(void *buf);
void Mshrink_sys(void *buf, long size);

char *load_file(const char *filename, long *size);
long read_file(const char *filename, char *buf, long offset, long size);
