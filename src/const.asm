; Color Squares - constants

; Note: in flag variables, only the most significant bit is important.

frame_counter    equ $00  ; LSB = square swap direction (0=right, 1=down)
square_x         equ $01  ; 0-15
square_y         equ $02  ; 0-14
moving_square1_x equ $03
moving_square1_y equ $04
moving_square2_x equ $05
moving_square2_y equ $06  ; must be immediately after moving_square2_x
temp             equ $07
nmi_done         equ $08  ; flag: has the NMI routine run
name_table_data  equ $80  ; 14 * 4 = 56 bytes
attribute_data   equ $c0  ;  7 * 8 = 56 bytes

