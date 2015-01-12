pub start(paramBlock)
'' Start the NeoPixel driver cog
   return cognew(@NeoCOG,paramBlock)
   
DAT          
        org 0

NeoCOG   
        mov     comPtr,par        ' This is the "trigger" address
        mov     bufPtr,par        ' This is the ...
        add     bufPtr,#4         ' ... buffer address
        mov     numPtr,par        ' This is the ...
        add     numPtr,#8         ' ... number of pixels to send
        mov     pinPtr,par        ' This is the ...
        add     pinPtr,#12        ' ... data pin number                 

top     rdlong  com,comPtr wz     ' Has an update been triggered?
  if_z  jmp     #top              ' No ... wait until

        rdlong  com,pinPtr        ' Which pin for this update
        mov     pn,#1             ' Pin number ...
        shl     pn,com            ' ... to mask
        or      dira,pn           ' Make sure we can write to it

        rdlong  num,numPtr        ' Number of pixels to write

        rdlong  pPtr,bufPtr       ' Where the pixels come from      

refresh
        rdlong  com,pPtr          ' Get the next pixel value
        add     pPtr,#4           ' Ready for next pixel in buffer
        shl     com, #8           ' Ignore top 8 bits (3 bytes only)
        mov     bitCnt,#24        ' 24 bits to move

bitLoop
        shl     com, #1 wc        ' MSB goes first
  if_c  jmp     #doOne            ' Go send one if it is a 1
        call    #sendZero         ' It is a zero ... send a 0
        jmp     #bottomLoop       ' Skip over sending a 1
doOne   call    #sendOne

bottomLoop
        djnz    bitCnt,#bitLoop   ' Do all 24 bits in the pixel
        djnz    num,#refresh      ' Do all requested pixels

        call    #sendDone         ' Latch in the LEDs  

        jmp     #done             ' Clear the trigger               
        
sendZero                 
        or      outa,pn           ' Take the data line high
        mov     c,#$5             ' wait 0.4us (400ns)
loop3   djnz    c,#loop3          '
        andn    outa,pn           ' Take the data line low
        mov     c,#$B             ' wait 0.85us (850ns) 
loop4   djnz    c,#loop4          '                              
sendZero_ret                      '
        ret                       ' Done

sendOne
        or      outa,pn           ' Take the data line high
        mov     c,#$D             ' wait 0.8us 
loop1   djnz    c,#loop1          '                       
        andn    outa,pn           ' Take the data line low
        mov     c,#$3             ' wait 0.45us  36 ticks, 9 instructions
loop2   djnz    c,#loop2          '
sendOne_ret                       '
        ret                       ' Done

sendDone
        andn    outa,pn           ' Take the data line low
        mov     c,C_RES           ' wait 60us
loop5   djnz    c,#loop5          '
sendDone_ret                      '
        ret                       '

done    mov     com,#0            ' Clear ...
        wrlong  com,comPtr        ' ... the trigger
        jmp     #top              ' Go back and wait

C_RES   long $4B0                 ' Wait count for latching the LEDs

comPtr  long 0
bufPtr  long 0
numPtr  long 0
pinPtr  long 0

com     long 0
pPtr    long 0  
pn      long 0
num     long 0
c       long 0

bitCnt  long 0
pixCnt  long 0