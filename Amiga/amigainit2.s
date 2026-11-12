amiga_init:
        move.l  4.w,a6                  ; ExecBase
        lea     gfxname(pc),a1
        moveq   #0,d0
        jsr     _LVOOpenLibrary(a6)
        move.l  d0,gfxbase
        beq     nogfx
 
        ; ---- allocate chip RAM (MEMF_CHIP|MEMF_CLEAR), buffers + copper
        move.l  4.w,a6
        move.l  #ALLOCSZ,d0
        move.l  #$10002,d1
        jsr     _LVOAllocMem(a6)
        move.l  d0,chipmem
        beq     nomem
 
        move.l  d0,buf_front
        add.l   #BUFSZ,d0
        move.l  d0,buf_back
        add.l   #BUFSZ,d0
        move.l  d0,copbase
 
        ; ---- copy copper template into chip RAM
        lea     coptmpl(pc),a0
        move.l  copbase,a1
        move.w  #(coptmpl_end-coptmpl)/2-1,d1
.cpy:   move.w  (a0)+,(a1)+
        dbra    d1,.cpy
 
        move.l  buf_front,d0
        bsr     setptrs                 ; copper shows front buffer first
 
        ; ---- take over the machine
        move.l  gfxbase,a6
        move.l  gb_ActiView(a6),oldview
        sub.l   a1,a1
        jsr     _LVOLoadView(a6)        ; LoadView(NULL)
        jsr     _LVOWaitTOF(a6)         ; let the old display finish
        jsr     _LVOWaitTOF(a6)
 
        move.l  4.w,a6
        jsr     _LVOForbid(a6)
 
        lea     $dff000,a5
        move.w  INTENAR(a5),oldintena
        move.w  DMACONR(a5),olddma
        move.w  #$7fff,INTENA(a5)       ; all interrupts off
        move.w  #$7fff,DMACON(a5)       ; all DMA off
 
        move.l  copbase,COP1LC(a5)
        move.w  d0,COPJMP1(a5)          ; strobe: start copper at our list
        move.w  #$83c0,DMACON(a5)       ; DMAEN+BPLEN+COPEN+BLTEN
		rts
		
clear_back_buffer:
		; ---- clear back buffer with the blitter (512 rows x 40 words)
        bsr     waitblit
        move.w  #$0100,BLTCON0(a5)      ; D only, minterm 0  -> clear
        move.w  #0,BLTCON1(a5)
        move.w  #$ffff,BLTAFWM(a5)
        move.w  #$ffff,BLTALWM(a5)
        move.w  #0,BLTDMOD(a5)
        move.l  buf_back,BLTDPT(a5)
        move.w  #(512<<6)|40,BLTSIZE(a5)
        ;bsr     waitblit
		rts
buffer_swap:
        ; ---- point the copper at the back buffer; it becomes visible
        ;      when the copper restarts at the next vertical blank
        move.l  buf_back,d0
        bsr     setptrs
 
        bsr     waitvbl                 ; wait until new frame has started
 
        ; ---- swap buffers (old front is no longer displayed -> safe to draw)
        move.l  buf_front,d0
        move.l  buf_back,buf_front
        move.l  d0,buf_back
		rts
;---------------------------------------------------------------------
; waitblit - wait until blitter is idle  (a5 = $dff000)
;---------------------------------------------------------------------
waitblit:
		lea     $dff000,a5
        tst.b   DMACONR(a5)             ; dummy read (OCS Agnus quirk)
.w:     btst    #6,DMACONR(a5)          ; BBUSY
        bne.s   .w
        rts
 
;---------------------------------------------------------------------
; waitvbl - wait for raster line 1 (copper has already reloaded the
;           bitplane pointers at line 0)
;---------------------------------------------------------------------
waitvbl:
.w:     move.l  $dff004,d0              ; VPOSR/VHPOSR
        and.l   #$1ff00,d0
        ;cmp.l   #$00100,d0
		beq.s	.w
.w1:	move.l	$dff004,d0
		and.l	#$1ff00,d0
        bne.s   .w1
        rts
 
;---------------------------------------------------------------------
; setptrs - write bitplane addresses for buffer d0 into the copper list
;---------------------------------------------------------------------
setptrs:
        move.l  copbase,a1
        lea     COPBPL(a1),a1
        moveq   #PLANES-1,d1
.p:     move.l  d0,d2
        swap    d2
        move.w  d2,2(a1)                ; BPLxPTH value
        move.w  d0,6(a1)                ; BPLxPTL value
        add.l   #PLANESZ,d0
        addq.l  #8,a1
        dbra    d1,.p
        rts

clean_exit:
;---------------------------------------------------------------------
; clean exit
;---------------------------------------------------------------------
        bsr     waitblit
        move.w  #$7fff,DMACON(a5)
 
        move.l  gfxbase,a0
        move.l  gb_copinit(a0),COP1LC(a5)       ; system copper list back
        move.w  d0,COPJMP1(a5)
 
        move.w  olddma,d0
        or.w    #$8000,d0
        move.w  d0,DMACON(a5)           ; restore DMA
        move.w  oldintena,d0
        or.w    #$c000,d0
        move.w  d0,INTENA(a5)           ; restore interrupts
 
        move.l  gfxbase,a6
        move.l  oldview,a1
        jsr     _LVOLoadView(a6)        ; restore Workbench/CLI view
        jsr     _LVOWaitTOF(a6)
 
        move.l  4.w,a6
        jsr     _LVOPermit(a6)
 
        move.l  chipmem,a1
        move.l  #ALLOCSZ,d0
        jsr     _LVOFreeMem(a6)
 
nomem:  move.l  4.w,a6
        move.l  gfxbase,a1
        jsr     _LVOCloseLibrary(a6)
nogfx:  movem.l (sp)+,d2-d7/a2-a6
        moveq   #0,d0                   ; return code 0
        rts
 
;---------------------------------------------------------------------
; data
;---------------------------------------------------------------------
gfxname:        dc.b    "graphics.library",0
        even
 
gfxbase:        dc.l    0
chipmem:        dc.l    0
copbase:        dc.l    0
buf_front:      dc.l    0
buf_back:       dc.l    0
oldview:        dc.l    0
oldintena:      dc.w    0
olddma:         dc.w    0
ypos:           dc.w    0
 
; ---- copper list template (copied to chip RAM at startup)
COPBPL          equ     cop_bpl-coptmpl
 
coptmpl:
        dc.w    $0100,$4200             ; BPLCON0: 4 bitplanes, colour on
        dc.w    $0102,$0000             ; BPLCON1
        dc.w    $0104,$0000             ; BPLCON2
        dc.w    $0108,$0000             ; BPL1MOD
        dc.w    $010a,$0000             ; BPL2MOD
        dc.w    $008e,$2c81             ; DIWSTRT
        dc.w    $0090,$2cc1             ; DIWSTOP  (256 lines)
        dc.w    $0092,$0038             ; DDFSTRT
        dc.w    $0094,$00d0             ; DDFSTOP  (320 pixels)
        ; palette
        dc.w    $0180,$0000,$0182,$0888,$0184,$0888,$0186,$0bbb
        dc.w    $0188,$0888,$018a,$0bbb,$018c,$0bbb,$018e,$0ddd
        dc.w    $0190,$0888,$0192,$0bbb,$0194,$0bbb,$0196,$0ddd
        dc.w    $0198,$0bbb,$019a,$0ddd,$019c,$0ddd,$019e,$0fff
cop_bpl:
        dc.w    $00e0,$0000,$00e2,$0000 ; BPL1PT
        dc.w    $00e4,$0000,$00e6,$0000 ; BPL2PT
        dc.w    $00e8,$0000,$00ea,$0000 ; BPL3PT
        dc.w    $00ec,$0000,$00ee,$0000 ; BPL4PT
        dc.w    $ffff,$fffe             ; end of copper list
coptmpl_end:
