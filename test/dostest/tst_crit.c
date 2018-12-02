#include <tos.h>
#include <aes.h>

int main()
{
	int dummy, kstate;

	appl_init();
	while(1)
		{
		graf_mkstate(&dummy, &dummy, &dummy, &kstate);
		if	((kstate & K_LSHIFT) && (kstate & K_RSHIFT))
			Fopen("A:\\mist", 0);
		}
}