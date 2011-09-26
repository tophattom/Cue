Structure Cue
	cueType.i
	
	name.s
	desc.s
	
	stream.l
	filePath.s
	waveform.i
	length.i
	
	state.i
	
	startMode.i
	delay.i

	*afterCue.Cue
	List *followCues.Cue()
	
	startPos.d
	endPos.d
	playTime.i
	
	startTime.l
	pauseTime.l
	duration.l
	
	fadeIn.f
	fadeOut.f
	
	volume.f
	pan.f
	
	*actionCues.Cue[6]
	actions.i[6]

	id.l
EndStructure

Enumeration 1
	#TYPE_AUDIO
	#TYPE_VIDEO
	#TYPE_EVENT
	#TYPE_CHANGE
	
	#STATE_STOPPED
	#STATE_WAITING
	#STATE_WAITING_END
	#STATE_PLAYING
	#STATE_PAUSED
	#STATE_DONE
	#STATE_FADING_OUT
	#STATE_FADING_IN
	
	#START_MANUAL
	#START_AFTER_START
	#START_AFTER_END
	#START_HOTKEY
	
	#EVENT_FADE_OUT
	#EVENT_STOP
EndEnumeration

#WAVEFORM_W = 680


Global NewList cueList.Cue()

Global gPlayState.i
Global *gCurrentCue.Cue
Global gCueAmount.i

Global gCueCounter.l

Global gEditor = #False

Global gControlsHidden = #False
Global gLastType = 0



Procedure AddCue(type.i)
	LastElement(cueList())
	AddElement(cueList())
	
	gCueAmount + 1
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

Procedure GetCueListIndex(*cue.Cue)
	ForEach cueList()
		If @cueList() = *cue
			ProcedureReturn ListIndex(cueList())
		EndIf
	Next
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

Procedure DeleteCue(*cue.Cue)
	GetCueListIndex(*cue)
	DeleteElement(cueList())
	gCueAmount - 1
EndProcedure

Procedure OnOff(value)
	If value = 0
		ProcedureReturn 1
	Else
		ProcedureReturn 0
	EndIf
EndProcedure

; IDE Options = PureBasic 4.50 (Windows - x86)
; CursorPosition = 77
; FirstLine = 37
; Folding = A-
; EnableXP