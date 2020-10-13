; Color Squares - constants

; --- Addresses -----------------------------------------------------------------------------------

square_ppu_addr equ $00  ; 2 bytes; PPU address (low byte first)
frame_counter   equ $03  ; 0...255; LSB = square swap direction (0=right, 1=down)
square1_pos     equ $04  ; position of 1st square to swap ($00...$ef; bits: YYYYXXXX)
square2_pos     equ $05  ; position of 2nd square to swap ($00...$ef; bits: YYYYXXXX)
square_pos      equ $06  ; position of active square ($00...$ef; bits: YYYYXXXX)
nmi_done        equ $07  ; most significant bit = has the NMI routine run (0=no, 1=yes)
temp            equ $08
name_table_data equ $80  ; 14 * 4 = 56 bytes
attribute_data  equ $c0  ;  7 * 8 = 56 bytes

; --- Non-address constants -----------------------------------------------------------------------

; colors
;
; background
color_bg equ $0f  ; black
;
; foreground 0
color_fg0a equ $06 ;$16 red
color_fg0b equ $0a ;$18 yellow
color_fg0c equ $02 ;$1a green
;
; foreground 1
color_fg1a equ $16 ;$1c cyan
color_fg1b equ $1a ;$12 blue
color_fg1c equ $12 ;$14 purple
;
; foreground 2
color_fg2a equ $26 ;$26 light red
color_fg2b equ $2a ;$28 light yellow
color_fg2c equ $22 ;$2a light green
;
; foreground 3
color_fg3a equ $36 ;$2c light cyan
color_fg3b equ $3a ;$22 light blue
color_fg3c equ $32 ;$24 light purple

