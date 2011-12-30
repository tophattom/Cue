;
; PureBasic Visual Designer v3.95 build 1485 (PB4Code)


;- Window Constants
;
Enumeration
  #MainWindow
  #EditorWindow
  #SettingsWindow
  #ExplorerWindow
  #AboutWindow
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
  #MenuImport
  #MenuPref
  #MenuExit
  #MenuAbout
  
  #PlaySc
  
  #DeleteSc
  
  #ExplorerSc
EndEnumeration



#WAVEFORM_W = 660

Global Dim eventCueSelect(5)
Global Dim eventActionSelect(5)
Global Dim eventEffectSelect(5)

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
      MenuItem(#MenuImport, "Import cues...")
      MenuBar()
      MenuItem(#MenuPref, "Preferences...")
      MenuBar()
      MenuItem(#MenuExit, "Exit")
      MenuTitle("Help")
      MenuItem(#MenuAbout, "About")
      
      AddKeyboardShortcut(#MainWindow,#PB_Shortcut_Control | #PB_Shortcut_N,#MenuNew)
      AddKeyboardShortcut(#MainWindow,#PB_Shortcut_Control | #PB_Shortcut_O,#MenuOpen)
      AddKeyboardShortcut(#MainWindow,#PB_Shortcut_Control | #PB_Shortcut_S,#MenuSave)
      AddKeyboardShortcut(#MainWindow,#PB_Shortcut_Control | #PB_Shortcut_Alt | #PB_Shortcut_N,#MenuSaveAs)
      
      AddKeyboardShortcut(#MainWindow,#PB_Shortcut_Space,#PlaySc)
    
    EndIf

      ;If CreateGadgetList(WindowID(#MainWindow))
        Frame3DGadget(#Frame3D_0, 10, 0, 280, 80, "Controls")
        ButtonGadget(#PlayButton, 20, 20, 80, 50, "Play") : GadgetToolTip(#PlayButton,"Start next cue")
        ButtonGadget(#PauseButton, 110, 20, 80, 50, "Pause")
        ButtonGadget(#StopButton, 200, 20, 80, 50, "Stop all") : GadgetToolTip(#StopButton,"Stop all cues")
        ListViewGadget(#Listview_1, 10, 420, 1010, 320)
        
        
        ListIconGadget(#CueList, 10, 90, 1010, 320, "Cue", 300, #PB_ListIcon_FullRowSelect | #PB_ListIcon_AlwaysShowSelection)
        AddGadgetColumn(#CueList, 1, "Cue type", 100)
        AddGadgetColumn(#CueList, 2, "Start mode", 100)
        AddGadgetColumn(#CueList, 3, "State", 100)
        AddGadgetColumn(#CueList, 4, "Time left", 100)
        EnableGadgetDrop(#CueList,#PB_Drop_Files,#PB_Drag_Copy)
        
        Frame3DGadget(#Frame3D_2, 310, 0, 190, 80, "Actions")
        ButtonGadget(#EditorButton, 320, 20, 80, 50, "Editor") : GadgetToolTip(#EditorButton,"Add and modify cues")
        ButtonGadget(#SettingsButton, 410, 20, 80, 50, "Cue list " + Chr(10) + " settings",#PB_Button_MultiLine)
        TrackBarGadget(#MasterSlider, 730, 50, 290, 30, 0, 100)
        SetGadgetState(#MasterSlider,100)
        TextGadget(#Text_2, 730, 30, 210, 20, "Master volume")
        
        ;EndIf
        
        
  EndIf
EndProcedure

Procedure Open_EditorWindow()
  If OpenWindow(#EditorWindow, 533, 221, 910, 710, "Cue - Editor",  #PB_Window_SystemMenu | #PB_Window_Invisible | #PB_Window_TitleBar | #PB_Window_ScreenCentered )
  	;If CreateGadgetList(WindowID(#EditorWindow))
  	
  	AddKeyboardShortcut(#EditorWindow,#PB_Shortcut_Control | #PB_Shortcut_Delete,#DeleteSc)
  	AddKeyboardShortcut(#EditorWindow,#PB_Shortcut_Control | #PB_Shortcut_E,#ExplorerSc)
  	
  	ListViewGadget(#EditorList, 10, 50, 200, 615,#PB_ListView_MultiSelect)
  	EnableGadgetDrop(#EditorList,#PB_Drop_Files,#PB_Drag_Copy)
    
    LoadImage(#DeleteImg,"Images/delete.ico")
    LoadImage(#UpImg,"Images/up.ico")
    LoadImage(#DownImg,"Images/down.ico")
    LoadImage(#PlayImg,"Images/eplay.ico")
    LoadImage(#PauseImg,"Images/epause.ico")
    LoadImage(#StopImg,"Images/estop.ico")
    LoadImage(#ExplorerImg,"Images/explorer.ico")
    
    CreateImage(#BlankWave, #WAVEFORM_W, 120)
    StartDrawing(ImageOutput(#BlankWave))
    Box(0,0,#WAVEFORM_W,120,RGB(64,64,64))
    StopDrawing()
    
    ButtonImageGadget(#DeleteButton, 180, 670, 30, 30, ImageID(#DeleteImg)) : GadgetToolTip(#DeleteButton,"Delete current cue(s)")
    ButtonImageGadget(#UpButton, 10, 670, 30, 30, ImageID(#UpImg)) : GadgetToolTip(#UpButton,"Move cue(s) up")
    ButtonImageGadget(#DownButton, 45, 670, 30, 30, ImageID(#DownImg)) : GadgetToolTip(#DownButton,"Move cue(s) down")
    
    ButtonGadget(#AddAudio, 10, 10, 130, 30, "Add audio cue")
    ButtonGadget(#AddChange, 290, 10, 130, 30, "Add level change cue")
    ButtonGadget(#AddEvent, 430, 10, 130, 30, "Add event cue")
    ButtonGadget(#AddVideo, 150, 10, 130, 30, "")
    
    ButtonImageGadget(#ExplorerButton, 870, 10, 30, 30, ImageID(#ExplorerImg)) : GadgetToolTip(#ExplorerButton,"Open file browser")
    
    PanelGadget(#EditorTabs, 220, 50, 680, 650)
    EnableGadgetDrop(#EditorTabs,#PB_Drop_Files,#PB_Drag_Copy)
    AddGadgetItem(#EditorTabs, 0, "Basic")
    
      StringGadget(#CueNameField, 75, 5, 300, 20, "")
      TextGadget(#Text_3, 5, 5, 40, 20, "Name:")
      StringGadget(#CueDescField, 75, 35, 300, 20, "")
      TextGadget(#Text_4, 5, 35, 60, 20, "Description:")
      StringGadget(#CueFileField, 75, 95, 300, 20, "", #PB_String_ReadOnly)
      TextGadget(#Text_6, 5, 95, 60, 20, "File:")
      ButtonGadget(#OpenCueFile, 385, 95, 30, 20, "...")
      TextGadget(#Text_9, 5, 125, 60, 20, "Length:")
      StringGadget(#LengthField, 75, 125, 50, 20, "",#PB_String_ReadOnly)

      TextGadget(#Text_10, 5, 185, 40, 20, "Start:")
      StringGadget(#StartPos, 45, 185, 50, 20, "")
      TextGadget(#Text_11, 145, 185, 40, 20, "End:")
      StringGadget(#EndPos, 185, 185, 50, 20, "")
      
      TextGadget(#Text_12, 5, 215, 40, 20, "Fade in:")
      StringGadget(#FadeIn, 45, 215, 50, 20, "")
      TextGadget(#Text_13, 135, 215, 50, 30, "Fade out:")
      StringGadget(#FadeOut, 185, 215, 50, 20, "")
      
      TextGadget(#Text_21, 5, 245, 40, 30, "Loop start:")
      StringGadget(#LoopStart, 45, 245, 50, 20, "")
      DisableGadget(#LoopStart, 1)
      TextGadget(#Text_22, 135, 245, 40, 30, "Loop end:")
      StringGadget(#LoopEnd, 185, 245, 50, 20, "")
      DisableGadget(#LoopEnd, 1)
      TextGadget(#Text_23, 265, 245, 40, 30, "Loop count:")
      StringGadget(#LoopCount, 315, 245, 50, 20, "")
      DisableGadget(#LoopCount, 1)
      CheckBoxGadget(#LoopEnable, 395, 245, 40, 20, "Loop")
      
      ;540
      TextGadget(#Text_14, 265, 185, 40, 20, "Volume:")
      TrackBarGadget(#VolumeSlider, 325, 185, 190, 30, 0, 1000)
      StringGadget(#CueVolume, 535, 185, 50, 20, "")
      TextGadget(#Text_15, 265, 215, 40, 20, "Pan:")
      TrackBarGadget(#PanSlider, 325, 215, 190, 30, 0, 2000)
      StringGadget(#CuePan, 535, 215, 50, 20, "")
      
      TextGadget(#Text_8, 5, 155, 60, 20, "Start mode:")
      ComboBoxGadget(#ModeSelect, 75, 155, 140, 20) : GadgetToolTip(#ModeSelect,"Cue's start type")
      AddGadgetItem(#ModeSelect,0,"Manual")
      SetGadgetItemData(#ModeSelect,0,#START_MANUAL)
      AddGadgetItem(#ModeSelect,1,"After start of cue")
      SetGadgetItemData(#ModeSelect,1,#START_AFTER_START)
      AddGadgetItem(#ModeSelect,2,"After end of cue")
      SetGadgetItemData(#ModeSelect,2,#START_AFTER_END)
      AddGadgetItem(#ModeSelect,3,"Hotkey")
      SetGadgetItemData(#ModeSelect,3,#START_HOTKEY)
      
      TextGadget(#Text_16, 235, 155, 40, 20, "Cue:")
      ComboBoxGadget(#CueSelect, 275, 155, 200, 20)
      
      TextGadget(#Text_17, 495, 155, 40, 20, "Delay:")
      StringGadget(#StartDelay, 535, 155, 50, 20, "") : GadgetToolTip(#StartDelay,"Delay before cue starts")
      
      ImageGadget(#WaveImg, 5, 335, #WAVEFORM_W, 120, 0)

      ButtonImageGadget(#EditorPlay, 5, 460, 30, 30, ImageID(#PlayImg),#PB_Button_Toggle)
      ButtonImageGadget(#EditorPause, 40, 460, 30, 30, ImageID(#PauseImg),#PB_Button_Toggle)
      ButtonImageGadget(#EditorStop, 75, 460, 30, 30, ImageID(#StopImg))
      
      TextGadget(#Text_24, 5 +#WAVEFORM_W - 95, 460, 40, 20, "Position:")
      StringGadget(#Position, 5 + #WAVEFORM_W - 50, 460, 50, 20, "", #PB_String_ReadOnly) : GadgetToolTip(#Position,"Current cue position")
      
      ;Event cue
      TextGadget(#Text_18, 5, 245, 40, 20, "Cue:")
      TextGadget(#Text_19, 275, 245, 40, 20, "Action:")
      TextGadget(#Text_26, 445, 245, 40, 20, "Effect:")
      For i = 0 To 5
      	eventCueSelect(i) = ComboBoxGadget(#PB_Any, 45, 245 + (i * 40), 200, 20)
      	eventActionSelect(i) = ComboBoxGadget(#PB_Any, 315, 245 + (i * 40), 120, 20)
      	eventEffectSelect(i) = ComboBoxGadget(#PB_Any, 485, 245 + (i * 40), 150, 20)
      	DisableGadget(eventEffectSelect(i),1)
      Next i
      
      ;Change cue
      TextGadget(#Text_20, 5, 185, 100, 20, "Change duration:")
      StringGadget(#ChangeDur, 105, 185, 40, 20, "")
      
      ;Efektivälilehti
      AddGadgetItem(#EditorTabs, 1, "Effects")
      
      TextGadget(#Text_25,5,12,60,20,"Effect type:")
      
      ComboBoxGadget(#EffectType, 65, 10, 120, 20)
      AddGadgetItem(#EffectType, 0, "Reverb")
      SetGadgetItemData(#EffectType, 0, #BASS_FX_DX8_REVERB)
      AddGadgetItem(#EffectType, 1, "Parametric EQ")
      SetGadgetItemData(#EffectType, 1, #BASS_FX_DX8_PARAMEQ)
      AddGadgetItem(#EffectType, 2, "VST plugin")
      SetGadgetItemData(#EffectType , 2, #EFFECT_VST)
      
      ButtonGadget(#AddEffect, 195, 5, 100, 30, "Add effect") : GadgetToolTip(#AddEffect,"Add selected effect to cue")
      
      ButtonImageGadget(#EffectPlay, 565, 5, 30, 30, ImageID(#PlayImg),#PB_Button_Toggle)
      ButtonImageGadget(#EffectPause, 600, 5, 30, 30, ImageID(#PauseImg),#PB_Button_Toggle)
      ButtonImageGadget(#EffectStop, 635, 5, 30, 30, ImageID(#StopImg))
      CloseGadgetList()
      
    ;EndIf
  EndIf
EndProcedure

Procedure Open_SettingsWindow()
	If OpenWindow(#SettingsWindow, 0, 0, 200, 100, "Cue list settings", #PB_Window_ScreenCentered | #PB_Window_SystemMenu)
		CheckBoxGadget(#CheckRelative, 5, 5, 120, 20, "Use relative paths")
		ButtonGadget(#SettingsOK, 155, 65, 40, 30, "OK")
	EndIf
EndProcedure

Procedure Open_ExplorerWindow()
	If OpenWindow(#ExplorerWindow, 0,0, 250, 400, "Explorer", #PB_Window_ScreenCentered | #PB_Window_Tool | #PB_Window_SizeGadget | #PB_Window_SystemMenu)
		*path = AllocateMemory(#MAX_PATH)
		SHGetSpecialFolderPath_(0,*path,#CSIDL_PERSONAL,0)
		ExplorerTreeGadget(#FileBrowser, 0, 0, 250, 400, PeekS(*path) + "\",#PB_Explorer_BorderLess)
		FreeMemory(*path)
	EndIf
EndProcedure

Procedure Open_AboutWindow()
	If OpenWindow(#AboutWindow,0,0,350,190,"About",#PB_Window_ScreenCentered |#PB_Window_SystemMenu)
		TextGadget(#AboutText,0,10,350,260,"Cue" + Chr(10) + Chr(10) + "Cue is a free and open source program for theatre sound cue control." + Chr(10) + "Project started as an attempt to create a free alternative to SCS." + Chr(10) + Chr(10) + "Creator: Jaakko Rinta-Filppula" + Chr(10) + "Special thanks to Mika Kuitunen for testing!" + Chr(10) + Chr(10) + "Wiki (only in Finnish) and code hosted at",#PB_Text_Center)
		HyperLinkGadget(#AboutLink,95,130,160,20,"http://github.com/SlyJack0/Cue/",#PB_HyperLink_Underline)
		SetGadgetColor(#AboutLink,#PB_Gadget_FrontColor,$FF0000)
		ButtonGadget(#AboutOk,155,155,40,30,"OK")
	EndIf
EndProcedure

