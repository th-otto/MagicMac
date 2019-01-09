long filestat(WORD nofollowlinks, const char *name, XATTR *xattr);

void *readfile(const char *filename, LONG *size);
LONG readbuf(const char *filename, void *buf, LONG offset, LONG size);
LONG writebuf(const char *filename, void *buf, LONG offset, LONG size);
