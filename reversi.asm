  .inesprg 1
  .ineschr 1
  .inesmir 0
  .inesmap 0

cellBlack         .equ $40
cellBlank         .equ $00
cellWhite         .equ $80
cellBlackToWhite  .equ cellWhite + 8*4
cellSetBlack      .equ cellBlack + 8
cellSetBlank      .equ cellBlank + 8
cellSetWhite      .equ cellWhite + 8
cellWhiteToBlack  .equ cellBlack + 8*4

controllerA       .equ $80
controllerB       .equ $40
controllerDown    .equ $04
controllerLeft    .equ $02
controllerRight   .equ $01
controllerSelect  .equ $20
controllerStart   .equ $10
controllerUp      .equ $08

enableBlack .equ %00000001
enableWhite .equ %00000010

gameModeBeginner      .equ 0
gameModeIntermediate  .equ 1
gameModeAdvanced      .equ 2
gameMode2Players      .equ 3

player1   .equ 0
player2   .equ 1
playerAI  .equ 2

resultDraw  .equ 0
resultLose  .equ 2
resultWin   .equ 1

  .rsset $00
aiControllerRisingEdge          .rs $01
aiEvaluationMax                 .rs $01
aiFrame                         .rs $01
aiPlayer1Cell                   .rs $01
aiScanSettablesEndIndex         .rs $01
aiSettablesIndex                .rs $01
aiTargetIndex                   .rs $01
bgBufferIndex                   .rs $01
blackArrangeCount               .rs $01
blackCount                      .rs $01
blackCursorX                    .rs $01
blackCursorY                    .rs $01
blackPass                       .rs $01
blackPlayer                     .rs $01
controller1                     .rs $01
controller1Prev                 .rs $01
controller1RisingEdge           .rs $01
controller2                     .rs $01
controller2Prev                 .rs $01
controller2RisingEdge           .rs $01
enablePlayer                    .rs $01
execPlayerCell                  .rs $01
execPlayerControllerRisingEdge  .rs $01
execPlayerCursorX               .rs $01
execPlayerCursorY               .rs $01
execPlayerPalette               .rs $01
execPlayerSetSE                 .rs $02
execPlayerSoundAddress          .rs $02
execPlayerSoundTimer            .rs $01
frameCount                      .rs $01
frameProceeded                  .rs $01
gameMode                        .rs $01
gameOver                        .rs $01
ppuAddress                      .rs $02
ppuControl1                     .rs $01
ppuControl2                     .rs $01
random                          .rs $02
round                           .rs $01
soundCh1Address                 .rs $02
soundCh1Timer                   .rs $01
soundCh2Address                 .rs $02
soundCh2Timer                   .rs $01
spriteIndex                     .rs $01
stoneX                          .rs $01
stoneY                          .rs $01
stoneChar                       .rs $01
titleAddress                    .rs $02
turnStonesCell                  .rs $01
turnStonesCount                 .rs $01
turnStonesDryRun                .rs $01
turnStonesEndIndex              .rs $01
turnStonesPrevIndex             .rs $01
turnStonesPrevIndexPartial      .rs $01
turnStonesStartIndex            .rs $01
turnStonesWriteAnimation        .rs $01
whiteArrangeCount               .rs $01
whiteCount                      .rs $01
whiteCursorX                    .rs $01
whiteCursorY                    .rs $01
whitePass                       .rs $01
whitePlayer                     .rs $01

  .rsset $0200
sprite  .rs $ff

  .rsset $0300
bgBuffer .rs $80
board    .rs 8*8

  .rsset $0400
aiSettables .rs 8*8
aiEvaluations .rs 8*8

  .bank 0
  .org $c000
Start:
  sei
  cld
  lda #$40
  sta $4017
  ldx #$ff
  txs
  lda #$00
  sta $2000
  sta $2001
  sta $4010

  bit $2002
initializeVBlank1Loop:
  bit $2002
  bpl initializeVBlank1Loop

  lda #$00
  tax
initializeMemoryLoop:
  sta $00,x
  sta $0100,x
  sta $0200,x
  sta $0300,x
  sta $0400,x
  sta $0500,x
  sta $0600,x
  sta $0700,x
  inx
  bne initializeMemoryLoop

  inc random

initializeVBlank2Loop:
  bit $2002
  bpl initializeVBlank2Loop

  lda #%10000000
  sta $2000
  sta ppuControl1
  lda #%00011000
  sta $2001
  sta ppuControl2

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
LoadPaletteLoop:
  lda Palette,y
  iny
  sta bgBuffer,x
  inx
  cpy #$20
  bne LoadPaletteLoop
  stx bgBufferIndex

LoadTitle:
  lda NoSound
  sta soundCh1Timer
  lda #low(NoSound + 1)
  sta soundCh1Address
  lda #high(NoSound + 1)
  sta soundCh1Address + 1
  lda NoSound
  sta soundCh2Timer
  lda #low(NoSound + 1)
  sta soundCh2Address
  lda #high(NoSound + 1)
  sta soundCh2Address + 1

  lda #$00
  sta ppuAddress
  lda #$20
  sta ppuAddress + 1
  lda #low(Title)
  sta titleAddress
  lda #high(Title)
  sta titleAddress + 1
LoadTitleLoop:
  jsr WaitFrameProceeded
  ldx #$00
  lda ppuAddress + 1
  sta bgBuffer,x
  inx
  lda ppuAddress
  sta bgBuffer,x
  inx
  lda #$20
  sta bgBuffer,x
  inx
  ldy #$00
LoadTitleWriteLoop:
  lda [titleAddress],y
  iny
  sta bgBuffer,x
  inx
  cpy #$20
  bne LoadTitleWriteLoop
  tya
  clc
  adc ppuAddress
  sta ppuAddress
  lda ppuAddress + 1
  adc #$00
  sta ppuAddress + 1
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
  bne LoadTitleLoop
  lda titleAddress + 1
  cmp #high(Title + $0400)
  bne LoadTitleLoop

  lda PineappleRagCh1
  sta soundCh1Timer
  lda #low(PineappleRagCh1 + 1)
  sta soundCh1Address
  lda #high(PineappleRagCh1 + 1)
  sta soundCh1Address + 1
  lda PineappleRagCh2
  sta soundCh2Timer
  lda #low(PineappleRagCh2 + 1)
  sta soundCh2Address
  lda #high(PineappleRagCh2 + 1)
  sta soundCh2Address + 1

  lda #%00011111
  sta $4015

TitleLoop:
  jsr WaitFrameProceeded
  jsr ReadController

  lda controller1RisingEdge
  and #controllerSelect
  beq SelectGameSkip
  inc gameMode
  lda gameMode
  and #$03
  sta gameMode
SelectGameSkip:

  ldx spriteIndex
  lda gameMode
  asl a
  asl a
  asl a
  asl a
  clc
  adc #$75
  sta sprite,x
  inx
  lda #$2a
  sta sprite,x
  inx
  lda #%00000010
  sta sprite,x
  inx
  lda #$44
  sta sprite,x
  inx
  stx spriteIndex

  jsr FinalizeSprite

  lda controller1RisingEdge
  and #controllerStart
  bne TitleBreak

  jmp TitleLoop
TitleBreak:

  lda #1
  sta round

  ldx #enableBlack
  lda controller1
  and #controllerA
  beq RealTimeModeSkip
  ldx #enableBlack + enableWhite
RealTimeModeSkip:
  stx enablePlayer

  lda gameMode
  asl a
  asl a
  asl a
  asl a
  asl a
  asl a
  tax
AIInitializeEvaluationsLoop:
  lda AIEvaluations,x
  sta aiEvaluations,x
  inx
  txa
  and #%00111111
  bne AIInitializeEvaluationsLoop

  lda StartSE
  sta soundCh1Timer
  lda #low(StartSE + 1)
  sta soundCh1Address
  lda #high(StartSE + 1)
  sta soundCh1Address + 1
  lda NoSound
  sta soundCh2Timer
  lda #low(NoSound + 1)
  sta soundCh2Address
  lda #high(NoSound + 1)
  sta soundCh2Address + 1
  ldx #90
  jsr Sleep

  jsr FinalizeSprite

ClearTitle:
  lda #$00
  sta ppuAddress
  lda #$20
  sta ppuAddress + 1
ClearTitleLoop:
  jsr WaitFrameProceeded
  ldx #$00
  lda ppuAddress + 1
  sta bgBuffer,x
  inx
  lda ppuAddress
  sta bgBuffer,x
  inx
  lda #$20
  sta bgBuffer,x
  inx
  lda #$00
ClearTitleWriteLoop:
  sta bgBuffer,x
  inx
  cpx #$20 + 3
  bne ClearTitleWriteLoop
  stx bgBufferIndex
  lda ppuAddress
  clc
  adc #$20
  sta ppuAddress
  lda ppuAddress + 1
  adc #$00
  sta ppuAddress + 1
  cmp #$24
  bne ClearTitleLoop

ContinueGame:
  jsr InitializeBoard

  jsr WaitFrameProceeded
  ldx #$00
  lda #$20
  sta bgBuffer,x
  inx
  lda #$41
  sta bgBuffer,x
  inx
  lda #25
  sta bgBuffer,x
  inx
  lda #$a9
  sta bgBuffer,x
  inx
  lda #$aa
LoadGameWriteTopBorderLoop:
  sta bgBuffer,x
  inx
  cpx #25 + 3
  bne LoadGameWriteTopBorderLoop
  lda #$23
  sta bgBuffer,x
  inx
  lda #$61
  sta bgBuffer,x
  inx
  lda #25
  sta bgBuffer,x
  inx
  lda #$ba
LoadGameWriteBottomBorderLoop:
  sta bgBuffer,x
  inx
  cpx #25 + 3 + 25 + 3
  bne LoadGameWriteBottomBorderLoop
  stx bgBufferIndex

  jsr WaitFrameProceeded
  ldx #$00
  lda #$20
  sta bgBuffer,x
  inx
  lda #$61
  sta bgBuffer,x
  inx
  lda #24 + %10000000
  sta bgBuffer,x
  inx
  lda #$b9
LoadGameWriteLeftBorderLoop:
  sta bgBuffer,x
  inx
  cpx #24 + 3
  bne LoadGameWriteLeftBorderLoop
  lda #$20
  sta bgBuffer,x
  inx
  lda #$5a
  sta bgBuffer,x
  inx
  lda #26 + %10000000
  sta bgBuffer,x
  inx
  lda #$ba
LoadGameWriteRightBorderLoop:
  sta bgBuffer,x
  inx
  cpx #24 + 3 + 26 + 3
  bne LoadGameWriteRightBorderLoop
  stx bgBufferIndex

  lda gameMode
  asl a
  tax
  jsr Random
  and #%10000000
  bne setPlayer
  lda Players,x
  sta blackPlayer
  lda Players + 1,x
  sta whitePlayer
  jmp setPlayerBreak
setPlayer:
  lda Players + 1,x
  sta blackPlayer
  lda Players,x
  sta whitePlayer
setPlayerBreak:

  jsr WaitFrameProceeded
  ldx bgBufferIndex
WriteInitialStatusLoop:
  lda StatusBgStart,x
  sta bgBuffer,x
  inx
  cpx #StatusBgEnd - StatusBgStart
  bne WriteInitialStatusLoop
  lda gameMode
  asl a
  asl a
  tay
  lda #$20
  sta bgBuffer,x
  inx
  lda #$9c
  sta bgBuffer,x
  inx
  lda #2 + %10000000
  sta bgBuffer,x
  inx
  lda gameModeChars,y
  iny
  sta bgBuffer,x
  inx
  lda gameModeChars,y
  iny
  sta bgBuffer,x
  inx
  lda #$20
  sta bgBuffer,x
  inx
  lda #$9d
  sta bgBuffer,x
  inx
  lda #2 + %10000000
  sta bgBuffer,x
  inx
  lda gameModeChars,y
  iny
  sta bgBuffer,x
  inx
  lda gameModeChars,y
  iny
  sta bgBuffer,x
  inx
  lda gameMode
  cmp #gameMode2Players
  beq WriteRoundSkip
  lda #$20
  sta bgBuffer,x
  inx
  lda #$fc
  sta bgBuffer,x
  inx
  lda #$02
  sta bgBuffer,x
  inx
  lda round
  jsr WriteDecimal
  lda #$20
  sta bgBuffer,x
  inx
  lda #$de
  sta bgBuffer,x
  inx
  lda #2 + %10000000
  sta bgBuffer,x
  inx
  lda #$85
  sta bgBuffer,x
  inx
  lda #$95
  sta bgBuffer,x
  inx
WriteRoundSkip:
  lda blackPlayer
  asl a
  asl a
  tay
  lda #$21
  sta bgBuffer,x
  inx
  lda #$dc
  sta bgBuffer,x
  inx
  lda #1
  sta bgBuffer,x
  inx
  lda PlayerChars,y
  iny
  sta bgBuffer,x
  inx
  lda #$21
  sta bgBuffer,x
  inx
  lda #$fc
  sta bgBuffer,x
  inx
  lda #3
  sta bgBuffer,x
  inx
  lda PlayerChars,y
  iny
  sta bgBuffer,x
  inx
  lda PlayerChars,y
  iny
  sta bgBuffer,x
  inx
  lda PlayerChars,y
  iny
  sta bgBuffer,x
  inx
  lda whitePlayer
  asl a
  asl a
  tay
  lda #$22
  sta bgBuffer,x
  inx
  lda #$dc
  sta bgBuffer,x
  inx
  lda #1
  sta bgBuffer,x
  inx
  lda PlayerChars,y
  iny
  sta bgBuffer,x
  inx
  lda #$22
  sta bgBuffer,x
  inx
  lda #$fc
  sta bgBuffer,x
  inx
  lda #3
  sta bgBuffer,x
  inx
  lda PlayerChars,y
  iny
  sta bgBuffer,x
  inx
  lda PlayerChars,y
  iny
  sta bgBuffer,x
  inx
  lda PlayerChars,y
  iny
  sta bgBuffer,x
  inx
  stx bgBufferIndex

  lda #cellSetBlack
  sta board + 4 + 3*8
  jsr WriteBoard
  lda SetBlackSE
  sta soundCh1Timer
  lda #low(SetBlackSE + 1)
  sta soundCh1Address
  lda #high(SetBlackSE + 1)
  sta soundCh1Address + 1
  ldx #30
  jsr Sleep
  lda #cellSetBlack
  sta board + 3 + 4*8
  jsr WriteBoard
  lda SetBlackSE
  sta soundCh1Timer
  lda #low(SetBlackSE + 1)
  sta soundCh1Address
  lda #high(SetBlackSE + 1)
  sta soundCh1Address + 1
  ldx #30
  jsr Sleep
  lda #cellSetWhite
  sta board + 3 + 3*8
  jsr WriteBoard
  lda SetWhiteSE
  sta soundCh2Timer
  lda #low(SetWhiteSE + 1)
  sta soundCh2Address
  lda #high(SetWhiteSE + 1)
  sta soundCh2Address + 1
  ldx #30
  jsr Sleep
  lda #cellSetWhite
  sta board + 4 + 4*8
  jsr WriteBoard
  lda SetWhiteSE
  sta soundCh2Timer
  lda #low(SetWhiteSE + 1)
  sta soundCh2Address
  lda #high(SetWhiteSE + 1)
  sta soundCh2Address + 1
  ldx #30
  jsr Sleep

  lda #3
  sta blackCursorX
  sta blackCursorY
  lda #4
  sta whiteCursorX
  sta whiteCursorY
  jsr AIInitialize
  jsr UpdateStatus

GameLoop:
  jsr WaitFrameProceeded
  jsr ReadController

  lda frameCount
  and #%00000001
  bne ExecFrameRule
  jsr ExecBlack
  jsr ExecWhite
  jmp ExecFrameRuleBreak
ExecFrameRule:
  jsr ExecWhite
  jsr ExecBlack
ExecFrameRuleBreak:

  jsr WriteBoard
  jsr FinalizeSprite

  lda blackPass
  beq GameEndSkip
  lda whitePass
  bne GameEnd
GameEndSkip:
  jmp GameLoop

GameEnd:
  ldx #0
GameEndWaitLoop:
  txa
  pha
  jsr WaitFrameProceeded
  jsr WriteBoard
  jsr FinalizeSprite
  pla
  tax
  inx
  cpx #180
  bne GameEndWaitLoop

  lda #cellBlack
  sta aiPlayer1Cell
  lda whitePlayer
  cmp #player1
  bne AISetPlayer1CellWhiteSkip
  lda #cellWhite
  sta aiPlayer1Cell
AISetPlayer1CellWhiteSkip:

  ldx #0
AIUpdateEvaluationsLoop:
  lda board,x
  and #%11000000
  cmp aiPlayer1Cell
  bne AIUpdateEvaluationSkip
  inc aiEvaluations,x
AIUpdateEvaluationSkip:
  inx
  cpx #8*8
  bne AIUpdateEvaluationsLoop

  lda blackCount
  cmp whiteCount
  bmi AddEmptyCellsToWhite
  lda #64
  sec
  sbc whiteCount
  sta blackCount
  jmp AddEmptyCellsBreak
AddEmptyCellsToWhite:
  lda #64
  sec
  sbc blackCount
  sta whiteCount
AddEmptyCellsBreak:

  lda #$00
  sta blackPass
  sta whitePass
  jsr WriteStatus
  jsr InitializeBoard

  lda #63
  sta blackArrangeCount
  lda #0
  sta whiteArrangeCount
ArrangeStonesLoop:
  ldy #$00
  lda #63
  sec
  sbc blackCount
  cmp blackArrangeCount
  beq ArrangeBlackSkip
  ldx blackArrangeCount
  lda #cellSetBlack
  sta board,x
  dec blackArrangeCount
  lda ArrangeBlackStoneSE
  sta soundCh1Timer
  lda #low(ArrangeBlackStoneSE + 1)
  sta soundCh1Address
  lda #high(ArrangeBlackStoneSE + 1)
  sta soundCh1Address + 1
  iny
ArrangeBlackSkip:
  lda whiteArrangeCount
  cmp whiteCount
  beq ArrangeWhiteSkip
  tax
  lda #cellSetWhite
  sta board,x
  inc whiteArrangeCount
  lda ArrangeWhiteStoneSE
  sta soundCh2Timer
  lda #low(ArrangeWhiteStoneSE + 1)
  sta soundCh2Address
  lda #high(ArrangeWhiteStoneSE + 1)
  sta soundCh2Address + 1
  iny
ArrangeWhiteSkip:
  cpy #$00
  beq ArrangeStonesSkip
  jsr WriteBoard
  ldx #5
  jsr Sleep
  jmp ArrangeStonesLoop
ArrangeStonesSkip:
  jsr WriteBoard
  ldx #60
  jsr Sleep

  ldx #$00
  stx gameOver
  ldy #resultDraw
  lda Pathetique2
  sta soundCh1Timer
  lda #low(Pathetique2 + 1)
  sta soundCh1Address
  lda #high(Pathetique2 + 1)
  sta soundCh1Address + 1
  lda blackCount
  cmp whiteCount
  beq SetResultSoundAISkip
  inc gameOver
  inc round
  ldy #resultWin
  lda gameMode
  cmp #gameMode2Players
  beq SetResultSoundAISkip
  dec gameOver
  lda LynghamCh1
  sta soundCh1Timer
  lda #low(LynghamCh1 + 1)
  sta soundCh1Address
  lda #high(LynghamCh1 + 1)
  sta soundCh1Address + 1
  lda LynghamCh2
  sta soundCh2Timer
  lda #low(LynghamCh2 + 1)
  sta soundCh2Address
  lda #high(LynghamCh2 + 1)
  sta soundCh2Address + 1
  ldx #$00
  lda blackPlayer
  cmp #player1
  bne SetResultSoundLose1Skip
  inx
SetResultSoundLose1Skip:
  lda blackCount
  cmp whiteCount
  bpl SetResultSoundLose2Skip
  inx
SetResultSoundLose2Skip:
  txa
  and #%00000001
  bne SetResultSoundAISkip
  inc gameOver
  ldy #resultLose
  lda Pathetique3Ch1
  sta soundCh1Timer
  lda #low(Pathetique3Ch1 + 1)
  sta soundCh1Address
  lda #high(Pathetique3Ch1 + 1)
  sta soundCh1Address + 1
  lda Pathetique3Ch2
  sta soundCh2Timer
  lda #low(Pathetique3Ch2 + 1)
  sta soundCh2Address
  lda #high(Pathetique3Ch2 + 1)
  sta soundCh2Address + 1
SetResultSoundAISkip:
  cpy #resultDraw
  bne WriteResultDrawSkip
  ldx bgBufferIndex
WriteResultDrawLoop:
  lda ResultDrawStart,x
  sta bgBuffer,x
  inx
  cpx #ResultDrawEnd - ResultDrawStart
  bne WriteResultDrawLoop
  stx bgBufferIndex
  jmp WriteResultBreak
WriteResultDrawSkip:
  cpy #resultWin
  bne WriteResultWinSkip
  ldx bgBufferIndex
WriteResultWinLoop:
  lda ResultWinStart,x
  sta bgBuffer,x
  inx
  cpx #ResultWinEnd - ResultWinStart
  bne WriteResultWinLoop
  ldy #4
  lda blackCount
  cmp whiteCount
  bmi WriteResultWinBlackSkip
  ldy #2
WriteResultWinBlackSkip:
  jmp WriteResultInject
WriteResultWinSkip:
  ldx bgBufferIndex
WriteResultLoseLoop:
  lda ResultLoseStart,x
  sta bgBuffer,x
  inx
  cpx #ResultLoseEnd - ResultLoseStart
  bne WriteResultLoseLoop
  ldy #4
  lda blackCount
  cmp whiteCount
  bpl WriteResultLoseBlackSkip
  ldy #2
WriteResultLoseBlackSkip:
WriteResultInject:
  lda #$21
  sta bgBuffer,x
  inx
  lda #$ca
  sta bgBuffer,x
  inx
  lda #$02 + %10000000
  sta bgBuffer,x
  inx
  lda TurnChars,y
  iny
  sta bgBuffer,x
  inx
  lda TurnChars,y
  iny
  sta bgBuffer,x
  inx
  lda #$21
  sta bgBuffer,x
  inx
  lda #$ec
  sta bgBuffer,x
  inx
  lda #$02
  sta bgBuffer,x
  inx
  lda blackCount
  sec
  sbc whiteCount
  jsr Abs
  jsr WriteDecimal
  stx bgBufferIndex
  jmp WriteResultBreak
WriteResultBreak:

ResultWaitLoop:
  jsr WaitFrameProceeded
  jsr ReadController
  lda controller1RisingEdge
  and #controllerStart
  beq ResultWaitLoop
  lda NoSound
  sta soundCh1Timer
  sta soundCh2Timer
  lda #low(NoSound + 1)
  sta soundCh1Address
  sta soundCh2Address
  lda #high(NoSound + 1)
  sta soundCh1Address + 1
  sta soundCh2Address + 1
  lda gameOver
  bne gameContinueSkip
  jmp ContinueGame
gameContinueSkip:
  jmp LoadTitle

Abs:
  cmp #$00
  bpl AbsInvertSkip
  eor #$ff
  clc
  adc #$01
AbsInvertSkip:
  rts

Decimal:
  ldy #0
DecimalLoop:
  cmp #10
  bmi DecimalBreak
  sec
  sbc #10
  iny
  jmp DecimalLoop
DecimalBreak:
  rts

ExecBlack:
  lda enablePlayer
  and #enableBlack
  beq ExecBlackSkip

  lda #cellSetBlack
  sta execPlayerCell
  lda #low(SetBlackSE)
  sta execPlayerSetSE
  lda #high(SetBlackSE)
  sta execPlayerSetSE + 1
  lda #$03
  sta execPlayerPalette
  lda blackCursorX
  sta execPlayerCursorX
  lda blackCursorY
  sta execPlayerCursorY
  lda soundCh1Timer
  sta execPlayerSoundTimer
  lda soundCh1Address
  sta execPlayerSoundAddress
  lda soundCh1Address + 1
  sta execPlayerSoundAddress + 1

  lda blackPlayer
  jsr PlayerController
  sta execPlayerControllerRisingEdge
  jsr ExecPlayer

  lda execPlayerCursorX
  sta blackCursorX
  lda execPlayerCursorY
  sta blackCursorY
  lda execPlayerSoundTimer
  sta soundCh1Timer
  lda execPlayerSoundAddress
  sta soundCh1Address
  lda execPlayerSoundAddress + 1
  sta soundCh1Address + 1

ExecBlackSkip:
  rts

ExecPlayer:
  lda execPlayerControllerRisingEdge
  and #controllerLeft
  beq MoveCursorLeftSkip
  dec execPlayerCursorX
MoveCursorLeftSkip:
  lda execPlayerControllerRisingEdge
  and #controllerRight
  beq MoveCursorRightSkip
  inc execPlayerCursorX
MoveCursorRightSkip:
  lda execPlayerCursorX
  and #7
  sta execPlayerCursorX
  lda execPlayerControllerRisingEdge
  and #controllerUp
  beq MoveCursorUpSkip
  dec execPlayerCursorY
MoveCursorUpSkip:
  lda execPlayerControllerRisingEdge
  and #controllerDown
  beq MoveCursorDownSkip
  inc execPlayerCursorY
MoveCursorDownSkip:
  lda execPlayerCursorY
  and #7
  sta execPlayerCursorY

  lda execPlayerCursorY
  asl a
  asl a
  asl a
  clc
  adc execPlayerCursorX
  tax
  lda execPlayerControllerRisingEdge
  and #controllerA
  beq SetStoneSkip
  lda board,x
  cmp #cellBlank
  bne SetStoneError
  lda execPlayerCell
  and #%11000000
  sta turnStonesCell
  lda #$00
  sta turnStonesDryRun
  txa
  pha
  jsr TurnStones
  pla
  tax
  lda turnStonesCount
  beq SetStoneError
  lda execPlayerCell
  sta board,x
  jsr TurnPlayer
  jsr UpdateStatus
  ldy #$00
  lda [execPlayerSetSE],y
  sta execPlayerSoundTimer
  lda execPlayerSetSE
  clc
  adc #$01
  sta execPlayerSoundAddress
  lda execPlayerSetSE + 1
  adc #$00
  sta execPlayerSoundAddress + 1
  jmp SetStoneSkip
SetStoneError:
  lda ErrorSE
  sta execPlayerSoundTimer
  lda #low(ErrorSE + 1)
  sta execPlayerSoundAddress
  lda #high(ErrorSE + 1)
  sta execPlayerSoundAddress + 1
SetStoneSkip:

  lda execPlayerCursorX
  asl a
  asl a
  asl a
  sta stoneX
  asl a
  clc
  adc stoneX
  sta stoneX
  lda execPlayerCursorY
  asl a
  asl a
  asl a
  sta stoneY
  asl a
  clc
  adc stoneY
  sta stoneY
  ldx spriteIndex
  lda stoneY
  clc
  adc #23
  sta sprite,x
  inx
  lda #$c9
  sta sprite,x
  inx
  lda execPlayerPalette
  sta sprite,x
  inx
  lda stoneX
  clc
  adc #16
  sta sprite,x
  inx
  lda stoneY
  clc
  adc #23
  sta sprite,x
  inx
  lda #$c9
  sta sprite,x
  inx
  lda execPlayerPalette
  ora #%01000000
  sta sprite,x
  inx
  lda stoneX
  clc
  adc #31
  sta sprite,x
  inx
  lda stoneY
  clc
  adc #38
  sta sprite,x
  inx
  lda #$c9
  sta sprite,x
  inx
  lda execPlayerPalette
  ora #%10000000
  sta sprite,x
  inx
  lda stoneX
  clc
  adc #16
  sta sprite,x
  inx
  lda stoneY
  clc
  adc #38
  sta sprite,x
  inx
  lda #$c9
  sta sprite,x
  inx
  lda execPlayerPalette
  ora #%11000000
  sta sprite,x
  inx
  lda stoneX
  clc
  adc #31
  sta sprite,x
  inx
  stx spriteIndex
  rts

ExecWhite:
  lda enablePlayer
  and #enableWhite
  beq ExecWhiteSkip

  lda #cellSetWhite
  sta execPlayerCell
  lda #low(SetWhiteSE)
  sta execPlayerSetSE
  lda #high(SetWhiteSE)
  sta execPlayerSetSE + 1
  lda #$00
  sta execPlayerPalette
  lda whiteCursorX
  sta execPlayerCursorX
  lda whiteCursorY
  sta execPlayerCursorY
  lda soundCh2Timer
  sta execPlayerSoundTimer
  lda soundCh2Address
  sta execPlayerSoundAddress
  lda soundCh2Address + 1
  sta execPlayerSoundAddress + 1

  lda whitePlayer
  jsr PlayerController
  sta execPlayerControllerRisingEdge
  jsr ExecPlayer

  lda execPlayerCursorX
  sta whiteCursorX
  lda execPlayerCursorY
  sta whiteCursorY
  lda execPlayerSoundTimer
  sta soundCh2Timer
  lda execPlayerSoundAddress
  sta soundCh2Address
  lda execPlayerSoundAddress + 1
  sta soundCh2Address + 1

ExecWhiteSkip:
  rts

FinalizeSprite:
  ldx spriteIndex
  lda #$f8
FinalizeSpriteLoop:
  cpx #$00
  beq FinalizeSpriteBreak
  sta sprite,x
  inx
  inx
  inx
  inx
  jmp FinalizeSpriteLoop
FinalizeSpriteBreak:
  stx spriteIndex
  rts

InitializeBoard:
  ldx #0
  lda #cellSetBlank
InitializeBoardLoop:
  sta board,x
  inx
  cpx #8*8
  bne InitializeBoardLoop
  jsr WriteBoard
  rts

PlayerController:
  cmp #player1
  bne Player1ControllerSkip
  lda controller1RisingEdge
  rts
Player1ControllerSkip:
  cmp #player2
  bne Player2ControllerSkip
  lda controller2RisingEdge
  rts
Player2ControllerSkip:
  cmp #playerAI
  bne AIControllerSkip
  jsr AIExecFrame
  lda aiControllerRisingEdge
  rts
AIControllerSkip:
  brk

Random:
  lda random + 1
  pha
  lda random
  asl a
  rol random + 1
  asl a
  rol random + 1
  asl a
  rol random + 1
  asl a
  rol random + 1
  asl a
  rol random + 1
  asl a
  rol random + 1
  asl a
  rol random + 1
  eor random
  sta random
  pla
  eor random + 1
  sta random + 1
  lsr a
  eor random
  sta random
  eor random + 1
  sta random + 1
  rts

ReadController:
  lda #$01
  sta $4016
  lsr a
  sta $4016
  lda controller1
  sta controller1Prev
  lda $4016
  lsr a
  rol controller1
  lda $4016
  lsr a
  rol controller1
  lda $4016
  lsr a
  rol controller1
  lda $4016
  lsr a
  rol controller1
  lda $4016
  lsr a
  rol controller1
  lda $4016
  lsr a
  rol controller1
  lda $4016
  lsr a
  rol controller1
  lda $4016
  lsr a
  rol controller1
  lda controller1Prev
  eor #$ff
  and controller1
  sta controller1RisingEdge
  lda controller2
  sta controller2Prev
  lda $4017
  lsr a
  rol controller2
  lda $4017
  lsr a
  rol controller2
  lda $4017
  lsr a
  rol controller2
  lda $4017
  lsr a
  rol controller2
  lda $4017
  lsr a
  rol controller2
  lda $4017
  lsr a
  rol controller2
  lda $4017
  lsr a
  rol controller2
  lda $4017
  lsr a
  rol controller2
  lda controller2Prev
  eor #$ff
  and controller2
  sta controller2RisingEdge
  rts

Sleep:
  jsr WaitFrameProceeded
  dex
  bne Sleep
  rts

WriteBoard:
  ldx #0
WriteBoardLoop:
  lda board,x
  and #%00111111
  beq WriteBoardSkip
  and #%00000111
  bne WriteBoardWriteSkip
  lda board,x
  lsr a
  lsr a
  lsr a
  tay
  lda StoneChars,y
  sta stoneChar
  txa
  and #7
  sta stoneX
  txa
  pha
  lsr a
  lsr a
  lsr a
  sta stoneY
  jsr WriteStone
  pla
  tax
WriteBoardWriteSkip:
  dec board,x
WriteBoardSkip:
  inx
  cpx #8*8
  bne WriteBoardLoop
  rts

TurnPlayer:
  lda enablePlayer
  cmp #enableBlack + enableWhite
  beq TurnPlayerSkip
  eor #enableBlack + enableWhite
  sta enablePlayer
TurnPlayerSkip:
  rts

TurnStones:
  stx turnStonesStartIndex
  ldy #0
  sty turnStonesCount
TurnStonesDirectionLoop:
  ldx turnStonesStartIndex
TurnStonesCheckLoop:
  stx turnStonesPrevIndex
  txa
  clc
  adc TurnStonesDirection,y
  tax

  lda turnStonesPrevIndex
  and #%00000111
  sta turnStonesPrevIndexPartial
  txa
  and #%00000111
  sec
  sbc turnStonesPrevIndexPartial
  jsr Abs
  cmp #%00000111
  beq TurnStonesCheckSkip
  lda turnStonesPrevIndex
  and #%00111000
  sta turnStonesPrevIndexPartial
  txa
  and #%00111000
  sec
  sbc turnStonesPrevIndexPartial
  jsr Abs
  cmp #%00111000
  beq TurnStonesCheckSkip

  lda board,x
  and #%11000000
  cmp #cellBlank
  beq TurnStonesCheckSkip

  lda board,x
  and #%11000000
  cmp turnStonesCell
  bne TurnStonesCellSkip
  lda #cellWhiteToBlack - cellBlack + 1
  sta turnStonesWriteAnimation
  stx turnStonesEndIndex
  ldx turnStonesStartIndex
TurnStonesWriteLoop:
  txa
  clc
  adc TurnStonesDirection,y
  tax
  cpx turnStonesEndIndex
  beq TurnStonesCheckSkip
  lda turnStonesDryRun
  bne TurnStonesWriteSkip
  lda turnStonesCell
  clc
  adc turnStonesWriteAnimation
  sta board,x
TurnStonesWriteSkip:
  inc turnStonesCount
  inc turnStonesWriteAnimation
  jmp TurnStonesWriteLoop
TurnStonesCellSkip:

  jmp TurnStonesCheckLoop
TurnStonesCheckSkip:
  iny
  cpy #8
  beq TurnStonesDirectionBreak
  jmp TurnStonesDirectionLoop
TurnStonesDirectionBreak:
  rts

WaitFrameProceeded:
  lda #$01
  sta frameProceeded
WaitFrameProceededLoop:
  lda frameProceeded
  bne WaitFrameProceededLoop
  rts

UpdateStatus:
  lda #0
  sta blackCount
  sta whiteCount
  lda #$01
  sta blackPass
  sta whitePass
  sta turnStonesDryRun
  ldx #0
UpdateStatusBoardLoop:
  lda board,x
  and #%11000000
  cmp #cellBlank
  bne UpdateStatusBlankSkip
  lda blackPass
  beq UpdateStatusBlackPassSkip
  lda #cellBlack
  sta turnStonesCell
  txa
  pha
  jsr TurnStones
  pla
  tax
  lda turnStonesCount
  beq UpdateStatusBlackPassSkip
  lda #$00
  sta blackPass
UpdateStatusBlackPassSkip:
  lda whitePass
  beq UpdateStatusWhitePassSkip
  lda #cellWhite
  sta turnStonesCell
  txa
  pha
  jsr TurnStones
  pla
  tax
  lda turnStonesCount
  beq UpdateStatusWhitePassSkip
  lda #$00
  sta whitePass
UpdateStatusWhitePassSkip:
  jmp UpdateStatusCellBreak
UpdateStatusBlankSkip:

  cmp #cellBlack
  bne UpdateStatusBlackSkip
  inc blackCount
  jmp UpdateStatusCellBreak
UpdateStatusBlackSkip:

  cmp #cellWhite
  bne UpdateStatusWhiteSkip
  inc whiteCount
  jmp UpdateStatusCellBreak
UpdateStatusWhiteSkip:
UpdateStatusCellBreak:

  inx
  cpx #8*8
  bne UpdateStatusBoardLoop

  lda blackPass
  beq passBlackSkip
  lda enablePlayer
  and #enableBlack
  beq passBlackSkip
  jsr TurnPlayer
  lda SkipSE
  sta soundCh1Timer
  lda #low(SkipSE + 1)
  sta soundCh1Address
  lda #high(SkipSE + 1)
  sta soundCh1Address + 1
passBlackSkip:

  lda whitePass
  beq passWhiteSkip
  lda enablePlayer
  and #enableWhite
  beq passWhiteSkip
  jsr TurnPlayer
  lda SkipSE
  sta soundCh2Timer
  lda #low(SkipSE + 1)
  sta soundCh2Address
  lda #high(SkipSE + 1)
  sta soundCh2Address + 1
passWhiteSkip:

  jsr WriteStatus
  rts

WriteDecimal:
  jsr Decimal
  pha
  tya
  clc
  adc #'0'
  sta bgBuffer,x
  inx
  pla
  clc
  adc #'0'
  sta bgBuffer,x
  inx
  rts

WriteStatus:
  ldx bgBufferIndex

  lda enablePlayer
  asl a
  tay
  lda #$21
  sta bgBuffer,x
  inx
  lda #$1c
  sta bgBuffer,x
  inx
  lda #2 + %10000000
  sta bgBuffer,x
  inx
  lda TurnChars,y
  iny
  sta bgBuffer,x
  inx
  lda TurnChars,y
  iny
  sta bgBuffer,x
  inx

  lda blackPass
  asl a
  asl a
  tay
  lda #$21
  sta bgBuffer,x
  inx
  lda #$9d
  sta bgBuffer,x
  inx
  lda #2 + %10000000
  sta bgBuffer,x
  inx
  lda PassChars,y
  iny
  sta bgBuffer,x
  inx
  lda PassChars,y
  iny
  sta bgBuffer,x
  inx
  lda #$21
  sta bgBuffer,x
  inx
  lda #$9e
  sta bgBuffer,x
  inx
  lda #2 + %10000000
  sta bgBuffer,x
  inx
  lda PassChars,y
  iny
  sta bgBuffer,x
  inx
  lda PassChars,y
  iny
  sta bgBuffer,x
  inx
  lda whitePass
  asl a
  asl a
  tay
  lda #$22
  sta bgBuffer,x
  inx
  lda #$9d
  sta bgBuffer,x
  inx
  lda #2 + %10000000
  sta bgBuffer,x
  inx
  lda PassChars,y
  iny
  sta bgBuffer,x
  inx
  lda PassChars,y
  iny
  sta bgBuffer,x
  inx
  lda #$22
  sta bgBuffer,x
  inx
  lda #$9e
  sta bgBuffer,x
  inx
  lda #2 + %10000000
  sta bgBuffer,x
  inx
  lda PassChars,y
  iny
  sta bgBuffer,x
  inx
  lda PassChars,y
  iny
  sta bgBuffer,x
  inx
  lda #$22
  sta bgBuffer,x
  inx
  lda #$3c
  sta bgBuffer,x
  inx
  lda #$02
  sta bgBuffer,x
  inx
  lda blackCount
  jsr WriteDecimal
  lda #$23
  sta bgBuffer,x
  inx
  lda #$3c
  sta bgBuffer,x
  inx
  lda #$02
  sta bgBuffer,x
  inx
  lda whiteCount
  jsr WriteDecimal

  stx bgBufferIndex
  rts

WriteStone:
  lda stoneX
  asl a
  clc
  adc stoneX
  clc
  adc #$62
  sta ppuAddress
  lda #$20
  sta ppuAddress + 1
  ldy stoneY
WriteStoneSetYLoop:
  cpy #$00
  beq WriteStoneSetYBreak
  lda ppuAddress
  clc
  adc #$60
  sta ppuAddress
  lda ppuAddress + 1
  adc #$00
  sta ppuAddress + 1
  dey
  jmp WriteStoneSetYLoop
WriteStoneSetYBreak:
  ldx bgBufferIndex
  cpx #$40
  bmi WriteStoneWaitSkip
  jsr WaitFrameProceeded
  ldx bgBufferIndex
WriteStoneWaitSkip:
  ldy #$00
WriteStoneLoop:
  lda ppuAddress + 1
  sta bgBuffer,x
  inx
  tya
  clc
  adc ppuAddress
  sta bgBuffer,x
  inx
  lda #3 + %10000000
  sta bgBuffer,x
  inx
  tya
  clc
  adc stoneChar
  sta bgBuffer,x
  inx
  clc
  adc #$10
  sta bgBuffer,x
  inx
  clc
  adc #$10
  sta bgBuffer,x
  inx
  iny
  cpy #3
  bne WriteStoneLoop
  stx bgBufferIndex
  rts

AIExecFrame:
  lda aiFrame
  bne AIExecFrame0Skip
  jsr Random
  jsr Abs
  cmp #$03
  bpl AIWait
  ldx #0*8
  stx aiSettablesIndex
  jsr AIScanSettables
  inc aiFrame
AIWait:
  lda #$00
  sta aiControllerRisingEdge
  jmp AIExecFrameBreak
AIExecFrame0Skip:

  cmp #1
  bne AIExecFrame1Skip
  ldx #1*8
  jsr AIScanSettables
  inc aiFrame
  jmp AIExecFrameBreak
AIExecFrame1Skip:

  cmp #2
  bne AIExecFrame2Skip
  ldx #2*8
  jsr AIScanSettables
  inc aiFrame
  jmp AIExecFrameBreak
AIExecFrame2Skip:

  cmp #3
  bne AIExecFrame3Skip
  ldx #3*8
  jsr AIScanSettables
  inc aiFrame
  jmp AIExecFrameBreak
AIExecFrame3Skip:

  cmp #4
  bne AIExecFrame4Skip
  ldx #4*8
  jsr AIScanSettables
  inc aiFrame
  jmp AIExecFrameBreak
AIExecFrame4Skip:

  cmp #5
  bne AIExecFrame5Skip
  ldx #5*8
  jsr AIScanSettables
  inc aiFrame
  jmp AIExecFrameBreak
AIExecFrame5Skip:

  cmp #6
  bne AIExecFrame6Skip
  ldx #6*8
  jsr AIScanSettables
  inc aiFrame
  jmp AIExecFrameBreak
AIExecFrame6Skip:

  cmp #7
  bne AIExecFrame7Skip
  ldx #7*8
  jsr AIScanSettables
  inc aiFrame
  jmp AIExecFrameBreak
AIExecFrame7Skip:

  cmp #8
  bne AIExecFrame8Skip
  lda aiSettablesIndex
  bne AIPassSkip
  jsr AIInitialize
  jmp AIExecFrameBreak
AIPassSkip:
  ldx #0
  stx aiEvaluationMax
AIDetermineTargetLoop:
  ldy aiSettables,x
  lda aiEvaluations,y
  cmp aiEvaluationMax
  bcc AIDetermineTargetUpdateSkip
  lda aiEvaluations,y
  sta aiEvaluationMax
  sty aiTargetIndex
AIDetermineTargetUpdateSkip:
  inx
  cpx aiSettablesIndex
  bne AIDetermineTargetLoop
  inc aiFrame
  jmp AIExecFrameBreak
AIExecFrame8Skip:

  cmp #9
  bne AIExecFrame9Skip
  lda aiTargetIndex
  and #%00000111
  cmp execPlayerCursorX
  bne AIMoveXEndSkip
  lda #$00
  sta aiControllerRisingEdge
  inc aiFrame
  jmp AIMoveXCancelSkip
AIMoveXEndSkip:
  bmi AIMoveLeft
  lda #controllerRight
  jmp AIMoveXBreak
AIMoveLeft:
  lda #controllerLeft
AIMoveXBreak:
  sta aiControllerRisingEdge
  lda frameCount
  and #%00000111
  beq AIMoveXCancelSkip
  lda #$00
  sta aiControllerRisingEdge
AIMoveXCancelSkip:
  jmp AIExecFrameBreak
AIExecFrame9Skip:

  cmp #10
  bne AIExecFrame10Skip
  lda aiTargetIndex
  lsr a
  lsr a
  lsr a
  cmp execPlayerCursorY
  bne AIMoveYEndSkip
  lda #controllerA
  sta aiControllerRisingEdge
  jsr AIInitialize
  jmp AIMoveYCancelSkip
AIMoveYEndSkip:
  bmi AIMoveUp
  lda #controllerDown
  jmp AIMoveYBreak
AIMoveUp:
  lda #controllerUp
AIMoveYBreak:
  sta aiControllerRisingEdge
  lda frameCount
  and #%00000111
  beq AIMoveYCancelSkip
  lda #$00
  sta aiControllerRisingEdge
AIMoveYCancelSkip:
  jmp AIExecFrameBreak
AIExecFrame10Skip:

AIExecFrameBreak:
  rts

AIInitialize:
  lda #0
  sta aiFrame
  rts

AIScanSettables:
  txa
  clc
  adc #8
  sta aiScanSettablesEndIndex
  lda #$01
  sta turnStonesDryRun
AIscanSettablesLoop:
  lda board,x
  and #%11000000
  cmp #cellBlank
  bne AIscanSettablesBlankSkip
  lda execPlayerCell
  and #%11000000
  sta turnStonesCell
  txa
  pha
  jsr TurnStones
  pla
  tax
  lda turnStonesCount
  beq AIscanSettablesBlankSkip
  ldy aiSettablesIndex
  txa
  sta aiSettables,y
  inc aiSettablesIndex
AIscanSettablesBlankSkip:
  inx
  cpx aiScanSettablesEndIndex
  bne AIscanSettablesLoop
  rts

VBlank:
  pha
  txa
  pha
  tya
  pha

  lda frameProceeded
  bne VBlankFrameProcess
  jmp VBlankFrameProcessSkip
VBlankFrameProcess:
  lda #high(sprite)
  sta $4014

  ldx #$00
WritePPULoop:
  cpx bgBufferIndex
  beq WritePPUBreak
  lda bgBuffer,x
  inx
  sta $2006
  lda bgBuffer,x
  inx
  sta $2006
  lda bgBuffer,x
  bpl WritePPUHorizontal
  lda ppuControl1
  ora #%00000100
  jmp WritePPUDirection
WritePPUHorizontal:
  lda ppuControl1
  and #%11111011
WritePPUDirection:
  sta $2000
  sta ppuControl1
  lda bgBuffer,x
  and #%01111111
  tay
  inx
WritePPUDataLoop:
  cpy #$00
  beq WritePPUDataBreak
  lda bgBuffer,x
  inx
  sta $2007
  dey
  jmp WritePPUDataLoop
WritePPUDataBreak:
  jmp WritePPULoop
WritePPUBreak:
  lda #$00
  sta bgBufferIndex
  sta $2005
  sta $2005

  lda #$04
  sta spriteIndex
  inc frameCount
VBlankFrameProcessSkip:

PlaySoundCh1Loop:
  lda soundCh1Timer
  bne PlaySoundCh1Break
  ldy #$00
  lda [soundCh1Address],y
  iny
  asl a
  beq PlaySoundCh1Break
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
  lda [soundCh1Address],y
  iny
  sta soundCh1Timer
  tya
  clc
  adc soundCh1Address
  sta soundCh1Address
  lda soundCh1Address + 1
  adc #$00
  sta soundCh1Address + 1
  jmp PlaySoundCh1Loop
PlaySoundCh1Break:
  dec soundCh1Timer

PlaySoundCh2Loop:
  lda soundCh2Timer
  bne PlaySoundCh2Break
  ldy #$00
  lda [soundCh2Address],y
  iny
  asl a
  beq PlaySoundCh2Break
  tax
  lda #%10000110
  sta $4004
  lda #%00000000
  sta $4005
  lda Notes,x
  sta $4006
  lda Notes + 1,x
  ora #%00001000
  sta $4007
  lda [soundCh2Address],y
  iny
  sta soundCh2Timer
  tya
  clc
  adc soundCh2Address
  sta soundCh2Address
  lda soundCh2Address + 1
  adc #$00
  sta soundCh2Address + 1
  jmp PlaySoundCh2Loop
PlaySoundCh2Break:
  dec soundCh2Timer

  jsr Random
  lda controller1
  bne VBlankRandom1Skip
  jsr Random
VBlankRandom1Skip:
  lda controller2
  bne VBlankRandom2Skip
  jsr Random
VBlankRandom2Skip:

  lda #$00
  sta frameProceeded
  pla
  tay
  pla
  tax
  pla
  rti

Players:
  .db player1, playerAI
  .db player1, playerAI
  .db player1, playerAI
  .db player1, player2
TurnStonesDirection:
  .db $01, $09, $08, $07, $ff, $f7, $f8, $f9

AIEvaluations:
  .db 008, 044, 057, 034, 024, 042, 000, 040
  .db 047, 061, 050, 021, 058, 047, 045, 024
  .db 055, 045, 010, 027, 009, 036, 047, 014
  .db 047, 059, 022, 040, 012, 046, 006, 034
  .db 029, 057, 057, 030, 063, 004, 005, 049
  .db 011, 034, 037, 054, 062, 008, 032, 042
  .db 037, 037, 037, 016, 011, 044, 059, 002
  .db 031, 036, 058, 003, 032, 042, 016, 017

  .db 064, 008, 024, 018, 018, 024, 008, 064
  .db 008, 000, 014, 014, 014, 014, 000, 008
  .db 024, 014, 022, 017, 017, 022, 014, 024
  .db 018, 014, 017, 017, 017, 017, 014, 018
  .db 018, 014, 017, 017, 017, 017, 014, 018
  .db 024, 014, 022, 017, 017, 022, 014, 024
  .db 008, 000, 014, 014, 014, 014, 000, 008
  .db 064, 008, 024, 018, 018, 024, 008, 064

  .db 045, 003, 015, 014, 014, 015, 003, 045
  .db 003, 000, 012, 012, 012, 012, 000, 003
  .db 015, 012, 015, 014, 014, 015, 012, 015
  .db 014, 012, 014, 014, 014, 014, 012, 014
  .db 014, 012, 014, 014, 014, 014, 012, 014
  .db 015, 012, 015, 014, 014, 015, 012, 015
  .db 003, 000, 012, 012, 012, 012, 000, 003
  .db 045, 003, 015, 014, 014, 015, 003, 045

gameModeChars:
  .db $80, $90, $83, $93
  .db $81, $91, $83, $93
  .db $82, $92, $83, $93
  .db $00, '2', $86, $96
Palette:  .incbin "palette.dat"
PassChars:
  .db $00, $00, $00, $00
  .db $1f, $18, $00, $19
PlayerChars:
  .db $87
  .db $97, $00, $00
  .db $88
  .db $98, $00, $00
  .db $00
  .db 'C', 'O', 'M'
ResultDrawStart:
  .db $21, $a9, 10, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
  .db $21, $c9, 10, $00, $00, $00, $61, $00, $62, $00, $00, $00, $00
  .db $21, $e9, 10, $00, $00, $00, $71, $1c, $72, $1b, $00, $00, $00
  .db $22, $09, 10, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
ResultDrawEnd:
ResultLoseStart:
  .db $21, $a9, 10, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
  .db $21, $c9, 10, $00, $00, $00, $00, $00, $8c, $8d, $8f, $00, $00
  .db $21, $e9, 10, $00, $00, $17, $00, $00, $9c, $9d, $9f, $1b, $00
  .db $22, $09, 10, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
ResultLoseEnd:
ResultWinStart:
  .db $21, $a9, 10, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
  .db $21, $c9, 10, $00, $00, $00, $00, $00, $8c, $8d, $8e, $00, $00
  .db $21, $e9, 10, $00, $00, $17, $00, $00, $9c, $9d, $9e, $1a, $00
  .db $22, $09, 10, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
ResultWinEnd:
StatusBgStart:
  .db $21, $1d, 2 + %10000000, $8b, $9b
  .db $21, $9c, 2 + %10000000, $89, $99
  .db $22, $1e, 2 + %10000000, $8c, $9c
  .db $22, $9c, 2 + %10000000, $8a, $9a
  .db $23, $1e, 2 + %10000000, $8c, $9c
StatusBgEnd:
StoneChars:
  .db $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0
  .db $a3, $a3, $d3, $dc, $d6, $a6, $a6, $a6
  .db $a6, $a6, $d9, $dc, $d0, $a3, $a3, $a3
Title:  .incbin "title.nam"
TurnChars
  .db $00, $00
  .db $89, $99
  .db $8a, $9a
  .db $00, '?'

Notes:
  .dw 6821, 6429, 6079, 5766, 5430, 5131, 4821, 4584, 4302, 4052, 3830, 3631, 3410, 3232, 3039, 2882
  .dw 2714, 2565, 2421, 2282, 2150, 2033, 1921, 1809, 1710, 1616, 1523, 1437, 1357, 1279, 1210, 1141
  .dw 1077, 1016, 0958, 0906, 0854, 0806, 0761, 0718, 0678, 0640, 0604, 0570, 0538, 0508, 0479, 0452
  .dw 0427, 0403, 0380, 0358, 0338, 0319, 0301, 0284, 0268, 0253, 0239, 0226, 0213, 0201, 0189, 0179
  .dw 0169, 0159, 0150, 0142, 0134, 0126, 0119, 0112, 0106, 0100, 0094, 0089, 0084, 0079, 0075, 0070
  .dw 0066, 0063, 0059, 0056, 0052, 0049, 0047, 0044, 0041, 0039, 0037, 0035, 0033, 0031, 0029, 0027
  .dw 0026, 0024, 0023, 0021, 0020, 0019, 0018, 0017, 0016, 0015, 0014, 0013, 0012, 0012, 0011, 0010
  .dw 0010, 0009, 0008, 0008, 0007, 0007, 0006, 0006, 0006, 0005, 0005, 0005, 0004, 0004, 0004, 0003
NoSound:
  .db 0, 0
LynghamCh1:
  .db 0, 65
  .db 38, 69
  .db 29, 70
  .db 10, 72
  .db 9, 74
  .db 10, 72
  .db 10, 70
  .db 9, 69
  .db 19, 70
  .db 20, 69
  .db 19, 65
  .db 19, 67
  .db 19, 64
  .db 19, 65
  .db 0, 0
LynghamCh2:
  .db 0, 57
  .db 38, 60
  .db 29, 58
  .db 10, 57
  .db 9, 58
  .db 10, 57
  .db 10, 55
  .db 28, 53
  .db 20, 53
  .db 19, 57
  .db 19, 58
  .db 19, 55
  .db 19, 57
  .db 0, 0
Pathetique2:
  .db 0, 60
  .db 27, 51
  .db 26, 56
  .db 27, 51
  .db 27, 58
  .db 26, 51
  .db 27, 55
  .db 27, 51
  .db 26, 63
  .db 27, 51
  .db 27, 56
  .db 26, 51
  .db 27, 58
  .db 27, 51
  .db 26, 61
  .db 27, 51
  .db 27, 60
  .db 26, 51
  .db 27, 63
  .db 27, 51
  .db 26, 68
  .db 27, 56
  .db 27, 70
  .db 26, 56
  .db 27, 63
  .db 27, 58
  .db 26, 55
  .db 27, 58
  .db 27, 55
  .db 26, 58
  .db 27, 64
  .db 27, 58
  .db 26, 65
  .db 27, 58
  .db 27, 55
  .db 26, 58
  .db 27, 58
  .db 27, 51
  .db 26, 55
  .db 27, 60
  .db 13, 61
  .db 14, 63
  .db 26, 51
  .db 27, 56
  .db 27, 51
  .db 26, 57
  .db 27, 48
  .db 27, 51
  .db 26, 48
  .db 27, 61
  .db 27, 49
  .db 26, 53
  .db 27, 49
  .db 27, 60
  .db 26, 58
  .db 27, 56
  .db 27, 55
  .db 26, 58
  .db 27, 51
  .db 27, 49
  .db 26, 51
  .db 27, 56
  .db 0, 0
Pathetique3Ch1:
  .db 0, 67
  .db 9, 72
  .db 9, 74
  .db 9, 75
  .db 26, 77
  .db 9, 74
  .db 27, 75
  .db 9, 72
  .db 35, 72
  .db 9, 71
  .db 9, 72
  .db 9, 74
  .db 9, 75
  .db 9, 74
  .db 9, 75
  .db 9, 77
  .db 8, 79
  .db 18, 79
  .db 18, 79
  .db 53, 77
  .db 9, 79
  .db 9, 80
  .db 36, 74
  .db 17, 75
  .db 9, 77
  .db 9, 79
  .db 36, 72
  .db 18, 72
  .db 8, 74
  .db 9, 75
  .db 18, 75
  .db 9, 77
  .db 9, 74
  .db 18, 74
  .db 9, 75
  .db 8, 72
  .db 0, 0
Pathetique3Ch2:
  .db 27, 48
  .db 9, 51
  .db 8, 55
  .db 9, 60
  .db 9, 48
  .db 9, 53
  .db 9, 55
  .db 9, 59
  .db 9, 48
  .db 9, 51
  .db 9, 55
  .db 8, 60
  .db 9, 63
  .db 9, 67
  .db 9, 63
  .db 9, 62
  .db 9, 60
  .db 9, 67
  .db 9, 60
  .db 9, 67
  .db 8, 62
  .db 9, 67
  .db 9, 56
  .db 9, 67
  .db 9, 55
  .db 9, 59
  .db 9, 62
  .db 9, 67
  .db 9, 55
  .db 8, 59
  .db 9, 62
  .db 9, 67
  .db 9, 53
  .db 9, 56
  .db 9, 59
  .db 9, 62
  .db 9, 53
  .db 9, 56
  .db 8, 59
  .db 9, 62
  .db 9, 51
  .db 9, 55
  .db 9, 60
  .db 9, 63
  .db 9, 56
  .db 9, 60
  .db 9, 63
  .db 8, 66
  .db 9, 55
  .db 9, 60
  .db 9, 63
  .db 9, 67
  .db 9, 55
  .db 9, 59
  .db 9, 62
  .db 9, 67
  .db 17, 48
  .db 9, 51
  .db 9, 55
  .db 9, 60
  .db 0, 0
PineappleRagCh1:
  .db 0, 67
  .db 10, 65
  .db 19, 63
  .db 9, 62
  .db 10, 61
  .db 10, 62
  .db 9, 60
  .db 10, 58
  .db 9, 60
  .db 10, 62
  .db 10, 65
  .db 48, 67
  .db 9, 67
  .db 19, 66
  .db 10, 67
  .db 10, 69
  .db 9, 70
  .db 19, 72
  .db 20, 65
  .db 38, 65
  .db 19, 70
  .db 10, 77
  .db 19, 75
  .db 10, 74
  .db 9, 73
  .db 10, 74
  .db 9, 72
  .db 10, 70
  .db 10, 72
  .db 9, 74
  .db 10, 77
  .db 19, 82
  .db 10, 86
  .db 19, 79
  .db 9, 77
  .db 20, 75
  .db 9, 74
  .db 10, 73
  .db 9, 74
  .db 10, 75
  .db 10, 70
  .db 19, 77
  .db 9, 74
  .db 10, 77
  .db 10, 74
  .db 9, 70
  .db 0, 0
PineappleRagCh2:
  .db 255, $7f
  .db 33, $7f
  .db 19, 46
  .db 19, 62
  .db 20, 41
  .db 19, 53
  .db 19, 46
  .db 19, 62
  .db 19, 41
  .db 20, 62
  .db 19, 46
  .db 19, 62
  .db 19, 41
  .db 19, 53
  .db 20, 46
  .db 0, 0
ArrangeBlackStoneSE:
  .db 0, 52
  .db 12, $7f
  .db 0, 0
ArrangeWhiteStoneSE:
  .db 1, 52
  .db 12, $7f
  .db 0, 0
ErrorSE:
  .db 0, 40
  .db 5, $7f
  .db 10, 40
  .db 15, $7f
  .db 0, 0
SetBlackSE:
  .db 0, $7f
  .db 0, 72
  .db 0, 67 - 6
  .db 4, 71 - 6
  .db 12, $7f
  .db 0, 0
SetWhiteSE:
  .db 0, 71 - 6
  .db 4, 67 - 6
  .db 12, $7f
  .db 0, 0
SkipSE:
  .db 0, 72
  .db 7, 74
  .db 7, 75
  .db 14, 65
  .db 7, 67
  .db 7, 68
  .db 0, 0
StartSE:
  .db 0, $7f
  .db 15, 45 + 24
  .db 7, 42 + 24
  .db 7, 38 + 24
  .db 7, 42 + 24
  .db 7, 45 + 24
  .db 0, 0

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
