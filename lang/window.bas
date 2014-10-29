#Include Once "../util/util.bas"
#Include Once "cursor.bas"
#Include Once "../gui/windowUDT.bas"

Dim Shared As Integer GLOBAL_INTERPRETER_window_WIDTH
Dim Shared As Integer GLOBAL_INTERPRETER_window_HEIGHT
GLOBAL_INTERPRETER_window_WIDTH = 8
GLOBAL_INTERPRETER_window_HEIGHT = 8

Type GLOBAL_Interpreter_window_UDT extends commandUDT
	Declare Constructor
	Declare virtual Function action(list As list_type Ptr,parent As Any Ptr=0) As UByte
End Type

Constructor GLOBAL_Interpreter_window_UDT
	base("window")
End Constructor

Function GLOBAL_Interpreter_window_UDT.action(list As list_type Ptr,parent As Any Ptr=0) As UByte
	'interpreter(list)
	Dim As SubString Ptr tmp1
	Dim As SubString Ptr tmp2
	Dim As SubString Ptr tmp3
	
	
	Dim As String tmp_id_name
	Dim As String tmp_text
	Dim As Integer tmp_width
	Dim As Integer tmp_height
	Dim As Integer tmp_isFullScreen
	
	
	If list = 0 Then Return 0
	list->Reset
	tmp1 = Cast(SubString ptr,list->getItem)
	If tmp1->text<>this.CommandString Then Return 0
	
	tmp1 = Cast(SubString ptr,list->getItem)
	If tmp1 = 0 Then Return 0
	If tmp1->listinuse Then
		tmp1->list->Reset
		Do
			tmp2 = Cast(SubString ptr,tmp1->list->getItem)	
			If tmp2<>0 Then		
				If tmp2->isCommand And tmp2->ListInUse Then
					tmp2->list->reset
					tmp3 = Cast(SubString Ptr,tmp2->list->getItem) 
					If LCase(tmp3->text) = "id_name" Then
						tmp3 = Cast(SubString Ptr,tmp2->list->getItem)
						If tmp3=0 Then
							logInterpret("no attribute for 'id_name'",1)
							Return 0
						EndIf
						tmp_id_name = tmp3->text
					EndIf
					If LCase(tmp3->text) = "text" Then
						tmp3 = Cast(SubString Ptr,tmp2->list->getItem)
						If tmp3=0 Then
							logInterpret("no attribute for 'text'",1)
						else
							tmp_text = tmp3->text	
						EndIf
						
					EndIf
					If LCase(tmp3->text) = "width" Then
						tmp3 = Cast(SubString Ptr,tmp2->list->getItem)
						If tmp3=0 Then
							logInterpret("no attribute for 'width'",1)
							Return 0
						EndIf
						If tmp3->IsNumber=0 Then Return 0
						tmp_width = Val(tmp3->text)
					EndIf
					If LCase(tmp3->text) = "height" Then
						tmp3 = Cast(SubString Ptr,tmp2->list->getItem)
						If tmp3=0 Then
							logInterpret("no attribute for 'height'",1)
							Return 0
						EndIf
						If tmp3->IsNumber=0 Then Return 0
						tmp_height = Val(tmp3->text)
					EndIf
					If LCase(tmp3->text) = "isfullscreen" Then
						tmp_isFullScreen = 1
					EndIf
					
					
					 
				EndIf
				
				
				
				
			
			End if
		Loop Until tmp2 = 0
		
		
		
	EndIf
	
	If get_window(tmp_id_name)<>0 Then
		loginterpret("id_name in use",2)
	EndIf

	
	Dim As windowUDT Ptr tmp_window
	If tmp_isFullScreen Then
		
		tmp_window = New windowUDT(tmp_id_name,tmp_text,0,tmp_width,tmp_height,0)
		'tmp_window = New windowUDT("spoidjg","edth",New PointUDT(100,100),400,400)	
	Else
		If tmp_width=0 Then
			logInterpret("missing attribute 'width'",1)
			Return 0
		EndIf
		If tmp_height=0 Then
			logInterpret("missing attribute 'width'",1)
			Return 0
		EndIf
		
		
		tmp_window = New windowUDT(tmp_id_name,tmp_text,New PointUDT(0,0),tmp_width,tmp_height)
		

				
	EndIf

	
	tmp1 = Cast(SubString ptr,list->getItem)
	If tmp1 = 0 Then Return 0
	If tmp1->listinuse Then
		interpreter(tmp1->list,tmp_window)
	EndIf
	Return 1	
	
End Function

Dim As GLOBAL_Interpreter_window_UDT Ptr GLOBAL_Interpreter_window = New GLOBAL_Interpreter_window_UDT