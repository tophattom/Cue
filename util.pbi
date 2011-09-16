Structure Cue
	cueType.i
	
	name.s
	desc.s
	
	file.i
	
	startMode.i
	delay.i

	*afterCue.Cue

	startTime.l
	duration.l
	
	fadeIn.i
	fadeOut.i
	
	volume.i
	pan.i
	
	List *followCues.Cue()
EndStructure

Enumeration
	#CUE_AV
	#CUE_TRIGGER
	#CUE_CHANGE
	
	#START_MANUAL
	#START_AFTER_START
	#START_AFTER_END
	#START_HOTKEY
EndEnumeration
; IDE Options = PureBasic 4.50 (Windows - x86)
; CursorPosition = 32
; EnableXP