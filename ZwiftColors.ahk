
; These are Zwift's button, menu and dialog background colors
rgbOrange  := 0xf36c3d
rgbBlue    := 0x0f92cc
rgbBlack   := 0x181818
rgbDkGray  := 0x303030
rgbLtGray  := 0x7f7f7f
rgbVLtGray := 0xdcdcdc
rgbVVLtGray:= 0xe1e1e1
rgbOffWhite:= 0xececec   ; only used in the group ride pre-start message box
rgbWhite   := 0xffffff

; for use with InStr() statements to match a color
; somehow(?) AHK knows to put these in as hex values with the 0x prefix, which acts as a delimiter
strMenuColors :=  rgbWhite . rgbOrange . rgbBlue . rgbBlack . rgbDkGray . rgbLtGray . rgbVLtGray . rgbVVLtGray . rgbOffWhite
  
; the alternating light and blue Z's in the banner background, and the amount of variation in color we're ok with finding
; this banner has some alpha-channel transparency, so variation is needed	
rgbBlue1  := 0x3979C3
varBlue1  := 20

rgbBlue2  := 0x1F62B3   
varBlue2  := 20