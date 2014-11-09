Type utilUDT extends object
	As Integer id=0,size=0
	Declare Constructor(id As Integer=0)
	Declare Virtual Destructor
	'override
	Declare virtual Function equals(o As utilUDT Ptr) As Integer
	Declare virtual Function compareTo(o As utilUDT Ptr) As Integer
	Declare virtual Function toString As String
	Declare virtual Function todo As Byte
	
	Declare virtual Function isEmpty As Byte
	
	'final
	Declare Function toBINString As String
	Declare Sub fromBINString(item As String)
End Type

Constructor utilUDT(id As Integer=0)
	this.id=id
End Constructor

Destructor utilUDT
	
End Destructor

Function utilUDT.equals(o As utilUDT Ptr) As Integer
	If o=0 Then Return 0
	If o->id=this.id Then Return 1
	Return 0
End Function

Function utilUDT.compareTo(o As utilUDT Ptr) As Integer
	If equals(o)=1 Then Return 0
	If o=0 Then Return -1
	
	If o->id>this.id Then Return -1
	If o->id<this.id Then Return 1
	
	Return 0
End Function

Function utilUDT.toString As String
	Return "Element: "+str(this.id)+" @"+Str(@This)
End Function

Function utilUDT.todo As Byte
	'do something
	Return 1 'sucess
	Return 0 'failure
End Function


Function utilUDT.isEmpty As Byte
	If id=0 Then Return 1
	Return 0
End Function

Function utilUDT.toBINString As String
	Dim As String tmp
	Dim As Any Ptr item=@this

	If size=0 Then Return ""
	tmp=Space(size)
	For toString_i As Integer = SizeOf(Any Ptr) To size-1
		tmp[toString_i]=Cast(UByte ptr,item)[toString_i]
	Next
	Return tmp
End Function

Sub utilUDT.fromBINString( item As String )
	Dim As Any Ptr destPTR=@This
	If item="" Then Return
	If len(item)<size Then Return
	For toString_i As Integer = SizeOf(Any Ptr) To size-1
		Cast(UByte Ptr,destPTR)[toString_i]=item[toString_i]
	Next
End Sub

Sub utilUDTrepair(BIN_ITEM As Any Ptr,BIN_DEST_ITEM As Any ptr)
	If BIN_ITEM=0 Then return
	Dim As String tmp
	Dim As Any Ptr item=BIN_ITEM
	tmp=Space(SizeOf(Any Ptr))
	For toString_i As Integer = 0 To SizeOf(Any Ptr)-1
		tmp[toString_i]=Cast(UByte ptr,item)[toString_i]
	Next
	

	
	Dim As Any Ptr destPTR=BIN_DEST_ITEM

	For toString_i As Integer = 0 To SizeOf(Any Ptr)-1
		Cast(UByte Ptr,destPTR)[toString_i]=tmp[toString_i]
	Next
End Sub

Function ContainsNumber(text As String) As UByte
	For i As Integer = 0 To Len(text)-1
		If text[i]<48 Or text[i]>57 Then Return 0 
	Next
	Return 1
End Function


Function delWhiteSpace(text As String) As String
	Dim As String outputstring
	For i As Integer = 0 To Len(text)-1
		If text[i] <> 32 And text[i] <> 9 Then
			outputstring += Chr(text[i])
		EndIf
	Next
	Return outputString
End Function

Function file2String(file As String,delWS As UByte=0) As String
	Dim As Integer f = FreeFile
	Dim As String outputstring	
	Dim As String tmp	
	Open file For Input As #f
		Do
			Input #f,tmp
			If delWS Then
				outputstring += delWhiteSpace(tmp)
			Else
				outputstring += tmp
			EndIf
			
		Loop Until Eof(f)
	Close #f
	Return outputstring	
End Function

Function bytetobit(item As UByte,position As UByte)As Ubyte
	If position>7 Then Return 0
	'Return ((2^position) And item)Shr position
	Return (item Shl (7-position))Shr 7
End Function

Function download(url As String,path As String) As UByte
	#IF DEFINED(__FB_LINUX__)
	#elseIF DEFINED(__FB_WIN32__)
		Dim URLDownloadToFile as function (ByVal pCaller As Long,ByVal szURL As zString ptr,ByVal szFileName As zString ptr,ByVal dwReserved As Long,ByVal lpfnCB As Long) As Long
		Dim lR As Long

		Dim library As Any Ptr
		library=dylibload( "urlmon.dll" )
		URLDownloadToFile=dylibsymbol(library, "URLDownloadToFileA" )
		lR = URLDownloadToFile(0, url, path, 0, 0)
		DylibFree library

		If lR = 0 Then
		  Return 1
		Else
		  Return 0
		End If

	#EndIf
	Return 0
End Function

Sub renameFile(file1 As String,file2 As String,path As String="")
	#IF DEFINED(__FB_LINUX__)
		Shell ("mv "+path+file1+" "+path+file2
	#ELSEIF DEFINED(__FB_WIN32__)
		If path<>"" then
			For i As Integer = 0 To Len(path)
				If path[i] = Asc("/") Then
					path[i] = Asc("\")
				EndIf
			Next
		End if
		Shell "rename "+path+file1+" "+file2
		If path<>"" then
			For i As Integer = 0 To Len(path)
				If path[i] = Asc("\") Then
					path[i] = Asc("/")
				EndIf
			Next
		End If
	#endif
End Sub

Sub deleteFile(file As String)
	#If DEFINED(__FB_LINUX__)
		Shell "rm "+file
	#ELSEIF DEFINED(__FB_WIN32__)
		If file<>"" then
			For i As Integer = 0 To Len(file)
				If file[i] = Asc("/") Then
					file[i] = Asc("\")
				EndIf
			Next
		End If
		Shell "del "+file
		If file<>"" then
			For i As Integer = 0 To Len(file)
				If file[i] = Asc("\") Then
					file[i] = Asc("/")
				EndIf
			Next
		End If
	#EndIf
End Sub

Dim shared as String FB_CUSTOMERROR_STRING
FB_CUSTOMERROR_STRING = "ndef"
Function getFBerrorMSG(id As UByte) As String
	Select Case id
		Case 0
			Return "No error"
		Case 1
			Return "Illegal function call"
		Case 2
			Return "File not found signal"
		Case 3
			Return "File I/O error"
		Case 4
			Return "Out of memory"
		Case 5
			Return "Illegal resume"
		Case 6
			Return "Out of bounds array access"
		Case 7
			Return "Null Pointer Access"
		Case 8
			Return "No privileges"
		Case 9
			Return "interrupted signal"
		Case 10
			Return "illegal instruction signal"
		Case 11
			Return "floating point error signal"
		Case 12
			Return "segmentation violation signal"
		Case 13
			Return "Termination request signal"
		Case 14
			Return "abnormal termination signal"
		Case 15
			Return "quit request signal"
		Case 16
			Return "return without gosub"
		Case 17
			Return "end of file"
		case 18
			return FB_CUSTOMERROR_STRING
			
	End Select
End Function

Sub FB_CUSTOMERROR(func as String="",modu as String = "")
	Dim As Integer utilUDT_ERROR_HANDLER_NUMBER
	utilUDT_ERROR_HANDLER_NUMBER = 18
	If utilUDT_ERROR_HANDLER_NUMBER<>0 Then
	cls
	Print "[ERROR] "+ getFBerrorMSG(utilUDT_ERROR_HANDLER_NUMBER)
	if func="" then
		Print "--> Function: "+*Erfn()
	else
		Print "--> Function: "+func'*Erfn()
	end if
	if modu="" then
		Print "--> Module  : "+*Ermn()
	else
		Print "--> Module  : "+modu
	end if
	sleep
	end
EndIf
end sub

On Error GoTo utilUDT_ERROR_HANDLER

utilUDT_ERROR_HANDLER:
Dim As Integer utilUDT_ERROR_HANDLER_NUMBER
	utilUDT_ERROR_HANDLER_NUMBER = err
	If utilUDT_ERROR_HANDLER_NUMBER<>0 Then
		cls
		Print "[ERROR] "+ getFBerrorMSG(utilUDT_ERROR_HANDLER_NUMBER)
		Print "--> Function: "+*Erfn()
		Print "--> Module  : "+*Ermn()
		sleep
		end
	EndIf


