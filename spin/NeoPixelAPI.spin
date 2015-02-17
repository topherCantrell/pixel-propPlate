var

  long self
  
  ' long   p_command        '  +0 Command trigger -- write non-zero value
  ' long   p_palette        '  +4 Color palette (some commands) 
  ' long   p_buffer         '  +8 Pointer to the pixel data buffer
  ' long   p_pin            ' +12 The pin number to send data over
  ' long   p_pixPerRow      ' +16 Number of pixels in a row on the plate
  ' long   p_numRows        ' +20 Number of rows on the plate
  ' long   p_numPlates      ' +24 Number of plates to update
  ' long   p_rowOffset      ' +28 Memory offset between rows
  ' long   p_plateOffset[3] ' +32 Up to four plates (change if you need more)

CON
  ofs_command     = 0
  ofs_palette     = ofs_command   + 4
  ofs_buffer      = ofs_palette   + 4
  ofs_pin         = ofs_buffer    + 4
  ofs_pixPerRow   = ofs_pin       + 4
  ofs_numRows     = ofs_pixPerRow + 4
  ofs_numPlates   = ofs_numRows   + 4
  ofs_rowOffset   = ofs_numPlates + 4
  ofs_plateOffset = ofs_rowOffset + 4
  
PUB init(_self)
  self := _self

PUB setCommand(v)
  long[self+ofs_command] :=v
PUB getCommand
  return long[self+ofs_command]
   
PUB setPalette(pal)
  long[self+ofs_palette] := pal
PUB getPalette
  return long[self+ofs_palette]

PUB setBuffer(v)
  long[self+ofs_buffer] :=v
PUB getBuffer
  return long[self+ofs_buffer]

PUB setOutputPin(pn)
  long[self+ofs_pin] := pn  
PUB getOutputPin
  return long[self+ofs_pin]   

PUB setPixelsPerRow(v)
  long[self+ofs_pixPerRow] := v
PUB getPixelsPerRow
  return long[self+ofs_pixPerRow]

PUB setNumberOfRows(v)
  long[self+ofs_numRows] := v
PUB getNumberOfRows
  return long[self+ofs_numRows]

PUB setNumberOfPlates(v)
  long[self+ofs_numPlates] := v
PUB getNumberOfPlates
  return long[self+ofs_numPlates]   
                               
PUB setRowOffset(v)
  long[self+ofs_rowOffset] := v
PUB getRowOffset
  return long[self+ofs_rowOffset]

PUB setPlateOffset(i,v)
  long[self+ofs_plateOffset+i*4] := v
PUB getPlateOffset(i)
  return long[self+ofs_plateOffset+i*4]

  

PUB waitCommand(v)
  long[self+ofs_command] :=v
  repeat while long[self]<>0
