/*****************************************************************
*
* Erledigt fÅr Mag!X 4.01 den Writeback- Cache
*
*****************************************************************/

#include <aes.h>
#include <tos.h>



#define	SIGFREEZE		100
#define	SIGIGN		((__mint_sighandler_t)1L)



int main(void)
{
	int ev;
	int buf[16];


	if	(appl_init() < 0)
		return(-1);

	/* dem AES sagen: ich verstehe AP_TERM */
	/* ----------------------------------- */

	shel_write(SHW_INFRECGN, 1, 0, (void * )0, (void *) 0);

	/* Writeback aktivieren */
	/* -------------------- */

	/*
	 * Sconfig 2nd Parameter is a long, except for SC_WBACK,
	 * which expects a short only
	 */
	if	(Sconfig(SC_WBACK, ((long)SCWB_SET << 16) | SCWB_SET) < 0L)
		return(-1);

	/* Einfrieren einfach verhindern */
	/* ----------------------------- */

	if	(Psignal(SIGFREEZE, SIGIGN))
		return(-2);

	for	(;;)
	{
		/* evnt_timer(500, 0);	*/	/* 0,5s warten */

		/* MagiC 3.0: evnt_xmesag mit Timeout in 50Hz- Schritten */
		ev = appl_read(-2, 25, buf);
		if	(ev & MU_MESAG)
		{
			if	(buf[0] == AP_TERM)
				return(0);		/* Ende */
		}

		Sync();
	}
}
