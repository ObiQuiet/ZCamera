; -------------------------
; Algorithm for detecting Zwift achievement banners (route completion, unlocks), independent of window size and screen resolution
;
; Author: ObiQuiet, quietjedi@gmail.com
; -------------------------

#include fnColorSearch.ahk

; the alternating light and blue Z's in the banner background, and the amount of variation in color we're ok with finding
rgbBlue1  := 0x3979C3
varBlue1  := 5

rgbBlue2  := 0x3d7dC7
varBlue2  := 5

; -----------------------------------------------------------------
; Combine multiple searches to come to one conclusion

CheckForAchievements()
	
	{
	global rgbBlue1
	global varBlue1

	global rgbBlue2
	global varBlue2

	msStart := A_TickCount    ; for measuring the time this function takes.   
							  ; Worst-case=common-case performance (no menus found) needs to be under 500ms, since that's the timer interval
	
	; look for the alternating light and blue Z's in the banner background
;	result := ColorSearchLine( 0.80, 0.85, 0.18, rbgLtBlue, varBlue)
;	and ColorSearchLine( 0.80, 0.85, 0.18, rbgLtBlue, varLtBlue)
		 ;  and ColorSearchLine( 0.80, 0.87, 0.05, rbgBlue, varBlue) and ColorSearchLine( 0.80, 0.87, 0.05, rbgLtBlue, varLtBlue))	
	
	  result := ColorSearch(0.85, 0.75, rgbBlue1, 300, varBlue1)
	        and ColorSearch(0.85, 0.75, rgbBlue2, 300, varBlue2)
	
	
	msEnd := A_TickCount-msStart
	ToolTip, %result% Achievement time: %msEnd%ms,A_ScreenWidth*0.5,A_ScreenHeight*0.5, 3
	
	return result
	
	}

