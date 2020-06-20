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

ScaleA0:  .dw 2033
ScaleAS0: .dw 1919
ScaleB0:  .dw 1811
ScaleC1:  .dw 1709
ScaleCS1: .dw 1613
ScaleD1:  .dw 1523
ScaleDS1: .dw 1437
ScaleE1:  .dw 1357
ScaleF1:  .dw 1280
ScaleFS1: .dw 1208
ScaleG1:  .dw 1141
ScaleGS1: .dw 1077
ScaleA1:  .dw 1016
ScaleAS1: .dw 959
ScaleB1:  .dw 905
ScaleC2:  .dw 854
ScaleCS2: .dw 806
ScaleD2:  .dw 761
ScaleDS2: .dw 718
ScaleE2:  .dw 678
ScaleF2:  .dw 640
ScaleFS2: .dw 604
ScaleG2:  .dw 570
ScaleGS2: .dw 538
ScaleA2:  .dw 508
ScaleAS2: .dw 479
ScaleB2:  .dw 452
ScaleC3:  .dw 427
ScaleCS3: .dw 403
ScaleD3:  .dw 380
ScaleDS3: .dw 359
ScaleE3:  .dw 338
ScaleF3:  .dw 319
ScaleFS3: .dw 301
ScaleG3:  .dw 284
ScaleGS3: .dw 268
ScaleA3:  .dw 253
ScaleAS3: .dw 239
ScaleB3:  .dw 226
ScaleC4:  .dw 213
ScaleCS4: .dw 201
ScaleD4:  .dw 189
ScaleDS4: .dw 179
ScaleE4:  .dw 169
ScaleF:   .dw 159
ScaleFS4: .dw 150
ScaleG4:  .dw 142
ScaleGS4: .dw 134
ScaleA4:  .dw 126
ScaleAS4: .dw 119
ScaleB4:  .dw 112
ScaleC5:  .dw 106
ScaleCS5: .dw 100
ScaleD5:  .dw 94
ScaleDS5: .dw 89
ScaleE5:  .dw 84
ScaleF5:  .dw 79
ScaleFS5: .dw 75
ScaleG5:  .dw 70
ScaleGS5: .dw 66
ScaleA5:  .dw 63
ScaleAS5: .dw 59
ScaleB5:  .dw 56
ScaleC6:  .dw 52
ScaleCS6: .dw 49
ScaleD6:  .dw 47
ScaleDS6: .dw 44
ScaleE6:  .dw 41
ScaleF6:  .dw 39
ScaleFS6: .dw 37
ScaleG6:  .dw 35
ScaleGS6: .dw 33
ScaleA6:  .dw 31
ScaleAS6: .dw 29
ScaleB6:  .dw 27
ScaleC7:  .dw 26
ScaleCS7: .dw 24
ScaleD7:  .dw 23
ScaleDS7: .dw 21
ScaleE7:  .dw 20
ScaleF7:  .dw 19
ScaleFS7: .dw 18
ScaleG7:  .dw 17
ScaleGS7: .dw 16
ScaleA7:  .dw 15
ScaleAS7: .dw 14
ScaleB7:  .dw 13
ScaleC8:  .dw 12

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
