blit2d_line_lp:
	; inputs:
	; a0 = bitplane buffer pointer
	; d0,d1 = x1,x2 16bit (1+9+6)
	; d2,d3 = y1,y2 16bit (1+9+6)
	
	asr.w #6,d0
	asr.w #6,d1
	asr.w #6,d2
	asr.w #6,d3

	lea $dff000,a1		; custom chips address
	
	sub.w d2,d3			; d3=dy
	sub.w d0,d1			; d1=dx
	
	asl.w #3,d2
	move.w d2,d4
	add.w d4,d4
	add.w d4,d4
	add.w d4,d2
	;mulu.w #40,d2		; y1*40
	adda.w d2,a0
	move.w d0,d4
	lsr.w #4,d4
	add.w d4,d4
	adda.w d4,a0		; starting address in ram
	
	and.w #$f,d0		; d0=x1 & 15
	ror.w #4,d0			; shift into bits 12-15 of BLTCON0
	
    ; BLTCON0: Shift value (bits 12-15) | Channels A, C, D | Minterm $4A (XOR) or $CA (OR)
    ; We use $CA for overwriting
	or.w #$0bca,d0
	
	; BLTCON1: bit2=major axis sigh, bit3=minor axis sign, bit4=major axis
	; octant
	moveq #17,d5
	moveq #0,d6
	tst.w d3
	bge.s .dypos
	neg.w d3
	addq #8,d5
	moveq #12,d6
.dypos:
	tst.w d1
	bge.s .dxpos
	neg.w d1
	addq #4,d5
	eor.b #12,d6
.dxpos:
	cmp.w d1,d3
	ble.s .xmajor
	eor.b d6,d5
	sub.b #16,d5
	exg d1,d3
.xmajor:
	
	; Bresenham parameters: small=d3, big=d1
	move.w d3,d4
	lsl.w #2,d4		; d4=4*small
	move.w d4,d6
	sub.w d1,d6
	sub.w d1,d6		; d6=4*small-2*big
	bpl .nosign
	or.b #$40,d5	; SIGN bit when initial error<0
.nosign:
	move.w d1,d2
	lsl.w #2,d2		; d2=4*big
	
	; wait for blitter, double test for old Agnus bug
	btst #14,DMACONR(a1)
.wait_blit
	btst #14,DMACONR(a1)
	bne .wait_blit
	
	move.w #$8000,BLTADAT(a1)	; single pixel mask
	move.w #$ffff,BLTBDAT(a1)	; solid line pattern
	moveq #-1,d3
	move.l d3,BLTAFWM(a1)		; BLTAFWM and BLTALWM = $ffff
	move.w #40,BLTCMOD(a1)
	move.w #40,BLTDMOD(a1)
	move.w d4,BLTBMOD(a1)		; 4*small
	sub.w d2,d4
	move.w d4,BLTAMOD(a1)		; 4*(small-big)
	move.w d6,BLTAPT+2(a1)		; initial error (accumulator), only low word
	move.w d0,BLTCON0(a1)
	move.w d5,BLTCON1(a1)
	move.l a0,BLTCPT(a1)
	move.l a0,BLTDPT(a1)
	
	;addq.w #1,d1		; add 1 pixel to line length
	lsl.w #6,d1
	addq.w #2,d1
	move.w d1,BLTSIZE(a1)
	
	rts
blit2d_line:
	move.l a0,blit2d_line_a0
	move.w d0,blit2d_line_d0
	move.w d1,blit2d_line_d1
	move.w d2,blit2d_line_d2
	move.w d3,blit2d_line_d3
	bsr blit2d_line_hp
	move.l blit2d_line_a0,a0
	adda.w #10240,a0
	move.w blit2d_line_d0,d0
	move.w blit2d_line_d1,d1
	add.w #32,d0
	add.w #32,d1
	move.w blit2d_line_d2,d2
	move.w blit2d_line_d3,d3
	bsr blit2d_line_hp
	move.l blit2d_line_a0,a0
	adda.w #20480,a0
	move.w blit2d_line_d0,d0
	move.w blit2d_line_d1,d1
	move.w blit2d_line_d2,d2
	move.w blit2d_line_d3,d3
	add.w #32,d2
	add.w #32,d3
	bsr blit2d_line_hp
	move.l blit2d_line_a0,a0
	adda.w #30720,a0
	move.w blit2d_line_d0,d0
	move.w blit2d_line_d1,d1
	move.w blit2d_line_d2,d2
	move.w blit2d_line_d3,d3
	add.w #32,d0
	add.w #32,d1
	add.w #32,d2
	add.w #32,d3
	bsr blit2d_line_hp

	rts
blit2d_line_a0:
	dc.l 0
blit2d_line_d0:
	dc.l 0
blit2d_line_d1:
	dc.l 0
blit2d_line_d2:
	dc.l 0
blit2d_line_d3:
	dc.l 0

blit2d_line_hp:
	; inputs:
	; a0 = bitplane buffer pointer
	; d0,d1 = x1,x2 16bit (1+9+6)
	; d2,d3 = y1,y2 16bit (1+9+6)
	
	asr.w #1,d0
	asr.w #1,d1
	asr.w #1,d2
	asr.w #1,d3

	lea $dff000,a1		; custom chips address
	
	move.w d3,d7		; save d7 for line length
	or.b #31,d7
	sub.w d2,d7
	swap d7
	move.w d1,d7
	or.b #31,d7
	sub.w d0,d7
	
	sub.w d2,d3			; d3=dy
	sub.w d0,d1			; d1=dx
	
	move.w d2,d5
	and.w #$ffe0,d5
	move.w d5,d4
	asr.w #2,d4
	add.w d4,d5
	;mulu.w #40,d2		; y1*40
	adda.w d5,a0
	move.w d0,d4
	lsr.w #8,d4
	and.b #$fe,d4
	adda.w d4,a0		; starting address in ram
	
	move.w d0,d6
	and.w #$1e0,d6		; d0=x1 & 15
	lsl.w #7,d6			; shift into bits 12-15 of BLTCON0
	
    ; BLTCON0: Shift value (bits 12-15) | Channels A, C, D | Minterm $4A (XOR) or $CA (OR)
    ; We use $CA for overwriting
	or.w #$0bca,d6
	swap d6
	
	; BLTCON1: bit2=major axis sigh, bit3=minor axis sign, bit4=major axis
	; octant
	moveq #17,d5
	clr.w d6
	tst.w d3
	bge.s .dypos
	neg.w d3
	swap d7
	neg.w d7
	swap d7
	addq #8,d5
	add.b #12,d6
	eor.b #31,d2
.dypos:
	tst.w d1
	bge.s .dxpos
	neg.w d1
	neg.w d7
	addq #4,d5
	eor.b #12,d6
	eor.b #31,d0
.dxpos:
	cmp.w d1,d3
	ble.s .xmajor
	eor.b d6,d5
	sub.b #16,d5
	exg d1,d3
	exg d0,d2
	swap d7
.xmajor:
	
	and.w #31,d0
	and.w #31,d2
	eor.b #31,d0
	eor.b #31,d2
	; Bresenham parameters: small=d3, big=d1
	move.w d3,d4
	lsl.w #1,d4		; d4=2*small

	mulu d3,d0
	mulu d1,d2
	sub.l d2,d0
	asr.l #4,d0
	and.w #$fffe,d0
	move.w d0,d6
;	move.w d4,d6
;	sub.w d1,d6
;	sub.w d1,d6		; d6=4*small-2*big

	bpl .nosign
	or.b #$40,d5	; SIGN bit when initial error<0
.nosign:
	move.w d1,d2
	lsl.w #1,d2		; d2=2*big
	
	; wait for blitter, double test for old Agnus bug
	btst #14,DMACONR(a1)
.wait_blit
	btst #14,DMACONR(a1)
	bne .wait_blit
	
	move.w #$8000,BLTADAT(a1)	; single pixel mask
	move.w #$ffff,BLTBDAT(a1)	; solid line pattern
	moveq #-1,d3
	move.l d3,BLTAFWM(a1)		; BLTAFWM and BLTALWM = $ffff
	move.w #40,BLTCMOD(a1)
	move.w #40,BLTDMOD(a1)
	move.w d4,BLTBMOD(a1)		; 4*small
	sub.w d2,d4
	move.w d4,BLTAMOD(a1)		; 4*(small-big)
	move.w d6,BLTAPT+2(a1)		; initial error (accumulator), only low word
	swap d6
	move.w d6,BLTCON0(a1)
	move.w d5,BLTCON1(a1)
	move.l a0,BLTCPT(a1)
	move.l a0,BLTDPT(a1)
	
	;addq.w #1,d1		; add 1 pixel to line length
	;move.w d1,d7
	and.w #$ffe0,d7
	add.w #32,d7
	add.w d7,d7
	addq.w #2,d7
	move.w d7,BLTSIZE(a1)
	
	rts
