    ; value to fill unused areas with
    fillvalue $ff

    include "../../nes-util/nes.asm"  ; see readme
    include "const.asm"

; --- iNES header ---------------------------------------------------------------------------------

    inesprg 1  ; PRG ROM size: 1 * 16 KiB
    ineschr 1  ; CHR ROM size: 1 * 8 KiB
    inesmir 1  ; name table mirroring: vertical
    inesmap 0  ; mapper: NROM

; --- PRG ROM -------------------------------------------------------------------------------------

    org $c000  ; last 16 KiB of CPU memory space
    include "init.asm"
    include "mainloop.asm"
    include "nmi.asm"
    pad $fffa
    dw nmi, reset, 0  ; interrupt vectors

; --- CHR ROM -------------------------------------------------------------------------------------

    pad $10000
    incbin "../chr-bg.bin"
    pad $12000

