#include <aes.h>
#include <magx.h>
#include <tos.h>

#ifndef TRUE
#define TRUE	1
#define FALSE	0
#endif

int main()
{
	char tail[] = "\xff"	"sis is e test "
						"dies ist ein Text "
						"ille est une teste "
						"este es un testo "
						"dobr dinske iste teste "
						"ching hong ping test "
						"pruschni gruschni tesni "
						"blubbi labi suelzi";
	int doex,isgr;

	appl_init();
	doex = 1;
	isgr = TRUE;
	/* shel_write fÅr MTOS */
	shel_write(doex, isgr, TRUE, "c:\\bin\\cmdline.prg", tail);
	appl_exit();
	return(0);
}
