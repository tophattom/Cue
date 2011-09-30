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
	
	loopStart.f
	loopEnd.f
	loopCount.i
	loopsDone.i
	loopHandle.l
	looped.i
	
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

Procedure LoadCueStream(*cue.Cue,path.s)
	If *cue\stream <> 0
    	BASS_StreamFree(*cue\stream)
    EndIf
    
    *cue\stream = BASS_StreamCreateFile(0,@path,0,0,0)
    
    *cue\length = BASS_ChannelBytes2Seconds(*cue\stream,BASS_ChannelGetLength(*cue\stream,#BASS_POS_BYTE))
    
    *cue\startPos = 0
    *cue\endPos = *cue\length
    *cue\loopEnd = *cue\length
    
    ;****Aallon piirto
    tmpStream.l = BASS_StreamCreateFile(0,@path,0,0,#BASS_STREAM_DECODE |#BASS_SAMPLE_FLOAT)
    length.l = BASS_ChannelGetLength(tmpStream,#BASS_POS_BYTE)
    Dim buffer.f(length / 4)
    
    BASS_ChannelGetData(tmpStream,@buffer(0), length)
    
    amount = ArraySize(buffer())
    s = amount / #WAVEFORM_W
    pos = 0
    
    If *cue\waveform = 0
    	*cue\waveform = CreateImage(#PB_Any,#WAVEFORM_W,120)
    EndIf
    
    StartDrawing(ImageOutput(*cue\waveform))
    Box(0,0,#WAVEFORM_W,120,RGB(64,64,64))
    For i = 0 To #WAVEFORM_W - 1
    	maxValue.f = 0.0
    	minValue.f = 1000.0
    	For k = (i * s) To (i * s + s)
    		If buffer(k) > maxValue
    			maxValue = buffer(k)
    		EndIf
    	Next k
    	
    	LineXY(i,60,i,60 + 55 * (maxValue),RGB(200,200,250))
    	LineXY(i,60,i,60 - 55 * (maxValue),RGB(200,200,250))
    Next i
    StopDrawing()
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
		result = MessageRequester("Overwrite?","File " + path + " already found. Do you want to overwrite it?",#PB_MessageRequester_YesNo)
		
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
		;Kirjoitetaan id:t alkuun
		ForEach cueList()
			WriteInteger(0,cueList()\id)
		Next
		
		;Muu data
		ForEach cueList()
			WriteByte(0,cueList()\cueType)
			
			WriteStringN(0,cueList()\name)
			WriteStringN(0,cueList()\desc)
			
			WriteStringN(0,cueList()\filePath)
			
			WriteByte(0,cueList()\startMode)
			WriteFloat(0,cueList()\delay)
			
			If cueList()\afterCue <> 0
				WriteInteger(0,cueList()\afterCue\id)
			Else
				WriteInteger(0,0)
			EndIf
			
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
		Next
		
		CloseFile(0)
	EndIf

	ProcedureReturn #True
EndProcedure

Procedure LoadCueList(path.s)
	If GetExtensionPart(path) = ""
		path = path + ".clf"
	EndIf
	
	If ReadFile(0,path)
		;Onko oikea tiedostotunniste
		tmp.s = Chr(ReadByte(0)) + Chr(ReadByte(0)) + Chr(ReadByte(0))
		
		If tmp <> "CLF"
			MessageRequester("Error","File type not supported!")
			CloseFile(0)
			ProcedureReturn #False
		EndIf
		
		;Tiedostoformaatin versio
		version.f = ReadFloat(0)
		
		;Cuejen m‰‰r‰
		tmpAmount = ReadInteger(0)
		
		;Luetaan idt ja luodaan cuet
		For i = 1 To tmpAmount
			AddElement(cueList())
			cueList()\id = ReadInteger(0)
			
			cueList()\state = #STATE_STOPPED
		Next i
		
		;Luetaan cuejen tiedot
		ForEach cueList()
			With cueList()
				\cueType = ReadByte(0)
				
				\name = ReadString(0)
				\desc = ReadString(0)
				
				\filePath = ReadString(0)
				LoadCueStream(@cueList(),\filePath)
				
				\startMode = ReadByte(0)
				\delay = ReadFloat(0)
				
				tmpId = ReadInteger(0)
				If tmpId <> 0
					\afterCue = GetCueById(ReadInteger(0))
				EndIf
					
				
				tmpA = ReadInteger(0)
				For k = 1 To tmpA
					AddElement(\followCues())
					\followCues() = GetCueById(ReadInteger(0))
				Next k
				
				\startPos = ReadFloat(0)
				\endPos = ReadFloat(0)
				
				\fadeIn = ReadFloat(0)
				\fadeOut = ReadFloat(0)
				
				\volume = ReadFloat(0)
				\pan = ReadFloat(0)
				
				For k = 0 To 5
					tmpId = ReadInteger(0)
					If tmpId <> 0
						\actionCues[i] = GetCueById(tmpId)
					EndIf
					
					\actions[i] = ReadByte(0)
				Next k
			EndWith
		Next
		
		CloseFile(0)
	Else
		MessageRequester("Error","Couldn't open file " + path + "!")
		ProcedureReturn #False
	EndIf
	
	ProcedureReturn #True
EndProcedure

		
		
		
; IDE Options = PureBasic 4.50 (Windows - x86)
; CursorPosition = 134
; FirstLine = 60
; Folding = Cw
; EnableXP