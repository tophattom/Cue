; PureBasic Visual Designer v3.95 build 1485 (PB4Code)

Declare UpdateEditorList()
Declare HideCueControls(value)
Declare UpdateCueControls()

IncludeFile "util.pbi"
IncludeFile "ui.pb"

UseOGGSoundDecoder()
UseFLACSoundDecoder()

InitMovie()
InitSound()

Open_MainWindow()
Open_EditorWindow()
HideWindow(#EditorWindow, 1)
HideCueControls(1)

Repeat ; Start of the event loop
  
	Event = WaitWindowEvent() ; This line waits until an event is received from Windows
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
    				pattern.s = "Audio files (*.mp3,*.wav,*.ogg,*.flac) |*.mp3;*.wav;*.ogg;*.flac"
    		EndSelect
    		
    		path.s = OpenFileRequester("Select file","",pattern,0)
    		
    		If path
    			*gCurrentCue\filePath = path
    			
    			Select *gCurrentCue\cueType
    				Case #TYPE_AUDIO
    					If GetExtensionPart(path) = "mp3"
    						*gCurrentCue\file = LoadMovie(#PB_Any,path)
    					Else
    						*gCurrentCue\file = LoadSound(#PB_Any,path)
    					EndIf
    			EndSelect
    			
    			UpdateCueControls()
    		EndIf
    	ElseIf GadgetID = #Image_1
      
    	ElseIf GadgetID = #ModeSelect
      		*gCurrentCue\startMode = GetGadgetItemData(#ModeSelect,GetGadgetState(#ModeSelect))
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
	HideGadget(#ModeSelect,value)
	HideGadget(#Text_3,value)
	HideGadget(#Text_4,value)
	HideGadget(#Text_6,value)
	HideGadget(#Text_8,value)
EndProcedure

Procedure UpdateCueControls()
	SetGadgetText(#CueNameField,*gCurrentCue\name)
	SetGadgetText(#CueDescField,*gCurrentCue\desc)
	SetGadgetText(#CueFileField,*gCurrentCue\filePath)
EndProcedure
; IDE Options = PureBasic 4.50 (Windows - x86)
; CursorPosition = 13
; Folding = 9
; EnableXP