#include <portab.h>
#include <tos.h>
#include <vdi.h>
#include "std.h"
#include "filediv.h"
#include "nvdi_wk.h"
#include "mxvdi.h"
#include "drivers.h"
#include "ph.h"

#define	OFFSCREEN_ptr OSC_ptr
#define	OFFSCREEN_count OSC_count

extern char gdos_path[];
extern WORD OFFSCREEN_count;
extern DRIVER *OFFSCREEN_ptr;


DRIVER *load_NOD_driver(ORGANISATION *info);
WORD unload_NOD_driver(DRIVER *drv);

WK *create_bitmap(DEVICE_DRIVER *device_driver, WK *dev_wk, MFDB *m, WORD *intin);
WORD delete_bitmap(WK *wk);
WK *create_wk(LONG wk_len);
void init_mono_NOD(DRVR_HEADER *);

static WORD delete_wk(WK *wk);

static WORD load_mono_NOD(void);
static WORD init_offscreen_drivers(const char *pattern);

/*----------------------------------------------------------------------------------------*/
/* Offscreen-Treiber im Ordner gdos_path scannen                                          */
/* Da sowohl OSD- als auch NOD-Treiber gesucht werden, kann fuer ein Bitformat mehr als   */
/* ein Treiber vorhanden sein. Das ist jedoch unkritisch, da init_offscreen_drivers die   */
/* Treiber rueckwaerts einsortiert, d.h. der letzte gefundene Treiber ist der erste in der*/
/* Liste. Daher werden bevorzugt die OSD-Treiber geladen.                                 */
/* Funktionsresultat:   1, wenn alles in Ordnung ist                                      */
/*----------------------------------------------------------------------------------------*/
WORD init_NOD_drivers(void)
{
	char tmp_path[256];

	OFFSCREEN_count = 0;
	OFFSCREEN_ptr = NULL;

	strgcpy(tmp_path, gdos_path);
	strgcat(tmp_path, "*.NOD");
	init_offscreen_drivers(tmp_path);								/* alle NOD-Treiber suchen */

	strgcpy(tmp_path, gdos_path);
	strgcat(tmp_path, "*.OSD");
	init_offscreen_drivers(tmp_path);								/* alle OSD-Treiber suchen */

	if (load_mono_NOD() == FALSE)									/* monochromer Treiber vorhanden? */
		return FALSE;

	if (OFFSCREEN_count == 0)										/* sind ueberhaupt Treiber vorhanden? */
		return FALSE;

	return TRUE;
}


static WORD init_offscreen_drivers(const char *tmp_path)
{
	DTA dta;
	DTA *old_dta;

	old_dta = Fgetdta();
	Fsetdta(&dta);

	if (Fsfirst(tmp_path, 0) == 0)	/* Datei gefunden */
	{
		do
		{
			char name[256];
			DRVR_HEADER head;

			strgcpy(name, gdos_path);
			strgcat(name, dta.d_fname);

			read_file(name, &head, sizeof(PH), sizeof(head));	/* Treiberheader laden */

			if (strgcmp(head.magic, OFFSCREEN_MAGIC) == 0 && head.version > 0x280)
			{
				DRIVER *drv;

				drv = (DRIVER *)Malloc_sys(sizeof(*drv));		/* Speicher fuer Treiberstruktur anfordern */
				if (drv != NULL)
				{
					strgcpy(drv->file_name, dta.d_fname);
					drv->file_size = dta.d_length;
					drv->file_path = gdos_path;
					drv->info = head.info;
					drv->used = 0;
					drv->code = 0;
					drv->wk_len = 0;
					drv->next = OFFSCREEN_ptr;
					OFFSCREEN_ptr = drv;
					OFFSCREEN_count++;
				}
			}
		} while (Fsnext() == 0);
	}

	Fsetdta(old_dta);

	return TRUE;
}


static WORD load_mono_NOD(void)
{
	ORGANISATION info;
	DRIVER *drv;
	static ORGANISATION mono_format = { 2, 1, 2, 1, 0, 0, 0 };
	
	info = mono_format;
	drv = load_NOD_driver(&info);
	if (drv != NULL)
	{
		init_mono_NOD(drv->code);
		return TRUE;
	}
	return FALSE;
}


/*----------------------------------------------------------------------------------------*/
/* Offscreen-Treiber laden                                                                */
/* Funktionsresultat:   Zeiger auf die Treiberstruktur oder 0                             */
/* info:                        Zeiger auf die Treiberbeschreibung                        */
/*----------------------------------------------------------------------------------------*/
DRIVER *load_NOD_driver(ORGANISATION *info)
{
	DRIVER *drv;

	for (drv = OFFSCREEN_ptr; drv != NULL; drv = drv->next)
	{
		/* uebereinstimmende Merkmale ueberpruefen */
		if (drv->info.colors == info->colors &&
			drv->info.planes == info->planes &&
			drv->info.format == info->format &&
			(drv->info.flags & info->flags) == info->flags)
		{
			if (drv->code == 0)
			{
				char name[256];
				
				strgcpy(name, drv->file_path);
				strgcat(name, drv->file_name);
				drv->code = load_prg(name);
			}
			
			if (drv->code != 0)	/* Treiber geladen? */
			{
				if (drv->used == 0)	/* ist der Treiber das erste Mal geladen worden? */
				{
					drv->wk_len = drv->code->init(&nvdi_struct);	/* dann initialisieren */
				}
				++drv->used;
				return drv;
			}
		}
	}
	return NULL;
}


/*----------------------------------------------------------------------------------------*/
/* Offscreen-Treiber freigeben                                                            */
/* Funktionsresultat:   1                                                                 */
/* drv:                     Zeiger auf die Treiberstruktur                                */
/*----------------------------------------------------------------------------------------*/
WORD unload_NOD_driver(DRIVER *drv)
{
	--drv->used;
	if (drv->used == 0)	/* Treiber nicht mehr benutzt? */
	{
		/* FIXME: call drv->code->reset */
		Mfree_sys(drv->code);	/* Speichr freigeben */
		drv->code = NULL;
	}
	return TRUE;
}


/*----------------------------------------------------------------------------------------*/
/* Programm-Datei laden und relozieren                                                    */
/* Funktionsresultat:   Zeiger auf den Programmstart oder 0                               */
/* name:                        Zeiger auf den kompletten Pfad mit Namen                  */
/*----------------------------------------------------------------------------------------*/
DRVR_HEADER *load_prg(const char *filename)
{
	DTA dta;
	DTA *old_dta;
	DRVR_HEADER *addr;

	addr = NULL;
	old_dta = Fgetdta();
	Fsetdta(&dta);

	if (Fsfirst(filename, 0) == 0)
	{
		LONG handle;

		handle = Fopen(filename, FO_READ);
		if (handle > 0)
		{
			PH phead;

			/* Programmheader laden */
			if (Fread((WORD)handle, sizeof(phead), &phead) == sizeof(phead))
			{
				if (phead.ph_branch == PH_MAGIC)	/* bra.s am Anfang? */
				{
					LONG memsize;

					memsize = dta.d_length + phead.ph_blen - phead.ph_slen;	/* anzufordernder Speicher	*/
					addr = (DRVR_HEADER *)Malloc_sys(memsize);
					if (addr != NULL)
					{
						LONG TD_len;
						LONG TDB_len;

						TD_len = phead.ph_tlen + phead.ph_dlen;	/* Laenge von Text- und Data-Segment */
						TDB_len = TD_len + phead.ph_blen;	/* Laenge von Text-, Data- und BSS-Segment */

						if (Fread((WORD)handle, TD_len, addr) == TD_len)	/* Code und Daten laden */
						{
							UBYTE *relo;
							LONG relo_len;

							Fseek(phead.ph_slen, (WORD)handle, SEEK_CUR);	/* Symboltabelle ueberspringen */
							clear_mem(phead.ph_blen, (char *)addr + TD_len);	/* BSS-Segment loeschen */
							
							relo = (UBYTE *)addr + TDB_len;	/* Zeiger auf die Relokationsdaten */
							
							relo_len = dta.d_length - sizeof(PH) - phead.ph_tlen - phead.ph_dlen - phead.ph_slen;	/* Laenge der Relokationsdaten */
							if (Fread((WORD)handle, relo_len, relo) == relo_len)
							{
								ULONG relo_offset;

								relo_offset = *((ULONG *)relo);	/* Startoffset fuer Relokationsdaten */
								relo += 4;
								if (relo_offset != 0)	/* Relokationsdaten vorhanden? */
								{
									UBYTE *code_ptr;
									UBYTE relo_val;

									code_ptr = (UBYTE *)addr + relo_offset;	/* erstes zu relozierendes Langwort */
									*((LONG *)code_ptr) += (LONG)addr;
									
									while ((relo_val = *relo++) != 0)
									{
										if (relo_val == 1)
										{
											code_ptr += 254;
										} else
										{
											code_ptr += (ULONG)relo_val;
											*((LONG *)code_ptr) += (LONG)addr;
										}
									}
								}
								Mshrink_sys(addr, TDB_len);		/* Speicher fuer Relokationsdaten freigeben */
							} else
							{
								Mfree_sys(addr);
								addr = NULL;
							}
						} else
						{
							Mfree_sys(addr);
							addr = NULL;
						}
					}
				}
			}
			Fclose((WORD)handle);
		}
	}
	
	Fsetdta(old_dta);

	if (addr)																/* Programm geladen? */
		clear_cpu_caches();												/* Caches loeschen */

	return addr;
}


/*-----------------------------------------------------------------------------------------*/
/* Offscreen-Treiber laden, Workstation oeffnen und initialisieren  und ggf. Speicher fuer */
/* die Bitmap anfordern.                                                                   */
/*                                                                                         */
/* Funktionsresultat:   Zeiger auf die Workstation oder 0L                                 */
/* device_driver:           Zeiger auf die Struktur des Geraetetreibers, dessen Handle bei */
/*                              v_opnbm() uebergeben wurde                                 */
/* dev_wk:                  Zeiger auf die zum Geraetetreiber gehoerende Workstation       */
/* m:                           Zeiger auf den MFDB der Bitmap                             */
/* intin:                   intin-Array wie es bei v_opnbm() vorliegt                      */
/*-----------------------------------------------------------------------------------------*/
WK *create_bitmap(DEVICE_DRIVER *device_driver, WK *dev_wk, MFDB *fdb, WORD *intin)
{
	WK *bitmap;
	DRIVER *drv;
	ORGANISATION info;

	bitmap = NULL;
	
	info.colors = *((LONG *)&intin[15]);
	info.planes = intin[17];
	info.format = intin[18];
	info.flags = intin[19];
	info.reserved[0] = 0;
	info.reserved[1] = 0;
	info.reserved[2] = 0;
	
	if (info.colors == 0) /* keine spezielle Organisation definiert? */
	{
		if (fdb->fd_nplanes == 0 || fdb->fd_nplanes == device_driver->addr->info.planes)	/* Organisation wie der Bildschirmtreiber? */
			info = device_driver->addr->info;
		else
			info.planes = 1;
	}

	if (info.planes == 1)					/* monochrom? */
	{
		info.colors = 2;
		info.format = FORM_ID_INTERLEAVED;
		info.flags = 1;
	}

	drv = load_NOD_driver(&info);		/* Offscreen-Treiber laden und initialisieren */

	if (drv != NULL)
	{
		bitmap = create_wk(drv->wk_len);	/* Workstation anlegen */
		
		if (bitmap != NULL)
		{
			bitmap->bitmap_info = info;							/* Bitmap-Beschreibung setzen */
			wk_init(NULL, drv, bitmap);	/* Workstation initialisieren */
			
			if (intin[11] != 0)					/* wurde die Bitmap-Groesse angegeben? */
			{
				bitmap->res_x = intin[11];
				bitmap->res_y = intin[12];
			} else
			{										/* Bitmap-Groesse des Bildschirms uebernehmen */
				bitmap->res_x = dev_wk->res_x;
				bitmap->res_y = dev_wk->res_y;
			}
			if (intin[13] != 0)					/* wurde die Pixel-Groesse angegeben? */
			{
				bitmap->pixel_width = intin[13];
				bitmap->pixel_height = intin[14];
			} else
			{
				bitmap->pixel_width = dev_wk->pixel_width;
				bitmap->pixel_height = dev_wk->pixel_height;
			}
			bitmap->bitmap_dx = ((bitmap->res_x + 16) & ~15) - 1;
			bitmap->bitmap_dy = bitmap->res_y;
			bitmap->clip_xmax = bitmap->res_x;
			bitmap->clip_ymax = bitmap->res_y;
			bitmap->bitmap_width = (WORD)((LONG)(bitmap->res_x + 1) * (LONG)(bitmap->r_planes + 1) / 8);
			bitmap->bitmap_len = (LONG)bitmap->bitmap_width * (LONG)(bitmap->res_y + 1);
			bitmap->bitmap_drvr = drv;
			
			if (fdb->fd_addr == 0)					/* wurde kein Speicherblock uebergeben? */
			{
				fdb->fd_w = bitmap->res_x + 1;
				fdb->fd_h = bitmap->res_y + 1;
				fdb->fd_nplanes = bitmap->r_planes + 1;
				fdb->fd_stand = 0;
				fdb->fd_wdwidth = (bitmap->bitmap_width / (bitmap->r_planes + 1)) / 2;
				fdb->fd_addr = Malloc_sys(bitmap->bitmap_len);
				bitmap->bitmap_addr = fdb->fd_addr;
				if (fdb->fd_addr != NULL)						/* Speicher vorhanden? */
				{
					bitmap->bitmap_info.flags |= 0x8000;	/* Bitmap wurde alloziert */
					clear_bitmap(bitmap);				/* Bitmap loeschen */
				} else
				{
					unload_NOD_driver(drv);			/* Offscreen-Treiber entfernen */
					delete_wk(bitmap);					/* Workstation loeschen */
					return NULL;
				}
			} else
			{
				bitmap->bitmap_addr = fdb->fd_addr;
				bitmap->bitmap_width = fdb->fd_wdwidth * 2 * fdb->fd_nplanes;
				if (fdb->fd_stand)					/* Standardformat? */
				{
					MFDB tmp;

					tmp = *fdb;
					tmp.fd_stand = 0;
					tmp.fd_addr = Malloc_sys(bitmap->bitmap_len);
					if (tmp.fd_addr != NULL)
					{
						transform_bitmap(fdb, &tmp, bitmap);
						copy_mem(bitmap->bitmap_len, tmp.fd_addr, fdb->fd_addr);
						/* BUG: tmp bitmap leaked; but crashes when we free it??? */
					} else
					{
						tmp.fd_addr = fdb->fd_addr;
						transform_bitmap(fdb, &tmp, bitmap);
					}
				}
			}
		}
	}
	return bitmap;
}


/*----------------------------------------------------------------------------------------*/
/* Offscreen-Treiber schliessen, ggf. Speicher fuer die Bitmap und die Workstation frei-  */
/* geben.                                                                                 */
/*                                                                                        */
/* Funktionsresultat:   1                                                                 */
/* wk:                      Zeiger auf die  Workstation                                   */
/*----------------------------------------------------------------------------------------*/
WORD delete_bitmap(WK *wk)
{
	unload_NOD_driver(wk->bitmap_drvr);		/* Offscreen-Treiber entfernen */
	if (wk->bitmap_info.flags & 0x8000)		/* Speicher freigeben alloziert? */
	{
		Mfree_sys(wk->bitmap_addr);
	}
	delete_wk(wk);									/* Workstation entfernen */

	return TRUE;
}


/*----------------------------------------------------------------------------------------*/
/* Speicher fuer eine Workstation anfordern und loeschen, die Workstation in wk_tab ein-  */
/* tragen und das   Handle in der Workstation vermerken.                                  */
/*                                                                                        */
/* Funktionsresultat:   Zeiger auf die Workstation oder 0L                                */
/* wk_len:                  Laenge der Workstation                                        */
/*----------------------------------------------------------------------------------------*/
WK *create_wk(LONG wk_len)
{
	WK *wk = NULL;
	WORD handle;
	
	for (handle = 2; handle <= MAX_HANDLES; handle++)
	{
		if (wk_tab[handle - 1] == &closed)	/* freier Eintrag? */
		{
			wk = (WK *)Malloc_sys(wk_len);			/* Speicher anfordern */
			if (wk != NULL)
			{
				clear_mem(wk_len, wk);			/* loeschen */
				wk->wk_handle = handle;			/* Handle eintragen */
				wk_tab[handle - 1] = wk;		/* Eintrag in der Workstation-Tabelle setzen */
			}
			break;
		}
	}
	return wk;
}


/*----------------------------------------------------------------------------------------*/
/* Speicher einer Workstation zurueckgeben  und das Handle freigeben                      */
/*                                                                                        */
/* Funktionsresultat:   1, wenn die Workstation freigegeben werden konnte                 */
/* wk_len:                  Laenge der Workstation                                        */
/*----------------------------------------------------------------------------------------*/
static WORD delete_wk(WK *wk)
{
	if (wk_tab[wk->wk_handle - 1] == wk)
	{
		wk_tab[wk->wk_handle - 1] = &closed;
		Mfree_sys(wk);
		return TRUE;
	}
	return FALSE;
}
