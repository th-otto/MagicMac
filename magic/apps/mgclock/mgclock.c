/*****************************************************************
*
* Stellt eine Uhr dar.
*
*****************************************************************/

#include <aes.h>
#include <vdi.h>
#include <tos.h>

#define DATESEP 	'-'
#define TIMESEP	':'
#define RIGHTOFFSET 1


char	datetime[] = "                 ";

void date_to_str(char *s, unsigned int date);
void time_to_str(char *s, unsigned int time);

/* Modi:
	0	hh:mm
	1	hh:mm:ss
	2	tt.mm  hh:mm:ss
	3	tt.mm.jj  hh:mm:ss
*/

void main(void)
{
	int work_out[57],work_in [12];	 /* VDI- Felder fÅr v_opnvwk() */
	int sec,tp,ln;
	register int i;
	int x,y;
	int mode;
	int len    [] = { 5, 8, 15, 18};
	int timepos[] = { 0, 0,  7, 10};
	int secpos [] = {-1, 7, 14, 17};
	int vdi_handle;
	int dummy, scrw;
	int hwchar, hhbox, hhchar;


     if   (appl_init() < 0)
          return;

	for  (i = 0; i < 10; work_in[i++] = 1)
		;
	work_in[10]=2;                     /* Rasterkoordinaten */
	v_opnvwk(work_in, &vdi_handle, work_out);
	/* Ausrichtung Zeichenzellenoberkante */
	vst_alignment(vdi_handle, 0, 5, &dummy, &dummy);
	graf_handle(&hwchar, &hhchar, &dummy, &hhbox);
	y = (hhbox-hhchar) >> 1;
	wind_get(0, WF_WORKXYWH, &dummy, &dummy, &scrw, &dummy);
	i = 9;
	mode = 3;

	for (;;)
	{
		i++;
		if	(i == 10)
		{
			if (mode != 3)
				mode = 1;
			sec = secpos[mode];
			tp = timepos[mode];
			ln = len[mode];
			x  = scrw - (ln+RIGHTOFFSET) * hwchar;
			datetime[sec] = 1;
		}

		if	(sec >= 0 && datetime[sec] & 1)
		{
			if	(mode > 1)
				date_to_str(datetime, Tgetdate());
			if	(tp > 0)
				datetime[tp - 1] = datetime[tp - 2] = ' ';
			time_to_str(datetime+tp, Tgettime());
			datetime[ln] = '\0';
		}
		else	datetime[sec] += 1;
		v_gtext(vdi_handle, x, y, datetime);

		evnt_timer(1000);		/* 1s warten */
	}
}


/*********************************************************************
*
* Wandelt DOS- Datum in eine Zeichenkette um.
*
*********************************************************************/

void date_to_str(char *s, unsigned int date)
{
	int t,m;

	t = date & 31;
	date >>= 5;
	m = date & 15;
	date >>= 4;
	date += 80;
	date %=100;
	*s++ = t/10 + '0';
	*s++ = t%10 + '0';
	*s++ = DATESEP;
	*s++ = m/10 + '0';
	*s++ = m%10 + '0';
	*s++ = DATESEP;
	*s++ = date/10 + '0';
	*s++ = date%10 + '0';
/*	*s = '\0'; */
}


/*********************************************************************
*
* Wandelt DOS- Zeit in eine Zeichenkette um.
*
*********************************************************************/

void time_to_str(char *s, unsigned int time)
{
	int min,sec;

	sec = 2 * (time & 31);
	time >>= 5;
	min = time & 63;
	time >>= 6;
	*s++ = time/10 + '0';
	*s++ = time%10 + '0';
	*s++ = TIMESEP;
	*s++ = min/10 + '0';
	*s++ = min%10 + '0';
	*s++ = TIMESEP;
	*s++ = sec/10 + '0';
	*s++ = sec%10 + '0';
	*s = '\0';
}
