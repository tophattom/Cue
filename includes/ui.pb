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
  	AddKeyboardShortcut(#EditorWindow,#PB_Shortcut_Control | #PB_Shortcut_F,#FreesoundSc)
  	
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
    
    CreateImage(#BlankWave, #WAVEFORM_W, #WAVEFORM_H)
    StartDrawing(ImageOutput(#BlankWave))
    Box(0,0,#WAVEFORM_W,#WAVEFORM_H,RGB(64,64,64))
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
      CanvasGadget(#WaveImg, 5, 335,#WAVEFORM_W, #CANVAS_H)

      ButtonImageGadget(#EditorPlay, 5, 335 + #CANVAS_H + 10, 30, 30, ImageID(#PlayImg),#PB_Button_Toggle)
      ButtonImageGadget(#EditorPause, 40, 335 + #CANVAS_H + 10, 30, 30, ImageID(#PauseImg),#PB_Button_Toggle)
      ButtonImageGadget(#EditorStop, 75, 335 + #CANVAS_H + 10, 30, 30, ImageID(#StopImg))
      
      TextGadget(#Text_30,5 + #WAVEFORM_W - 340,335 + #CANVAS_H + 10,40,20,"Zoom:")
      TrackBarGadget(#ZoomSlider,5 + #WAVEFORM_W - 300,335 + #CANVAS_H + 10,200,30,0,1000)
      
      TextGadget(#Text_24, 5 +#WAVEFORM_W - 95, 335 + #CANVAS_H + 10, 40, 20, "Position:")
      StringGadget(#Position, 5 + #WAVEFORM_W - 50, 335 + #CANVAS_H + 10, 50, 20, "", #PB_String_ReadOnly) : GadgetToolTip(#Position,"Current cue position")
      
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
		
Procedure Open_FSWindow(*dat)
	If OpenWindow(#FSWindow,0,0,700,500,"Freesound.org",#PB_Window_ScreenCentered | #PB_Window_SystemMenu)
		
		AddKeyboardShortcut(#FSWindow,#PB_Shortcut_Return,#SearchSc)
		
		StringGadget(#SearchQuery,10,10,300,20,"")
		ButtonGadget(#SearchButton,320,10,60,20,"Search")
		
		TrackBarGadget(#FSSeek,390,5,200,30,0,1000)
		StringGadget(#FSPosition,600,10,50,20,SecondsToString(0),#PB_String_ReadOnly)
		ButtonImageGadget(#FSStop,660,5,30,30,ImageID(#StopImg))
		
		ListIconGadget(#SearchResult,10,40,430,450,"Filename",280,#PB_ListIcon_FullRowSelect)
		AddGadgetColumn(#SearchResult,1,"Filetype",70)
		AddGadgetColumn(#SearchResult,2,"Duration",70)
		
		TextGadget(#SoundInfo,450,40,240,450,"",#PB_Text_Border)
		
		CreatePopupMenu(#SearchPopup)
		MenuItem(#FSCreateCue,"Create an audio cue")
		MenuItem(#FSSetCueFile,"Use in current cue")
		MenuItem(#FSPreview,"Preview")
		MenuItem(#FSInfo,"Sound info")
		
		*selectedSound.FreeSound_Sound
		*newCue.Cue
		
		Define searchThread,infoThread,dlThread
		Define dlOn
		
		Repeat
			wEvent = WindowEvent()
			GadgetID = EventGadget()
			MenuID = EventMenu()
			EventType = EventType()
			
			If tmpStream <> 0
				pos.f = BASS_ChannelBytes2Seconds(tmpStream,BASS_ChannelGetPosition(tmpStream,#BASS_POS_BYTE))
				
				SetGadgetText(#FSPosition,SecondsToString(pos))
			EndIf
			
			If IsThread(dlThread) And dlOn = #True
				SetWindowTitle(#FSWindow,"Downloading...")
			ElseIf Not IsThread(dlThread) And dlOn = #True
				SetWindowTitle(#FSWindow,"Freesound.org")
				dlOn = #False

				CreateThread(@LoadCueStream2(),*newCue)
			EndIf
			
			If wEvent = #PB_Event_Menu
				If MenuID = #FSCreateCue
					If *selectedSound <> 0 And dlOn = #False
						location.s = SaveFileRequester("Select download location",*selectedSound\originalFilename,"All files",0)
						
						If location <> ""
							tmpS.s = *selectedSound\urls[#URL_SERVE] + "?api_key=" + #API_KEY + Chr(10) + location
							*dat = AllocateMemory(StringByteLength(tmpS))
							PokeS(*dat,tmpS)
							
							dlThread = CreateThread(@HTTP_GET2(),*dat)
							dlOn = #True
							
							*newCue = AddCue(#TYPE_AUDIO)
							*newCue\filePath = location
							*newCue\desc = Left(GetFilePart(*selectedSound\originalFilename),Len(*selectedSound\originalFilename) - Len(*selectedSound\type) - 1)
							
							*gCurrentCue = *newCue
							
							SignalSemaphore(gDlSemaphore)
						EndIf
					EndIf
				ElseIf MenuID = #FSSetCueFile
					location.s = SaveFileRequester("Select download location",*selectedSound\originalFilename,"All files",0)
						
					If location <> ""
						tmpS.s = *selectedSound\urls[#URL_SERVE] + "?api_key=" + #API_KEY + Chr(10) + location
						*dat = AllocateMemory(StringByteLength(tmpS))
						PokeS(*dat,tmpS)
							
						dlThread = CreateThread(@HTTP_GET2(),*dat)
						dlOn = #True
						
						*gCurrentCue\filePath = location
						*gCurrentCue\desc = Left(GetFilePart(*selectedSound\originalFilename),Len(*selectedSound\originalFilename) - Len(*selectedSound\type) - 1)
						
						*newCue = *gCurrentCue
						
						SignalSemaphore(gDlSemaphore)
					EndIf
				ElseIf MenuID = #FSPreview
					If *selectedSound <> 0
						If tmpStream <> 0
							BASS_ChannelStop(tmpStream)
							BASS_StreamFree(tmpStream)
						EndIf
							
						tmpStream = BASS_StreamCreateURL(*selectedSound\previews[#PREVIEW_LQ_MP3],0,#BASS_STREAM_AUTOFREE,#Null,0)

						BASS_ChannelPlay(tmpStream,1)
					EndIf
				ElseIf MenuID = #FSInfo
					If *selectedSound <> 0
						If *selectedSound\dataFetched = #False
							ClearStructure(@gCurrentFS,FreeSound_Sound)
							Dim gCurrentFS\tags(0)
							
							id = *selectedSound\id
							infoThread = CreateThread(@FreeSound_GetSoundInfo(),@id)
							
							While IsThread(infoThread)
								Delay(100)
							Wend
							
							ClearStructure(*selectedSound,FreeSound_Sound)
							Dim *selectedSound\tags(0)
							
							CopyStructure(@gCurrentFS,*selectedSound,FreeSound_Sound)
							*selectedSound\dataFetched = #True
						Else
							ClearStructure(@gCurrentFS,FreeSound_Sound)
							Dim gCurrentFS\tags(0)
							
							CopyStructure(*selectedSound,@gCurrentFS,FreeSound_Sound)
						EndIf
						
						SetGadgetText(#SoundInfo,"Filename:" + Chr(10) + gCurrentFS\originalFilename + Chr(10)+Chr(10) + "Description:" + Chr(10) + gCurrentFS\description)
					EndIf
				ElseIf MenuID = #SearchSc	;- Pikanäppäimet
					wEvent = #PB_Event_Gadget
					GadgetID = #SearchButton
				EndIf
			EndIf
			
			If wEvent = #PB_Event_Gadget
				If GadgetID = #SearchButton
					query.s = GetGadgetText(#SearchQuery)
					
					searchThread = CreateThread(@FreeSound_Search(),@query)
					
					While IsThread(searchThread)
						SetWindowTitle(#FSWindow,"Loading...")
						
						Delay(100)
					Wend
					
					SetWindowTitle(#FSWindow,"Freesound.org")
					
					ClearGadgetItems(#SearchResult)
					
					i = 0
					ForEach gSearchResult()
						AddGadgetItem(#SearchResult,i,"")
						
						SetGadgetItemText(#SearchResult,i,gSearchResult()\originalFilename,0)
						SetGadgetItemText(#SearchResult,i,gSearchResult()\type,1)
						SetGadgetItemText(#SearchResult,i,SecondsToString(gSearchResult()\fileInfo[#INFO_DURATION]),2)
						
						SetGadgetItemData(#SearchResult,i,@gSearchResult())
						
						Select gSearchResult()\type
							Case "wav"
								color.i = RGB(100,200,200)
							Case "aif"
								color.i = RGB(100,200,100)
							Case "mp3"
								color.i = RGB(200,100,100)
							Case "flac"
								color.i = RGB(200,200,100)
						EndSelect
						
						SetGadgetItemColor(#SearchResult,i,#PB_Gadget_BackColor,color)
						
						i + 1
					Next
				ElseIf	GadgetID = #FSSeek
					If tmpStream <> 0
						length.f = BASS_ChannelBytes2Seconds(tmpStream,BASS_ChannelGetLength(tmpStream,#BASS_POS_BYTE))
						
						pos.f = BASS_ChannelSeconds2Bytes(tmpStream,GetGadgetState(#FSSeek) * length / 1000)
						
						BASS_ChannelSetPosition(tmpStream,pos,#BASS_POS_BYTE)
					EndIf
				ElseIf	GadgetID = #FSStop
					If tmpStream <> 0
						If tmpStream <> 0
							BASS_ChannelStop(tmpStream)
							BASS_StreamFree(tmpStream)
							
							tmpStream = 0
							
							SetGadgetText(#FSPosition,SecondsToString(0))
							SetGadgetState(#FSSeek,0)
						EndIf
					EndIf
				ElseIf GadgetID = #SearchResult
					*selectedSound = GetGadgetItemData(#SearchResult,GetGadgetState(#SearchResult))

					If EventType = #PB_EventType_RightClick
						If *gCurrentCue <> 0
							If *gCurrentCue\cueType = #TYPE_AUDIO
								DisableMenuItem(#SearchPopup,#FSSetCueFile,0)
							Else
								DisableMenuItem(#SearchPopup,#FSSetCueFile,1)
							EndIf
						Else
							DisableMenuItem(#SearchPopup,#FSSetCueFile,1)
						EndIf
						
						DisplayPopupMenu(#SearchPopup,WindowID(#FSWindow))
					EndIf
				EndIf
			ElseIf wEvent = #PB_Event_CloseWindow
				break
			EndIf
		ForEver
		
		CloseWindow(#FSWindow)
	EndIf
EndProcedure
