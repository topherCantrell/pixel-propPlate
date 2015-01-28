obj

  NEO_API : "NeoPixelAPI"

var
  byte bufA[64]
  byte bufB[64]

  long palette[256]
  
pub init(paramsPtr)
  NEO_API.init(paramsPtr)
  
pub playGame | x

                ' GG_RR_BB
  palette[0]  := $00_00_00 ' Empty
  palette[1]  := $10_10_10 ' Grid lines
  palette[2]  := $00_00_00 ' Player 1 Cursor (yellow)
  palette[3]  := $00_00_00 ' Player 1 Win    (bright green)
  palette[4]  := $00_00_00 ' Player 1 Normal (green) 
  palette[5]  := $00_00_00 ' Player 1 Faint  (dim green)
  palette[6]  := $00_20_20 ' Player 2 Cursor
  palette[7]  := $40_00_00 ' Player 2 Win
  palette[8]  := $20_00_00 ' Player 2 Normal
  palette[9]  := $10_00_00 ' Player 2 Faint

  palette[20] := $00_00_00 ' Empty
  palette[21] := $10_10_10 ' Grid lines
  palette[22] := $00_00_00 ' Player 1 Cursor
  palette[23] := $00_00_00 ' Player 1 Win
  palette[24] := $00_00_00 ' Player 1 Normal
  palette[25] := $00_00_00 ' Player 1 Faint
  palette[26] := $00_00_00 ' Player 2 Cursor
  palette[27] := $20_00_00 ' Player 2 Win
  palette[28] := $20_00_00 ' Player 2 Normal
  palette[29] := $10_00_00 ' Player 2 Faint

  NEO_API.setPalette(@palette)
  NEO_API.setRowOffset(0)
  NEO_API.setNumberOfRows(8)
  NEO_API.setPixelsPerRow(8)
  
  repeat x from 0 to 7
    bufA[x*8+2] := 1
    bufA[x*8+5] := 1
    bufA[8*2+x] := 1
    bufA[8*5+x] := 1

  NEO_API.setBuffer(@bufA)
  NEO_API.waitCommand(2)
 
  repeat

