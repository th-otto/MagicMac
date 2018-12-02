/*
*
* Beispielprogramm fÅr VDI.
*
*/

#include <tos.h>
#include <stdio.h>
#include <aes.h>
#include <vdi.h>


int vdi_handle;
int work_out[57],work_in [12];	 /* VDI- Felder fÅr v_opnvwk() */
int	gl_hhbox, gl_hwbox, gl_hhchar, gl_hwchar;
int	ap_id;
int aes_handle;		/* Screen-Workstation des AES */


/* Raster-Kopie pixelweise */

static void RectCopy(
		int sx, int sy,
		int dx, int dy,
		int w, int h)
{
	register int iw,ih;
	union
	{
		struct
		{
			int index;
			int pel;
		} c;
		long val;
	} pixel;


	for	(ih = 0; ih < h; ih++)
	{
		for	(iw = 0; iw < w; iw++)
		{
			v_get_pixel(
					vdi_handle,
					sx + iw,
					sy + ih,
					&pixel.c.pel,
					&pixel.c.index);
		}
	}
}


int main( void )
{
	register int i;



	if   ((ap_id = appl_init()) < 0)
	{
		Cconws("Fehler bei appl_init()");
		Pterm(-1);
	}

	aes_handle = graf_handle(&gl_hwchar, &gl_hhchar, &gl_hwbox, &gl_hhbox);

	vdi_handle = aes_handle;
	for  (i = 0; i < 10; work_in[i++] = 1)
		;
	work_in[10]=2;                     /* Rasterkoordinaten */
	v_opnvwk(work_in, &vdi_handle, work_out);

	RectCopy(10, 10, 10, 100, 51, 40);

	return(0);
}