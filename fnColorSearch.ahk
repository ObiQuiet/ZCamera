; -------------------------
; Convenience functions for searching the screen for pixels of specific colors
;
; Author: ObiQuiet, quietjedi@gmail.com
; -------------------------

ColorSearch(pctX, pctY, rgb)  ; returns true if the color is found within a small area, 
							  ; expressed as a (pctX, pctY) are the upper left corner expressed as a percentage of the window size
	{
	CoordMode, Pixel, Relative
	CoordMode, Mouse, Relative
	
	WinGetPos , X, Y, Width, Height, ahk_exe ZwiftApp.exe
	PixelSearch, CPx, CPy, Width*pctX, Height*pctY, (Width*pctX)+5, (Height*pctY)+5, rgb, 0, Fast RGB
	
	return (ErrorLevel==0)
	}
	
ColorSearchLine(pctX, pctY, pctWidth, rgb)	
	{
	CoordMode, Pixel, Relative
	WinGetPos , X, Y, Width, Height, ahk_exe ZwiftApp.exe			
	PixelSearch, CPx, CPy, Width*pctX, Height*pctY, Width*(pctX+pctWidth), Height*pctY, rgb, 0, Fast RGB
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