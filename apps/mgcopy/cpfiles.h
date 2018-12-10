extern void init_messages( void );
extern void send_shwdraw( void );
extern long prepare_action(int function,
				int cmode,
				int checkfree_flag,
				long *n_dat, long *n_ord,
				long *size_used_src, long *cl_used_dst,
				long *size_netto_src,
				long *cl_free_dst,
				long *clsize_dst,
				int argc, char *argv[],
				char *dest_path);
