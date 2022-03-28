#include <aes.h>
#include <tos.h>

#ifndef FALSE
#  define FALSE 0
#  define TRUE  1
#endif
#ifndef _WORD
#  ifdef __PUREC__
#    define _WORD int
#  else
#    define _WORD short
#  endif
#endif

#define VA_START			0x4711
#define AV_STARTPROG		0x4722
#define AV_STARTED			0x4738


static _WORD apID;
static _WORD sd_action = 0;

long cdecl mpc_control(long funcno, ...);
long cdecl mpc_call(char *path, long pathnamelen, char *arg, long arglen);
long cdecl mpc_debout(const char *str, ...);

#define MPC_INIT                0x10
#define MPC_EXIT                0x11
#define MPC_CONTROL             0x20
#define MPC_SHUTDOWN_START      0x21
#define MPC_SHUTDOWN_COMPLETED  0x22
#define MPC_SHUTDOWN_CANCELED   0x23
#define MPC_EXECUTE             0x30
#define MPC_RUN_EXE             0x31
#define MPC_DEBUGOUT            0x40

static long getjar(void)
{
	return *((long *)0x5a0);
}


static int getCookie(long id, long *val)
{
	long *jar;
	
	jar = (long *)Supexec(getjar);
	if (jar == 0)
	{
		return 0;
	} else
	{
		while (*jar != 0)
		{
			if (*jar == id)
			{
				*val = jar[1];
				return TRUE;
			}
			jar += 2;
		}
	}
	return FALSE;
}


static int doShutdown(void)
{
	_WORD msg[8];
	
	msg[0] = AP_TERM;
	msg[1] = -1;
	msg[2] = 0;
	msg[3] = -1;
	msg[4] = 0;
	msg[5] = AP_TERM;
	msg[6] = 0;
	msg[7] = 0;
	appl_write(0, 16, msg);
	return TRUE;
}


static _WORD starte_prog(char *path, char *arg)
{
	_WORD msg[8];
	
	msg[0] = AV_STARTPROG;
	msg[1] = apID;
	msg[2] = 0;
	*((char **)&msg[3]) = path;
	*((char **)&msg[5]) = arg;
	msg[7] = -1;
	appl_write(0, 16, msg);
	return msg[7];
}


static void starte_exe(_WORD *msg)
{
	char *path;
	_WORD from;
	_WORD message[8];
	
	path = *((char **)&msg[3]);
	from = msg[1];
	mpc_control(MPC_RUN_EXE, path);
	message[0] = AV_STARTED;
	message[1] = apID;
	message[2] = 0;
	message[3] = msg[3];
	message[4] = msg[4];
	message[5] = message[6] = message[7] = 0;
	appl_write(from, 16, message);
}


int main(void)
{
	long v;
	int done;

	done = FALSE;
	apID = appl_init();

	if (getCookie(0x4d675043L, &v) == 0)
	{
		_WORD message[8];

		for (;;)
		{
			evnt_mesag(message);
			if (message[0] == AC_OPEN)
				form_alert(1, "[3][MPC_ACC unn\224tig!][ OK ]");
		}
	}
	
	{
		char path[256];
		char args[256];
		_WORD message[8];
		_WORD mox;
		_WORD moy;
		_WORD button;
		_WORD kstate;
		_WORD key;
		_WORD clicks;
		_WORD events;

		mpc_control(MPC_INIT);
		
		for (;;)
		{
			events = evnt_multi(MU_MESAG | MU_TIMER, 0, 0, 0,
				0, 0, 0, 0, 0,
				0, 0, 0, 0, 0,
				message,
				500,
				&mox, &moy, &button, &kstate, &key, &clicks);
			if (events & MU_MESAG)
			{
				switch (message[0])
				{
				case AC_OPEN:
					form_alert(1, "[3][MPC_ACC][ OK ]");
					break;
				
				case SHUT_COMPLETED:
					mpc_debout("\nshutdown: %i, %i, %i, %i, %i, %i", (long)message[1], (long)message[2], (long)message[3], (long)message[4], (long)message[5], (long)message[6]);
					if (message[3] != 0)
					{
						/* shutdown was successfull */
						mpc_control(MPC_SHUTDOWN_COMPLETED);
						sd_action = 2;
					} else
					{
						/* shutdown failed */
						mpc_control(MPC_SHUTDOWN_CANCELED);
						sd_action = 4;
					}
					break;
				
				case AP_TERM:
					mpc_debout("\nsd_action: %i", (long)sd_action);
					break;
				
				case VA_START:
					starte_exe(message);
					break;
				}
			}
			
			if (done)
				break;
			
			if (events & MU_TIMER)
			{
				if (mpc_control(MPC_CONTROL) != 0)
				{
					if (doShutdown() > 0)
					{
						mpc_control(MPC_SHUTDOWN_START);
						sd_action = 1;
					}
				}
				if (mpc_call(path, sizeof(path), args, sizeof(args)) > 0)
					starte_prog(path, args);
			}
		}
	}
	
	appl_exit();
	return 0;
}
