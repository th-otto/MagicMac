/* Umlenken der BIOS-Kan„le */

#include <tos.h>
#include <stdio.h>

#define HDL_PRN -3

int main()
{
	long ret;
	int oldhdl;
	int newhdl;


	ret = Fdup(HDL_PRN);
	if	(ret < 0)
		return((int) ret);
	oldhdl = (int) ret;
	ret = Fcreate("out", 0);
	if	(ret < 0)
		{
		Fclose(oldhdl);
		return((int) ret);
		}
	newhdl = (int) ret;
	ret = Fforce(HDL_PRN, newhdl);
	Fclose(newhdl);
	if	(ret < 0)
		{
		Fclose(oldhdl);
		return((int) ret);
		}
	Cconin();
	Fforce(HDL_PRN, oldhdl);
	Fclose(oldhdl);
	return(0);
}