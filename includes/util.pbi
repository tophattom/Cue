;-Effect structure
;{
Structure Effect
	handle.l
	StructureUnion
		revParam.BASS_DX8_REVERB
		eqParam.BASS_DX8_PARAMEQ
	EndStructureUnion
	
	type.i
	priority.i
	
	gadgets.l[17]
	
	pluginPath.s
	
	active.i
	defaultActive.i
	
	name.s
	id.i
EndStructure
;}

;-Cue structure
;{
Structure Cue
	cueType.i
	
	name.s
	desc.s
	
	stream.l
	
	filePath.s
	absolutePath.s
	relativePath.s
	
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
	*actionEffects.Effect[6]
	
	List effects.Effect()

	id.l
EndStructure
;}

;-Recent file structure
;{
Structure RecentFile
	path.s
	mItem.i
EndStructure
;}

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
	#EVENT_EFFECT_ON
	#EVENT_EFFECT_OFF
EndEnumeration

;Asetusvakiot
#SETTINGS = 1	;Listalle
Enumeration
	#SETTING_RELATIVE
EndEnumeration

#MAX_RECENT = 5
#APP_SETTINGS = 2
Enumeration
	#SETTING_ADEVICE
	#SETTING_FONTSIZE
EndEnumeration

#FORMAT_VERSION = 3.7


;Efektien s‰‰timet
Enumeration
	#EGADGET_FRAME
	#EGADGET_UP
	#EGADGET_DOWN
	#EGADGET_DELETE
	#EGADGET_ACTIVE
EndEnumeration

;Onko efekti VST plugin
#EFFECT_VST = 9

;Kuvien vakiot
Enumeration
	#DeleteImg
	#UpImg
	#DownImg
	#PlayImg
	#PauseImg
	#StopImg
	#ExplorerImg
	#RefreshImg
EndEnumeration

;- Gadget Constants
;{
Enumeration 1
  #Frame3D_0
  #PlayButton
  #PauseButton
  #StopButton
  #CueList
  #Frame3D_2
  #EditorButton
  #SettingsButton
  
  #EditorList
  #AddAudio
  #AddChange
  #AddEvent
  #AddVideo
  #ExplorerButton
  #MasterSlider
  #Text_2
  #CueNameField
  #Text_3
  #CueDescField
  #Text_4
  #CueFileField
  #Text_6
  #OpenCueFile
  #Image_1
  #ModeSelect
  #Text_8
  #Text_9
  #LengthField
  #StartPos
  #EndPos
  #Text_10
  #Text_11
  #Text_12
  #Text_13
  #FadeIn
  #FadeOut
  #Text_14
  #Text_15
  #VolumeSlider
  #PanSlider
  #CueVolume
  #CuePan
  #UpButton
  #DownButton
  #DeleteButton
  #Text_16
  #CueSelect
  #Text_17
  #StartDelay
  #WaveImg
  #Text_18
  #Text_19
  #Text_20
  #ChangeDur
  #EditorPlay
  #EditorPause
  #EditorStop
  #BlankWave
  #Text_21
  #Text_22
  #Text_23
  #LoopStart
  #LoopEnd
  #LoopCount
  #LoopEnable
  #Position
  #Text_24
  #Text_26
  
  #EditorTabs
  
  #AddEffect
  #Text_25
  #EffectType
  #EffectPlay
  #EffectPause
  #EffectStop
  
  #CheckRelative
  #SettingsOK
  
  #FileBrowser
  #RefreshBrowser
  
  #AboutOk
  #AboutText
  #AboutLink
  
  #LoadBar
  
  #PrefAFrame
  #PrefIFrame
  #Text_27
  #SelectADevice
  #Text_28
  #FontSize
  #PrefOk
  #PrefCancel
EndEnumeration
;}

;- Menu constants
;{
Enumeration
  #MenuBar
EndEnumeration

Enumeration	  
  #Recent1
  #Recent2
  #Recent3
  #Recent4
  #Recent5
  
  #MenuNew
  #MenuOpen
  #MenuSave
  #MenuSaveAs
  #MenuImport
  #MenuPref
  #MenuExit
  #MenuAbout

  #PlaySc
  
  #DeleteSc
  
  #ExplorerSc
EndEnumeration
;}

#WAVEFORM_W = 660


Global NewList cueList.Cue()
Global NewList *gSelection.Cue()

Global Dim gListSettings(#SETTINGS - 1)
Global Dim gAppSettings(#APP_SETTINGS)	;Ohjelman asetukset

Global Dim gRecentFiles.s(#MAX_RECENT - 1)	;Viimeisimm‰t tiedostot

Global gPlayState.i
Global *gCurrentCue.Cue
Global gCueAmount.i

Global gCueCounter.l
Global gEffectCounter.i

Global gEditor = #False

Global gControlsHidden = #False
Global gLastType = 0

Global gSavePath.s = ""
Global gSaved

Global gLoadThread
Global gLoadMutex = CreateMutex()

Global gCuesLoaded

Global gLastHash

Global gCueListFont

Declare DeleteCueEffect(*cue.Cue,*effect.Effect)
Declare.s RelativePath(absolutePath.s,relativeTo.s)
Declare StopCue(*cue.Cue)

Procedure SaveAppSettings()
	If FileSize("settings.ini") = -1
		CreatePreferences("settings.ini")
	EndIf
	
	If OpenPreferences("settings.ini")
		PreferenceGroup("General")
		WritePreferenceInteger("Audio device",gAppSettings(#SETTING_ADEVICE))
		WritePreferenceInteger("Font size",gAppSettings(#SETTING_FONTSIZE))
		
		PreferenceGroup("Recent files")
		For i = 1 To #MAX_RECENT
			WritePreferenceString("File " + Str(i),gRecentFiles(i - 1))
		Next i
	EndIf
EndProcedure

Procedure SetDefaultSettings()
	gAppSettings(#SETTING_ADEVICE) = 1
	gAppSettings(#SETTING_FONTSIZE) = 8
	
	SaveAppSettings()
EndProcedure

Procedure LoadAppSettings()
	If FileSize("settings.ini") > -1
		If OpenPreferences("settings.ini")
			PreferenceGroup("General")
			gAppSettings(#SETTING_ADEVICE) = ReadPreferenceInteger("Audio device",1)
			BASS_SetDevice(gAppSettings(#SETTING_ADEVICE))
			
			gAppSettings(#SETTING_FONTSIZE) = ReadPreferenceInteger("Font size",8)
			gCueListFont = LoadFont(#PB_Any,"Microsoft Sans Serif",gAppSettings(#SETTING_FONTSIZE))
			
			PreferenceGroup("Recent files")
			ExaminePreferenceKeys()
			For i = 0 To #MAX_RECENT - 1
				NextPreferenceKey()
				gRecentFiles(i) = PreferenceKeyValue()
			Next i
			
			ClosePreferences()
		EndIf
	Else
		SetDefaultSettings()
	EndIf
EndProcedure

Procedure AddRecentFile(path.s)
	start = #MAX_RECENT - 1
	
	For i = 0 To #MAX_RECENT - 1
		If gRecentFiles(i) = path
			start = i
			Break
		EndIf
	Next i
	
	For i = start - 1 To 0 Step -1
		gRecentFiles(i + 1) = gRecentFiles(i)
		SetMenuItemText(#MenuBar,i + 1,GetFilePart(gRecentFiles(i)))
	Next i
	
	gRecentFiles(0) = path
	SetMenuItemText(#MenuBar,0,GetFilePart(gRecentFiles(0)))
	
	SaveAppSettings()
EndProcedure

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

Procedure LoadCueStream2(*cue.Cue)
	LockMutex(gLoadMutex)
	
	path.s = *cue\filePath
	
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
   	StopDrawing()
    
    For i = 0 To #WAVEFORM_W - 1
    	StartDrawing(ImageOutput(*cue\waveform))
    	maxValue.f = 0.0
    	For k = (i * s) To (i * s + s)
    		If buffer(k) > maxValue
    			maxValue = buffer(k)
    		EndIf
    	Next k
    	
    	LineXY(i,60,i,60 + 55 * (maxValue),RGB(200,200,250))
    	LineXY(i,60,i,60 - 55 * (maxValue),RGB(200,200,250))
    	StopDrawing()
    	
    	If *gCurrentCue = *cue
    		SetGadgetState(#WaveImg,ImageID(*cue\waveform))
    	EndIf
    Next i

    UnlockMutex(gLoadMutex)
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
	If ListSize(*cue\effects()) > 0
		ForEach *cue\effects()
			DeleteCueEffect(*cue,@*cue\effects())
		Next
	EndIf
	
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

Procedure Min(a.f,b.f)
	If a - b <= 0
		ProcedureReturn a
	Else
		ProcedureReturn b
	EndIf
EndProcedure

Procedure Max(a.f,b.f)
	If a - b <= 0
		ProcedureReturn b
	Else
		ProcedureReturn a
	EndIf
EndProcedure

Procedure AddCueEffect(*cue.Cue,eType.i,*revParams.BASS_DX8_REVERB=0,*eqParams.BASS_DX8_PARAMEQ=0,active=1,id=-1,path.s="")
	If *cue\stream <> 0
		amount = ListSize(*cue\effects())
		
		If amount > 0
			ForEach *cue\effects()
				*cue\effects()\priority + 1
				
				If *cue\effects()\type <> #EFFECT_VST
					BASS_ChannelRemoveFX(*cue\stream,*cue\effects()\handle)
					*cue\effects()\handle = BASS_ChannelSetFX(*cue\stream,*cue\effects()\type,*cue\effects()\priority)
					
					Select *cue\effects()\type
						Case #BASS_FX_DX8_REVERB
							*params = @*cue\effects()\revParam
						Case #BASS_FX_DX8_PARAMEQ
							*params = @*cue\effects()\eqParam
					EndSelect
							
					BASS_FXSetParameters(*cue\effects()\handle,*params)
				Else
					count = BASS_VST_GetParamCount(*cue\effects()\handle)
					Dim tmp.f(count - 1)
					For i = 0 To count - 1
						tmp(i) = BASS_VST_GetParam(*cue\effects()\handle,i)
					Next i
					
					BASS_VST_ChannelRemoveDSP(*cue\stream,*cue\effects()\handle)
					*cue\effects()\handle = BASS_VST_ChannelSetDSP(*cue\stream,@*cue\effects()\pluginPath,0,*cue\effects()\priority)
					BASS_VST_EmbedEditor(*cue\effects()\handle,WindowID(*cue\effects()\gadgets[5]))
					
					For i = 0 To count - 1
						BASS_VST_SetParam(*cue\effects()\handle,i,tmp(i))
					Next i
					
					FreeArray(tmp())
				EndIf
				
			Next
		EndIf
		
		If eType = #EFFECT_VST And path = ""
			path.s = OpenFileRequester("Select plugin file","","DLL files | *.dll",0)
			If path = ""
				ProcedureReturn #False
			EndIf
		ElseIf eType = #EFFECT_VST And path <> ""
			If FileSize(path) = -1
				result = MessageRequester("File not found","Plugin file " + path + " not found!" + Chr(10) + "Do you want to locate it?",#PB_MessageRequester_YesNo)
				
				If result = #PB_MessageRequester_Yes
					path.s = OpenFileRequester("Select plugin file","","DLL files | *.dll",0)
					If path = ""
						ProcedureReturn #False
					EndIf
				Else
					ProcedureReturn #False
				EndIf
			EndIf
		EndIf
		
		
			
		AddElement(*cue\effects())
		amount + 1
		gEffectCounter + 1
		
		*cue\effects()\priority = 0
		*cue\effects()\type = eType
		*cue\effects()\active = active
		*cue\effects()\defaultActive = active
		If id = -1
			*cue\effects()\id = gEffectCounter
		Else
			*cue\effects()\id = id
		EndIf
		If eType <> #EFFECT_VST
			*cue\effects()\handle = BASS_ChannelSetFX(*cue\stream,eType,0)
		Else
			*cue\effects()\handle = BASS_VST_ChannelSetDSP(*cue\stream,@path,0,0)
			*cue\effects()\pluginPath = path
		EndIf
		
		
		;S‰‰timet
		OpenGadgetList(#EditorTabs,1)
		tmpY = 40 + (amount - 1) * 115
		Select eType
			Case #BASS_FX_DX8_REVERB
				*cue\effects()\name = "Reverb"
				text.s = "Reverb " + Str(gEffectCounter)
				
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
				
				If *revParams = 0
					*cue\effects()\revParam\fReverbTime = 1000
					*cue\effects()\revParam\fHighFreqRTRatio = 0.001
				Else
					*cue\effects()\revParam\fReverbTime = *revParams\fReverbTime
					*cue\effects()\revParam\fInGain = *revParams\fInGain
					*cue\effects()\revParam\fReverbMix = *revParams\fReverbMix
					*cue\effects()\revParam\fHighFreqRTRatio = *revParams\fHighFreqRTRatio
				EndIf
				
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
				*cue\effects()\name = "Parametric EQ"
				text.s = "Parametic EQ " + Str(gEffectCounter)
				
				info.BASS_CHANNELINFO
				BASS_ChannelGetInfo(*cue\stream,@info.BASS_CHANNELINFO)
				
				*cue\effects()\gadgets[5] = TrackBarGadget(#PB_Any,75, tmpY + 40,170,30,80,Min(16000,info\freq / 3))	;Center
				*cue\effects()\gadgets[6] = TrackBarGadget(#PB_Any,75, tmpY + 75,170,30,1,360) 							;Bandwidth [1,36]
				*cue\effects()\gadgets[7] = TrackBarGadget(#PB_Any,390, tmpY + 40,170,30,0,300) 							;Gain [-15,15]
				
				*cue\effects()\gadgets[9] = StringGadget(#PB_Any,250,tmpY + 40,40,20,"",#PB_String_ReadOnly)
				*cue\effects()\gadgets[10] = StringGadget(#PB_Any,250,tmpY + 75,40,20,"",#PB_String_ReadOnly)
				*cue\effects()\gadgets[11] = StringGadget(#PB_Any,565,tmpY + 40,40,20,"",#PB_String_ReadOnly)
				
				*cue\effects()\gadgets[13] = TextGadget(#PB_Any,10,tmpY + 40,60,30,"Center (Hz):")
				*cue\effects()\gadgets[14] = TextGadget(#PB_Any,10,tmpY + 75,60,30,"Bandwidth (semitones):")
				*cue\effects()\gadgets[15] = TextGadget(#PB_Any,330,tmpY + 40,60,30,"Gain (dB):")
				
				If *eqParams = 0
					*cue\effects()\eqParam\fBandwidth = 12.0
					*cue\effects()\eqParam\fCenter = 80
					*cue\effects()\eqParam\fGain = 0
				Else
					*cue\effects()\eqParam\fBandwidth = *eqParams\fBandwidth
					*cue\effects()\eqParam\fCenter = *eqParams\fCenter
					*cue\effects()\eqParam\fGain = *eqParams\fGain
				EndIf
				
				BASS_FXSetParameters(*cue\effects()\handle,@*cue\effects()\eqParam)
				
				SetGadgetState(*cue\effects()\gadgets[5],*cue\effects()\eqParam\fCenter)
				SetGadgetState(*cue\effects()\gadgets[6],*cue\effects()\eqParam\fBandwidth * 10)
				SetGadgetState(*cue\effects()\gadgets[7],*cue\effects()\eqParam\fGain * 10 + 150)
				
				SetGadgetText(*cue\effects()\gadgets[9],Str(*cue\effects()\eqParam\fCenter))
				SetGadgetText(*cue\effects()\gadgets[10],StrF(*cue\effects()\eqParam\fBandwidth,1))
				SetGadgetText(*cue\effects()\gadgets[11],StrF(*cue\effects()\eqParam\fGain,1))
			Case #EFFECT_VST
				vstInfo.BASS_VST_INFO
				BASS_VST_GetInfo(*cue\effects()\handle,@vstInfo)
				
				*cue\effects()\name = vstInfo\effectName
				text.s = vstInfo\effectName + " " + Str(gEffectCounter)
				
				If vstInfo\hasEditor = 1
					*cue\effects()\gadgets[5] = OpenWindow(#PB_Any,0,0,vstInfo\editorWidth,vstInfo\editorHeight,*cue\name + " - " + vstInfo\effectName,#PB_Window_ScreenCentered | #PB_Window_SystemMenu)
					BASS_VST_EmbedEditor(*cue\effects()\handle,WindowID(*cue\effects()\gadgets[5]))
					
					OpenGadgetList(#EditorTabs,1)
					
					*cue\effects()\gadgets[6] = ButtonGadget(#PB_Any,10,tmpY + 40,70,30,"Open editor")
				EndIf		
		EndSelect
		
		*cue\effects()\gadgets[#EGADGET_FRAME] = Frame3DGadget(#PB_Any,5,tmpY,660,115,text)
		*cue\effects()\gadgets[#EGADGET_UP] = ButtonImageGadget(#PB_Any,625,tmpY + 10,30,30,ImageID(#UpImg))
		*cue\effects()\gadgets[#EGADGET_DOWN] = ButtonImageGadget(#PB_Any,625,tmpY + 45,30,30,ImageID(#DownImg))
		*cue\effects()\gadgets[#EGADGET_DELETE] = ButtonImageGadget(#PB_Any,625,tmpy + 80,30,30,ImageID(#DeleteImg))
		*cue\effects()\gadgets[#EGADGET_ACTIVE] = CheckBoxGadget(#PB_Any,10,tmpY + 15,60,20,"Active")
		SetGadgetState(*cue\effects()\gadgets[#EGADGET_ACTIVE],1)
		
		ProcedureReturn #True
		
		CloseGadgetList()
	EndIf
EndProcedure

Procedure DeleteCueEffect(*cue.Cue,*effect.Effect)
	amount = ListSize(*cue\effects()) - 2
	
	ChangeCurrentElement(*cue\effects(),*effect)
	
	While NextElement(*cue\effects()) <> 0
		*cue\effects()\priority = *cue\effects()\priority - 1
		
		If *cue\effects()\type <> #EFFECT_VST
			BASS_ChannelRemoveFX(*cue\stream,*cue\effects()\handle)
			*cue\effects()\handle = BASS_ChannelSetFX(*cue\stream,*cue\effects()\type,*cue\effects()\priority)
			
			Select *cue\effects()\type
				Case #BASS_FX_DX8_REVERB
					*params = @*cue\effects()\revParam
				Case #BASS_FX_DX8_PARAMEQ
					*params = @*cue\effects()\eqParam
			EndSelect
							
			BASS_FXSetParameters(*cue\effects()\handle,*params)
		Else
			count = BASS_VST_GetParamCount(*cue\effects()\handle)
			Dim tmp.f(count - 1)
			For i = 0 To count - 1
				tmp(i) = BASS_VST_GetParam(*cue\effects()\handle,i)
			Next i
				
			BASS_VST_ChannelRemoveDSP(*cue\stream,*cue\effects()\handle)
			*cue\effects()\handle = BASS_VST_ChannelSetDSP(*cue\stream,@*cue\effects()\pluginPath,0,*cue\effects()\priority)
			BASS_VST_EmbedEditor(*cue\effects()\handle,WindowID(*cue\effects()\gadgets[5]))
				
			For i = 0 To count - 1
				BASS_VST_SetParam(*cue\effects()\handle,i,tmp(i))
			Next i
			
			FreeArray(tmp())
		EndIf

		For i = 0 To 16
			If *cue\effects()\gadgets[i] <> 0
				If Not IsWindow(*cue\effects()\gadgets[i])
					ResizeGadget(*cue\effects()\gadgets[i],#PB_Ignore,GadgetY(*cue\effects()\gadgets[i]) - 115,#PB_Ignore,#PB_Ignore)
				EndIf
			EndIf
		Next i
	Wend
	
	ForEach *cue\effects()
		If *effect = @*cue\effects()
			If *effect\type <> #EFFECT_VST
				BASS_ChannelRemoveFX(*cue\stream,*cue\effects()\handle)
			Else
				BASS_VST_ChannelRemoveDSP(*cue\stream,*cue\effects()\handle)
				CloseWindow(*cue\effects()\gadgets[5])
			EndIf
			
			For i = 0 To 16
				If Not IsWindow(*cue\effects()\gadgets[i])
					FreeGadget(*cue\effects()\gadgets[i])
				EndIf
			Next i
			
			DeleteElement(*cue\effects())
			Break
		EndIf
	Next
EndProcedure

Procedure DisableCueEffect(*cue.Cue,*effect.Effect,value)
	If value = 1
		If *effect\type <> #EFFECT_VST
			BASS_ChannelRemoveFX(*cue\stream,*effect\handle)
			*effect\handle = 0
		Else
			BASS_VST_SetBypass(*effect\handle,1)
		EndIf
		
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
		
		If *effect\type = #EFFECT_VST
			BASS_VST_SetBypass(*effect\handle,0)
		EndIf
		
		*effect\active = #True
	EndIf
EndProcedure

Procedure GetEffectById(id.l)
	ForEach cueList()
		ForEach cueList()\effects()
			If cueList()\effects()\id = id
				ProcedureReturn @cueList()\effects()
			EndIf
		Next
	Next
EndProcedure

Procedure SaveCueList(path.s,check=1)
	ForEach cueList()
		StopCue(@cueList())
	Next
	
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
		WriteByte(0,67)	;C
		WriteByte(0,76)	;L
		WriteByte(0,70)	;F
		
		;Tiedostoformaatin versio
		WriteFloat(0,#FORMAT_VERSION)
		
		;Listan asetukset
		WriteInteger(0,#SETTINGS)
		For i = 0 To #SETTINGS - 1
			WriteInteger(0, gListSettings(i))
		Next i
		
		;Cuejen lukum‰‰r‰
		WriteInteger(0,gCueAmount)
		
		;**** Data
		;Kirjoitetaan id:t alkuksi, jotta niiden perusteella voidaan hakea osoitteet
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
			Debug "Follow cues (" + cueList()\name + "): " + Str(ListSize(cueList()\followCues()))
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
			
			;Efektit
			eAmount = ListSize(cueList()\effects())
			Debug "Effect amount:" + Str(eAmount)
			WriteInteger(0,eAmount)
			If eAmount > 0
				ForEach cueList()\effects()
					With cueList()\effects()
						Debug "Effect type: " + Str(\type)
						WriteByte(0,\type)
						WriteByte(0,\active)
						WriteInteger(0,\id)
						
						If \type = #BASS_FX_DX8_REVERB
							WriteFloat(0,\revParam\fInGain)
							WriteFloat(0,\revParam\fReverbMix)
							WriteFloat(0,\revParam\fReverbTime)
							WriteFloat(0,\revParam\fHighFreqRTRatio)
						ElseIf \type = #BASS_FX_DX8_PARAMEQ
							WriteFloat(0,\eqParam\fCenter)
							WriteFloat(0,\eqParam\fBandwidth)
							WriteFloat(0,\eqParam\fGain)
						ElseIf \type = #EFFECT_VST
							WriteStringN(0,\pluginPath)
							
							pAmount = BASS_VST_GetParamCount(\handle)
							Debug \handle
							Debug "Param amount: " + Str(pAmount)
							WriteInteger(0,pAmount)
							For i = 0 To pAmount - 1
								WriteFloat(0,BASS_VST_GetParam(\handle,i))
							Next i
						EndIf
					EndWith
				Next
			EndIf
			
			;"Action efektit"
			For i = 0 To 5
				If cueList()\actionEffects[i] <> 0
					WriteInteger(0,cueList()\actionEffects[i]\id)
				Else
					WriteInteger(0,0)
				EndIf
			Next i
			
		Next
		
		CloseFile(0)
	EndIf
	
	If ListSize(cueList()) > 0
		FirstElement(cueList())
		gLastHash = CRC32Fingerprint(@cueList(),SizeOf(Cue) * ListSize(cueList()))
	EndIf

	ProcedureReturn #True
EndProcedure

Procedure LoadCueList(lPath.s)
	If GetExtensionPart(lPath) = ""
		lPath = lPath + ".clf"
	EndIf
	
	Debug ""
	Debug "*** LOADING ***"
	
	If ReadFile(0,lPath)
		;Onko oikea tiedostotunniste
		tmp.s = Chr(ReadByte(0)) + Chr(ReadByte(0)) + Chr(ReadByte(0))
		
		If tmp <> "CLF"
			MessageRequester("Error","File type not supported!")
			CloseFile(0)
			ProcedureReturn #False
		EndIf
		
		;Tiedostoformaatin versio
		version.f = ReadFloat(0)
		
		;Asetukset
		If version >= 3.6
			sAmount = ReadInteger(0)
			For i = 0 To sAmount - 1
				gListSettings(i) = ReadInteger(0)	
			Next i
		EndIf
		
		Debug gListSettings(#SETTING_RELATIVE)
		
		;Cuejen m‰‰r‰
		tmpAmount = ReadInteger(0)
		Debug "Cue mount: " + Str(tmpAmount)
		
		gCueAmount = 0
		gCueCounter = 0
		gCuesLoaded = 0

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
		
		Debug "Cue amount: "  + Str(ListSize(cueList()))
		
		;Luetaan cuejen tiedot
		ForEach cueList()
			With cueList()
				Debug ""
				Debug "Current index: " + Str(ListIndex(cueList()))
				\cueType = ReadByte(0)
				Debug "Type: " + Str(\cueType)
				
				\name = ReadString(0)
				\desc = ReadString(0)
				
				\filePath = ReadString(0)
				If \cueType = #TYPE_AUDIO And \filePath <> ""
					If gListSettings(#SETTING_RELATIVE) = 1
						fPath.s = GetPathPart(lPath) + \filePath
					Else
						fPath = \filePath
					EndIf
					
					If FileSize(fPath) = -1
						result = MessageRequester("File not found","File " + fPath + " not found!" + Chr(10) + "Do you want to locate it?",#PB_MessageRequester_YesNo)
						
						If result = #PB_MessageRequester_Yes
				    		pattern.s = "Audio files (*.mp3,*.wav,*.ogg,*.aiff) |*.mp3;*.wav;*.ogg;*.aiff"
				    		
				    		path.s = OpenFileRequester("Select file","",pattern,0)
				    		
				    		If path
				    			If gListSettings(#SETTING_RELATIVE) = 1
				    				\filePath = RelativePath(GetPathPart(path),GetPathPart(lPath)) + GetFilePart(path)
				    			Else
				    				\filePath = path
				    			EndIf
				    			
				    			LoadCueStream(@cueList(),fPath)
				    		EndIf
				    	EndIf
				    Else
				    	LoadCueStream(@cueList(),fPath)
				    EndIf
				EndIf
				
				\startMode = ReadByte(0)
				\delay = ReadFloat(0)
				
				*prev.Cue = @cueList()
				
				tmpId = ReadInteger(0)
				If tmpId <> 0
					*prev\afterCue = GetCueById(tmpId)
					
					Debug "After cue id: " + Str(*prev\afterCue\id)
					Debug "After cue name: " + *prev\afterCue\name
				EndIf
				ChangeCurrentElement(cueList(),*prev)
					
				;Cuen j‰lkeiset cuet
				tmpA = ReadInteger(0)
				Debug "Follow cues (" + \name + "): " + Str(tmpA)
				
				For k = 1 To tmpA
					AddElement(*prev\followCues())
					*prev\followCues() = GetCueById(ReadInteger(0))
					Debug "Follow cue: " + *prev\followCues()\name
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
				
				;"Action cuet"
				For k = 0 To 5
					tmpId = ReadInteger(0)
					If tmpId <> 0
						*prev\actionCues[k] = GetCueById(tmpId)
					EndIf
					
					*prev\actions[k] = ReadByte(0)
				Next k
				ChangeCurrentElement(cueList(),*prev)
				
				;Efektit
				eAmount = ReadInteger(0)
				Debug "Effect amount: " + Str(eAmount)
				If eAmount > 0
					For i = 1 To eAmount
						tmpType = ReadByte(0)
						Debug "Effect type: " + Str(tmpType)
						tmpActive = ReadByte(0)
						
						If version >= 3.7
							tmpId = ReadInteger(0)
						Else
							tmpId = -1
						EndIf
						
						If tmpType = #BASS_FX_DX8_REVERB
							revParams.BASS_DX8_REVERB
							revParams\fInGain = ReadFloat(0)
							revParams\fReverbMix = ReadFloat(0)
							revParams\fReverbTime = ReadFloat(0)
							revParams\fHighFreqRTRatio = ReadFloat(0)
							
							AddCueEffect(@cueList(),tmpType,@revParams,0,tmpActive,tmpId)
						ElseIf tmpType = #BASS_FX_DX8_PARAMEQ
							eqParams.BASS_DX8_PARAMEQ
							eqParams\fCenter = ReadFloat(0)
							eqParams\fBandwidth = ReadFloat(0)
							eqParams\fGain = ReadFloat(0)
							
							AddCueEffect(@cueList(),tmpType,0,@eqParams,tmpActive,tmpId)
						ElseIf tmpType = #EFFECT_VST
							tmpPath.s = ReadString(0)
							result = AddCueEffect(@cueList(),tmpType,0,0,tmpActive,tmpId,tmpPath)
							
							If result = #True
								pAmount = ReadInteger(0)
								For k = 0 To pAmount - 1
									BASS_VST_SetParam(cueList()\effects()\handle,k,ReadFloat(0))
								Next k
							EndIf
							
						EndIf
					Next i
				EndIf
				ChangeCurrentElement(cueList(),*prev)
				
				;"action efektit"
				If version >= 3.7
					For i = 0 To 5
						tmpId = ReadInteger(0)
						If tmpId <> 0
							*prev\actionEffects[i] = GetEffectById(tmpId)
						EndIf
					Next i
				EndIf
				ChangeCurrentElement(cueList(),*prev)
						
			EndWith
			
			gCuesLoaded + 1
		Next
		
		CloseFile(0)
		
		AddRecentFile(lPath)
	Else
		MessageRequester("Error","Couldn't open file " + path + "!")
		ProcedureReturn #False
	EndIf
	
	If ListSize(cueList()) > 0
		FirstElement(cueList())
		gLastHash = CRC32Fingerprint(@cueList(),SizeOf(Cue) * ListSize(cueList()))
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

Procedure.s RelativePath(absolutePath.s,relativeTo.s)
	absCount = CountString(absolutePath,"\") + 1
	If Right(absolutePath,1) = "\"
		absCount - 1
	EndIf
	
	relCount = CountString(relativeTo,"\") + 1
	If Right(relativeTo,1) = "\"
		relCount - 1
	EndIf
	
	Dim absoluteDirs.s(absCount - 1)
	Dim relativeDirs.s(relCount - 1)
	
	For i = 0 To absCount - 1
		absoluteDirs(i) = StringField(absolutePath,i + 1,"\")
		Debug absoluteDirs(i)
	Next i
	
	
	For i = 0 To relCount - 1
		relativeDirs(i) = StringField(relativeTo,i + 1,"\")
		Debug relativeDirs(i)
	Next i
	
	Define sameCounter = 0
	While sameCounter < relCount And sameCounter < absCount And relativeDirs(sameCounter) = absoluteDirs(sameCounter)
		sameCounter + 1
	Wend
	
	If sameCounter = 0
		ProcedureReturn absolutePath ;No relative link
	EndIf
	
	Dim relPath.s(0)
	Define returnString.s
	For i = sameCounter To relCount - 1
		ReDim relPath(ArraySize(relPath()) + 1)
		relPath(ArraySize(relPath())) = "..\"
	Next i
	
	For i = sameCounter To absCount - 1
		ReDim relPath(ArraySize(relPath()) + 1)
		relPath(ArraySize(relPath())) = absoluteDirs(i) + "\"
	Next i
	
	;ReDim relPath(ArraySize(relPath()) - 1)
	
	For i = 0 To ArraySize(relPath())
		returnString = returnString + relPath(i)
	Next i
	
	ProcedureReturn returnString
EndProcedure

Procedure ChangePathsToRelative()
	ForEach cueList()
		cueList()\filePath = RelativePath(GetPathPart(cueList()\filePath),GetPathPart(gSavePath)) + GetFilePart(cueList()\filePath)
	Next
EndProcedure





	
		
		