#include <aes.h>
#include <tos.h>

static void redraw(GRECT *g);

void main()
{
	int hdl;
	int message[8];


	appl_init();
	hdl = wind_create(SIZER+RTARROW, 0, 0, 100, 100);
	wind_open(hdl, 50, 50, 100, 100);
	for	(;;)
		{
		evnt_mesag(message);
		if	(message[0] == WM_REDRAW)
			{
			redraw((GRECT *) (message+4));
			}
		}
}


static OBJECT o = {
	-1,-1,-1,
	G_BOX,
	NONE,
	NORMAL,
	0L,
	0,0,0,0
	};
	
static void redraw(GRECT *g)
{
	o.ob_x = g->g_x;
	o.ob_y = g->g_y;
	o.ob_width = g->g_w;
	o.ob_height = g->g_h;
	objc_draw(&o, 0, 0, 0, 0, 0, 0);
}