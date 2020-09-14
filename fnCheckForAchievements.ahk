; -------------------------
; Algorithm for detecting Zwift achievement banners (route completion, unlocks), independent of window size and screen resolution
;
; Author: ObiQuiet, quietjedi@gmail.com
; -------------------------

#include fnColorSearch.ahk
#include ZwiftColors.ahk

; -----------------------------------------------------------------
; Combine multiple searches to come to one conclusion

CheckForAchievements()
	
	{
	global rgbBlue1, varBlue1
	global rgbBlue2, varBlue2
	
	global rgbOrange, rgbWhite

	msStart := A_TickCount    ; for measuring the time this function takes.   
							  ; Worst-case=common-case performance (no menus found) needs to be under 500ms, since that's the timer interval
	
	; look for the alternating light and blue Z's in the banner background	
	result := (   ColorSearch(0.85, 0.75, rgbBlue1, 150, varBlue1)   ; look for the blue Z's in the banner background	
	          and ColorSearch(0.85, 0.75, rgbBlue2, 150, varBlue2) ) ; this banner has some alpha-channel transparency, so variation is needed
		   or (   ColorSearch(0.00, 0.80, rgbWhite,  150, 0)		   ; the big white and orange Unlock banner
			  and ColorSearch(0.20, 0.80, rgbWhite,  150, 0)		  
			  and ColorSearch(0.80, 0.95, rgbOrange, 150, 0))
			  
	
	msEnd := A_TickCount-msStart
	;ToolTip, %A_TickCount% %result% Achievement time: %msEnd%ms,A_ScreenWidth*0.5,A_ScreenHeight*0.5, 3
	
	return result
	
	}

