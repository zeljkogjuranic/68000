	section TEXT
	
start:
	include "ataristinit.s"
	
	move.l	scr_address,a0
	bsr		draw2d_clear_screen
loop_test1:
	;move.b	($0fff00),d0 ; trigger debugger
	;bsr		atari_st_init_flip_buffer
keypress_loop:
	bsr		clear_edge_buffers

;	move.b	($0fff00),d0 ; trigger debugger
	move.l	scr_address,a0
	bsr		draw2d_clear_screen
	bsr		math_transformation
	moveq.l	#0,d0
;	lea		vertices_screen(PC),a3
;	move.l	scr_address,a0
;	REPT 8
;	move.w	(a3)+,d0
;	move.w	(a3)+,d1
;	asr.w	#6,d0
;	asr.w	#6,d1
;	bsr		draw2d_point
;	ENDR
	bsr		draw2d_draw_face
	;bsr		clear_edge_buffers
	moveq.l	#1,d0
	bsr		draw2d_draw_face
	;bsr		clear_edge_buffers
	moveq.l	#2,d0
	bsr		draw2d_draw_face
	;bsr		clear_edge_buffers
	moveq.l	#3,d0
	bsr		draw2d_draw_face
	;bsr		clear_edge_buffers
	moveq.l	#4,d0
	bsr		draw2d_draw_face
	;bsr		clear_edge_buffers
	moveq.l	#5,d0
	bsr		draw2d_draw_face
	lea		transform_angles(PC),a2
	;add.w	#3,(a2)+
	;add.w	#8,(a2)+
	;add.w	#4,(a2)+

;	move.w	#$700,$FF8240	; red background
	bsr		atari_st_init_flip_buffer	
;	bsr		atari_st_init_check_keypress_direct
	bsr		atari_st_init_check_keypress
;	move.w	#$777,$FF8240	; black background
	cmp.w	#0,d0
	beq		keypress_loop
	bsr		atari_st_init_clear_keypress
	;bsr		atari_st_init_wait_keypress
	jmp		atari_st_init_restore_and_exit

	include "draw2d.s"
	include "math.s"

clear_edge_buffers:
	lea line_buffer_y_dy(PC),a0
	moveq #1,d0
	swap d0
	REPT 12
	move.l d0,(a0)+
	ENDR
	rts	

	section DATA
	
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
color_test_1
	dc.w	1
num_vertices
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
	dc.w	300,800,400
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
	;include "bitmasktable.s"
	include "sinetable.s"
	section BSS

scr_buffer:
	ds.w	32128
