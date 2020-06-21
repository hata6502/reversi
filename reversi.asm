  .inesprg 1
  .ineschr 1
  .inesmir 0
  .inesmap 0

bgBufferLength .equ $40

  .rsset $00
bgBufferIndex   .rs $01
titleAddress    .rs $02
titlePpuAddress .rs $02
soundAddress    .rs $02
soundTimer      .rs $01

  .rsset $0300
bgBuffer .rs bgBufferLength

  .bank 0
  .org $c000
Start:
  sei
  cld
  ldx #$ff
  txs

  lda #$00
  tax
InitializeMemory:
  sta $00,x
  sta $200,x
  sta $300,x
  sta $400,x
  sta $500,x
  sta $600,x
  sta $700,x
  inx
  bne InitializeMemory

  lda #%10000000
  sta $2000
  lda #%00011000
  sta $2001

  lda #%00000111
  sta $4015

  ldx #$00
  lda #$3f
  sta bgBuffer,x
  inx
  lda #$00
  sta bgBuffer,x
  inx
  lda #$20
  sta bgBuffer,x
  inx
  ldy #$00
LoadPalette:
  lda Palette,y
  iny
  sta bgBuffer,x
  inx
  cpy #$20
  bne LoadPalette
  stx bgBufferIndex

  lda #$00
  sta titlePpuAddress
  lda #$20
  sta titlePpuAddress + 1
  lda #low(Title)
  sta titleAddress
  lda #high(Title)
  sta titleAddress + 1
LoadTitleWait:
  lda bgBufferIndex
  bne LoadTitleWait
  tax
  lda titlePpuAddress + 1
  sta bgBuffer,x
  inx
  lda titlePpuAddress
  sta bgBuffer,x
  inx
  lda #$20
  sta bgBuffer,x
  inx
  ldy #$00
LoadTitle:
  lda [titleAddress],y
  iny
  sta bgBuffer,x
  inx
  cpy #$20
  bne LoadTitle
  tya
  clc
  adc titlePpuAddress
  sta titlePpuAddress
  lda titlePpuAddress + 1
  adc #$00
  sta titlePpuAddress + 1
  tya
  clc
  adc titleAddress
  sta titleAddress
  lda titleAddress + 1
  adc #$00
  sta titleAddress + 1
  stx bgBufferIndex
  lda titleAddress
  cmp #low(Title + $0400)
  bne LoadTitleWait
  lda titleAddress + 1
  cmp #high(Title + $0400)
  bne LoadTitleWait

  lda PineappleRag
  sta soundTimer
  lda #low(PineappleRag + 1)
  sta soundAddress
  lda #high(PineappleRag + 1)
  sta soundAddress + 1

Wait:
  jmp Wait

VBlank:
  ; TODO: レジスタ退避
  ; TODO: 処理落ち中は BG バッファを処理しない。
  ldx #$00
WritePpu:
  cpx bgBufferIndex
  beq WritePpuBreak
  lda bgBuffer,x
  inx
  sta $2006
  lda bgBuffer,x
  inx
  sta $2006
  ldy bgBuffer,x
  inx
WritePpuData:
  cpy #$00
  beq WritePpuDataBreak
  lda bgBuffer,x
  inx
  sta $2007
  dey
  jmp WritePpuData
WritePpuDataBreak:
  jmp WritePpu
WritePpuBreak:
  lda #$00
  sta bgBufferIndex
  sta $2005
  sta $2005

PlaySound:
  lda soundTimer
  bne PlaySoundBreak
  ldy #$00
  lda [soundAddress],y
  iny
  asl a
  tax
  lda #%10000110
  sta $4000
  lda #%00000000
  sta $4001
  lda Notes,x
  sta $4002
  lda Notes + 1,x
  ora #%00001000
  sta $4003
  lda [soundAddress],y
  iny
  sta soundTimer
  tya
  clc
  adc soundAddress
  sta soundAddress
  lda soundAddress + 1
  adc #$00
  sta soundAddress + 1
  jmp PlaySound
PlaySoundBreak:
  dec soundTimer

  ; TODO: レジスタ復帰
  rti

Notes:
  .dw 6821, 6429, 6079, 5766, 5430, 5131, 4821, 4584, 4302, 4052, 3830, 3631, 3410, 3232, 3039, 2882
  .dw 2714, 2565, 2421, 2282, 2150, 2033, 1921, 1809, 1710, 1616, 1523, 1437, 1357, 1279, 1210, 1141
  .dw 1077, 1016, 0958, 0906, 0854, 0806, 0761, 0718, 0678, 0640, 0604, 0570, 0538, 0508, 0479, 0452
  .dw 0427, 0403, 0380, 0358, 0338, 0319, 0301, 0284, 0268, 0253, 0239, 0226, 0213, 0201, 0189, 0179
  .dw 0169, 0159, 0150, 0142, 0134, 0126, 0119, 0112, 0106, 0100, 0094, 0089, 0084, 0079, 0075, 0070
  .dw 0066, 0063, 0059, 0056, 0052, 0049, 0047, 0044, 0041, 0039, 0037, 0035, 0033, 0031, 0029, 0027
  .dw 0026, 0024, 0023, 0021, 0020, 0019, 0018, 0017, 0016, 0015, 0014, 0013, 0012, 0012, 0011, 0010
  .dw 0010, 0009, 0008, 0008, 0007, 0007, 0006, 0006, 0006, 0005, 0005, 0005, 0004, 0004, 0004, 0003

Palette:  .incbin "palette.dat"

PineappleRag:
  .db 0, 67
  .db 8, 67
  .db 1, 65
  .db 17, 65
  .db 2, 63
  .db 8, 63
  .db 1, 62
  .db 10, 62
  .db 0, 61
  .db 10, 61
  .db 0, 62
  .db 10, 62
  .db 0, 60
  .db 8, 60
  .db 1, 58
  .db 10, 58
  .db 0, 60
  .db 10, 60
  .db 0, 62
  .db 10, 62
  .db 0, 65
  .db 43, 65
  .db 5, 67
  .db 8, 67
  .db 1, 67
  .db 17, 67
  .db 2, 66
  .db 8, 66
  .db 1, 67
  .db 10, 67
  .db 0, 69
  .db 10, 69
  .db 0, 70
  .db 17, 70
  .db 2, 72
  .db 17, 72
  .db 2, 65
  .db 36, 65
  .db 2, 65
  .db 17, 65
  .db 2, 7
  .db 0, 79
  .db 0, 74
  .db 0, 70
  .db 8, 79
  .db 0, 74
  .db 0, 70
  .db 1, 77
  .db 17, 77
  .db 2, 75
  .db 8, 75
  .db 1, 74
  .db 10, 74
  .db 0, 73
  .db 10, 73
  .db 0, 74
  .db 10, 74
  .db 0, 72
  .db 8, 72
  .db 1, 70
  .db 10, 70
  .db 0, 72
  .db 10, 72
  .db 0, 74
  .db 10, 74
  .db 0, 77
  .db 18, 77
  .db 1, 82
  .db 8, 82
  .db 1, 77
  .db 0, 86
  .db 17, 77
  .db 0, 86
  .db 2, 70
  .db 0, 74
  .db 0, 79
  .db 8, 70
  .db 0, 74
  .db 0, 79
  .db 1, 77
  .db 17, 77
  .db 2, 75
  .db 8, 75
  .db 1, 74
  .db 10, 74
  .db 0, 73
  .db 10, 73
  .db 0, 74
  .db 10, 74
  .db 0, 75
  .db 8, 75
  .db 1, 7
  .db 0, 77
  .db 0, 74
  .db 0, 70
  .db 17, 77
  .db 0, 74
  .db 0, 70
  .db 0, 7
  .db 2, 7
  .db 0, 70
  .db 0, 77
  .db 10, 70
  .db 0, 77
  .db 0, 7
  .db 0, 74
  .db 8, 74
  .db 0, 7
  .db 1, 7
  .db 0, 70
  .db 0, 77
  .db 10, 70
  .db 0, 77
  .db 0, 7
  .db 0, 74
  .db 10, 74
  .db 0, 7
  .db 0, 77
  .db 0, 70
  .db 17, 77
  .db 0, 70
  .db 2, 7
  .db 0, 70
  .db 10, 70
  .db 0, 75
  .db 0, 82
  .db 17, 75
  .db 0, 82
  .db 2, 70
  .db 10, 70
  .db 0, 75
  .db 0, 82
  .db 17, 75
  .db 0, 82
  .db 2, 70
  .db 10, 70
  .db 0, 75
  .db 0, 82
  .db 18, 75
  .db 0, 82
  .db 1, 86
  .db 10, 86
  .db 0, 82
  .db 10, 82
  .db 0, 74
  .db 8, 74
  .db 1, 77
  .db 0, 70
  .db 10, 77
  .db 0, 76
  .db 10, 76
  .db 0, 77
  .db 10, 77
  .db 0, 79
  .db 5, 70
  .db 4, 79
  .db 1, 81
  .db 10, 81
  .db 0, 72
  .db 0, 77
  .db 17, 72
  .db 0, 77
  .db 2, 81
  .db 10, 81
  .db 0, 70
  .db 0, 76
  .db 0, 79
  .db 17, 70
  .db 0, 76
  .db 0, 79
  .db 2, 81
  .db 0, 76
  .db 0, 70
  .db 8, 81
  .db 0, 76
  .db 0, 70
  .db 1, 69
  .db 0, 77
  .db 26, 69
  .db 0, 77
  .db 2, 69
  .db 10, 69
  .db 0, 70
  .db 10, 70
  .db 0, 72
  .db 10, 72
  .db 0, 74
  .db 10, 74
  .db 0, 75
  .db 10, 75
  .db 0, 77
  .db 8, 77
  .db 1, 7
  .db 0, 79
  .db 0, 74
  .db 0, 70
  .db 8, 79
  .db 0, 74
  .db 0, 70
  .db 1, 77
  .db 17, 77
  .db 2, 75
  .db 8, 75
  .db 1, 74
  .db 10, 74
  .db 0, 73
  .db 10, 73
  .db 0, 74
  .db 10, 74
  .db 0, 72
  .db 8, 72
  .db 1, 70
  .db 10, 70
  .db 0, 72
  .db 10, 72
  .db 0, 74
  .db 10, 74
  .db 0, 77
  .db 18, 77
  .db 1, 82
  .db 8, 82
  .db 1, 86
  .db 0, 77
  .db 17, 86
  .db 0, 77
  .db 2, 70
  .db 0, 74
  .db 0, 79
  .db 8, 70
  .db 0, 74
  .db 0, 79
  .db 1, 77
  .db 17, 77
  .db 2, 75
  .db 8, 75
  .db 1, 74
  .db 10, 74
  .db 0, 73
  .db 10, 73
  .db 0, 74
  .db 10, 74
  .db 0, 75
  .db 8, 75
  .db 1, 70
  .db 0, 74
  .db 0, 77
  .db 17, 70
  .db 0, 74
  .db 0, 77
  .db 2, 77
  .db 0, 70
  .db 8, 77
  .db 0, 70
  .db 1, 74
  .db 8, 74
  .db 1, 70
  .db 0, 77
  .db 10, 70
  .db 0, 77
  .db 0, 74
  .db 10, 74
  .db 0, 70
  .db 0, 77
  .db 17, 70
  .db 0, 77
  .db 2, 7
  .db 0, 70
  .db 10, 70
  .db 0, 75
  .db 0, 82
  .db 17, 75
  .db 0, 82
  .db 2, 70
  .db 10, 70
  .db 0, 82
  .db 0, 75
  .db 17, 82
  .db 0, 75
  .db 2, 70
  .db 10, 70
  .db 0, 75
  .db 0, 82
  .db 18, 75
  .db 0, 82
  .db 1, 86

Title:  .incbin "title.nam"

  .bank 1
  .org $fffa
  ; VBlank 割り込み
  .dw VBlank
  ; リセット割り込み
  .dw Start
  ; IRQ 割り込み
  .dw Start

  .bank 2
  .org $0000
  .incbin "reversi.chr"
