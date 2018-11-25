						;'Die Dispatcher'

;Aufruf mit nicht existenter Funktionsnummer bearbeiten
;Eingaben
;d1.l pb
;Ausgaben
;d0.l wird veraendert
;contrl[2/4] werden auf 0 gesetzt
opcode_err_rts:	pea		vdi_exit(pc)	;Ruecksprungadresse eintragen
opcode_err: 		movea.l	d1,a1
						movea.l	(a1),a1
opcode_err_komp:	move.w	(a1),d0			;Funktionsnummer
opcode_err_exit:	clr.w 	n_intout(a1)	;keine Ausgaben
						clr.w 	n_ptsout(a1)
						rts

;Aufruf mit ungueltigem Handle bearbeiten
;Eingaben
;a1.l contrl
;Ausgaben
;d0.l wird veraendert
;contrl[2/4] werden eventuell auf 0 gesetzt
handle_err:
handle_err_tst:	move.w	(a1),d0			;contrl[0] = Opcode
						subq.w	#V_OPNWK,d0 	;v_opnwk()?
						beq.s 	handle_0_used
						subi.w	#V_OPNVWK-V_OPNWK,d0 ;v_opnvwk()?
						beq.s 	handle_0_used
handle_err_komp:	nop
handle_0_used: 	movea.l	linea_wk_ptr,a6
						clr.w 	handle(a1)		;contrl[6]=0
						moveq 	#0,d0
						bra		handle_found	;in den Dispatcher einspringen

;VDI-Hauptdispatcher
;Register d0 wird veraendert
;Eingaben
;d0.w 115
;d1.l pb
vdi_entry:
vdi_disp:			movem.l	a0-a1/a6,-(sp) 			;Register retten
						movea.l	d1,a0 						;pblock
						movea.l	(a0),a1						;contrl
						move.w	handle(a1),d0				;contrl[6] (Handle)
						beq		handle_err_tst
						cmp.w 	#MAX_HANDLE,d0				;Handle gueltig ?
						bhi		handle_err_tst
						subq.w	#AES_HANDLE,d0
						add.w 	d0,d0
						add.w 	d0,d0 						;Zugriffsindex fuer die WK-Tabelle
						lea		wk_tab,a6					;Zeiger auf die Workstationtabelle
						movea.l	0(a6,d0.w),a6				;Zeiger auf die Workstation
						movea.l	(a6),a0						;weiterfuehrende Dispatcheradresse
						jmp		(a0)							;Dispatcher anspringen
handle_found:		movea.l	d1,a0
						movea.l	(a0),a1						;contrl
						move.w	(a1),d0 						;Funktionsnummer = contrl[0]
						cmp.w		#VQT_FONTINFO,d0			;zu hohe Funktionsnummer?
						bhi		opcode_err_rts
						cmp.w		#VST_ALIGNMENT,d0
						bhi.s		vdi_disp_opnvwk
						lsl.w 	#3,d0
						lea		vdi_tab(pc,d0.w),a0
						bra.s		vdi_disp_par
vdi_disp_opnvwk:	sub.w		#V_OPNVWK,d0				;ungueltige Funktionsnummer?
						bmi		opcode_err_rts
						lsl.w 	#3,d0
						lea		vdi_tab100(pc),a0
						adda.w	d0,a0
vdi_disp_par:		move.w	(a0)+,n_ptsout(a1) 		;Anzahl der Eintraege in ptsout
						move.w	(a0)+,n_intout(a1)		;Anzahl der Eintraege in intout
						movea.l	(a0),a1						;Funktionsadresse
						movea.l	d1,a0 						;pblock
						jsr		(a1)
vdi_exit:			movem.l	(sp)+,a0-a1/a6				;Register zurueckschreiben
						moveq		#0,d0
						rts

;Tabelle mit Anzahl der Ausgabeparameter und Funktionsadresse
vdi_tab: 			DC.W 0,0
						DC.L opcode_err			;0

						DC.W 6,45
						DC.L v_opnwk				;1

						DC.W 0,0
						DC.L v_clswk				;2

						DC.W 0,0
						DC.L v_clrwk				;3

						DC.W 0,0
						DC.L v_updwk				;4

						DC.W 0,0
						DC.L v_escape				;5

						DC.W 0,0
						DC.L v_pline				;6

						DC.W 0,0
						DC.L v_pmarker 			;7

						DC.W 0,0
						DC.L v_gtext				;8

						DC.W 0,0
						DC.L v_fillarea			;9

						DC.W 0,0
						DC.L v_cellarray			;10

						DC.W 0,0
						DC.L v_gdp					;11

						DC.W 2,0
						DC.L vst_height			;12

						DC.W 0,1
						DC.L vst_rotation 		;13

						DC.W 0,0
						DC.L vs_color				;14

						DC.W 0,1
						DC.L vsl_type				;15

						DC.W 1,0
						DC.L vsl_width 			;16

						DC.W 0,1
						DC.L vsl_color 			;17

						DC.W 0,1
						DC.L vsm_type				;18

						DC.W 1,0
						DC.L vsm_height			;19

						DC.W 0,1
						DC.L vsm_color 			;20

						DC.W 0,1
						DC.L vst_font				;21

						DC.W 0,1
						DC.L vst_color 			;22

						DC.W 0,1
						DC.L vsf_interior 		;23

						DC.W 0,1
						DC.L vsf_style 			;24

						DC.W 0,1
						DC.L vsf_color 			;25

						DC.W 0,4
						DC.L vq_color				;26

						DC.W 0,0
						DC.L vq_cellarray 		;27

						DC.W 0,0
						DC.L v_locator 			;28

						DC.W 0,2
						DC.L v_valuator			;29

						DC.W 0,1
						DC.L v_choice				;30

						DC.W 0,0
						DC.L v_string				;31

						DC.W 0,1
						DC.L vswr_mode 			;32

						DC.W 0,1
						DC.L vsin_mode 			;33

						DC.W 0,0
						DC.L opcode_err			;34 (nicht existent)

						DC.W 1,5
						DC.L vql_attributes		;35

						DC.W 1,3
						DC.L vqm_attributes		;36

						DC.W 0,5
						DC.L vqf_attributes		;37

						DC.W 2,6
						DC.L vqt_attributes		;38

						DC.W 0,2
						DC.L vst_alignment		;39

						REPT 60
						DC.L 0
						DC.L opcode_err			;40-99 (nicht existent)
						ENDM

vdi_tab100:			DC.W 6,45
						DC.L v_opnvwk				;100

						DC.W 0,0
						DC.L v_clsvwk				;101

						DC.W 6,45
						DC.L vq_extnd				;102

						DC.W 0,0
						DC.L v_contourfill		;103

						DC.W 0,1
						DC.L vsf_perimeter		;104

						DC.W 0,2
						DC.L v_get_pixel			;105

						DC.W 0,1
						DC.L vst_effects			;106

						DC.W 2,1
						DC.L vst_point 			;107

						DC.W 0,0
						DC.L vsl_ends				;108

						DC.W 0,0
						DC.L vro_cpyfm 			;109

						DC.W 0,0
						DC.L vr_trnfm				;110

						DC.W 0,0
						DC.L vsc_form				;111

						DC.W 0,0
						DC.L vsf_udpat 			;112

						DC.W 0,0
						DC.L vsl_udsty 			;113

						DC.W 0,0
						DC.L vr_recfl				;114

						DC.W 0,1
						DC.L vqin_mode 			;115

						DC.W 4,0
						DC.L vqt_extent			;116

						DC.W 3,1
						DC.L vqt_width 			;117

						DC.W 0,1
						DC.L vex_timv				;118

						DC.W 0,1
						DC.L vst_load_fonts		;119

						DC.W 0,0
						DC.L vst_unload_fonts	;120

						DC.W 0,0
						DC.L vrt_cpyfm 			;121

						DC.W 0,0
						DC.L v_show_c				;122

						DC.W 0,0
						DC.L v_hide_c				;123

						DC.W 1,1
						DC.L vq_mouse				;124

						DC.W 0,0
						DC.L vex_butv				;125

						DC.W 0,0
						DC.L vex_motv				;126

						DC.W 0,0
						DC.L vex_curv				;127

						DC.W 0,1
						DC.L vq_key_s				;128

						DC.W 0,0
						DC.L vs_clip				;129

						DC.W 0,33
						DC.L vqt_name				;130

						DC.W 5,2
						DC.L vqt_fontinfo 		;131



						
