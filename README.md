# propNeoPixel

This is my NeoPixel driver for the Propeller.

I used the Adafruit 8x8 NeoPixel plates:<br>
https://www.adafruit.com/products/1487

Here is my plate connected to my propeller quick-start board:<br>
![](https://github.com/topherCantrell/propNeoPixel/blob/master/Art/Hardware.jpg)

Here are the schematics from the "NeoPixelTest.spin" documentation:<br>
![](https://github.com/topherCantrell/propNeoPixel/blob/master/Art/Schematics.jpg)

## Dot Matrix Mapping

The driver allows you to map up to four plates over a larger dot-matrix image. (You can modify
the code to support as many plates as you need).

The chain-of-plates forms a "window" or "view" over the larger image. Here are several example
views over a single image:
![](https://github.com/topherCantrell/propNeoPixel/blob/master/Art/ExampleMap.jpg)

You tell the driver the view layout in the init function. Here are two example "lines" of plates:
![](https://github.com/topherCantrell/propNeoPixel/blob/master/Art/Lines.jpg)

The first parameter to init is the output pin number to drive the plate (or chain of plates).

The next two parameters tell the driver how many rows and columns are on the plate. The adafruit plates are 8x8.

The fourth and fifth parameters are the first plate's (x,y) offset within view. In the "lines" example the first
plate was always the upper left corner of the view window, but this need not be the case.

The last three pairs of parameters are used to define the layout of other plates in the chain. These take the
form of (x,y) offsets from the plate before. For instance (1,0) means the next plate is to the right one plate.
A value of (-1,-1) means the next plate is up a plate and left a plate. If there is no "next plate" then
pass (0,0).

Here is an example of a square window made from 4 plates. There are many ways to physically chain the plates 
together:
![](https://github.com/topherCantrell/propNeoPixel/blob/master/Art/Squares.jpg)

The second example is a complex example with a crossing wiring pattern. Note the first plate has (ix,iy) of (8,8)
since the first plate is at the bottom right of the window.

## Multiple Chains

The "MultiNeoPixelPlateAPI.spin" module allows you to combine multiple plate drivers to form a single view. This
provides a faster refresh rate since there are two serial streams instead of one.
![](https://github.com/topherCantrell/propNeoPixel/blob/master/Art/Multi.jpg)

## Color Palette

The driver supports and optional "color palette" mode.

Neo Pixels have 24 bit color: 1 byte for red, 1 for green, and 1 for blue.

The driver allows you to use a color palette with up up to 256 entries. Each entry is a long (4 byte) value specifying a pixel color. Only the lower 3 bytes are used.

The image map is then a grid of one-byte-per-pixel. The driver uses the byte value from the image buffer to find the actual 3-byte pixel value from the color palette. Thus you can only use 256 colors at a time, but those colors can be any 3-byte value.

This palette mode is optional. Your images may be defined with full 24-bit color.

## Sequencer

The sequencer reads binary-sequence data to produce animated displays on the plate window. A python program reads
a text sequence description and produces the propeller data section for the propeller sequencer to parse.

Comments in the text file begin with ";". Commands begin with "#". Most commands have a number of data-lines that follow.

```
\# Palette start=0
00_00_00_00
00_FF_10_FF
; 
; Fill the color palette beginning at [start] with as many colors as given

\#Chars chars=.ABCDE+X values=00,01,02,03,04,05,06,07
; Define a character-to-pixel-value map for drawing images in ascii art

\#DrawBytes x=0 y=0
........
.AAAAAA.
.A....A.
.A.BB.A.
.A.BB.A.
.A....A.
.AAAAAA.
........
;
; Draw the window over the given image with window offset of (x,y)

\#DrawLast x=7 y=7
;
; Draw the window over the last image given with window offset of (x,y)

\Delay ms=1000
;
; Pause for 1000 ms

\#Restart
;
; Restart the sequence at the start

\#Repeat count=4
\#Repeat count=2
; Other commands in here
\#Next
\#Next
;
; You can nest "repeat" commands up to 4 levels deep. The "next" command takes you back
; to the top of the repeat loop. The "count" tells how many times to repeat the loop.
```

## The Parallax Object Exchange

Here is the code on the Parallax Object Exchange:<br>
[http://obex.parallax.com/object/774](http://obex.parallax.com/object/774)



