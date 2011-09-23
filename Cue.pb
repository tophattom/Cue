; PureBasic Visual Designer v3.95 build 1485 (PB4Code)


IncludeFile "includes\bass.pbi"
IncludeFile "includes\util.pbi"
IncludeFile "includes\ui.pb"

Declare UpdateEditorList()
Declare HideCueControls(value)
Declare UpdateCueControls()
Declare PlayCue(*cue.Cue)
Declare PauseCue(*cue.Cue)
Declare StopCue(*cue.Cue)
Declare UpdateCues()
Declare UpdateMainCueList()

Open_MainWindow()
Open_EditorWindow()
HideWindow(#EditorWindow, 1)
HideCueControls(1)

BASS_Init(-1,44100,0,WindowID(#MainWindow),#Null)


Repeat ; Start of the event loop
	
	Event = WindowEvent() ; This line waits until an event is received from Windows
	WindowID = EventWindow() ; The Window where the event is generated, can be used in the gadget procedures
	GadgetID = EventGadget() ; Is it a gadget event?
	EventType = EventType() ; The event type
	
	
	If *gCurrentCue <> 0
		HideCueControls(0)
	Else
		HideCueControls(1)
	EndIf
	
	UpdateCues()
	
	;You can place code here, and use the result as parameters for the procedures
	  
	If Event = #PB_Event_Menu
		MenuID = EventMenu()
		   
		If MenuID = #MenuNew
			Debug "GadgetID: #MenuNew"
		
		ElseIf MenuID = #MenuOpen
			Debug "GadgetID: #MenuOpen"
		      
		ElseIf MenuID = #MenuSave
			Debug "GadgetID: #MenuSave"
		      
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
				PlayCue(*gCurrentCue)
				GetCueListIndex(*gCurrentCue)
				
				*gCurrentCue = NextElement(cueList())

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

			If EventType() = #PB_EventType_LeftDoubleClick
				gEditor = #True
				HideWindow(#EditorWindow,0)
				UpdateEditorList()
				UpdateCueControls()
			EndIf
		ElseIf GadgetID = #EditorButton
		   	HideWindow(#EditorWindow,0)
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
		ElseIf GadgetID = #AddEvent
			*gCurrentCue = AddCue(#TYPE_EVENT)
			UpdateEditorList()
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
    					If *gCurrentCue\stream <> 0
    						BASS_StreamFree(*gCurrentCue\stream)
    					EndIf
    					
    					*gCurrentCue\stream = BASS_StreamCreateFile(0,@path,0,0,0)
    					
    					*gCurrentCue\length = BASS_ChannelBytes2Seconds(*gCurrentCue\stream,BASS_ChannelGetLength(*gCurrentCue\stream,#BASS_POS_BYTE))
    					
    					*gCurrentCue\startPos = 0
    					*gCurrentCue\endPos = *gCurrentCue\length
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
      		*gCurrentCue\playTime = (*gCurrentCue\endPos - *gCurrentCue\startPos)
      	ElseIf GadgetID = #EndPos
      		*gCurrentCue\endPos = StringToSeconds(GetGadgetText(#EndPos))
      		*gCurrentCue\playTime = (*gCurrentCue\endPos - *gCurrentCue\startPos)
      	ElseIf GadgetID = #FadeIn
      		*gCurrentCue\fadeIn = Val(GetGadgetText(#FadeIn))
      	ElseIf GadgetID = #FadeOut
      		*gCurrentCue\fadeOut = Val(GetGadgetText(#FadeOut))
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
			UpdateCueControls()
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
		EndIf
		     
	EndIf
	
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

Procedure HideCueControls(value)
	HideGadget(#CueNameField,value)
	HideGadget(#CueDescField,value)
	HideGadget(#CueFileField,value)
	HideGadget(#OpenCueFile,value)
	HideGadget(#LengthField,value)
	HideGadget(#ModeSelect,value)
	HideGadget(#Text_3,value)
	HideGadget(#Text_4,value)
	HideGadget(#Text_6,value)
	HideGadget(#Text_8,value)
	HideGadget(#Text_9,value)
	HideGadget(#PreviewButton,value)
	HideGadget(#Text_10,value)
	HideGadget(#Text_11,value)
	HideGadget(#StartPos,value)
	HideGadget(#EndPos,value)
	HideGadget(#Text_12,value)
	HideGadget(#Text_13,value)
	HideGadget(#FadeIn,value)
	HideGadget(#FadeOut,value)
	HideGadget(#Text_14,value)
	HideGadget(#Text_15,value)
	HideGadget(#CueVolume,value)
	HideGadget(#CuePan,value)
	HideGadget(#VolumeSlider,value)
	HideGadget(#PanSlider,value)
	HideGadget(#Text_16,value)
	HideGadget(#Text_17,value)
	HideGadget(#CueSelect,value)
	HideGadget(#StartDelay,value)
EndProcedure

Procedure UpdateCueControls()
	SetGadgetText(#CueNameField,*gCurrentCue\name)
	SetGadgetText(#CueDescField,*gCurrentCue\desc)
	SetGadgetText(#CueFileField,*gCurrentCue\filePath)
	
	SetGadgetText(#LengthField,SecondsToString(*gCurrentCue\length))
	
	SetGadgetText(#StartPos,SecondsToString(*gCurrentCue\startPos))
	SetGadgetText(#EndPos,SecondsToString(*gCurrentCue\endPos))
	
	SetGadgetText(#FadeIn,Str(*gCurrentCue\fadeIn))
	SetGadgetText(#FadeOut,Str(*gCurrentCue\fadeOut))
	
	SetGadgetState(#VolumeSlider,*gCurrentCue\volume * 100)
	SetGadgetState(#PanSlider,*gCurrentCue\pan * 100 + 100)
	SetGadgetText(#CueVolume,Str(*gCurrentCue\volume * 100))
	SetGadgetText(#CuePan,Str(*gCurrentCue\pan * 100))
	
	SetGadgetText(#StartDelay,StrF(*gCurrentCue\delay / 1000.0,2))
	
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

Procedure UpdateCues()
	ForEach cueList()
		If cueList()\state = #STATE_PLAYING		
			pos = BASS_ChannelBytes2Seconds(cueList()\stream,BASS_ChannelGetPosition(cueList()\stream,#BASS_POS_BYTE))
			
			If cueList()\fadeOut > 0
				If pos >= (cueList()\endPos - cueList()\fadeOut) And BASS_ChannelIsSliding(cueList()\stream,#BASS_ATTRIB_VOL) = 0
					BASS_ChannelSlideAttribute(cueList()\stream,#BASS_ATTRIB_VOL,0,cueList()\fadeOut * 1000)
				EndIf
			EndIf
			
			If pos >= cueList()\endPos And Not BASS_ChannelIsSliding(cueList()\stream,#BASS_ATTRIB_VOL)
				StopCue(@cueList())
			EndIf

		ElseIf cueList()\state = #STATE_WAITING
			If ElapsedMilliseconds() >= (cueList()\startTime + cueList()\delay)
				PlayCue(@cueList())
			EndIf
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
				color = RGB(100,100,200)
			Case #TYPE_VIDEO
				text.s = "Video"
			Case #TYPE_CHANGE
				text.s = "Change"
				color = RGB(100,200,100)
			Case #TYPE_EVENT
				text.s = "Event"
				color = RGB(200,200,100)
		EndSelect
		
		Select cueList()\startMode
			Case #START_MANUAL
				start.s = "Manual"
			Case #START_HOTKEY
				start.s = "Hotkey"
			Case #START_AFTER_START
				start.s = "After start"
			Case #START_AFTER_END
				start.s = "After end"
		EndSelect
		
		Select cueList()\state
			Case #STATE_STOPPED
				state.s = "Stopped"
			Case #STATE_WAITING
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
; CursorPosition = 226
; FirstLine = 199
; Folding = I9
; EnableXP