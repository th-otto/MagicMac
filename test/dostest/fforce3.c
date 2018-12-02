/* Umlenken von STDERR */

#include <tos.h>
#include <stdio.h>

int main()
{
	long ret,ret2;
	int oldhdl;
	int newhdl;


	printf("meine Basepage ist %08lx\n", _BasPag);
	printf("act_pd = %08lx\n", *((long *) 0x2ba8));
	ret = Fdup(STDERR);
	printf("Fdup(STDERR) => %ld\n", ret);
	Cconws("Taste ");Cconin();
	if	(ret < 0)
		return((int) ret);
	oldhdl = (int) ret;
	ret = Fcreate("out", 0);
	printf("Fcreate(\"out\", 0) => %ld\n", ret);
	if	(ret < 0)
		{
		Fclose(oldhdl);
		return((int) ret);
		}
	newhdl = (int) ret;
	ret = Fforce(STDERR, newhdl);
	printf("Fforce(STDERR, %d) => %ld\n", newhdl, ret);
	ret2 = Fclose(newhdl);
	printf("Fclose(%d) => %ld\n", newhdl, ret2);
	if	(ret < 0)
		{
		Fclose(oldhdl);
		return((int) ret);
		}
	Cconws("Taste ");Cconin();
	Fwrite(STDERR, 4L, "test");
	ret = Fforce(STDERR, oldhdl);
	printf("Fforce(STDERR, %d) => %ld\n", oldhdl, ret);
	Cconws("Taste ");Cconin();
	ret2 = Fclose(oldhdl);
	printf("Fclose(%d) => %ld\n", oldhdl, ret2);
	Cconws("Taste ");Cconin();
	return(0);
}