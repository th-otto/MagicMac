/*
* übergib rgb-Tripel in Promille für die Iconwandlung
* bei "direct colour" Bildschirm-Modi.
*
* Ab MagiC 5.20 vom 20.11.97
*/

void *sys_recalc_cicon_colours( UWORD colour_values[3*256] )
{
	PARMDATA d;
	static WORD	c[] = { 0, 1, 1, 0 };

	d.intin[0] = 5;
	d.addrin[0] = colour_values;
	_mt_aes_alt( &d, c, NULL );
}
