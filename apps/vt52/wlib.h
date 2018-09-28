/*----------------------------------------------------------------------------------------*/
/* Funktionsdeklarationen                                                                 */
/*----------------------------------------------------------------------------------------*/
WORD	init_wlib( WORD id );
WORD	reset_wlib( void );
WINDOW	*get_window_list( void );
WINDOW	*search_struct( WORD handle );
WINDOW	*create_window( WORD kind, GRECT *border,
		WORD *handle, char *name, char *iconified_name,
		OBJECT *iconfied_tree );
void	set_slpos( WINDOW *window );
void	set_slsize( WINDOW *window );
void	redraw_window( WORD handle, GRECT *area );
void	delete_window( WORD handle );
void	move_window( WORD handle, GRECT *area );
void	arr_window( WORD handle, WORD command );
void	up_window( WINDOW *window, int32_t dy );
void	dn_window( WINDOW *window, int32_t dy );
void	lf_window( WINDOW *window, int32_t dx );
void	rt_window( WINDOW *window, int32_t dx );
void	hlsid_window( WORD handle, WORD hslid );
void	vslid_window( WORD handle, WORD vslid );
void	size_window( WORD handle, GRECT *size );
void	full_window( WORD handle, WORD max_width, WORD max_height );
void	iconify_window( WORD handle, GRECT *size );
void	uniconify_window( WORD handle, GRECT *size );
void	switch_window( void );

#if 1

#define	uppage_window( w )	up_window( w, w->workarea.g_h )
#define	dnpage_window( w )	dn_window( w, w->workarea.g_h )
#define	upline_window( w )	up_window( w, w->dy )
#define	dnline_window( w )	dn_window( w, w->dy )
#define	lfpage_window( w )	lf_window( w, w->workarea.g_w )
#define	rtpage_window( w )	rt_window( w, w->workarea.g_w )
#define	lfline_window( w )	lf_window( w, w->dx )
#define	rtline_window( w )	rt_window( w, w->dx )

#else
/* ersetzte Funktionen */
void	uppage_window( WINDOW *window );
void	dnpage_window( WINDOW *window );
void	upline_window( WINDOW *window );
void	dnline_window( WINDOW *window );
void	lfline_window( WINDOW *window );
void	rtline_window( WINDOW *window );
void	lfpage_window( WINDOW *window );
void	rtpage_window( WINDOW *window );
#endif
