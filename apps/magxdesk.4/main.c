#line 1/*ACE 4 0073 */
#include <gemfast.h>

/*
 * AV-Meldungen
 */
#define AV_PROTOKOLL        0x4700
#define VA_PROTOSTATUS      0x4701
#define AV_GETSTATUS        0x4703
#define AV_STATUS           0x4704
#define VA_SETSTATUS        0x4705
#define AV_SENDKEY          0x4710
#define VA_START            0x4711
#define AV_ASKFILEFONT      0x4712
#define VA_FILEFONT         0x4713
#define AV_ASKCONFONT       0x4714
#define VA_CONFONT          0x4715
#define AV_ASKOBJECT        0x4716
#define VA_OBJECT           0x4717
#define AV_OPENCONSOLE      0x4718
#define VA_CONSOLEOPEN      0x4719
#define AV_OPENWIND         0x4720
#define VA_WINDOPEN         0x4721
#define AV_STARTPROG        0x4722
#define VA_PROGSTART        0x4723
#define AV_ACCWINDOPEN      0x4724
#define VA_DRAGACCWIND      0x4725
#define AV_ACCWINDCLOSED    0x4726
#define AV_COPY_DRAGGED     0x4728
#define VA_COPY_COMPLETE    0x4729
#define AV_PATH_UPDATE      0x4730
#define AV_WHAT_IZIT        0x4732
#define VA_THAT_IZIT        0x4733
#define AV_DRAG_ON_WINDOW   0x4734
#define VA_DRAG_COMPLETE    0x4735
#define AV_STARTED          0x4738
#define AV_XWIND            0x4740
#define VA_XOPEN            0x4741
#define AV_VIEW             0x4751
#define VA_VIEWED           0x4752
#define AV_FILEINFO         0x4753
#define VA_FILECHANGED      0x4754
#define AV_COPYFILE         0x4755
#define VA_FILECOPIED       0x4756
#define AV_DELFILE          0x4757
#define VA_FILEDELETED      0x4758
#define AV_SETWINDPOS       0x4759
#define VA_PATH_UPDATE      0x4760
#define AV_EXIT             0x4736

int Server = -1;

Send(dest, what, m3, m4, m5, m6, m7)
int dest, what, m3, m4, m5, m6, m7;
{
	static int msg[8];
	register int    *m;

	if (dest == -1) {
		dest = appl_find("MAGXDESK");
		if (dest >= 0)
			Server = dest;
		else
			return;
	}

	m = msg;
	*m++ = what;
	*m++ = global[2];
	*m++ = 0;
	*m++ = m3;
	*m++ = m4;
	*m++ = m5;
	*m++ = m6;
	*m++ = m7;
	appl_write(dest, 16, msg);
}

XSend(int *msg)
{
	Send(Server, msg[0], msg[3], msg[4], msg[5], msg[6], msg[7]);
}

_main()
{
	int     msg[8], id, t;
	char    *path;
	GRECT   rv;

	appl_init();
	do {
		evnt_mesag(msg);
		switch(msg[0]) {
			case AP_TERM:
				goto quit;

			case AV_WHAT_IZIT:
				id = wind_find(msg[3], msg[4]);     // Fenster finden
				t = 0;
				if (id>0) {                         // da ist eines
					winx_get(id, WF_OWNER, &rv);    // Eigentmer finden
					id = rv.g_x;                    // merken
					t = 7;                          // Typ ist Fenster
				}
				else
					id = 0;                         // im Zweifel: Desktop
				Send(msg[1], VA_THAT_IZIT, id, t, 0L, 0);
				break;

			case AV_SENDKEY:
				winx_get(0, WF_TOP, &rv);       // top, owner, below
				t = msg[4]>>8;
				if ((t == 17) && (msg[3] == K_CTRL)) {
					id = rv.g_w;                                // below
					winx_get(id, WF_OWNER, &rv);                // owner
					Send(rv.g_x, WM_TOPPED, id, 0L, 0L);
				}
				else if (t == 22 && msg[3] == K_CTRL)
					Send(rv.g_y, WM_CLOSED, rv.g_x, 0L, 0L);
				break;

			case AV_DRAG_ON_WINDOW:
				Send(msg[1], VA_DRAG_COMPLETE, 0L, 0L, 0);
				break;

			case AV_PROTOKOLL:
				Send(msg[1], VA_PROTOSTATUS, 1+16+32+512+2048, 0L,
					 "AVSERVER");
				break;

			case SH_WDRAW:
			case AV_OPENWIND:
			case AV_XWIND:
			case AV_STARTPROG:
				XSend(msg);
				break;

			case AV_PATH_UPDATE:
				path = *(char **)&msg[3];
				Send(Server, SH_WDRAW, drive_from_letter(*path), 0L, 0L);
				break;
		}
	} while (1);
quit:
	appl_exit();
	_exit(0);
}




