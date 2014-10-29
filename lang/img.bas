
#Include Once "../util/util.bas"
#Include Once "cursor.bas"

Dim Shared As Any Ptr GLOBAL_IMG_OUTPUT_BUFFER(1 To 2)

Type GLOBAL_Interpreter_img_UDT extends commandUDT
	Declare Constructor
	Declare virtual Function action(list As list_type Ptr,parent As Any Ptr=0) As UByte
End Type

Constructor GLOBAL_Interpreter_img_UDT
	base("img")
End Constructor

Function GLOBAL_Interpreter_img_UDT.action(list As list_type Ptr,parent As Any Ptr=0) As UByte


	Dim As SubString Ptr tmp
	Dim As SubString Ptr tmp2


	If list = 0 Then Return 0
	list->Reset
	tmp2 = Cast(SubString ptr,list->getItem)
	If tmp2->text<>this.CommandString Then Return 0
	tmp2 = Cast(SubString ptr,list->getItem)	
	If tmp2=0 Then Return 0
	
	
	Dim As imgUDT Ptr tmpIMG = getIMG(tmp2->text)
	If tmpIMG = 0 Then Return 0
	GLOBAL_CURSOR.setModul(tmpIMG->Width,tmpIMG->height)
	

	If GLOBAL_IMG_OUTPUT_BUFFER(1)<>0 Then
		Put GLOBAL_IMG_OUTPUT_BUFFER(1),(GLOBAL_CURSOR.x,GLOBAL_CURSOR.y),tmpIMG->buffer,Alpha
		
	EndIf
	If GLOBAL_IMG_OUTPUT_BUFFER(2)<>0 Then
		Put GLOBAL_IMG_OUTPUT_BUFFER(2),(GLOBAL_CURSOR.x,GLOBAL_CURSOR.y),tmpIMG->buffer,Alpha
	EndIf
	
	'If parent<>0 then


	'	logInterpret("load button on "+"("+Str(tmp->position.x)+","+Str(tmp->position.y)+") ("+Str(tmp->width_)+"x"+Str(tmp->height)+")",0)
	'	Return 1
	'Else
	'	logInterpret("no parent object for button",1)
	'	Return 1
	'End If
				
End Function
		
		
Dim As GLOBAL_Interpreter_img_UDT Ptr GLOBAL_Interpreter_img = New GLOBAL_Interpreter_img_UDT
		
		
	