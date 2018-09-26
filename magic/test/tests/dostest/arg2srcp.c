#include <tos.h>
#include <stdlib.h>
#include <stdio.h>

extern BASPAG *_BasPag;


int main(void)
{
	long ret;
	int fh;
	char *env;
	register char *s;


	env = _BasPag->p_env;
	if	(env)
		{
		ret = Fcreate("C:\\GEMSYS\\GEMSCRAP\\ENV.ARG", 0);
		if	(ret < 0)
			return((int) ret);
		fh = (int) ret;
		for	(s = env; (s[0]) || (s[1]); s++)
			;
		s += 2;
		Fwrite(fh, s - env, env);
		Fclose(fh);
		}
	return(0);
}