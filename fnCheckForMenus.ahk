; -------------------------
; Algorithm for detecting Zwift game menus, independent of window size and screen resolution
;
; Author: ObiQuiet, quietjedi@gmail.com
; -------------------------

#include fnColorSearch.ahk
#include ZwiftColors.ahk


; -----------------------------------------------------------------
; Search a grid of pixels for the colors used in menus and dialogs
; Method: 1. Iterate over the points in the grid.  
;         2. If a target color is found, check 20px to the right.
;         3. If the two pixels match assume we have a solid patch of the target color, and conclude there's a menu visible  

ColorSearchGrid(pctXStart, pctXEnd, pctXIncr, pctYStart, pctYEnd, pctYIncr, fDebug := 0)
	{
	global rgbOrange  
	global rgbBlue    
	global rgbBlack   
	global rgbDkGray  
	global rgbLtGray 
	global rgbVLtGray 
	; global rgbOffWhite
	global rgbWhite   

	
	CoordMode, Pixel, Relative

	WinGetPos , X, Y, Width, Height, ahk_exe ZwiftApp.exe			

	pctX := pctXStart
	pctY := pctYStart
	
	while (pctX <= pctXEnd)
		{
		pctY := pctYStart
		while (pctY <= pctYEnd)
			{
			;PixelGetColor, rgbAtXY, A_ScreenWidth*pctX, A_ScreenHeight*pctY, RGB
			PixelGetColor, rgbAtXY, Width*pctX, Height*pctY, RGB
			mx := A_ScreenWidth*pctX
			my := A_ScreenHeight*pctY
			if (fDebug)
				{
				MouseMove,%mx%, %my%
				sleep 100
				}
			
			if (rgbAtXY == rgbWhite) 
			or (rgbAtXY == rgbOrange) 
			or (rgbAtXY == rgbBlue) 
			or (rgbAtXY == rgbDkGray) 
			or (rgbAtXY == rgbLtGray)
			or (rgbAtXY == rgbVLtGray)			
			or (rgbAtXY == rgbBlack)
				{
				
				;PixelGetColor, rgbAtXY_Next, A_ScreenWidth*pctX+20, A_ScreenHeight*pctY, RGB
				PixelGetColor, rgbAtXY_Next, Width*pctX+20, Height*pctY, RGB
				
				if (rgbAtXY == rgbAtXY_Next)
					return true
				}
			pctY := pctY+pctYIncr
			}
		pctX := pctX+pctXIncr
		}
	return false
	}

; -----------------------------------------------------------------
; Combine multiple searches to come to one conclusion

CheckForMenus()
	
	{
	global rgbOrange
	global rgbOffWhite

	msStart := A_TickCount    ; for measuring the time this function takes.   
							  ; Worst-case=common-case performance (no menus found) needs to be under 500ms, since that's the timer interval
	
	result := ColorSearchLine( 0.40,             0.80, 0.30, rgbOrange)     ; check for the Route/Intersection selection prompts
		  or  ColorSearchGrid( 0.40, 0.60, 0.03, 0.85, 0.95, 0.03, false)	; grid at the bottom center, for Message dialog and buttons
		  or  ColorSearchGrid( 0.40, 0.55, 0.03, 0.45, 0.55, 0.05, false)	; grid at center, for all other menus and dialogs
		  or  ColorSearch(     0.92,             0.92,       rgbOffWhite)   ; group ride, pre-start Message window

		;  or  ColorSearchGrid( 0.30, 0.70, 0.10, 0.40, 0.50, 0.05, false)   ; grid at the center of the screen for most menus  
																			 ; two smaller grids is faster than one large one -- fewer total checks
	msEnd := A_TickCount-msStart
	; ToolTip, ColorSearchGrid time: %msEnd%ms,A_ScreenWidth*0.5,A_ScreenHeight*0.5, 3
	
	return result
	
	}

; ---------------------------------
; Alternate method - looks for specific colors at specific places.
; This technique depends on knowing the resolution and window placement ahead of time.

CheckForMenus1920x1080()
	{
	global rgbOrange  
	global rgbBlue    
	global rgbBlack   
	global rgbDkGray  
	global rgbLtGray  
	global rgbWhite   
	global rgbVLtGray 

	
	msStart := A_TickCount
	
	result := ColorSearchLine(760, 860, 1150-760, rgbOrange)  ; Direction choices at intersections
	or DoubleColorSearch(880,  1040,  140, rgbOrange) ; Settings
	or DoubleColorSearch(850,  1032,  200, rgbOrange) ; Garage
	or DoubleColorSearch(870,   912,  200, rgbOrange) ; Searching while Pairing
	or DoubleColorSearch(1050,  650,  200, rgbOrange) ; Are you Sure, no paired devices
	or DoubleColorSearch(840,   980,  240, rgbOrange) ; Badges
	or DoubleColorSearch(1100, 1022,  300, rgbOrange) ; End Ride Pause
	or DoubleColorSearch(845,   609,  240, rgbOrange) ; End Ride Confirmation
  ; or DoubleColorSearch(650,   900,  600, rgbBlack)  ; Message and Promo Code type in boxes
	or DoubleColorSearch(640,  1040,  100, rgbWhite)  ; Message and Promo
	or DoubleColorSearch(650,   130,  600, rgbBlack)  ; Paired Devices
  ; or DoubleColorSearch(500,    70, 1000, rgbBlack)  ; Training and Workout Reviews
	or DoubleColorSearch(500,   500, 1000, rgbBlue)   ; Loading screen
	or DoubleColorSearch(750,   850,   50, rgbWhite)  ; Log in
	or DoubleColorSearch(1200,  970,   50, rgbOrange) ; Select Route
	or DoubleColorSearch(600,   910,   20, rgbWhite)  ; Next Up
	or DoubleColorSearch(900,   990,   25, rgbBlue)   ; Blue pop up: view & gesture menu

	msEnd := A_TickCount-msStart
	;ToolTip, %msEnd%,A_ScreenWidth*0.5,A_ScreenHeight*0.5, 3

	return result
	}
	
	
CheckForMenus_Alg2()
	
	{
	global rgbOrange
	global rgbOffWhite
	global rgbWhite

	msStart := A_TickCount    ; for measuring the time this function takes.   
							  ; Worst-case performance (no menus found) needs to be under 500ms, since that's the timer interval
	
	
	result :=  QuadColorSearch(  0.40, 0.80,       0.60, 0.95, rgbWhite)
	; QuadColorSearch(  0.40, 0.40,       0.60, 0.60, rgbWhite)
	     ;  or QuadColorSearch(  0.40, 0.80,       0.60, 0.95, rgbOrange)
		 ;  or QuadColorSearch(  0.40, 0.80,       0.60, 0.95, rgbWhite)
		 ;  or  ColorSearchLine( 0.40,             0.80, 0.30, rgbOrange)     ; check for the Route/Intersection selection prompts
		;  or  ColorSearchGrid( 0.40, 0.60, 0.03, 0.85, 0.95, 0.03, false)	; grid at the bottom center, for Message dialog and buttons
		;  or  ColorSearchGrid( 0.40, 0.55, 0.03, 0.45, 0.55, 0.05, false)	; grid at center
		;  or  ColorSearch(     0.92,             0.92,       rgbOffWhite)   ; group ride, pre-start Message window

		;  or  ColorSearchGrid( 0.30, 0.70, 0.10, 0.40, 0.50, 0.05, false)   ; grid at the center of the screen for most menus  
																			 ; two smaller grids is faster than one large one -- fewer total checks
	msEnd := A_TickCount-msStart
	ToolTip, ColorSearchGrid time: %msEnd%ms,A_ScreenWidth*0.5,A_ScreenHeight*0.12, 3
	
	return result
	
	}
