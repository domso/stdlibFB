#Include Once "../util/util.bas"
#Include Once "../store/store.bas"



Type accountUDT extends utilUDT
	Private:
		As UByte state '128-root|64-Administrator|32-XXX|16-XXX|8-Moderator|4-Developer|2-registeredUser|1-BannedUser
		
	Public:
	As String* 8 acc_name 
	As integer char(1 To 10) 'ID
	As UByte inUse
	
	Declare Constructor(acc_name As String)
	
	Declare Function equals(o As utilUDT Ptr) As Integer
	
	Declare Function toString As String
	
	Declare Function addNewChar As Byte
	
	Declare Sub setState(stateID As UByte,set As UByte)
	Declare Function getState(stateID As UByte) As UByte
	Declare Function checkPermission(permission As permissionUDT ) As UByte
End Type

Constructor accountUDT(acc_name As String)
	if len(acc_name)=0 then acc_name="noname"
	this.acc_name=acc_name
End Constructor

Function accountUDT.equals(o As utilUDT Ptr) As Integer
	If o=0 Then Return 0
	If this.acc_name=Cast(accountUDT ptr,o)->acc_name Then Return 1
	Return 0
End Function

Function accountUDT.toString As String
	Dim As String tmp
	For j As Integer = 0 To 7
		Dim As Integer i = 7-j
		If this.getstate((2^i))=1 Then
			'tmp+="|"+getAccountStageText(2^i)
		EndIf
	Next
	If tmp<>"" Then tmp+="|"
	
	Return "Account: ID="+Str(id)+" Name='"+acc_name+"' "+tmp
End Function

Function accountUDT.addNewChar As byte
	For i As Integer = 1 To 10
		If char(i)=0 Then
			Return i
		EndIf
	Next
	Return 0
End Function

Sub accountUDT.setState(stateID As UByte,set As UByte)
	If set=0 Then
		this.state = this.state and Not stateID
	Else
		this.state = this.state or stateID		
	EndIf
End Sub

Function accountUDT.getState(stateID As UByte) As UByte
	Return (this.state And stateID) / stateID
End Function

Function accountUDT.checkPermission(permission As permissionUDT) As UByte
	If this.getState(BANNED) Then Return 0
	For j As Integer = 0 To 7
		Dim As Integer i = 7-j
		If this.getstate((2^i))=1 Then
			'If (2^i)>=permission.state Then Return 1
		EndIf
	Next
	Return 0
End Function

'Dim As accountUDT Ptr test
'test = New accountUDT("domso")
'test->setState(root,1)
'test->setState(moderator,1)
'test->setState(BANNED,1)
'
'
'Print test->toString
'
'
'test->setState(BANNED,0)
'
'If test->checkPermission(testPermission) Then
'	Print "SUCCESSFULL!"
'Else
'	Print "ACCESS DENIED!"
'EndIf
'sleep
