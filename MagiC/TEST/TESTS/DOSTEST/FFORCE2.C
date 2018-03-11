/* Umlenken von Handle -1 */

#include <tos.h>
#include <stdio.h>
#include <magx.h>

int main()
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