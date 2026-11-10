atari_st_init:
	; Shrink the allocated memory, and reserve stack
	; On entry, 4(sp) holds the pointer to our program's Basepage
	move.l  4(a7),a5	; Save Basepage address in A5
	
	; 1. Calculate how much memory our program actually occupies
	move.l  $0c(a5),d0	; Text segment length
	add.l   $14(a5),d0	; + Data segment length
	add.l   $1c(a5),d0	; + BSS segment length
	add.l   #$100,d0	; + 256 bytes (Size of the Basepage itself)
	add.l   #2048,d0	; + 2048 bytes (Our custom safe stack size allocation)
	
	; 2. Correct the Stack Pointer to our new local stack array
	; (Remember, stack grows downwards, so point to the END of the array)
	move.l  a5,d1
	add.l   d0,d1		; Top of our allocated program chunk
	move.l  d1,a7		; Initialize our new safe Stack Pointer

	; 3. Return the remaining free RAM back to GEMDOS
	move.l  d0,-(a7)	; Push total size we want to keep
	move.l  a5,-(a7)	; Push base address of our block
	clr.w   -(a7)		; Junk/Reserved parameter
	move.w  #$4A,-(a7)	; GEMDOS Mshrink() opcode
	trap    #1			; Call GEMDOS
	lea     12(a7),a7	; Clean up stack
	
	; check resolution
	move.w	#4,-(a7)	; XBIOS function 4: Getrez
	trap	#14			; invoke XBIOS
	addq.l	#2,a7		; clean up stack (2 bytes)
	; resolution is in d0, 0=low, 1=med, 2=high
	move.w d0,current_rezolution
	cmp.w #2,d0
	bne atari_st_init_display_error
	
	; Print message
	pea 	message(PC)
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	
	; Wait for keypress
	bsr		atari_st_init_wait_keypress
	jmp		atari_st_init_clean_exit

atari_st_init_wait_keypress:
	move.w	#7,-(a7)		; Function 7: Crawcin (Raw Console Input)
	trap	#1				; Wait for any key...
	addq.l	#2,a7			; Clean up stack
	rts

atari_st_init_check_keypress_direct:
;	move.b	($0fff00),d0 ; trigger debugger
	moveq	#0,d0
	cmpi.b	#$39,$FFFC02
	seq		d0
	rts
	
atari_st_init_check_keypress:
	move.w	#1,-(a7)		; Device code: 1=keyboard
	move.w	#14,-(a7)		; XBIOS function 14: Iorec()
	trap	#14				; XBIOS
	addq.l	#4,a7
	move.l	d0,a0			; A0 = address of the IOREC structure
	move.w	8(a0),d0		; tail index
	sub.w	6(a0),d0		; subtract head index from tail index
	rts						; d0 = number of keys in buffer
	
atari_st_init_clear_keypress:
	move.w	#1,-(a7)		; Device code: 1=keyboard
	move.w	#14,-(a7)		; XBIOS function 14: Iorec()
	trap	#14				; XBIOS
	addq.l	#4,a7
	move.l	d0,a0			; A0 = address of the IOREC structure
	clr.w	6(a0)			; clear head index
	clr.w	8(a0)			; clear tail index
	rts						;	

atari_st_init_flip_buffer2:
	move.w	#37,-(a7)
	trap	#14
	addq.l	#2,a7
	move.l	scr_address,a0
	move.w	#0,-(a7)	; screen mode
	move.l	a0,-(a7)	; physical base
	move.l	#-1,-(a7)	; logical base
	move.w	#5,-(a7)	; 5=setscreeen
	trap	#14
	add.l	#12,a7
	move.l	scr_address_inc,d0
	add.l	d0,scr_address
	neg.l	scr_address_inc
	rts

atari_st_init_flip_buffer:
; wait vb
;	move.l	$466.w,d0
;	cmp.l	$466.w,d0
;	beq		atari_st_init_flip_buffer
	
	move.l	scr_address,d1
	lsr.l	#8,d1
	lea		$FF8201,a0
	movep.w	d1,0(a0)
	move.l	scr_address_inc,d0
	add.l	d0,scr_address
	neg.l	scr_address_inc

	move.w	#37,-(a7)
	trap	#14
	addq.l	#2,a7

	rts

message:
	dc.b	"Color display required! Press any key to exit.",13,10,0
	even
current_rezolution:
	dc.w	0
;current_logbase:
;	dc.l	0
current_physbase:
	dc.l	0
scr_address:
	dc.l	0
scr_address_inc:
	dc.l	32000
old_stack:
	dc.l	0
old_ier_a:
	dc.b	0
old_ier_b:
	dc.b	0
	
atari_st_init_display_error:
	move.w	#2,-(a7)
	trap	#14
	addq.l	#2,a7
	move.l	d0,current_physbase
	;move.w	#3,-(a7)
	;trap	#14
	;addq.l	#2,a7
	;move.l	d0,current_logbase
	;move.b	($0fff00),d0 ; trigger debugger
	lea scr_buffer(PC),a0
	move.l	a0,d0
	add.l	#255,d0
	clr.b	d0
	move.l	d0,scr_address

	move.l	d0,a0		; screen buffer
	move.w	#0,-(a7)	; screen mode
	move.l	a0,-(a7)	; physical base
	move.l	#-1,-(a7)	; logical base
	move.w	#5,-(a7)	; 5=setscreeen
	trap	#14
	add.l	#12,a7
	;add.l	scr_address_inc,d0
	;move.l	d0,scr_address
	;neg.l	scr_address_inc
	
	; disable all interrupts
	clr.l	-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,sp
	move.l	d0,old_stack
	
	move.b	$FFFA07,old_ier_a
	move.b	$FFFA09,old_ier_b
	;clr.b	$FFFA07
	;clr.b	$FFFA09
	
	jmp		atari_st_init_end

atari_st_init_restore_and_exit:			
	; restore resolution and screen base
	move.w	current_rezolution,d0
	move.w	d0,-(a7)
	move.l	current_physbase,a0
	move.l	a0,-(a7)
	;move.l	current_logbase,a0
	move.l	#-1,-(a7)
	move.w	#5,-(a7)
	trap	#14
	add.l	#12,a7

atari_st_init_clean_exit:	
	move.b	old_ier_a,$FFFA07
	move.b	old_ier_b,$FFFA09
	move.l	old_stack,-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	; Exit cleanly
	clr.w	-(a7)			; Shortcut for move.w #0,-(a7)
	;move.w	#$4c,-(a7)		; $4c is 76 in hex (Pterm)
	trap	#1
atari_st_init_end: