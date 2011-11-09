;****************************
;BASS_DSHOW PureBasic wrapper
;****************************


;-Version info
#xVideo_VERSION = $02040202
#xVideo_VERSIONTEXT$ = "2.4"


;-Stream creation flags
#xVideo_UNICODE = $80000000
#xVideo_STREAM_AUTOFREE = $40000
#xVideo_STREAM_DECODE = $200000
#xVideo_STREAM_MIX = $20000

;-xVideo_CaptureXX function flags
#xVideo_CaptureAudio = $10066
#xVideo_CaptureVideo = $10080

;-xVideo_ChannelGetState return values
Enumeration 1
	#xVideo_STATE_PLAYING
	#xVideo_STATE_PAUSED
	#xVideo_STATE_STOPPED
EndEnumeration

;-xVideo_ChannelGetLength/SetPosition/GetPosition modes
Enumeration 0
	#xVideo_POS_SEC
	#xVideo_POS_FRAME
	#xVideo_POS_MILISEC
	#xVideo_POS_REFTIME
EndEnumeration

;-xVideo_SetConfig configs and values
#xVideo_CONFIG_VideoRenderer = $1000
Enumeration 1
	#xVideo_VMR7
	#xVideo_VMR9
	#xVideo_VMR7WindowsLess
	#xVideo_VMR9WindowsLess
	#xVideo_EVR
	#xVideo_NULLVideo
EndEnumeration

#xVideo_CONFIG_WindowLessStreams = $1002
#xVideo_CONFIG_WindowLessHandle = $1001

;-Color controls flags
#xVideo_ControlBrightness = $00000001
#xVideo_ControlContrast = $00000002
#xVideo_ControlHue = $00000004
#xVideo_ControlSaturation = $00000008

;-xVideo_ChannelSet/GetAttribute constants
Enumeration 1
	#xVideo_ATTRIB_VOL
	#xVideo_ATTRIB_PAN
	#xVideo_ATTRIB_RATE
	#xVideo_ATTRIB_ALPHA
EndEnumeration

;-For video BMP functions
Structure xVideo_VideoBitmap
	visible.l
	inLeft.i
	inTop.i
	inRight.i
	inBottom.i
	outLeft.f
	outTop.f
	outRight.f
	outBottom.f
	alphavalue.f
	transColor.l
	bmp.l
EndStructure

;-For secondary get devices function
Structure xVideo_Device
	name.s
	guid.l
	type.l
EndStructure

;-xVideo_ChannelGetData
#xVideo_DATA_END = $80000000

;-xVideo_CallbackItemByIndex
Enumeration 1
	#xVideo_CALLBACK_AC
	#xVideo_CALLBACK_VC
	#xVideo_CALLBACK_AR
EndEnumeration

;-For xVideo_ChannelGetInfo()
Structure xVideo_ChannelInfo
	AvgTimePerFrame.d
	Height.i
	Width.i
	nChannels.i
	freq.l
	wBits.l
	floatingpoint.l
EndStructure

;-For xVideo_ChannelColorRange()
Structure xVideo_ColorsRange
	MinValue.f
	MaxValue.f
	DefaultSize.f
	StepSize.f
	type.l
EndStructure

;-For xVideo_ChannelSetColors()
Structure xVideo_ColorsSet
	Contrast.f
	Brightness.f
	Hue.f
	Saturation.f
EndStructure

;-xVideo_PLUGININFO
Structure xVideo_PLUGININFO
	version.l
	decoderType.l
	*plgdescription.s
EndStructure

;-// DVD function flags
;-for xVideo_DVDGetProperty function
#xVideo_CurentDVDTitle = $10010
#xVideo_DVDTitles = $10020
#xVideo_DVDTitleChapters = $10030
#xVideo_DVDCurrentTitleDuration = 145
#xVideo_DVDCurrentTitlePosition = 146

;-for xVideo_DVDSetProperty function
Enumeration 100
	#xVideo_DVD_TITLEMENU
	#xVideo_DVD_ROOT  
	#xVideo_DVD_NEXTCHAPTER     
	#xVideo_DVD_PREVCHAPTER   
	#xVideo_DVD_TITLE   
	#xVideo_DVD_TITLECHAPTER
EndEnumeration

;-for xVideo_DVDChannelMenu function
Enumeration 21
	#xVideo_DVDSelectAtPos
	#xVideo_DVDActionAtPos
	#xVideo_DVDActiveBut
	#xVideo_DVDSelectButton
EndEnumeration



;-xVideo error codes
Enumeration 0
	#xVideo_OK
	#xVideo_INVALIDCHAN 
	#xVideo_UNKNOWN
	#xVideo_NotInitialized
	#xVideo_POSNOTAVAILABLE
	#xVideo_NODSHOW
	#xVideo_INVALIDWINDOW
	#xVideo_NOAUDIO
	#xVideo_NOVIDEO
	#xVideo_ERRORMEM
	#xVideo_ERRORCALLBACK
	#xVideo_ERRORFLAG
	#xVideo_NOTAVAILABLE
	#xVideo_ERRORINIT
EndEnumeration


;-//// Functions \\\\
Import "BASS_DSHOW.lib"
	xVideo_ErrorGetCode.l()
	xVideo_GetVersion.l()
	xVideo_Init.l(handle.l,flags.l)
	xVideo_Free.l()
	
	xVideo_StreamCreateFile.l(*str,pos.l,win.l,flags.l)
	xVideo_ChannelPlay.l(chan.l)
	xVideo_ChannelPause.l(chan.l)
	xVideo_ChannelStop.l(chan.l)
	xVideo_StreamFree.l(chan.l)
	xVideo_ChannelAddWindow.l(chan.l,win.l)
	xVideo_ChannelRemoveWindow.l(chan.l,window.l)
	xVideo_ChannelGetLength.d(chan.l,mode.l)
	xVideo_ChannelGetPosition.d(chan.l,mode.l)
	xVideo_ChannelSetPosition.l(chan.l,pos.d,mode.l)
	xVideo_GetGraph.l(chan.l)
	xVideo_ChannelResizeWindow.l(chan.l,hVideo.l,left.i,top.i,right.i,bottom.i)
	xVideo_ChannelSetFullscreen.l(chan.l,value.l)
	xVideo_SetConfig.l(config.l,value.l)
	xVideo_ChannelGetInfo.l(chan.l,*info.xVideo_ChannelInfo)
	xVideo_ChannelGetBitmap.l(chan.l)
	xVideo_ChannelColorRange.l(chan.l,id.l,*ctrl.xVideo_ColorsRange)
	xVideo_ChannelSetColors.l(chan.l,id.l,*Struct.xVideo_ColorsSet)
	xVideo_SetVideoAlpha.l(chan.l,win.l,layer.i,alpha.d)
	xVideo_GetVideoAlpha.d(chan.l,win.l,layer.i)
	xVideo_MIXChannelResize.l(chan.l,layer.i,left.i,top.i,right.i,bottom.i)
	xVideo_CaptureGetDevices.i(devicetype.l,*callback,*user)
	xVideo_CaptureDeviceProfiles.i(device.i,devicetype.l,*callback,*user)
	xVideo_ChannelOverlayBitmap.l(chan.l,*Struct.xVideo_VideoBitmap)
	xVideo_ChannelSetWindow.l(chan.l,window.l,handle.l)
	xVideo_ChannelAddFile.l(chan.l,*filename,flags.l)
	xVideo_ChannelGetConnectedFilters.l(chan.l,*CALLBack,*user)
	xVideo_ShowFilterPropertyPage.l(chan.l,filter.l,parent.l)
	xVideo_ChannelGetState.l(chan.l)
	xVideo_ChannelSetFX.l(chan.l,fx.i)
	xVideo_ChannelRemoveFX.l(chan.l,fx.l)
	xVideo_SetFXParameters.l(chan.l,fx.l,*param)
	xVideo_GetFXParameters.l(chan.l,fx.l,*param)
	xVideo_ChannelSetAttribute.l(chan.l,option.l,value.d)
	xVideo_ChannelGetAttribute.d(chan.l,option.l)
	xVideo_CaptureCreate.l(audio.i,video.i,audioprofile.i,videoprofile.i,flags.l)
	xVideo_CaptureFree.l(chan.l)
	xVideo_GetAudioRenderers(*callback,*user)
	
	xVideo_StreamCreateFileMem(*dat,size.q,win.l,flags.l)
	xVideo_StreamCreateFileUser(flags.l,win.l,*proc,*user)
	
	xVideo_ChannelRemoveDSP.l(chan.l,dsp.l)
	xVideo_ChannelSetDSP.l(chan.l,*proc,*user)
	
	xVideo_ChannelGetData.l(chan.l,*dat,size.l)
	xVideo_ChannelRepaint.l(chan.l,handle.l,hDC.l)
	xVideo_CallbackItemByIndex.l(type.l,index.l)
	xVideo_LoadPlugin.l(*filename,flags.l)
	xVideo_PluginGetInfo.l(plugin.l,*info.xVideo_PLUGININFO)
	xVideo_RemovePlugin.l(plugin.l)
	
	xVideo_StreamCreateDVD.l(*dvd,win.l,flags.l)
	xVideo_DVDGetProperty.l(chan.l,prop.l,value.l)
	xVideo_DVDSetProperty.l(chan.l,prop.l,value.l)
	xVideo_DVDChannelMenu.l(chan.l,option.l,value1.i,value2.i)
	xVideo_GetConfig.l(config.l)
	xVideo_ChannelSetPositionVB.l(chan.l,pos.l,mode.l)
EndImport


	
	
	
	


