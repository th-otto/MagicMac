#include <mgx_dos.h>
#include <stdio.h>


int main( void )
{
	long retcode;

	Pdomain(1);
	/* Schlieže Handle 0 */
	retcode = Fclose(0);
	printf("Fclose(0) => %ld\n", retcode);
	/* Dupliziere Handle 1 */
	retcode = Fcntl(1, 0, F_DUPFD);
	printf("Fcntl(F_DUPFD) von Handle 1 => %ld\n", retcode);
	return((int) retcode);
}