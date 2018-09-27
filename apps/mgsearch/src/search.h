extern long filesearch( char *startpath, char *pattern,
			int min_date, int max_date,
			long min_len, long max_len,
			int (*callback_ever)( void ),
			void (*callback)(char *path, char *fname) );


			