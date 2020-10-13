; Color Squares - initialization

reset:
    initialize_nes

    clear_flag nmi_done
    copy_via_a #0, frame_counter

    ; copy name table & attribute table data from ROM to RAM
    ldx #(14 * 4 - 1)
-   lda initial_name_table_data, x
    sta name_table_data, x
    lda initial_attribute_data, x
    sta attribute_data, x
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

    ; write name table 0
    ; 16*14 squares, 1 square = 2*2 tiles, 1 byte in name_table_data = 4*1 squares
    ;
    set_ppu_address $2000
    ;
    ; which set of 8*1 tiles; bits: 0YYYYHXX (square Y, square top/bottom half, square X)
    ldy #0
    ;
    ; index to name_table_data -> X (bits: 00YYYYXX)
-   tya
    and #%01111000
    lsr
    sta temp
    tya
    and #%00000011
    ora temp
    tax
    ;
    ; data byte -> X
    lda name_table_data, x
    tax
    ;
    ; write 8*1 tiles
    tya
    pha
    jsr write_8_tiles  ; reads Y, X
    pla
    tay
    ;
    iny
    cpy #(28 * 4)
    bne -
    ;
    ; pad name table with zeroes
    lda #$00
    ldx #(2 * 32)
-   sta ppu_data
    dex
    bne -

    ; write attribute table 0
    ;
    set_ppu_address $23c0
    ;
    ; copy data from table
    ldx #0
-   lda attribute_data, x
    sta ppu_data
    inx
    cpx #(7 * 8)
    bne -
    ;
    ; pad with zeroes
    lda #$00
    ldx #8
-   sta ppu_data
    dex
    bne -

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

background_palette:
    db color_bg, color_fg0a, color_fg0b, color_fg0c
    db color_bg, color_fg1a, color_fg1b, color_fg1c
    db color_bg, color_fg2a, color_fg2b, color_fg2c
    db color_bg, color_fg3a, color_fg3b, color_fg3c

initial_name_table_data:
    ; 14*4 = 56 bytes, 1 byte = 4*1 squares, each 2-bit group = 1...3.
    ; Note: within a byte, the most significant bit pair represents the *rightmost* square.
    ; (That makes routines simpler.)
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

initial_attribute_data:
    ; 7*8 = 56 bytes, 1 byte = 2*2 squares.
    ; Python 3:
    ; " ".join(format(random.randrange(256), "02x") for i in range(56))
    ;
    hex bc 5b 18 91 b1 f3 17 79
    hex e9 0d 6e 73 2b 8d fb 64
    hex 88 36 97 47 38 78 4b bc
    hex c8 35 09 be 3a 21 93 ad
    hex 99 c7 37 d6 14 9b 18 88
    hex 14 1b 99 fb a7 5c f4 2a
    hex 78 17 b6 43 0f 6e 29 f8

write_8_tiles:
    ; Write 8*1 tiles to Name Table.
    ; Y: loop counter (set of 8*1 tiles)
    ; X: byte from name_table_data
    ; tile number: 0000VCCH (V = top/bottom half, CC = square color, H = left/right half)

    ; top/bottom half OR mask -> temp (0000V000)
    tya
    and #%00000100
    asl
    sta temp

    ; write 4*2 tiles (read least significant bit pair first!)
    ;
    ldy #4
    txa
    ;
-   and #%00000011
    asl
    ora temp
    sta ppu_data
    ora #%00000001
    sta ppu_data
    ;
    ; X >>= 2
    txa
    lsr
    lsr
    tax
    ;
    dey
    bne -

    rts

