  .inesprg 1
  .ineschr 1
  .inesmir 0
  .inesmap 0

  .bank 0
  .org $c000
Start:
  sei
  cld
  ldx #$ff
  txs

  lda #%10000000
  sta $2000

  lda #%00000111
  sta $4015

Wait:
  jmp Wait

VBlank:
  lda #$ff
  sta $4008
  lda #$c0
  sta $400a
  lda #$ff
  sta $400b

  rti

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
  .incbin "ai-reversi.chr"
