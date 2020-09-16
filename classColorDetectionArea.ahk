class class_ColorDetectionArea
{
	pctX1 := 0
	pctY1 := 0
	pctX2 := 0
	pctY2 := 0

	score := 0
	msTotal := 0
	countSearches := 0
	msWorstCase := 0
	msBestCase  := 9223372036854775807   ; maxint

__New(pctX1_in, pctY1_in, pctX2_in, pctY2_in)
	{
	this.pctX1 := pctX1_in
	this.pctY1 := pctY1_in
	this.pctX2 := pctX2_in
	this.pctY2 := pctY2_in
	}
	
Search_Alg1(rgbColorToFind)
	{
	global winTitle
;	DebugMsg("in Search_Alg1")
	
	
;	CoordMode, Pixel, Client
	WinGetPos , X, Y, Width, Height, %winTitle%			

	
	msStart := A_TickCount


	found := false
	pxSearchStartX := Width*this.pctX1
	pxSearchStartY := Height*this.pctY1
	
	pxSearchEndX   := pxSearchStartX
	pxSearchEndY   := Height*this.pctY2

	while (not found) 
		{
		
	;	DebugMsg(pxSearchStartX . ", " . pxSearchStartY . " / " .   pxSearchEndX  . "," . pxSearchEndY)
		
		PixelSearch, CPx, CPy, pxSearchStartX, pxSearchStartY, pxSearchEndX, pxSearchEndY, rgbColorToFind, 0, Fast RGB
		if (CPx == "")
			{
			break   ; done searching
			}
	;	DebugMsg(CPx . ", " . CPy)
		; check nearby pixels
		PixelGetColor, rgbAtXY, CPx+20, CPy, RGB
				
		if (rgbAtXY == rgbColorToFind) 
			{
			found := true
			break
			}
			
		; if the nearby pixel test failed, start searching from where we left off	
		pxSearchStartX := CPx
		pxSearchStartY := CPy+1
		
		}
	
	
	msElapsed        := A_TickCount-msStart
	this.msTotal     += msElapsed
	this.msWorstCase := max(this.msWorstCase, msElapsed)
	this.msBestCase  := min(this.msBestCase, msElapsed)
	this.countSearches++
	
	return found
	}

Search_Alg2(strTargets)
	{
	global rgbOrange
	global winTitle
	
	CoordMode, Pixel, Relative
	WinGetPos , X, Y, Width, Height, %winTitle%			

	msStart := A_TickCount

	X := RandBetween(Width*this.pctX1,  Width*this.pctX2,  false)
	Y := RandBetween(Height*this.pctY1, Height*this.pctY2, false)

	PixelGetColor, rgbAtXY, X,    Y, RGB
	
	found1 := false
	found2 := false
	found3 := false
	
#Warn UseUnsetLocal, Off 	
	if InStr(strTargets, rgbAtXY)
		{
		found1 := true
		}
	
	if (found1)
		{
		PixelGetColor, rgbAtXY_plus, X+20, Y, RGB
		found2 := (rgbAtXY_plus == rgbAtXY)
		}
		
	if (found1 and not found2)
		{
		PixelGetColor, rgbAtXY_minus, X-20, Y, RGB
		found3 := (rgbAtXY_minus == rgbAtXY)
		}
	
	
	if (found1 and (found2 or found3))
		{
	  ;  OutputDebug, Found %rgbAtXY% at %X% %Y% 
	 ;Mousemove, %X%, %Y%
		this.score := min(1, this.score+0.1)
		}
	else
		{
		this.score := max(0, this.score*0.9)
		}
	
	msElapsed        := A_TickCount-msStart
	this.msTotal     += msElapsed
	this.msWorstCase := max(this.msWorstCase, msElapsed)
	this.msBestCase  := min(this.msBestCase, msElapsed)
	this.countSearches++
	
	return this.score >= 0.3
	}	

Search_Alg3(ByRef listPointsX, ByRef listPointsY, rgbColorToFind)
	{
	global winTitle
	
	CoordMode, Pixel, Relative
	WinGetPos , X, Y, Width, Height, %winTitle%			
	
	msStart := A_TickCount
	
	found := false
	
	for x in listPointsX
		{

		PixelGetColor, rgbAtXY, Width*listPointsX[A_Index], Height*listPointsY[A_Index], RGB
		if (rgbAtXY == rgbColorToFind) 
			{
			PixelGetColor, rgbAtXY_adjacent, Width*listPointsX[A_Index]+20, Height*listPointsY[A_Index], RGB
			if (rgbAtXY == rgbAtXY_Next)
				{
				found := true
				break
				}
			}
		}	
	
	msElapsed        := A_TickCount-msStart
	this.msTotal     += msElapsed
	this.msWorstCase := max(this.msWorstCase, msElapsed)
	this.msBestCase  := min(this.msBestCase, msElapsed)
	this.countSearches++
	
	return found
	}


BlueTint()
	{
	global winTitle
	
	CoordMode, Pixel, Relative
	WinGetPos , X, Y, Width, Height, %winTitle%			

	biasBlue := 0

	msStart := A_TickCount

	loop 10
		{
		X := RandBetween(Width*this.pctX1,  Width*this.pctX2,  false)
		Y := RandBetween(Height*this.pctY1, Height*this.pctY2, false)

		PixelGetColor, rgbAtXY, X,    Y, RGB

		numBlue  := (rgbAtXY & 0xFF)
		numGreen := ((rgbAtXY & 0xFF00) >> 8)
		numRed   := ((rgbAtXY & 0xFF0000) >> 16)

		biasBlue += max(0, (numBlue - max(numGreen, numRed)))

		}

	biasBlue := biasBlue / 10
			
	msElapsed        := A_TickCount-msStart
	this.msTotal     += msElapsed
	this.msWorstCase := max(this.msWorstCase, msElapsed)
	this.msBestCase  := min(this.msBestCase, msElapsed)
	this.countSearches++
	
	return biasBlue
	}



Reset()
	{
	this.msTotal := 0
	this.countSearches := 0
	this.msWorstCase := 0
	this.msBestCase  := 9223372036854775807   ; maxint
	}
	
AverageTime()
	{
	return this.msTotal / this.countSearches
	}
	
BestTime()
	{
	return this.msBestCase
	}
	
WorstTime()
	{
	return this.WorstCase
	}
	
ScoreCurrent()
	{
	return this.score
	}
	
}
