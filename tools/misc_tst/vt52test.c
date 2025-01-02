#include <tos.h>

static const char *const color_names[16] = {
	"white",
	"red",
	"green",
	"yellow",
	"blue",
	"magenta",
	"cyan",
	"light grey",
	"dark grey",
	"dark red",
	"dark green",
	"dark yellow",
	"dark blue",
	"dark magenta",
	"dark cyan",
	"black"
};

static void set_fgcolor(int color)
{
	Cconout(0x1b);
	Cconout('b');
	Cconout(color);
}

static void set_bgcolor(int color)
{
	Cconout(0x1b);
	Cconout('c');
	Cconout(color);
}

int main(void)
{
	int i;
	
	for (i = 0; i < 16; i++)
	{
		set_fgcolor(i);
		Cconws(color_names[i]);
		Cconws("\r\n");
	}
	set_bgcolor(15);
	for (i = 0; i < 16; i++)
	{
		set_fgcolor(i);
		Cconws(color_names[i]);
		Cconws("\r\n");
	}
	
	set_bgcolor(0);
	set_fgcolor(15);
	return 0;
}
