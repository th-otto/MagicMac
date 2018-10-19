typedef struct {
	short unknown1[16];
	short v_planes;
	short unknown2[2];
	long form_id;
} VWK;

#define FORM_ID_STANDARD    0
#define FORM_ID_PIXPACKED   1
#define FORM_ID_INTERLEAVED 2
