#Include Once "utilUDT.bas"
#Include Once "linklist.bas"
Dim Shared As list_type GLOBAL_COMMAND_LIST
Type commandUDT extends utilUDT
	As String CommandString
	Declare virtual Function equals(o As utilUDT Ptr) As Integer
	Declare Constructor(CommandString As String="noCommandSet",NO_GLOBAL_COMMAND_LIST As UByte= 0)
	
	Declare virtual Function action(list As list_type Ptr,parent As Any Ptr=0) As UByte
	
End Type
Function commandUDT.equals(o As utilUDT Ptr) As Integer
	If o=0 Then Return 0
	If Cast(commandUDT Ptr,o)->CommandString=this.CommandString Then Return 1
	Return 0
End Function

Constructor commandUDT(CommandString As String="noCommandSet",NO_GLOBAL_COMMAND_LIST As UByte= 0)
	If NO_GLOBAL_COMMAND_LIST=0 Then
		GLOBAL_COMMAND_LIST.add(@This)
	EndIf
	this.CommandString = LCase(CommandString)
	
End Constructor

Function commandUDT.action(list As list_type Ptr,parent As Any Ptr=0) As UByte
	If list = 0 Then Return 0
	list->out
	Return 1
End Function

