;---------------------------------------------------------------------
start:
		include "constants.s"
        movem.l d2-d7/a2-a6,-(sp)	; store registers state
		bsr amiga_init
   
;---------------------------------------------------------------------
; main loop
;---------------------------------------------------------------------
mainloop:
		bsr		clear_back_buffer
		;bsr		clear_edge_buffers
		;bsr		draw2d_clear_screen

		bsr		math_transformation

		move.l	buf_back,a0

		lea vertices_screen(PC),a6
		move.w (a6)+,d0
		move.w (a6)+,d2
		move.w (a6)+,d1
		move.w (a6)+,d3
		bsr blit2d_line
		move.l	buf_back,a0
		suba.w #4,a6
		move.w (a6)+,d0
		move.w (a6)+,d2
		move.w (a6)+,d1
		move.w (a6)+,d3
		bsr blit2d_line
		move.l	buf_back,a0
		suba.w #4,a6
		move.w (a6)+,d0
		move.w (a6)+,d2
		move.w (a6)+,d1
		move.w (a6)+,d3
		bsr blit2d_line
		move.l	buf_back,a0
		suba.w #4,a6
		move.w (a6)+,d0
		move.w (a6)+,d2
		suba.w #16,a6
		move.w (a6)+,d1
		move.w (a6)+,d3
		bsr blit2d_line
		move.l	buf_back,a0
		suba.w #4,a6
		move.w (a6)+,d0
		move.w (a6)+,d2
		adda.w #12,a6
		move.w (a6)+,d1
		move.w (a6)+,d3
		bsr blit2d_line
		move.l	buf_back,a0
		suba.w #16,a6
		move.w (a6)+,d0
		move.w (a6)+,d2
		adda.w #12,a6
		move.w (a6)+,d1
		move.w (a6)+,d3
		bsr blit2d_line
		move.l	buf_back,a0
		suba.w #16,a6
		move.w (a6)+,d0
		move.w (a6)+,d2
		adda.w #12,a6
		move.w (a6)+,d1
		move.w (a6)+,d3
		bsr blit2d_line
		move.l	buf_back,a0
		suba.w #16,a6
		move.w (a6)+,d0
		move.w (a6)+,d2
		adda.w #12,a6
		move.w (a6)+,d1
		move.w (a6)+,d3
		bsr blit2d_line
		move.l	buf_back,a0
		suba.w #16,a6
		move.w (a6)+,d0
		move.w (a6)+,d2
		move.w (a6)+,d1
		move.w (a6)+,d3
		bsr blit2d_line
		move.l	buf_back,a0
		suba.w #4,a6
		move.w (a6)+,d0
		move.w (a6)+,d2
		move.w (a6)+,d1
		move.w (a6)+,d3
		bsr blit2d_line
		move.l	buf_back,a0
		suba.w #4,a6
		move.w (a6)+,d0
		move.w (a6)+,d2
		move.w (a6)+,d1
		move.w (a6)+,d3
		bsr blit2d_line
		move.l	buf_back,a0
		suba.w #4,a6
		move.w (a6)+,d0
		move.w (a6)+,d2
		suba.w #16,a6
		move.w (a6)+,d1
		move.w (a6)+,d3
		bsr blit2d_line

;		move.l	buf_back,a0
;		move.w #10240,d0
;		move.w #16640,d1
;		move.w #8192,d2
;		move.w #8832,d3
;		bsr blit2d_line
;		move.l	buf_back,a0
;		move.w #10240,d0
;		move.w #10880,d1
;		move.w #8192,d2
;		move.w #14592,d3
;		bsr blit2d_line
;		move.l	buf_back,a0
;		move.w #10240,d0
;		move.w #9600,d1
;		move.w #8192,d2
;		move.w #14592,d3
;		bsr blit2d_line
;		move.l	buf_back,a0
;		add.l #10240,a0
;		move.w #10240,d0
;		move.w #3840,d1
;		move.w #8192,d2
;		move.w #8832,d3
;		bsr blit2d_line
;		move.l	buf_back,a0
;		add.l #10240,a0
;		move.w #10240,d0
;		move.w #3840,d1
;		move.w #8192,d2
;		move.w #7552,d3
;		bsr blit2d_line
;		move.l	buf_back,a0
;		move.w #10240,d0
;		move.w #9600,d1
;		move.w #8192,d2
;		move.w #1792,d3
;		bsr blit2d_line
;		move.l	buf_back,a0
;		move.w #10240,d0
;		move.w #10880,d1
;		move.w #8192,d2
;		move.w #1792,d3
;		bsr blit2d_line
;		move.l	buf_back,a0
;		move.w #10240,d0
;		move.w #16640,d1
;		move.w #8192,d2
;		move.w #7552,d3
;		bsr blit2d_line
				
		lea		transform_angles(PC),a2
		add.w	#3,(a2)+
		add.w	#8,(a2)+
		add.w	#4,(a2)+
 
		bsr		buffer_swap
        btst    #6,CIAAPRA              ; left mouse button?
        bne     mainloop
 
		jmp clean_exit
 
 clear_edge_buffers:
	lea line_buffer_y_dy(PC),a0
	moveq #1,d0
	swap d0
	REPT 12
	move.l d0,(a0)+
	ENDR
	rts	

 include "amigainit.s"
 include "amiblit2d.s"
 include "amidraw2d.s"
 include "math.s"
 
 num_vertices:
	dc.w	8
vertices:
	dc.w	-8192,-8192,-8192
	dc.w	8192,-8192,-8192
	dc.w	8192,8192,-8192
	dc.w	-8192,8192,-8192
	dc.w	-8192,-8192,8192
	dc.w	8192,-8192,8192
	dc.w	8192,8192,8192
	dc.w	-8192,8192,8192
vertices_transformed:
	ds.w	24
vertices_screen:
	dc.w	5472,1632,15072,1632,15072,11232,5472,11232
	dc.w	0,0,0,0,0,0,0,0	
transform_matrix:
	ds.w	9
transform_angles:
; 3 8 4
	;dc.w	300,800,400
	dc.w	00,00,00
num_edges:
	dc.w	12
edges:
	dc.w	3,2,1,0,1,10,5,9
	dc.w	5,6,7,4,7,11,3,8
	dc.w	11,6,10,2,8,0,9,4
;	dc.w	0,1,2,3,9,5,10,1
;	dc.w	4,7,6,5,8,3,11,7
;	dc.w	2,10,6,11,4,9,0,8
num_faces:
	dc.w	6
faces:
	dc.w	0,3,2,1,1,2,6,5
	dc.w	5,6,7,4,4,7,3,0
	dc.w	3,7,6,2,4,0,1,5
;	dc.w	0,1,2,3,1,5,6,2
;	dc.w	5,4,7,6,4,0,3,7
;	dc.w	3,2,6,7,4,5,1,0
face_colors:
	dc.b	1,2,3,4,5,6
line_buffer_increment_x:
	ds.l	24
line_buffer_y_dy:
	dc.w	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1		; -1 = not defined

	include "sinetable.s"
