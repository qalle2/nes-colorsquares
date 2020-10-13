; Color Squares - main loop

main_loop:
    branch_if_flag_clear nmi_done, main_loop

    ; get coordinates of squares to swap
    ;
    ; 1st square
    ldx frame_counter
    lda shuffle_data, x
    sta square1_pos
    ;
    ; 2nd square (add 1 to square1_pos in X/Y direction, depending on swap direction)
    lda frame_counter
    lsr                ; LSB -> carry
    lda square1_pos
    bcs +
    add #1             ; right
    jmp ++
+   add #16            ; down
++  sta square2_pos

    inc frame_counter
    clear_flag nmi_done
    jmp main_loop

shuffle_data:
    ; 256 bytes
    ; upper nybble = Y position (0...d at even indexes, 0...c at odd indexes)
    ; lower nybble = X position (0...e at even indexes, 0...f at odd indexes)
    ; Python 3:
    ; " ".join(format(random.randrange(14 - i % 2) << 4 | random.randrange(15 + i % 2), "02x") for i in range(256))
    ;
    hex 43 47 70 16 12 92 0b 09 93 91 c7 51 37 56 68 c7
    hex 32 65 6e bc 24 70 22 0d 14 02 c5 5d 84 37 42 78
    hex 53 cb d2 0e d2 b8 ba 9b b9 b7 82 3a a6 66 61 27
    hex 71 46 cc c9 15 a1 87 6d 65 c4 cb 94 54 74 0d 2a
    hex 7a a1 dc 8a 4b 78 85 9a a5 ac 15 23 b9 56 82 13
    hex 6d 60 3c 2d ab 64 d3 8b 47 a8 15 0f 4c a6 28 3f
    hex 45 78 51 b7 96 3b 88 69 cd 4a 3e 87 ba 37 02 7c
    hex d6 a9 7b 44 a1 01 41 7e 41 ae a3 78 9e 06 61 34
    hex 54 be 32 9d 9b 43 37 2e 69 67 81 9d 90 23 dd b2
    hex 26 bd a8 5a c6 c1 00 a5 9c 6c 48 2b 27 49 37 13
    hex 09 4a b4 71 9c c2 48 60 b7 0a 03 4c 01 7f 44 5c
    hex 25 3b 24 95 10 71 05 c8 52 0e aa 7f 3a 51 44 26
    hex c9 cc 04 2d 4b 27 21 01 72 2f 8a c7 a2 3b 8d 92
    hex 9a 07 8b 7c 91 1e 7e b0 49 46 d1 cc 00 bb a5 a7
    hex c0 45 00 c0 cc 63 cc 3e 33 7e 05 c5 86 3d b8 25
    hex a3 36 ac 16 21 cc 53 b8 29 af 11 4a a8 0a 4d 58

