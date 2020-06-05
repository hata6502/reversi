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

  lda #$ff
  sta $4008
  lda #$80
  sta $400a
  lda #$ff
  sta $400b

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

Palette:
  .incbin "palette.dat"

Title:
  .incbin "title.nam"

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
