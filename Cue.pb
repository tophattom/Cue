; PureBasic Visual Designer v3.95 build 1485 (PB4Code)

Declare UpdateEditorList()

IncludeFile "util.pbi"
IncludeFile "ui.pb"

Open_MainWindow()
Open_EditorWindow()
HideWindow(#EditorWindow, 1)

Repeat ; Start of the event loop
  
	Event = WaitWindowEvent() ; This line waits until an event is received from Windows
	WindowID = EventWindow() ; The Window where the event is generated, can be used in the gadget procedures
	GadgetID = EventGadget() ; Is it a gadget event?
	EventType = EventType() ; The event type
	  
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
	
	ForEach cueList()
		AddGadgetItem(#EditorList,-1,cueList()\name + "  " + cueList()\desc)
	Next
EndProcedure

; IDE Options = PureBasic 4.50 (Windows - x86)
; CursorPosition = 69
; FirstLine = 35
; Folding = -
; EnableXP