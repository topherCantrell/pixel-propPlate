VAR

    ' If sequencer is running in a separate COG
    long   PixelSequencerStack[64]
    long   PixelSequencerCOG
            
    ' Palette
    long   pal[256]   ' Use for one-byte mode

    ' Up to 8 nested repeat-counters
    long   repeatAddr[8]
    long   repeatCnt[8]
    long   repeatInd

    long v1x
    long v1y
    long v2x
    long v2y
    long v3x
    long v3y

OBJ
    NEO_API : "NeoPixelAPI" 

pub init(neoAPIptr, cols, rows, _v1x,_v1y, _v2x,_v2y, _v3x,_v3y)
  ' Currently there is no COG running
  NEO_API.init(neoAPIptr)

  v1x := _v1x
  v1y := _v1y
  v2x := _v2x
  v2y := _v2y
  v3x := _v3x
  v3y := _v3y

  if v1x>1
    NEO_API.setNumberOfPlates(1)
  else if v2x>1
    NEO_API.setNumberOfPlates(2)
  else if v3x>1
    NEO_API.setNumberOfPlates(3)
  else
    NEO_API.setNumberOfPlates(4)  
  
  PixelSequencerCOG := -1
  
pub startSequencer(ptr)
  ' Only start one COG
  if PixelSequencerCOG == -1
    PixelSequencerCOG := cognew(sequencer(ptr), @PixelSequencerStack)

pub stopSequencer
  ' Only stop if one is running
  if PixelSequencerCOG > -1
    cogstop(PixelSequencerCOG)
    PixelSequencerCOG := -1



    
pub sequencer(ptr) | og, c, w, n, addr, ct, p, i,x , y, lastDraw, lastRowLen

  ' TODO the driver should be the only one who cares about the IO pin direction
  ' Running in a separate COG ... we need to init our I/O
  dira[NEO_API.getOutputPin] := 1
  outa[NEO_API.getOutputPin] := 0

  pal[0] := $00_00_00
  pal[1] := $0F_00_00
  pal[2] := $00_0F_00
  pal[3] := $00_00_0F

  NEO_API.setPalette(@pal)  
    
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

      NEO_API.setRowOffset(lastRowLen - NEO_API.getPixelsPerRow)     
      NEO_API.setBuffer(ptr + y*lastRowLen + x)
      NEO_API.waitCommand(2)
      
      ptr := ptr + n
      next

    if w==$20
      ' 20_00_XX_YY (one-byte-pixels ... use last data)
      x := (c>>8) & $FF
      y := c & $FF
      NEO_API.setBuffer(lastDraw + y*lastRowLen + x)
      NEO_API.waitCommand(2)   

        
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