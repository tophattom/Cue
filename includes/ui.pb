;
; PureBasic Visual Designer v3.95 build 1485 (PB4Code)

;- Fonts


Procedure Open_MainWindow()
	winRect.RECT
	SystemParametersInfo_(#SPI_GETWORKAREA,0,@winRect,0)

	windowH = Min(768,winRect\bottom - winRect\top)
	
  If OpenWindow(#MainWindow, 479, 152, 1024, windowH, "Cue",  #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget | #PB_Window_SizeGadget | #PB_Window_TitleBar | #PB_Window_ScreenCentered )
  	If windowH < 768
  		ResizeWindow(#MainWindow,#PB_Ignore,0,#PB_Ignore,#PB_Ignore)
  	EndIf
  	
  	If CreateMenu(#MenuBar, WindowID(#MainWindow))
      MenuTitle("File")
      MenuItem(#MenuNew, "New..." + Chr(9) + "Ctrl+N")
      MenuItem(#MenuOpen, "Open..." + Chr(9) + "Ctrl+O")
      
      OpenSubMenu("Open recent")
      For i = 0 To #MAX_RECENT - 1
      	MenuItem(i,GetFilePart(gRecentFiles(i)))
      Next i
      CloseSubMenu()
      
      MenuItem(#MenuSave, "Save" + Chr(9) + "Ctrl+S")
      MenuItem(#MenuSaveAs, "Save As..." + Chr(9) + "Ctrl+Alt+S")
      MenuBar()
      MenuItem(#MenuImport, "Import cues...")
      DisableMenuItem(#MenuBar,#MenuImport,1)
      MenuBar()
      MenuItem(#MenuPref, "Preferences...")
      MenuBar()
      MenuItem(#MenuExit, "Exit")
      MenuTitle("Help")
      MenuItem(#MenuAbout, "About")
      
      AddKeyboardShortcut(#MainWindow,#PB_Shortcut_Control | #PB_Shortcut_N,#MenuNew)
      AddKeyboardShortcut(#MainWindow,#PB_Shortcut_Control | #PB_Shortcut_O,#MenuOpen)
      AddKeyboardShortcut(#MainWindow,#PB_Shortcut_Control | #PB_Shortcut_S,#MenuSave)
      AddKeyboardShortcut(#MainWindow,#PB_Shortcut_Control | #PB_Shortcut_Alt | #PB_Shortcut_S,#MenuSaveAs)
      
      AddKeyboardShortcut(#MainWindow,#PB_Shortcut_Space,#PlaySc)
      AddKeyboardShortcut(#MainWindow,#PB_Shortcut_Return,#StopSc)
    
    EndIf

      ;If CreateGadgetList(WindowID(#MainWindow))
        Frame3DGadget(#Frame3D_0, 10, 0, 280, 80, "Controls")
        ButtonGadget(#PlayButton, 20, 20, 80, 50, "Play") : GadgetToolTip(#PlayButton,"Start next cue")
        ButtonGadget(#PauseButton, 110, 20, 80, 50, "Pause")
        ButtonGadget(#StopButton, 200, 20, 80, 50, "Stop all") : GadgetToolTip(#StopButton,"Stop all cues")

        ListIconGadget(#CueList, 10, 90, 1004, 628, "Cue", 334, #PB_ListIcon_FullRowSelect | #PB_ListIcon_AlwaysShowSelection) : SetGadgetFont(#CueList,FontID(gCueListFont))
        AddGadgetColumn(#CueList, 1, "Cue type", 166)
        AddGadgetColumn(#CueList, 2, "Start mode", 166)
        AddGadgetColumn(#CueList, 3, "State", 166)
        AddGadgetColumn(#CueList, 4, "Time left", 166)
        EnableGadgetDrop(#CueList,#PB_Drop_Files,#PB_Drag_Copy)
        
        Frame3DGadget(#Frame3D_2, 310, 0, 190, 80, "Actions")
        ButtonGadget(#EditorButton, 320, 20, 80, 50, "Editor") : GadgetToolTip(#EditorButton,"Add and modify cues")
        ButtonGadget(#SettingsButton, 410, 20, 80, 50, "Cue list " + Chr(10) + " settings",#PB_Button_MultiLine)
        TrackBarGadget(#MasterSlider, 730, 50, 290, 30, 0, 100)
        SetGadgetState(#MasterSlider,100)
        TextGadget(#Text_2, 730, 30, 210, 20, "Master volume")
        
        ;EndIf
        
        If CreateStatusBar(#StatusBar,WindowID(#MainWindow))
        	AddStatusBarField(#PB_Ignore)
        EndIf
        
  EndIf
EndProcedure

Procedure Open_EditorWindow()
  If OpenWindow(#EditorWindow, 533, 221, 910, 710, "Cue - Editor",  #PB_Window_SystemMenu | #PB_Window_Invisible | #PB_Window_TitleBar | #PB_Window_ScreenCentered )
  	;If CreateGadgetList(WindowID(#EditorWindow))
  	
  	AddKeyboardShortcut(#EditorWindow,#PB_Shortcut_Control | #PB_Shortcut_Delete,#DeleteSc)
  	AddKeyboardShortcut(#EditorWindow,#PB_Shortcut_Control | #PB_Shortcut_E,#ExplorerSc)
  	AddKeyboardShortcut(#EditorWindow,#PB_Shortcut_Control | #PB_Shortcut_I,#InSc)
  	AddKeyboardShortcut(#EditorWindow,#PB_Shortcut_Control | #PB_Shortcut_O,#OutSc)
  	
  	ListViewGadget(#EditorList, 10, 50, 200, 615,#PB_ListView_MultiSelect)
  	EnableGadgetDrop(#EditorList,#PB_Drop_Files,#PB_Drag_Copy)
    
    LoadImage(#DeleteImg,"Images/delete.ico")
    LoadImage(#UpImg,"Images/up.ico")
    LoadImage(#DownImg,"Images/down.ico")
    LoadImage(#PlayImg,"Images/eplay.ico")
    LoadImage(#PauseImg,"Images/epause.ico")
    LoadImage(#StopImg,"Images/estop.ico")
    LoadImage(#ExplorerImg,"Images/explorer.ico")
    LoadImage(#AddImg,"Images/add.ico")
    
    CreateImage(#BlankWave, #WAVEFORM_W, 120)
    StartDrawing(ImageOutput(#BlankWave))
    Box(0,0,#WAVEFORM_W,120,RGB(64,64,64))
    StopDrawing()
    
    ButtonImageGadget(#DeleteButton, 180, 670, 30, 30, ImageID(#DeleteImg)) : GadgetToolTip(#DeleteButton,"Delete current cue(s) (Ctrl+Delete)")
    ButtonImageGadget(#UpButton, 10, 670, 30, 30, ImageID(#UpImg)) : GadgetToolTip(#UpButton,"Move cue(s) up")
    ButtonImageGadget(#DownButton, 45, 670, 30, 30, ImageID(#DownImg)) : GadgetToolTip(#DownButton,"Move cue(s) down")
    
    ButtonGadget(#AddAudio, 10, 10, 130, 30, "Add audio cue")
    ButtonGadget(#AddChange, 290, 10, 130, 30, "Add level change cue")
    ButtonGadget(#AddEvent, 430, 10, 130, 30, "Add event cue")
    ButtonGadget(#AddVideo, 150, 10, 130, 30, "")
    ButtonGadget(#AddNote, 570, 10, 130, 30, "Add note cue")
    
    ButtonImageGadget(#ExplorerButton, 870, 10, 30, 30, ImageID(#ExplorerImg)) : GadgetToolTip(#ExplorerButton,"Open file browser (Ctrl+E)")
    
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
      
      TextGadget(#Text_33, 235, 155, 100, 20, "Key (combination):")
      ShortcutGadget(#HotkeyField,335,155,140,20,0)
      
      TextGadget(#Text_17, 495, 155, 40, 20, "Delay:")
      StringGadget(#StartDelay, 535, 155, 50, 20, "") : GadgetToolTip(#StartDelay,"Delay before cue starts")
      
      ;ImageGadget(#WaveImg, 5, 335, #WAVEFORM_W, 120, 0)
      CanvasGadget(#WaveImg, 5, 335,#WAVEFORM_W, 120)

      ButtonImageGadget(#EditorPlay, 5, 460, 30, 30, ImageID(#PlayImg),#PB_Button_Toggle)
      ButtonImageGadget(#EditorPause, 40, 460, 30, 30, ImageID(#PauseImg),#PB_Button_Toggle)
      ButtonImageGadget(#EditorStop, 75, 460, 30, 30, ImageID(#StopImg))
      
      TextGadget(#Text_30,5 + #WAVEFORM_W - 340,460,40,20,"Zoom:")
      TrackBarGadget(#ZoomSlider,5 + #WAVEFORM_W - 300,460,200,30,0,1000)
      
      TextGadget(#Text_24, 5 +#WAVEFORM_W - 95, 460, 40, 20, "Position:")
      StringGadget(#Position, 5 + #WAVEFORM_W - 50, 460, 50, 20, "", #PB_String_ReadOnly) : GadgetToolTip(#Position,"Current cue position")
      
      ;Event cue
      TextGadget(#Text_18, 5, 245, 40, 20, "Events:")
      ListViewGadget(#EventList, 5, 265, 100, 140)
      
      TextGadget(#Text_19, 115, 265, 40, 20, "Target:")
      ComboBoxGadget(#EventTarget, 115, 285, 200,20)
      
      TextGadget(#Text_26, 115, 315, 40, 20, "Action:")
      ComboBoxGadget(#EventAction, 115, 335, 120, 20)
      AddGadgetItem(#EventAction,0,"Fade out")
      AddGadgetItem(#EventAction,1,"Stop")
      AddGadgetItem(#EventAction,2,"Release loop")
      AddGadgetItem(#EventAction,3,"Effect on")
      AddGadgetItem(#EventAction,4,"Effect off")
      
      TextGadget(#Text_31, 115, 365, 40, 20, "Effect:")
      ComboBoxGadget(#EventEffect, 115, 385, 120, 20)
      
      ButtonImageGadget(#EventAdd, 5, 410, 30, 30, ImageID(#AddImg))
      ButtonImageGadget(#EventDelete, 75, 410, 30, 30, ImageID(#DeleteImg))
      
      
      
      ;Change cue
      TextGadget(#Text_20, 5, 185, 100, 20, "Change duration:")
      StringGadget(#ChangeDur, 105, 185, 40, 20, "")
      
      TextGadget(#Text_32, 5, 245, 60, 20, "Target cue:")
      ComboBoxGadget(#ChangeTarget, 65, 245, 200, 20)
      
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
      DisableGadget(#AddEffect,1)
      
      ButtonImageGadget(#EffectPlay, 565, 5, 30, 30, ImageID(#PlayImg),#PB_Button_Toggle)
      ButtonImageGadget(#EffectPause, 600, 5, 30, 30, ImageID(#PauseImg),#PB_Button_Toggle)
      ButtonImageGadget(#EffectStop, 635, 5, 30, 30, ImageID(#StopImg))
            
      ScrollAreaGadget(#EffectScroll,0,40,670,580,650,0,#PB_Ignore,#PB_ScrollArea_BorderLess)
      SetGadgetColor(#EffectScroll,#PB_Gadget_BackColor,$FFFFFF)
      
      CloseGadgetList()
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
		LoadImage(#RefreshImg,"Images/refresh.ico")
		
		ButtonImageGadget(#RefreshBrowser,228,2,20,20,ImageID(#RefreshImg))
		
		*path = AllocateMemory(#MAX_PATH)
		SHGetSpecialFolderPath_(0,*path,#CSIDL_PERSONAL,0)
		ExplorerTreeGadget(#FileBrowser, 0, 24, 250, 376, PeekS(*path) + "\")
		FreeMemory(*path)
	EndIf
EndProcedure

Procedure Open_AboutWindow()
	If OpenWindow(#AboutWindow,0,0,350,190,"About",#PB_Window_ScreenCentered |#PB_Window_SystemMenu)
		TextGadget(#AboutText,0,10,350,260,"Cue" + Chr(10) + Chr(10) + "Cue is a free and open source program for theatre sound cue control." + Chr(10) + "Project started as an attempt to create a free alternative to SCS." + Chr(10) + Chr(10) + "Creator: Jaakko Rinta-Filppula" + Chr(10) + "Special thanks to Mika Kuitunen for testing!" + Chr(10) + Chr(10) + "Wiki and code hosted at",#PB_Text_Center)
		HyperLinkGadget(#AboutLink,95,130,160,20,"http://github.com/SlyJack0/Cue/",#PB_HyperLink_Underline)
		SetGadgetColor(#AboutLink,#PB_Gadget_FrontColor,$FF0000)
		ButtonGadget(#AboutOk,155,155,40,30,"OK")
	EndIf
EndProcedure

Procedure Open_LoadWindow(*value)
	If OpenWindow(#LoadWindow,0,0,200,40,"Loading, pease wait...",#PB_Window_ScreenCentered | #PB_Window_Tool)
		ProgressBarGadget(#LoadBar,10,10,180,20,0,100,#PB_ProgressBar_Smooth)
		
		Repeat
			If gCueAmount
				SetGadgetState(#LoadBar,Int((gCuesLoaded / gCueAmount) * 100))
			EndIf
		Until gCuesLoaded = gCueAmount
		
		CloseWindow(#LoadWindow)
	EndIf
EndProcedure

Procedure Open_PrefWindow()
	If OpenWindow(#PrefWindow,0,0,640,480,"Preferences",#PB_Window_ScreenCentered | #PB_Window_SystemMenu)
		Frame3DGadget(#PrefAFrame,10,10,620,60,"Audio")
		
		TextGadget(#Text_27,20,30,80,20,"Audio device:")
		ComboBoxGadget(#SelectADevice,100,30,200,20)
		info.BASS_DEVICEINFO
		i = 1
		While BASS_GetDeviceInfo(i,@info)
			AddGadgetItem(#SelectADevice,-1,PeekS(info\name))
			i + 1
		Wend
		SetGadgetState(#SelectADevice,BASS_GetDevice() - 1)
		
		
		Frame3DGadget(#PrefIFrame,10,80,620,60,"Interface")
		
		TextGadget(#Text_28,20,100,55,20,"Font size:")
		StringGadget(#FontSize,75,100,30,20,"",#PB_String_Numeric)
		SetGadgetText(#FontSize,Str(gAppSettings(#SETTING_FONTSIZE)))
		
		Frame3DGadget(#PrefGFrame,10, 150, 620, 60, "General")
		
		TextGadget(#Text_29,20,170,60,20,"Cue naming:")
		StringGadget(#CuePrefix,90,170,60,20,gCueNaming) : GadgetToolTip(#CuePrefix,"# = number, $ = lower Case letter, & = upper case letter")
		
		
		ButtonGadget(#PrefOk,590,440,40,30,"OK")
		ButtonGadget(#PrefCancel,535,440,50,30,"Cancel")
	EndIf
EndProcedure
