#include <tos.h>
#include <gemx.h>
#include "diallib.h"
#include SPEC_DEFINITION_FILE

#if USE_MENU == YES

void ChooseMenu(int title, int entry)
{
	if((menu_tree[title].ob_state&OS_DISABLED)||
			(menu_tree[entry].ob_state&OS_DISABLED))	/*	Wenn Menutitel inaktiv...	*/
		return;												/*	... tschuess	*/

	menu_tnormal(menu_tree,title,0);
	SelectMenu(title,entry);
	menu_tnormal(menu_tree,title,1);
}

#endif
