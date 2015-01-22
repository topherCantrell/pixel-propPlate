VAR

    ' Param block for the driver COG
    '
    long   command    ' Command trigger -- write non-zero value
    long   buffer     ' Pointer to the pixel data buffer
    long   pixPerRow  ' Number of pixels in a row
    long   numRows    ' Number of rows
    long   rowOffset  ' Memory offset between rows
    long   palette    ' Color palette (some commands)
    long   pin        ' The pin number to send data over
        
    ' Palettes
    long   pals[256*4]

    long   repeatAddr[8]
    long   repeatCnt[8]
    long   repeatInd

OBJ
    NEO    : "NeoPixel" 

pub playSequence(ptr) | og, c, w, n, addr, ct, p, i

  dira[0] := 1
  outa[0] := 0

  pals[0] := $00_00_00
  pals[1] := $0F_00_00
  pals[2] := $00_0F_00
  pals[3] := $00_00_0F

  pin       := 0
  palette   := @pals
  rowOffset := 0
  numRows   := 1
  pixPerRow := 64    

  command := 0
  NEO.start(@command)

  og := ptr
  repeatInd := -1

  repeat  
    c := long[ptr]
    ptr := ptr + 4
    w := c>>24

    if w==$FF
      ' FF_FF_FF_FF (End)
      return

    if w==$0A
      ' 0A_NN_XX_CC  N=palette number, X=Address, C=number of entries
      n := (c>>16) & $FF    ' Pal number
      addr := (c>>8) & $FF  ' Offset entry in pal
      ct := c & $FF         ' Number of entries
      p := @pals + n*1024 + addr*4 
      repeat i from 1 to ct
        long[p] := long[ptr]
        p := p + 4
        ptr := ptr + 4
      next

    if w==$02
      ' 02_00_00_00 (one-byte-pixels)
      buffer := ptr
      command := w
      ptr := ptr + 64
      repeat while command<>0
      next

    if w==$0B
      ' 0B_DD_DD_DD  D=millisecond delay
      PauseMSec(c & $FF_FF_FF)
      next

    if w==$0C
      ' 0C_00_00_00 (Restart)
      ptr := og
      next

    if w==$0D
      ' 0D_CC_CC_CC (Repeat) C=Count
      repeatInd := repeatInd + 1
      repeatAddr[repeatInd] := ptr
      repeatCnt[repeatInd] := c & $FF_FF_FF
      next

    if w==$0E
      ' 0E_00_00_00 (Next)
      repeatCnt[repeatInd] := repeatCnt[repeatInd] -1
      if repeatCnt[repeatInd] > 0
        ptr := repeatAddr[repeatInd]
      else
        repeatInd := repeatInd - 1
      next                                    
  
PRI PauseMSec(Duration)
  waitcnt(((clkfreq / 1_000 * Duration - 3932) #> 381) + cnt)