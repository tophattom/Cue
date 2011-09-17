Structure Cue
	cueType.i
	
	name.s
	desc.s
	
	file.i
	filePath.s
	
	state.i
	
	startMode.i
	delay.i

	*afterCue.Cue

	startTime.l
	duration.l
	
	fadeIn.i
	fadeOut.i
	
	volume.i
	pan.i
	
	List *followCues.Cue()
	
	id.l
EndStructure

Enumeration
	#TYPE_AUDIO
	#TYPE_VIDEO
	#TYPE_EVENT
	#TYPE_CHANGE
	
	#STATE_STOPPED
	#STATE_PLAYING
	#STATE_PAUSED
	#STATE_DONE
	
	#START_MANUAL
	#START_AFTER_START
	#START_AFTER_END
	#START_HOTKEY
EndEnumeration


Global NewList cueList.Cue()

Global gPlayState.i
Global *gCurrentCue.Cue
Global gCueCount.i

Global gCueCounter.l



Procedure AddCue(type.i)
	LastElement(cueList())
	AddElement(cueList())
	
	gCueCount + 1
	gCueCounter + 1
	
	With cueList()
		\cueType = type
		
		Select type
			Case #TYPE_AUDIO
				\name = "(Audio)"
			Case #TYPE_VIDEO
				\name = "(Video)"
			Case #TYPE_CHANGE
				\name = "(Change)"
			Case #TYPE_EVENT
				\name = "(Event)"
		EndSelect

		\state = #STATE_STOPPED
		
		\startMode = #START_MANUAL
		\delay = 0
		
		\volume = 100
		\pan = 0
		
		\id = gCueCounter
	EndWith
	
	ProcedureReturn @cueList()
EndProcedure

Procedure GetCueById(id.l)
	ForEach cueList()
		If cueList()\id = id
			ProcedureReturn @cueList()
		EndIf
	Next
	
	ProcedureReturn #False
EndProcedure

; IDE Options = PureBasic 4.50 (Windows - x86)
; CursorPosition = 7
; Folding = -
; EnableXP