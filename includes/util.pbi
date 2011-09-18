Structure Cue
	cueType.i
	
	name.s
	desc.s
	
	stream.i
	filePath.s
	waveform.i
	length.i
	
	state.i
	
	startMode.i
	delay.i

	*afterCue.Cue
	
	startPos.d
	endPos.d
	playTime.i
	
	startTime.l
	pauseTime.l
	duration.l
	
	fadeIn.f
	fadeOut.f
	
	volume.f
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
		
		\name = "Q" + Str(gCueCounter)

		\state = #STATE_STOPPED
		
		\startMode = #START_MANUAL
		\delay = 0
		
		\volume = 1
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

Procedure.s SecondsToString(value)
	mins.s = Str(Int(value / 60))
	tmp = value % 60
	
	If tmp < 10
		secs.s = "0" + Str(tmp)
	Else
		secs.s = Str(tmp)
	EndIf
	
	ProcedureReturn mins + ":" + secs
EndProcedure

Procedure StringToSeconds(text.s)
	mins = Val(StringField(text,1,":"))
	secs = ValD(StringField(text,2,":"))
	
	ProcedureReturn mins * 60 + secs
EndProcedure

; IDE Options = PureBasic 4.50 (Windows - x86)
; CursorPosition = 81
; FirstLine = 37
; Folding = x
; EnableXP