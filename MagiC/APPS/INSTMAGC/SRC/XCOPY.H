extern long copy_subdir( char *src, char *dst );
extern long MFcreate( char *name );
extern long GDcreate(char *path, char *name);
extern long GFcopy(char *path, char *name, char *dstpath);
extern void callback(char *action, char *name);

extern char *writing;
extern char *reading;
extern char *crfolder;
extern char *err_creating;
extern char *diskfull;