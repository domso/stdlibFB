#Include Once "../util/util.bas"

Type GLOBAL_Interpreter_link_UDT extends commandUDT
	Declare Constructor
	Declare virtual Function action(list As list_type Ptr,parent As Any Ptr=0) As UByte
End Type

Constructor GLOBAL_Interpreter_link_UDT
	base("link")
End Constructor

Function GLOBAL_Interpreter_link_UDT.action(list As list_type Ptr,parent As Any Ptr=0) As UByte
	Dim As SubString Ptr tmp
	Dim As variableUDT Ptr tmpVar
	Dim As variableUDT Ptr tmpVar2

	If list = 0 Then Return 0

	list->Reset
	tmp = Cast(SubString ptr,list->getItem)
	If tmp->text<>this.CommandString Then Return 0
	tmp->text = GLOBAL_Interpreter_variable->commandString
	Return 1
	'
	'tmp = Cast(SubString ptr,list->getItem)
	'If tmp = 0 Then Return 0
	'
	'
	'
	'tmpVar = New variableUDT(tmp->text,1)
	'
	'
	'tmpVar2 = Cast(variableUDT Ptr,GLOBAL_VARIABLE_LIST.search(tmpVar))
	'Delete tmpVar
	'If tmpVar2 = 0 Then 
	'	logInterpret("Variable '"+tmp->text+"' not found!",1)
	'	Return 0
	'EndIf
	'

	If parent<>0 then

		Cast(Substring Ptr,parent)->text = "var"'tmpVar2->toValString
		Cast(Substring Ptr,parent)->IsNumber = ContainsNumber(Cast(Substring Ptr,parent)->text)
		Cast(Substring Ptr,parent)->isCommand = 0
	End If

	'logInterpret("VARIABLE "+ tmpvar2->toString)
	'Return 1
	
End Function

Dim As GLOBAL_Interpreter_link_UDT Ptr GLOBAL_Interpreter_link = New GLOBAL_Interpreter_link_UDT 