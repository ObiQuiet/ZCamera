; -------------------------
; Functions to make AHK tooltips easier to use
; Author: ObiQuiet, quietjedi@gmail.com
; -------------------------

CoordMode, Tooltip, Screen

CenterToolTip(strText, msDuration)
	{
	ToolTip, %strText%,A_ScreenWidth/2,A_ScreenHeight/3, 2
	sleep %msDuration%		
	ToolTip ,, 2
	}

CountdownToolTip(strText, msDuration)
	{
	timeOut := A_TickCount+msDuration
	while A_TickCount < timeOut
		{
		secsLeft := ceil((timeOut - A_TickCount) / 1000)
		ToolTip, %strText% %secsLeft%,A_ScreenWidth/2,A_ScreenHeight/3, 2
		sleep 10000
		}
	ToolTip ,, 2
	}
	
StaticToolTip(strText, pctX, pctY)
	{
	ToolTip, %strText%,A_ScreenWidth*pctX,A_ScreenHeight*pctY, 1
	}
	
StatusMsg(strMsg, pxNewX := "", pxNewY := "")
	{
	static pxX := A_ScreenWidth/2
	static pxY := A_ScreenHeight/3
	static strLastMsg := ""
	
	if pxNewX is Number
		pxX := pxNewX

	if pxNewY is Number
		pxY := pxNewY	
	
	if (strMsg != strLastMsg)     ; prevents flickering when the message hasn't changed
		{
		ToolTip, %strMsg%, pxX, pxY , 2
		strLastMsg := strMsg
		}
	}