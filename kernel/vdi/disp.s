                  ;'Die Dispatcher'

;Aufruf mit nicht existenter Funktionsnummer bearbeiten
;Eingaben
;d1.l pb
;Ausgaben
;d0.l wird veraendert
;contrl[2/4] werden auf 0 gesetzt
opcode_err_rts:   pea.l    vdi_exit(pc)   ;Ruecksprungadresse eintragen
opcode_err:       movea.l  d1,a1
                  movea.l  (a1),a1
opcode_err_komp:  move.w   (a1),d0        ;Funktionsnummer
opcode_err_exit:  clr.w    v_nintout(a1)  ;keine Ausgaben
                  clr.w    v_nptsout(a1)
                  rts

;Aufruf mit ungueltigem Handle bearbeiten
;Eingaben
;a1.l contrl
;Ausgaben
;d0.l wird veraendert
;contrl[2/4] werden eventuell auf 0 gesetzt
handle_err:
handle_err_tst:   move.w   (a1),d0        ;contrl[0] = Opcode
                  subq.w   #V_OPNWK,d0    ;v_opnwk()?
                  beq.s    handle_0_used
                  subi.w   #V_OPNVWK-V_OPNWK,d0 ;v_opnvwk()?
                  beq.s    handle_0_used  ; BUG: v_resize_bm has same opcode, but needs valid handle
handle_err_komp:  nop
handle_0_used:    movea.l  (linea_wk_ptr).w,a6
                  clr.w    v_handle(a1)   ;contrl[6]=0
                  moveq.l  #0,d0
                  bra.s    handle_found   ;in den Dispatcher einspringen

;VDI-Hauptdispatcher
;Register d0 wird veraendert
;Eingaben
;d0.w 115
;d1.l pb
vdi_entry:
                  movem.l  a0-a1/a6,-(sp)          ;Register retten
                  movea.l  d1,a0                   ;pblock
                  movea.l  (a0),a1                 ;contrl
                  move.w   v_handle(a1),d0         ;contrl[6] (Handle)
                  beq.s    handle_err_tst
                  cmp.w    #MAX_HANDLES,d0         ;Handle gueltig ?
                  bhi.s    handle_err_tst
                  subq.w   #AES_HANDLE,d0
                  add.w    d0,d0
                  add.w    d0,d0                   ;Zugriffsindex fuer die WK-Tabelle
                  lea.l    (wk_tab).w,a6           ;Zeiger auf die Workstationtabelle
                  movea.l  0(a6,d0.w),a6           ;Zeiger auf die Workstation
                  movea.l  disp_addr1(a6),a0       ;weiterfuehrende Dispatcheradresse
                  jmp      (a0)                    ;Dispatcher anspringen
handle_found:     movea.l  d1,a0
                  movea.l  (a0),a1                 ;contrl
                  move.w   (a1),d0                 ;Funktionsnummer = contrl[0]
                  cmp.w    #VQT_FONTINFO,d0        ;zu hohe Funktionsnummer?
                  bhi.s    opcode_err_rts
                  cmp.w    #VST_ALIGNMENT,d0
                  bhi.s    vdi_disp_opnvwk
                  lsl.w    #3,d0
                  lea.l    vdi_tab(pc,d0.w),a0
                  bra.s    vdi_disp_par
vdi_disp_opnvwk:  sub.w    #V_OPNVWK,d0            ;ungueltige Funktionsnummer?
                  bmi.s    opcode_err_rts
                  lsl.w    #3,d0
                  lea.l    vdi_tab100(pc),a0
                  adda.w   d0,a0
vdi_disp_par:     move.w   (a0)+,v_nptsout(a1)     ;Anzahl der Eintraege in ptsout
                  move.w   (a0)+,v_nintout(a1)     ;Anzahl der Eintraege in intout
                  movea.l  (a0),a1                 ;Funktionsadresse
                  movea.l  d1,a0                   ;pblock
                  jsr      (a1)
vdi_exit:         movem.l  (sp)+,a0-a1/a6          ;Register zurueckschreiben
                  moveq.l  #0,d0
                  rts

;Tabelle mit Anzahl der Ausgabeparameter und Funktionsadresse
vdi_tab:
                  DC.W 0,0
                  DC.L opcode_err         ;0

                  DC.W 6,45
                  DC.L v_opnwk            ;1

                  DC.W 0,0
                  DC.L v_clswk            ;2

                  DC.W 0,0
                  DC.L v_clrwk            ;3

                  DC.W 0,0
                  DC.L v_updwk            ;4

                  DC.W 0,0
                  DC.L v_escape           ;5

                  DC.W 0,0
                  DC.L v_pline            ;6

                  DC.W 0,0
                  DC.L v_pmarker          ;7

                  DC.W 0,0
                  DC.L v_gtext            ;8

                  DC.W 0,0
                  DC.L v_fillarea         ;9

                  DC.W 0,0
                  DC.L v_cellarray        ;10

                  DC.W 0,0
                  DC.L v_gdp              ;11

                  DC.W 2,0
                  DC.L vst_height         ;12

                  DC.W 0,1
                  DC.L vst_rotation       ;13

                  DC.W 0,0
                  DC.L vs_color           ;14

                  DC.W 0,1
                  DC.L vsl_type           ;15

                  DC.W 1,0
                  DC.L vsl_width          ;16

                  DC.W 0,1
                  DC.L vsl_color          ;17

                  DC.W 0,1
                  DC.L vsm_type           ;18

                  DC.W 1,0
                  DC.L vsm_height         ;19

                  DC.W 0,1
                  DC.L vsm_color          ;20

                  DC.W 0,1
                  DC.L vst_font           ;21

                  DC.W 0,1
                  DC.L vst_color          ;22

                  DC.W 0,1
                  DC.L vsf_interior       ;23

                  DC.W 0,1
                  DC.L vsf_style          ;24

                  DC.W 0,1
                  DC.L vsf_color          ;25

                  DC.W 0,4
                  DC.L vq_color           ;26

                  DC.W 0,0
                  DC.L vq_cellarray       ;27

                  DC.W 0,0
                  DC.L v_locator          ;28

                  DC.W 0,2
                  DC.L v_valuator         ;29

                  DC.W 0,1
                  DC.L v_choice           ;30

                  DC.W 0,0
                  DC.L v_string           ;31

                  DC.W 0,1
                  DC.L vswr_mode          ;32

                  DC.W 0,1
                  DC.L vsin_mode          ;33

                  DC.W 0,0
                  DC.L opcode_err         ;34 (nicht existent)

                  DC.W 1,5
                  DC.L vql_attributes     ;35

                  DC.W 1,3
                  DC.L vqm_attributes     ;36

                  DC.W 0,5
                  DC.L vqf_attributes     ;37

                  DC.W 2,6
                  DC.L vqt_attributes     ;38

                  DC.W 0,2
                  DC.L vst_alignment      ;39

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

                  DC.W 0,0
                  DC.L opcode_err

vdi_tab100:
                  DC.W 6,45
                  DC.L v_opnvwk           ;100

                  DC.W 0,0
                  DC.L v_clsvwk           ;101

                  DC.W 6,45
                  DC.L vq_extnd           ;102

                  DC.W 0,0
                  DC.L v_contourfill      ;103

                  DC.W 0,1
                  DC.L vsf_perimeter      ;104

                  DC.W 0,2
                  DC.L v_get_pixel        ;105

                  DC.W 0,1
                  DC.L vst_effects        ;106

                  DC.W 2,1
                  DC.L vst_point          ;107

                  DC.W 0,0
                  DC.L vsl_ends           ;108

                  DC.W 0,0
                  DC.L vro_cpyfm          ;109

                  DC.W 0,0
                  DC.L vr_trnfm           ;110

                  DC.W 0,0
                  DC.L vsc_form           ;111

                  DC.W 0,0
                  DC.L vsf_udpat          ;112

                  DC.W 0,0
                  DC.L vsl_udsty          ;113

                  DC.W 0,0
                  DC.L vr_recfl           ;114

                  DC.W 0,1
                  DC.L vqin_mode          ;115

                  DC.W 4,0
                  DC.L vqt_extent         ;116

                  DC.W 3,1
                  DC.L vqt_width          ;117

                  DC.W 0,1
                  DC.L vex_timv           ;118

                  DC.W 0,1
                  DC.L vst_load_fonts     ;119

                  DC.W 0,0
                  DC.L vst_unload_fonts   ;120

                  DC.W 0,0
                  DC.L vrt_cpyfm          ;121

                  DC.W 0,0
                  DC.L v_show_c           ;122

                  DC.W 0,0
                  DC.L v_hide_c           ;123

                  DC.W 1,1
                  DC.L vq_mouse           ;124

                  DC.W 0,0
                  DC.L vex_butv           ;125

                  DC.W 0,0
                  DC.L vex_motv           ;126

                  DC.W 0,0
                  DC.L vex_curv           ;127

                  DC.W 0,1
                  DC.L vq_key_s           ;128

                  DC.W 0,0
                  DC.L vs_clip            ;129

                  DC.W 0,33
                  DC.L vqt_name           ;130

                  DC.W 5,2
                  DC.L vqt_fontinfo       ;131

                  DC.W 0,0
                  DC.L opcode_err         ;132 (vqt_justified)

                  DC.W 0,0
                  DC.L opcode_err         ;133

                  DC.W 0,0
                  DC.L opcode_err         ;134 (vex_wheelv)

                  DC.W 0,0
                  DC.L opcode_err         ;135

                  DC.W 0,0
                  DC.L opcode_err         ;136

                  DC.W 0,0
                  DC.L opcode_err         ;137

                  DC.W 0,0
                  DC.L opcode_err         ;138 (v_setrgb)

                  DC.W 0,0
                  DC.L opcode_err         ;139

                  DC.W 0,0
                  DC.L opcode_err         ;140

                  DC.W 0,0
                  DC.L opcode_err         ;141

                  DC.W 0,0
                  DC.L opcode_err         ;142

                  DC.W 0,0
                  DC.L opcode_err         ;143

                  DC.W 0,0
                  DC.L opcode_err         ;144

                  DC.W 0,0
                  DC.L opcode_err         ;145

                  DC.W 0,0
                  DC.L opcode_err         ;146

                  DC.W 0,0
                  DC.L opcode_err         ;147

                  DC.W 0,0
                  DC.L opcode_err         ;148

                  DC.W 0,0
                  DC.L opcode_err         ;149

                  DC.W 0,0
                  DC.L opcode_err         ;150

                  DC.W 0,0
                  DC.L opcode_err         ;151

                  DC.W 0,0
                  DC.L opcode_err         ;152

                  DC.W 0,0
                  DC.L opcode_err         ;153

                  DC.W 0,0
                  DC.L opcode_err         ;154

                  DC.W 0,0
                  DC.L opcode_err         ;155

                  DC.W 0,0
                  DC.L opcode_err         ;156

                  DC.W 0,0
                  DC.L opcode_err         ;157

                  DC.W 0,0
                  DC.L opcode_err         ;158

                  DC.W 0,0
                  DC.L opcode_err         ;159

                  DC.W 0,0
                  DC.L opcode_err         ;160

                  DC.W 0,0
                  DC.L opcode_err         ;161

                  DC.W 0,0
                  DC.L opcode_err         ;162

                  DC.W 0,0
                  DC.L opcode_err         ;163

                  DC.W 0,0
                  DC.L opcode_err         ;164

                  DC.W 0,0
                  DC.L opcode_err         ;165

                  DC.W 0,0
                  DC.L opcode_err         ;166

                  DC.W 0,0
                  DC.L opcode_err         ;167

                  DC.W 0,0
                  DC.L opcode_err         ;168

                  DC.W 0,0
                  DC.L opcode_err         ;169

                  DC.W 0,0
                  DC.L opcode_err         ;170 (vr_transfer_bits)

                  DC.W 0,0
                  DC.L opcode_err         ;171 (vr_clip_rect*)

                  DC.W 0,0
                  DC.L opcode_err         ;172

                  DC.W 0,0
                  DC.L opcode_err         ;173

                  DC.W 0,0
                  DC.L opcode_err         ;174

                  DC.W 0,0
                  DC.L opcode_err         ;175

                  DC.W 0,0
                  DC.L opcode_err         ;176

                  DC.W 0,0
                  DC.L opcode_err         ;177

                  DC.W 0,0
                  DC.L opcode_err         ;178

                  DC.W 0,0
                  DC.L opcode_err         ;179

                  DC.W 0,0
                  DC.L opcode_err         ;180 (v_create_driver_info)

                  DC.W 0,0
                  DC.L opcode_err         ;181 (v_delete_driver_info)

                  DC.W 0,0
                  DC.L opcode_err         ;182 (v_read_default_settings/v_write_default_settings)

                  DC.W 0,0
                  DC.L opcode_err         ;183

                  DC.W 0,0
                  DC.L opcode_err         ;184

                  DC.W 0,0
                  DC.L opcode_err         ;185

                  DC.W 0,0
                  DC.L opcode_err         ;186

                  DC.W 0,0
                  DC.L opcode_err         ;187

                  DC.W 0,0
                  DC.L opcode_err         ;188

                  DC.W 0,0
                  DC.L opcode_err         ;189

                  DC.W 0,0
                  DC.L opcode_err         ;190 (vqt_charindex)

                  DC.W 0,0
                  DC.L opcode_err         ;191

                  DC.W 0,0
                  DC.L opcode_err         ;192

                  DC.W 0,0
                  DC.L opcode_err         ;193

                  DC.W 0,0
                  DC.L opcode_err         ;194

                  DC.W 0,0
                  DC.L opcode_err         ;195

                  DC.W 0,0
                  DC.L opcode_err         ;196

                  DC.W 0,0
                  DC.L opcode_err         ;197

                  DC.W 0,0
                  DC.L opcode_err         ;198

                  DC.W 0,0
                  DC.L opcode_err         ;199

                  DC.W 0,0
                  DC.L opcode_err         ;200 (vs[tflmr]_fg_color)

                  DC.W 0,0
                  DC.L opcode_err         ;201 (vs[tflmr]_bg_color)

                  DC.W 0,0
                  DC.L opcode_err         ;202 (vq[tflmr]_fg_color)

                  DC.W 0,0
                  DC.L opcode_err         ;203 (vq[tflmr]_bg_color)

                  DC.W 0,0
                  DC.L opcode_err         ;204 (v_color2value)

                  DC.W 0,0
                  DC.L opcode_err         ;205 (vs_ctab)

                  DC.W 0,0
                  DC.L opcode_err         ;206 (vq_ctab)

                  DC.W 0,0
                  DC.L opcode_err         ;207 (vs_[hilite|min|max|weight]_color)

                  DC.W 0,0
                  DC.L opcode_err         ;208 (v_create_itab)

                  DC.W 0,0
                  DC.L opcode_err         ;209 (vq_[hilite|min|max|weight]_color)

                  DC.W 0,0
                  DC.L opcode_err         ;210

                  DC.W 0,0
                  DC.L opcode_err         ;211

                  DC.W 0,0
                  DC.L opcode_err         ;212

                  DC.W 0,0
                  DC.L opcode_err         ;213

                  DC.W 0,0
                  DC.L opcode_err         ;214

                  DC.W 0,0
                  DC.L opcode_err         ;215

                  DC.W 0,0
                  DC.L opcode_err         ;216

                  DC.W 0,0
                  DC.L opcode_err         ;217

                  DC.W 0,0
                  DC.L opcode_err         ;218

                  DC.W 0,0
                  DC.L opcode_err         ;219

                  DC.W 0,0
                  DC.L opcode_err         ;220

                  DC.W 0,0
                  DC.L opcode_err         ;221

                  DC.W 0,0
                  DC.L opcode_err         ;222

                  DC.W 0,0
                  DC.L opcode_err         ;223

                  DC.W 0,0
                  DC.L opcode_err         ;224

                  DC.W 0,0
                  DC.L opcode_err         ;225

                  DC.W 0,0
                  DC.L opcode_err         ;226

                  DC.W 0,0
                  DC.L opcode_err         ;227

                  DC.W 0,0
                  DC.L opcode_err         ;228

                  DC.W 0,0
                  DC.L opcode_err         ;229 (vqt_xfntinfo)

                  DC.W 0,0
                  DC.L opcode_err         ;230 (vst_name)

                  DC.W 0,0
                  DC.L opcode_err         ;231 (vst_width)

                  DC.W 0,0
                  DC.L opcode_err         ;232 (vqt_fontheader)

                  DC.W 0,0
                  DC.L opcode_err         ;233 (v_mono_ftext)

                  DC.W 0,0
                  DC.L opcode_err         ;234 (vqt_trackkern)

                  DC.W 0,0
                  DC.L opcode_err         ;235 (vqt_pairkern)

                  DC.W 0,0
                  DC.L opcode_err         ;236 (vst_charmap/vst_map_mode)

                  DC.W 0,0
                  DC.L opcode_err         ;237 (vst_kern) 

                  DC.W 0,0
                  DC.L opcode_err         ;238 (vq_ptsinsz)

                  DC.W 0,0
                  DC.L opcode_err         ;239 (v_getbitmap_info)

                  DC.W 0,0
                  DC.L opcode_err         ;240 (vqt_f_extent)

                  DC.W 0,0
                  DC.L opcode_err         ;241 (v_ftext)

                  DC.W 0,0
                  DC.L opcode_err         ;242 (v_killoutline)

                  DC.W 0,0
                  DC.L opcode_err         ;243 (v_getoutline)

                  DC.W 0,0
                  DC.L opcode_err         ;244 (vst_scratch)

                  DC.W 0,0
                  DC.L opcode_err         ;245 (vst_error)

                  DC.W 0,0
                  DC.L opcode_err         ;246 (vst_arbpt)

                  DC.W 0,0
                  DC.L opcode_err         ;247 (vqt_advance)

                  DC.W 0,0
                  DC.L opcode_err         ;248 (vq_devinfo)

                  DC.W 0,0
                  DC.L opcode_err         ;249 (v_savecache)

                  DC.W 0,0
                  DC.L opcode_err         ;250 (v_loadcache)

                  DC.W 0,0
                  DC.L opcode_err         ;251 (v_flushcache)

                  DC.W 0,0
                  DC.L opcode_err         ;252 (vst_setsize)

                  DC.W 0,0
                  DC.L opcode_err         ;253 (vst_skew)

                  DC.W 0,0
                  DC.L opcode_err         ;254 (vqt_get_table)

                  DC.W 0,0
                  DC.L opcode_err         ;255 (vqt_cachesize/vqt_cacheinfo)
