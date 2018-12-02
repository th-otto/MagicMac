#include <tos.h>
#include <stdio.h>


int main( void )
{
	char	*cmdline1 = "\xfe" "ARGV=dreck" "\0" "erster " "\0" "zweiter" "\0";


	Pexec(0, "c:\\bin\\cmdline.tos", cmdline1, NULL);
	return(0);
}