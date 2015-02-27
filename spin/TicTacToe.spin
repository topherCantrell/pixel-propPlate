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

  ' Button states (pressed = 0)
  B_DOWN = 0
  B_UP = 1

  ' 2 second means held down 
  HOLD_COUNT = 200 
  

obj

  NEO_API : "NeoPixelPlateAPI"

var
  byte buf[64]

  long palA[40]
  long palB[40]
  long buttonPin
  
pub init(neoAPIptr,_buttonPin)
  NEO_API.init(neoAPIptr)
  buttonPin := _buttonPin
  dira[buttonPin] := 0

pub setCell(x,y,value) | px,py
  px := x*3
  py := y*3
  buf[py*8+px] := value
  buf[(py+1)*8+px] := value
  buf[py*8+px+1] := value
  buf[(py+1)*8+px+1] := value 

pub makeGameColors
  palA[0]  := $00_00_00  ' Empty           
  palA[1]  := C_WHITE    ' Grid lines      (white)  
  palA[2]  := C_YELLOW   ' Player 1 Cursor (yellow)
  palA[3]  := C_BR_GREEN ' Player 1 Win    (bright green)
  palA[4]  := C_GREEN    ' Player 1 Normal (green) 
  palA[5]  := C_DM_GREEN ' Player 1 Faint  (dim green)
  palA[6]  := C_YELLOW   ' Player 2 Cursor (yellow)
  palA[7]  := C_BR_RED   ' Player 2 Win    (bright red)
  palA[8]  := C_RED      ' Player 2 Normal (red)
  palA[9]  := C_DM_RED   ' Player 2 Faint  (dim red)

  palB[0] := $00_00_00  ' Empty
  palB[1] := C_WHITE    ' Grid lines      (white)
  palB[2] := C_DM_GREEN ' Player 1 Cursor (dim green)
  palB[3] := C_GREEN    ' Player 1 Win    (green)
  palB[4] := C_GREEN    ' Player 1 Normal (green)
  palB[5] := C_DM_GREEN ' Player 1 Faint  (dim green)
  palB[6] := C_DM_RED   ' Player 2 Cursor (dim red)
  palB[7] := C_RED      ' Player 2 Win    (red)
  palB[8] := C_RED      ' Player 2 Normal (red) 
  palB[9] := C_DM_RED   ' Player 2 Faint  (dim red)

pub clearGameBoard | x
  repeat x from 0 to 63
    buf[x] :=0
    
  repeat x from 0 to 7
    buf[x*8+2] := 1
    buf[x*8+5] := 1
    buf[8*2+x] := 1
    buf[8*5+x] := 1

  NEO_API.setPalette(@palA)
  NEO_API.waitCommand(2)              

pub blinkPalettes(pause, count) | x  
  repeat x from 1 to count
    NEO_API.setPalette(@palA)
    NEO_API.waitCommand(2)
    PauseMSec(pause)
    NEO_API.setPalette(@palB)
    NEO_API.waitCommand(2)
    PauseMSec(pause)

pub promptPlayer(pause, longTimeout) | x, inDeb, bs, qc, mode, pc, pn

  ' return a value:
  '   1 = quick click
  '   2 = hold
  '   3 = long timeout

  ' If the button is down then wait for it to come up
  ' before watching for input.
  inDeb := 0
  if ina[buttonPin]==B_DOWN
    inDeb := 1
    
  pc := pause-1 ' Start out with a palette flip
  pn := 1       ' Start out showing palette A
  qc := 0       ' Count up to "held-down" when pressed
  mode := 0     ' 0=waiting, 1=button down

  repeat
  
    ' 10MS resolution on state machine 
    PauseMSec(10) 

    ' We only wait for so long
    longTimeout := longTimeout - 1
    if longTimeout == 0
      return 3
  
    ' We flip the palette regularly. Once the
    ' button is pressed, we hold the palette
    pc := pc + 1
    if pc==pause and mode==0
      ' Flip the palette
      pc := 0
      if pn==1
        NEO_API.setPalette(@palA)
        NEO_API.waitCommand(2)
        pn := 0
      else
        NEO_API.setPalette(@palB)
        NEO_API.waitCommand(2)
        pn := 1

    ' Get the current button state
    bs := ina[buttonPin]

    ' If we are debouncing, wait for the button to release
    if inDeb==1
      if bs==B_UP
        inDeb:=0
      next

    ' If the button has been pressed then hold the palette
    ' and start counting for "held down"
    if mode==0 ' Waiting for a button press
      if bs==B_DOWN
        mode:=1
        NEO_API.setPalette(@palA)
        NEO_API.waitCommand(2)
      next

    if mode==1' Already got a button press    
      if bs==B_DOWN
        qc := qc + 1
        if qc == HOLD_COUNT
          return 2
      else
        return 1        
    
pub playGame | x, opType

  ' opType: 0=Mr. Random, 1=One Ahead, 2=Cat Woman

  ' TODO: NO ... pass these in
  
  ' TODO: Random go first
  ' TODO: Show opponent on display
  ' TODO: Splash sequences (attract) -- this goes in the caller main loop

  opType := 0
                  
  makeGameColors

  NEO_API.setPalette(@palA)
  NEO_API.setRowOffset(0)
  NEO_API.setNumberOfRows(8)
  NEO_API.setPixelsPerRow(8)
  NEO_API.setBuffer(@buf)

  clearGameBoard

  setCell(0,0,2)

  x := promptPlayer(25,30*100)

  setCell(x-1,2,2)

  blinkPalettes(250,100)    
 
  repeat

PRI PauseMSec(Duration)
  waitcnt(((clkfreq / 1_000 * Duration - 3932) #> 381) + cnt)  