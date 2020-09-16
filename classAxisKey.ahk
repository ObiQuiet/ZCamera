
#include fnRandBetween.ahk

SendDroneKey(key)
	{
	global fOkToSendKeys
	if (fOkToSendKeys)
		{
		Send %key%
		; ToolTip Key %strSeq%,A_ScreenWidth*0.01,A_ScreenHeight*0.2, 7
		; sleep 1000
		}
	}

PrepBeforeDroneMode()
	{
	global ZAxis
	global VAxis
	global HAxis
	global msLastTick
	
	; strAxisIn, keyPosIn, keyNegIn,                msMinDurationIn, msMaxDurationIn, msRestIn, msDirectionRestIn, msStartPos
	ZAxis := new class_AxisKey("Z", "+", "-", 		  600, 2500, 2000, 8000, 1900, 9000)
	VAxis := new class_AxisKey("V", "up", "down", 	 1000, 3500, 4000, 6000, 200)
	HAxis := new class_AxisKey("H", "left", "right", 1000, 3500, 4000, 6000, 1800)
	
	msLastTick := A_TickCount+4000
	}

CleanUpAfterDroneMode()
	{
	global ZAxis
	global VAxis
	global HAxis
	
	ZAxis := ""  ; delete these objects until the next time
	VAxis := "" 
	HAxis := ""
	; Send {Down}  ; FIXME corrects spurious view menu

	; ensure all are keys up at the end of the flight
	Send {Left up}{Right up}{Up up}{Down up}{+ up}{- up}	
	}


class class_AxisKey
{
	strAxis := ""
	keyPos := ""
	keyNeg := ""
    fKeyIsDown := false
	msMinDuration := 0 	
	msMaxDuration := 0
	msRestIn 	  := 0
	msDirectionRest := 0
    msPosition  := 0
    msNextKeyDown :=0
	msNextKeyUp   := 0
	msDuration := 0
	direction := 1

	__New(strAxisIn, keyPosIn, keyNegIn, msMinDurationIn, msMaxDurationIn, msRestIn, msDirectionRestIn, msStartPos, msFirstMove := 0)
    {
		this.keyPos 		:= keyPosIn
		this.keyNeg 		:= keyNegIn
		this.msMinDuration 	:= msMinDurationIn
		this.msMaxDuration 	:= msMaxDurationIn
		this.msRest 		:=  msRestIn
		this.msDirectionRest := msDirectionRestIn
		this.msPosition 	:= msStartPos
		this.strAxis		:= strAxisIn

        if (msFirstMove == 0)
			{
			this.direction	:= (RandBetween(0,10) > 5) ? 1 : -1
			this.msNextKeyDown := A_TickCount+RandBetween(100, 1000)
			this.msNextKeyUp   := this.NextKeyDown+RandBetween(this.msMinDuration, this.msMaxDuration)
			}
		else if (msFirstMove > 0)
			{
			this.direction	:= 1
			this.msNextKeyDown := A_TickCount+100
			this.msNextKeyUp   := this.NextKeyDown+msFirstMove
			}
		else if (msFirstMove < 0)
			{
			this.direction	:= -1
			this.msNextKeyDown := A_TickCount+100
			this.msNextKeyUp   := this.NextKeyDown+abs(msFirstMove)
			}
		
		this.fKeyIsDown := false
		
	}
	
	__Delete()
    {
	; unpress the keys
	SendDroneKey("{" . (this.keyPos) . " up}")
	SendDroneKey("{" . (this.keyNeg) . " up}")
    }
	
	GetPos()
		{
		return this.msPosition
		}
	
	GetState()
		{
		if (this.fKeyIsDown and this.direction<0)
			{
			return "v"
			}
		else if (this.fKeyIsDown)
			{
			return "^"
			}
		else return "-"
		}
	
Tick(fLimit = false)
    {
		if (((A_TickCount >= this.msNextKeyUp) and this.fKeyIsDown) or (fLimit and this.fKeyIsDown and (A_TickCount-this.msNextKeyDown > 300)))
			{
			;CenterToolTip("Key Up " . this.strAxis, 500)
	
			SendDroneKey("{" . (this.keyPos) . " up}")
			SendDroneKey("{" . (this.keyNeg) . " up}")
			
			this.msPosition :=  min(2000, max(0, this.msPosition + this.direction * this.msDuration))
			
			if (RandBetween(0,10) > 5) ; or (this.msPosition = 0) or (this.msPosition = 2000)
				{
				; change in direction
				if  (this.msPosition = 0)
					{ this.direction := 1 
					}
				else if (this.msPosition = 2000)
					{ this.direction := -1
					}
				else this.direction := -this.direction
				this.msNextKeyDown := A_TickCount+RandBetween(this.msDirectionRest, this.msDirectionRest+3000)
				}
			else
				{
				this.msNextKeyDown := A_TickCount+RandBetween(this.msRest, this.msRest+3000)
				}
				
			if (fLimit)
				{ 
				this.msDuration := 300
				}
			else
				{
				this.msDuration := RandBetween(this.msMinDuration, this.msMaxDuration)
				}
				
			this.msNextKeyUp   := this.msNextKeyDown+this.msDuration
			;CenterToolTip("Next up" . this.msNextKeyUp, 5000)
			this.fKeyIsDown := false
			}
	
        else if ( (A_TickCount >= this.msNextKeyDown) and not this.fKeyIsDown)
			{
			;CenterToolTip("Key Down " . this.strAxis, 500)
	
			if (this.direction > 0)
				{
				SendDroneKey("{" . (this.keyPos) . " down}")
				}
			else
				{
				SendDroneKey("{" . (this.keyNeg) . " down}")
				}
			this.fKeyIsDown := true
			}			
	    }

	}
	


