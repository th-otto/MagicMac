/*****************************************************************
*
* Erledigt fÅr Mag!X 4.01 den Writeback- Cache
*
*****************************************************************/

#include <aes.h>
#include <tos.h>
#include <magx.h>



#define	SIGFREEZE		100
#define	SIGIGN		1L

/* shel_write modes for parameter "doex" */

#define SHW_NOEXEC       0
#define SHW_EXEC         1
#define SHW_SHUTDOWN     4                                  /* AES 3.3     */
#define SHW_INFRECGN     9                                  /* AES 4.0     */
#define SHW_AESSEND      10                                 /* AES 4.0     */

int main()
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

	if	(gemdos((int) SCONFIG, (int) SC_WBACK, (int) SCWB_SET) < 0L)
		return(-1);

	/* Einfrieren einfach verhindern */
	/* ----------------------------- */

	if	(Psignal(SIGFREEZE, (void *) SIGIGN))
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

		Ssync();
		}
}
