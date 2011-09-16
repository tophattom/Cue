;
; PureBasic Visual Designer v3.95 build 1485 (PB4Code)


;- Window Constants
;
Enumeration
  #MainWindow
  #EditorWindow
EndEnumeration

;- MenuBar Constants
;
Enumeration
  #MenuBar
EndEnumeration

Enumeration
  #MenuNew
  #MenuOpen
  #MenuSave
  #MenuSaveAs
  #MenuPref
  #MenuExit
  #MenuAbout
EndEnumeration

;- Gadget Constants
;
Enumeration
  #Frame3D_0
  #PlayButton
  #PauseButton
  #StopButton
  #Listview_1
  #CueList
  #Frame3D_2
  #EditorButton
  #EditorList
  #AddAudio
  #AddChange
  #AddEvent
  #AddVideo
  #MasterSlider
  #Text_2
EndEnumeration

;- Fonts
Global FontID1
FontID1 = LoadFont(1, "Tahoma", 14)

Procedure Open_MainWindow()
  If OpenWindow(#MainWindow, 479, 152, 1024, 768, "Cue",  #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget | #PB_Window_SizeGadget | #PB_Window_TitleBar | #PB_Window_ScreenCentered )
    If CreateMenu(#MenuBar, WindowID(#MainWindow))
      MenuTitle("File")
      MenuItem(#MenuNew, "New...")
      MenuItem(#MenuOpen, "Open...")
      MenuItem(#MenuSave, "Save")
      MenuItem(#MenuSaveAs, "Save As...")
      MenuBar()
      MenuItem(#MenuPref, "Preferences...")
      MenuBar()
      MenuItem(#MenuExit, "Exit")
      MenuTitle("Help")
      MenuItem(#MenuAbout, "About")
      EndIf

      ;If CreateGadgetList(WindowID(#MainWindow))
        Frame3DGadget(#Frame3D_0, 10, 0, 280, 80, "Controls")
        ButtonGadget(#PlayButton, 20, 20, 80, 50, "Play next")
        ButtonGadget(#PauseButton, 110, 20, 80, 50, "Pause")
        ButtonGadget(#StopButton, 200, 20, 80, 50, "Stop all")
        ListViewGadget(#Listview_1, 10, 420, 1010, 320)
        
        ;-
        ListIconGadget(#CueList, 10, 90, 1010, 320, "Cue Name", 300)
        AddGadgetColumn(#CueList, 1, "Cue type", 100)
        AddGadgetColumn(#CueList, 2, "Start mode", 100)
        Frame3DGadget(#Frame3D_2, 310, 0, 250, 80, "Actions")
        ButtonGadget(#EditorButton, 320, 20, 80, 50, "Editor")
        TrackBarGadget(#MasterSlider, 730, 50, 290, 30, 0, 100)
        SetGadgetState(#MasterSlider,100)
        TextGadget(#Text_2, 730, 30, 210, 20, "Master volume")
        
      ;EndIf
    EndIf
EndProcedure

Procedure Open_EditorWindow()
  If OpenWindow(#EditorWindow, 533, 221, 910, 710, "Cue - Editor",  #PB_Window_SystemMenu | #PB_Window_Invisible | #PB_Window_TitleBar | #PB_Window_ScreenCentered )
    ;If CreateGadgetList(WindowID(#EditorWindow))
      ListViewGadget(#EditorList, 10, 50, 200, 640)
      ButtonGadget(#AddAudio, 10, 10, 130, 30, "Add audio cue")
      ButtonGadget(#AddChange, 290, 10, 130, 30, "Add level change cue")
      ButtonGadget(#AddEvent, 430, 10, 130, 30, "Add event cue")
      ButtonGadget(#AddVideo, 150, 10, 130, 30, "")
      
    ;EndIf
  EndIf
EndProcedure


; IDE Options = PureBasic 4.50 (Windows - x86)
; CursorPosition = 52
; FirstLine = 29
; Folding = -
; EnableXP