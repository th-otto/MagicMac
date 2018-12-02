#include <tos.h>

#define FILENAME	"C:\\GEMSYS\\GEMSCRAP\\test.txt"
#define FATHER_MSG	"Das stammt vom Vaterprozež\r\n"
#define CHILD_MSG	"Das stammt vom Kindprozež\r\n"

#define UNUSED(x)	(void)(x)

#define KILLME		1

#undef SIGUSR1
#define SIGUSR1 29
#undef SIGUSR2
#define SIGUSR2 30


static void cdecl handle_sigusr1(long signal);

void main(void)
{
	int		handle,
			child;
	long	err;

	Pdomain(1);
	if ((long) Psignal(SIGUSR1, handle_sigusr1) == -32L)
	{
		Cconws("Psignal() fehlt!\r\n");
		Pterm(-1);
	}
	if (Pgetpid() == -32L)
	{
		Cconws("Pgetpid() fehlt!\r\n");
		Pterm(-1);
	}
	if (Pkill(Pgetpid(), 0) == -32L)
	{
		Cconws("Pkill() fehlt!\r\n");
		Pterm(-1);
	}
	if ((err = Fcreate(FILENAME, 0)) < 0L)
	{
		Cconws("Fcreate() fehlgeschlagen!\r\n");
		Pterm(-1);
	}
	handle = (int)err;
	if ((err = Pfork()) == -32L)
	{
		Cconws("Pfork() fehlt!\r\n");
		Fclose(handle);
		Fdelete(FILENAME);
		Pterm(-1);
	}
	if (err < 0L)
	{
		Cconws("Pfork() fehlgeschlagen!\r\n");
		Fclose(handle);
		Fdelete(FILENAME);
		Pterm(-1);
	}
	child = (int)err;
	if (child)
	{
		/* Vaterprozess */
		Cconws("Ich bin der Elterprozež.\r\n");
		Cconws("Meine Domain ist ");Cconws((Pdomain(-1)) ? "MiNT\r\n" : "TOS\r\n");
		Fwrite(handle, sizeof(FATHER_MSG) - 1, FATHER_MSG);
		Fclose(handle);
		Pterm(0);
	}
	else
	{
		/* Kindprozess */
		Cconws("Ich bin der Kindprozež.\r\n");
		Cconws("Meine Domain ist ");Cconws((Pdomain(-1)) ? "MiNT\r\n" : "TOS\r\n");
		Fwrite(handle, sizeof(CHILD_MSG) - 1, CHILD_MSG);
		Fclose(handle);
#ifdef KILLME
		Pkill(Pgetpid(), SIGUSR1);
#endif
		Pterm(0);
	}
	/* Not reached */
}

static void cdecl handle_sigusr1(long signal)
{
	UNUSED(signal);
	Cconws("SIGUSR1 erhalten\r\n");
}
