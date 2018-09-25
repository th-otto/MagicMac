#include <stdio.h>
#include <tos.h>

#define inpipe  "u:\\pipe\\TestIn"
#define outpipe "u:\\pipe\\TestOut"

int main(void)
{
 int out[2], in[2];
 long bytes, start;
 char buffer[300];

 out[1]=(int)Fcreate(outpipe,0);
 if(out[1]>0)
 {
  out[0]=(int)Fopen(outpipe,0);
  if(out[0]>0)
  {
   Fforce(1,out[1]);
   in[1]=(int)Fcreate(inpipe,FA_SYSTEM);
   if(in[1]>0)
   {
    in[0]=(int)Fopen(inpipe,0);
    if(in[0]>0)
    {
     Fforce(0,in[0]);
     start=Pexec(100,"out.tos","",0L);
     fprintf(stderr,"Programmstart: %ld\n",start);
     if(start>=0L)
     {
      fprintf(stderr,"Waiting ...\n");
      for(;;)
      {
       bytes=gemdos(0x105,out[0]);
       if(bytes>0)
       {
        fprintf(stderr,"erwarte: %ld Bytes\n",bytes);
        fprintf(stderr,"gelesen: %ld Bytes\n",Fread(out[0],bytes<256 ? bytes : 256,buffer));
       }
       else if(bytes<0) break;
      }
     }
     else fprintf(stderr,"Can\'t start prog.\n");
     Fclose(in[0]);
    }
    else fprintf(stderr,"Fopen(inpipe) failed.\n");
    Fclose(in[1]);
   }
   else fprintf(stderr,"Fcreate(inpipe) failed.\n");
   Fclose(out[0]);
  }
  else fprintf(stderr,"Fopen(outpipe) failed.\n");
  Fclose(out[1]);
 }
 else fprintf(stderr,"Fcreate(outpipe) failed.\n");
 return(0);
}
