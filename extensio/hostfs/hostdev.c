/*
 *
 * Device driver part for the hostfs.xfs for MagiX.
 * Based on Andreas Kromke's port of the cd-xfs
 *
 * (C) Thorsten Otto 2018
 *
 */

#include "hostfs.h"
#include "util.h"


/*******************************************************************
 *
 * Wir bekommen hier die Gelegenheit, evtl. Schreibpuffer o.ae.
 * zurueckzuschreiben, bevor die Datei geschlossen wird.
 * Auf dem HOSTFS brauchen wir nur den Deskriptor freizugeben.
 *
 *******************************************************************/

static LONG __CDECL dev_close(MX_FD *f)
{
	HOSTXFS_FD *fd = (HOSTXFS_FD *) f;
	long ret;
	short pid = Pgetpid();
	
	DEBUGPRINTF(("dev_close\n"));
	if ((ret = check_fd(fd)) < 0)
		return ret;
#if 0
	if (fd->fp.flags & O_LOCK)
	{
		MINT_LOCK *lock;
		MINT_LOCK **oldlock;
		
		MINT_LOCK *hostfs_lock;
		MINT_LOCK **locks = &hostfs_lock;
		long r;
		
		r = nf_call(HOSTFS(DEV_IOCTL), &fd->fp, (long)F_GETLK, locks);
		if (r == 0)
		{
			oldlock = locks;
			lock = *oldlock;
			
			while (lock)
			{
				if (lock->l.l_pid == pid)
				{
					*oldlock = lock->next;
					wake(IO_Q, (long) lock);
					kfree(lock);
				} else
				{
					oldlock = &lock->next;
				}
				lock = *oldlock;
			}
			r = nf_call(HOSTFS(DEV_IOCTL), &fd->fp, (long)F_SETLK, locks);
		}
	}
#endif

	ret = nf_call(HOSTFS(DEV_CLOSE), &fd->fp, (long)pid);
#if DEBUG
	if (ret != E_OK)
	{
		DEBUGPRINTF(("host returned %ld when trying to close FD %08lx\n", ret, fd));
	}
#endif
	if (ret == E_OK)
	{
		if (fd->fd.fd_refcnt)
			fd->fd.fd_refcnt--;
		if (!fd->fd.fd_refcnt)
			kernel_int_mfree(fd);
	}
	return ret;
}


/*******************************************************************
 *
 * analog to MiNT fs_dev_read
 *
 *******************************************************************/

/*
 * unlike MiNT, we have to check the access modes and range here.
 * In our case, it is easy, since the host does that already
 */
static LONG __CDECL dev_read(MX_FD *f, LONG count, void *buf)
{
	HOSTXFS_FD *fd = (HOSTXFS_FD *) f;
	LONG err;
	
	DEBUGPRINTF(("dev_read\n"));
	if ((err = check_fd(fd)) < 0)
		return err;

	return nf_call(HOSTFS(DEV_READ), &fd->fp, buf, count);
}


/*******************************************************************
 *
 * analog to MiNT fs_dev_write
 *
 *******************************************************************/

static LONG __CDECL dev_write(MX_FD *f, LONG count, void *buf)
{
	HOSTXFS_FD *fd = (HOSTXFS_FD *) f;
	LONG err;

	DEBUGPRINTF(("dev_write\n"));
	if ((err = check_fd(fd)) < 0)
		return err;

	return nf_call(HOSTFS(DEV_WRITE), &fd->fp, buf, count);
}


/*******************************************************************
 *
 * corresponds to MiNT's select/unselect callbacks.
 * In ARAnyM at least, these functions are not implemented,
 * so we just do some permission checks here.
 *
 *******************************************************************/

static LONG __CDECL dev_stat(MX_FD *f, MAGX_UNSEL *unselect, WORD rwflag, LONG apcode)
{
	HOSTXFS_FD *fd = (HOSTXFS_FD *) f;
	LONG err;
	
	DEBUGPRINTF(("dev_stat\n"));
	if ((err = check_fd(fd)) < 0)
	{
		;
	}
	/*
	 * check whether we are allowed to read
	 */
	else if (!rwflag && (fd->fd.fd_mode & (OM_RPERM | OM_EXEC)) == 0)
	{
		err = EACCDN;
	}
	/*
	 * check whether we are allowed to write
	 */
	else if (rwflag && (fd->fd.fd_mode & OM_WPERM) == 0)
	{
		err = EACCDN;
	} else if (apcode)					/* komplizierter Fall */
	{
		/* nf_call(HOSTFS(DEV_SELECT), &fd->fp, proc, (long)rwflag); */
		err = 1;						/* device ready */
	} else
	{									/* polling */
		/* nf_call(HOSTFS(DEV_UNSELECT), &fd->fp, proc, (long)rwflag); */
		err = 1;
	}
	if (unselect)
		unselect->unsel.status = err;
	return err;
}


/*******************************************************************
 *
 * analog to MiNT fs_dev_lseek
 *
 *******************************************************************/

/*
 * unlike MiNT, we have to check the range here.
 * In our case, it is easy, since the host does that already
 */
static LONG __CDECL dev_seek(MX_FD *f, LONG offset, WORD whence)
{
	HOSTXFS_FD *fd = (HOSTXFS_FD *) f;
	LONG err;
	
	DEBUGPRINTF(("dev_seek\n"));
	if ((err = check_fd(fd)) < 0)
		return err;

	return nf_call(HOSTFS(DEV_LSEEK), &fd->fp, offset, (long)whence);
}


/*******************************************************************
 *
 * analog to MiNT fs_dev_datime
 *
 *******************************************************************/

static LONG __CDECL dev_datime(MX_FD *f, WORD timeptr[2], WORD set)
{
	HOSTXFS_FD *fd = (HOSTXFS_FD *) f;
	LONG err;

	DEBUGPRINTF(("dev_datime\n"));
	if ((err = check_fd(fd)) < 0)
		return err;

	return nf_call(HOSTFS(DEV_DATIME), &fd->fp, timeptr, (long)set);
}


/*******************************************************************
 *
 * analog to MiNT fs_dev_ioctl
 *
 *******************************************************************/

static LONG __CDECL dev_ioctl(MX_FD *f, WORD cmd, void *buf)
{
	HOSTXFS_FD *fd = (HOSTXFS_FD *) f;
	LONG err;

	DEBUGPRINTF(("dev_ioctl\n"));
	if ((err = check_fd(fd)) < 0)
		return err;

	switch (cmd)
	{
	case F_SETLK:
	case F_SETLKW:
	case F_GETLK:
#if 0
		/*
		 * The hostfs part in the emulator will never be able to
		 * emulate file locking, since it does not have any notice of
		 * MiNT processes, so these calls have to be handled here.
		 * We need some help here however: the per-file lock list ptr
		 * must be initialized.
		 */
		{
			MINT_LOCK *hostfs_lock;
			MINT_LOCK **locks = &hostfs_lock;
			struct flock *fl = (struct flock *) buf;
			MINT_LOCK t;
			MINT_LOCK *lck;
			long r;
			int cpid;		/* Current proc pid */
			
			r = nf_call(HOSTFS(DEV_IOCTL), &fd->fp, (long)F_GETLK, locks);
			if (r < 0)
				return r;
			t.l = *fl;
	
			switch (t.l.l_whence)
			{
			case SEEK_SET:
				break;
			case SEEK_CUR:
				r = dev_seek(f, 0L, SEEK_CUR);
				t.l.l_start += r;
				break;
			case SEEK_END:
				r = dev_seek(f, 0L, SEEK_CUR);
				t.l.l_start = dev_seek (f, t.l.l_start, SEEK_END);
				(void) dev_seek(f, r, SEEK_SET);
				break;
			default:
				DEBUG (("hostfs_ioctl: invalid value for l_whence"));
				return ENOSYS;
			}
	
			if (t.l.l_start < 0)
				t.l.l_start = 0;
			t.l.l_whence = 0;
	
			cpid = Pgetpid();
	
			if (mode == F_GETLK)
			{
				lck = denylock (cpid, *locks, &t);
				if (lck)
					*fl = lck->l;
				else
					fl->l_type = F_UNLCK;
	
				return E_OK;
			}
	
			if (t.l.l_type == F_UNLCK)
			{
				/* try to find the lock */
				MINT_LOCK **lckptr = locks;
	
				lck = *lckptr;
				while (lck)
				{
					if (lck->l.l_pid == cpid
					    && ((lck->l.l_start == t.l.l_start && lck->l.l_len == t.l.l_len) ||
						    (lck->l.l_start >= t.l.l_start && t.l.l_len == 0)))
					{
						/* found it -- remove the lock */
						*lckptr = lck->next;
						DEBUGPRINTF(("hostfs_ioctl: unlocked #%li: %ld + %ld", f->fc.index, t.l.l_start, t.l.l_len));
						
						/* wake up anyone waiting on the lock */
						wake(IO_Q, (long) lck);
						kfree(lck);
	
						nf_call(HOSTFS(DEV_IOCTL), &fd->fp, (long)F_SETLK, locks);
						return E_OK;
					}
	
					lckptr = &(lck->next);
					lck = lck->next;
				}
	
				return ENSLOCK;
			}
	
			DEBUGRINT(("hostfs_ioctl: lock #%li: %ld + %ld", &fd->fp.fc.index, t.l.l_start, t.l.l_len));
	
			/* see if there's a conflicting lock */
			while ((lck = denylock(cpid, *locks, &t)) != 0)
			{
				DEBUG (("hostfs_ioctl: lock conflicts with one held by %d", lck->l.l_pid));
				if (mode == F_SETLKW)
				{
					/* sleep a while */
					sleep(IO_Q, (long) lck);
				} else
				{
					return ELOCKED;
				}
			}
	
			/* if not, add this lock to the list */
			lck = kmalloc (sizeof (*lck));
			if (!lck)
			{
				/* KERNEL_ALERT ("HostFS: kmalloc fail in: hostfs_ioctl: #%li", f->fc.index); */
				return ENOMEM;
			}
	
			lck->l = t.l;
			lck->l.l_pid = cpid;
	
			lck->next = *locks;
			*locks = lck;
	
			/* mark the file as being locked */
			f->flags |= O_LOCK;
			nf_call(HOSTFS(DEV_IOCTL), &fd->fp, (long)F_SETLK, locks);
		}
		return E_OK;
#else
		return ENOSYS;
#endif
	}
		
	return nf_call(HOSTFS(DEV_IOCTL), &fd->fp, (long)cmd, buf);
}


/*******************************************************************
 *
 * Standardprozedur, um auf Nicht-Terminals dev_getc() auf
 * dev_read() zurueckzufuehren.
 *
 * Geschickter waere es hier, wenn der Kernel selbstaendig diese
 * Prozedur ausfuehren koennte, falls das XFS kein dev_getc() hat.
 *
 *******************************************************************/

static LONG __CDECL dev_getc(MX_FD *f, WORD mode)
{
	unsigned char c;
	LONG ret;

	DEBUGPRINTF(("dev_getc\n"));
	UNUSED(mode);
	ret = dev_read(f, 1, &c);
	if (ret < 0)
		return ret;					/* Fehler   */
	if (!ret)
		return 0x0000ff1a;			/* EOF */
	return c;
}


/*******************************************************************
 *
 * Standardprozedur, um auf Nicht-Terminals dev_getline() auf
 * dev_read() zurueckzufuehren.
 *
 *******************************************************************/

static LONG __CDECL dev_getline(MX_FD *f, char *buf, WORD mode, LONG size)
{
	unsigned char c;
	LONG gelesen, ret;

	DEBUGPRINTF(("dev_getline\n"));
	UNUSED(mode);
	for (gelesen = 0; gelesen < size;)
	{
		ret = dev_read(f, 1, &c);
		if (ret < 0)
			return ret;					/* Fehler */
		if (ret == 0)
			break;						/* EOF  */
		if (c == 0x0d)
			continue;
		if (c == 0x0a)
			break;
		gelesen++;
		*buf++ = c;
	}
	return gelesen;
}


/*******************************************************************
 *
 * Standardprozedur, um auf Nicht-Terminals dev_putc() auf
 * dev_write() zurueckzufuehren.
 *
 *******************************************************************/

static LONG __CDECL dev_putc(MX_FD *f, WORD mode, LONG val)
{
	unsigned char c;

	DEBUGPRINTF(("dev_putc\n"));
	UNUSED(mode);
	c = (unsigned char) val;
	return dev_write(f, 1, &c);
}


/*
 * Die cdecl-Device-Struktur fuer den Assembler-Umsetzer:
 */
CDECL_MX_DEV const cdecl_hostdev = {
	dev_close,
	dev_read,
	dev_write,
	dev_stat,
	dev_seek,
	dev_datime,
	dev_ioctl,
	dev_getc,
	dev_getline,
	dev_putc
};
