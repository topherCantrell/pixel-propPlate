VAR
    long v1x
    long v1y
    long v2x
    long v2y
    long v3x
    long v3y
    
OBJ
    NEO_API : "NeoPixelAPI"

pub init(neoAPIptr, cols, rows, _v1x,_v1y, _v2x,_v2y, _v3x,_v3y)
  NEO_API.init(neoAPIptr)

pub drawRaster(data,numCols,numRows)
  repeat