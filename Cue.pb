; PureBasic Visual Designer v3.95 build 1485 (PB4Code)

Declare UpdateEditorList()
Declare HideCueControls(value)
Declare UpdateCueControls()

IncludeFile "includes\bass.pbi"
IncludeFile "includes\util.pbi"
IncludeFile "includes\ui.pb"


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
		      
		ElseIf GadgetID = #PauseButton
		      
		ElseIf GadgetID = #StopButton
		      
		ElseIf GadgetID = #Listview_1
		      
		ElseIf GadgetID = #CueList
			If EventType() = #PB_EventType_LeftDoubleClick
				HideWindow(#EditorWindow,0)
			EndIf
		ElseIf GadgetID = #EditorButton
		   	HideWindow(#EditorWindow,0)
		ElseIf GadgetID = #EditorList
			*gCurrentCue = GetCueById(GetGadgetItemData(#EditorList,GetGadgetState(#EditorList)))
			
			If *gCurrentCue <> 0
				UpdateCueControls()
			EndIf
		ElseIf GadgetID = #AddAudio
			*gCurrentCue = AddCue(#TYPE_AUDIO)
			UpdateEditorList()
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
    					*gCurrentCue\stream = BASS_StreamCreateFile(0,@path,0,0,0)
    					
    					*gCurrentCue\length = BASS_ChannelBytes2Seconds(*gCurrentCue\stream,BASS_ChannelGetLength(*gCurrentCue\stream,#BASS_POS_BYTE))
    					
    					*gCurrentCue\startPos = 0
    					*gCurrentCue\endPos = *gCurrentCue\length
    			EndSelect
    			
    			If *gCurrentCue\desc = ""
    				*gCurrentCue\desc = GetFilePart(path)
    			EndIf
    			
    			UpdateCueControls()
    			UpdateEditorList()
    		EndIf
    	ElseIf GadgetID = #Image_1
      
    	ElseIf GadgetID = #ModeSelect
      		*gCurrentCue\startMode = GetGadgetItemData(#ModeSelect,GetGadgetState(#ModeSelect))
      	ElseIf GadgetID = #PreviewButton
      		If *gCurrentCue\stream <> 0
      			If GetGadgetState(#PreviewButton) = 1
      				BASS_ChannelSetPosition(*gCurrentCue\stream,BASS_ChannelSeconds2Bytes(*gCurrentCue\stream,*gCurrentCue\startPos),#BASS_POS_BYTE)
      				BASS_ChannelPlay(*gCurrentCue\stream,0)
      			Else
      				BASS_ChannelStop(*gCurrentCue\stream)
      			EndIf
      		EndIf
      	ElseIf GadgetID = #StartPos
      		*gCurrentCue\startPos = StringToSeconds(GetGadgetText(#StartPos))
      	ElseIf GadgetID = #EndPos
      		*gCurrentCue\endPos = StringToSeconds(GetGadgetText(#EndPos))
      	EndIf
	EndIf
	
	If Event = #PB_Event_CloseWindow
		If EventWindow() = #EditorWindow
			HideWindow(#EditorWindow,1)
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
		SetGadgetItemData(#EditorList,i,cueList()\id)
		
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
EndProcedure

Procedure UpdateCueControls()
	SetGadgetText(#CueNameField,*gCurrentCue\name)
	SetGadgetText(#CueDescField,*gCurrentCue\desc)
	SetGadgetText(#CueFileField,*gCurrentCue\filePath)
	
	SetGadgetText(#LengthField,SecondsToString(*gCurrentCue\length))
	
	SetGadgetText(#StartPos,SecondsToString(*gCurrentCue\startPos))
	SetGadgetText(#EndPos,SecondsToString(*gCurrentCue\endPos))
EndProcedure
; IDE Options = PureBasic 4.50 (Windows - x86)
; CursorPosition = 137
; FirstLine = 100
; Folding = +
; EnableXP