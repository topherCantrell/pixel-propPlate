con
              ' GG_RR_BB
  C_WHITE    = $20_20_20
  C_YELLOW   = $20_20_00

  ' Player 1
  C_DM_GREEN = $10_00_00
  C_GREEN    = $20_00_00
  C_BR_GREEN = $40_00_00   

  ' Player 2
  C_DM_RED   = $00_10_00
  C_RED      = $00_20_00
  C_BR_RED   = $00_40_00 
  

obj

  NEO_API : "NeoPixelAPI"

var
  byte buf[64]

  long palette[256]
  
pub init(paramsPtr)
  NEO_API.init(paramsPtr)

pub setCell(x,y,value) | px,py
  px := x*3
  py := y*3
  buf[py*8+px] := value
  buf[(py+1)*8+px] := value
  buf[py*8+px+1] := value
  buf[(py+1)*8+px+1] := value 

pub makeGameColors
  palette[0]  := $00_00_00  ' Empty           
  palette[1]  := C_WHITE    ' Grid lines      (white)
  '
  palette[2]  := C_YELLOW   ' Player 1 Cursor (yellow)
  palette[3]  := C_BR_GREEN ' Player 1 Win    (bright green)
  palette[4]  := C_GREEN    ' Player 1 Normal (green) 
  palette[5]  := C_DM_GREEN ' Player 1 Faint  (dim green)
  '
  palette[6]  := C_YELLOW   ' Player 2 Cursor (yellow)
  palette[7]  := C_BR_RED   ' Player 2 Win    (bright red)
  palette[8]  := C_RED      ' Player 2 Normal (red)
  palette[9]  := C_DM_RED   ' Player 2 Faint  (dim red)

  palette[20] := $00_00_00  ' Empty
  palette[21] := C_WHITE    ' Grid lines      (white)
  '
  palette[22] := C_DM_GREEN ' Player 1 Cursor (dim green)
  palette[23] := C_GREEN    ' Player 1 Win    (green)
  palette[24] := C_GREEN    ' Player 1 Normal (green)
  palette[25] := C_DM_GREEN ' Player 1 Faint  (dim green)
  '
  palette[26] := C_DM_RED   ' Player 2 Cursor (dim red)
  palette[27] := C_RED      ' Player 2 Win    (red)
  palette[28] := C_RED      ' Player 2 Normal (red) 
  palette[29] := C_DM_RED   ' Player 2 Faint  (dim red)

pub clearGameBoard | x
  repeat x from 0 to 63
    buf[x] :=0
    
  repeat x from 0 to 7
    buf[x*8+2] := 1
    buf[x*8+5] := 1
    buf[8*2+x] := 1
    buf[8*5+x] := 1               

pub blinkPalettes(pause, count) | x  
  repeat x from 1 to count
    NEO_API.setPalette(@palette)
    NEO_API.waitCommand(2)
    PauseMSec(pause)
    NEO_API.setPalette(@palette+4*20)
    NEO_API.waitCommand(2)
    PauseMSec(pause)

pub promptPlayer(pause, longTimeout) | x
  ' TODO if count is 0 then we watch the button and
  ' return a value:
  '   1 = quick click
  '   2 = hold
  '   3 = long timeout
  ' Don't forget to debounce any still-pressed
  ' When the button is pressed, always switch to palette 1
  '  while waiting for "hold"
  repeat x from 1 to count
    NEO_API.setPalette(@palette)
    NEO_API.waitCommand(2)
    PauseMSec(pause)
    NEO_API.setPalette(@palette+4*20)
    NEO_API.waitCommand(2)
    PauseMSec(pause)
  
pub playGame | x, opType

  ' opType: 0=Mr. Random, 1=One Ahead, 2=Cat Woman

  ' TODO: Random go first
  ' TODO: Show opponent on display
  ' TODO: Splash sequences (attract) -- this goes in the caller main loop

  opType := 0
                  
  makeGameColors

  NEO_API.setPalette(@palette)
  NEO_API.setRowOffset(0)
  NEO_API.setNumberOfRows(8)
  NEO_API.setPixelsPerRow(8)
  NEO_API.setBuffer(@buf)

  clearGameBoard

  setCell(0,0,2)
  setCell(1,1,8)

  blinkPalettes(250,10)  
 
  repeat

PRI PauseMSec(Duration)
  waitcnt(((clkfreq / 1_000 * Duration - 3932) #> 381) + cnt)  