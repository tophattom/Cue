; PureBasic Visual Designer v3.95 build 1485 (PB4Code)


IncludeFile "includes\bass.pbi"
IncludeFile "includes\util.pbi"
IncludeFile "includes\ui.pb"

Declare UpdateEditorList()
Declare HideCueControls()
Declare ShowCueControls()
Declare UpdateCueControls()
Declare PlayCue(*cue.Cue)
Declare PauseCue(*cue.Cue)
Declare StopCue(*cue.Cue)
Declare StartEvents(*cue.Cue)
Declare UpdateCues()
Declare UpdateMainCueList()

Open_MainWindow()
Open_EditorWindow()
HideWindow(#EditorWindow, 1)
HideCueControls()

BASS_Init(-1,44100,0,WindowID(#MainWindow),#Null)


Repeat ; Start of the event loop
	
	Event = WindowEvent() ; This line waits until an event is received from Windows
	WindowID = EventWindow() ; The Window where the event is generated, can be used in the gadget procedures
	GadgetID = EventGadget() ; Is it a gadget event?
	EventType = EventType() ; The event type
	
	
	If *gCurrentCue <> 0
		If gControlsHidden = #True Or gLastType <> *gCurrentCue\cueType
			gLastType = *gCurrentCue\cueType
			ShowCueControls()
		EndIf
	Else
		If gControlsHidden = #False
			HideCueControls()
		EndIf
		
	EndIf
	
	UpdateCues()
	
	;You can place code here, and use the result as parameters for the procedures
	  
	If Event = #PB_Event_Menu
		MenuID = EventMenu()
		   
		If MenuID = #MenuNew
			Debug "GadgetID: #MenuNew"
		
		ElseIf MenuID = #MenuOpen
			path.s = OpenFileRequester("Open cue list","","Cue list files (*.clf) |*.clf",0)
			
			If path <> ""
				ClearList(cueList())
				LoadCueList(path)
				
				*gCurrentCue = FirstElement(cueList())
				UpdateMainCueList()
				UpdateEditorList()
				UpdateCueControls()
			EndIf		      
		ElseIf MenuID = #MenuSave
			path.s = OpenFileRequester("Save cue list","","Cue list files (*.clf) |*.clf",0)
			
			If path <> ""
				SaveCueList(path)
			EndIf  
		ElseIf MenuID = #MenuSaveAs
			Debug "GadgetID: #MenuSaveAs"
		      
		ElseIf MenuID = #MenuPref
			Debug "GadgetID: #MenuPref"
		      
		ElseIf MenuID = #MenuExit
			End
		ElseIf MenuID = #MenuAbout
			Debug "GadgetID: #MenuAbout"      
		EndIf
	EndIf
	  
	If Event = #PB_Event_Gadget
		If GadgetID = #PlayButton
			If *gCurrentCue <> 0
				If *gCurrentCue\cueType = #TYPE_AUDIO
					PlayCue(*gCurrentCue)
				ElseIf *gCurrentCue\cueType = #TYPE_EVENT Or *gCurrentCue\cueType = #TYPE_CHANGE
					StartEvents(*gCurrentCue)
				EndIf

				GetCueListIndex(*gCurrentCue)
				
				*gCurrentCue = NextElement(cueList())
				If *gCurrentCue <> 0
					While *gCurrentCue\state <> #STATE_STOPPED
						*gCurrentCue = NextElement(cueList())
						
						If *gCurrentCue = 0
							Break
						EndIf
					Wend
				EndIf

				UpdateMainCueList()
			EndIf
		ElseIf GadgetID = #PauseButton
			
		ElseIf GadgetID = #StopButton
			ForEach cueList()
				StopCue(@cueList())
			Next
			UpdateMainCueList()
		ElseIf GadgetID = #Listview_1
		      
		ElseIf GadgetID = #CueList
			*gCurrentCue = GetGadgetItemData(#CueList,GetGadgetState(#CueList))
			
			If *gCurrentCue = 0
				*gCurrentCue = FirstElement(cueList())
			EndIf
			
			If EventType() = #PB_EventType_LeftDoubleClick
				gEditor = #True
				HideWindow(#EditorWindow,0)
				UpdateEditorList()
				If *gCurrentCue <> 0
					UpdateCueControls()
				EndIf
				
			EndIf
		ElseIf GadgetID = #EditorButton
			HideWindow(#EditorWindow,0)
			
			If *gCurrentCue = 0
				*gCurrentCue = FirstElement(cueList())
			EndIf
			
			UpdateEditorList()
			
			If *gCurrentCue <> 0
				UpdateCueControls()
			EndIf
		ElseIf GadgetID = #EditorList
			*gCurrentCue = GetGadgetItemData(#EditorList,GetGadgetState(#EditorList))
			
			If *gCurrentCue <> 0
				UpdateCueControls()
			EndIf
		ElseIf GadgetID = #AddAudio
			*gCurrentCue = AddCue(#TYPE_AUDIO)
			UpdateEditorList()
			UpdateCueControls()
		ElseIf GadgetID = #AddChange
			*gCurrentCue = AddCue(#TYPE_CHANGE)
			UpdateEditorList()
			UpdateCueControls()
		ElseIf GadgetID = #AddEvent
			*gCurrentCue = AddCue(#TYPE_EVENT)
			UpdateEditorList()
			UpdateCueControls()
		ElseIf GadgetID = #AddVideo
		      
		ElseIf GadgetID = #MasterSlider
			BASS_SetVolume(GetGadgetState(#MasterSlider) / 100)
		ElseIf GadgetID = #CueNameField
			*gCurrentCue\name = GetGadgetText(#CueNameField)
			UpdateEditorList()
  		ElseIf GadgetID = #CueDescField
  			*gCurrentCue\desc = GetGadgetText(#CueDescField)
  			UpdateEditorList()
    	ElseIf GadgetID = #CueFileField
      
    	ElseIf GadgetID = #OpenCueFile
    		Select *gCurrentCue\cueType
    			Case #TYPE_AUDIO
    				pattern.s = "Audio files (*.mp3,*.wav,*.ogg,*.aiff) |*.mp3;*.wav;*.ogg;*.aiff"
    		EndSelect
    		
    		path.s = OpenFileRequester("Select file","",pattern,0)
    		
    		If path
    			*gCurrentCue\filePath = path
    			
    			Select *gCurrentCue\cueType
    				Case #TYPE_AUDIO
    					LoadCueStream(*gCurrentCue,path)
    			EndSelect
    			
    			If *gCurrentCue\desc = ""
    				file.s = GetFilePart(path)
    				*gCurrentCue\desc = Mid(file,0,Len(file) - 4)
    			EndIf
    			
    			UpdateCueControls()
    			UpdateEditorList()
    		EndIf
    	ElseIf GadgetID = #Image_1
      
    	ElseIf GadgetID = #ModeSelect
    		*gCurrentCue\startMode = GetGadgetItemData(#ModeSelect,GetGadgetState(#ModeSelect))
    		UpdateCueControls()
      	ElseIf GadgetID = #PreviewButton
      		If GetGadgetState(#PreviewButton) = 1
      			PlayCue(*gCurrentCue)
      		Else
      			StopCue(*gCurrentCue)
      		EndIf
      	ElseIf GadgetID = #StartPos
      		*gCurrentCue\startPos = StringToSeconds(GetGadgetText(#StartPos))
      	ElseIf GadgetID = #EndPos
      		*gCurrentCue\endPos = StringToSeconds(GetGadgetText(#EndPos))
      	ElseIf GadgetID = #FadeIn
      		*gCurrentCue\fadeIn = ValF(GetGadgetText(#FadeIn))
      	ElseIf GadgetID = #FadeOut
      		*gCurrentCue\fadeOut = ValF(GetGadgetText(#FadeOut))
      	ElseIf GadgetID = #VolumeSlider
      		*gCurrentCue\volume = GetGadgetState(#VolumeSlider) / 100
      		UpdateCueControls()
      	ElseIf GadgetID = #PanSlider
      		*gCurrentCue\pan = (GetGadgetState(#PanSlider) - 100) / 100
      		UpdateCueControls()
      	ElseIf GadgetID = #DeleteButton
      		If *gCurrentCue <> 0
      			DeleteCue(*gCurrentCue)
      			*gCurrentCue = 0
      			UpdateEditorList()
      		EndIf
      	ElseIf GadgetID = #UpButton
      		If *gCurrentCue <> 0 And *gCurrentCue <> FirstElement(cueList())
      			GetCueListIndex(*gCurrentCue)
      			*prev.Cue = PreviousElement(cueList())
      			SwapElements(cueList(),*gCurrentCue,*prev)
      			UpdateEditorList()
      		EndIf
      	ElseIf GadgetID = #DownButton
			If *gCurrentCue <> 0 And *gCurrentCue <> LastElement(cueList())
				GetCueListIndex(*gCurrentCue)
				*nex.Cue = NextElement(cueList())
				SwapElements(cueList(),*gCurrentCue,*nex)
				UpdateEditorList()
			EndIf
		ElseIf GadgetID = #StartDelay
			*gCurrentCue\delay = ValF(GetGadgetText(#StartDelay)) * 1000
		ElseIf GadgetID = #CueSelect
			tmpState = GetGadgetState(#CueSelect)
			
			If tmpState > -1
				If *gCurrentCue\afterCue <> 0
					ForEach *gCurrentCue\afterCue\followCues()
						If *gCurrentCue\afterCue\followCues() = *gCurrentCue
							DeleteElement(*gCurrentCue\afterCue\followCues())
						EndIf
					Next
				EndIf
				
				*tmp.Cue = GetGadgetItemData(#CueSelect, tmpState)
				
				If *tmp <> 0
					*gCurrentCue\afterCue = *tmp
					
					AddElement(*tmp\followCues())
					*tmp\followCues() = *gCurrentCue
				EndIf
			EndIf
		ElseIf GadgetID = #ChangeDur
			*gCurrentCue\fadeIn = Val(GetGadgetText(#ChangeDur))
		EndIf
		     
	EndIf
	
	For i = 0 To 5
		If GadgetID = eventCueSelect(i)
			*gCurrentCue\actionCues[i] = GetGadgetItemData(eventCueSelect(i),GetGadgetState(eventCueSelect(i)))
		EndIf
		
		If GadgetID = eventActionSelect(i)
			*gCurrentCue\actions[i] = GetGadgetItemData(eventActionSelect(i),GetGadgetState(eventActionSelect(i)))
		EndIf
	Next i
	
	
	If Event = #PB_Event_CloseWindow
		If EventWindow() = #EditorWindow
			gEditor = #False
			HideWindow(#EditorWindow,1)
			UpdateMainCueList()
		ElseIf EventWindow = #MainWindow
			End
		EndIf
	EndIf
  
ForEver

Procedure UpdateEditorList()
	ClearGadgetItems(#EditorList)
	
	i = 0
	
	ForEach cueList()
		text.s = cueList()\name + "  " + cueList()\desc
		Select cueList()\cueType
			Case #TYPE_AUDIO
				text = text + "  (Audio)"
			Case #TYPE_VIDEO
				text = text + "  (Video)"
			Case #TYPE_CHANGE
				text = text + "  (Change)"
			Case #TYPE_EVENT
				text = text + "  (Event)"
		EndSelect
		
		AddGadgetItem(#EditorList,i,text)
		SetGadgetItemData(#EditorList,i,@cueList())
		
		If @cueList() = *gCurrentCue
			SetGadgetState(#EditorList,i)
		EndIf
		
		i + 1
	Next
	
	ProcedureReturn i
EndProcedure

Procedure HideCueControls()
	gControlsHidden = #True
	
	HideGadget(#CueNameField,1)
	HideGadget(#CueDescField,1)
	HideGadget(#Text_3,1)
	HideGadget(#Text_4,1)
	HideGadget(#ModeSelect,1)
	HideGadget(#Text_8,1)
	HideGadget(#Text_16,1)
	HideGadget(#Text_17,1)
	HideGadget(#CueSelect,1)
	HideGadget(#StartDelay,1)
	HideGadget(#CueFileField,1)
	HideGadget(#OpenCueFile,1)
	HideGadget(#LengthField,1)
	HideGadget(#Text_6,1)
	HideGadget(#Text_9,1)
	HideGadget(#PreviewButton,1)
	HideGadget(#Text_10,1)
	HideGadget(#Text_11,1)
	HideGadget(#StartPos,1)
	HideGadget(#EndPos,1)
	HideGadget(#Text_12,1)
	HideGadget(#Text_13,1)
	HideGadget(#FadeIn,1)
	HideGadget(#FadeOut,1)
	HideGadget(#Text_14,1)
	HideGadget(#Text_15,1)
	HideGadget(#CueVolume,1)
	HideGadget(#CuePan,1)
	HideGadget(#VolumeSlider,1)
	HideGadget(#PanSlider,1)
	HideGadget(#WaveImg,1)
	HideGadget(#Text_18,1)
	HideGadget(#Text_19,1)
	HideGadget(#Text_20,1)
	HideGadget(#ChangeDur,1)
	
	For i = 0 To 5
		HideGadget(eventCueSelect(i),1)
		HideGadget(eventActionSelect(i),1)
	Next i
EndProcedure

Procedure ShowCueControls()
	If *gCurrentCue <> 0
		HideCueControls()
		
		gControlsHidden = #False
		HideGadget(#CueNameField,0)
		HideGadget(#CueDescField,0)
		HideGadget(#Text_3,0)
		HideGadget(#Text_4,0)
		HideGadget(#ModeSelect,0)
		HideGadget(#Text_8,0)
		HideGadget(#Text_16,0)
		HideGadget(#Text_17,0)
		HideGadget(#CueSelect,0)
		HideGadget(#StartDelay,0)
		
		Select *gCurrentCue\cueType
			Case #TYPE_AUDIO
				HideGadget(#CueFileField,0)
				HideGadget(#OpenCueFile,0)
				HideGadget(#LengthField,0)
				HideGadget(#Text_6,0)
				HideGadget(#Text_9,0)
				HideGadget(#PreviewButton,0)
				HideGadget(#Text_10,0)
				HideGadget(#Text_11,0)
				HideGadget(#StartPos,0)
				HideGadget(#EndPos,0)
				HideGadget(#Text_12,0)
				HideGadget(#Text_13,0)
				HideGadget(#FadeIn,0)
				HideGadget(#FadeOut,0)
				HideGadget(#Text_14,0)
				HideGadget(#Text_15,0)
				HideGadget(#CueVolume,0)
				HideGadget(#CuePan,0)
				HideGadget(#VolumeSlider,0)
				HideGadget(#PanSlider,0)
				HideGadget(#WaveImg,0)
			Case #TYPE_EVENT
				HideGadget(#Text_18,0)
				HideGadget(#Text_19,0)
				
				For i = 0 To 5
					HideGadget(eventCueSelect(i),0)
					HideGadget(eventActionSelect(i),0)
				Next i
			Case #TYPE_CHANGE
				HideGadget(#Text_14,0)
				HideGadget(#Text_15,0)
				HideGadget(#CueVolume,0)
				HideGadget(#CuePan,0)
				HideGadget(#VolumeSlider,0)
				HideGadget(#PanSlider,0)
				HideGadget(#Text_20,0)
				HideGadget(#ChangeDur,0)
				HideGadget(#Text_18,0)
				HideGadget(eventCueSelect(0),0)
		EndSelect
	EndIf
EndProcedure

Procedure UpdateCueControls()
	SetGadgetText(#CueNameField,*gCurrentCue\name)
	SetGadgetText(#CueDescField,*gCurrentCue\desc)
	SetGadgetText(#CueFileField,*gCurrentCue\filePath)
		
	SetGadgetText(#LengthField,SecondsToString(*gCurrentCue\length))
		
	SetGadgetText(#StartPos,SecondsToString(*gCurrentCue\startPos))
	SetGadgetText(#EndPos,SecondsToString(*gCurrentCue\endPos))
		
	SetGadgetText(#FadeIn,StrF(*gCurrentCue\fadeIn,2))
	SetGadgetText(#FadeOut,StrF(*gCurrentCue\fadeOut,2))
		
	SetGadgetState(#VolumeSlider,*gCurrentCue\volume * 100)
	SetGadgetState(#PanSlider,*gCurrentCue\pan * 100 + 100)
	SetGadgetText(#CueVolume,Str(*gCurrentCue\volume * 100))
	SetGadgetText(#CuePan,Str(*gCurrentCue\pan * 100))
		
	SetGadgetText(#StartDelay,StrF(*gCurrentCue\delay / 1000.0,2))
	
	SetGadgetText(#ChangeDur,StrF(*gCurrentCue\fadeIn,2))
		
	ClearGadgetItems(#CueSelect)
	If *gCurrentCue\startMode = #START_AFTER_END Or *gCurrentCue\startMode = #START_AFTER_START
		DisableGadget(#CueSelect, 0)
		i = 0
		ForEach cueList()
			If @cueList() <> *gCurrentCue
				AddGadgetItem(#CueSelect, i, cueList()\name + "  " + cueList()\desc)
				SetGadgetItemData(#CueSelect, i, @cueList())
				
				If @cueList() = *gCurrentCue\afterCue
					SetGadgetState(#CueSelect, i)
				EndIf
					
				i + 1
			EndIf
							
		Next
	Else
		DisableGadget(#CueSelect, 1)
	EndIf
	
	Select *gCurrentCue\startMode
		Case #START_MANUAL
			SetGadgetState(#ModeSelect, 0)
		Case #START_AFTER_START
			SetGadgetState(#ModeSelect, 1)
		Case #START_AFTER_END
			SetGadgetState(#ModeSelect, 2)
		Case #START_HOTKEY
			SetGadgetState(#ModeSelect, 3)
	EndSelect
	
	If *gCurrentCue\waveform <> 0
		SetGadgetState(#WaveImg,ImageID(*gCurrentCue\waveform))
	Else
		SetGadgetState(#WaveImg,0)
	EndIf
	
	
	For i = 0 To 5
		ClearGadgetItems(eventCueSelect(i))
		ClearGadgetItems(eventActionSelect(i))
		
		k = 0
		ForEach cueList()
			If @cueList() <> *gCurrentCue
				AddGadgetItem(eventCueSelect(i), k, cueList()\name + "  " + cueList()\desc)
				SetGadgetItemData(eventCueSelect(i), k, @cueList())
				
				If @cueList() = *gCurrentCue\actionCues[i]
					SetGadgetState(eventCueSelect(i), k)
				EndIf
				
				k + 1
			EndIf
		Next
		
		AddGadgetItem(eventActionSelect(i), 0 , "Fade out")
		SetGadgetItemData(eventActionSelect(i), 0, #EVENT_FADE_OUT)
		AddGadgetItem(eventActionSelect(i), 1, "Stop")
		SetGadgetItemData(eventActionSelect(i), 1, #EVENT_STOP)
		
		If *gCurrentCue\actions[i] = #EVENT_FADE_OUT
			SetGadgetState(eventActionSelect(i), 0)
		ElseIf *gCurrentCue\actions[i] = #EVENT_STOP
			SetGadgetState(eventActionSelect(i), 1)
		EndIf
		
	Next i
	
EndProcedure

Procedure PlayCue(*cue.Cue)
	If *cue\stream <> 0
		If *cue\delay > 0 And *cue\state = #STATE_STOPPED
			*cue\state = #STATE_WAITING
			*cue\startTime = ElapsedMilliseconds()
		Else
			*cue\state = #STATE_PLAYING
			*cue\startTime = ElapsedMilliseconds()
			BASS_ChannelSetPosition(*cue\stream,BASS_ChannelSeconds2Bytes(*cue\stream,*cue\startPos),#BASS_POS_BYTE)
			BASS_ChannelSetAttribute(*cue\stream,#BASS_ATTRIB_VOL,*cue\volume)
			BASS_ChannelSetAttribute(*cue\stream,#BASS_ATTRIB_PAN,*cue\pan)
			BASS_ChannelPlay(*cue\stream,0)
			
			If *cue\fadeIn > 0
				BASS_ChannelSetAttribute(*cue\stream,#BASS_ATTRIB_VOL,0)
				BASS_ChannelSlideAttribute(*cue\stream,#BASS_ATTRIB_VOL,*cue\volume,*cue\fadeIn * 1000)
			EndIf
			
			ForEach *cue\followCues()
				If *cue\followCues()\startMode = #START_AFTER_START
					PlayCue(*cue\followCues())
				ElseIf *cue\followCues()\startMode = #START_AFTER_END
					*cue\followCues()\state = #STATE_WAITING_END
				EndIf
			Next
		EndIf

		ProcedureReturn #True
	Else
		ProcedureReturn #False
	EndIf
EndProcedure

Procedure StopCue(*cue.Cue)
	If *cue\stream <> 0
		*cue\state = #STATE_STOPPED
		BASS_ChannelStop(*cue\stream)
		
		ForEach *cue\followCues()
			If *cue\followCues()\startMode = #START_AFTER_END
				PlayCue(*cue\followCues())
			EndIf
		Next
		
		ProcedureReturn #True
	Else
		ProcedureReturn #False
	EndIf
EndProcedure

Procedure PauseCue(*cue.Cue)
	If *cue\stream <> 0
		If *cue\state = #STATE_PLAYING
			*cue\state = #STATE_PAUSED
			*cue\pauseTime = ElapsedMilliseconds()
			BASS_ChannelPause(*cue\stream)
			
			ProcedureReturn #True
		ElseIf *cue\state = #STATE_PAUSED
			*cue\state = #STATE_PLAYING
			BASS_ChannelPlay(*cue\stream,0)
			
			ProcedureReturn #True
		EndIf
		
		ProcedureReturn #False
	Else
		ProcedureReturn #False
	EndIf
EndProcedure

Procedure StartEvents(*cue.Cue)
	If *cue\cueType = #TYPE_EVENT
		For i = 0 To 5
			If *cue\actionCues[i] <> 0
				Select *cue\actions[i]
					Case #EVENT_FADE_OUT
						*cue\actionCues[i]\state = #STATE_FADING_OUT
						BASS_ChannelSlideAttribute(*cue\actionCues[i]\stream,#BASS_ATTRIB_VOL,0,*cue\actionCues[i]\fadeOut * 1000)
					Case #EVENT_STOP
						StopCue(*cue\actionCues[i])
				EndSelect
			EndIf
		Next i
	ElseIf *cue\cueType = #TYPE_CHANGE
		If *cue\actionCues[0] <> 0
			BASS_ChannelSlideAttribute(*cue\actionCues[0]\stream,#BASS_ATTRIB_VOL,*cue\volume,*cue\fadeIn * 1000)
			BASS_ChannelSlideAttribute(*cue\actionCues[0]\stream,#BASS_ATTRIB_PAN,*cue\pan,*cue\fadeIn * 1000)
		EndIf
	EndIf
	
EndProcedure

Procedure UpdateCues()
	ForEach cueList()
		If cueList()\state = #STATE_PLAYING		
			pos = BASS_ChannelBytes2Seconds(cueList()\stream,BASS_ChannelGetPosition(cueList()\stream,#BASS_POS_BYTE))
			
			If cueList()\fadeOut > 0
				If pos >= (cueList()\endPos - cueList()\fadeOut) And BASS_ChannelIsSliding(cueList()\stream,#BASS_ATTRIB_VOL) = 0
					cueList()\state = #STATE_FADING_OUT
					BASS_ChannelSlideAttribute(cueList()\stream,#BASS_ATTRIB_VOL,0,cueList()\fadeOut * 1000)
				EndIf
			EndIf
			
			If pos >= cueList()\endPos ;And Not BASS_ChannelIsSliding(cueList()\stream,#BASS_ATTRIB_VOL)
				StopCue(@cueList())
			EndIf
		ElseIf cueList()\state = #STATE_WAITING
			If ElapsedMilliseconds() >= (cueList()\startTime + cueList()\delay)
				PlayCue(@cueList())
			EndIf
		ElseIf cueList()\state = #STATE_FADING_OUT And Not BASS_ChannelIsSliding(cueList()\stream,#BASS_ATTRIB_VOL)
			StopCue(@cueList())
		EndIf
		
	Next
EndProcedure

Procedure UpdateMainCueList()
	ClearGadgetItems(#CueList)
	
	i = 0
	
	ForEach cueList()
		Select cueList()\cueType
			Case #TYPE_AUDIO
				text.s = "Audio"
				color = RGB(0,200,200)
			Case #TYPE_VIDEO
				text.s = "Video"
			Case #TYPE_CHANGE
				text.s = "Change"
				color = RGB(200,0,200)
			Case #TYPE_EVENT
				text.s = "Event"
				color = RGB(200,200,0)
		EndSelect
		
		Select cueList()\startMode
			Case #START_MANUAL
				start.s = "Manual"
			Case #START_HOTKEY
				start.s = "Hotkey"
			Case #START_AFTER_START
				start.s = StrF(cueList()\delay / 1000,2) + " as "
				If cueList()\afterCue <> 0
					start = start + cueList()\afterCue\name
				EndIf
			Case #START_AFTER_END
				start.s = StrF(cueList()\delay / 1000,2) + " ae "
				If cueList()\afterCue <> 0
					start = start + cueList()\afterCue\name
				EndIf
		EndSelect
		
		Select cueList()\state
			Case #STATE_STOPPED
				state.s = "Stopped"
			Case #STATE_WAITING
				state.s = "Waiting to start"
			Case #STATE_WAITING_END
				state.s = "Waiting to start"
			Case #STATE_PLAYING
				state.s = "Playing"
			Case #STATE_DONE
				state.s = "Done"
			Case #STATE_PAUSED
				state.s = "Paused"
		EndSelect
		
		AddGadgetItem(#CueList, i, cueList()\name + "  " + cueList()\desc + Chr(10) + text + Chr(10) + start + Chr(10) + state)
		SetGadgetItemData(#CueList, i, @cueList())
		SetGadgetItemColor(#CueList, i, #PB_Gadget_BackColor, color, -1)
		
		If @cueList() = *gCurrentCue
			SetGadgetState(#CueList,i)
		EndIf
		
		i + 1
	Next
EndProcedure
; IDE Options = PureBasic 4.50 (Windows - x86)
; CursorPosition = 63
; FirstLine = 28
; Folding = Aw
; EnableXP