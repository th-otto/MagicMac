#include <aes.h>
#include <tos.h>

void main()
{
	int message[8];


	appl_init();
	for	(;;)
		{
		evnt_mesag(message);
		if	(message[0] == AP_TERM)
			{
			break;
			}
		}
}
