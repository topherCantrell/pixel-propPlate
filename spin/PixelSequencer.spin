VAR

    ' If sequencer is running in a separate COG
    long   PixelSequencerStack[64]
    long   PixelSequencerCOG

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
    long   pal[256]   ' Use for one-byte mode

    ' Up to 8 nested repeat-counters
    long   repeatAddr[8]
    long   repeatCnt[8]
    long   repeatInd            

OBJ
    NEO    : "NeoPixel" 

pub initSequencer
  ' Currently there is no COG running
  PixelSequencerCOG := -1
  
pub startSequencer(ptr,pn)
  ' Only start one COG
  if PixelSequencerCOG == -1
    PixelSequencerCOG := cognew(sequencer(ptr,pn), @PixelSequencerStack)

pub stopSequencer
  ' Only stop if one is running
  if PixelSequencerCOG > -1
    cogstop(PixelSequencerCOG)
    PixelSequencerCOG := -1

pub sequencer(ptr,pn) | og, c, w, n, addr, ct, p, i,x , y, lastDraw, lastRowLen

  dira[pn] := 1
  outa[pn] := 0

  pal[0] := $00_00_00
  pal[1] := $0F_00_00
  pal[2] := $00_0F_00
  pal[3] := $00_00_0F

  pin       := pn
  palette   := @pal
  rowOffset := 0
  numRows   := 8
  pixPerRow := 8    

  command := 0
  NEO.start(@command)         
  
  og := ptr
  repeatInd := -1

  repeat  
    c := long[ptr]
    ptr := ptr + 4
    w := c>>24

    
    if w==$02
      ' 02_00_XX_YY (one-byte-pixels)
      ' nn_nn_oo_oo (n=number of bytes in data, o=row length)

      x := (c>>8) & $FF
      y := c & $FF        
      c := long[ptr]
      ptr := ptr + 4
      n := (c>>16) & $FF_FF
      lastRowLen := c & $FF_FF         
      lastDraw := ptr

      rowOffset :=  lastRowLen - 8      
      buffer := ptr + y*lastRowLen + x
      command := 2       
      repeat while command<>0
      
      ptr := ptr + n
      next

    if w==$20
      ' 20_00_XX_YY (one-byte-pixels ... use last data)
      x := (c>>8) & $FF
      y := c & $FF
      buffer := lastDraw + y*lastRowLen + x
      command := 2       
      repeat while command<>0   

        
    if w==$0A
      ' 0A_00_XX_CC  X=Address, C=number of entries
      addr := (c>>8) & $FF  ' Offset entry in pal
      ct := c & $FF         ' Number of entries
      p := @pal + addr*4 
      repeat i from 1 to ct
        long[p] := long[ptr]
        p := p + 4
        ptr := ptr + 4
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

      
    if w==$FF
      ' FF_FF_FF_FF (End)
      return                                 
  
PRI PauseMSec(Duration)
  waitcnt(((clkfreq / 1_000 * Duration - 3932) #> 381) + cnt)