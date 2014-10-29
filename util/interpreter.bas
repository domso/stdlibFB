#Include Once "linklist.bas"
#Include Once "parser.bas"
#Include Once "commandUDT.bas"
#Include Once "variableUDT.bas"


Declare Function interpreterStatement(list As list_type Ptr,parent As Any Ptr=0) As UByte
Declare Function InterpreterCommand(CommandString As String,list As list_type Ptr,parent As Any Ptr=0) As UByte

'########################################################
Dim Shared As list_type GLOBAL_INTERPRET_LOG
Type GLOBAL_INTERPRET_LOG_UDT extends utilUDT
	As String text
	As UByte isError,isWarning
	Declare Constructor(text As String,status As UByte=0)
	Declare Function toString As String
End Type

Constructor GLOBAL_INTERPRET_LOG_UDT(text As String,status As UByte=0)
	this.text=text
	If status=1 Then isError=1
	If status=2 Then isWarning=1
	GLOBAL_INTERPRET_LOG.add(@This,1)
End Constructor
Function GLOBAL_INTERPRET_LOG_UDT.toString As String
	If isError Then Return "[ERROR] "+text
	If isWarning Then Return "[WARNING] "+text
	Return text
End Function

Sub logInterpret(text As String,status As UByte=0)
	Var x = New GLOBAL_INTERPRET_LOG_UDT(text,status)
End Sub
'########################################################
Type GLOBAL_Interpreter_variable_UDT extends commandUDT
	Declare Constructor
	Declare virtual Function action(list As list_type Ptr,parent As Any Ptr=0) As UByte
End Type

Constructor GLOBAL_Interpreter_variable_UDT
	base("var")
End Constructor

Function GLOBAL_Interpreter_variable_UDT.action(list As list_type Ptr,parent As Any Ptr=0) As UByte
	Dim As SubString Ptr tmp
	Dim As variableUDT Ptr tmpVar
	Dim As variableUDT Ptr tmpVar2

	If list = 0 Then Return 0

	list->Reset
	tmp = Cast(SubString ptr,list->getItem)
	If tmp->text<>this.CommandString Then Return 0
	
	tmp = Cast(SubString ptr,list->getItem)
	If tmp = 0 Then Return 0
	tmpVar = New variableUDT(tmp->text,1)
	tmpVar2 = Cast(variableUDT Ptr,GLOBAL_VARIABLE_LIST.search(tmpVar))
	Delete tmpVar
	If tmpVar2 = 0 Then 
		logInterpret("Variable '"+tmp->text+"' not found!",1)
		Return 0
	EndIf
	

	If parent<>0 then

		Cast(Substring Ptr,parent)->text = tmpVar2->toValString
		Cast(Substring Ptr,parent)->IsNumber = ContainsNumber(Cast(Substring Ptr,parent)->text)
		Cast(Substring Ptr,parent)->isCommand = 0
	End if

	logInterpret("VARIABLE "+ tmpvar2->toString)
	Return 1
	
End Function

Dim Shared As GLOBAL_Interpreter_variable_UDT Ptr GLOBAL_Interpreter_variable
GLOBAL_Interpreter_variable = New GLOBAL_Interpreter_variable_UDT 

Sub interpreterVariable(list As list_type ptr)
	If list=0 Then Return 
	list->reset
	Dim As utilUDT Ptr tmp
	Dim As SubString Ptr tmp2
	Dim As SubString Ptr tmp3
	Dim As UByte found
	tmp = list->getItem
	
	If tmp<>0 then
		Do
			tmp2 = Cast(SubString Ptr,tmp)
			If tmp2->list<>0 Then
				tmp2->list->reset
				tmp3 = Cast(Substring Ptr,tmp2->list->getItem)
				If tmp3<>0 Then
					If tmp3->text = GLOBAL_Interpreter_variable->CommandString Then
						found = 1	
						'tmp2->list->Out
						
						GLOBAL_Interpreter_variable->action(tmp2->list,tmp2)
						
					EndIf
				EndIf
			End if

			If found=0 then
				interpreterVariable(tmp2->list)
			End if
			found=0
			'tmp2->text = tmp2->toString
			
			tmp = list->getItem
		Loop Until tmp=0
	End if
	
	
	Return 
	
End Sub



'########################################################

Function interpreter(list As list_type Ptr,parent As Any Ptr=0) As UByte
	interpreterVariable(list)
	If list=0 Then Return 0
	list->Reset	
	Dim As utilUDT Ptr tmp
	Dim As SubString Ptr tmp2
	tmp = list->getItem
	If tmp<>0 then
		Do
			tmp2 = Cast(SubString Ptr,tmp)
				If tmp2->isCommand=0 Then
					'Print tmp2->toString
					'is this a comment? 
				Else
					If parent = 0 Then
						interpreterStatement(tmp2->list)
					Else
						interpreterStatement(tmp2->list,parent)
					End If
				EndIf
			tmp = list->getItem
		Loop Until tmp=0
	End if
	
	
	Return 0	
End Function


Function interpreterStatement(list As list_type Ptr,parent As Any Ptr=0) As UByte
	If list=0 Then Return 0
	
	list->Reset
	Dim As utilUDT Ptr tmp
	Dim As SubString Ptr tmp2
	tmp = list->getItem
	If tmp<>0 Then
		tmp2 = Cast(SubString Ptr,tmp)
		If tmp2->isCommand=0 Then
			InterpreterCommand(tmp2->text,list,parent)
		Else
			Do
				tmp2 = Cast(SubString Ptr,tmp)
					If tmp2->isCommand=0 Then
						Print "??"+tmp2->toString+"??"
					Else
						interpreterStatement(tmp2->list,parent)
					EndIf
				tmp = list->getItem
			Loop Until tmp=0
		End if
	End if
	
	
	Return 0	
End Function


Function InterpreterCommand(CommandString As String,list As list_type Ptr,parent As Any Ptr=0) As UByte
	
	CommandString = LCase(CommandString)
	Dim As commandUDT Ptr tmp = New commandUDT(commandString,1)
	Dim As commandUDT Ptr tmp2
	tmp2 = Cast(commandUDT Ptr,GLOBAL_COMMAND_LIST.search(tmp))
	Delete tmp
	If tmp2<>0 Then
		If tmp2->action(list,parent)=1 Then Return 1
		logInterpret("Error found in: '"+commandString+"'",1)
		Return 0
	EndIf
	logInterpret("Command not found: '"+commandString+"'",1)
	
	Return 0
End Function

'########################################################
