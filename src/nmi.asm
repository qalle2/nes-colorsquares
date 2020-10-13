; Color Squares - NMI routine

nmi:
    ; TODO: move stuff to main loop; wrapping?

    push_registers

    ; update name table
    ;
    ; read 1st & 2nd square
    copy_via_a square1_pos, square_pos
    jsr get_square_color
    pha
    copy_via_a square2_pos, square_pos
    jsr get_square_color
    pha
    ;
    ; write 1st & 2nd square
    copy_via_a square1_pos, square_pos
    pla
    jsr square_to_name_table
    copy_via_a square2_pos, square_pos
    pla
    jsr square_to_name_table

;    ; read & push tile number and attribute value
;    jsr set_name_table_address  ; square_x, square_y -> X, A
;    lda ppu_data                ; garbage read
;    lda ppu_data
;    pha
;    jsr get_square_attribute
;    pha

;    ; read & push tile number and attribute color (1-3)
;    jsr set_name_table_address  ; square_x, square_y -> X, A
;    lda ppu_data                ; garbage read
;    lda ppu_data
;    pha
;    jsr get_square_attribute
;    pha

;    ; write new values
;    pla
;    tay
;    jsr set_square_attribute        ; in: Y, square_x, square_y
;    pla
;    tay
;    jsr write_square_to_name_table  ; in: Y, square_x, square_y

;    ; write new values
;    pla
;    tay
;    jsr set_square_attribute        ; in: Y, square_x, square_y
;    pla
;    tay
;    jsr write_square_to_name_table  ; in: Y, square_x, square_y

    reset_ppu_address_latch
    set_ppu_address $0000
    set_ppu_scroll 0, 240 - 8  ; center active area vertically

    set_flag nmi_done
    pull_registers
    rti

; --------------------------------------------------------------------------------------------------

get_name_table_address:
    ; in: square_pos (bits: YYYYXXXX)
    ; out: square_ppu_addr (top left tile in name table 0): $2000 + YYYY*64 + XXXX*2
    ;      (bits: 001000YY YY0XXXX0)

    ; high byte
    lda square_pos  ; YYYYXXXX
    asl             ; YYYXXXX0
    rol             ; YYXXXX0Y
    rol             ; YXXXX0YY
    and #%00000011  ; 000000YY
    ora #%00100000  ; 001000YY
    sta square_ppu_addr + 1

    ; low byte
    lda square_pos         ; YYYYXXXX
    asl                    ; YYYXXXX0
    and #%00011110         ; 000XXXX0
    tax
    lda square_pos         ; YYYYXXXX
    asl                    ; YYYXXXX0
    asl                    ; YYXXXX00
    and #%11000000         ; YY000000
    ora identity_table, x  ; YY0XXXX0
    sta square_ppu_addr + 0

    rts

square_to_name_table:
    ; Write a square (2*2 tiles) to name table.
    ; in: square_pos (bits: YYYYXXXX), A (square color, 1-3)

    ; get index of top left tile (2/4/6), push it
    asl
    pha

    jsr get_name_table_address  ; square_pos -> square_ppu_addr
    reset_ppu_address_latch

    ; top left & right
    ;
    copy_via_a square_ppu_addr + 1, ppu_addr
    copy_via_a square_ppu_addr + 0, ppu_addr
    ;
    pla
    pha
    sta ppu_data
    ora #%00000001
    sta ppu_data

    ; bottom left & right
    ;
    copy_via_a square_ppu_addr + 1, ppu_addr
    lda square_ppu_addr + 0
    ora #$20
    sta ppu_addr
    ;
    pla
    ora #$08
    sta ppu_data
    ora #%00000001
    sta ppu_data

    rts

; --------------------------------------------------------------------------------------------------

get_square_color:
    ; Get color of specified square from name_table_data.
    ; in: square_pos (bits: YYYYXXXX)
    ; out: A (1-3)

    ; get shift count: Y = square_pos & 0x03
    ; (use Y because lda zp,x is needed for other purposes later; 6502 has no lda zp,y)
    lda square_pos
    and #%00000011
    tay

    ; get data byte: A = name_table_data[square_pos >> 2]
    lda square_pos
    lsr
    lsr
    tax
    lda name_table_data, x

    ; get color: A = (A >> (2 * Y)) & 0x03
    cpy #0
    beq +
-   lsr
    lsr
    dey
    bne -
+   and #%00000011

    rts

; --------------------------------------------------------------------------------------------------

get_square_attribute:
    ; Get attribute color of specified square.
    ; called by: nmi
    ; in: square_x, square_y
    ; out: A (1-3)
    ; scrambles: A, X

    ; get bit position of attribute block within byte
    ;lda square_x
    lsr
    ;lda square_y
    rol
    and #$03
    tax

    ; set PPU address
    ; bits: square_y: 0000ABCD, square_x: 0000abcd -> 00100011 11ABCabc
    ; high byte
    lda #$23
    sta ppu_addr
    ; low byte
    ;lda square_y
    and #$0e
    asl
    asl
    asl
    ;ora square_x
    lsr
    ora #$c0
    sta ppu_addr

    ; read byte
    lda ppu_data
    lda ppu_data

    ; shift important bits to LSBs
    cpx #0
    beq shift_done
-   lsr
    lsr
    dex
    bne -
shift_done:
    and #$03

    rts

set_square_attribute:
    ; Write attribute color to specified square.
    ; called by: nmi
    ; in: Y (0-3), square_x, square_y
    ; scrambles: A, X, Y

    ; get bit position of attribute block within byte
    ;lda square_x
    lsr
    ;lda square_y
    rol
    and #$03
    tax

    ; set PPU address, push for later use
    ; bits: square_y: 0000ABCD, square_x: 0000abcd -> 00100011 11ABCabc
    ; high byte
    lda #$23
    sta ppu_addr
    pha
    ; low byte
    ;lda square_y
    and #$0e
    asl
    asl
    asl
    ;ora square_x
    lsr
    ora #$c0
    sta ppu_addr
    pha

    ; read old byte
    lda ppu_data
    lda ppu_data

    ; clear bits to change
    and and_masks, x
    sta temp

    ; shift new bits to correct position, combine with old byte
    tya
    cpx #0
    beq shift_done2
-   asl
    asl
    dex
    bne -
shift_done2:

    ; combine old and new bits
    ora temp
    tax

    ; pull & set PPU address
    pull_y
    pla
    sta ppu_addr
    sty ppu_addr

    ; write new byte
    stx ppu_data

    rts

and_masks:
    ; AND bitmasks for attribute table data
    hex fc f3 cf 3f

