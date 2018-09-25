#include <tos.h>
#include <stdlib.h>

#define inpipe  "u:\\pipe\\TestIn"
#define outpipe "u:\\pipe\\TestOut"

int main(void)
{
 int out[2], in[2];
 long bytes, start;
 char buffer[300];
 long ret;

	out[1]=(int)Fcreate(outpipe,0);
	if	(out[1]<0)
 		return(-1);
 	ret = Fopen(outpipe,0);
 	ltoa(ret, buffer, 10);
 	Cconws("out[0] = ");
 	Cconws(buffer);
 	Cconws("\r\n");
	out[0]=(int) ret;
	if	(out[0]<0)
 		return(-1);

	in[1]=(int)Fcreate(inpipe,FA_SYSTEM);
	if	(in[1]<0)
		return(-1);
	in[0]=(int)Fopen(inpipe,0);
	if	(in[0]<0)
		return(-1);
	Fforce(0,in[0]);

	if	(Fforce(1,out[1]))
		return(-2);

	start=Pexec(100,"out.tos","",0L);
     if	(start<0L)
     	return(-1);

      for(;;)
	      {
	      bytes = gemdos(0x105, out[0]);
 /*     	 bytes=Finstat(out[0]);	*/
	       if(bytes>0)
    		   {
    			   return(0);
 	      }
 	      else if(bytes<0) break;
 	     }

 return(0);
}
