;=====================================================================
; dblbuf.s  -  Amiga 500 / Kickstart 1.3 (OCS)
; 320x256, 4 bitplanes (16 colours), double buffered
; - draws a horizontal line into the back buffer (moves down each frame)
; - flips buffers through the copper on vertical blank
; - left mouse button -> clean exit back to AmigaDOS
;
; Assemble (vasm):  vasmm68k_mot -Fhunkexe -kick1hunks -nosym -o dblbuf dblbuf.s
; (Devpac / AsmOne / AsmPro also work: plain Motorola syntax)
;=====================================================================
 
; ---- exec / graphics library vector offsets (LVOs)
_LVOForbid      equ     -132
_LVOPermit      equ     -138
_LVOAllocMem    equ     -198
_LVOFreeMem     equ     -210
_LVOOpenLibrary equ     -552
_LVOCloseLibrary equ    -414
_LVOLoadView    equ     -222
_LVOWaitTOF     equ     -270
 
gb_ActiView     equ     34
gb_copinit      equ     38
 
; ---- custom chip register offsets (from $DFF000)
DMACONR         equ     $002
VPOSR           equ     $004
COP1LC          equ     $080
COPJMP1         equ     $088
DMACON          equ     $096
INTENAR         equ     $01c
INTENA          equ     $09a
BLTCON0         equ     $040
BLTCON1         equ     $042
BLTAFWM         equ     $044
BLTALWM         equ     $046
BLTCPT			equ		$048
BLTBPT			equ		$04c
BLTAPT			equ		$050
BLTDPT          equ     $054
BLTSIZE         equ     $058
BLTCMOD			equ		$060
BLTBMOD			equ		$062
BLTAMOD			equ		$064
BLTDMOD         equ     $066
BLTBDAT			equ		$072
BLTADAT			equ		$074
 
CIAAPRA         equ     $bfe001         ; bit 6 = left mouse button (0 = pressed)
 
; ---- screen geometry
WIDTH_BYTES     equ     40              ; 320 / 8
HEIGHT          equ     256
PLANES          equ     4
PLANESZ         equ     WIDTH_BYTES*HEIGHT      ; 10240 bytes
BUFSZ           equ     PLANESZ*PLANES          ; 40960 bytes per buffer
ALLOCSZ         equ     BUFSZ*2+256             ; 2 buffers + copper list
