;-BASS_VST_ChannelSetDSP flag
#BASS_VST_KEEP_CHANS = $00000001

;-BASS_VST_GetParamInfo return
Structure BASS_VST_PARAM_INFO
	name.s{16}
	unit.s{16}
	display.s{16}
	defaultValue.f
EndStructure

;-BASS_VST_GetInfo return
Structure BASS_VST_INFO
	channelHandle.l
	uniqueId.l
	effectName.s{80}
	effectVersion.l
	effectVstVersion.l
	hostVstVersion.l
	productName.s{80}
	vendorName.s{80}
	vendorVersion.l
	chansIn.l
	chansOut.l
	initialDelay.l
	hasEditor.l
	editorWidth.l
	editorHeight.l
	*aefect
	isInstrument.l
	dspHandle.l
EndStructure

;-BASS_VST_SetCallback action constants
Enumeration 1
	#BASS_VST_PARAM_CHANGED
	#BASS_VST_EDITOR_RESIZED
	#BASS_VST_AUDIO_MASTER
EndEnumeration

Structure BASS_VST_AUDIO_MASTER_PARAM
	*aeffect
	opcode.l
	index.l
	value.l
	*ptr
	opt.f
	doDefault.l
EndStructure

;-Error codes
Enumeration 3000
	#BASS_VST_ERROR_NOINPUTS
	#BASS_VST_ERROR_NOOUTPUTS
	#BASS_VST_ERROR_NOREALTIME
EndEnumeration

;-//// Functions \\\\\
Import "bass_vst.lib"
	BASS_VST_ChannelSetDSP.l(chHandle.l,*dllFile.s,flags.l,priority.i)
	BASS_VST_ChannelRemoveDSP.l(chHandle.l,vstHandle.l)
	
	BASS_VST_ChannelCreate.l(freq.l,chans.l,*dllFile.s,flags.l)
	BASS_VST_ChannelFree.l(vstHandle.l)
	
	
	BASS_VST_GetParamCount.i(vstHandle.l)
	BASS_VST_GetParam.f(vstHandle.l,paramIndex.i)
	BASS_VST_SetParam.l(vstHandle.l,paramIndex.i,value.f)
	BASS_VST_GetParamInfo.l(vstHandle.l,paramIndex.i,*ret.BASS_VST_PARAM_INFO)
	
	BASS_VST_GetProgramCount.i(vstHandle.l)
	BASS_VST_GetProgram.i(vstHandle.l)
	BASS_VST_SetProgram.l(vstHandle.l,programIndex.i)
	BASS_VST_GetProgramParam.f(vstHandle.l,programIndex.i)
	BASS_VST_SetProgramParam.l(vstHandle.l,programIndex.i,*param.f)
	BASS_VST_GetProgramName.l(vstHandle.l,programIndex.i)
	BASS_VST_SetProgramName.l(vstHandle.l,programIndex.i,*name.s)
	
	BASS_VST_Resume.l(vstHandle.l)
	BASS_VST_SetBypass.l(vstHandle.l,state.l)
	BASS_VST_GetBypass.l(vstHandle.l)
	BASS_VST_GetInfo.l(vstHandle.l,*ret.BASS_VST_INFO)
	CompilerIf #PB_Compiler_OS=#PB_OS_Windows
		BASS_VST_EmbedEditor.l(vstHandle.l,parentWindow.l)
	CompilerElse
		BASS_VST_EmbedEditor.l(vstHandle.l,*parentWindow)
	CompilerEndIf
	BASS_VST_SetScope.l(vstHandle.l,scope.l)
	BASS_VST_SetCallback.l(vstHandle.l,*VSTPROC,*user)
	BASS_VST_SetLanguage.l(*lang.s)
	BASS_VST_ProcessEvent.l(vstHandle.l,midiCh.l,event.l,param.l)
	BASS_VST_ProcessEventRaw.l(vstHandle.l,*event,length.l)
EndImport
	
	

; IDE Options = PureBasic 4.50 (Windows - x86)
; CursorPosition = 40
; EnableXP