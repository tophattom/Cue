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
  #PreviewButton
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
  #DeleteImg
  #UpImg
  #DownImg
  #Text_16
  #CueSelect
  #Text_17
  #StartDelay
  #WaveImg
  #Text_18
  #Text_19
EndEnumeration

Global Dim eventCueSelect(5)
Global Dim eventActionSelect(5)

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
        ButtonGadget(#PlayButton, 20, 20, 80, 50, "Play")
        ButtonGadget(#PauseButton, 110, 20, 80, 50, "Pause")
        ButtonGadget(#StopButton, 200, 20, 80, 50, "Stop all")
        ListViewGadget(#Listview_1, 10, 420, 1010, 320)
        
        
        ListIconGadget(#CueList, 10, 90, 1010, 320, "Cue", 300, #PB_ListIcon_FullRowSelect | #PB_ListIcon_AlwaysShowSelection)
        AddGadgetColumn(#CueList, 1, "Cue type", 100)
        AddGadgetColumn(#CueList, 2, "Start mode", 100)
        AddGadgetColumn(#CueList, 3, "State", 100)
        
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
    ListViewGadget(#EditorList, 10, 50, 200, 605)
    
    LoadImage(#DeleteImg,"Images/delete.ico")
    LoadImage(#UpImg,"Images/up.ico")
    LoadImage(#DownImg,"Images/down.ico")
    ButtonImageGadget(#DeleteButton, 180, 660, 30, 30, ImageID(#DeleteImg))
    ButtonImageGadget(#UpButton, 10, 660, 30, 30, ImageID(#UpImg))
    ButtonImageGadget(#DownButton, 45, 660, 30, 30, ImageID(#DownImg))
    
    ButtonGadget(#AddAudio, 10, 10, 130, 30, "Add audio cue")
    ButtonGadget(#AddChange, 290, 10, 130, 30, "Add level change cue")
    ButtonGadget(#AddEvent, 430, 10, 130, 30, "Add event cue")
    ButtonGadget(#AddVideo, 150, 10, 130, 30, "")
      
      StringGadget(#CueNameField, 290, 50, 300, 20, "")
      TextGadget(#Text_3, 220, 50, 40, 20, "Name:")
      StringGadget(#CueDescField, 290, 80, 300, 20, "")
      TextGadget(#Text_4, 220, 80, 60, 20, "Description:")
      StringGadget(#CueFileField, 290, 140, 300, 20, "")
      TextGadget(#Text_6, 220, 140, 60, 20, "File:")
      ButtonGadget(#OpenCueFile, 600, 140, 30, 20, "...")
      TextGadget(#Text_9, 220, 170, 60, 20, "Length:")
      StringGadget(#LengthField, 290, 170, 50, 20, "",#PB_String_ReadOnly)
      
      ButtonGadget(#PreviewButton, 470, 230, 50, 20, "Preview", #PB_Button_Toggle)
      
      TextGadget(#Text_10, 220, 230, 40, 20, "Start:")
      StringGadget(#StartPos, 260, 230, 50, 20, "")
      TextGadget(#Text_11, 360, 230, 40, 20, "End:")
      StringGadget(#EndPos, 400, 230, 50, 20, "")
      
      TextGadget(#Text_12, 220, 260, 40, 20, "Fade in:")
      StringGadget(#FadeIn, 260, 260, 50, 20, "")
      TextGadget(#Text_13, 350, 260, 50, 30, "Fade out:")
      StringGadget(#FadeOut, 400, 260, 50, 20, "")
      
      TextGadget(#Text_14, 540, 230, 40, 20, "Volume:")
      TrackBarGadget(#VolumeSlider, 600, 230, 100, 30, 0, 100)
      StringGadget(#CueVolume, 720, 230, 40, 20, "", #PB_String_ReadOnly)
      TextGadget(#Text_15, 540, 260, 40, 20, "Pan:")
      TrackBarGadget(#PanSlider, 600, 260, 100, 30, 0, 200)
      StringGadget(#CuePan, 720, 260, 40, 20, "", #PB_String_ReadOnly)
      
      TextGadget(#Text_8, 220, 200, 60, 20, "Start mode:")
      ComboBoxGadget(#ModeSelect, 290, 200, 140, 20)
      AddGadgetItem(#ModeSelect,0,"Manual")
      SetGadgetItemData(#ModeSelect,0,#START_MANUAL)
      AddGadgetItem(#ModeSelect,1,"After start of cue")
      SetGadgetItemData(#ModeSelect,1,#START_AFTER_START)
      AddGadgetItem(#ModeSelect,2,"After end of cue")
      SetGadgetItemData(#ModeSelect,2,#START_AFTER_END)
      AddGadgetItem(#ModeSelect,3,"Hotkey")
      SetGadgetItemData(#ModeSelect,3,#START_HOTKEY)
      
      TextGadget(#Text_16, 450, 200, 40, 20, "Cue:")
      ComboBoxGadget(#CueSelect, 490, 200, 200, 20)
      
      TextGadget(#Text_17, 710, 200, 40, 20, "Delay:")
      StringGadget(#StartDelay, 750, 200, 50, 20, "")
      
      ImageGadget(#WaveImg, 220, 380, #WAVEFORM_W, 120, 0)
      
      ;Event cue
      TextGadget(#Text_18, 220, 250, 40, 20, "Cue:")
      TextGadget(#Text_19, 490, 250, 40, 20, "Action:")
      For i = 0 To 5
      	eventCueSelect(i) = ComboBoxGadget(#PB_Any, 260, 250 + (i * 40), 200, 20)
      	eventActionSelect(i) = ComboBoxGadget(#PB_Any, 530, 250 + (i * 40), 200, 20)
      Next i
      
    ;EndIf
  EndIf
EndProcedure


; IDE Options = PureBasic 4.50 (Windows - x86)
; CursorPosition = 206
; FirstLine = 154
; Folding = -
; EnableXP