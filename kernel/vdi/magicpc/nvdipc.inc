	.offset 0
nvdipcmode_length: ds.l 1
nvdipcmode_planes: ds.w 1
nvdipcmode_xres:   ds.w 1
nvdipcmode_yres:   ds.w 1
nvdipcmode_sizeof:

	.offset 0
nvdipc_length:     ds.l 1
nvdipc_magic:      ds.l 1
nvdipc_version:    ds.l 1
nvdipc_nummodes:   ds.l 1
nvdipc_defmode:    ds.w 16
nvdipc_modes:      ds.b 16*nvdipcmode_sizeof
