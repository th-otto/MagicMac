extern void global_init( void );
extern void global_init2( void );
extern void wbm_create( WININFO *w );
extern void wbm_skind( WININFO *w );
extern void wbm_ssize( WININFO *w );
extern void wbm_sslid( WININFO *w, WORD vertical );
extern void wbm_sstr( WININFO *w );
extern void wbm_sattr( WININFO *w, WORD chbits );
extern void wbm_calc( WORD kind, WORD *fg );
extern WORD wbm_obfind( WININFO *w, WORD x, WORD y );
