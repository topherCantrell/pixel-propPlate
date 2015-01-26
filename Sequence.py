
with open("Sequence.txt") as f:
    raw = f.readlines()
    
lines = []
for r in raw:
    r = r.strip()
    if ";" in r:
        r = r[0:r.index(";")].strip()
    if len(r)>0:
        lines.append(r)
        
data = []

def parseHex(value):
    value = value.replace("_","")
    return int(value,16)

def addLong(data,value):
    data.append((value>>0)  & 0xFF)
    data.append((value>>8)  & 0xFF)
    data.append((value>>16) & 0xFF)
    data.append((value>>24) & 0xFF)
    
def addWord(data,value):
    data.append((value>>0)  & 0xFF)
    data.append((value>>8)  & 0xFF)    
    
charMap = {}

x=0
while x<len(lines):
    line = lines[x]    
    x=x+1
    if line.startswith("#Palette"):
        words = line.split(" ")
        addr = int(words[1])        
        y = x
        while y<len(lines) and not lines[y].startswith("#"):
            y = y + 1        
        cnt = y - x 
                
        # 0A_00_XX_CC  X=Address, C=number of entries       
        data.append(cnt)   
        data.append(addr)
        data.append(0)  
        data.append(0x0A)    
        for y in xrange(cnt):
            addLong(data,parseHex(lines[x]))
            x=x+1
        continue
    
    if line.startswith("#Chars"):
        i = line.index('"')
        j = line.index('"',i+1)
        cs = line[i+1:j]
        m = line[j+1:].strip().split(" ")
        charMap = {}
        for z in xrange(len(cs)):
            charMap[cs[z]] = int(m[z],16)
        continue   
    
    if line.startswith("#DrawBytes"):        
        ox = 0
        oy = 0        
        words = line.split(" ")[1:]
        if len(words)>0:
            ox = int(words[0])
            oy = int(words[1])
            
        addLong(data,0x02000000 | (ox<<8) | oy)
        
        y = x
        while y<len(lines) and not lines[y].startswith("#"):
            y = y + 1        
        cnt = y - x        
        
        ln = len(lines[x])                
        addLong(data, ((cnt*ln)<<16) | ln  )
        
        for i in xrange(cnt):
            for j in xrange(ln):                
                data.append(charMap[lines[x][j]])
            x = x + 1 
        continue
    
    if line.startswith("#DrawLast"):
        ox = 0
        oy = 0        
        words = line.split(" ")[1:]
        if len(words)>0:
            ox = int(words[0])
            oy = int(words[1])            
        addLong(data,0x20000000 | (ox<<8) | oy)
        continue        
    
    if line.startswith("#Delay"):
        dv = int(line[6:].strip())
        addLong(data,dv | 0x0B000000)
        continue
    
    if line.startswith("#Restart"):
        addLong(data,0x0C000000)
        continue
    
    if line.startswith("#Repeat"):
        words = line.split(" ")
        addLong(data,0x0D000000 | int(words[1]))
        continue
    
    if line.startswith("#Next"):
        addLong(data,0x0E000000)
        continue        
    
    raise Exception("UNKNOWN '"+line+"' on line "+str(x))     
        

addLong(data,0xFFFFFFFF)

pos = -1
s = ""
for d in data:
    pos = pos + 1
    if pos==0:
        s = "  byte "
    s = s + "$"+ format(d,'02x')
    if pos==15:
        pos = -1        
        print s
    else:
        s = s + ","
        
if len(s)>0:
    if s[-1]==',':
        s = s[0:-1]
    print s
    
           