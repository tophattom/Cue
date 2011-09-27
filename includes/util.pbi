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
	delay.f

	*afterCue.Cue
	List *followCues.Cue()
	
	startPos.f
	endPos.f
	
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

#FORMAT_VERSION = 1.0

#WAVEFORM_W = 680


Global NewList cueList.Cue()

Global gPlayState.i
Global *gCurrentCue.Cue
Global gCueAmount.i

Global gCueCounter.l

Global gEditor = #False

Global gControlsHidden = #False
Global gLastType = 0



Procedure AddCue(type.i,name.s="",vol=1,pan=0,id=0)
	LastElement(cueList())
	AddElement(cueList())
	
	gCueAmount + 1
	gCueCounter + 1
	
	With cueList()
		\cueType = type
		
		If name = ""
			\name = "Q" + Str(gCueCounter)
		Else
			\name = name
		EndIf

		\state = #STATE_STOPPED
		
		\startMode = #START_MANUAL
		\delay = 0
		
		\volume = 1
		\pan = 0
		
		If id = 0
			\id = gCueCounter
		Else
			\id = id
		EndIf
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

Procedure SaveCueList(path.s)
	If GetExtensionPart(path) = ""
		path = path + ".clf"
	EndIf
	
	If FileSize(path) > -1
		result = MessageRequester("Overwrite","File " + path + " already found. Do you want to overwrite it?",#PB_MessageRequester_YesNo)
		
		If result <> #PB_MessageRequester_Yes
			ProcedureReturn #False
		EndIf
	EndIf
	
	If CreateFile(0,path)
		;CLF
		WriteByte(0,67)
		WriteByte(0,76)
		WriteByte(0,70)
		
		;Tiedostoformaatin versio
		WriteFloat(0,#FORMAT_VERSION)
		
		;Cuejen lukum‰‰r‰
		WriteInteger(0,gCueAmount)
		
		;**** Data
		ForEach cueList()
			WriteByte(0,cueList()\cueType)
			
			WriteString(0,cueList()\name)
			WriteString(0,cueList()\desc)
			
			WriteString(0,cueList()\filePath)
			
			WriteByte(0,cueList()\startMode)
			WriteFloat(0,cueList()\delay)
			
			WriteInteger(0,cueList()\afterCue\id)
			
			;Cuen j‰lkeiset cuet
			WriteInteger(0,ListSize(cueList()\followCues()))
			ForEach cueList()\followCues()
				WriteInteger(0,cueList()\followCues()\id)
			Next
			
			WriteFloat(0,cueList()\startPos)
			WriteFloat(0,cueList()\endPos)
			
			WriteFloat(0,cueList()\fadeIn)
			WriteFloat(0,cueList()\fadeOut)
			
			WriteFloat(0,cueList()\volume)
			WriteFloat(0,cueList()\pan)
			
			;"Action cuet"
			For i = 0 To 5
				If cueList()\actionCues[i] <> 0
					WriteInteger(0,cueList()\actionCues[i]\id)
				Else
					WriteInteger(0,0)
				EndIf
				
				WriteByte(0,cueList()\actions[i])
			Next i
			
			WriteInteger(0,cueList()\id)
		Next
	EndIf
	
	ProcedureReturn #True
EndProcedure

Procedure LoadCueList(path.s)
	If GetExtensionPart(path) = ""
		path = path + ".clf"
	EndIf
	
	If ReadFile(0,path)
		tmp.s = Chr(ReadByte(0)) + Chr(ReadByte(0)) + Chr(ReadByte(0))
		
		If tmp <> "CLF"
			MessageRequester("Error","File type not supported!")
			ProcedureReturn #False
		EndIf
		
		version.f = ReadFloat(0)
		
		tmpAmount = ReadInteger(0)
		
		For i = 1 To tmpAmount
		Next i
	EndIf
EndProcedure

		
		
		
; IDE Options = PureBasic 4.50 (Windows - x86)
; CursorPosition = 261
; FirstLine = 176
; Folding = B+
; EnableXP