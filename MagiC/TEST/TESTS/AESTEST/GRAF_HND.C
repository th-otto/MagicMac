#include <aes.h>
#include <stdio.h>
#include <tos.h>

int main()
{
	int r,wc,hc,wb,hb;

	r = graf_handle(&wc, &hc, &wb, &hb);
	printf("%d %d %d %d %d\n", r, wc, hc, wb, hb);
	Cnecin();
	return(0);
}