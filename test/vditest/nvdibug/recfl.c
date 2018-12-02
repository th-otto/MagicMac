/*
*
* Dieses Beispielprogramm zeigt den Fehler im NVDI.
* Das Clipping-Rechteck ist auûerhalb des Bildschirms,
* trotzdem wird eine schwarze Linie gezeichnet.
*
*/

#include <tos.h>
#include <aes.h>
#include <vdi.h>


int vdi_handle;
int work_out[57],work_in [12];	 /* VDI- Felder fÅr v_opnvwk() */
int	gl_hhbox, gl_hwbox, gl_hhchar, gl_hwchar;
int	ap_id;
int aes_handle;		/* Screen-Workstation des AES */


int main()
{
	register int i;
	int pxy[4];



	if   ((ap_id = appl_init()) < 0)
		Pterm(-1);
	aes_handle = graf_handle(&gl_hwchar, &gl_hhchar, &gl_hwbox, &gl_hhbox);

	vdi_handle = aes_handle;
	for  (i = 0; i < 10; work_in[i++] = 1)
		;
	work_in[10]=2;                     /* Rasterkoordinaten */
	v_opnvwk(work_in, &vdi_handle, work_out);


	/* Clipping setzen */
	/* --------------- */

	pxy[0] = -16;
	pxy[1] = 100;
	pxy[2] = -1;
	pxy[3] = 200;
	vs_clip(vdi_handle, 1, pxy);
	pxy[2] = 15;
	vr_recfl(vdi_handle, pxy);
	return 0;
}
