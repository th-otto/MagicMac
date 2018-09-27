/* externe Wandelfunktionen in Assembler-Code */
extern	void	xp_ip_4( void );
extern	void	xp_ip_8( void );
extern	void	xp_pp_4( void );
extern	void	xp_pp_8( void );
extern	void	xp_pp_16( void );
extern	void	xp_pp_24( void );
extern	void	xp_pp_32( void );
extern	LONG	W_mul_L( UWORD a, UWORD b );		/* entspricht mulu: w * w => l */
extern	WORD	L_div_W( ULONG a, UWORD b );		/* entspricht divu: l / w => w */
extern void _vq_scrninfo( VDIPB *vpb, WORD *work_out );
extern void _vq_color( VDIPB *vpb, WORD index, WORD setflag );
extern void *xp_raster;
extern void *xp_rasterC;