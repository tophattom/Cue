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

;-Event structure
;{
Structure Event
	*target.Cue
	action.i
	*effect.Effect
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
	
	stopHandle.l
	
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
	
	List events.Event()
	
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
	#TYPE_NOTE
EndEnumeration

Enumeration 1
	#STATE_STOPPED
	#STATE_WAITING
	#STATE_WAITING_END
	#STATE_PLAYING
	#STATE_PAUSED
	#STATE_DONE
	#STATE_FADING_OUT
	#STATE_FADING_IN
EndEnumeration

Enumeration 1
	#START_MANUAL
	#START_AFTER_START
	#START_AFTER_END
	#START_HOTKEY
EndEnumeration

Enumeration 1
	#EVENT_FADE_OUT
	#EVENT_STOP
	#EVENT_RELEASE
	#EVENT_EFFECT_ON
	#EVENT_EFFECT_OFF
	
	#TARGET_ALL
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
	#AddImg
	
	#StartOffset
	#EndOffset
	#LoopArea
EndEnumeration

;Vakioita rajaimien avuksi
Enumeration 1
	#GRAB_START
	#GRAB_END
	#GRAB_POS
	#GRAB_LOOP_START
	#GRAB_LOOP_END
	#GRAB_WAVEFORM
EndEnumeration


CreateImage(#StartOffset,1,120)
CreateImage(#EndOffset,1,120)

CreateImage(#LoopArea,1,120)
StartDrawing(ImageOutput(#LoopArea))
Box(0,0,1,120,$00FF00)
StopDrawing()


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
  #AddNote
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
  #Text_31
  #EventList
  #EventTarget
  #EventAction
  #EventEffect
  #EventAdd
  #EventDelete
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
  #Text_30
  #ZoomSlider
  #Text_32
  #ChangeTarget
  
  #EditorTabs
  
  #AddEffect
  #Text_25
  #EffectType
  #EffectPlay
  #EffectPause
  #EffectStop
  #EffectScroll
  
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
  #PrefGFrame
  #Text_27
  #SelectADevice
  #Text_28
  #FontSize
  #PrefOk
  #PrefCancel
  #Text_29
  #CuePrefix
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
  #StopSc
  
  #DeleteSc
  
  #ExplorerSc
  
  #InSc
  #OutSc
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

Global *gCurrentEvent.Event

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

Global gCueNaming.s	;Cuen nime‰misk‰yt‰ntˆ.		# = numero, $ = pieni kirjain, & = iso kirjain

Declare DeleteCueEffect(*cue.Cue,*effect.Effect)
Declare.s RelativePath(absolutePath.s,relativeTo.s)
Declare StopCue(*cue.Cue)
Declare UpdateWaveform(pos.f,mode=0)
Declare StopProc(handle.i,channel.i,d,*user.Cue)
Declare Min(a.f,b.f)
Declare Open_LoadWindow(*value)

Procedure SaveAppSettings()
	If FileSize("settings.ini") = -1
		CreatePreferences("settings.ini")
	EndIf
	
	If OpenPreferences("settings.ini")
		PreferenceGroup("General")
		WritePreferenceInteger("Audio device",gAppSettings(#SETTING_ADEVICE))
		WritePreferenceInteger("Font size",gAppSettings(#SETTING_FONTSIZE))
		WritePreferenceString("Cue naming",gCueNaming)
		
		PreferenceGroup("Recent files")
		For i = 1 To #MAX_RECENT
			WritePreferenceString("File " + Str(i),gRecentFiles(i - 1))
		Next i
	EndIf
EndProcedure

Procedure SetDefaultSettings()
	gAppSettings(#SETTING_ADEVICE) = 1
	gAppSettings(#SETTING_FONTSIZE) = 8
	
	gCueNaming = "Q#"
	
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
			
			gCueNaming = ReadPreferenceString("Cue naming","Q#")
			
			PreferenceGroup("Recent files")
			ExaminePreferenceKeys()
			For i = 0 To #MAX_RECENT - 1
				NextPreferenceKey()
				If FileSize(PreferenceKeyValue()) > -1
					gRecentFiles(i) = PreferenceKeyValue()
				EndIf
			Next i
			
			ClosePreferences()
		EndIf
		
		SaveAppSettings()
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

Procedure.s CreateCueName()
	cueName.s = gCueNaming
	
	;#
	cueName = ReplaceString(cueName,"#",Str(gCueCounter))
	
	;&
	r = Round(gCueCounter / 27,#PB_Round_Down)

	If r > 0
		tmpS.s = Chr(64 + r)
	EndIf
	
	tmpS = tmpS + Chr(64 + (gCueCounter - gCueCounter * r))
	
	cueName = ReplaceString(cueName,"&",tmpS)
	
	;$
	tmpS = ""
	If r > 0
		tmpS = Chr(96 + r)
	EndIf
	
	tmpS = tmpS + Chr(96 + (gCueCounter - gCueCounter * r))
	
	cueName = ReplaceString(cueName,"$",tmpS)
	
	ProcedureReturn cueName
EndProcedure

Procedure AddCue(type.i,name.s="",vol=1,pan=0,id=0)
	LastElement(cueList())
	AddElement(cueList())
	
	gCueAmount + 1
	gCueCounter + 1
	
	With cueList()
		\cueType = type
		
		If type = #TYPE_CHANGE
			AddElement(\events())
		EndIf
		
		If name = ""
			\name = CreateCueName()
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
    
    *cue\stopHandle = BASS_ChannelSetSync(*cue\stream,#BASS_SYNC_POS,BASS_ChannelSeconds2Bytes(*cue\stream,*cue\endPos),@StopProc(),*cue)
    
    ;****Aallon piirto
    tmpStream.l = BASS_StreamCreateFile(0,@path,0,0,#BASS_STREAM_DECODE | #BASS_SAMPLE_FLOAT)
    length.l = BASS_ChannelGetLength(tmpStream,#BASS_POS_BYTE)
    Dim buffer.f(length / 4)
    
    BASS_ChannelGetData(tmpStream,@buffer(0), length)
    
    amount = ArraySize(buffer())
    tmpW = Min(4000,amount)
    s = amount / tmpW
    pos = 0
    
    
    If *cue\waveform = 0
    	*cue\waveform = CreateImage(#PB_Any,tmpW,120)
    EndIf
    
    StartDrawing(ImageOutput(*cue\waveform))
    Box(0,0,tmpW,120,RGB(64,64,64))
    For i = 0 To tmpW - 1
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
    
    *cue\stopHandle = BASS_ChannelSetSync(*cue\stream,#BASS_SYNC_POS,BASS_ChannelSeconds2Bytes(*cue\stream,*cue\endPos),@StopProc(),*cue)

    ;****Aallon piirto
    tmpStream.l = BASS_StreamCreateFile(0,@path,0,0,#BASS_STREAM_DECODE |#BASS_SAMPLE_FLOAT)
    length.l = BASS_ChannelGetLength(tmpStream,#BASS_POS_BYTE)
    Dim buffer.f(length / 4)
    
    BASS_ChannelGetData(tmpStream,@buffer(0), length)
    
    amount = ArraySize(buffer())
    tmpW = Min(4000,amount)
    s = amount / tmpW
    pos = 0
    
    
    If *cue\waveform = 0
    	*cue\waveform = CreateImage(#PB_Any,tmpW,120)
    EndIf
    
    StartDrawing(ImageOutput(*cue\waveform))
    Box(0,0,tmpW,120,RGB(64,64,64))
   	StopDrawing()
    
    For i = 0 To tmpW - 1
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
    		If i % 200 = 0
    			UpdateWaveform(0)
    		EndIf
    		;SetGadgetState(#WaveImg,ImageID(*cue\waveform))
    	EndIf
    Next i
    
    UpdateWaveform(0)
    
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
	ForEach cueList()
		If @cueList() <> *cue
			ForEach cueList()\events()
				If cueList()\events()\target = *cue
					DeleteElement(cueList()\events())
					Break
				EndIf
			Next
		EndIf
	Next
	
	If *cue\afterCue <> 0
		ForEach *cue\afterCue\followCues()
			If *cue\afterCue\followCues() = *cue
				DeleteElement(*cue\afterCue\followCues())
			EndIf
		Next
	EndIf
	
	If ListSize(*cue\effects()) > 0
		ForEach *cue\effects()
			DeleteCueEffect(*cue,@*cue\effects())
		Next
	EndIf
	
	ClearList(*cue\events())
	
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
		SetGadgetAttribute(#EffectScroll,#PB_ScrollArea_InnerHeight,GetGadgetAttribute(#EffectScroll,#PB_ScrollArea_InnerHeight) + 115)
		OpenGadgetList(#EffectScroll,1)
		tmpY = (amount - 1) * 115
		Select eType
			Case #BASS_FX_DX8_REVERB
				*cue\effects()\name = "Reverb"
				text.s = "Reverb " + Str(gEffectCounter)
				
				*cue\effects()\gadgets[5] = TrackBarGadget(#PB_Any,75, tmpY + 40,170,30,0,960)		;Input gain [-96.0,0.0]
				*cue\effects()\gadgets[6] = TrackBarGadget(#PB_Any,75, tmpY + 75,170,30,0,960) 		;Reverb mix [-96.0,0.0]
				*cue\effects()\gadgets[7] = TrackBarGadget(#PB_Any,370, tmpY + 40,170,30,1,3000) 	;Reverb time [1,3000]
				*cue\effects()\gadgets[8] = TrackBarGadget(#PB_Any,370, tmpY + 75,170,30,1,999)		;High freq rvrb time [0.001,0.999]
				
				*cue\effects()\gadgets[9] = StringGadget(#PB_Any,250,tmpY + 40,40,20,"",#PB_String_ReadOnly)
				*cue\effects()\gadgets[10] = StringGadget(#PB_Any,250,tmpY + 75,40,20,"",#PB_String_ReadOnly)
				*cue\effects()\gadgets[11] = StringGadget(#PB_Any,545,tmpY + 40,40,20,"",#PB_String_ReadOnly)
				*cue\effects()\gadgets[12] = StringGadget(#PB_Any,545,tmpY + 75,40,20,"",#PB_String_ReadOnly)
				
				*cue\effects()\gadgets[13] = TextGadget(#PB_Any,10,tmpY + 40,60,30,"Input gain (dB):")
				*cue\effects()\gadgets[14] = TextGadget(#PB_Any,10,tmpY + 75,60,30,"Reverb mix (dB):")
				*cue\effects()\gadgets[15] = TextGadget(#PB_Any,310,tmpY + 40,60,30,"Reverb time (ms):")
				*cue\effects()\gadgets[16] = TextGadget(#PB_Any,310,tmpY + 75,60,30,"High freq time ratio:")
				
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
				*cue\effects()\gadgets[7] = TrackBarGadget(#PB_Any,370, tmpY + 40,170,30,0,300) 							;Gain [-15,15]
				
				*cue\effects()\gadgets[9] = StringGadget(#PB_Any,250,tmpY + 40,40,20,"",#PB_String_ReadOnly)
				*cue\effects()\gadgets[10] = StringGadget(#PB_Any,250,tmpY + 75,40,20,"",#PB_String_ReadOnly)
				*cue\effects()\gadgets[11] = StringGadget(#PB_Any,545,tmpY + 40,40,20,"",#PB_String_ReadOnly)
				
				*cue\effects()\gadgets[13] = TextGadget(#PB_Any,10,tmpY + 40,60,30,"Center (Hz):")
				*cue\effects()\gadgets[14] = TextGadget(#PB_Any,10,tmpY + 75,60,30,"Bandwidth (semitones):")
				*cue\effects()\gadgets[15] = TextGadget(#PB_Any,310,tmpY + 40,60,30,"Gain (dB):")
				
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
					
					OpenGadgetList(#EffectScroll,1)
					
					*cue\effects()\gadgets[6] = ButtonGadget(#PB_Any,10,tmpY + 40,70,30,"Open editor")
				EndIf		
		EndSelect
		
		*cue\effects()\gadgets[#EGADGET_FRAME] = Frame3DGadget(#PB_Any,5,tmpY,640,115,text)
		*cue\effects()\gadgets[#EGADGET_UP] = ButtonImageGadget(#PB_Any,605,tmpY + 10,30,30,ImageID(#UpImg))
		*cue\effects()\gadgets[#EGADGET_DOWN] = ButtonImageGadget(#PB_Any,605,tmpY + 45,30,30,ImageID(#DownImg))
		*cue\effects()\gadgets[#EGADGET_DELETE] = ButtonImageGadget(#PB_Any,605,tmpy + 80,30,30,ImageID(#DeleteImg))
		*cue\effects()\gadgets[#EGADGET_ACTIVE] = CheckBoxGadget(#PB_Any,10,tmpY + 15,60,20,"Active")
		SetGadgetState(*cue\effects()\gadgets[#EGADGET_ACTIVE],1)
		
		
		For i = 0 To 16
			If IsGadget(*cue\effects()\gadgets[i])
				SetGadgetColor(*cue\effects()\gadgets[i],#PB_Gadget_BackColor,$FFFFFF)
			EndIf
		Next i
		
		CloseGadgetList()
		ProcedureReturn #True	
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
	
	SetGadgetAttribute(#EffectScroll,#PB_ScrollArea3D_InnerHeight,GetGadgetAttribute(#EffectScroll,#PB_ScrollArea3D_InnerHeight) - 115)
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

Procedure SaveCueListXML(path.s,check=1)
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
	
	xml = CreateXML(#PB_Any)
	mainNode = CreateXMLNode(RootXMLNode(xml))
	SetXMLNodeName(mainNode,"cuelist")
	
	;Listan asetukset
	setNode = CreateXMLNode(mainNode)
	SetXMLNodeName(setNode,"settings")
	SetXMLAttribute(setNode,"amount",Str(#SETTINGS))
	For i = 0 To #SETTINGS - 1
		tmpNode = CreateXMLNode(setNode)
		SetXMLNodeName(tmpNode,"setting")
		SetXMLAttribute(tmpNode,"type",Str(i))
		SetXMLAttribute(tmpNode,"value",Str(gListSettings(i)))
	Next i
	
	;Kirjoitetaan idt alkuun, jotta cuet voidaan luoda ennen tietojen asetusta
	idNode = CreateXMLNode(mainNode)
	SetXMLNodeName(idNode,"ids")
	SetXMLAttribute(idNode,"amount",Str(gCueAmount))
	ForEach cueList()
		tmpNode = CreateXMLNode(idNode)
		SetXMLNodeName(tmpNode,"cueid")
		SetXMLNodeText(tmpNode,Str(cueList()\id))
	Next
	
	;Cuejen tiedot
	cuesNode = CreateXMLNode(mainNode)
	SetXMLNodeName(cuesNode,"cues")
	SetXMLAttribute(cuesNode,"amount",Str(gCueAmount))
	ForEach cueList()
		cueNode = CreateXMLNode(cuesNode)
		SetXMLNodeName(cueNode,"cue")
		SetXMLAttribute(cueNode,"id",Str(cueList()\id))
		
		;Cuen tyyppi
		tmpNode = CreateXMLNode(cueNode)
		SetXMLNodeName(tmpNode,"type")
		SetXMLNodeText(tmpNode,Str(cueList()\cueType))
		
		;Nimi
		tmpNode = CreateXMLNode(cueNode)
		SetXMLNodeName(tmpNode,"name")
		SetXMLNodeText(tmpNode,cueList()\name)
		
		;Kuvaus
		tmpNode = CreateXMLNode(cueNode)
		SetXMLNodeName(tmpNode,"description")
		SetXMLNodeText(tmpNode,cueList()\desc)
		
		;Tiedostopolku
		tmpNode = CreateXMLNode(cueNode)
		SetXMLNodeName(tmpNode,"file")
		SetXMLNodeText(tmpNode,cueList()\filePath)
		
		;Aloitustapa
		tmpNode = CreateXMLNode(cueNode)
		SetXMLNodeName(tmpNode,"startmode")
		SetXMLNodeText(tmpNode,Str(cueList()\startMode))
		
		;Viive
		tmpNode = CreateXMLNode(cueNode)
		SetXMLNodeName(tmpNode,"delay")
		SetXMLNodeText(tmpNode,StrF(cueList()\delay))
		
		;After cue
		tmpNode = CreateXMLNode(cueNode)
		SetXMLNodeName(tmpNode,"aftercue")
		If cueList()\afterCue <> 0
			SetXMLNodeText(tmpNode,Str(cueList()\afterCue\id))
		Else
			SetXMLNodeText(tmpNode,"")
		EndIf
		
		;Cuen j‰lkeiset cuet
		followNode = CreateXMLNode(cueNode)
		SetXMLNodeName(followNode,"followcues")
		SetXMLAttribute(followNode,"amount",Str(ListSize(cueList()\followCues())))
		ForEach cueList()\followCues()
			tmpNode = CreateXMLNode(followNode)
			SetXMLNodeName(tmpNode,"cueid")
			SetXMLNodeText(tmpNode,Str(cueList()\followCues()\id))
		Next
		
		If cueList()\cueType = #TYPE_AUDIO Or cueList()\cueType = #TYPE_CHANGE
			;Alku
			tmpNode = CreateXMLNode(cueNode)
			SetXMLNodeName(tmpNode,"startpos")
			SetXMLNodeText(tmpNode,StrF(cueList()\startPos))
			;Loppu
			tmpNode = CreateXMLNode(cueNode)
			SetXMLNodeName(tmpNode,"endpos")
			SetXMLNodeText(tmpNode,StrF(cueList()\endPos))
			
			;Looppi
			tmpNode = CreateXMLNode(cueNode)
			SetXMLNodeName(tmpNode,"looped")
			SetXMLNodeText(tmpNode,Str(cueList()\looped))
			;Loopin alku
			tmpNode = CreateXMLNode(cueNode)
			SetXMLNodeName(tmpNode,"loopstart")
			SetXMLNodeText(tmpNode,StrF(cueList()\loopStart))
			;Loopin loppu
			tmpNode = CreateXMLNode(cueNode)
			SetXMLNodeName(tmpNode,"loopend")
			SetXMLNodeText(tmpNode,StrF(cueList()\loopEnd))
			;Looppien m‰‰r‰
			tmpNode	= CreateXMLNode(cueNode)
			SetXMLNodeName(tmpNode,"loopcount")
			SetXMLNodeText(tmpNode,Str(cueList()\loopCount))
			
			;Fade in
			tmpNode = CreateXMLNode(cueNode)
			SetXMLNodeName(tmpNode,"fadein")
			SetXMLNodeText(tmpNode,StrF(cueList()\fadeIn))
			;Fade out
			tmpNode = CreateXMLNode(cueNode)
			SetXMLNodeName(tmpNode,"fadeout")
			SetXMLNodeText(tmpNode,StrF(cueList()\fadeOut))
			
			;Volume
			tmpNode = CreateXMLNode(cueNode)
			SetXMLNodeName(tmpNode,"volume")
			SetXMLNodeText(tmpNode,StrF(cueList()\volume))
			;Pannaus
			tmpNode = CreateXMLNode(cueNode)
			SetXMLNodeName(tmpNode,"pan")
			SetXMLNodeText(tmpNode,StrF(cueList()\pan))
		EndIf
		
		;Eventit
		If cueList()\cueType = #TYPE_EVENT Or cueList()\cueType = #TYPE_CHANGE
			eventsNode = CreateXMLNode(cueNode)
			SetXMLNodeName(eventsNode,"events")
			ForEach cueList()\events()
				eventNode = CreateXMLNode(eventsNode)
				SetXMLNodeName(eventNode,"event")
				SetXMLAttribute(eventNode,"action",Str(cueList()\events()\action))
				
				;Kohde
				tmpNode = CreateXMLNode(eventNode)
				SetXMLNodeName(tmpNode,"target")
				If cueList()\events()\target <> 0
					SetXMLNodeText(tmpNode,Str(cueList()\events()\target\id))
				Else
					SetXMLNodeText(tmpNode,"0")
				EndIf

				;Kohde-efekti
				tmpNode = CreateXMLNode(eventNode)
				SetXMLNodeName(tmpNode,"effect")
				If cueList()\events()\effect <> 0
					SetXMLNodeText(tmpNode,Str(cueList()\events()\effect\id))
				Else
					SetXMLNodeText(tmpNode,"0")
				EndIf
			Next
		EndIf
		
		;Efektit
		If cueList()\cueType = #TYPE_AUDIO
			effectsNode = CreateXMLNode(cueNode)
			SetXMLNodeName(effectsNode,"effects")
			SetXMLAttribute(effectsNode,"amount",Str(ListSize(cueList()\effects())))
			
			ForEach cueList()\effects()
				With cueList()\effects()
					effectNode = CreateXMLNode(effectsNode)
					SetXMLNodeName(effectNode,"effect")
					SetXMLAttribute(effectNode,"type",Str(\type))
					SetXMLAttribute(effectNode,"id",Str(\id))
					
					;Aktiivisuus
					tmpNode = CreateXMLNode(effectNode)
					SetXMLNodeName(tmpNode,"active")
					SetXMLNodeText(tmpNode,Str(\active))
					
					;Arvot
					If \type = #BASS_FX_DX8_REVERB
						tmpNode = CreateXMLNode(effectNode)
						SetXMLNodeName(tmpNode,"ingain")
						SetXMLNodeText(tmpNode,StrF(\revParam\fInGain))
						
						tmpNode = CreateXMLNode(effectNode)
						SetXMLNodeName(tmpNode,"reverbmix")
						SetXMLNodeText(tmpNode,StrF(\revParam\fReverbMix))
						
						tmpNode = CreateXMLNode(effectNode)
						SetXMLNodeName(tmpNode,"reverbtime")
						SetXMLNodeText(tmpNode,StrF(\revParam\fReverbTime))
						
						tmpNode = CreateXMLNode(effectNode)
						SetXMLNodeName(tmpNode,"hfrtr")
						SetXMLNodeText(tmpNode,StrF(\revParam\fHighFreqRTRatio))
					ElseIf \type = #BASS_FX_DX8_PARAMEQ
						tmpNode = CreateXMLNode(effectNode)
						SetXMLNodeName(tmpNode,"center")
						SetXMLNodeText(tmpNode,StrF(\eqParam\fCenter))
						
						tmpNode = CreateXMLNode(effectNode)
						SetXMLNodeName(tmpNode,"bandwidth")
						SetXMLNodeText(tmpNode,StrF(\eqParam\fBandwidth))
						
						tmpNode = CreateXMLNode(effectNode)
						SetXMLNodeName(tmpNode,"gain")
						SetXMLNodeText(tmpNode,StrF(\eqParam\fGain))
					ElseIf \type = #EFFECT_VST
						tmpNode = CreateXMLNode(effectNode)
						SetXMLNodeName(tmpNode,"vstpath")
						SetXMLNodeText(tmpNode,\pluginPath)

						pAmount = BASS_VST_GetParamCount(\handle)
						For i = 0 To pAmount - 1
							info.BASS_VST_PARAM_INFO
							BASS_VST_GetParamInfo(\handle,i,@info)
							
							tmpNode = CreateXMLNode(effectNode)
							SetXMLNodeName(tmpNode,info\name)
							SetXMLNodeText(tmpNode,StrF(BASS_VST_GetParam(\handle,i)))
						Next i
					EndIf
				EndWith
			Next		
		EndIf
	Next

	SaveXML(xml,path)
	FreeXML(xml)
	
	AddRecentFile(path)
	
	If ListSize(cueList()) > 0
		FirstElement(cueList())
		gLastHash = CRC32Fingerprint(@cueList(),SizeOf(Cue) * ListSize(cueList()))
	EndIf
	
	ProcedureReturn #True
EndProcedure

Procedure LoadCueListXML(lPath.s)
	If LoadXML(0,lPath)
		If XMLStatus(0) <> #PB_XML_Success
			Message$ = "Error in the XML file:" + Chr(13)
			Message$ + "Message: " + XMLError(0) + Chr(13)
			Message$ + "Line: " + Str(XMLErrorLine(0)) + "   Character: " + Str(XMLErrorPosition(0))
			MessageRequester("Error", Message$)
		EndIf
		
		If GetXMLNodeName(MainXMLNode(0)) <> "cuelist"
			MessageRequester("Error","File" + lPath + " is not a cue List file!")
		EndIf
		
		gCuesLoaded = 0
		CreateThread(@Open_LoadWindow(),0)
		
		currentNode = ChildXMLNode(MainXMLNode(0))
		Repeat
			If currentNode = 0
				Break
			EndIf
			
			Select GetXMLNodeName(currentNode)
				Case "settings"		;---Asetukset
					settingNode = ChildXMLNode(currentNode)
					While settingNode <> 0
						tmp = Val(GetXMLAttribute(settingNode,"type"))
						tmpValue = Val(GetXMLAttribute(settingNode,"value"))
						
						gListSettings(tmp) = tmpValue
						
						settingNode = NextXMLNode(settingNode)
					Wend
				Case "ids"		;---Cuejen idt
					gCueAmount = Val(GetXMLAttribute(currentNode,"amount"))
					idNode = ChildXMLNode(currentNode)
					While idNode <> 0
						AddElement(cueList())
						cueList()\id = Val(GetXMLNodeText(idNode))
						
						If cueList()\id > high
							high = cueList()\id
						EndIf
						
						cueList()\state = #STATE_STOPPED
						
						idNode = NextXMLNode(idNode)
					Wend
					
					gCueCounter = high
				Case "cues"		;---Cuejen tiedot
					cueNode = ChildXMLNode(currentNode)
					ForEach cueList()
						*prev.Cue = @cueList()
						
						With cueList()
							attrNode = ChildXMLNode(cueNode)
							While attrNode <> 0
								attr.s = GetXMLNodeName(attrNode)
								value.s = GetXMLNodeText(attrNode)
								
								Select attr
									Case "type"
										\cueType = Val(value)
									Case "name"
										\name = value
									Case "description"
										\desc = value
									Case "file"
										\filePath = value
										
										If \filePath <> ""
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
									Case "startmode"
										\startMode = Val(value)
									Case "delay"
										\delay = ValF(value)
									Case "aftercue"
										tmpId = Val(value)
										
										If tmpId <> 0
											*prev\afterCue = GetCueById(tmpId)
										EndIf
										
										ChangeCurrentElement(cueList(),*prev)
									Case "followcues"
										idNode = ChildXMLNode(attrNode)
										While idNode <> 0
											AddElement(*prev\followCues())
											
											*prev\followCues() = GetCueById(Val(GetXMLNodeText(idNode)))
											idNode = NextXMLNode(idNode)
										Wend
										
										ChangeCurrentElement(cueList(),*prev)
									Case "startpos"
										\startPos = ValF(value)
									Case "endpos"
										\endPos = ValF(value)
									Case "looped"
										\looped = Val(value)
									Case "loopstart"
										\loopStart = ValF(value)
									Case "loopend"
										\loopEnd = ValF(value)
									Case "loopcount"
										\loopCount = Val(value)
									Case "fadein"
										\fadeIn = ValF(value)
									Case "fadeout"
										\fadeOut = ValF(value)
									Case "volume"
										\volume = ValF(value)
									Case "pan"
										\pan = ValF(value)
									Case "events"
										eventNode = ChildXMLNode(attrNode)
										While eventNode <> 0
											AddElement(*prev\events())
											
											*prev\events()\action = Val(GetXMLAttribute(eventNode,"action"))
											
											tmpNode = ChildXMLNode(eventNode)
											tmpId = Val(GetXMLNodeText(tmpNode))
											Select GetXMLNodeName(tmpNode)
												Case "target"
													If tmpId <> 0
														*prev\events()\target = GetCueById(tmpId)
													EndIf
												Case "effect"
													If tmpId <> 0
														*prev\events()\effect = GetEffectById(tmpId)
													EndIf
											EndSelect

											eventNode = NextXMLNode(eventNode)
										Wend
										
										ChangeCurrentElement(cueList(),*prev)
									Case "effects"
										effectNode = ChildXMLNode(attrNode)
										While effectNode <> 0
											eType = Val(GetXMLAttribute(effectNode,"type"))
											tmpId = Val(GetXMLAttribute(effectNode,"id"))
											
											tmpNode = ChildXMLNode(effectNode)
											tmpActive = Val(GetXMLNodeText(tmpNode))
											
											If eType = #BASS_FX_DX8_REVERB
												revParams.BASS_DX8_REVERB
												
												tmpNode = NextXMLNode(tmpNode)
												While tmpNode <> 0
													tmpVal.f = ValF(GetXMLNodeText(tmpNode))
													Select GetXMLNodeName(tmpNode)
														Case "ingain"
															revParams\fInGain = tmpVal
														Case "reverbmix"
															revParams\fReverbMix = tmpVal
														Case "reverbtime"
															revParams\fReverbTime = tmpVal
														Case "hfrtr"
															revParams\fHighFreqRTRatio = tmpVal
													EndSelect
													
													tmpNode = NextXMLNode(tmpNode)
												Wend
												
												AddCueEffect(@cueList(),eType,@revParams,0,tmpActive,tmpId)
											ElseIf eType = #BASS_FX_DX8_PARAMEQ
												eqParams.BASS_DX8_PARAMEQ
												
												tmpNode = NextXMLNode(tmpNode)
												While tmpNode <> 0
													tmpVal.f = ValF(GetXMLNodeText(tmpNode))
													Select GetXMLNodeName(tmpNode)
														Case "center"
															eqParams\fCenter = tmpVal
														Case "bandwidth"
															eqParams\fBandwidth = tmpVal
														Case "gain"
															eqParams\fGain = tmpVal
													EndSelect
													
													tmpNode = NextXMLNode(tmpNode)
												Wend
												
												AddCueEffect(@cueList(),eType,0,@eqParams,tmpActive,tmpId)
											ElseIf eType = #EFFECT_VST
												tmpNode = NextXMLNode(tmpNode)
												tmpPath.s = GetXMLNodeText(tmpNode)
												
												result = AddCueEffect(@cueList(),eType,0,0,tmpActive,tmpId,tmpPath)
												
												If result = #True
													tmpNode = NextXMLNode(tmpNode)
													i = 0
													While tmpNode <> 0
														tmpVal.f = ValF(GetXMLNodeText(tmpNode))
														BASS_VST_SetParam(cueList()\effects()\handle,i,tmpVal)
														
														i + 1
														tmpNode = NextXMLNode(tmpNode)
													Wend
													
												EndIf
											EndIf
											
											effectNode = NextXMLNode(effectNode)
										Wend
								EndSelect
								
								attrNode = NextXMLNode(attrNode)
							Wend
						EndWith
						
						cueNode = NextXMLNode(cueNode)
						gCuesLoaded + 1
					Next
			EndSelect
			
			currentNode = NextXMLNode(currentNode)
			
		ForEver
		
		FreeXML(0)
		
		AddRecentFile(lPath)
	Else
		MessageRequester("Error","File " + lPath + " couldn't be loaded!")
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
		DeleteCue(@cueList())
	Next
	
	;ClearList(cueList())
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
		SaveCueListXML(gSavePath)
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

Procedure Triangle(x1,y1,x2,y2,x3,y3,fill=0)
	LineXY(x1,y1,x2,y2)
    LineXY(x2,y2,x3,y3)
    LineXY(x3,y3,x1,y1)

    If fill = 1
        If y2<y1
            tmp=y1
            y1=y2
            y2=tmp
            
            tmp=x1
            x1=x2
            x2=tmp
        EndIf
        
        If y3<y1
            tmp=y1
            y1=y3
            y3=tmp
            
            tmp=x1
            x1=x3
            x3=tmp
        EndIf
        
        If y3<y2
            tmp=y2
            y2=y3
            y3=tmp
            
            tmp=x2
            x2=x3
            x3=tmp
        EndIf
        
        dy1=y2-y1
        dx1=x2-x1
        dy2=y3-y1
        dx2=x3-x1
        
        If dy1
            For i = y1 To y2
                ax=x1+((i-y1)*dx1)/dy1
                bx=x1+((i-y1)*dx2)/dy2
                LineXY(ax,i,bx,i)
            Next i
        EndIf
        
        dy1=y3-y2
        dx1=x3-x2
        
        If dy1
            For i = y2 To y3
                ax=x2+((i-y2)*dx1)/dy1
                bx=x1+((i-y1)*dx2)/dy2
                LineXY(ax,i,bx,i)
            Next i
        EndIf
    EndIf
EndProcedure



Procedure LoadCueListSCSQ(lPath.s)
	If LoadXML(0,lPath)
		If XMLStatus(0) <> #PB_XML_Success
			Message$ = "Error in the XML file:" + Chr(13)
			Message$ + "Message: " + XMLError(0) + Chr(13)
			Message$ + "Line: " + Str(XMLErrorLine(0)) + "   Character: " + Str(XMLErrorPosition(0))
			MessageRequester("Error", Message$)
		EndIf
		
		If GetXMLNodeName(MainXMLNode(0)) <> "Production"
			MessageRequester("Error","Unknown file format!")
		EndIf
		
		gCuesLoaded = 0
		;CreateThread(@Open_LoadWindow(),0)
		
		currentNode = ChildXMLNode(MainXMLNode(0))
		Repeat
			If currentNode = 0
				Break
			EndIf
			
			Select GetXMLNodeName(currentNode)
				Case "Cue"
					*gCurrentCue = AddCue(0)
					*parentCue.Cue = *gCurrentCue
					
					attrNode = ChildXMLNode(currentNode)
					While attrNode <> 0
						attr.s = GetXMLNodeName(attrNode)
						value.s = GetXMLNodeText(attrNode)
						
						Select attr
							Case "CueId"
								*gCurrentCue\name = value
							Case "Description"
								*gCurrentCue\desc = value
							Case "AutoActivateTime"
								*gCurrentCue\delay = ValF(value)
							Case "AutoActivatePosn"
								Select value
									Case "start"
										*gCurrentCue\startMode = #START_AFTER_START
									Case "end"
										*gCurrentCue\startMode = #START_AFTER_END
								EndSelect
							Case "AutoActivateCue"
								ForEach cueList()
									If @cueList() <> *gCurrentCue
										If cueList()\name = value
											*gCurrentCue\afterCue = @cueList()
											
											AddElement(cueList()\followCues())
											cueList()\followCues() = *gCurrentCue
										EndIf
									EndIf
								Next
							Case "Sub"								
									subNode = ChildXMLNode(attrNode)
									While subNode <> 0
										Select GetXMLNodeName(subNode)
											Case "SubType"
												If *gCurrentCue\cueType > 0	;Cue on SCS:n sub-cue
													*gCurrentCue = AddCue(0)
													
													;Koska Cuessa ei ole vastaavaa ominaisuutta, laitetaan uusi cue alkamaan automaattisesti
													*gCurrentCue\startMode = #START_AFTER_START
													*gCurrentCue\afterCue = *parentCue
													
													AddElement(*parentCue\followCues())
													*parentCue\followCues() = *gCurrentCue
												EndIf
												
												Select GetXMLNodeText(subNode)
													Case "F"
														*gCurrentCue\cueType = #TYPE_AUDIO
													Case "S"
														*gCurrentCue\cueType = #TYPE_EVENT
													Case "L"
														*gCurrentCue\cueType = #TYPE_CHANGE
														*tmpEvent.Event = AddElement(*gCurrentCue\events())
													Case "N"
														*gCurrentCue\cueType = #TYPE_NOTE
														*gCurrentCue\startMode = #START_AFTER_START
												EndSelect
											Case "RelStartTime"
												*gCurrentCue\delay = ValF(GetXMLNodeText(subNode))
											Case "SubDescription"
												*gCurrentCue\desc = GetXMLNodeText(subNode)
											Case "SFRCueType","SFRCueType1","SFRCueType2","SFRCueType3","SFRCueType4"
												If GetXMLNodeText(subNode) = "sel"
													*tmpEvent.Event = AddElement(*gCurrentCue\events())
												ElseIf GetXMLNodeText(subNode) = "all"
													*tmpEvent.Event = AddElement(*gCurrentCue\events())
													*tmpEvent\target = #TARGET_ALL
												Else
													*tmpEvent.Event = 0
												EndIf
											Case "SFRCue0","SFRCue1","SFRCue2","SFRCue3","SFRCue4"
												If *tmpEvent <> 0
													ForEach cueList()
														If @cueList() <> *gCurrentCue
															If cueList()\name = GetXMLNodeText(subNode)
																*tmpEvent\target = @cueList()
															EndIf
														EndIf
													Next
												EndIf
											Case "SFRAction0","SFRAction1","SFRAction2","SFRAction3","SFRAction4"
												If *tmpEvent <> 0
													Select GetXMLNodeText(subNode)
														Case "stop"
															*tmpEvent\action = #EVENT_STOP
														Case "fadeout"
															*tmpEvent\action = #EVENT_FADE_OUT
														Case "release"
															*tmpEvent\action = #EVENT_RELEASE
													EndSelect
												EndIf
											Case "LCCue"
												If *tmpEvent <> 0
													ForEach cueList()
														If @cueList() <> *gCurrentCue
															If cueList()\name = GetXMLNodeText(subNode)
																*tmpEvent\target = @cueList()
															EndIf
														EndIf
													Next
												EndIf
											Case "LCReqdDBLevel0"
												dB.f = ValF(GetXMLNodeText(subNode))
															
												*gCurrentCue\volume = Pow(Pow(10,(dB * -1) / 10),-1)
											Case "LCReqdPan0"
												pan.f = ValF(GetXMLNodeText(subNode))
												
												*gCurrentCue\pan = ((pan * 2) - 1000) / 1000.0
											Case "LCTime0"
												*gCurrentCue\fadeIn = ValF(GetXMLNodeText(subNode)) / 1000.0
											Case "AudioFile"
												tmpNode = ChildXMLNode(subNode)
												While tmpNode <> 0
													Select GetXMLNodeName(tmpNode)
														Case "FileName"
															fPath.s = GetXMLNodeText(tmpNode)
															fPath = ReplaceString(fPath,"$(Cue)",Left(GetPathPart(lPath),Len(GetPathPart(lPath)) - 1))
															
															*gCurrentCue\filePath = fPath
															
															If FileSize(fPath) = -1
																result = MessageRequester("File not found","File " + fPath + " not found!" + Chr(10) + "Do you want to locate it?",#PB_MessageRequester_YesNo)
																
																If result = #PB_MessageRequester_Yes
														    		pattern.s = "Audio files (*.mp3,*.wav,*.ogg,*.aiff) |*.mp3;*.wav;*.ogg;*.aiff"
														    		
														    		path.s = OpenFileRequester("Select file","",pattern,0)
														    		
														    		If path
														    			If gListSettings(#SETTING_RELATIVE) = 1
														    				*gCurrentCue\filePath = RelativePath(GetPathPart(path),GetPathPart(lPath)) + GetFilePart(path)
														    			Else
														    				*gCurrentCue\filePath = path
														    			EndIf
														    			
														    			LoadCueStream(*gCurrentCue,fPath)
														    		EndIf
														    	EndIf
														    Else
														    	LoadCueStream(@cueList(),fPath)
														    EndIf
														Case "FadeInTime"
															*gCurrentCue\fadeIn = ValF(GetXMLNodeText(tmpNode)) / 1000
														Case "FadeOutTime"
															*gCurrentCue\fadeOut = ValF(GetXMLNodeText(tmpNode)) / 1000
														Case "DBLevel0"
															dB.f = ValF(GetXMLNodeText(tmpNode))
															
															*gCurrentCue\volume = Pow(Pow(10,(dB * -1) / 10),-1)
														Case "LoopStart"
															*gCurrentCue\looped = 1
															*gCurrentCue\loopStart = Val(GetXMLNodeText(tmpNode)) / 1000
														Case "LoopEnd"
															*gCurrentCue\looped = 1
															
															tmpVal.f = ValF(GetXMLNodeText(tmpNode)) / 1000
															If tmpVal > -1
																*gCurrentCue\loopEnd = Val(GetXMLNodeText(tmpNode)) / 1000
															Else
																*gCurrentCue\loopEnd = *gCurrentCue\length
															EndIf
													EndSelect

													tmpNode = NextXMLNode(tmpNode)
												Wend
										EndSelect
			
										subNode = NextXMLNode(subNode)
									Wend
						EndSelect
						
						attrNode = NextXMLNode(attrNode)
					Wend
			EndSelect
			
			currentNode = NextXMLNode(currentNode)
		ForEver
		
		ProcedureReturn #True
	EndIf
EndProcedure

							
					
					
					
					
					
					
					
					
					
		
		