; PureBasic Visual Designer v3.95 build 1485 (PB4Code)


IncludeFile "includes\bass.pbi"
IncludeFile "includes\bassvst.pbi"
IncludeFile "includes\bass_dshow.pbi"
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
Declare UpdateOutputList()
Declare ShowOutputControls()
Declare HideOutputControls()

Open_MainWindow()
Open_EditorWindow()

HideWindow(#EditorWindow, 1)
HideCueControls()

BASS_Init(-1,44100,0,WindowID(#MainWindow),#Null)
xVideo_Init(WindowID(#MainWindow),0)

BASS_PluginLoad("basswma.dll",0)
BASS_PluginLoad("bassflac.dll",0)


Repeat ; Start of the event loop
	Event = WindowEvent() ; This line waits until an event is received from Windows
	WindowID = EventWindow() ; The Window where the event is generated, can be used in the gadget procedures
	GadgetID = EventGadget() ; Is it a gadget event?
	EventType = EventType() ; The event type
	
	
	If *gCurrentCue <> 0
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
			lastUpdate = ElapsedMilliseconds()
		EndIf
	EndIf
	
	;You can place code here, and use the result as parameters for the procedures
	
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
				gSavePath = path
				ClearCueList()
				LoadCueList(path)
				
				*gCurrentCue = FirstElement(cueList())
				UpdateMainCueList()
				UpdateEditorList()
				UpdateCueControls()
				UpdateOutputList()
			EndIf		      
		ElseIf MenuID = #MenuSave
			If gSavePath = ""
				check = 1
				gSavePath = OpenFileRequester("Save cue list","","Cue list files (*.clf) |*.clf",0)
			Else
				check = 0
			EndIf
			
			If gSavePath <> ""
				SaveCueList(gSavePath,check)
			EndIf  
		ElseIf MenuID = #MenuSaveAs
			gSavePath = OpenFileRequester("Save cue list","","Cue list files (*.clf) |*.clf",0)
			
			If gSavePath <> ""
				SaveCueList(gSavePath)
			EndIf
		ElseIf MenuID = #MenuPref

		ElseIf MenuID = #MenuExit
			End
		ElseIf MenuID = #MenuAbout
			Debug "GadgetID: #MenuAbout"      
		ElseIf MenuID = #PlaySc ;---Pikan‰pp‰imet
			Event = #PB_Event_Gadget
			GadgetID = #PlayButton
		ElseIf MenuID = #DeleteSc
			If *gCurrentCue <> 0
      			DeleteCue(*gCurrentCue)
      			*gCurrentCue = 0
      			UpdateEditorList()
      		EndIf
		EndIf	
	EndIf
	;}
	
	;- P‰‰ikkuna
	If Event = #PB_Event_Gadget
		If GadgetID = #PlayButton
			If *gCurrentCue <> 0
				If *gCurrentCue\cueType = #TYPE_AUDIO Or *gCurrentCue\cueType = #TYPE_VIDEO
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
			HideWindow(#EditorWindow,0)
			
			If *gCurrentCue = 0
				*gCurrentCue = FirstElement(cueList())
			EndIf
			
			UpdateEditorList()
			
			If *gCurrentCue <> 0
				UpdateCueControls()
			EndIf
			
			gEditor = #True
		ElseIf GadgetID = #EditorList ;-Editori
			*gCurrentCue = GetGadgetItemData(#EditorList,GetGadgetState(#EditorList))
			
			If *gCurrentCue <> 0
				UpdateCueControls()
			EndIf
		ElseIf GadgetID = #AddAudio ;--- Editorin napit
			*gCurrentCue = AddCue(#TYPE_AUDIO)
			UpdateEditorList()
			UpdateCueControls()
		ElseIf GadgetID = #AddChange
			*gCurrentCue = AddCue(#TYPE_CHANGE)
			UpdateEditorList()
			UpdateCueControls()
		ElseIf GadgetID = #AddEvent
			*gCurrentCue = AddCue(#TYPE_EVENT)
			UpdateEditorList()
			UpdateCueControls()
		ElseIf GadgetID = #AddVideo
			*gCurrentCue = AddCue(#TYPE_VIDEO)
			UpdateEditorList()
			UpdateCueControls()
		ElseIf GadgetID = #MasterSlider
			BASS_SetVolume(GetGadgetState(#MasterSlider) / 100)
		ElseIf GadgetID = #CueNameField 
			*gCurrentCue\name = GetGadgetText(#CueNameField)
			UpdateEditorList()
  		ElseIf GadgetID = #CueDescField
  			*gCurrentCue\desc = GetGadgetText(#CueDescField)
  			UpdateEditorList()
    	ElseIf GadgetID = #OpenCueFile
    		Select *gCurrentCue\cueType
    			Case #TYPE_AUDIO
    				pattern.s = "Audio files (*.mp3,*.wav,*.ogg,*.aiff,*.wma,*.flac) |*.mp3;*.wav;*.ogg;*.aiff;*.wma;*.flac"
    			Case #TYPE_VIDEO
    				pattern.s = "Video files |*.*"
    		EndSelect
    		
    		path.s = OpenFileRequester("Select file","",pattern,0)
    		
    		If path
    			*gCurrentCue\filePath = path
    			
    			Select *gCurrentCue\cueType
    				Case #TYPE_AUDIO, #TYPE_VIDEO
    					LoadCueStream(*gCurrentCue,path)
    			EndSelect
    			
    			If *gCurrentCue\desc = ""
    				file.s = GetFilePart(path)
    				*gCurrentCue\desc = Mid(file,0,Len(file) - 4)
    			EndIf
    			
    			UpdateCueControls()
    			UpdateEditorList()
    			
    			If *gCurrentCue\cueType = #TYPE_VIDEO
    				UpdateOutputList()
    			EndIf
    		EndIf
    	ElseIf GadgetID = #Image_1
      
    	ElseIf GadgetID = #ModeSelect ;--- Aloitustapa
    		*gCurrentCue\startMode = GetGadgetItemData(#ModeSelect,GetGadgetState(#ModeSelect))
    		UpdateCueControls()
    	ElseIf GadgetID = #EditorPlay ;--- Esikuuntelu
    		If *gCurrentCue\state = #STATE_PAUSED
    			PauseCue(*gCurrentCue)
    		ElseIf *gCurrentCue\state <> #STATE_PLAYING
    			PlayCue(*gCurrentCue)
    		EndIf
    		
    		SetGadgetState(#EditorPause,0)
    		SetGadgetState(#EditorPlay,1)
    	ElseIf GadgetID = #EditorPause
    		If *gCurrentCue\state <> #STATE_STOPPED
	    		PauseCue(*gCurrentCue)
	    		
	    		If *gCurrentCue\state = #STATE_PAUSED
	    			SetGadgetState(#EditorPlay,0)
	    		Else
	    			SetGadgetState(#EditorPlay,1)
	    		EndIf
	    	EndIf
    	ElseIf GadgetID = #EditorStop
    		StopCue(*gCurrentCue)
    		
    		SetGadgetState(#EditorPlay,0)
    		SetGadgetState(#EditorPause,0)
    		
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
		
		;--- Videon ulostulojen asetukset
		;{
		If GadgetID = #AddOutput
			AddCueOutput(*gCurrentCue)
			UpdateOutputList()
		ElseIf GadgetID = #DeleteOutput
			If *gCurrentOutput <> FirstElement(*gCurrentCue\outputs())
				DeleteCueOutput(*gCurrentCue,GetGadgetItemData(#OutputList,GetGadgetState(#OutputList)))
				UpdateOutputList()
				HideOutputControls()
			EndIf
		ElseIf GadgetID = #OutputList
			*gCurrentOutput = GetGadgetItemData(#OutputList,GetGadgetState(#OutputList))
			
			If *gCurrentOutput <> -1
				If *gCurrentOutput = FirstElement(*gCurrentCue\outputs())
					HideOutputControls()
				Else
					ShowOutputControls()
					
					If GetGadgetState(#KeepRatio) = 1
						ratio.f = *gCurrentOutput\width / *gCurrentOutput\height
					EndIf
				EndIf
			EndIf
		ElseIf GadgetID = #OutputX ;----- Paikka
			*gCurrentOutput\x = Val(GetGadgetText(#OutputX))
			ResizeWindow(*gCurrentOutput\window,DesktopX(*gCurrentOutput\monitor) + *gCurrentOutput\x,#PB_Ignore,#PB_Ignore,#PB_Ignore)
		ElseIf GadgetID = #OutputY
			*gCurrentOutput\y = Val(GetGadgetText(#OutputY))
			ResizeWindow(*gCurrentOutput\window,#PB_Ignore,DesktopY(*gCurrentOutput\monitor) + *gCurrentOutput\y,#PB_Ignore,#PB_Ignore)
		ElseIf GadgetID = #OutputW ;----- Koko
			*gCurrentOutput\width = Val(GetGadgetText(#OutputW))
			
			If GetGadgetState(#KeepRatio) = 1
				*gCurrentOutput\height = *gCurrentOutput\width * Pow(ratio.f,-1)
				SetGadgetText(#OutputH,Str(*gCurrentOutput\height))
			EndIf
			
			ResizeWindow(*gCurrentOutput\window,#PB_Ignore,#PB_Ignore,*gCurrentOutput\width,*gCurrentOutput\height)
			xVideo_ChannelResizeWindow(*gCurrentCue\stream,*gCurrentOutput\handle,0,0,*gCurrentOutput\width,*gCurrentOutput\height)
		ElseIf GadgetID = #OutputH
			*gCurrentOutput\height = Val(GetGadgetText(#OutputH))
			
			If GetGadgetState(#KeepRatio) = 1
				*gCurrentOutput\width = *gCurrentOutput\height * ratio.f
				SetGadgetText(#OutputW,Str(*gCurrentOutput\width))
			EndIf
			
			ResizeWindow(*gCurrentOutput\window,#PB_Ignore,#PB_Ignore,*gCurrentOutput\width,*gCurrentOutput\height)
			xVideo_ChannelResizeWindow(*gCurrentCue\stream,*gCurrentOutput\handle,0,0,*gCurrentOutput\width,*gCurrentOutput\height)
		ElseIf GadgetID = #OutputMonitor ;----- N‰yttˆ
			*gCurrentOutput\monitor = GetGadgetState(#OutputMonitor)
			ResizeWindow(*gCurrentOutput\window,DesktopX(*gCurrentOutput\monitor) + *gCurrentOutput\x,DesktopY(*gCurrentOutput\monitor) + *gCurrentOutput\y,#PB_Ignore,#PB_Ignore)
		ElseIf GadgetID = #OutputActive
			*gCurrentOutput\active = GetGadgetState(#OutputActive)
			
			If *gCurrentOutput\active = 0
				HideWindow(*gCurrentOutput\window,1)
			Else
				HideWindow(*gCurrentOutput\window,0)
			EndIf
		ElseIf GadgetID = #OutputName
			*gCurrentOutput\name = GetGadgetText(#OutputName)
			UpdateOutputList()
		ElseIf GadgetID = #KeepRatio
			If GetGadgetState(#KeepRatio) = 1
				ratio.f = *gCurrentOutput\width / *gCurrentOutput\height
			EndIf
		ElseIf GadgetID = #AlignHor ;----- Pika-asetukset
			*gCurrentOutput\x = DesktopWidth(*gCurrentOutput\monitor) / 2 - *gCurrentOutput\width / 2
			SetGadgetText(#OutputX,Str(*gCurrentOutput\x))
			
			ResizeWindow(*gCurrentOutput\window,DesktopX(*gCurrentOutput\monitor) + *gCurrentOutput\x,#PB_Ignore,#PB_Ignore,#PB_Ignore)
		ElseIf GadgetID = #AlignVer
			*gCurrentOutput\y = DesktopHeight(*gCurrentOutput\monitor) / 2 - *gCurrentOutput\height / 2
			SetGadgetText(#OutputY,Str(*gCurrentOutput\y))
			
			ResizeWindow(*gCurrentOutput\window,#PB_Ignore,DesktopY(*gCurrentOutput\monitor) + *gCurrentOutput\y,#PB_Ignore,#PB_Ignore)
		ElseIf GadgetID = #FullButton
			If GetGadgetState(#KeepRatio) = 0
				*gCurrentOutput\x = 0
				*gCurrentOutput\y = 0
				*gCurrentOutput\width = DesktopWidth(*gCurrentOutput\monitor)
				*gCurrentOutput\height = DesktopHeight(*gCurrentOutput\monitor)
			Else
				tmpW = DesktopWidth(*gCurrentOutput\monitor)
				tmpH = tmpW * Pow(ratio.f,-1)
				
				If tmpH > DesktopHeight(*gCurrentOutput\monitor)
					tmpH = DesktopHeight(*gCurrentOutput\monitor)
					tmpW = tmpH * ratio
				EndIf
				
				*gCurrentOutput\width = tmpW
				*gCurrentOutput\height = tmpH
				*gCurrentOutput\x = DesktopWidth(*gCurrentOutput\monitor) / 2 - *gCurrentOutput\width / 2
				*gCurrentOutput\y = DesktopHeight(*gCurrentOutput\monitor) / 2 - *gCurrentOutput\height / 2
			EndIf
			
			SetGadgetText(#OutputX,Str(*gCurrentOutput\x))
			SetGadgetText(#OutputY,Str(*gCurrentOutput\y))
			SetGadgetText(#OutputW,Str(*gCurrentOutput\width))
			SetGadgetText(#OutputH,Str(*gCurrentOutput\height))
			
			ResizeWindow(*gCurrentOutput\window,DesktopX(*gCurrentOutput\monitor) + *gCurrentOutput\x,DesktopY(*gCurrentOutput\monitor) + *gCurrentOutput\y,*gCurrentOutput\width,*gCurrentOutput\height)
			xVideo_ChannelResizeWindow(*gCurrentCue\stream,*gCurrentOutput\handle,0,0,*gCurrentOutput\width,*gCurrentOutput\height)
		EndIf
		;}
	
	EndIf
	
	For i = 0 To 5
		If GadgetID = eventCueSelect(i)
			*gCurrentCue\actionCues[i] = GetGadgetItemData(eventCueSelect(i),GetGadgetState(eventCueSelect(i)))
		EndIf
		
		If GadgetID = eventActionSelect(i)
			*gCurrentCue\actions[i] = GetGadgetItemData(eventActionSelect(i),GetGadgetState(eventActionSelect(i)))
		EndIf
	Next i
	
	If Event = #PB_Event_CloseWindow
		eWindow = EventWindow()

		If eWindow = #MainWindow
			End
		Else
			HideWindow(eWindow,1)
			
			If eWindow = #EditorWindow
				gEditor = #False
			EndIf
		EndIf
	EndIf
	
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
	HideGadget(#OutputList, 1)
	HideGadget(#Text_26, 1)
	HideGadget(#AddOutput, 1)
	HideGadget(#DeleteOutput, 1)

	For i = 0 To 5
		HideGadget(eventCueSelect(i),1)
		HideGadget(eventActionSelect(i),1)
	Next i
	
	HideEffectControls()
	HideOutputControls()
EndProcedure

Procedure ShowCueControls()
	If *gCurrentCue <> 0
		HideCueControls()
		
		gControlsHidden = #False
		HideGadget(#CueNameField,0)
		HideGadget(#CueDescField,0)
		HideGadget(#Text_3,0)
		HideGadget(#Text_4,0)
		HideGadget(#ModeSelect,0)
		HideGadget(#Text_8,0)
		HideGadget(#Text_16,0)
		HideGadget(#Text_17,0)
		HideGadget(#CueSelect,0)
		HideGadget(#StartDelay,0)
		
		Select *gCurrentCue\cueType
			Case #TYPE_AUDIO, #TYPE_VIDEO
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
				If *gCurrentCue\cueType = #TYPE_AUDIO
					HideGadget(#WaveImg,0)
				EndIf
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
				
				If *gCurrentCue\cueType = #TYPE_VIDEO
					HideGadget(#OutputList, 0)
					HideGadget(#Text_26, 0)
					HideGadget(#AddOutput, 0)
					HideGadget(#DeleteOutput, 0)
					
					If *gCurrentOutput <> 0
						ShowOutputControls()
					Else
						HideOutputControls()
					EndIf
					
				EndIf
				
				
				ShowEffectControls()
			Case #TYPE_EVENT
				HideGadget(#Text_18,0)
				HideGadget(#Text_19,0)
				
				For i = 0 To 5
					HideGadget(eventCueSelect(i),0)
					HideGadget(eventActionSelect(i),0)
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

Procedure HideOutputControls()
	HideGadget(#Text_27, 1)
	HideGadget(#Text_28, 1)
	HideGadget(#Text_29, 1)
	HideGadget(#Text_30, 1)
	HideGadget(#Text_31, 1)
	HideGadget(#Text_32, 1)
	HideGadget(#OutputMonitor, 1)
	HideGadget(#OutputX, 1)
	HideGadget(#OutputY, 1)
	HideGadget(#OutputW, 1)
	HideGadget(#OutputH, 1)
	HideGadget(#OutputActive, 1)
	HideGadget(#OutputName, 1)
	HideGadget(#KeepRatio, 1)
	HideGadget(#AlignHor, 1)
	HideGadget(#AlignVer, 1)
	HideGadget(#FullButton, 1)
EndProcedure

Procedure ShowOutputControls()
	HideGadget(#Text_27, 0)
	HideGadget(#Text_28, 0)
	HideGadget(#Text_29, 0)
	HideGadget(#Text_30, 0)
	HideGadget(#Text_31, 0)
	HideGadget(#Text_32, 0)
	HideGadget(#OutputMonitor, 0)
	HideGadget(#OutputX, 0)
	HideGadget(#OutputY, 0)
	HideGadget(#OutputW, 0)
	HideGadget(#OutputH, 0)
	HideGadget(#OutputActive, 0)
	HideGadget(#OutputName, 0)
	HideGadget(#KeepRatio, 0)
	HideGadget(#AlignHor, 0)
	HideGadget(#AlignVer, 0)
	HideGadget(#FullButton, 0)
	
	SetGadgetState(#OutputMonitor, *gCurrentOutput\monitor)
	SetGadgetState(#OutputActive, *gCurrentOutput\active)
	SetGadgetText(#OutputName, *gCurrentOutput\name)
	SetGadgetText(#OutputX, Str(*gCurrentOutput\x))
	SetGadgetText(#OutputY, Str(*gCurrentOutput\y))
	SetGadgetText(#OutputW, Str(*gCurrentOutput\width))
	SetGadgetText(#OutputH, Str(*gCurrentOutput\height))
	
EndProcedure

Procedure UpdateCueControls()
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

	If *gCurrentCue\waveform <> 0
		SetGadgetState(#WaveImg,ImageID(*gCurrentCue\waveform))
	Else
		SetGadgetState(#WaveImg,ImageID(#BlankWave))
	EndIf
	
	
	For i = 0 To 5
		ClearGadgetItems(eventCueSelect(i))
		ClearGadgetItems(eventActionSelect(i))
		
		k = 0
		ForEach cueList()
			If @cueList() <> *gCurrentCue
				AddGadgetItem(eventCueSelect(i), k, cueList()\name + "  " + cueList()\desc)
				SetGadgetItemData(eventCueSelect(i), k, @cueList())
				
				If @cueList() = *gCurrentCue\actionCues[i]
					SetGadgetState(eventCueSelect(i), k)
				EndIf
				
				k + 1
			EndIf
		Next
		
		AddGadgetItem(eventActionSelect(i), 0 , "Fade out")
		SetGadgetItemData(eventActionSelect(i), 0, #EVENT_FADE_OUT)
		AddGadgetItem(eventActionSelect(i), 1, "Stop")
		SetGadgetItemData(eventActionSelect(i), 1, #EVENT_STOP)
		AddGadgetItem(eventActionSelect(i), 2, "Release loop")
		SetGadgetItemData(eventActionSelect(i), 2, #EVENT_RELEASE)
		
		If *gCurrentCue\actions[i] = #EVENT_FADE_OUT
			SetGadgetState(eventActionSelect(i), 0)
		ElseIf *gCurrentCue\actions[i] = #EVENT_STOP
			SetGadgetState(eventActionSelect(i), 1)
		EndIf
	Next i
	
	UpdatePosField()

	If *gCurrentCue\cueType = #TYPE_AUDIO Or *gCurrentCue\cueType = #TYPE_VIDEO
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
EndProcedure

Procedure PlayCue(*cue.Cue)
	If *cue\stream <> 0
		If *cue\delay > 0 And *cue\state = #STATE_STOPPED
			*cue\state = #STATE_WAITING
			*cue\startTime = ElapsedMilliseconds()
		Else
			*cue\state = #STATE_PLAYING
			*cue\startTime = ElapsedMilliseconds()
			
			BASS_ChannelSetAttribute(*cue\stream,#BASS_ATTRIB_VOL,*cue\volume)
			BASS_ChannelSetAttribute(*cue\stream,#BASS_ATTRIB_PAN,*cue\pan)
			
			If *cue\cueType = #TYPE_AUDIO
				BASS_ChannelSetPosition(*cue\stream,BASS_ChannelSeconds2Bytes(*cue\stream,*cue\startPos),#BASS_POS_BYTE)
				
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
			ElseIf *cue\cueType = #TYPE_VIDEO
				If gEditor = #True
					FirstElement(*cue\outputs())
					HideWindow(*cue\outputs()\window,0)
				EndIf
				xVideo_ChannelSetPosition(*cue\stream,*cue\startPos * 1000,#xVideo_POS_MILISEC)
				xVideo_ChannelPlay(*cue\stream)
			EndIf
			
			
			ForEach *cue\followCues()
				If *cue\followCues()\startMode = #START_AFTER_START
					PlayCue(*cue\followCues())
				ElseIf *cue\followCues()\startMode = #START_AFTER_END
					*cue\followCues()\state = #STATE_WAITING_END
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
		
		If *cue\cueType = #TYPE_AUDIO
			BASS_ChannelStop(*cue\stream)
			BASS_ChannelSetPosition(*cue\stream,BASS_ChannelSeconds2Bytes(*cue\stream,*cue\startPos),#BASS_POS_BYTE)
		ElseIf *cue\cueType = #TYPE_VIDEO
			xVideo_ChannelStop(*cue\stream)
			xVideo_ChannelSetPosition(*cue\stream,*cue\startPos * 1000,#xVideo_POS_MILISEC)
		EndIf
		
		
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
			
			If *cue\cueType = #TYPE_AUDIO
				BASS_ChannelPause(*cue\stream)
			ElseIf *cue\cueType = #TYPE_VIDEO
				xVideo_ChannelPause(*cue\stream)
			EndIf
			
			ProcedureReturn #True
		ElseIf *cue\state = #STATE_PAUSED
			*cue\state = #STATE_PLAYING
			
			If *cue\cueType = #TYPE_AUDIO
				BASS_ChannelPlay(*cue\stream,0)
			ElseIf *cue\cueType = #TYPE_VIDEO
				xVideo_ChannelPlay(*cue\stream)
			EndIf
			
			
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
			PlayCue(*cue\followCues())
		EndIf
	Next
	
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
				PlayCue(@cueList())
			EndIf
		ElseIf cueList()\state = #STATE_FADING_OUT And Not BASS_ChannelIsSliding(cueList()\stream,#BASS_ATTRIB_VOL)
			StopCue(@cueList())
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
				color = RGB(0,200,200)
			Case #TYPE_VIDEO
				text.s = "Video"
				color = RGB(200,100,100)
			Case #TYPE_CHANGE
				text.s = "Change"
				color = RGB(200,0,200)
			Case #TYPE_EVENT
				text.s = "Event"
				color = RGB(200,200,0)
		EndSelect
		
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
		EndSelect
		
		secs.f = BASS_ChannelBytes2Seconds(cueList()\stream,BASS_ChannelGetPosition(cueList()\stream,#BASS_POS_BYTE))
		
		AddGadgetItem(#CueList, i, cueList()\name + "  " + cueList()\desc + Chr(10) + text + Chr(10) + start + Chr(10) + state + Chr(10) + "-" + SecondsToString(cueList()\endPos - secs))
		SetGadgetItemData(#CueList, i, @cueList())
		SetGadgetItemColor(#CueList, i, #PB_Gadget_BackColor, color, -1)
		
		If @cueList() = *gCurrentCue
			SetGadgetState(#CueList,i)
		EndIf
		
		i + 1
	Next
EndProcedure

Procedure UpdatePosField()
	If *gCurrentCue\cueType = #TYPE_AUDIO
		pos.f = BASS_ChannelBytes2Seconds(*gCurrentCue\stream,BASS_ChannelGetPosition(*gCurrentCue\stream,#BASS_POS_BYTE))
	ElseIf *gCurrentCue\cueType = #TYPE_VIDEO
		pos.f = xVideo_ChannelGetPosition(*gCurrentCue\stream,#xVideo_POS_MILISEC) / 1000.0
	EndIf
	
	SetGadgetText(#Position, SecondsToString(pos))
EndProcedure

Procedure UpdateOutputList()
	ClearGadgetItems(#OutputList)
	k = 0
	
	ForEach *gCurrentCue\outputs()
		AddGadgetItem(#OutputList, k, *gCurrentCue\outputs()\name)
		SetGadgetItemData(#OutputList, k, @*gCurrentCue\outputs())
		
		k + 1
	Next
EndProcedure

