; PureBasic Visual Designer v3.95 build 1485 (PB4Code)


IncludeFile "includes\bass.pbi"
IncludeFile "includes\bassvst.pbi"
IncludeFile "includes\util.pbi"
IncludeFile "includes\ui.pb"

Declare UpdateEditorList()
Declare HideCueControls()
Declare ShowCueControls()
Declare HideEffectControls()
Declare ShowEffectControls()
Declare UpdateCueControls()
Declare PlayCue(*cue.Cue)
Declare PauseCue(*cue.Cue)
Declare StopCue(*cue.Cue)
Declare LoopProc(handle.l,channel.l,d,*user.Cue)
Declare StartEvents(*cue.Cue)
Declare UpdateCues()
Declare UpdateMainCueList()
Declare UpdatePosField()
Declare UpdateListSettings()
Declare MoveCueUp(*cue.Cue)
Declare MoveCueDown(*cue.Cue)
Declare UpdateAppSettings()

LoadAppSettings()

Open_MainWindow()
Open_EditorWindow()

HideWindow(#EditorWindow, 1)
HideCueControls()

BASS_Init(-1,44100,0,WindowID(#MainWindow),#Null)

BASS_PluginLoad("basswma.dll",0)
BASS_PluginLoad("bassflac.dll",0)
BASS_PluginLoad("bass_aac.dll",0)

;Parametrit
;{
paramCount = CountProgramParameters()
If paramCount > 0
	For i = 1 To paramCount
		param.s = ProgramParameter()
		
		;Annettu tiedosto avattavaksi
		If Right(param,4) = ".clf"
			gSavePath = param
			ClearCueList()
			LoadCueList(param)
				
			*gCurrentCue = FirstElement(cueList())
			UpdateMainCueList()
			UpdateEditorList()
			UpdateCueControls()
		EndIf
	Next i
EndIf
;}


Repeat ; Start of the event loop
	Event = WindowEvent() ; This line waits until an event is received from Windows
	WindowID = EventWindow() ; The Window where the event is generated, can be used in the gadget procedures
	GadgetID = EventGadget() ; Is it a gadget event?
	EventType = EventType() ; The event type
	
	
	If *gCurrentCue <> 0 And ListSize(*gSelection()) <= 1
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
	
	If GetGadgetState(#EditorPlay) = 1
		UpdatePosField()
	EndIf
	
	If gEditor = #False
		If ElapsedMilliseconds() > lastUpdate + 500
			UpdateMainCueList()
			
			If gSavePath = ""
				SetWindowTitle(#MainWindow,"Cue - Untitled")
			Else
				SetWindowTitle(#MainWindow,"Cue - " + GetFilePart(gSavePath))
			EndIf
			
			If ListSize(cueList()) > 0
				FirstElement(cueList())
				tmpHash = CRC32Fingerprint(@cueList(),SizeOf(Cue) * ListSize(cueList()))
			Else
				tmpHash = 0
			EndIf
			
			If tmpHash <> gLastHash
				SetWindowTitle(#MainWindow,GetWindowTitle(#MainWindow) + "*")
				gSaved = #False
			Else
				gSaved = #True
			EndIf
				
			
			lastUpdate = ElapsedMilliseconds()
		EndIf
	EndIf
	
	;- Valikot
	;{
	If Event = #PB_Event_Menu
		MenuID = EventMenu()
		   
		If MenuID = #MenuNew
			ClearCueList()
			gCueAmount = 0
			gCueCounter = 0
			gSavePath = ""
			
			UpdateMainCueList()
			UpdateEditorList()
		ElseIf MenuID = #MenuOpen
			path.s = OpenFileRequester("Open cue list","","Cue list files (*.clf) |*.clf",0)
			
			If path <> ""
				ClearCueList()
				
				CreateThread(@Open_LoadWindow(),0)
				
				If LoadCueList(path)
					gSavePath = path
					
					*gCurrentCue = FirstElement(cueList())
					UpdateMainCueList()
					UpdateEditorList()
					UpdateCueControls()
				EndIf
			EndIf		      
		ElseIf MenuID = #MenuSave
			If gSavePath = ""
				check = 1
				gSavePath = SaveFileRequester("Save cue list","","Cue list files (*.clf) |*.clf",0)
			Else
				check = 0
			EndIf
			
			If gSavePath <> ""
				SaveCueList(gSavePath,check)
			EndIf  
		ElseIf MenuID = #MenuSaveAs
			gSavePath = SaveFileRequester("Save cue list","","Cue list files (*.clf) |*.clf",0)
			
			If gSavePath <> ""
				SaveCueList(gSavePath)
			EndIf
		ElseIf MenuID = #MenuPref
			If IsWindow(#PrefWindow)
				HideWindow(#PrefWindow,0)
			Else
				Open_PrefWindow()
			EndIf
			
			UpdateAppSettings()
		ElseIf MenuID = #MenuExit
			If gSaved = #False And ListSize(cueList()) > 0
				result = MessageRequester("Cue","Cue list has been modified. Do you want to save it?",#PB_MessageRequester_YesNoCancel)
				
				If result = #PB_MessageRequester_Yes
					If gSavePath = ""
						check = 1
						gSavePath = SaveFileRequester("Save cue list","","Cue list files (*.clf) |*.clf",0)
					Else
						check = 0
					EndIf
					
					If gSavePath <> ""
						SaveCueList(gSavePath,check)
						End
					EndIf
				ElseIf result = #PB_MessageRequester_No
					End
				EndIf
			Else
				End
			EndIf
		ElseIf MenuID = #MenuAbout
			If IsWindow(#AboutWindow)
				HideWindow(#AboutWindow,0)
			Else
				Open_AboutWindow()
			EndIf
		ElseIf MenuID = #PlaySc ;---Pikan‰pp‰imet
			Event = #PB_Event_Gadget
			GadgetID = #PlayButton
		ElseIf MenuID = #DeleteSc
			If ListSize(*gSelection()) <= 1
	      		If *gCurrentCue <> 0
	      			ForEach cueList()
						StopCue(@cueList())
					Next
					
					tmpNum = GetGadgetState(#EditorList)
					Debug "Position: " + Str(tmpNum)
					
					DeleteCue(*gCurrentCue)
					*gCurrentCue = 0
					UpdateEditorList()

					If CountGadgetItems(#EditorList) > tmpNum
						*gCurrentCue = GetGadgetItemData(#EditorList,tmpNum)
					Else
						If gCueAmount > 0
							*gCurrentCue = GetGadgetItemData(#EditorList,tmpNum - 1)
						EndIf
					EndIf
					
					UpdateEditorList()
	      		EndIf
	      	Else
	      		ForEach cueList()
					StopCue(@cueList())
				Next
				ForEach *gSelection()
					DeleteCue(*gSelection())
				Next
				*gCurrentCue = 0
				UpdateEditorList()
				ClearList(*gSelection())
			EndIf
      	ElseIf MenuID = #ExplorerSc
      		Event = #PB_Event_Gadget
      		GadgetID = #ExplorerButton
      	EndIf
      	
      	For i = 0 To #MAX_RECENT - 1
      		If MenuID = i
      			path = gRecentFiles(i)
      			
      			If path <> ""	
					ClearCueList()
					
					CreateThread(@Open_LoadWindow(),0)
					
					If LoadCueList(path)
						gSavePath = path
						
						*gCurrentCue = FirstElement(cueList())
						UpdateMainCueList()
						UpdateEditorList()
						UpdateCueControls()
					EndIf
				EndIf
			EndIf
		Next i
	EndIf
	;}
	
	;- Selaimen koko
	;{
	If Event = #PB_Event_SizeWindow
		If WindowID = #ExplorerWindow
			ResizeGadget(#FileBrowser,0,24,WindowWidth(#ExplorerWindow),WindowHeight(#ExplorerWindow) - 24)
			ResizeGadget(#RefreshBrowser,WindowWidth(#ExplorerWindow) - 22,2,#PB_Ignore,#PB_Ignore)
		ElseIf WindowID = #MainWindow
			ResizeGadget(#CueList,#PB_Ignore,#PB_Ignore,WindowWidth(#MainWindow) - 20,WindowHeight(#MainWindow) - 120)
			ResizeGadget(#MasterSlider,Max(510,WindowWidth(#MainWindow) - 300),#PB_Ignore,#PB_Ignore,#PB_Ignore)
			ResizeGadget(#Text_2,Max(510,WindowWidth(#MainWindow) - 300),#PB_Ignore,#PB_Ignore,#PB_Ignore)
			
			SetGadgetItemAttribute(#CueList,0,#PB_ListIcon_ColumnWidth,Round(GadgetWidth(#CueList) / 3,#PB_Round_Down),0)
			For i = 1 To 4
				SetGadgetItemAttribute(#CueList,i,#PB_ListIcon_ColumnWidth,Round((GadgetWidth(#CueList) * (2 / 3)) / 4 - 1,#PB_Round_Down),i)
			Next i
		EndIf
	EndIf
	;}
	
	;- P‰‰ikkuna
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
					While *gCurrentCue\state <> #STATE_STOPPED Or *gCurrentCue\startMode <> #START_MANUAL
						*gCurrentCue = NextElement(cueList())
							
						If *gCurrentCue = 0
							Break
						EndIf
					Wend
				EndIf

				UpdateMainCueList()
				
				If gSaved = #True
					FirstElement(cueList())
					gLastHash = CRC32Fingerprint(@cueList(),SizeOf(Cue) * ListSize(cueList()))
				EndIf
			EndIf
		ElseIf GadgetID = #PauseButton
			
		ElseIf GadgetID = #StopButton
			ForEach cueList()
				StopCue(@cueList())
			Next
			UpdateMainCueList()
			
			If gSaved = #True
				FirstElement(cueList())
				gLastHash = CRC32Fingerprint(@cueList(),SizeOf(Cue) * ListSize(cueList()))
			EndIf
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
			ForEach cueList()
				StopCue(@cueList())
			Next
			UpdateMainCueList()
			
			HideWindow(#EditorWindow,0)
			
			If *gCurrentCue = 0
				*gCurrentCue = FirstElement(cueList())
			EndIf
			
			UpdateEditorList()
			
			If *gCurrentCue <> 0
				UpdateCueControls()
			EndIf
			
			gEditor = #True
		ElseIf GadgetID = #SettingsButton
			If Not IsWindow(#SettingsWindow)
				Open_SettingsWindow()
			Else
				HideWindow(#SettingsWindow, 0)
				UpdateListSettings()
			EndIf
		ElseIf GadgetID = #EditorList ;-Editori
			ForEach cueList()
				StopCue(@cueList())
			Next
			
			ClearList(*gSelection())
			
			If GetGadgetState(#EditorList) > -1
				For i = 0 To CountGadgetItems(#EditorList) - 1
					If GetGadgetItemState(#EditorList,i) = 1
						AddElement(*gSelection())
						*gSelection() = GetGadgetItemData(#EditorList,i)
					EndIf
				Next i
			EndIf
			
			*gCurrentCue = GetGadgetItemData(#EditorList,GetGadgetState(#EditorList))

			If *gCurrentCue <> 0
				UpdateCueControls()
			EndIf
		ElseIf GadgetID = #AddAudio ;--- Editorin napit
			ForEach cueList()
				StopCue(@cueList())
			Next
			
			*gCurrentCue = AddCue(#TYPE_AUDIO)
			UpdateEditorList()
			UpdateCueControls()
		ElseIf GadgetID = #AddChange
			ForEach cueList()
				StopCue(@cueList())
			Next
			
			*gCurrentCue = AddCue(#TYPE_CHANGE)
			UpdateEditorList()
			UpdateCueControls()
		ElseIf GadgetID = #AddEvent
			ForEach cueList()
				StopCue(@cueList())
			Next
			
			*gCurrentCue = AddCue(#TYPE_EVENT)
			UpdateEditorList()
			UpdateCueControls()
		ElseIf GadgetID = #AddVideo
		ElseIf GadgetID = #AddNote
			ForEach cueList()
				StopCue(@cueList())
			Next
			
			*gCurrentCue = AddCue(#TYPE_NOTE,"NOTE:")
			*gCurrentCue\startMode = #START_AFTER_START
			UpdateEditorList()
			UpdateCueControls()
		ElseIf GadgetID = #ExplorerButton
			If Not IsWindow(#ExplorerWindow)
				Open_ExplorerWindow()
			Else
				HideWindow(#ExplorerWindow, 0)
				SetActiveWindow(#ExplorerWindow)
			EndIf
			
		ElseIf GadgetID = #MasterSlider
			BASS_SetVolume(GetGadgetState(#MasterSlider) / 100)
		ElseIf GadgetID = #CueNameField 
			*gCurrentCue\name = GetGadgetText(#CueNameField)
			UpdateEditorList()
  		ElseIf GadgetID = #CueDescField
  			*gCurrentCue\desc = GetGadgetText(#CueDescField)
  			UpdateEditorList()
    	ElseIf GadgetID = #OpenCueFile ;--- Tiedoston lataus
    		Select *gCurrentCue\cueType
    			Case #TYPE_AUDIO
    				pattern.s = "Audio files (*.mp3,*.wav,*.ogg,*.aiff,*.wma,*.flac,*.aac,*.m4a) |*.mp3;*.wav;*.ogg;*.aiff;*.wma;*.flac;*.aac;*.m4a"
    		EndSelect
    		
    		path.s = OpenFileRequester("Select file","",pattern,0)
    		
    		If path
    			*gCurrentCue\absolutePath = path
    			
    			If gListSettings(#SETTING_RELATIVE) = 1
    				*gCurrentCue\relativePath = RelativePath(GetPathPart(gSavePath),GetPathPart(path)) + GetFilePart(path)
    				*gCurrentCue\filePath = *gCurrentCue\relativePath
    			Else
    				*gCurrentCue\filePath = *gCurrentCue\absolutePath
    			EndIf
    			
    			Select *gCurrentCue\cueType
    				Case #TYPE_AUDIO
						gLoadThread = CreateThread(@LoadCueStream2(),*gCurrentCue)	
    			EndSelect
    			
    			If *gCurrentCue\desc = ""
    				file.s = GetFilePart(path)
    				*gCurrentCue\desc = Mid(file,0,Len(file) - 4)
    			EndIf
    			
    			UpdateCueControls()
    			UpdateEditorList()
    			
    			
    		EndIf
    	ElseIf GadgetID = #Image_1
      
    	ElseIf GadgetID = #ModeSelect ;--- Aloitustapa
    		*gCurrentCue\startMode = GetGadgetItemData(#ModeSelect,GetGadgetState(#ModeSelect))
    		
    		If *gCurrentCue\startMode = #START_MANUAL
    			If *gCurrentCue\afterCue <> 0
    				ForEach *gCurrentCue\afterCue\followCues()
    					If *gCurrentCue\afterCue\followCues() = *gCurrentCue
    						DeleteElement(*gCurrentCue\afterCue\followCues())
    					EndIf
    				Next
    				
    				*gCurrentCue\afterCue = 0
    			EndIf
    		EndIf
    		
    		UpdateCueControls()
    	ElseIf GadgetID = #EditorPlay Or GadgetID = #EffectPlay ;--- Esikuuntelu
    		If *gCurrentCue\state = #STATE_PAUSED
    			PauseCue(*gCurrentCue)
    		ElseIf *gCurrentCue\state <> #STATE_PLAYING
    			PlayCue(*gCurrentCue)
    		EndIf
    		
    		SetGadgetState(#EditorPause,0)
    		SetGadgetState(#EditorPlay,1)
    		SetGadgetState(#EffectPause,0)
    		SetGadgetState(#EffectPlay,1)
    	ElseIf GadgetID = #EditorPause Or GadgetID = #EffectPause
    		If *gCurrentCue\state <> #STATE_STOPPED
	    		PauseCue(*gCurrentCue)
	    		
	    		If *gCurrentCue\state = #STATE_PAUSED
	    			SetGadgetState(#EditorPlay,0)
	    			SetGadgetState(#EffectPlay,0)
	    		Else
	    			SetGadgetState(#EditorPlay,1)
	    			SetGadgetState(#EffectPlay,1)
	    		EndIf
	    	EndIf
    	ElseIf GadgetID = #EditorStop Or GadgetID = #EffectStop
    		StopCue(*gCurrentCue)
    		
    		SetGadgetState(#EditorPlay,0)
    		SetGadgetState(#EditorPause,0)
    		SetGadgetState(#EffectPlay,0)
    		SetGadgetState(#EffectPause,0)
    		
    		UpdatePosField()
      	ElseIf GadgetID = #StartPos ;--- Rajaus, fade, pan, volume
      		*gCurrentCue\startPos = StringToSeconds(GetGadgetText(#StartPos))
      	ElseIf GadgetID = #EndPos
      		*gCurrentCue\endPos = StringToSeconds(GetGadgetText(#EndPos))
      	ElseIf GadgetID = #FadeIn
      		*gCurrentCue\fadeIn = ValF(GetGadgetText(#FadeIn))
      	ElseIf GadgetID = #FadeOut
      		*gCurrentCue\fadeOut = ValF(GetGadgetText(#FadeOut))
      	ElseIf GadgetID = #VolumeSlider
      		*gCurrentCue\volume = GetGadgetState(#VolumeSlider) / 1000.0
      		SetGadgetText(#CueVolume,StrF(*gCurrentCue\volume * 100.0,1))
      	ElseIf GadgetID = #PanSlider
      		*gCurrentCue\pan = (GetGadgetState(#PanSlider) - 1000) / 1000.0
      		SetGadgetText(#CuePan,StrF(*gCurrentCue\pan * 100.0,1))
      	ElseIf GadgetID = #CueVolume
      		*gCurrentCue\volume = Max(0,Min(100.0,ValF(GetGadgetText(#CueVolume)))) / 100.0
      		SetGadgetState(#VolumeSlider,*gCurrentCue\volume * 1000)
      	ElseIf GadgetID = #CuePan
      		*gCurrentCue\pan = Max(-100.0,Min(100.0,ValF(GetGadgetText(#CuePan)))) / 100.0
			SetGadgetState(#PanSlider,*gCurrentCue\pan * 1000 + 1000)
      	ElseIf GadgetID = #DeleteButton ;--- Listan k‰sittely
      		If ListSize(*gSelection()) <= 1
	      		If *gCurrentCue <> 0
	      			ForEach cueList()
						StopCue(@cueList())
					Next
					
					tmpNum = GetGadgetState(#EditorList)
					Debug "Position: " + Str(tmpNum)
					
					DeleteCue(*gCurrentCue)
					*gCurrentCue = 0
					UpdateEditorList()

					If CountGadgetItems(#EditorList) > tmpNum
						*gCurrentCue = GetGadgetItemData(#EditorList,tmpNum)
					Else
						If gCueAmount > 0
							*gCurrentCue = GetGadgetItemData(#EditorList,tmpNum - 1)
						EndIf
					EndIf
					
					UpdateEditorList()
	      		EndIf
	      	Else
	      		ForEach cueList()
					StopCue(@cueList())
				Next
				ForEach *gSelection()
					DeleteCue(*gSelection())
				Next
				*gCurrentCue = 0
				UpdateEditorList()
				ClearList(*gSelection())
			EndIf
      	ElseIf GadgetID = #UpButton
      		If ListSize(*gSelection()) = 1
      			MoveCueUp(*gCurrentCue)
      		Else     			
      			If FirstElement(*gSelection()) <> FirstElement(cueList())
      				ForEach *gSelection()
      					MoveCueUp(*gSelection())
      				Next
      			EndIf
      		EndIf
      		UpdateEditorList()
      	ElseIf GadgetID = #DownButton
      		If ListSize(*gSelection()) = 1
      			MoveCueDown(*gCurrentCue)
      		Else
      			If LastElement(*gSelection()) <> LastElement(cueList())
      				LastElement(*gSelection())
      				Repeat
      					MoveCueDown(*gSelection())
      				Until PreviousElement(*gSelection()) = 0
      			EndIf
      		EndIf
      		UpdateEditorList()
		ElseIf GadgetID = #StartDelay	;--- Delay, cuen valinta, muutoksen nopeus
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
		ElseIf GadgetID = #LoopEnable ;--- Looppaus
			If GetGadgetState(#LoopEnable) = #PB_Checkbox_Checked
				*gCurrentCue\looped = #True
				DisableGadget(#LoopStart, 0)
				DisableGadget(#LoopEnd, 0)
				DisableGadget(#LoopCount, 0)
			Else
				*gCurrentCue\looped = #False
				
				If *gCurrentCue\loopHandle <> 0
					BASS_ChannelRemoveSync(*gCurrentCue\stream,*gCurrentCue\loopHandle)
					*gCurrentCue\loopHandle = 0
				EndIf
				
				DisableGadget(#LoopStart, 1)
				DisableGadget(#LoopEnd, 1)
				DisableGadget(#LoopCount, 1)
			EndIf
			UpdateCueControls()
		ElseIf GadgetID = #LoopStart
			*gCurrentCue\loopStart = StringToSeconds(GetGadgetText(#LoopStart))
		ElseIf GadgetID = #LoopEnd
			*gCurrentCue\loopEnd = StringToSeconds(GetGadgetText(#LoopEnd))
		ElseIf GadgetID = #LoopCount
			*gCurrentCue\loopCount = Val(GetGadgetText(#LoopCount))
		ElseIf GadgetID = #EditorTabs ;--- Efektien asetukset
			If *gCurrentCue <> 0
				UpdateCueControls()
			EndIf
		ElseIf GadgetID = #EffectType
			If *gCurrentCue <> 0
				UpdateCueControls()
			EndIf
		ElseIf GadgetID = #AddEffect
			AddCueEffect(*gCurrentCue,GetGadgetItemData(#EffectType,GetGadgetState(#EffectType)))
			UpdateCueControls()
		EndIf
		
		;----- Efektien s‰‰timet
		;{
		If *gCurrentCue <> 0 And ListSize(*gCurrentCue\effects()) > 0
			ForEach *gCurrentCue\effects()
				With *gCurrentCue\effects()
					Select \type
						Case #BASS_FX_DX8_REVERB ;------- Reverb
							If GadgetID = \gadgets[5]
								value.f = (GetGadgetState(\gadgets[5]) - 960) / 10.0
								\revParam\fInGain = value
								
								SetGadgetText(\gadgets[9],StrF(value,1))
								
								BASS_FXSetParameters(*gCurrentCue\effects()\handle,@\revParam)
							ElseIf GadgetID = \gadgets[6]
								value.f = (GetGadgetState(\gadgets[6]) - 960) / 10.0
								\revParam\fReverbMix = value
								
								SetGadgetText(\gadgets[10],StrF(value,1))
								
								BASS_FXSetParameters(*gCurrentCue\effects()\handle,@\revParam)
							ElseIf GadgetID = \gadgets[7]
								value.f = GetGadgetState(\gadgets[7])
								\revParam\fReverbTime = value
								
								SetGadgetText(\gadgets[11],Str(value))
								
								BASS_FXSetParameters(*gCurrentCue\effects()\handle,@\revParam)
							ElseIf GadgetID = \gadgets[8]
								value.f = GetGadgetState(\gadgets[8]) / 1000.0
								\revParam\fHighFreqRTRatio = value
								
								SetGadgetText(\gadgets[12],StrF(value,3))
								
								BASS_FXSetParameters(*gCurrentCue\effects()\handle,@\revParam)
							EndIf
						Case #BASS_FX_DX8_PARAMEQ ;------- EQ
							If GadgetID = \gadgets[5]
								value.f = GetGadgetState(\gadgets[5])
								\eqParam\fCenter = value
								
								SetGadgetText(\gadgets[9],Str(value))
								
								BASS_FXSetParameters(*gCurrentCue\effects()\handle,@\eqParam)
							ElseIf GadgetID = \gadgets[6]
								value.f = GetGadgetState(\gadgets[6]) / 10.0
								\eqParam\fBandwidth = value
								
								SetGadgetText(\gadgets[10],StrF(value,1))
								
								BASS_FXSetParameters(*gCurrentCue\effects()\handle,@\eqParam)
							ElseIf GadgetID = \gadgets[7]
								value.f = (GetGadgetState(\gadgets[7]) - 150) / 10.0
								\eqParam\fGain = value
								
								SetGadgetText(\gadgets[11],StrF(value,1))
								
								BASS_FXSetParameters(*gCurrentCue\effects()\handle,@\eqParam)
							EndIf
						Case #EFFECT_VST ;------- VST
							If GadgetID = \gadgets[6]
								HideWindow(\gadgets[5],0)
							EndIf
					EndSelect
					
					If GadgetID = \gadgets[#EGADGET_DELETE]
						DeleteCueEffect(*gCurrentCue,@*gCurrentCue\effects())
					ElseIf GadgetID = \gadgets[#EGADGET_ACTIVE]
						state = GetGadgetState(\gadgets[#EGADGET_ACTIVE])
						DisableCueEffect(*gCurrentCue,@*gCurrentCue\effects(),OnOff(state))
						*gCurrentCue\effects()\defaultActive = state
						
						For i = 5 To 16
							If \gadgets[i] <> 0
								If Not IsWindow(\gadgets[i])
									DisableGadget(\gadgets[i],OnOff(state))
								EndIf
							EndIf
						Next i
					ElseIf GadgetID = \gadgets[#EGADGET_UP]
						*currentEffect.Effect = @*gCurrentCue\effects()
						
						If *currentEffect <> FirstElement(*gCurrentCue\effects())
							ChangeCurrentElement(*gCurrentCue\effects(),*currentEffect)
							*prevEffect.Effect = PreviousElement(*gCurrentCue\effects())

							SwapElements(*gCurrentCue\effects(),*currentEffect,*prevEffect)
							ChangeCurrentElement(*gCurrentCue\effects(),*currentEffect)
							
							For i = 0 To 16
								If \gadgets[i] <> 0 And Not IsWindow(\gadgets[i])
									ResizeGadget(\gadgets[i],#PB_Ignore,GadgetY(\gadgets[i]) - 115,#PB_Ignore,#PB_Ignore)
								EndIf
							Next i
							
							\priority + 1
							
							If \type <> #EFFECT_VST
								BASS_ChannelRemoveFX(*gCurrentCue\stream,\handle)
								\handle = BASS_ChannelSetFX(*gCurrentCue\stream,\type,\priority)
								If \type = #BASS_FX_DX8_REVERB
									BASS_FXSetParameters(\handle,\revParam)
								ElseIf \type = #BASS_FX_DX8_PARAMEQ
									BASS_FXSetParameters(\handle,\eqParam)
								EndIf
							Else
								count = BASS_VST_GetParamCount(\handle)
								Dim tmp.f(count - 1)
								For i = 0 To count - 1
									tmp(i) = BASS_VST_GetParam(\handle,i)
								Next i
								
								BASS_VST_ChannelRemoveDSP(*gCurrentCue\stream,\handle)
								\handle = BASS_VST_ChannelSetDSP(*gCurrentCue\stream,@\pluginPath,0,\priority)
								For i = 0 To count - 1
									BASS_VST_SetParam(\handle,i,tmp(i))
								Next i
								BASS_VST_EmbedEditor(\handle,WindowID(\gadgets[5]))
								FreeArray(tmp())
							EndIf
							
	
							*prevEffect\priority - 1
							
							If *prevEffect\type <> #EFFECT_VST
								BASS_ChannelRemoveFX(*gCurrentCue\stream,*prevEffect\handle)
								*prevEffect\handle = BASS_ChannelSetFX(*gCurrentCue\stream,*prevEffect\type,*prevEffect\priority)
								If *prevEffect\type = #BASS_FX_DX8_REVERB
									BASS_FXSetParameters(*prevEffect\handle,*prevEffect\revParam)
								ElseIf *prevEffect\type = #BASS_FX_DX8_PARAMEQ
									BASS_FXSetParameters(*prevEffect\handle,*prevEffect\eqParam)
								EndIf
							Else
								count = BASS_VST_GetParamCount(*prevEffect\handle)
								Dim tmp.f(count - 1)
								For i = 0 To count - 1
									tmp(i) = BASS_VST_GetParam(*prevEffect\handle,i)
								Next i
								
								BASS_VST_ChannelRemoveDSP(*gCurrentCue\stream,*prevEffect\handle)
								*prevEffect\handle = BASS_VST_ChannelSetDSP(*gCurrentCue\stream,@*prevEffect\pluginPath,0,*prevEffect\priority)
								For i = 0 To count - 1
									BASS_VST_SetParam(*prevEffect\handle,i,tmp(i))
								Next i
								BASS_VST_EmbedEditor(*prevEffect\handle,WindowID(*prevEffect\gadgets[5]))
								FreeArray(tmp())
							EndIf
							
							For i = 0 To 16 
								If *prevEffect\gadgets[i] <> 0 And Not IsWindow(*prevEffect\gadgets[i])
									ResizeGadget(*prevEffect\gadgets[i],#PB_Ignore,GadgetY(*prevEffect\gadgets[i]) + 115,#PB_Ignore,#PB_Ignore)
								EndIf
							Next i
						EndIf
					ElseIf GadgetID = \gadgets[#EGADGET_DOWN]
						*currentEffect.Effect = @*gCurrentCue\effects()
						
						If *currentEffect <> LastElement(*gCurrentCue\effects())
							ChangeCurrentElement(*gCurrentCue\effects(),*currentEffect)
							*nextEffect.Effect = NextElement(*gCurrentCue\effects())
							
							SwapElements(*gCurrentCue\effects(),*currentEffect,*nextEffect)
							ChangeCurrentElement(*gCurrentCue\effects(),*currentEffect)
							
							For i = 0 To 16
								If \gadgets[i] <> 0 And Not IsWindow(\gadgets[i])
									ResizeGadget(\gadgets[i],#PB_Ignore,GadgetY(\gadgets[i]) + 115,#PB_Ignore,#PB_Ignore)
								EndIf
							Next i
							
							\priority - 1
							
							If \type <> #EFFECT_VST
								BASS_ChannelRemoveFX(*gCurrentCue\stream,\handle)
								\handle = BASS_ChannelSetFX(*gCurrentCue\stream,\type,\priority)
								If \type = #BASS_FX_DX8_REVERB
									BASS_FXSetParameters(\handle,\revParam)
								ElseIf \type = #BASS_FX_DX8_PARAMEQ
									BASS_FXSetParameters(\handle,\eqParam)
								EndIf
							Else
								count = BASS_VST_GetParamCount(\handle)
								Dim tmp.f(count - 1)
								For i = 0 To count - 1
									tmp(i) = BASS_VST_GetParam(\handle,i)
								Next i
								
								BASS_VST_ChannelRemoveDSP(*gCurrentCue\stream,\handle)
								\handle = BASS_VST_ChannelSetDSP(*gCurrentCue\stream,@\pluginPath,0,\priority)
								For i = 0 To count - 1
									BASS_VST_SetParam(\handle,i,tmp(i))
								Next i
								BASS_VST_EmbedEditor(\handle,WindowID(\gadgets[5]))
								FreeArray(tmp())
							EndIf
							
							*nextEffect\priority + 1
							
							If *nextEffect\type <> #EFFECT_VST
								BASS_ChannelRemoveFX(*gCurrentCue\stream,*nextEffect\handle)
								*nextEffect\handle = BASS_ChannelSetFX(*gCurrentCue\stream,*nextEffect\type,*nextEffect\priority)
								If *nextEffect\type = #BASS_FX_DX8_REVERB
									BASS_FXSetParameters(*nextEffect\handle,*nextEffect\revParam)
								ElseIf *nextEffect\type = #BASS_FX_DX8_PARAMEQ
									BASS_FXSetParameters(*nextEffect\handle,*nextEffect\eqParam)
								EndIf
							Else
								count = BASS_VST_GetParamCount(*nextEffect\handle)
								Dim tmp.f(count - 1)
								For i = 0 To count - 1
									tmp(i) = BASS_VST_GetParam(*nextEffect\handle,i)
								Next i
								
								BASS_VST_ChannelRemoveDSP(*gCurrentCue\stream,*nextEffect\handle)
								*nextEffect\handle = BASS_VST_ChannelSetDSP(*gCurrentCue\stream,@*nextEffect\pluginPath,0,*nextEffect\priority)
								For i = 0 To count - 1
									BASS_VST_SetParam(*nextEffect\handle,i,tmp(i))
								Next i
								BASS_VST_EmbedEditor(*nextEffect\handle,WindowID(*nextEffect\gadgets[5]))
								FreeArray(tmp())
							EndIf
							
							For i = 0 To 16
								If *nextEffect\gadgets[i] <> 0 And Not IsWindow(*nextEffect\gadgets[i])
									ResizeGadget(*nextEffect\gadgets[i],#PB_Ignore,GadgetY(*nextEffect\gadgets[i]) - 115,#PB_Ignore,#PB_Ignore)
								EndIf
							Next i
						EndIf
						
					EndIf
						
				EndWith
			Next
		EndIf
		;}
		
		;- Listan asetukset
		;{
		If GadgetID = #CheckRelative ;--- Suhteelliset polut
			If gSavePath = ""
				MessageRequester("Attention","You need to save your list before you can use relative paths!")
				SetGadgetState(#CheckRelative, 0)
			Else
				gListSettings(#SETTING_RELATIVE) = GetGadgetState(#CheckRelative)
				
				If gListSettings(#SETTING_RELATIVE) = 1
					ChangePathsToRelative()
				EndIf
				
			EndIf
		ElseIf GadgetID = #SettingsOK
			HideWindow(#SettingsWindow, 1)
		EndIf
	
		If GadgetID = #FileBrowser And EventType = #PB_EventType_DragStart
			DragFiles(GetGadgetText(#FileBrowser) + GetGadgetItemText(#FileBrowser,GetGadgetState(#FileBrowser)))
		EndIf
		;}
		
		;- Ohjelman asetukset
		;{
		If GadgetID = #PrefCancel
			HideWindow(#PrefWindow,1)
		ElseIf GadgetID = #PrefOk
			gAppSettings(#SETTING_ADEVICE) = GetGadgetState(#SelectADevice) + 1
			BASS_SetDevice(gAppSettings(#SETTING_ADEVICE))
			
			gAppSettings(#SETTING_FONTSIZE) = Val(GetGadgetText(#FontSize))
			FreeFont(gCueListFont)
			gCueListFont = LoadFont(#PB_Any,"Microsoft Sans Serif",gAppSettings(#SETTING_FONTSIZE))
			SetGadgetFont(#CueList,FontID(gCueListFont))
			
			SaveAppSettings()
			
			HideWindow(#PrefWindow,1)
		EndIf
		
			
		;}
		
		;- About-ikkuna
		;{
		If GadgetID = #AboutLink
			RunProgram(GetGadgetText(#AboutLink))
		ElseIf GadgetID = #AboutOk
			HideWindow(#AboutWindow,1)
		EndIf
		;}
		
		;- Selaimen p‰ivitys
		If GadgetID = #RefreshBrowser
			tmpPath.s = GetPathPart(GetGadgetText(#FileBrowser))
			FreeGadget(#FileBrowser)
			
			ExplorerTreeGadget(#FileBrowser, 0, 24, WindowWidth(#ExplorerWindow), WindowHeight(#ExplorerWindow) - 24, tmpPath)
		EndIf
	EndIf

	
	For i = 0 To 5
		If GadgetID = eventCueSelect(i)
			*gCurrentCue\actionCues[i] = GetGadgetItemData(eventCueSelect(i),GetGadgetState(eventCueSelect(i)))
		EndIf
		
		If GadgetID = eventActionSelect(i)
			*gCurrentCue\actions[i] = GetGadgetItemData(eventActionSelect(i),GetGadgetState(eventActionSelect(i)))
			
			If *gCurrentCue\actions[i] = #EVENT_EFFECT_ON Or *gCurrentCue\actions[i] = #EVENT_EFFECT_OFF
				UpdateCueControls()
			EndIf
		EndIf
		
		If GadgetID = eventEffectSelect(i)
			*gCurrentCue\actionEffects[i] = GetGadgetItemData(eventEffectSelect(i),GetGadgetState(eventEffectSelect(i)))
		EndIf
	Next i

	If Event = #PB_Event_CloseWindow
		eWindow = EventWindow()

		If eWindow = #MainWindow
			If gSaved = #False And ListSize(cueList()) > 0
				result = MessageRequester("Cue","Cue list has been modified. Do you want to save it?",#PB_MessageRequester_YesNoCancel)
				
				If result = #PB_MessageRequester_Yes
					If gSavePath = ""
						check = 1
						gSavePath = SaveFileRequester("Save cue list","","Cue list files (*.clf) |*.clf",0)
					Else
						check = 0
					EndIf
					
					If gSavePath <> ""
						SaveCueList(gSavePath,check)
						End
					EndIf
				ElseIf result = #PB_MessageRequester_No
					End
				EndIf
			Else
				End
			EndIf
		Else
			HideWindow(eWindow,1)
			
			If eWindow = #EditorWindow
				ForEach cueList()
					StopCue(@cueList())
				Next
				
				gEditor = #False
				If IsWindow(#ExplorerWindow)
					HideWindow(#ExplorerWindow, 1)
				EndIf
			EndIf
		EndIf
	EndIf

	;- Drag&drop lataus
	;{
	If Event = #PB_Event_GadgetDrop
		If GadgetID = #EditorTabs
			If GetGadgetState(#EditorTabs) = 0	;Ladataan ‰‰ni
				If *gCurrentCue = 0	;Jos cuea ei ole auki, luodaan uusi
					ForEach cueList()
						StopCue(@cueList())
					Next
					
					*gCurrentCue = AddCue(#TYPE_AUDIO)
					UpdateEditorList()
				EndIf
				
				path.s = StringField(EventDropFiles(),1,Chr(10))
				If path And *gCurrentCue\cueType = #TYPE_AUDIO
	    			*gCurrentCue\absolutePath = path
	    			
	    			If gListSettings(#SETTING_RELATIVE) = 1
	    				*gCurrentCue\relativePath = RelativePath(GetPathPart(gSavePath),GetPathPart(path)) + GetFilePart(path)
	    				*gCurrentCue\filePath = *gCurrentCue\relativePath
	    			Else
	    				*gCurrentCue\filePath = *gCurrentCue\absolutePath
	    			EndIf
	    			
	    			Select *gCurrentCue\cueType
	    				Case #TYPE_AUDIO
	    					gLoadThread = CreateThread(@LoadCueStream2(),*gCurrentCue)
	    			EndSelect
	    			
	    			If *gCurrentCue\desc = ""
	    				file.s = GetFilePart(path)
	    				*gCurrentCue\desc = Mid(file,0,Len(file) - 4)
	    			EndIf
	    			
	    			UpdateCueControls()
	    			UpdateEditorList()
	    		EndIf
	    	ElseIf GetGadgetState(#EditorTabs) = 1 And *gCurrentCue\stream <> 0	;Ladataan VST
	    		path.s = StringField(EventDropFiles(),1,Chr(10))
	    		
	    		If path <> "" And Right(path,4) = ".dll"
	    			AddCueEffect(*gCurrentCue,#EFFECT_VST,0,0,1,-1,path)
	    			UpdateCueControls()
	    		EndIf
	    	EndIf
	    ElseIf GadgetID = #EditorList	;Luodaan uusi cue
	    	ForEach cueList()
				StopCue(@cueList())
			Next
			
	    	*gCurrentCue = AddCue(#TYPE_AUDIO)
			UpdateEditorList()
			
	    	path.s = StringField(EventDropFiles(),1,Chr(10))
			If path
	    		*gCurrentCue\absolutePath = path
	    			
	    		If gListSettings(#SETTING_RELATIVE) = 1
	    			*gCurrentCue\relativePath = RelativePath(GetPathPart(gSavePath),GetPathPart(path)) + GetFilePart(path)
	    			*gCurrentCue\filePath = *gCurrentCue\relativePath
	    		Else
	    			*gCurrentCue\filePath = *gCurrentCue\absolutePath
	    		EndIf
	    			
	    		Select *gCurrentCue\cueType
	    			Case #TYPE_AUDIO
	    				gLoadThread = CreateThread(@LoadCueStream2(),*gCurrentCue)
	    		EndSelect
	    			
	    		If *gCurrentCue\desc = ""
	    			file.s = GetFilePart(path)
	    			*gCurrentCue\desc = Mid(file,0,Len(file) - 4)
	    		EndIf
	    			
	    		UpdateCueControls()
	    		UpdateEditorList()
	    	EndIf
	    ElseIf GadgetID = #CueList
	    	path.s = StringField(EventDropFiles(),1,Chr(10))
	    	
	    	If Right(path,4) = ".clf"
	    		
	    		ClearCueList()
	    		
	    		CreateThread(@Open_LoadWindow(),0)
	    		
				If LoadCueList(path)
					gSavePath = path
					
					*gCurrentCue = FirstElement(cueList())
					UpdateMainCueList()
					UpdateEditorList()
					UpdateCueControls()
				EndIf
	    	EndIf
	    EndIf
	    	
	EndIf
	;}
	
	Delay(1)
	
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
			Case #TYPE_NOTE
				text = text + "  (Note)"
		EndSelect
		
		AddGadgetItem(#EditorList,i,text)
		SetGadgetItemData(#EditorList,i,@cueList())
		
		If ListSize(*gSelection()) <= 1
			If @cueList() = *gCurrentCue
				SetGadgetState(#EditorList,i)
			EndIf
		Else
			ForEach *gSelection()
				If *gSelection() = @cueList()
					SetGadgetItemState(#EditorList,i,1)
				EndIf
			Next
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
	HideGadget(#EditorPlay,1)
	HideGadget(#EditorPause,1)
	HideGadget(#EditorStop,1)
	HideGadget(#LoopStart, 1)
	HideGadget(#LoopEnd, 1)
	HideGadget(#LoopCount, 1)
	HideGadget(#LoopEnable, 1)
	HideGadget(#Text_21, 1)
	HideGadget(#Text_22, 1)
	HideGadget(#Text_23, 1)
	HideGadget(#Text_24, 1)
	HideGadget(#Position, 1)
	HideGadget(#Text_26, 1)
	
	For i = 0 To 5
		HideGadget(eventCueSelect(i),1)
		HideGadget(eventActionSelect(i),1)
		HideGadget(eventEffectSelect(i),1)
	Next i
	
	HideEffectControls()
EndProcedure

Procedure ShowCueControls()
	If *gCurrentCue <> 0
		HideCueControls()
		
		gControlsHidden = #False
		HideGadget(#CueNameField,0)
		HideGadget(#CueDescField,0)
		HideGadget(#Text_3,0)
		HideGadget(#Text_4,0)
		
		If *gCurrentCue\cueType <> #TYPE_NOTE
			HideGadget(#ModeSelect,0)
			HideGadget(#Text_8,0)
			HideGadget(#Text_16,0)
			HideGadget(#Text_17,0)
			HideGadget(#CueSelect,0)
			HideGadget(#StartDelay,0)
		EndIf
		
		Select *gCurrentCue\cueType
			Case #TYPE_AUDIO
				HideGadget(#CueFileField,0)
				HideGadget(#OpenCueFile,0)
				HideGadget(#LengthField,0)
				HideGadget(#Text_6,0)
				HideGadget(#Text_9,0)
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
				HideGadget(#EditorPlay,0)
				HideGadget(#EditorPause,0)
				HideGadget(#EditorStop,0)
				HideGadget(#LoopStart, 0)
				HideGadget(#LoopEnd, 0)
				HideGadget(#LoopCount, 0)
				HideGadget(#LoopEnable, 0)
				HideGadget(#Text_21, 0)
				HideGadget(#Text_22, 0)
				HideGadget(#Text_23, 0)
				HideGadget(#Text_24, 0)
				HideGadget(#Position, 0)
				
				ShowEffectControls()
			Case #TYPE_EVENT
				HideGadget(#Text_18,0)
				HideGadget(#Text_19,0)
				HideGadget(#Text_26,0)
				
				For i = 0 To 5
					HideGadget(eventCueSelect(i),0)
					HideGadget(eventActionSelect(i),0)
					HideGadget(eventEffectSelect(i),0)
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

Procedure HideEffectControls()
	ForEach cueList()
		If ListSize(cueList()\effects()) > 0
			ForEach cueList()\effects()
				For i = 0 To 16
					If cueList()\effects()\gadgets[i] <> 0
						If IsWindow(cueList()\effects()\gadgets[i])
							HideWindow(cueList()\effects()\gadgets[i],1)
						Else
							HideGadget(cueList()\effects()\gadgets[i],1)
						EndIf
					EndIf
				Next i
			Next
		EndIf
	Next
EndProcedure

Procedure ShowEffectControls()
	If ListSize(*gCurrentCue\effects()) > 0
		ForEach *gCurrentCue\effects()
			For i = 0 To 16
				If *gCurrentCue\effects()\gadgets[i] <> 0
					If Not IsWindow(*gCurrentCue\effects()\gadgets[i])
						HideGadget(*gCurrentCue\effects()\gadgets[i],0)
					EndIf
				EndIf
			Next i
		Next
	EndIf
EndProcedure

Procedure UpdateCueControls()
	If *gCurrentCue <> 0
		SetGadgetText(#CueNameField,*gCurrentCue\name)
		SetGadgetText(#CueDescField,*gCurrentCue\desc)
		SetGadgetText(#CueFileField,*gCurrentCue\filePath)
			
		SetGadgetText(#LengthField,SecondsToString(*gCurrentCue\length))
			
		SetGadgetText(#StartPos,SecondsToString(*gCurrentCue\startPos))
		SetGadgetText(#EndPos,SecondsToString(*gCurrentCue\endPos))
			
		SetGadgetText(#FadeIn,StrF(*gCurrentCue\fadeIn,2))
		SetGadgetText(#FadeOut,StrF(*gCurrentCue\fadeOut,2))
		
		SetGadgetText(#LoopStart,SecondsToString(*gCurrentCue\loopStart))
		SetGadgetText(#LoopEnd, SecondsToString(*gCurrentCue\loopEnd))
		SetGadgetText(#LoopCount, Str(*gCurrentCue\loopCount))
		If *gCurrentCue\looped = #True
			SetGadgetState(#LoopEnable,#PB_Checkbox_Checked)
			DisableGadget(#LoopStart, 0)
			DisableGadget(#LoopEnd, 0)
			DisableGadget(#LoopCount, 0)
		Else
			SetGadgetState(#LoopEnable,#PB_Checkbox_Unchecked)
			DisableGadget(#LoopStart, 1)
			DisableGadget(#LoopEnd, 1)
			DisableGadget(#LoopCount, 1)
		EndIf
			
		SetGadgetState(#VolumeSlider,*gCurrentCue\volume * 1000)
		SetGadgetState(#PanSlider,*gCurrentCue\pan * 1000 + 1000)
		SetGadgetText(#CueVolume,StrF(*gCurrentCue\volume * 100.0,1))
		SetGadgetText(#CuePan,StrF(*gCurrentCue\pan * 100.0,1))
			
		SetGadgetText(#StartDelay,StrF(*gCurrentCue\delay / 1000.0,2))
		
		SetGadgetText(#ChangeDur,StrF(*gCurrentCue\fadeIn,2))
			
		ClearGadgetItems(#CueSelect)
		If *gCurrentCue\startMode = #START_AFTER_END Or *gCurrentCue\startMode = #START_AFTER_START
			DisableGadget(#CueSelect, 0)
			i = 0
			ForEach cueList()
				If @cueList() <> *gCurrentCue And cueList()\cueType <> #TYPE_NOTE
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
			;SetGadgetState(#WaveImg,ImageID(*gCurrentCue\waveform))
			StartDrawing(CanvasOutput(#WaveImg))
			DrawImage(ImageID(*gCurrentCue\waveform),0,0)
			StopDrawing()
		Else
			;SetGadgetState(#WaveImg,ImageID(#BlankWave))
			StartDrawing(CanvasOutput(#WaveImg))
			DrawImage(ImageID(#BlankWave),0,0)
			StopDrawing()
		EndIf
		
		
		For i = 0 To 5
			ClearGadgetItems(eventCueSelect(i))
			ClearGadgetItems(eventActionSelect(i))
			ClearGadgetItems(eventEffectSelect(i))
			DisableGadget(eventEffectSelect(i),1)
			
			
			AddGadgetItem(eventCueSelect(i), 0, "")
			SetGadgetItemData(eventCueSelect(i), 0, 0)
			
			k = 1
			ForEach cueList()
				If @cueList() <> *gCurrentCue And cueList()\cueType <> #TYPE_NOTE
					AddGadgetItem(eventCueSelect(i), k, cueList()\name + "  " + cueList()\desc)
					SetGadgetItemData(eventCueSelect(i), k, @cueList())
					
					If @cueList() = *gCurrentCue\actionCues[i]
						SetGadgetState(eventCueSelect(i), k)
					EndIf
					
					k + 1
				EndIf
			Next
			
			AddGadgetItem(eventActionSelect(i), 0, "")
			SetGadgetItemData(eventActionSelect(i), 0, 0)
			
			AddGadgetItem(eventActionSelect(i), 1 , "Fade out")
			SetGadgetItemData(eventActionSelect(i), 1, #EVENT_FADE_OUT)
			
			AddGadgetItem(eventActionSelect(i), 2, "Stop")
			SetGadgetItemData(eventActionSelect(i), 2, #EVENT_STOP)
			
			AddGadgetItem(eventActionSelect(i), 3, "Release loop")
			SetGadgetItemData(eventActionSelect(i), 3, #EVENT_RELEASE)
			
			AddGadgetItem(eventActionSelect(i), 4, "Effect on")
			SetGadgetItemData(eventActionSelect(i), 4, #EVENT_EFFECT_ON)
			
			AddGadgetItem(eventActionSelect(i), 5, "Effect off")
			SetGadgetItemData(eventActionSelect(i), 5, #EVENT_EFFECT_OFF)
			
			If *gCurrentCue\actions[i] = #EVENT_FADE_OUT
				SetGadgetState(eventActionSelect(i), 1)
			ElseIf *gCurrentCue\actions[i] = #EVENT_STOP
				SetGadgetState(eventActionSelect(i), 2)
			ElseIf *gCurrentCue\actions[i] = #EVENT_RELEASE
				SetGadgetState(eventActionSelect(i),3)
			ElseIf *gCurrentCue\actions[i] = #EVENT_EFFECT_ON Or *gCurrentCue\actions[i] = #EVENT_EFFECT_OFF
				If *gCurrentCue\actions[i] = #EVENT_EFFECT_ON
					SetGadgetState(eventActionSelect(i), 4)
				Else
					SetGadgetState(eventActionSelect(i), 5)
				EndIf
				
				DisableGadget(eventEffectSelect(i),0)
	
				If *gCurrentCue\actionCues[i] <> 0
					AddGadgetItem(eventEffectSelect(i), 0, "")
					SetGadgetItemData(eventEffectSelect(i), 0, 0)
					
					k = 1
					ForEach *gCurrentCue\actionCues[i]\effects()
						AddGadgetItem(eventEffectSelect(i),k,*gCurrentCue\actionCues[i]\effects()\name + " " + Str(*gCurrentCue\actionCues[i]\effects()\id))
						SetGadgetItemData(eventEffectSelect(i),k,@*gCurrentCue\actionCues[i]\effects())
						
						If @*gCurrentCue\actionCues[i]\effects() = *gCurrentCue\actionEffects[i]
							SetGadgetState(eventEffectSelect(i),k)
						EndIf
						
						k + 1
					Next
				EndIf
				
			EndIf
		Next i
		
		UpdatePosField()
	
		If *gCurrentCue\cueType = #TYPE_AUDIO
			If GetGadgetState(#EffectType) > -1 And *gCurrentCue\stream <> 0
				DisableGadget(#AddEffect, 0)
			Else
				DisableGadget(#AddEffect, 1)
			EndIf
		Else
			DisableGadget(#AddEffect, 1)
		EndIf
		
		HideEffectControls()
		ShowEffectControls()
	EndIf

EndProcedure

Procedure PlayCue(*cue.Cue)
	If *cue\stream <> 0
		If *cue\delay > 0 And *cue\state = #STATE_STOPPED And gEditor = #False
			*cue\state = #STATE_WAITING
			*cue\startTime = ElapsedMilliseconds()
		Else
			*cue\state = #STATE_PLAYING
			*cue\startTime = ElapsedMilliseconds()
			BASS_ChannelSetPosition(*cue\stream,BASS_ChannelSeconds2Bytes(*cue\stream,*cue\startPos),#BASS_POS_BYTE)
			BASS_ChannelSetAttribute(*cue\stream,#BASS_ATTRIB_VOL,*cue\volume)
			BASS_ChannelSetAttribute(*cue\stream,#BASS_ATTRIB_PAN,*cue\pan)
			
			If *cue\looped = #True
				If *cue\loopHandle <> 0
					BASS_ChannelRemoveSync(*cue\stream,*cue\loopHandle)
					*cue\loopHandle = 0
				EndIf
				*cue\loopHandle = BASS_ChannelSetSync(*cue\stream,#BASS_SYNC_POS,BASS_ChannelSeconds2Bytes(*cue\stream,*cue\loopEnd),@LoopProc(),*cue)
			EndIf
			BASS_ChannelPlay(*cue\stream,0)
			
			If *cue\fadeIn > 0
				BASS_ChannelSetAttribute(*cue\stream,#BASS_ATTRIB_VOL,0)
				BASS_ChannelSlideAttribute(*cue\stream,#BASS_ATTRIB_VOL,*cue\volume,*cue\fadeIn * 1000)
			EndIf
			
			If gEditor = #False
				ForEach *cue\followCues()
					If *cue\followCues()\startMode = #START_AFTER_START
						If *cue\followCues()\cueType = #TYPE_AUDIO
							PlayCue(*cue\followCues())
						ElseIf *cue\followCues()\cueType = #TYPE_EVENT Or *cue\followCues()\cueType = #TYPE_CHANGE
							StartEvents(*cue\followCues())
						EndIf
					ElseIf *cue\followCues()\startMode = #START_AFTER_END
						*cue\followCues()\state = #STATE_WAITING_END
					EndIf
				Next
			EndIf
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
		BASS_ChannelSetPosition(*cue\stream,BASS_ChannelSeconds2Bytes(*cue\stream,*cue\startPos),#BASS_POS_BYTE)
		
		If gEditor = #False
			ForEach *cue\followCues()
				If *cue\followCues()\startMode = #START_AFTER_END
					PlayCue(*cue\followCues())
				EndIf
			Next
		Else
			SetGadgetState(#EditorPlay, 0)
			SetGadgetState(#EditorPause, 0)
		EndIf
		
		*cue\loopsDone = 0
		
		ForEach *cue\effects()
			DisableCueEffect(*cue,@*cue\effects(),OnOff(*cue\effects()\defaultActive))
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

Procedure LoopProc(handle.l,channel.l,d,*user.Cue)
	BASS_ChannelSetPosition(channel,BASS_ChannelSeconds2Bytes(channel,*user\loopStart),#BASS_POS_BYTE)
	
	If *user\loopCount > 0
		*user\loopsDone + 1
		If *user\loopsDone = *user\loopCount
			BASS_ChannelRemoveSync(channel,*user\loopHandle)
			*user\loopHandle = 0
			*user\loopsDone = 0
		EndIf
	EndIf
EndProcedure
	
Procedure StartEvents(*cue.Cue)
	If *cue\delay > 0 And *cue\state = #STATE_STOPPED
		*cue\state = #STATE_WAITING
		*cue\startTime = ElapsedMilliseconds()
	Else
		*cue\state = #STATE_STOPPED
		*cue\startTime = ElapsedMilliseconds()
		
		If *cue\cueType = #TYPE_EVENT
			For i = 0 To 5
				If *cue\actionCues[i] <> 0
					Select *cue\actions[i]
						Case #EVENT_FADE_OUT
							*cue\actionCues[i]\state = #STATE_FADING_OUT
							BASS_ChannelSlideAttribute(*cue\actionCues[i]\stream,#BASS_ATTRIB_VOL,0,*cue\actionCues[i]\fadeOut * 1000)
						Case #EVENT_STOP
							StopCue(*cue\actionCues[i])
						Case #EVENT_RELEASE
							If *cue\actionCues[i]\loopHandle <> 0
								BASS_ChannelRemoveSync(*cue\actionCues[i]\stream,*cue\actionCues[i]\loopHandle)
								*cue\actionCues[i]\loopHandle = 0
								*cue\actionCues[i]\loopsDone = 0
							EndIf
						Case #EVENT_EFFECT_ON
							If *cue\actionEffects[i] <> 0
								DisableCueEffect(*cue\actionCues[i],*cue\actionEffects[i],0)
							EndIf
						Case #EVENT_EFFECT_OFF
							If *cue\actionEffects[i] <> 0
								DisableCueEffect(*cue\actionCues[i],*cue\actionEffects[i],1)
							EndIf
					EndSelect
				EndIf
			Next i
		ElseIf *cue\cueType = #TYPE_CHANGE
			If *cue\actionCues[0] <> 0
				BASS_ChannelSlideAttribute(*cue\actionCues[0]\stream,#BASS_ATTRIB_VOL,*cue\volume,*cue\fadeIn * 1000)
				BASS_ChannelSlideAttribute(*cue\actionCues[0]\stream,#BASS_ATTRIB_PAN,*cue\pan,*cue\fadeIn * 1000)
			EndIf
		EndIf
		
		ForEach *cue\followCues()
			If *cue\followCues()\startMode = #START_AFTER_START Or *cue\followCues()\startMode = #START_AFTER_END
				If *cue\followCues()\cueType = #TYPE_AUDIO
					PlayCue(*cue\followCues())
				ElseIf *cue\followCues()\cueType = #TYPE_EVENT Or *cue\followCues()\cueType = #TYPE_CHANGE
					StartEvents(*cue\followCues())
				EndIf
			EndIf
		Next
	EndIf
	
	
EndProcedure

Procedure UpdateCues()
	ForEach cueList()
		If cueList()\state = #STATE_PLAYING		
			pos = BASS_ChannelBytes2Seconds(cueList()\stream,BASS_ChannelGetPosition(cueList()\stream,#BASS_POS_BYTE))
			
			If cueList()\loopHandle = 0
				If cueList()\fadeOut > 0
					If pos >= (cueList()\endPos - cueList()\fadeOut) And BASS_ChannelIsSliding(cueList()\stream,#BASS_ATTRIB_VOL) = 0
						cueList()\state = #STATE_FADING_OUT
						BASS_ChannelSlideAttribute(cueList()\stream,#BASS_ATTRIB_VOL,0,cueList()\fadeOut * 1000)
					EndIf
				EndIf
				
				If pos >= cueList()\endPos ;And Not BASS_ChannelIsSliding(cueList()\stream,#BASS_ATTRIB_VOL)
					StopCue(@cueList())
				EndIf
			EndIf
		ElseIf cueList()\state = #STATE_WAITING
			If ElapsedMilliseconds() >= (cueList()\startTime + cueList()\delay)
				If cueList()\cueType = #TYPE_AUDIO
					PlayCue(@cueList())
				ElseIf cueList()\cueType = #TYPE_EVENT Or cueList()\cueType = #TYPE_CHANGE
					StartEvents(@cueList())
				EndIf
			EndIf
		ElseIf cueList()\state = #STATE_FADING_OUT And Not BASS_ChannelIsSliding(cueList()\stream,#BASS_ATTRIB_VOL)
			StopCue(@cueList())
		EndIf
		
	Next
EndProcedure

Procedure UpdateMainCueList()
	SetGadgetState(#CueList,-1)
	
	listAmount = CountGadgetItems(#CueList)
	If gCueAmount > listAmount
		For i = 1 To (gCueAmount - listAmount)
			AddGadgetItem(#CueList,-1,"")
		Next i
	ElseIf gCueAmount < listAmount
		For i = 1 To (listAmount - gCueAmount)
			RemoveGadgetItem(#CueList,listAmount - i)
		Next i
	EndIf
	
	i = 0
	
	ForEach cueList()
		Select cueList()\cueType
			Case #TYPE_AUDIO
				text.s = "Audio"
				color = RGB(100,200,200)
			Case #TYPE_VIDEO
				text.s = "Video"
			Case #TYPE_CHANGE
				text.s = "Change"
				color = RGB(200,100,200)
			Case #TYPE_EVENT
				text.s = "Event"
				color = RGB(100,200,100)
			Case #TYPE_NOTE
				text.s = "Note"
				color = RGB(240,190,0)
		EndSelect
		
		If cueList()\cueType <> #TYPE_NOTE
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
				Case #STATE_FADING_OUT
					state.s = "Fading out"
			EndSelect
		Else
			start.s = ""
			state.s = ""
		EndIf
		
		
		
		secs.f = BASS_ChannelBytes2Seconds(cueList()\stream,BASS_ChannelGetPosition(cueList()\stream,#BASS_POS_BYTE))
		
		;AddGadgetItem(#CueList, i, cueList()\name + "  " + cueList()\desc + Chr(10) + text + Chr(10) + start + Chr(10) + state + Chr(10) + "-" + SecondsToString(cueList()\endPos - secs))
		SetGadgetItemText(#CueList, i, cueList()\name + "  " + cueList()\desc,0)
		SetGadgetItemText(#CueList, i, text, 1)
		SetGadgetItemText(#CueList, i, start, 2)
		SetGadgetItemText(#CueList, i, state, 3)
		
		If cueList()\cueType <> #TYPE_NOTE
			SetGadgetItemText(#CueList, i, "-" + SecondsToString(cueList()\endPos - secs),4)
		EndIf
		
		SetGadgetItemData(#CueList, i, @cueList())
		SetGadgetItemColor(#CueList, i, #PB_Gadget_BackColor, color, -1)
		
		If @cueList() = *gCurrentCue
			SetGadgetState(#CueList,i)
		EndIf
		
		i + 1
	Next
EndProcedure

Procedure UpdatePosField()
	pos.f = BASS_ChannelBytes2Seconds(*gCurrentCue\stream,BASS_ChannelGetPosition(*gCurrentCue\stream,#BASS_POS_BYTE))
	SetGadgetText(#Position, SecondsToString(pos))
	
	If *gCurrentCue\waveform <> 0
		StartDrawing(CanvasOutput(#WaveImg))
		FrontColor($0000FF)
		DrawImage(ImageID(*gCurrentCue\waveform),0,0)
		
		tmpX = #WAVEFORM_W * (pos / *gCurrentCue\length)
		Triangle(tmpX - 5,0,tmpX + 5,0,tmpX,8,1)
		LineXY(tmpX,0,tmpX,120)
		StopDrawing()
	endif
EndProcedure

Procedure UpdateListSettings()
	SetGadgetState(#CheckRelative, gListSettings(#SETTING_RELATIVE))
EndProcedure

Procedure UpdateAppSettings()
	SetGadgetState(#SelectADevice,gAppSettings(#SETTING_ADEVICE) - 1)
EndProcedure

Procedure MoveCueUp(*cue.Cue)
	If *cue <> 0 And *cue <> FirstElement(cueList())
		GetCueListIndex(*cue)
		*prev.Cue = PreviousElement(cueList())
		SwapElements(cueList(),*cue,*prev)
	EndIf
EndProcedure

Procedure MoveCueDown(*cue.Cue)
	If *cue <> 0 And *cue <> LastElement(cueList())
		GetCueListIndex(*cue)
		*nex.Cue = NextElement(cueList())
		SwapElements(cueList(),*cue,*nex)
	EndIf
EndProcedure


