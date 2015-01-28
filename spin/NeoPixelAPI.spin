var
  long parPtr
  'long   command    ' Command trigger -- write non-zero value
  'long   buffer     ' Pointer to the pixel data buffer
  'long   pixPerRow  ' Number of pixels in a row
  'long   numRows    ' Number of rows
  'long   rowOffset  ' Memory offset between rows
  'long   palette    ' Color palette (some commands)
  'long   pin        ' The pin number to send data over
  
PUB init(paramsPtr)
  parPtr := paramsPtr

PUB setOutputPin(pn)
  long[parPtr+4*6] := pn

PUB getOutputPin
  return long[parPtr+4*6]
  
PUB setPalette(pal)
  long[parPtr+4*5] := pal

PUB setRowOffset(v)
  long[parPtr+4*4] := v

PUB setNumberOfRows(v)
  long[parPtr+4*3] := v

PUB setPixelsPerRow(v)
  long[parPtr+4*2] := v

PUB setBuffer(v)
  long[parPtr+4] :=v

PUB setCommand(v)
  long[parPtr] :=v

PUB waitCommand(v)
  long[parPtr] :=v
  repeat while long[parPtr]<>0

PUB getCommand
  return long[parPtr]
