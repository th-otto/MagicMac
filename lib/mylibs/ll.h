#ifdef __PUREC__
#pragma warn -stv
#endif

typedef union {
	struct {
		unsigned long hi;
		unsigned long lo;
	} p;
#ifdef __GNUC__
	unsigned long long ll;
#endif
} ULONG64;

ULONG64 ullmul(unsigned long x, unsigned long y);
char *print_ull(ULONG64 z, int shift, char *p);
