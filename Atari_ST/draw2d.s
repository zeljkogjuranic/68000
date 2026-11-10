draw2d_polygon_line_lp:
	; inputs
	; a0 = table pointer
	; d0,d1 = x1,x2 16bit (1+9+6)
	; d2,d3 = y1,y2 16bit (1+9+6)
	; d4 = egde index
	
	; D0=x1			D1=x2-x1
	; D2=(y1-y2)*64	D3=y2*64
	; D4=y1-y2		D5=increment
	; D6=rest		D7=current X
	; A0=table pointer	A1=table pointer at Y
	; A2=edge buffer X	A3=edge buffer Y
	; A4=?				A5=?
	; A6=code pointer
	
	; top and bottom
	lea draw2d_polygon_start(PC),a4
	cmp.w (a4),d2
	bge draw2d_lp_skip_top_update
	move.w d2,(a4)
draw2d_lp_skip_top_update:
	addq.l #2,a4
	cmp.w (a4),d2
	ble draw2d_lp_skip_bot_update
	move.w d2,(a4)	
draw2d_lp_skip_bot_update:
	lea line_buffer_increment_x(PC),a2
	lea line_buffer_y_dy(PC),a3
	lea draw2d_span_buffer_left(PC),a0
	add.w d4,d4
	add.w d4,d4
	adda.w d4,a3
	add.w d4,d4
	adda.w d4,a2
	cmp.w d3,d2
	beq draw2d_lp_skip_polygon_line	;if d2=0 goto skip_draw_line
	bgt draw2d_lp_skip_reverse_line
	lea draw2d_span_buffer_right(PC),a0
	exg d0,d1
	exg d2,d3
draw2d_lp_skip_reverse_line:
	move.l a0,a1
	move.w (a3)+,d4
	bgt draw2d_lp_skip_buffered_line
	move.w (a3),d6
	adda.w	d6,a1
	adda.w	d6,a1
	move.l (a2)+,d5
	move.l (a2),d7
	jmp draw2d_lp_polyline_loop2
draw2d_lp_skip_buffered_line:
	asr.w #6,d0
	asr.w #6,d1
	asr.w #6,d2
	asr.w #6,d3
	move.w d2,d4
	move.w d3,d5
	move.w d2,d6
	sub.w d3,d2			;d2=(y1-y2)
	adda.w d4,a1		;pointer to table at y1
	adda.w d4,a1
	move.w d4,(a3)
	addq #2,a1
	sub.w d5,d4			;d4=y1-y2
	ble draw2d_lp_skip_polygon_line	;if d4<=0 goto skip_draw_line
	lea draw2d_div_table,a4
	moveq #0,d5			;d5=x increment
	moveq #0,d7
	move.w d0,d7
	swap d7
	sub.w d0,d1			;d1=(x2-x1)
	bge draw2d_lp_polyline_positivedx
	neg.w d1
	;ext.l d1
	;asl.l #7,d1
	add.w d2,d2
	mulu (a4,d2.w),d1 ; d1=dx*65536/dy
	;swap d1
	;divu d2,d1
	move.l d1,d5
	neg.l d5
	jmp draw2d_lp_polyline_enddivp
	
draw2d_lp_polyline_positivedx:
	;ext.l d1
	;asl.l #7,d1
	add.w d2,d2
	mulu (a4,d2.w),d1
;	swap d1
;	divu d2,d1
	move.l d1,d5
draw2d_lp_polyline_enddivp:
	;asl.l #8,d5
	;add.w d5,d7
	;asl.l #1,d5
	swap d5
	swap d7
	add.w d4,d4
	add.w d4,d4
	neg.w d4
	move.l d5,(a2)+
	move.l d7,(a2)
	move.w (a3),d0
	addq.w #1,d0
	move.w d0,(a3)
	move.w d4,-(a3)
	
draw2d_lp_polyline_loop2:	
	lea draw2d_lp_skip_polygon_line(PC),a6
	move.l d5,d0
	clr.w d0
	add.l d0,d7
	jmp (a6,d4)
;draw2d_polyline_loop1:
	REPT 200
	move.w d7,-(a1)	; 33 07
	addx.l d5,d7	; DF 85
	ENDR
draw2d_lp_skip_polygon_line:
	rts


draw2d_polygon_line:
	; inputs
	; a0 = table pointer
	; d0,d1 = x1,x2 16bit (1+9+6)
	; d2,d3 = y1,y2 16bit (1+9+6)
	; d4 = egde index
	
	; D0=x1			D1=x2-x1
	; D2=(y1-y2)*64	D3=y2*64
	; D4=y1-y2		D5=increment
	; D6=rest		D7=current X
	; A0=table pointer	A1=table pointer at Y
	; A2=edge buffer X	A3=edge buffer Y
	; A4=?				A5=?
	; A6=code pointer
	
	;move.b	($0fff00),d0 ; trigger debugger
	; top and bottom
	lea draw2d_polygon_start(PC),a4
	cmp.w (a4),d2
	bge draw2d_skip_top_update
	;move.b	($0fff00),d0 ; trigger debugger
	move.w d2,(a4)
draw2d_skip_top_update:
	addq.l #2,a4
	cmp.w (a4),d2
	ble draw2d_skip_bot_update
	move.w d2,(a4)	
draw2d_skip_bot_update:
	lea line_buffer_increment_x(PC),a2
	lea line_buffer_y_dy(PC),a3
	lea draw2d_span_buffer_left(PC),a0
	;move.b	($0fff00),d0 ; trigger debugger
	add.w d4,d4
	add.w d4,d4
	adda.w d4,a3
	add.w d4,d4
	adda.w d4,a2
	cmp.w d3,d2
	beq draw2d_skip_polygon_line	;if d2=0 goto skip_draw_line
	bgt draw2d_skip_reverse_line
	lea draw2d_span_buffer_right(PC),a0
	exg d0,d1
	exg d2,d3
draw2d_skip_reverse_line:
	move.l a0,a1
	move.w (a3)+,d4
	bgt draw2d_skip_buffered_line
	;move.b	($0fff00),d0 ; trigger debugger
	move.w (a3),d6
	adda.w	d6,a1
	adda.w	d6,a1
	move.l (a2)+,d5
	move.l (a2),d7
	jmp draw2d_polyline_loop2
draw2d_skip_buffered_line:
	move.w d2,d4
	move.w d3,d5
	move.w d2,d6
	sub.w d3,d2			;d2=(y1-y2)*64
	asr.w #6,d4			;d4/=64
	asr.w #6,d5			;d5/=64
	adda.w d4,a1		;pointer to table at y1
	adda.w d4,a1
	move.w d4,(a3)
	addq #2,a1
	sub.w d5,d4			;d4=y1-y2
	ble draw2d_skip_polygon_line	;if d4<=0 goto skip_draw_line
	andi.w #63,d6		;d6=rest
	moveq.l #0,d7
	move.w d0,d7		;d7=x1*64
	swap d7				;d7*=65536
	lsr.l #6,d7			;d7/=64
	ext.l d2			
	moveq #0,d5			;d5=x increment
	sub.w d0,d1			;d1=(x2-x1)*64
	bge draw2d_polyline_positivedx
	; if dx<dy dx<<=16
	; if dx<dy*256	dx<<=8
	; else no shift
	neg.w d1
	ext.l d1
	cmp.w d2,d1
	bge draw2d_polyline_hisln
	swap d1
	divu d2,d1
	move.w d1,d5
	mulu d5,d6
	lsr.l #6,d6
	sub.l d6,d7
	jmp draw2d_polyline_enddivn
draw2d_polyline_hisln:
	move.l d2,d3
	asl.l #8,d3
	cmp.l d3,d1
	bge draw2d_polyline_medsln
	asl.l #8,d1
	divu d2,d1
	move.w d1,d5
	mulu d5,d6
	asl.l #2,d6
	sub.l d6,d7
	asl.l #8,d5
	jmp draw2d_polyline_enddivn
draw2d_polyline_medsln:
	divu d2,d1
	move.w d1,d5
	mulu d5,d6
	asr.l #6,d6
	swap d5
	swap d6
	sub.l d6,d7
draw2d_polyline_enddivn:
	neg.l d5
	;subq.l #1,d5
	jmp draw2d_polyline_enddivp
	
draw2d_polyline_positivedx:
	ext.l d1
	cmp.w d2,d1
	bge draw2d_polyline_hislp
	swap d1
	divu d2,d1
	move.w d1,d5
	mulu d5,d6
	lsr.l #6,d6
	add.l d6,d7
	jmp draw2d_polyline_enddivp
draw2d_polyline_hislp:
	move.l d2,d3
	asl.l #8,d3
	cmp.l d3,d1
	bge draw2d_polyline_medslp
	asl.l #8,d1
	divu d2,d1
	move.w d1,d5
	mulu d5,d6
	asl.l #2,d6
	add.l d6,d7
	asl.l #8,d5
	jmp draw2d_polyline_enddivp
draw2d_polyline_medslp:
	divu d2,d1
	move.w d1,d5
	mulu d5,d6
	asr.l #6,d6
	swap d5
	swap d6
	add.l d6,d7
draw2d_polyline_enddivp:
	swap d5
	swap d7
	;subq.w #1,d4
	add.w d4,d4
	add.w d4,d4
	neg.w d4
	move.l d5,(a2)+
	move.l d7,(a2)
	move.w (a3),d0
	addq.w #1,d0
	move.w d0,(a3)
	move.w d4,-(a3)
	
draw2d_polyline_loop2:	
	lea draw2d_skip_polygon_line(PC),a6
	move.l d5,d0
	clr.w d0
	add.l d0,d7
	jmp (a6,d4)
;draw2d_polyline_loop1:
	REPT 200
	move.w d7,-(a1)	; 33 07
	addx.l d5,d7	; DF 85
	ENDR
	;dbra.w d4,draw2d_polyline_loop1
draw2d_skip_polygon_line:
	rts
	
draw2d_rasterize_polygon:
	; inputs
	; a0 = screen buffer
	; d7 = color
	
	; A0 Screen line start		D0 Temporary
	; A1 Left table				D1 Line counter
	; A2 Right table			D2 Bitmask1 (16 bit)
	; A3 Screen pointer			D3 Bitmask1 neg (16 bit)
	; A4 Color 1 (32 bit)		D4 Bitmask2 (16 bit)
	; A5 Color 2 (32 bit)		D5 Bitmask2 neg (16 bit)
	; A6 Code pointer			D6 #15
	; A7 Stack pointer			D7 not #15 = #-16
	
	moveq #15,d6
	and.w d6,d7
	asl.w #4,d7
	lea draw2d_rasterize_color_code1(PC),a1
	lea draw2d_rasterize_color_code2(PC),a2
	lea draw2d_color_table(PC),a6
	adda.w d7,a6
	move.l (a6)+,a4	; first 2 bitplanes (words) in a4
	move.l (a6)+,a5 ; second 2 bitplanes (words) in a5
	move.l (a6)+,d0 ; code for first word for all bitplanes in d0
	move.l (a6)+,d1 ; code for last word for all bitplanes in d1
	movep.l d0,0(a1) ; replace first word code
	movep.l d1,0(a2) ; replace last/single word code
	moveq #-16,d7
		
	move.w draw2d_polygon_height,d1	; d1 = polygon height
	subq.w #1,d1					; d1-=1, for dbra instruction
	blt draw2d_rasterize_skip_polygon	; if smaller than 0, skip
	move.w draw2d_polygon_start,d0	; d0=y1
	add.w d0,d0						; d0*=2
	lea draw2d_span_buffer_left(PC),a1	
	lea draw2d_span_buffer_right(PC),a2
	adda.w d0,a1						; pointer to start of span buffer
	adda.w d0,a2
	lsl.w #4,d0		; next 5 instructions d0*=80
	move.w d0,d2
	add.w d2,d2
	add.w d2,d2
	add.w d0,d2
	lea (a0,d2),a0	; a0=screen line start
	lea draw2d_rasterize_last_word(PC),a6	; a6=code pointer
	;move.b	($0fff00),d0 ; trigger debugger
draw2d_rasterize_loop1:
	move.l a0,a3	; a0=start of the line, a3=start od the polygon
	move.w (a1)+,d0 ; d0=start x coordinate
	move.w (a2)+,d4 ; d4=end x coordinate
	cmp.w d0,d4
	ble draw2d_rasterize_skip_line ; right coordinate is the 1st pixel outside the polygon (left beacuse all is mirrored)
	move.w d0,d5
	move.w d4,d3
	and.w d7,d4
	and.w d7,d0
	asr.w #1,d0
	asr.w #1,d4
	sub.w d0,d4		; d4 = of full words x4 +1
	suba.w d0,a3	; a3=start of the polygon
	move.w d3,d0
	and.w d6,d5		; get bitmask1 index in d5
	beq draw2d_rasterize_skip_first_word
	moveq #-1,d2
	bclr.l d5,d2
	addq #1,d2
	subq.w #8,d4
	bpl draw2d_rasterize_skip_same_word
	and.w d6,d0	; get bitmask2 index in d0
	moveq #0,d4
	bset.l d0,d4
	subq #1,d4
	and.w d2,d4
	jmp draw2d_rasterize_same_word
draw2d_rasterize_skip_same_word:
	move.w d2,d3
	not.w d3
draw2d_rasterize_color_code1:
	REPT 4
	or.w d2,-(a3)	; or=(85 63), and=(C7 63)
	ENDR
draw2d_rasterize_skip_first_word:
	asr.w #1,d4
	neg.w d4
	jmp (a6,d4.w)
	REPT 20
	move.l a4,-(a3)			; 27 0C
	move.l a5,-(a3)			; 27 0D
	ENDR
draw2d_rasterize_last_word:
; last word
	and.w d6,d0	; get bitmask2 index in d0
	beq draw2d_rasterize_skip_line
	moveq #0,d4
	bset.l d0,d4
	subq #1,d4
draw2d_rasterize_same_word:	
	move.w d4,d5
	not.w d5
draw2d_rasterize_color_code2:
	REPT 4
	or.w d4,-(a3)	; or=(89 63), and=(CB 63)
	ENDR
draw2d_rasterize_skip_line:
	lea 160(a0),a0
	dbra d1,draw2d_rasterize_loop1
draw2d_rasterize_skip_polygon:
	rts

draw2d_clear_screen:
	; a0 = screen buffer
	moveq.l #-1,d0
	move.l d0,d1
	move.l d0,d2
	move.l d0,d3
	move.l d0,d4
	move.l d0,d5
	move.l d0,a2
	move.l d0,a3
	lea 32000(a0),a1
	move.w #49,d6
draw2d_clear_screen_loop:
	REPT 20
	movem.l d0-d5/a2-a3,-(a1)
	ENDR
	dbra.w d6,draw2d_clear_screen_loop
	rts

draw2d_point:
	; d0=x d1=y a0=screen
	asl.w #5,d1
	move.w d1,d2
	asl.w #2,d2
	add.w d2,d1
	move.w d0,d2
	asr.w #4,d0
	asl.w #3,d0
	add.w d0,d1		; d1=address
	andi.w #15,d2
	move.w #15,d3
	sub.w d2,d3
	moveq #0,d2
	bset.l d3,d2
	lea (a0,d1),a1
	or.w d2,(a1)+
	or.w d2,(a1)+
	or.w d2,(a1)+
	or.w d2,(a1)+
	rts

draw2d_draw_face:
; d0=face
	lea face_colors(PC),a4
	adda.w d0,a4
	moveq.l #0,d1
	move.b (a4),d1
	move.w d1,-(a7)
	lea faces(PC),a4
	asl.w #3,d0
	move.w d0,d7
	adda.w d0,a4
	move.w (a4)+,d0
	move.w (a4)+,d1
	move.w (a4)+,d2
	move.w (a4)+,d3
	add.w d0,d0
	add.w d0,d0
	add.w d1,d1
	add.w d1,d1
	add.w d2,d2
	add.w d2,d2
	add.w d3,d3
	add.w d3,d3
	lea vertices_screen(PC),a0
	move.l a0,a1
	move.l a0,a2
	move.l a0,a3
	adda.w d0,a0
	adda.w d1,a1
	adda.w d2,a2
	adda.w d3,a3
	; calculate visibility
	;area=x1*(y2-y1)+x2*(y3-y1)+x3*(y1-y2); // triangle area
	;area=d0*(d3-d1)+d2*(d5-d1)+d4*(d1-d3)
	move.w (a0)+,d0
	move.w (a0),d1
	move.w (a1)+,d2
	move.w (a1),d3
	move.w (a2)+,d4
	move.w (a2),d5
	; push vertices to Stack
	move.w d0,-(a7)
	move.w d1,-(a7)
	move.w d2,-(a7)
	move.w d3,-(a7)
	move.w d4,-(a7)
	move.w d5,-(a7)
	move.w d3,d6
	sub.w d5,d6
	muls d6,d0
	sub.w d1,d5
	muls d5,d2
	sub.w d3,d1
	muls d1,d4
	add.l d2,d0
	add.l d4,d0
	ble draw2d_skip_face
	move.w (a3)+,d0
	move.w (a3),d3
	move.w d0,-(a7)
	move.w d3,-(a7)
	; clear top and bottom
	lea draw2d_polygon_start(PC),a4
	;move.l #$7fff8000,d4
	move.l #$7fff8000,(a4)
	; d0,d1 = x1,x2 16bit (1+9+6)
	; d2,d3 = y1,y2 16bit (1+9+6)
	; d4 = egde index
	lea edges(PC),a4
	adda.w d7,a4
	move.w (a4)+,d4
	move.w d4,-(a7)
	move.w (a4)+,d0
	move.w d0,-(a7)
	move.w (a4)+,d0
	move.w d0,-(a7)
	move.w (a4)+,d0
	move.w d0,-(a7)
	; stack: ed4,ed3,ed2,ed1,y4,x4,y3,x3,y2,x2,y1,x1,color
	move.w (a0),d2
	move.w -(a0),d0
	move.w (a1),d3
	move.w -(a1),d1
;	move.b	($0fff00),d0 ; trigger debugger
	bsr draw2d_polygon_line ; edge 1-2
	move.l a7,a0
	addq.l #4,a0
	move.w (a0)+,d4
	addq.l #6,a0
	move.w (a0)+,d3
	move.w (a0)+,d1
	move.w (a0)+,d2
	move.w (a0)+,d0
	bsr draw2d_polygon_line ; edge 2-3
	move.l a7,a0
	addq.l #2,a0
	move.w (a0)+,d4
	addq.l #4,a0
	move.w (a0)+,d3
	move.w (a0)+,d1
	move.w (a0)+,d2
	move.w (a0)+,d0
	;move.b	($0fff00),d0 ; trigger debugger
	bsr draw2d_polygon_line ; edge 3-4
	move.l a7,a0
	move.w (a0)+,d4
	addq.l #6,a0
	move.w (a0)+,d2
	move.w (a0)+,d0
	addq.l #8,a0
	move.w (a0)+,d3
	move.w (a0)+,d1
	bsr draw2d_polygon_line ; edge 4-1
	lea draw2d_polygon_start(PC),a0
	;move.b	($0fff00),d0 ; trigger debugger
	move.w (a0),d0
	asr.w #6,d0
	;addq.w #1,d0
	move.w d0,(a0)
	add.w #1,(a0)+
	move.w (a0),d1
	asr.w #6,d1
	sub.w d0,d1
	;subq.w #1,d1
	move.w d1,(a0)
	move.l scr_address,a0
	moveq.l #12,d0
	adda.w d0,a7
	move.l a7,a1
	adda.w d0,a1
	move.w (a1),d7
	bsr draw2d_rasterize_polygon		
draw2d_skip_face:
	moveq.l #14,d0
	adda.w d0,a7
	rts
	
;182,138
;132,39
;108,117

;11668,8852
;8468,2516
;6932,7508

;X1,X2,Y1,Y2
;1. 11668,8468,8852,2516 (right)
;2. 11668,6932,8852,7508 (left)
;3. 6932,8468,7508,2516 (left)
draw2d_polygon_start:
	dc.w	40
draw2d_polygon_height:
	dc.w	120
draw2d_span_buffer_left:
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85
	dc.w	85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85
	dc.w	85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85
	dc.w	85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85
	dc.w	85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85
	dc.w	85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	
;	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;	dc.w	133,133,133,132,132,132,131,131,131,130,130,130,129,129,129,128,128,128,127,127
;	dc.w	127,126,126,126,125,125,125,124,124,124,123,123,123,122,122,122,121,121,121,120
;	dc.w	120,120,120,119,119,119,118,118,118,117,117,117,116,116,116,115,115,115,114,114
;	dc.w	114,113,113,113,112,112,112,111,111,111,110,110,110,109,109,109,108,108,111,115
;	dc.w	118,122,126,130,133,137,141,145,148,152,156,160,163,167,171,175,178,182,0,0
;	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
draw2d_span_buffer_right:
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	235,235,235,235,235,235,235,235,235,235,235,235,235,235,235,235,235,235,235,235
	dc.w	235,235,235,235,235,235,235,235,235,235,235,235,235,235,235,235,235,235,235,235
	dc.w	235,235,235,235,235,235,235,235,235,235,235,235,235,235,235,235,235,235,235,235
	dc.w	235,235,235,235,235,235,235,235,235,235,235,235,235,235,235,235,235,235,235,235
	dc.w	235,235,235,235,235,235,235,235,235,235,235,235,235,235,235,235,235,235,235,235
	dc.w	235,235,235,235,235,235,235,235,235,235,235,235,235,235,235,235,235,235,235,235
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

;	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;	dc.w	132,133,134,134,135,135,136,136,137,137,138,138,139,140,140,141,141,142,142,143
;	dc.w	143,144,144,145,145,146,146,147,147,148,148,149,149,150,150,151,152,152,153,153
;	dc.w	154,154,155,155,156,156,157,157,158,158,159,159,160,160,161,161,162,162,163,163
;	dc.w	164,165,165,166,166,167,167,168,168,169,169,170,170,171,171,172,172,173,173,174
;	dc.w	174,175,175,176,177,177,178,178,179,179,180,180,181,181,182,182,183,183,0,0
;	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
draw2d_color_table:
;	dc.l	$00000000,$00000000,$c7c7c7c7,$cbcbcbcb
;	dc.l	$ffff0000,$00000000,$85c7c7c7,$89cbcbcb
;	dc.l	$0000ffff,$00000000,$c785c7c7,$cb89cbcb
;	dc.l	$ffffffff,$00000000,$8585c7c7,$8989cbcb
;	dc.l	$00000000,$ffff0000,$c7c785c7,$cbcb89cb
;	dc.l	$ffff0000,$ffff0000,$85c785c7,$89cb89cb
;	dc.l	$0000ffff,$ffff0000,$c78585c7,$cb8989cb
;	dc.l	$ffffffff,$ffff0000,$858585c7,$898989cb
;	dc.l	$00000000,$0000ffff,$c7c7c785,$cbcbcb89
;	dc.l	$ffff0000,$0000ffff,$85c7c785,$89cbcb89
;	dc.l	$0000ffff,$0000ffff,$c785c785,$cb89cb89
;	dc.l	$ffffffff,$0000ffff,$8585c785,$8989cb89
;	dc.l	$00000000,$ffffffff,$c7c78585,$cbcb8989
;	dc.l	$ffff0000,$ffffffff,$85c78585,$89cb8989
;	dc.l	$0000ffff,$ffffffff,$c7858585,$cb898989
;	dc.l	$ffffffff,$ffffffff,$85858585,$89898989

	dc.l	$00000000,$00000000,$c7c7c7c7,$cbcbcbcb
	dc.l	$00000000,$ffff0000,$c7c7c785,$cbcbcb89
	dc.l	$00000000,$0000ffff,$c7c785c7,$cbcb89cb
	dc.l	$00000000,$ffffffff,$c7c78585,$cbcb8989
	dc.l	$ffff0000,$00000000,$c785c7c7,$cb89cbcb
	dc.l	$ffff0000,$ffff0000,$c785c785,$cb89cb89
	dc.l	$ffff0000,$0000ffff,$c78585c7,$cb8989cb
	dc.l	$ffff0000,$ffffffff,$c7858585,$cb898989
	dc.l	$0000ffff,$00000000,$85c7c7c7,$89cbcbcb
	dc.l	$0000ffff,$ffff0000,$85c7c785,$89cbcb89
	dc.l	$0000ffff,$0000ffff,$85c785c7,$89cb89cb
	dc.l	$0000ffff,$ffffffff,$85c78585,$89cb8989
	dc.l	$ffffffff,$00000000,$8585c7c7,$8989cbcb
	dc.l	$ffffffff,$ffff0000,$8585c785,$8989cb89
	dc.l	$ffffffff,$0000ffff,$858585c7,$898989cb
	dc.l	$ffffffff,$ffffffff,$85858585,$89898989

draw2d_div_table:
	dc.w $ffff,$ffff,$8000,$5555,$4000,$3333,$2aab,$2492,$2000,$1c72,$199a,$1746,$1555,$13b1,$1249,$1111
	dc.w $1000,$0f0f,$0e39,$0d79,$0ccd,$0c31,$0ba3,$0b21,$0aab,$0a3d,$09d9,$097b,$0925,$08d4,$0889,$0842
	dc.w $0800,$07c2,$0788,$0750,$071c,$06eb,$06bd,$0690,$0666,$063e,$0618,$05f4,$05d1,$05b0,$0591,$0572
	dc.w $0555,$0539,$051f,$0505,$04ec,$04d5,$04be,$04a8,$0492,$047e,$046a,$0457,$0444,$0432,$0421,$0410
	dc.w $0400,$03f0,$03e1,$03d2,$03c4,$03b6,$03a8,$039b,$038e,$0382,$0376,$036a,$035e,$0353,$0348,$033e
	dc.w $0333,$0329,$031f,$0316,$030c,$0303,$02fa,$02f1,$02e9,$02e0,$02d8,$02d0,$02c8,$02c1,$02b9,$02b2
	dc.w $02ab,$02a4,$029d,$0296,$028f,$0289,$0283,$027c,$0276,$0270,$026a,$0264,$025f,$0259,$0254,$024e
	dc.w $0249,$0244,$023f,$023a,$0235,$0230,$022b,$0227,$0222,$021e,$0219,$0215,$0211,$020c,$0208,$0204
	dc.w $0200,$01fc,$01f8,$01f4,$01f0,$01ed,$01e9,$01e5,$01e2,$01de,$01db,$01d7,$01d4,$01d1,$01ce,$01ca
	dc.w $01c7,$01c4,$01c1,$01be,$01bb,$01b8,$01b5,$01b2,$01af,$01ac,$01aa,$01a7,$01a4,$01a1,$019f,$019c
	dc.w $019a,$0197,$0195,$0192,$0190,$018d,$018b,$0188,$0186,$0184,$0182,$017f,$017d,$017b,$0179,$0176
	dc.w $0174,$0172,$0170,$016e,$016c,$016a,$0168,$0166,$0164,$0162,$0160,$015e,$015d,$015b,$0159,$0157
	dc.w $0155,$0154,$0152,$0150,$014e,$014d,$014b,$0149,$0148,$0146,$0144,$0143,$0141,$0140,$013e,$013d
	dc.w $013b,$013a,$0138,$0137,$0135,$0134,$0132,$0131,$012f,$012e,$012d,$012b,$012a,$0129,$0127,$0126
	dc.w $0125,$0123,$0122,$0121,$011f,$011e,$011d,$011c,$011a,$0119,$0118,$0117,$0116,$0115,$0113,$0112
	dc.w $0111,$0110,$010f,$010e,$010d,$010b,$010a,$0109,$0108,$0107,$0106,$0105,$0104,$0103,$0102,$0101
	
	