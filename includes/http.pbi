; HTTP_GET.pbi
; by Rasmus Schultz
; Version 1.0c

; Based on a technique by Marius Eckardt (Thalius)

#HTTP_BUFFER_SIZE = 4096  ; receive buffer size
#HTTP_IDLE_DELAY = 20     ; delay during inactivity
#HTTP_LAG_DELAY = 50      ; delay during little activity
#HTTP_TIMEOUT = 20000     ; timeout in milliseconds

#HTTP_OK = 0

#HTTP_ERROR_CONNECT   = -1     ; Unable to connect to the specified server
#HTTP_ERROR_MEMORY    = -2     ; Unable to allocate memory for response buffer
#HTTP_ERROR_TIMEOUT   = -3     ; #HTTP_TIMEOUT exceeded
#HTTP_ERROR_FILE      = -4     ; Local file could not be created
#HTTP_ERROR_PROTOCOL  = -5     ; Unknown HTTP protocol (version 1.0 or 1.1 required)

Enumeration ; Parser states
  #HTTP_STATE_EXPECT_HEADER
  #HTTP_STATE_HEADER
  #HTTP_STATE_DATA
EndEnumeration

Macro HTTP_Debug(Str)
  Debug Str ; comment out this line to disable debugging messages
EndMacro

Procedure HTTP_GET(URL.s, LocalFilename.s)
	
  
  ; function returns 0 on successful download (HTTP status 200)
  ; negative number in case of tehnical errors (see #HTTP_ERROR codes above)
  ; or positive number in case of HTTP status code other than "200"
  
  Protected Host.s      ; Server's hostname
  Protected Path.s      ; Remote path
  Protected Port.l = 80 ; Port number
  
  Protected Pos.l       ; Used for various string operations
  
  Protected Con.l       ; Connection ID
  
  Protected Request.s   ; HTTP request headers
  
  Protected CRLF.s = Chr(13) + Chr(10)
  
  ; Parse URL:
  
  If FindString(URL, "http://", 1) = 1 : URL = Right(URL, Len(URL)-7) : EndIf
  
  Pos = FindString(URL, "/", 1)
  If Pos = 0
    Host = URL
    Path = "/"
  Else
    Host = Left(URL, Pos-1)
    Path = Right(URL, Len(URL)-Pos+1)
  EndIf
  
  Pos = FindString(Host, ":", 1)
  If Pos > 0
    Port = Val(Right(Host, Len(Host)-Pos))
    Host = Left(Host, Pos-1)
  EndIf
  
  HTTP_Debug("Host: " + Chr(34) + Host + Chr(34))
  HTTP_Debug("Path: " + Chr(34) + Path + Chr(34))
  HTTP_Debug("Port: " + Str(Port))

  ; Allocate response buffer:
  
  Protected *Buffer
  *Buffer = AllocateMemory(#HTTP_BUFFER_SIZE)
  If Not *Buffer : ProcedureReturn #HTTP_ERROR_MEMORY : EndIf
  
  ; Open connection:
  
  Con = OpenNetworkConnection(Host, Port)
  If Con = 0 : ProcedureReturn #HTTP_ERROR_CONNECT : EndIf
  
  ; Send HTTP request:
  
  Request = "GET " + Path + " HTTP/1.0" + CRLF
  Request + "Host: " + Host + CRLF
  Request + "Connection: Close" + CRLF + CRLF
  
  SendNetworkString(Con, Request)
  
  ; Create output file:
  
  Protected FileID.l = 0
  
  ; Process response:
  
  Protected Exit.l = #False   ; Exit flag
  
  Protected Bytes.l           ; Number of bytes received
  
  Protected Time.l = ElapsedMilliseconds() ; Time of last data reception
  
  Protected Status.l = #HTTP_OK ; Status flag
  
  Protected State.l = #HTTP_STATE_EXPECT_HEADER
  
  Protected String.s          ; Parser input
  Protected Index.l           ; Parser position
  Protected Char.s            ; Parser char
  
  Protected Header.s          ; Current header
  
  Protected HTTP_Protocol.s   ; HTTP protocol version
  Protected HTTP_Status.l = 0 ; HTTP status code
  
  Protected Redirected.b = #False
  
  Repeat
    
    If NetworkClientEvent(Con) = #PB_NetworkEvent_Data
      
      Repeat
        
        Bytes = ReceiveNetworkData(Con, *Buffer, #HTTP_BUFFER_SIZE)
        
        If Bytes = 0
          
          Exit = #True
          
        Else
          
          If Bytes < #HTTP_BUFFER_SIZE : Delay(#HTTP_LAG_DELAY) : EndIf
          
          HTTP_Debug("Received: " + Str(Bytes) + " bytes")
          
          If State = #HTTP_STATE_DATA
            
            WriteData(FileID, *Buffer, Bytes)
            
          Else
            
            String = PeekS(*Buffer, Bytes, #PB_Ascii)
            Index = 0
            
            Repeat
              
              Index + 1
              Char = Mid(String, Index, 1)
              
              Select State
                
                Case #HTTP_STATE_EXPECT_HEADER
                  If Char = Chr(10)
                    State = #HTTP_STATE_DATA
                    HTTP_Debug("Creating file: " + LocalFilename)
                    FileID = CreateFile(#PB_Any, LocalFilename)
                    If FileID = 0
                      Exit = #True
                      Status = #HTTP_ERROR_FILE
                    ElseIf Index < Bytes
                      WriteData(FileID, *Buffer+Index, Bytes-Index)
                    EndIf
                  ElseIf Char = Chr(13)
                    ; (ignore)
                  Else
                    Header = Char
                    State = #HTTP_STATE_HEADER
                  EndIf
                
                Case #HTTP_STATE_HEADER
                  If Char = Chr(10)
                    If HTTP_Status = 0
                      HTTP_Protocol = StringField(StringField(Header, 1, " "), 2, "/")
                      HTTP_Status = Val(StringField(Header, 2, " "))
                      If ((HTTP_Protocol <> "1.0") And (HTTP_Protocol <> "1.1")) Or (StringField(StringField(Header, 1, " "), 1, "/") <> "HTTP") Or (HTTP_Status = 0)
                        HTTP_Debug("HTTP Protocol error!")
                        Exit = #True
                        Status = #HTTP_ERROR_PROTOCOL
                      EndIf
                      HTTP_Debug("HTTP Protocol " + HTTP_Protocol + ", Status " + Str(HTTP_Status))
                      If (HTTP_Status >= 300) And (HTTP_Status < 400)
                        HTTP_Debug("Redirection...")
                        Redirected = #True
                      ElseIf HTTP_Status <> 200
                        Status = HTTP_Status
                        Exit = #True
                        HTTP_Debug("Status <> 200 - abort!")
                      EndIf
                    ElseIf Left(Header, 10) = "Location: "
                      Status = HTTP_GET(Right(Header, Len(Header)-10), LocalFilename)
                      Exit = #True
                    Else
                      HTTP_Debug(Header)
                    EndIf
                    State = #HTTP_STATE_EXPECT_HEADER
                  ElseIf Char = Chr(13)
                    ; (ignore)
                  Else
                    Header + Char
                  EndIf
                
              EndSelect
              
            Until (State = #HTTP_STATE_DATA) Or (Index = Bytes) Or (Exit = #True)
            
          EndIf
          
          Time = ElapsedMilliseconds()
          
        EndIf
        
      Until Exit = #True
      
    Else
      
      HTTP_Debug("Idle...")
      Delay(#HTTP_IDLE_DELAY)
      
      If ElapsedMilliseconds() - Time > #HTTP_TIMEOUT
        Exit = #True
        Status = #HTTP_ERROR_TIMEOUT
      EndIf
      
    EndIf
    
  Until Exit = #True
  
  ; Close and finish:
  
  CloseNetworkConnection(Con)
  FreeMemory(*Buffer)
  If FileID <> 0 : CloseFile(FileID) : EndIf
  
  ProcedureReturn Status
  
EndProcedure

Procedure HTTP_GET2(*dat)
	
	URL.s = StringField(PeekS(*dat),1,Chr(10))
	LocalFilename.s = StringField(PeekS(*dat),2,Chr(10))
	
  ; function returns 0 on successful download (HTTP status 200)
  ; negative number in case of tehnical errors (see #HTTP_ERROR codes above)
  ; or positive number in case of HTTP status code other than "200"
  
  Protected Host.s      ; Server's hostname
  Protected Path.s      ; Remote path
  Protected Port.l = 80 ; Port number
  
  Protected Pos.l       ; Used for various string operations
  
  Protected Con.l       ; Connection ID
  
  Protected Request.s   ; HTTP request headers
  
  Protected CRLF.s = Chr(13) + Chr(10)
  
  ; Parse URL:
  
  If FindString(URL, "http://", 1) = 1 : URL = Right(URL, Len(URL)-7) : EndIf
  
  Pos = FindString(URL, "/", 1)
  If Pos = 0
    Host = URL
    Path = "/"
  Else
    Host = Left(URL, Pos-1)
    Path = Right(URL, Len(URL)-Pos+1)
  EndIf
  
  Pos = FindString(Host, ":", 1)
  If Pos > 0
    Port = Val(Right(Host, Len(Host)-Pos))
    Host = Left(Host, Pos-1)
  EndIf
  
  HTTP_Debug("Host: " + Chr(34) + Host + Chr(34))
  HTTP_Debug("Path: " + Chr(34) + Path + Chr(34))
  HTTP_Debug("Port: " + Str(Port))

  ; Allocate response buffer:
  
  Protected *Buffer
  *Buffer = AllocateMemory(#HTTP_BUFFER_SIZE)
  If Not *Buffer : ProcedureReturn #HTTP_ERROR_MEMORY : EndIf
  
  ; Open connection:
  
  Con = OpenNetworkConnection(Host, Port)
  If Con = 0 : ProcedureReturn #HTTP_ERROR_CONNECT : EndIf
  
  ; Send HTTP request:
  
  Request = "GET " + Path + " HTTP/1.0" + CRLF
  Request + "Host: " + Host + CRLF
  Request + "Connection: Close" + CRLF + CRLF
  
  SendNetworkString(Con, Request)
  
  ; Create output file:
  
  Protected FileID.l = 0
  
  ; Process response:
  
  Protected Exit.l = #False   ; Exit flag
  
  Protected Bytes.l           ; Number of bytes received
  
  Protected Time.l = ElapsedMilliseconds() ; Time of last data reception
  
  Protected Status.l = #HTTP_OK ; Status flag
  
  Protected State.l = #HTTP_STATE_EXPECT_HEADER
  
  Protected String.s          ; Parser input
  Protected Index.l           ; Parser position
  Protected Char.s            ; Parser char
  
  Protected Header.s          ; Current header
  
  Protected HTTP_Protocol.s   ; HTTP protocol version
  Protected HTTP_Status.l = 0 ; HTTP status code
  
  Protected Redirected.b = #False
  
  Repeat
    
    If NetworkClientEvent(Con) = #PB_NetworkEvent_Data
      
      Repeat
        
        Bytes = ReceiveNetworkData(Con, *Buffer, #HTTP_BUFFER_SIZE)
        
        If Bytes = 0
          
          Exit = #True
          
        Else
          
          If Bytes < #HTTP_BUFFER_SIZE : Delay(#HTTP_LAG_DELAY) : EndIf
          
          HTTP_Debug("Received: " + Str(Bytes) + " bytes")
          
          If State = #HTTP_STATE_DATA
            
            WriteData(FileID, *Buffer, Bytes)
            
          Else
            
            String = PeekS(*Buffer, Bytes, #PB_Ascii)
            Index = 0
            
            Repeat
              
              Index + 1
              Char = Mid(String, Index, 1)
              
              Select State
                
                Case #HTTP_STATE_EXPECT_HEADER
                  If Char = Chr(10)
                    State = #HTTP_STATE_DATA
                    HTTP_Debug("Creating file: " + LocalFilename)
                    FileID = CreateFile(#PB_Any, LocalFilename)
                    If FileID = 0
                      Exit = #True
                      Status = #HTTP_ERROR_FILE
                    ElseIf Index < Bytes
                      WriteData(FileID, *Buffer+Index, Bytes-Index)
                    EndIf
                  ElseIf Char = Chr(13)
                    ; (ignore)
                  Else
                    Header = Char
                    State = #HTTP_STATE_HEADER
                  EndIf
                
                Case #HTTP_STATE_HEADER
                  If Char = Chr(10)
                    If HTTP_Status = 0
                      HTTP_Protocol = StringField(StringField(Header, 1, " "), 2, "/")
                      HTTP_Status = Val(StringField(Header, 2, " "))
                      If ((HTTP_Protocol <> "1.0") And (HTTP_Protocol <> "1.1")) Or (StringField(StringField(Header, 1, " "), 1, "/") <> "HTTP") Or (HTTP_Status = 0)
                        HTTP_Debug("HTTP Protocol error!")
                        Exit = #True
                        Status = #HTTP_ERROR_PROTOCOL
                      EndIf
                      HTTP_Debug("HTTP Protocol " + HTTP_Protocol + ", Status " + Str(HTTP_Status))
                      If (HTTP_Status >= 300) And (HTTP_Status < 400)
                        HTTP_Debug("Redirection...")
                        Redirected = #True
                      ElseIf HTTP_Status <> 200
                        Status = HTTP_Status
                        Exit = #True
                        HTTP_Debug("Status <> 200 - abort!")
                      EndIf
                    ElseIf Left(Header, 10) = "Location: "
                      Status = HTTP_GET(Right(Header, Len(Header)-10), LocalFilename)
                      Exit = #True
                    Else
                      HTTP_Debug(Header)
                    EndIf
                    State = #HTTP_STATE_EXPECT_HEADER
                  ElseIf Char = Chr(13)
                    ; (ignore)
                  Else
                    Header + Char
                  EndIf
                
              EndSelect
              
            Until (State = #HTTP_STATE_DATA) Or (Index = Bytes) Or (Exit = #True)
            
          EndIf
          
          Time = ElapsedMilliseconds()
          
        EndIf
        
      Until Exit = #True
      
    Else
      
      HTTP_Debug("Idle...")
      Delay(#HTTP_IDLE_DELAY)
      
      If ElapsedMilliseconds() - Time > #HTTP_TIMEOUT
        Exit = #True
        Status = #HTTP_ERROR_TIMEOUT
      EndIf
      
    EndIf
    
  Until Exit = #True
  
  ; Close and finish:
  
  CloseNetworkConnection(Con)
  FreeMemory(*Buffer)
  If FileID <> 0 : CloseFile(FileID) : EndIf
  
  ProcedureReturn Status
  
EndProcedure
