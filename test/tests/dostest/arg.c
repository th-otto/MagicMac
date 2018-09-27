#include <tos.h>
#include <tosdefs.h>
#include <stdio.h>


void readline(char *s, int len);


int main( void )
{
	char *cmdline2 = "\xff" "erster zweiter  dritter muell";
	char *cmdline3 = "\xff" "erster zweiter  dritter    vierter "
						"fnfter sechster siebter achter"
						" neunter zehnter elfter "
						"zw”lfter dreizehnter vierzehnter"
						" fnfzehnter sechszechnter achtzehnter";


	Pexec(0, "c:\\bin\\cmdline.tos", cmdline2, NULL);
	Cconws("\r\n");
	Pexec(0, "c:\\bin\\cmdline.tos", cmdline3, NULL);
	return(0);
}