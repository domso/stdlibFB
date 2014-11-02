#Include Once "linklist.bas"

Dim Shared As list_type GLOBAL_CONFIG_LIST
Type configUDT extends utilUDT
	As String item
	As String value
	Declare Constructor(item As String,value As String,noList As UByte=0)
	Declare Function toString As String	
	Declare virtual Function equals(o As utilUDT Ptr) As Integer
End Type

Constructor configUDT(item As String,value As String,noList As UByte=0)
	this.item = item
	this.value = value
	If noList=0 Then GLOBAL_CONFIG_LIST.add(@This)
End Constructor

Function configUDT.toString As String
	Return item+" = "+value
End Function

Function configUDT.equals(o As utilUDT Ptr) As Integer
	If o = 0 Then Return 0
	If this.item = Cast(configUDT Ptr,o)->item Then Return 1
	Return 0
End Function

Sub configLoad(file As String)
	Dim As Integer f = FreeFile
	Dim As Integer tmpINSTR
	Dim As String tmp	
	Open file For Input As #f
		Do
			Input #f,tmp
			tmp = delWhiteSpace(tmp)
			tmpINSTR = InStr(tmp,"=") 
			If tmpINSTR <> 0 Then
				Var o = New configUDT(Mid(tmp,1,tmpINSTR-1),Mid(tmp,tmpINSTR+1))
			EndIf
		Loop Until Eof(f)
	Close #f
End Sub

Sub configSave(file As String)
	Dim As Integer f = FreeFile
	Dim As configUDT Ptr tmp	
	Open file For output As #f	
		GLOBAL_CONFIG_LIST.reset		
		Do
			tmp = Cast(configUDT Ptr,GLOBAL_CONFIG_LIST.getitem)
			If tmp<>0 Then
				put #f,, tmp->toString
				Put #f,, Chr(13)+Chr(10) 'new line
			EndIf
		Loop Until tmp = 0	
	Close #f
End Sub

Function getConfigValue(item as String) As String
	Dim As configUDT Ptr tmp
	Dim As configUDT Ptr tmp2
	tmp = New configUDT(item,"",1)
	tmp2 = Cast(configUDT Ptr,GLOBAL_CONFIG_LIST.search(tmp))
	Delete tmp
	If tmp2 = 0 Then Return ""
	Return tmp2->value
End Function