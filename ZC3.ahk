; -------------------------
; ZCamera 
; v0.9 BETA test
; Revision: 2020-08-23
; Author: ObiQuiet, quietjedi@gmail.com
; -------------------------
; Depends on AutoHotkey, from autohotkey.com

; -------------------------
; Limitations

#SingleInstance force

if not A_IsAdmin
	Run *RunAs "%A_ScriptFullPath%"

; --- performance enhancers, see https://www.autohotkey.com/docs/misc/Performance.htm
#NoEnv 
SetBatchLines -1
ListLines Off

#Warn  						; Enable warnings to assist with detecting common errors, like uninitialized variables
SendMode Input  			; Recommended by AHK
SetWorkingDir %A_ScriptDir% ; Location for include files

#InstallKeybdHook
#InstallMouseHook
#UseHook On

#include classAxisKey.ahk
#include fnTooltips.ahk
#include classWeightedChoices.ahk
#include fnCheckForMenus.ahk
#include fnRandBetween.ahk

; --------------------------------------------------------------------------------------------------
; Safe Keystroke Sending 
; --------------------------------------------------------------------------------------------------
;
SendToZwiftOnly(key)
	{
	global fOkToSendKeys
	if (fOkToSendKeys)
		Send %key%
	}

; --------------------------------------------------------------------------------------------------
; Initialization
; --------------------------------------------------------------------------------------------------
;
StatusMsg("ZCamera", A_ScreenWidth*0.1, 0)


; -----------------
; Initialize the exit delay used to close ZCamera when Zwift is not or is no longer running
msExitDelay := 3 * 60 * 1000
msExitTime := A_TickCount+msExitDelay


; ---------------------
; Prepare globals for the dectection of Zwift's in-game menus and whether or not the game is running and is the active window.
		
	fStopped := false
	fMenuFound := true
	fZwiftActive := false
	fZwiftExists := false
	fOkToSendKeys := false     ; when true, prevents ZCamera from sending any keystrokes that might interfere with menus or other programs
					   	   
	GoSub CheckForMenus
	SetTimer, CheckForMenus, 500, 0   
	
; ---------------------
; Initialize the views we'll be switching between, and create a set of weighted choices from which to select one at random
off := 0    ; synonyms used for clarity in MyOptions.txt
yes := 1
no  := 0

#include MyOptions.txt

	; If views are added or removed in the Options include file, add or remove them here too
	; Easier to just set their Odds to 0 in the Options file, though
	listViews := {	FirstPerson:FirstPerson	
					,Side:		 Side	  	
					,Helicopter: Helicopter  
					,Spectator:	 Spectator	
					,HeadOn:	 HeadOn	 	
					,RearWheel:	 RearWheel	
					,ThirdPerson:ThirdPerson	
					,Default:    Default		
					,Drone:		 Drone		
					,BirdsEye:	 BirdsEye	}	

	aryViewKeys := { FirstPerson:"{NumPad3}"
					,Side:		 "{NumPad4}"
					,Helicopter: "{NumPad8}"
					,Spectator:	 "{NumPad7}"
					,HeadOn:	 "{NumPad6}"
					,RearWheel:	 "{NumPad5}"
					,ThirdPerson:"{NumPad2}"
					,Default:    "{NumPad1}"
					,Drone:		 "{0}"
					,BirdsEye:	 "{NumPad9}" }	



	objWeightedChoices := new class_WeightedChoices()
	for view in listViews
		{
		objWeightedChoices.AddChoice(view, listViews[view]["Odds"])    ; the special value 'off' is treated as 0
		}

	strCurrentView := "..."
	SetTimer, ChangeView, -10000


; ---------------------
; Globals which will hold the drone axis objects when in drone mode
	ZAxis := "" 
	VAxis := "" 
	HAxis := ""
	msLastTick := ""


; ---------------------
; Prepare to take screen shots every so often.   Which views can have their pictures taken is defined in MyOptions.ahk
; Pictures are taken at roughly the intervals specified here.  Exactly when depends on which views are set to allow pictures
; which view is visible when the interval occurs, and some randomness 

    ; Values come from user's settings in the MyOptions.ahk include file
	minsFirstPic  := 	FirstPictureDelay  			; wait this many minutes before taking the first picture
	msPicInterval :=    PictureInterval*60*1000   
	numPicsToTake := 	NumberOfPictures   			; take no more than this many pictures.  Zero for no pictures at all.  
	fPicTimerStarted := false
 
	keyTakePic 	  := "{F10}"
	
	; The timer for taking pictures is stared in the main loop, once Zwift is active and ready
	
; ---------------------
; Disables things that would make ZCamera press keys
Stop()
	{
	SetTimer, ChangeView,  Off
	SetTimer, TakePicture, Off
	SetTimer, DroneTick,   Delete
	CleanUpAfterDroneMode()   ; in case we were in it
	}

	
; --------------------------------------------------------------------------------------------------
; Main Loop 
; --------------------------------------------------------------------------------------------------

loop
{
	sleep 500

	; --------------------------------
	; update status messages based on current state detected / created by timers 
	; see the image file states_kmap.png for a depiction of this logic
	
	if fStopped and (not fMenuFound) and fZwiftExists and fZwiftActive
		{
		StatusMsg("ZCamera STOPPED.  Hit 'c' to start")
		continue
		}
  
	else if (not fStopped) and (not fMenuFound) and fZwiftExists and fZwiftActive
		{				
		StatusMsg("ZCamera " . strCurrentView)
		
		; start the picture-taking clock for the first time
		if (not fPicTimerStarted)
			{
			msFirstPic := minsFirstPic * 60 * 1000
			SetTimer, TakePicture, -%msFirstPic%
			fPicTimerStarted := true
			}		
		}	
		
	else if fMenuFound and fZwiftExists and fZwiftActive
		{				
		StatusMsg("ZCamera AUTO-PAUSED")
		}
			
	else if fZwiftExists and (not fZwiftActive)   ; go into a waiting mode
		{
		StatusMsg("ZCamera is WAITING for the Zwift game window to be active")
		}
		
	else if (not fZwiftExists)   ;  update status to show exit delay
		{
		secsInTens := Round((msExitTime-A_TickCount)/10000)*10
		StatusMsg("Zwift game is not running, ZCamera will exit in " . secsInTens . " seconds")
		}
	
	; --------------------------------
	; other house keeping 
	if ((A_TimeIdleMouse > 1*60*1000) and fZwiftActive)
		{
		Mousemove, A_ScreenWidth, A_ScreenHeight*0.8     ; sending keys to Zwift causes the cursor to stay visible,
														 ; defeating the game's auto-hide, so move it away from center.
		}
	
	if fZwiftExists   ; reset the exit delay
		msExitTime := A_TickCount + msExitDelay 	
	
	if (A_TickCount > msExitTime)   ; exit delay has expired
		{
		ExitApp
		}
	
} 


; --------------------------------------------------------------------------------------------------
; ChangeView - invoked by timer
; --------------------------------------------------------------------------------------------------

ChangeView:
	; stopping Drone 
	if (strCurrentView == "Drone")
		{
		SetTimer, DroneTick, Delete
		CleanUpAfterDroneMode()
		}


	if (not fOkToSendKeys)
		{
		SetTimer ChangeView, -15000   ; do nothing, try again in 15s
		return
		}
	
	; Alternates between the PrimaryView (set in Views.ahk) and a random one of the others
	if (strCurrentView == PrimaryView)
		{ 
		strCurrentView := objWeightedChoices.PickOne()
		}
	else
		{
		strCurrentView := PrimaryView
		}

	SendToZwiftOnly(aryViewKeys[strCurrentView])	
	StatusMsg("ZCamera " . strCurrentView)

	
	
	msHoldFor := RandBetween(listViews[strCurrentView]["MinTime"]*1000, listViews[strCurrentView]["MaxTime"]*1000)
	SetTimer ChangeView, -%msHoldFor%	

	; starting Drone 
	if (strCurrentView == "Drone")
		{
		PrepBeforeDroneMode()
		SetTimer, DroneTick, 100
		}
	
	return


; --------------------------------------------------------------------------------------------------
; TakePicture - invoked by timer
; --------------------------------------------------------------------------------------------------

TakePicture:
	
	Random, rand, 1, 100
	If (rand <= 25) or (not fOkToSendKeys) or (not listViews[strCurrentView]["TakePic"])
		{
		SetTimer TakePicture, -5000    ; try again in 5s
		return
		}
	
	SendToZwiftOnly(keyTakePic)
	numPicsToTake--

	if (MsgWhenPictureTaken)
		CenterToolTip("ZCamera Picture Taken", 3000)

	if (numPicsToTake > 0)
		SetTimer TakePicture, -%msPicInterval%
	else
		SetTimer TakePicture, Delete
	
	return

; --------------------------------------------------------------------------------------------------
; CheckForMenus - invoked by timer
; --------------------------------------------------------------------------------------------------

CheckForMenus:
	
	fZwiftExists := WinExist("ahk_exe ZwiftApp.exe")
	fZwiftActive := WinActive("ahk_exe ZwiftApp.exe")
	
	if (fZwiftActive)
		fMenuFound := CheckForMenus()
	else
		fMenuFound := false
	
	fOkToSendKeys := (not fMenuFound) and (not fStopped) and (fZwiftActive) and (fZwiftExists)

	return


; --------------------------------------------------------------------------------------------------
; DroneTick orchestrates the drone's axis movements -- invoked by timer
; --------------------------------------------------------------------------------------------------
DroneTick:

		fKeyboardActiveSinceLastTick := A_TimeIdleKeyboard <= (A_TickCount - msLastTick) 

		temp := (A_TickCount - msLastTick) 

		;MsgBox %A_TimeIdleKeyboard% %temp%

		if (not fOkToSendKeys) or (fKeyboardActiveSinceLastTick)
			{
			strCurrentView := "..."
			CleanUpAfterDroneMode()
			SetTimer, DroneTick, Delete
			return
			}

		strState := (ZAxis.GetState()) . (HAxis.GetState()) . (VAxis.GetState())
		; ToolTip Tick %strState%,A_ScreenWidth*0.5,A_ScreenHeight*0.5, 2
		
		ZAxis.Tick(false)
		temp1 := ZAxis.GetPos()
		temp2 := VAxis.GetPos()
		;ToolTip ZPos %temp1%  VPos %temp2%,A_ScreenWidth*0.45,A_ScreenHeight*0.5, 3

		HAxis.Tick(ZAxis.GetPos() > 1700)
		VAxis.Tick(ZAxis.GetPos() > 1700)

		return


; --------------------------------------------------------------------------------------------------
; HotKeys
; --------------------------------------------------------------------------------------------------

#IfWinActive ahk_exe ZwiftApp.exe  
$d::
	if (not fOkToSendKeys) or (fStopped)	; ignore the d if a menu or dialog is open, and send it to the game instead
		{
		Send d
		return
		}
	else
		{
		strCurrentView := "Drone"	        ; manually invoked drone mode
		StatusMsg("ZCamera Drone")
		PrepBeforeDroneMode()
		SendToZwiftOnly(aryViewKeys[strCurrentView])	
		SetTimer, ChangeView, -60000	
		SetTimer, DroneTick, 100, 1
		}
	return

#IfWinActive

#IfWinActive ahk_exe ZwiftApp.exe  
$c::

	if (fMenuFound)				; ignore the c if a menu or dialog is open, and send it to the game instead
		{
		Send c
		return
		}

	fStopped := not fStopped            ; toggle manual halt to sending keystrokes
	
	if (fStopped)
		{
		StatusMsg("ZCamera STOPPED.  Hit 'c' to start")
		; stop all timer-triggered keyboard actions. The main loop will still run to report status
		Stop()
		}
	else
		{
		strCurrentView := "..."
		StatusMsg("ZCamera FirstPerson")
		Gosub ChangeView            ; this will switch to the Primary View and restart the ChangeView timer
		SetTimer, TakePicture, On
		}
 	return
#IfWinActive



!2::
StatusMsg("ZCamera STOPPED")
Pause
; Pause stops timers from running

!3::
StatusMsg("ZCamera RELOADING")
Sleep 3000
Reload


