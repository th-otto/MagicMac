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


int pxy[8];
MFDB mfdb_screen;


/* Raster-Kopie */

static void RasterCopyOpaque(
		int sx, int sy,
		int dx, int dy,
		int w, int h)
{
	register int i;


	pxy[0] = sx;		/* sx */
	pxy[1] = sy;		/* sy */
	pxy[2] = sx+w-1;	/* sx2 */
	pxy[3] = sy+h-1;	/* sy2 */

	pxy[4] = dx;		/* dx */
	pxy[5] = dy;		/* dy */
	pxy[6] = dx+w-1;	/* dx2 */
	pxy[7] = dy+h-1;	/* dy2 */

	for	(i = 0; i <= 15; i++)
	{
		vro_cpyfm(
				vdi_handle,
				i,		/* int vr_mode */
				pxy,
				&mfdb_screen,
				&mfdb_screen);

		pxy[4] += w + 5;
	/*	pxy[5] += h + 10;	*/
		pxy[6] += w + 5;
	/*	pxy[7] += h + 10;	*/
	}
}


static void RasterCopyTransparent(
		int sx, int sy,
		int dx, int dy,
		int w, int h,
		int col[2])
{
	register int i;


	pxy[0] = sx;		/* sx */
	pxy[1] = sy;		/* sy */
	pxy[2] = sx+w-1;	/* sx2 */
	pxy[3] = sy+h-1;	/* sy2 */

	pxy[4] = dx;		/* dx */
	pxy[5] = dy;		/* dy */
	pxy[6] = dx+w-1;	/* dx2 */
	pxy[7] = dy+h-1;	/* dy2 */

	for	(i = 1; i <= 4; i++)
	{
		vrt_cpyfm(
				vdi_handle,
				i,		/* int vr_mode */
				pxy,
				&mfdb_screen,
				&mfdb_screen,
				col);

		pxy[4] += w + 5;
	/*	pxy[5] += h + 10;	*/
		pxy[6] += w + 5;
	/*	pxy[7] += h + 10;	*/
	}
}


int main( void )
{
	register int i;
	int c[2];



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

	mfdb_screen.fd_addr = 0;


	RasterCopyOpaque(10, 10, 10, 100, 51, 40);

	RasterCopyOpaque(907, 671, 10, 300, 51, 40);

	c[0] = 0;
	c[1] = 1;
	RasterCopyTransparent(10, 10, 10, 500, 51, 40, c);

	return(0);
}