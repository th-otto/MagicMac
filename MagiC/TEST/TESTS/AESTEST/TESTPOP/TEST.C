/*
*
* Testprogramm fÅr menu_popup()
* Korrigiert und modernisiert (mt_aes) von Andreas Kromke
*
*/

#include <mt_aes.h>
#include <stdio.h>
#include <string.h>

#include "test.h"

WORD	main(VOID)
{
	OBJECT	*dial;
	WORD		antw;
	MENU		pop,outpop;		/* muû verschieden sein!!! */
	GRECT	g;
	WORD	i, p_x, p_y;


	appl_init();
	rsrc_load("test.rsc");
	graf_mouse(ARROW, 0x0L);

	rsrc_gaddr(R_TREE, DIAL, &dial);

	rsrc_gaddr(R_TREE, POPUPS, &pop.mn_tree);
	pop.mn_menu = POPWORK;
	pop.mn_item = PWCOMP;
	pop.mn_scroll = 0;
	pop.mn_keystate = 0;

	strcpy(dial[POPUP].ob_spec.tedinfo->te_ptext, pop.mn_tree[pop.mn_item].ob_spec.free_string);

	wind_update(BEG_UPDATE);
	form_center(dial, &g);
	form_dial(FMD_START, &g, &g);
	objc_draw(dial, ROOT, MAX_DEPTH, &g);
	do
	{
		antw = form_do(dial, -1);
		if (antw == POPUP)
		{
			objc_offset(dial, POPUP, &p_x, &p_y);
			i = menu_popup(&pop, p_x, p_y, &outpop);

			printf("menu_popup:\n"
				  "     => %d\n"
				  "     mn_tree = %08lx\n"
				  "     mn_item = %d\n"
				  "     mn_scroll = %d\n"
				  "     mn_keystate = %d\n\n",
				  i,
				  outpop.mn_tree,
				  outpop.mn_item,
				  outpop.mn_scroll,
				  outpop.mn_keystate);

			if (i != 0)
			{
				strcpy(dial[POPUP].ob_spec.tedinfo->te_ptext, pop.mn_tree[pop.mn_item].ob_spec.free_string);
				objc_draw(dial, POPUPS, 1, &g);
			}
		}
	}
	while (antw != ABBRUCH);
	form_dial(FMD_FINISH, &g, &g);
	wind_update(END_UPDATE);

	rsrc_free();
	appl_exit();
	return(0);
}
