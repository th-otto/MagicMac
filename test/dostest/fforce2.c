/* Umlenken von Handle -1 */

#include <tos.h>
#include <stdio.h>

#define HDL_CON -1

int main(void)
{
	long ret;
	int newhdl;


	ret = Fopen("U:\\DEV\\NULL", 2);
	if	(ret < 0)
		return((int) ret);
	newhdl = (int) ret;
	ret = Fforce(HDL_CON, newhdl);
	Fclose(newhdl);
	return(0);
}