Structure Effect
	handle.l
	StructureUnion
		revParam.BASS_DX8_REVERB
		eqParam.BASS_DX8_PARAMEQ
	EndStructureUnion
	
	
	type.i
	priority.i
	
	gadgets.l[17]
	
	active.i
EndStructure

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
	
	startTime.f
	pauseTime.f
	duration.l
	
	fadeIn.f
	fadeOut.f
	
	volume.f
	pan.f
	
	*actionCues.Cue[6]
	actions.i[6]
	
	List effects.Effect()

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
	#EVENT_RELEASE
EndEnumeration

;Asetusvakiot
#SETTINGS = 1
Enumeration
	#SETTING_RELATIVE
EndEnumeration

#FORMAT_VERSION = 2.0


;Efektien s‰‰timet
Enumeration
	#EGADGET_FRAME
	#EGADGET_UP
	#EGADGET_DOWN
	#EGADGET_DELETE
	#EGADGET_ACTIVE
EndEnumeration

;Kuvien vakiot
Enumeration
	#DeleteImg
	#UpImg
	#DownImg
	#PlayImg
	#PauseImg
	#StopImg
EndEnumeration

#WAVEFORM_W = 660


Global NewList cueList.Cue()
Global Dim gSettings(#SETTINGS - 1)

Global gPlayState.i
Global *gCurrentCue.Cue
Global gCueAmount.i

Global gCueCounter.l

Global gEditor = #False

Global gControlsHidden = #False
Global gLastType = 0

Global gSavePath.s = ""


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

Procedure.s SecondsToString(value.f)
	mins.s = Str(Int(value / 60))
	tmp.f = (value / 60.0 - ValF(mins)) * 60.0
	
	If tmp < 10
		secs.s = "0" + StrF(tmp,2)
	Else
		secs.s = StrF(tmp,2)
	EndIf
	
	ProcedureReturn mins + ":" + secs
EndProcedure

Procedure.f StringToSeconds(text.s)
	mins.f = Val(StringField(text,1,":"))
	secs.f = ValF(StringField(text,2,":"))

	ProcedureReturn mins * 60.0 + secs
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

Procedure Min(a,b)
	If a - b <= 0
		ProcedureReturn a
	Else
		ProcedureReturn b
	EndIf
EndProcedure

Procedure SaveCueList(path.s,check=1)
	If GetExtensionPart(path) = ""
		path = path + ".clf"
	EndIf
	
	If check = 1
		If FileSize(path) > -1
			result = MessageRequester("Overwrite?","File " + path + " already found. Do you want to overwrite it?",#PB_MessageRequester_YesNo)
			
			If result <> #PB_MessageRequester_Yes
				ProcedureReturn #False
			EndIf
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
			
			WriteByte(0,cueList()\looped)
			WriteFloat(0,cueList()\loopStart)
			WriteFloat(0,cueList()\loopEnd)
			WriteInteger(0,cueList()\loopCount)
			
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
		Debug "Amount: " + Str(tmpAmount)
		
		gCueAmount = 0
		gCueCounter = 0
		
		high = 0
		;Luetaan idt ja luodaan cuet
		For i = 1 To tmpAmount
			AddElement(cueList())
			cueList()\id = ReadInteger(0)
			
			If cueList()\id > high
				high = cueList()\id
			EndIf
			
			cueList()\state = #STATE_STOPPED
			
			gCueAmount + 1
		Next i
		
		gCueCounter = high
		
		Debug ListSize(cueList())
		
		;Luetaan cuejen tiedot
		ForEach cueList()
			With cueList()
				\cueType = ReadByte(0)
				Debug "Type: " + Str(\cueType)
				
				\name = ReadString(0)
				\desc = ReadString(0)
				
				\filePath = ReadString(0)
				If \cueType = #TYPE_AUDIO
					If FileSize(\filePath) = -1
						result = MessageRequester("File not found","File " + \filePath + " not found!" + Chr(10) + "Do you want to locate it?",#PB_MessageRequester_YesNo)
						
						If result = #PB_MessageRequester_Yes
				    		pattern.s = "Audio files (*.mp3,*.wav,*.ogg,*.aiff) |*.mp3;*.wav;*.ogg;*.aiff"
				    		
				    		path.s = OpenFileRequester("Select file","",pattern,0)
				    		
				    		If path
				    			\filePath = path
				    			LoadCueStream(@cueList(),\filePath)
				    		EndIf
				    	EndIf
				    Else
				    	LoadCueStream(@cueList(),\filePath)
				    EndIf
				EndIf
				
				\startMode = ReadByte(0)
				\delay = ReadFloat(0)
				
				tmpId = ReadInteger(0)
				If tmpId <> 0
					\afterCue = GetCueById(ReadInteger(0))
				EndIf
					
				
				tmpA = ReadInteger(0)
				*prev.Cue = @cueList()
				For k = 1 To tmpA
					AddElement(*prev\followCues())
					*prev\followCues() = GetCueById(ReadInteger(0))
				Next k
				ChangeCurrentElement(cueList(),*prev)
				
				\startPos = ReadFloat(0)
				\endPos = ReadFloat(0)
				
				\looped = ReadByte(0)
				\loopStart = ReadFloat(0)
				\loopEnd = ReadFloat(0)
				\loopStart = ReadFloat(0)
				
				\fadeIn = ReadFloat(0)
				\fadeOut = ReadFloat(0)
				
				\volume = ReadFloat(0)
				\pan = ReadFloat(0)
				
				For k = 0 To 5
					tmpId = ReadInteger(0)
					If tmpId <> 0
						*prev\actionCues[k] = GetCueById(tmpId)
					EndIf
					
					*prev\actions[k] = ReadByte(0)
				Next k
				ChangeCurrentElement(cueList(),*prev)
			EndWith
		Next
		
		CloseFile(0)
	Else
		MessageRequester("Error","Couldn't open file " + path + "!")
		ProcedureReturn #False
	EndIf
	
	ProcedureReturn #True
EndProcedure

Procedure ClearCueList()
	ForEach cueList()
		If cueList()\stream <> 0
			BASS_StreamFree(cueList()\stream)
		EndIf
		
		If cueList()\waveform <> 0
			FreeImage(cueList()\waveform)
		EndIf
	Next
	
	ClearList(cueList())
EndProcedure

Procedure CreateProjectFolder(path.s)
	If FileSize(path) = -1
		CreateDirectory(path)	
	EndIf
	
	CreateDirectory(path + "Sound\")
	
	ForEach cueList()
		If cueList()\filePath <> ""
			Select cueList()\cueType
				Case #TYPE_AUDIO
					newPath.s = path + "Sound\" + GetFilePart(cueList()\filePath)
					CopyFile(cueList()\filePath,newPath)
			EndSelect
			
			cueList()\filePath = newPath
		EndIf
	Next
	
	gSavePath = OpenFileRequester("Save cue list",path,"Cue List files (*.clf) |*.clf",0)
			
	If gSavePath <> ""
		SaveCueList(gSavePath)
	EndIf
EndProcedure

Procedure AddCueEffect(*cue.Cue,eType.i)
	If *cue\stream <> 0
		amount = ListSize(*cue\effects())
		If amount > 0
			ForEach *cue\effects()
				*cue\effects()\priority + 1
				
				BASS_ChannelRemoveFX(*cue\stream,*cue\effects()\handle)
				*cue\effects()\handle = BASS_ChannelSetFX(*cue\stream,*cue\effects()\type,*cue\effects()\priority)
				
				Select *cue\effects()\type
					Case #BASS_FX_DX8_REVERB
						*params = @*cue\effects()\revParam
					Case #BASS_FX_DX8_PARAMEQ
						*params = @*cue\effects()\eqParam
				EndSelect
						
				BASS_FXSetParameters(*cue\effects()\handle,*params)
			Next
		EndIf
				
				
		AddElement(*cue\effects())
		amount + 1
		
		*cue\effects()\priority = 0
		*cue\effects()\type = eType
		*cue\effects()\active = #True
		*cue\effects()\handle = BASS_ChannelSetFX(*cue\stream,eType,0)
		
		;S‰‰timet
		tmpY = 40 + (amount - 1) * 115
		Select eType
			Case #BASS_FX_DX8_REVERB
				text.s = "Reverb"
				
				*cue\effects()\gadgets[5] = TrackBarGadget(#PB_Any,75, tmpY + 40,170,30,0,960)		;Input gain [-96.0,0.0]
				*cue\effects()\gadgets[6] = TrackBarGadget(#PB_Any,75, tmpY + 75,170,30,0,960) 		;Reverb mix [-96.0,0.0]
				*cue\effects()\gadgets[7] = TrackBarGadget(#PB_Any,390, tmpY + 40,170,30,1,3000) 	;Reverb time [1,3000]
				*cue\effects()\gadgets[8] = TrackBarGadget(#PB_Any,390, tmpY + 75,170,30,1,999)		;High freq rvrb time [0.001,0.999]
				
				*cue\effects()\gadgets[9] = StringGadget(#PB_Any,250,tmpY + 40,40,20,"",#PB_String_ReadOnly)
				*cue\effects()\gadgets[10] = StringGadget(#PB_Any,250,tmpY + 75,40,20,"",#PB_String_ReadOnly)
				*cue\effects()\gadgets[11] = StringGadget(#PB_Any,565,tmpY + 40,40,20,"",#PB_String_ReadOnly)
				*cue\effects()\gadgets[12] = StringGadget(#PB_Any,565,tmpY + 75,40,20,"",#PB_String_ReadOnly)
				
				*cue\effects()\gadgets[13] = TextGadget(#PB_Any,10,tmpY + 40,60,30,"Input gain (dB):")
				*cue\effects()\gadgets[14] = TextGadget(#PB_Any,10,tmpY + 75,60,30,"Reverb mix (dB):")
				*cue\effects()\gadgets[15] = TextGadget(#PB_Any,330,tmpY + 40,60,30,"Reverb time (ms):")
				*cue\effects()\gadgets[16] = TextGadget(#PB_Any,330,tmpY + 75,60,30,"High freq time ratio:")
				
				*cue\effects()\revParam\fReverbTime = 1000
				*cue\effects()\revParam\fHighFreqRTRatio = 0.001
				BASS_FXSetParameters(*cue\effects()\handle,@*cue\effects()\revParam)
				
				SetGadgetState(*cue\effects()\gadgets[5],*cue\effects()\revParam\fInGain * 10 + 960)
				SetGadgetState(*cue\effects()\gadgets[6],*cue\effects()\revParam\fReverbMix * 10 + 960)
				SetGadgetState(*cue\effects()\gadgets[7],*cue\effects()\revParam\fReverbTime)
				SetGadgetState(*cue\effects()\gadgets[8],*cue\effects()\revParam\fHighFreqRTRatio * 1000)
				
				SetGadgetText(*cue\effects()\gadgets[9],StrF(*cue\effects()\revParam\fInGain,1))
				SetGadgetText(*cue\effects()\gadgets[10],StrF(*cue\effects()\revParam\fReverbMix,1))
				SetGadgetText(*cue\effects()\gadgets[11],Str(*cue\effects()\revParam\fReverbTime))
				SetGadgetText(*cue\effects()\gadgets[12],StrF(*cue\effects()\revParam\fHighFreqRTRatio,3))
				
			Case #BASS_FX_DX8_PARAMEQ
				text.s = "Parametic EQ"
				
				info.BASS_CHANNELINFO
				BASS_ChannelGetInfo(*cue\stream,@info.BASS_CHANNELINFO)
				
				*cue\effects()\gadgets[5] = TrackBarGadget(#PB_Any,75, tmpY + 40,170,30,80,Min(16000,info\freq / 3))	;Center
				*cue\effects()\gadgets[6] = TrackBarGadget(#PB_Any,75, tmpY + 75,170,30,1,36) 							;Bandwidth [1,36]
				*cue\effects()\gadgets[7] = TrackBarGadget(#PB_Any,390, tmpY + 40,170,30,0,300) 							;Gain [-15,15]
				
				*cue\effects()\gadgets[9] = StringGadget(#PB_Any,250,tmpY + 40,40,20,"",#PB_String_ReadOnly)
				*cue\effects()\gadgets[10] = StringGadget(#PB_Any,250,tmpY + 75,40,20,"",#PB_String_ReadOnly)
				*cue\effects()\gadgets[11] = StringGadget(#PB_Any,565,tmpY + 40,40,20,"",#PB_String_ReadOnly)
				
				*cue\effects()\gadgets[13] = TextGadget(#PB_Any,10,tmpY + 40,60,30,"Center (Hz):")
				*cue\effects()\gadgets[14] = TextGadget(#PB_Any,10,tmpY + 75,60,30,"Bandwidth (semitones):")
				*cue\effects()\gadgets[15] = TextGadget(#PB_Any,330,tmpY + 40,60,30,"Gain (dB):")
				
				*cue\effects()\eqParam\fBandwidth = 12
				*cue\effects()\eqParam\fCenter = 80
				*cue\effects()\eqParam\fGain = 0
				BASS_FXSetParameters(*cue\effects()\handle,@*cue\effects()\eqParam)
				
				SetGadgetState(*cue\effects()\gadgets[5],*cue\effects()\eqParam\fCenter)
				SetGadgetState(*cue\effects()\gadgets[6],*cue\effects()\eqParam\fBandwidth)
				SetGadgetState(*cue\effects()\gadgets[7],*cue\effects()\eqParam\fGain * 10 + 150)
				
				SetGadgetText(*cue\effects()\gadgets[9],Str(*cue\effects()\eqParam\fCenter))
				SetGadgetText(*cue\effects()\gadgets[10],Str(*cue\effects()\eqParam\fBandwidth))
				SetGadgetText(*cue\effects()\gadgets[11],StrF(*cue\effects()\eqParam\fGain,1))
		EndSelect
		
		*cue\effects()\gadgets[#EGADGET_FRAME] = Frame3DGadget(#PB_Any,5,tmpY,660,115,text)
		*cue\effects()\gadgets[#EGADGET_UP] = ButtonImageGadget(#PB_Any,625,tmpY + 10,30,30,ImageID(#UpImg))
		*cue\effects()\gadgets[#EGADGET_DOWN] = ButtonImageGadget(#PB_Any,625,tmpY + 45,30,30,ImageID(#DownImg))
		*cue\effects()\gadgets[#EGADGET_DELETE] = ButtonImageGadget(#PB_Any,625,tmpy + 80,30,30,ImageID(#DeleteImg))
		*cue\effects()\gadgets[#EGADGET_ACTIVE] = CheckBoxGadget(#PB_Any,10,tmpY + 15,60,20,"Active")
		SetGadgetState(*cue\effects()\gadgets[#EGADGET_ACTIVE],1)
	EndIf
EndProcedure

Procedure DeleteCueEffect(*cue.Cue,*effect.Effect)
	amount = ListSize(*cue\effects()) - 2
	
	ChangeCurrentElement(*cue\effects(),*effect)
	
	While NextElement(*cue\effects()) <> 0
		*cue\effects()\priority = *cue\effects()\priority - 1

		For i = 0 To 16
			If *cue\effects()\gadgets[i] <> 0
				ResizeGadget(*cue\effects()\gadgets[i],#PB_Ignore,GadgetY(*cue\effects()\gadgets[i]) - 115,#PB_Ignore,#PB_Ignore)
			EndIf
		Next i
	Wend
	
	ForEach *cue\effects()
		If *effect = @*cue\effects()
			BASS_ChannelRemoveFX(*cue\stream,*cue\effects()\handle)
			For i = 0 To 16
				FreeGadget(*cue\effects()\gadgets[i])
			Next i
			
			DeleteElement(*cue\effects())
			Break
		EndIf
	Next
EndProcedure

Procedure DisableCueEffect(*cue.Cue,*effect.Effect,value)
	If value = 0
		BASS_ChannelRemoveFX(*cue\stream,*effect\handle)
		*effect\handle = 0
		*effect\active = #False
	Else
		If *effect\handle = 0
			*effect\handle = BASS_ChannelSetFX(*cue\stream,*effect\type,*effect\priority)
			
			Select *effect\type
				Case #BASS_FX_DX8_REVERB
					*params = @*effect\revParam
				Case #BASS_FX_DX8_PARAMEQ
					*params = @*effect\eqParam
			EndSelect
			BASS_FXSetParameters(*effect\handle,*params)
		EndIf
	EndIf
EndProcedure




; IDE Options = PureBasic 4.50 (Windows - x86)
; CursorPosition = 578
; FirstLine = 195
; Folding = AA+
; EnableXP