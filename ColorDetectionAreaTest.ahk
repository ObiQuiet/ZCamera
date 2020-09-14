#Warn
AddToGrid(A1, A2, incrA, B1, B2, incrB, ByRef listA, ByRef listB)
	{
	widthA := 0.03
	widthB := 0.03
	A := A1
	while (A <= A2)
		{
		B := B1
		while (B <= B2)
			{		
			if true ; or (A-A1 <= widthA) or (A2-A <= widthA) or (B-B1 <= widthB) or (B2-B <= widthB) 
				{
				listA.Push( A )
				listB.Push( B )
				}
			B += incrB
			}
		A += incrA
		}	
	}

listX := []
listY := []
AddToGrid(0.40, 0.55, 0.03, 0.45, 0.55, 0.05, listX, listY)



#include ZwiftColors.ahk
#include fnRandBetween.ahk
#include fnToolTips.ahk
#include classColorDetectionArea.ahk



DebugMsg(str)
	{
	OutputDebug, %str%
	CenterTooltip(str, 100)
	}

	

!v::
	
objSearchArea := new class_ColorDetectionArea(0.40, 0.45, 0.55, 0.55)
objLowerSearchArea := new class_ColorDetectionArea(0.40, 0.85, 0.60, 0.95)

DebugMsg("Start Test --------------------------")

resultPrev := true
result := true

loop 1000
	{
	resultPrev := result
	; result := objSearchArea.Search_Alg3(listX, listY, rgbOrange)
	result := objSearchArea.Search_Alg2() or objLowerSearchArea.Search_Alg2()
	; DebugMsg(objSearchArea.AverageTime() . ": " . result . ": " . objSearchArea.ScoreCurrent())
	DebugMsg(result . ": " . Format("{1:0.3f}",objSearchArea.ScoreCurrent()) . ": " . Format("{1:0.3f}",objLowerSearchArea.ScoreCurrent()))
	
	if (resultPrev != result)
		{
		SoundBeep
		}
	}

DebugMsg(objSearchArea.AverageTime() . ": " . result . ": " . objSearchArea.ScoreCurrent())

objSearchArea.Reset()


DebugMsg("Stop Test --------------------------")

return


!2::
StatusMsg("Color Test STOPPED")
Pause
; Pause stops timers from running

!3::
StatusMsg("Color Test RELOADING")
Sleep 3000
Reload