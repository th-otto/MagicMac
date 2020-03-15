/*
		definiere fehlende Typen
*/

#ifndef __VDI__
	#if USE_VDI==YES
		#if SAVE_COLORS==YES
			typedef void *RGB1000;
		#endif
	#endif
#endif

#ifndef min
	#define	min(a, b)	((a) < (b) ? (a) : (b))
#endif
#ifndef max
	#define	max(a, b)	((a) > (b) ? (a) : (b))
#endif
#ifndef abs
	#define	abs(a)		((a) >= 0   ? (a) : -(a))
#endif
