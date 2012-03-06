IncludeFile "includes\http.pbi"

;- FreeSound user structure
;{
;Description can be found at http://www.freesound.org/docs/api/resources.html#user-resource
Structure FreeSound_User
	userInfo.s[6]
	
	urls.s[5]
EndStructure
;}

;- FreeSound sound structure
;{
;Description can be found at http://www.freesound.org/docs/api/resources.html#sound-resource
Structure FreeSound_Sound
	id.i
	
	urls.s[6]
	
	previews.s[4]
	
	type.s
	
	fileInfo.f[6]
	
	originalFilename.s
	description.s
	
	Array tags.s(0)
	
	license.s
	created.s
	
	stats.i[3]
	avgRating.f
	
	user.FreeSound_User
	
	imgs.s[4]
EndStructure
;}


;- Constants for user structure
;{
Enumeration 0
	#USER_NICK
	#USER_FIRSTNAME
	#USER_LASTNAME
	#USER_ABOUT
	#USER_SIGNATURE
	#USER_JOINED
EndEnumeration

Enumeration 0
	#URL_REF
	#URL_SITE
	#URL_SOUNDS
	#URL_PACKS
	#URL_HOMEPAGE
EndEnumeration
;}

;- Constants for sound structure
;{
Enumeration 0
	#PREVIEW_HQ_MP3
	#PREVIEW_LQ_MP3
	#PREVIEW_HQ_OGG
	#PREVIEW_LQ_OGG
EndEnumeration

Enumeration 0
	#URL_REF
	#URL_SITE
	#URL_SERVE
	#URL_SIMILAR
	#URL_ANALYSIS
	#URL_ANALYSIS_FRAMES
EndEnumeration

Enumeration 0
	#INFO_DURATION
	#INFO_SAMPLERATE
	#INFO_BITDEPTH
	#INFO_FILESIZE
	#INFO_BITRATE
	#INFO_CHANNELS
EndEnumeration

Enumeration 0
	#STATS_COMMENTS
	#STATS_DLS
	#STATS_RATINGS
EndEnumeration

Enumeration 0
	#IMG_SPECTRAL_M
	#IMG_SPECTRAL_L
	#IMG_WAVEFORM_M
	#IMG_WAVEFORM_L
EndEnumeration
;}


;- URI parts for different requests
#BASE_URI = "http://www.freesound.org/api"

#URI_SOUNDS 			= "/sounds/"
#URI_SOUNDS_SEARCH 		= "/sounds/search/"
#URI_SOUND 				= "/sounds/<sound_id>/"
#URI_SOUND_ANALYSIS 	= "/sounds/<sound_id>/analysis/<filter>/"
#URI_SOUND_SIMILAR 		= "/sounds/<sound_id>/similar/"
#URI_USERS 				= "/people/"
#URI_USER 				= "/people/<username>/"
#URI_USER_SOUNDS 		= "/people/<username>/sounds/"
#URI_USER_PACKS 		= "/people/<username>/packs/"
#URI_PACKS 				= "/packs/"
#URI_PACK 				= "/packs/<pack_id>/"
#URI_PACK_SOUNDS 		= "/packs/<pack_id>/sounds/"

;- API key for Cue
#API_KEY = "02173fe5c324492d90ecc948e716f452"




Global NewList gSearchResult.FreeSound_Sound()

Global gResponseFile.s = "response.xml"

Global gResultsFound.i
Global gResultPages.i

Global gCurrentFS.FreeSound_Sound



;define the whitespace as desired
#whitespace$ = " " + Chr($9) + Chr($A) + Chr($B) + Chr($C) + Chr($D) + Chr($1C) + Chr($1D) + Chr($1E) + Chr($1F)
 
Procedure.s myLTrim(source.s)
  Protected i, *ptrChar.Character, length = Len(source)
  *ptrChar = @source
  For i = 1 To length
    If Not FindString(#whitespace$, Chr(*ptrChar\c))
      ProcedureReturn Right(source, length + 1 - i)
    EndIf
    *ptrChar + SizeOf(Character)
  Next
EndProcedure
 
Procedure.s myRTrim(source.s)
  Protected i, *ptrChar.Character, length = Len(source)
  *ptrChar = @source + (length - 1) * SizeOf(Character)
  For i = length To 1 Step - 1
    If Not FindString(#whitespace$, Chr(*ptrChar\c))
      ProcedureReturn Left(source, i)
    EndIf
    *ptrChar - SizeOf(Character)
  Next
EndProcedure
 
Procedure.s myTrim(source.s)
  ProcedureReturn myRTrim(myLTrim(source))
EndProcedure

Procedure.s URI(uri.s,Map *args.s())
	If MapSize(*args()) > 0
		ForEach *args()
			uri = ReplaceString(uri,"<" + MapKey(*args()) + ">",*args())
		Next
	EndIf
	
	uri = #BASE_URI + uri
	uri = SetURLPart(uri,"format","xml")
	uri = SetURLPart(uri,"api_key",#API_KEY)
	
	ProcedureReturn uri
EndProcedure

Procedure FormatResponse()
	If LoadXML(0,gResponseFile)
		FormatXML(0,#PB_XML_WindowsNewline | #PB_XML_ReFormat,4)
		SaveXML(0,gResponseFile)
		FreeXML(0)
	EndIf
EndProcedure

Procedure ParseSoundResponse(*ret.FreeSound_Sound,file.s="",xml=0)
	If file <> ""
		xml = LoadXML(#PB_Any,file)
	Else
		SaveXML(xml,"tmp.xml")
	EndIf
	
	If xml
		;FormatXML(xml,#PB_XML_ReduceSpace)
		
		If XMLStatus(xml) <> #PB_XML_Success
			Message$ = "Error in the XML file:" + Chr(13)
			Message$ + "Message: " + XMLError(xml) + Chr(13)
			Message$ + "Line: " + Str(XMLErrorLine(xml)) + "   Character: " + Str(XMLErrorPosition(0))
			MessageRequester("Error", Message$)
			
			ProcedureReturn #False
		EndIf
		
		If xml = 0
			If GetXMLNodeName(MainXMLNode(xml)) <> "response"
				MessageRequester("Error","No valid response!")
				
				ProcedureReturn #False
			EndIf
		EndIf
		
		currentNode = ChildXMLNode(MainXMLNode(xml))
		While currentNode <> 0
			attr.s = GetXMLNodeName(currentNode)
			value.s = myTrim(GetXMLNodeText(currentNode))
			
			Select attr
				Case "id"
					*ret\id = Val(value)
				Case "ref"
					*ret\urls[#URL_REF] = value
				Case "url"
					*ret\urls[#URL_SITE] = value
				Case "preview-hq-mp3"
					*ret\previews[#PREVIEW_HQ_MP3] = value
				Case "preview-lq-mp3"
					*ret\previews[#PREVIEW_LQ_MP3] = value
				Case "preview-hq-ogg"
					*ret\previews[#PREVIEW_HQ_OGG] = value
				Case "preview-lq-ogg"
					*ret\previews[#PREVIEW_LQ_OGG] = value
				Case "serve"
					*ret\urls[#URL_SERVE] = value
				Case "similarity"
					*ret\urls[#URL_SIMILAR] = value
				Case "type"
					*ret\type = value
				Case "duration"
					*ret\fileInfo[#INFO_DURATION] = ValF(value)
				Case "samplerate"
					*ret\fileInfo[#INFO_SAMPLERATE] = ValF(value)
				Case "bitdepth"
					*ret\fileInfo[#INFO_BITDEPTH] = ValF(value)
				Case "filesize"
					*ret\fileInfo[#INFO_FILESIZE] = ValF(value)
				Case "bitrate"
					*ret\fileInfo[#INFO_BITRATE] = ValF(value)
				Case "channels"
					*ret\fileInfo[#INFO_CHANNELS] = Val(value)
				Case "original_filename"
					*ret\originalFilename = value
				Case "description"
					*ret\description = value
				Case "tags"
					resNode = ChildXMLNode(currentNode)
					
					i = 0
					
					While resNode <> 0
						ReDim *ret\tags(i)
						
						*ret\tags(i) = GetXMLNodeText(resNode)
						
						i + 1
						resNode = NextXMLNode(resNode)
					Wend
				Case "license"
					*ret\license = value
				Case "created"
					*ret\created = value
				Case "num_comments"
					*ret\stats[#STATS_COMMENTS] = Val(value)
				Case "num_downloads"
					*ret\stats[#STATS_DLS] = Val(value)
				Case "num_ratings"
					*ret\stats[#STATS_RATINGS] = Val(value)
				Case "avg_rating"
					*ret\avgRating = ValF(value)
				Case "spectral_m"
					*ret\imgs[#IMG_SPECTRAL_M] = value
				Case "spectral_l"
					*ret\imgs[#IMG_SPECTRAL_L] = value
				Case "waveform_m"
					*ret\imgs[#IMG_WAVEFORM_M] = value
				Case "waveform_l"
					*ret\imgs[#IMG_WAVEFORM_L] = value
			EndSelect
									
			currentNode = NextXMLNode(currentNode)
		Wend
		
		FreeXML(xml)
		
		ProcedureReturn #True
	Else
		ProcedureReturn #False
	EndIf
EndProcedure

Procedure ParseSearchResponse()
	If LoadXML(0,gResponseFile)
		If XMLStatus(0) <> #PB_XML_Success
			Message$ = "Error in the XML file:" + Chr(13)
			Message$ + "Message: " + XMLError(0) + Chr(13)
			Message$ + "Line: " + Str(XMLErrorLine(0)) + "   Character: " + Str(XMLErrorPosition(0))
			MessageRequester("Error", Message$)
		EndIf
		
		If GetXMLNodeName(MainXMLNode(0)) <> "response"
			MessageRequester("Error","No valid response!")
		EndIf
		
		ClearList(gSearchResult())

		currentNode = ChildXMLNode(MainXMLNode(0))
		While currentNode <> 0
			Select GetXMLNodeName(currentNode)
				Case "num_results"
					gResultsFound = Val(GetXMLNodeText(currentNode))
				Case "sounds"
					resNode = ChildXMLNode(currentNode)
					
					While resNode <> 0
						AddElement(gSearchResult())
						
						tmpXml = CreateXML(#PB_Any)
						CopyXMLNode(resNode,RootXMLNode(tmpXml))
						
						ParseSoundResponse(@gSearchResult(),"",tmpXml)
						
						resNode = NextXMLNode(resNode)
					Wend
				Case "num_pages"
					gResultPages = Val(GetXMLNodeText(currentNode))
			EndSelect
			
			
			currentNode = NextXMLNode(currentNode)
		Wend
		
		FreeXML(0)
	EndIf
	
	ProcedureReturn #True
EndProcedure


Procedure FreeSound_Search(*query.s)
	url.s = URLEncoder(#BASE_URI + #URI_SOUNDS_SEARCH + "?q=" + *query + "&id,original_filename&format=xml&api_key=" + #API_KEY)
	
	HTTP_GET(url,gResponseFile)
	
	FormatResponse()
	
	ParseSearchResponse()
EndProcedure

Procedure FreeSound_GetSoundInfo(*dat)
	id = PeekI(*dat)
	
	NewMap args.s()
	
	args("sound_id") = Str(id)
	url.s = URI(#URI_SOUND,@args())
	
	HTTP_GET(url,gResponseFile)
	
	FormatResponse()
	ParseSoundResponse(@gCurrentFS,gResponseFile)
EndProcedure

InitNetwork()



