long copy_subdir(const char *src, const char *dst);
long MFcreate(const char *name);
long GDcreate(const char *path, const char *name);
long GFcopy(const char *path, const char *name, const char *dstpath);
void callback(const char *action, const char *name);

extern char *writing;
extern char *reading;
extern char *crfolder;
extern char *err_creating;
extern char *diskfull;