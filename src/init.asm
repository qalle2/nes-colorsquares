; Initialization

reset:
    initialize_nes

    clear_flag nmi_done
    copy_via_a #0, frame_counter

    ; copy name table data from ROM to RAM
    ldx #(14 * 4 - 1)
-   lda initial_name_table_data, x
    sta name_table_data, x
    dex
    bpl -

    wait_for_vblank_start

    ; copy palette to PPU
    ;
    set_ppu_address $3f00
    ;
    ldx #0
-   lda background_palette, x
    sta ppu_data
    inx
    cpx #16
    bne -

    jsr write_name_table
    jsr write_attribute_table

    reset_ppu_address_latch
    set_ppu_address $0000
    set_ppu_scroll 0, 240 - 8  ; center active area vertically

    wait_for_vblank_start

    ; enable NMI
    copy_via_a #%10000000, ppu_ctrl

    ; show background
    copy_via_a #%00001010, ppu_mask

    jmp main_loop

; --------------------------------------------------------------------------------------------------

initial_name_table_data:
    ; Each byte specifies the color of 4*1 squares.
    ; The value of each 2-bit group is 1-3, so each nybble is one of: 1235679abdef
    ; 14 * 4 = 56 bytes
    ; Python 3:
    ; " ".join(format(sum(random.randint(1,3) << s for s in (0,2,4,6)), "x") for i in range(56))
    ;
    hex 66 77 7b af
    hex ed 99 da e6
    hex 56 99 65 ae
    hex 6a e6 76 db
    hex a7 bd 9f d5
    hex fd df 6b a7
    hex eb 65 99 b6
    hex 59 f6 ff d9
    hex 7b e5 65 75
    hex 6e e7 a6 ef
    hex fb 5f 69 9e
    hex 55 65 bb 79
    hex 6b 9f 66 ea
    hex a6 6f bb 9e

background_palette:
    hex 0f 12 14 16  ; black, blue, purple, red
    hex 0f 18 1a 1c  ; black, yellow, green, teal
    hex 0f 22 24 26  ; like 1st subpalette but lighter foreground colors
    hex 0f 28 2a 2c  ; like 2nd subpalette but lighter foreground colors

; --------------------------------------------------------------------------------------------------

write_name_table:
    ; Write Name Table 0.
    ; 16*14 squares, square = 2*2 tiles.
    ; Each byte in name_table_data specifies the color of 4*1 squares.

    set_ppu_address $2000

    ldy #0  ; loop counter
name_table_loop:
    ; Write 8*1 tiles per round.

    ; Data byte -> X. Bits: X=0ABCDEFG, table index=00ABCDFG. (Each byte is used on two tile rows.)
    tya
    and #%01111000
    lsr
    sta temp
    tya
    and #%00000011
    ora temp
    tax
    lda name_table_data, x
    tax
    ; store loop counter
    tya
    pha
    ; write tiles
    jsr write_8_tiles
    ; restore loop counter
    pla
    tay
    ; end loop
    iny
    cpy #(28 * 4)
    bne name_table_loop

    ; pad with 0x00
    lda #$00
    ldx #(2 * 32)
-   sta ppu_data
    dex
    bne -

    rts

write_8_tiles:
    ; Write 8*1 tiles to Name Table.
    ; Y: loop counter (set of 8*1 tiles)
    ; X: data byte from name_table_data
    ; Scrambles A, X, Y.

    ; temp: OR mask (%00000000 if even row, %00001000 if odd)
    tya
    and #%00000100
    asl
    sta temp

    ldy #4
    txa
write_tiles_loop:
    ; Write two tiles per round.
    ; Bits of tile number: 0000VCCH (V = bottom/top half, CC = color, H = left/right half)
    and #%00000011
    asl
    ora temp
    sta ppu_data
    ora #$01
    sta ppu_data
    ; restore data byte, discard two LSBs, store again
    txa
    lsr
    lsr
    tax
    ; end loop
    dey
    bne write_tiles_loop

    rts

; --------------------------------------------------------------------------------------------------

write_attribute_table:
    ; Write Attribute Table 0.

    set_ppu_address $23c0

    ; copy data from table
    ldx #0
-   lda attribute_table_data, x
    sta ppu_data
    inx
    cpx #(7 * 8)
    bne -

    ; pad with 0x00
    lda #$00
    ldx #8
-   sta ppu_data
    dex
    bne -

    rts

attribute_table_data:
    ; 7 * 8 = 56 bytes
    hex bc 5b 18 91 b1 f3 17 79
    hex e9 0d 6e 73 2b 8d fb 64
    hex 88 36 97 47 38 78 4b bc
    hex c8 35 09 be 3a 21 93 ad
    hex 99 c7 37 d6 14 9b 18 88
    hex 14 1b 99 fb a7 5c f4 2a
    hex 78 17 b6 43 0f 6e 29 f8

