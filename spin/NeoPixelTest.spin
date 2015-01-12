CON
  _clkmode        = xtal1 + pll16x
  _xinfreq        = 5_000_000

OBJ    
    NEO    : "NeoPixel"

VAR
    long   command
    long   buffer
    long   numPixels
    long   pin

    long   pixels[64]
    
PUB Main : i

  dira[0] := 1
  outa[0] := 0
   
  NEO.start(@command)

  PauseMSec(1000)

  ' $00_GG_RR_BB

  ' Fill the grid with a green
  repeat i from 0 to 63
    pixels[i] := $00_10_00_00

  repeat i from 0 to 7
    pixels[i*8 + i]   := $00_00_20_00  ' Red diagonal upper-left to bottom-right
    pixels[i*8 +7 -i] := $00_00_00_20  ' Blue diagonal upper-right to bottom-left
  
  pin        := 0
  numPixels  := 64
  buffer     := @pixels
  command    := 1

  repeat 
                                                                                                           
PRI PauseMSec(Duration)
  waitcnt(((clkfreq / 1_000 * Duration - 3932) #> 381) + cnt)
