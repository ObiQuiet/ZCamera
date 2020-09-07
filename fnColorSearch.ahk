; -------------------------
; Convenience functions for searching the screen for pixels of specific colors
;
; Author: ObiQuiet, quietjedi@gmail.com
; -------------------------

ColorSearch(pctX, pctY, rgb, pxSize := 5, variation := 0)  ; returns true if the color is found within a small area, 
		 ; (pctX, pctY) are the upper left corner expressed as a percentage of the window size
	{
	CoordMode, Pixel, Relative
	
	WinGetPos , X, Y, Width, Height, A
	PixelSearch, CPx, CPy, Width*pctX, Height*pctY, (Width*pctX)+pxSize, (Height*pctY)+pxSize, rgb, variation, Fast RGB
	
	; Box_Draw(Width*pctX, Height*pctY, pxSize, pxSize)
	; sleep 500
	return (ErrorLevel==0)
	}
	
ColorSearchHLine(pctX, pctY, pctWidth, rgb, variation := 0)	
	{
	CoordMode, Pixel, Relative
	WinGetPos , X, Y, Width, Height, A  		
	PixelSearch, CPx, CPy, Width*pctX, Height*pctY, Width*(pctX+pctWidth), 1+Height*pctY, rgb, variation, Fast RGB
	
	; Box_Draw(Width*pctX, Height*pctY, Width*pctWidth, 1)
	; sleep 500
	
	
	return (ErrorLevel==0)	
	}
	
ColorSearchVLine(pctX, pctY, pctHeight, rgb, variation := 0)	
	{
	CoordMode, Pixel, Relative
	WinGetPos , X, Y, Width, Height, A  		
	PixelSearch, CPx, CPy, Width*pctX, Height*pctY, 1+Width*pctX, Height*(pctY+pctHeight), rgb, variation, Fast RGB
	
	; Box_Draw(Width*pctX, Height*pctY, Width*pctWidth, 1)
	; sleep 500
	
	
	return (ErrorLevel==0)	
	}
	
DoubleColorSearch(x1, y1, width, rgb)
; Looks for the given color at two points, horizontally offset from each other
; This is more reliable than a single search when looking for e.g. a button/message/dialog against a variagated background
; and is faster than searching a rectangular area or for an image 
	{
	CoordMode, Pixel, Screen
	
	PixelGetColor, rgbAtXY, x1, y1, RGB
	fFound1 := (rgbAtXY=rgb)

	PixelGetColor, rgbAtXY, x1+width, y1, RGB
	fFound2 := (rgbAtXY=rgb)

	return (fFound1 and fFound2)
	}
	
QuadColorSearch(pctX1, pctY1, pctX2, pctY2, rgb)
	{
	CoordMode, Pixel, Relative
	WinGetPos , X, Y, Width, Height, Photo			
	PixelSearch, CPx, CPy, Width*pctX1, Height*pctY1, Width*pctX2, Height*pctY2, rgb, 0, Fast RGB
	
	if (ErrorLevel==0)
		{
		PixelGetColor, rgbAtXY, CPx+5, CPy, RGB
		result := (rgbAtXY==rgb)
		
		PixelGetColor, rgbAtXY, CPx-5, CPy, RGB
		result := result or (rgbAtXY==rgb)
		
		
		PixelGetColor, rgbAtXY, CPx+5, CPy+5, RGB
		result := result or (rgbAtXY==rgb)
		
		
		PixelGetColor, rgbAtXY, CPx-5, CPy-5, RGB
		result := result or (rgbAtXY==rgb)
		}
	else
		{
		result := false	
		}
	return result
	}