  .inesprg 1
  .ineschr 1
  .inesmir 0
  .inesmap 0

bgBufferLength .equ $40

  .rsset $00
bgBufferIndex .rs $01
titleAddress .rs $02
titlePpuAddress .rs $02

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
  lda titlePpuAddress
  clc
  adc #$20
  sta titlePpuAddress
  lda titlePpuAddress + 1
  adc #$00
  sta titlePpuAddress + 1
  lda titleAddress
  clc
  adc #$20
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

  lda #%10000110
  sta $4000
  lda #%00000000
  sta $4001
  lda Notes + 69*2
  sta $4002
  lda Notes + 69*2 + 1
  ORA #%00001000
  sta $4003

Wait:
  jmp Wait

VBlank:
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
  rti

Palette:  .incbin "palette.dat"

Notes:  .dw 6821, 6429, 6079, 5766, 5430, 5131, 4821, 4584, 4302, 4052, 3830, 3631, 3410, 3232, 3039, 2882, 2714, 2565, 2421, 2282, 2150, 2033, 1921, 1809, 1710, 1616, 1523, 1437, 1357, 1279, 1210, 1141, 1077, 1016, 0958, 0906, 0854, 0806, 0761, 0718, 0678, 0640, 0604, 0570, 0538, 0508, 0479, 0452, 0427, 0403, 0380, 0358, 0338, 0319, 0301, 0284, 0268, 0253, 0239, 0226, 0213, 0201, 0189, 0179, 0169, 0159, 0150, 0142, 0134, 0126, 0119, 0112, 0106, 0100, 0094, 0089, 0084, 0079, 0075, 0070, 0066, 0063, 0059, 0056, 0052, 0049, 0047, 0044, 0041, 0039, 0037, 0035, 0033, 0031, 0029, 0027, 0026, 0024, 0023, 0021, 0020, 0019, 0018, 0017, 0016, 0015, 0014, 0013, 0012, 0012, 0011, 0010, 0010, 0009, 0008, 0008, 0007, 0007, 0006, 0006, 0006, 0005, 0005, 0005, 0004, 0004, 0004, 0003

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
