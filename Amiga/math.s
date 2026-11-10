math_getsincos:
	; d0 = angle
	; returns d1=sine, d2=cosine
	move.w #$0ffe,d2
	lea sine_table(PC),a0
	move.w d0,d1
	add.w d1,d1
	and.w d2,d1
	addq.w #2,d2
	sub.w d1,d2
	move.w (a0,d1),d1
	move.w (a0,d2),d2
	btst #11,d0
	beq math_sincos_skip1
	exg d1,d2
	neg.w d2
math_sincos_skip1:
	btst #12,d0
	beq math_sincos_skip2
	neg.w d1
	neg.w d2
math_sincos_skip2:
	rts

math_transformation:
; transformation matrix
;	[cosc*cosb,  -sinc*cosa+cosc*sinb*sina,  sinc*sina+cosc*sinb*cosa],
;	[sinc*cosb,  cosc*cosa+sinc*sinb*sina,  -cosc*sina+sinc*sinb*cosa],
;	[-sinb,  cosb*sina,  cosb*cosa]

;	sbsc=sb*sc	sbcc=sb*cc	cacc=ca*cc
;	[cb*cc,  -sc*ca+sa*sbcc,  sa*sc+sb*cacc],
;	[sc*cb,  cacc+sa*sbsc,  -sa*cc+sbsc*ca],
;	[-sb,  sa*cb,  ca*cb]
	lea transform_angles(PC),a1
	move.w (a1)+,d0
	bsr math_getsincos
	move.w d1,d6	; d6=sa
	move.w d2,d7	; d7=ca
	move.w (a1)+,d0
	bsr math_getsincos
	move.w d1,d4	; d4=sb
	move.w d2,d5	; d5=cb
	move.w (a1)+,d0
	bsr math_getsincos ; d1=sc  d2=cc  d0,d3 are free
	lea transform_matrix+18(PC),a2
	move.w d7,d0	; ca
	muls d5,d0		; ca*cb=d0
	swap d0			; divide by 65536 range +-16384
	move.w d0,-(a2)	; last matrix element #8
	move.w d6,d0	; sa
	muls d5,d0		; sa*cb=d0
	swap d0			; divide by 65536
	move.w d0,-(a2)	; matrix element #7
	move.w d4,d0	; sb
	asr.w #1,d0
	neg.w d0
	move.w d0,-(a2)	; matrix element #6
; -sa*cc+sbsc*ca
	move.w d4,d3	; sb
	muls d1,d3		; sbsc=d3
	add.l d3,d3
	swap d3
	move.w d7,d0	; ca
	muls d3,d0		; sbsc*ca
	move.l d3,a3	; a3=sbsc backup
	move.w d6,d3	; sa
	neg.w d3
	muls d2,d3		; -sa*cc=d3
	add.l d3,d0
	swap d0
	move.w d0,-(a2)	; matrix element #5
; cacc+sa*sbsc	
	move.l a3,d0	;sbsc=d0
	muls d6,d0		;sa*sbsc=d0
	move.w d7,d3	;ca
	muls d2,d3		;cacc=d3
	add.l d3,d0
	swap d0
	move.w d0,-(a2)	; matrix element #4
; sc*cb
	move.w d1,d0	; sc
	muls d5,d0		; sc*cb=d0
	swap d0
	move.w d0,-(a2)	; matrix element #3
;	[cb*cc,  -sc*ca+sa*sbcc,  sa*sc+sb*cacc],	
	add.l d3,d3		; fix cacc
	swap d3
	muls d4,d3		; sb*cacc=d3
	move.w d6,d0	; sa
	muls d1,d0		; sa*sc=d0
	add.l d3,d0
	swap d0
	move.w d0,-(a2)	; matrix element #2
	move.w d4,d3	; sb
	muls d2,d3		; sb*cc=d3
	add.l d3,d3
	swap d3
	muls d6,d3		; sa*sb*cc=d3
	move.w d1,d0	; sc
	neg.w d0
	muls d7,d0		; -sc*ca=d0
	add.l d3,d0
	swap d0
	move.w d0,-(a2)	; matrix element #1
	muls d5,d2		; cb*cc
	swap d2
	move.w d2,-(a2)	; matrix element #0
	
; d0,d1 - calculation
; d2,d3,d4 - x,y,z
; a3,d5,d6 - increments
; a2 - matrix,  a0 - vertices, a1 - transformed vertices
; a4,a5 - xrotated, yrotated
; d7 loop counter
;	move.b	($0fff00),d0 ; trigger debugger
	moveq.l #7,d7
	move.l #22118,a3		; z
	move.w #10240,d5		; x
	move.w #8192,d6			; y
	lea vertices(PC),a0
	lea vertices_screen(PC),a1
math_transformation_loop1:
	move.w (a0)+,d2
	move.w (a2)+,d0
	muls d2,d0
	move.l d0,d1
	move.w (a0)+,d3
	move.w (a2)+,d0
	muls d3,d0
	add.l d0,d1
	move.w (a0)+,d4
	move.w (a2)+,d0
	muls d4,d0
	add.l d0,d1
	move.l d1,a4	; X
	move.w (a2)+,d0
	muls d2,d0
	move.l d0,d1
	move.w (a2)+,d0
	muls d3,d0
	add.l d0,d1
	move.w (a2)+,d0
	muls d4,d0
	add.l d0,d1
	move.l d1,a5	; Y
	move.w (a2)+,d0
	muls d2,d0
	move.l d0,d1
	move.w (a2)+,d0
	muls d3,d0
	add.l d0,d1
	move.w (a2),d0
	muls d4,d0
	add.l d0,d1		; Z=d1

	add.l d1,d1
	;add.l d1,d1
	swap d1
	add.l a3,d1		; Z increment
	move.l a4,d0
	asr.l #1,d0
	neg.l d0
	divs d1,d0
	add.w d5,d0
	move.w d0,(a1)+	; x screen
	move.l a5,d0
	asr.l #1,d0
	divs d1,d0
	add.w d6,d0
	move.w d0,(a1)+ ; y screen
	suba.w #16,a2
	dbra.w d7,math_transformation_loop1
	rts
	