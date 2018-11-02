#include <portab.h>
#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include "list.h"


/*
 * These functions require the "next" pointer
 * to be the first member of the structure
 */

int list_remove(void **root, void *entry)
{
	while (*root != NULL)
	{
		void **prev = root;
		root = *root;
		if (root == entry)
		{
			*prev = *root;
			return TRUE;
		}
	}
	return FALSE;
}


void list_append(void **root, void *entry)
{
	while (*root != NULL)
		root = *root;
	*root = entry;
}


void *list_nth(void *list, WORD index)
{
	void **search = list;

	while (search != NULL)
	{
		if (index == 0)
			return search;
		--index;
		search = *search;
	}
	return NULL;
}


WORD list_count(void *list)
{
	WORD count;
	void **search = list;
	
	count = 0;
	
	while (search)
	{
		count++;
		search = *search;
	}
	return count;
}
