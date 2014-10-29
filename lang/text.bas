#Include Once "../util/util.bas"
#Include Once "cursor.bas"

Dim Shared As Any Ptr GLOBAL_STRING_OUTPUT_BUFFER(1 To 2)
Dim Shared As Integer GLOBAL_INTERPRETER_TEXT_WIDTH
Dim Shared As Integer GLOBAL_INTERPRETER_TEXT_HEIGHT
GLOBAL_INTERPRETER_TEXT_WIDTH = 8
GLOBAL_INTERPRETER_TEXT_HEIGHT = 8

Type GLOBAL_Interpreter_text_UDT extends commandUDT
	Declare Constructor
	Declare virtual Function action(list As list_type Ptr,parent As Any Ptr=0) As UByte
End Type

Constructor GLOBAL_Interpreter_text_UDT
	base("text")
End Constructor

Function GLOBAL_Interpreter_text_UDT.action(list As list_type Ptr,parent As Any Ptr=0) As UByte
	
	Dim As SubString Ptr tmp
	Dim As SubString Ptr tmp3

	Dim As Integer tmp_height
	Dim As Integer tmp_width
	
	If list = 0 Then Return 0
	list->Reset
	tmp = Cast(SubString ptr,list->getItem)
	If tmp->text<>this.CommandString Then Return 0
	
	
	
	Do
		tmp = Cast(SubString ptr,list->getItem)	
		If tmp<>0 Then
			
			
			
			If tmp->text="TBD" Then
				
				
			Else
				
				'If Len(tmp->text)*GLOBAL_INTERPRETER_TEXT_WIDTH > GLOBAL_CURSOR.margin_x*2-GLOBAL_CURSOR.Width Then
				'	tmp_width = GLOBAL_CURSOR.margin_x*2-GLOBAL_CURSOR.Width
				'	tmp_height = (Len(tmp->text)*GLOBAL_INTERPRETER_TEXT_WIDTH \ GLOBAL_CURSOR.margin_x*2-GLOBAL_CURSOR.Width + 1) * GLOBAL_INTERPRETER_TEXT_HEIGHT
				'	
				'Else
					
				'EndIf
				If GLOBAL_INTERPRETER_TEXT_WIDTH > (GLOBAL_CURSOR.width - GLOBAL_CURSOR.margin_x) Then
					logInterpret("NO SPACE FOR TEXT!",1)
					Return 0
				EndIf
			
				Do
					tmp_width = Len(tmp->text)*GLOBAL_INTERPRETER_TEXT_WIDTH
					tmp_height = GLOBAL_INTERPRETER_TEXT_HEIGHT
					GLOBAL_CURSOR.setModul(tmp_width,tmp_height)	

					If (Len(tmp->text) * GLOBAL_INTERPRETER_TEXT_WIDTH + GLOBAL_CURSOR.x) > (GLOBAL_CURSOR.width - GLOBAL_CURSOR.margin_x) Then
						Dim As Integer max_char_in_line = ( (Len(tmp->text) * GLOBAL_INTERPRETER_TEXT_WIDTH + GLOBAL_CURSOR.x) - (GLOBAL_CURSOR.width - GLOBAL_CURSOR.margin_x) ) \ GLOBAL_INTERPRETER_TEXT_WIDTH
						If GLOBAL_STRING_OUTPUT_BUFFER(1) = 0 Then
							Draw String(GLOBAL_CURSOR.x,GLOBAL_CURSOR.y),Mid(tmp->text,1,Len(tmp->text)-max_char_in_line)
						Else
							Draw String GLOBAL_STRING_OUTPUT_BUFFER(1),(GLOBAL_CURSOR.x,GLOBAL_CURSOR.y),Mid(tmp->text,1,Len(tmp->text)-max_char_in_line)
						End If
						If GLOBAL_STRING_OUTPUT_BUFFER(2) = 0 Then
							Draw String(GLOBAL_CURSOR.x,GLOBAL_CURSOR.y),Mid(tmp->text,1,Len(tmp->text)-max_char_in_line)
						Else
							Draw String GLOBAL_STRING_OUTPUT_BUFFER(2),(GLOBAL_CURSOR.x,GLOBAL_CURSOR.y),Mid(tmp->text,1,Len(tmp->text)-max_char_in_line)
						End If						
						
						logInterpret("TEXT '"+Mid(tmp->text,1,Len(tmp->text)-max_char_in_line)+"' set on ("+Str(GLOBAL_CURSOR.x)+"x"+Str(GLOBAL_CURSOR.y)+")")
					
						'Print Mid(tmp->text,1,Len(tmp->text)-max_char_in_line)
		
						tmp->text = Mid(tmp->text,Len(tmp->text)-max_char_in_line+1)	
						'Print max_char_in_line									

						'Print   (Len(tmp->text) * GLOBAL_INTERPRETER_TEXT_WIDTH + GLOBAL_CURSOR.x) 
						'print (GLOBAL_CURSOR.width - GLOBAL_CURSOR.margin_x) )
					Else
						'Print tmp->text
						If GLOBAL_STRING_OUTPUT_BUFFER(1) = 0 then
							Draw String(GLOBAL_CURSOR.x,GLOBAL_CURSOR.y),tmp->text
						Else
							Draw String GLOBAL_STRING_OUTPUT_BUFFER(1),(GLOBAL_CURSOR.x,GLOBAL_CURSOR.y),tmp->text
						End If
							If GLOBAL_STRING_OUTPUT_BUFFER(2) = 0 then
							Draw String(GLOBAL_CURSOR.x,GLOBAL_CURSOR.y),tmp->text
						Else
							Draw String GLOBAL_STRING_OUTPUT_BUFFER(2),(GLOBAL_CURSOR.x,GLOBAL_CURSOR.y),tmp->text
						End If
						logInterpret("TEXT '"+tmp->text+"' set on ("+Str(GLOBAL_CURSOR.x)+"x"+Str(GLOBAL_CURSOR.y)+")")
						
					
						
						Exit do
					EndIf
				loop

								
			EndIf
		EndIf
	Loop Until tmp = 0
	Return 1
	
End Function

Dim As GLOBAL_Interpreter_text_UDT Ptr GLOBAL_Interpreter_text = New GLOBAL_Interpreter_text_UDT