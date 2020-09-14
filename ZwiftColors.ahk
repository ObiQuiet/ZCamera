
; These are Zwift's button, menu and dialog background colors
rgbOrange  := 0xf36c3d
rgbBlue    := 0x1192cc
rgbBlack   := 0x181818
rgbDkGray  := 0x303030
rgbLtGray  := 0x7f7f7f
rgbVLtGray := 0xdcdcdc
rgbOffWhite:= 0xececec   ; only used in the group ride pre-start message box
rgbWhite   := 0xffffff

; for use with "if var in matchlist" statements
ListOfColors = %rgbWhite%,%rgbOrange%,%rgbBlue%,%rgbBlack%,%rgbDkGray%,%rgbLtGray%,%rgbVLtGray%,%rgbOffWhite%
   
; the alternating light and blue Z's in the banner background, and the amount of variation in color we're ok with finding
; this banner has some alpha-channel transparency, so variation is needed	
rgbBlue1  := 0x3979C3
varBlue1  := 10

rgbBlue2  := 0x1F62B3   
varBlue2  := 10