
void	double_to_tedinfo( OBJECT *obj, double n );
double	tedinfo_to_double( OBJECT *obj );
LONG	str_to_fixed( BYTE *str, WORD *bad_chars );
LONG	get_number( BYTE *text, BYTE **end, WORD *digits );
void	fixed_to_str( BYTE *str, WORD len, LONG number );
