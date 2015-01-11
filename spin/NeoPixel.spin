CON
  _clkmode        = xtal1 + pll16x
  _xinfreq        = 5_000_000

OBJ    
    PST     : "Parallax Serial Terminal"

        
PUB Main

  DIRA[0] := 1
  OUTA[0] := 0

  repeat  
                                                                                                           
PRI PauseMSec(Duration)
  waitcnt(((clkfreq / 1_000 * Duration - 3932) #> 381) + cnt)