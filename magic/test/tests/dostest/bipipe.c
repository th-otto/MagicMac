/* Umlenken von STDERR */

#include <tos.h>
#include <stdio.h>

void main(void)

{
    long f_r, f_w;
    char buffer[10];
    
    f_r = Fcreate("U:\\PIPE\\pfeife", 0);
    f_w = Fopen("U:\\PIPE\\pfeife", FO_RW);
    
    if (f_w > 0) {
        Fwrite((int )f_w, 5, "Hallo");
    }
    if (f_r > 0) {
        Cconws("lese Buffer:>");
        Fread((int )f_r, 5, buffer);
        buffer[5] = '\0';
        Cconws(buffer);
        Cconws("<\r\n");
    }
    Fclose((int )f_r);
    Fclose((int )f_w);
}