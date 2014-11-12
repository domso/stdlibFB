#Include Once "../util/util.bas"
#Include Once "../gui/gui.bas"

Type GLOBAL_Interpreter_color_UDT extends commandUDT
	Declare Constructor
	Declare virtual Function action(list As list_type Ptr,parent As Any Ptr=0) As UByte
End Type

Constructor GLOBAL_Interpreter_color_UDT
	base("color")
End Constructor

Function GLOBAL_Interpreter_color_UDT.action(list As list_type Ptr,parent As Any Ptr=0) As UByte
	Dim As utilUDT Ptr tmp
	Dim As SubString Ptr tmp2
	
	If list = 0 Then Return 0
	list->Reset
	tmp2 = Cast(SubString ptr,list->getItem)
	If tmp2->text<>this.CommandString Then Return 0
	
	tmp2 = Cast(SubString ptr,list->getItem)	
	If tmp2=0 Then Return 0
	If tmp2->IsNumber=0 Then Return 0
	GLOBAL_GRAPHIC_DEFAULT_COLOR_RED = Val(tmp2->text)
	logInterpret "CHANGED GLOBAL_GRAPHIC_DEFAULT_COLOR_RED to:" + Str(GLOBAL_GRAPHIC_DEFAULT_COLOR_RED) 
	
	tmp2 = Cast(SubString ptr,list->getItem)	
	If tmp2=0 Then Return 0
	If tmp2->IsNumber=0 Then Return 0
	GLOBAL_GRAPHIC_DEFAULT_COLOR_GREEN = Val(tmp2->text)
	logInterpret "CHANGED GLOBAL_GRAPHIC_DEFAULT_COLOR_GREEN to:" + Str(GLOBAL_GRAPHIC_DEFAULT_COLOR_GREEN) 
	
	tmp2 = Cast(SubString ptr,list->getItem)	
	If tmp2=0 Then Return 0
	If tmp2->IsNumber=0 Then Return 0
	GLOBAL_GRAPHIC_DEFAULT_COLOR_BLUE = Val(tmp2->text)
	logInterpret "CHANGED GLOBAL_GRAPHIC_DEFAULT_COLOR_BLUE to:" + Str(GLOBAL_GRAPHIC_DEFAULT_COLOR_BLUE) 
	
	tmp2 = Cast(SubString ptr,list->getItem)	
	If tmp2=0 Then Return 0
	If tmp2->IsNumber=0 Then Return 0
	GLOBAL_GRAPHIC_DEFAULT_COLOR_RED_EFFECT = Val(tmp2->text)
	logInterpret "CHANGED GLOBAL_GRAPHIC_DEFAULT_COLOR_RED_EFFECT to:" + Str(GLOBAL_GRAPHIC_DEFAULT_COLOR_RED_EFFECT) 
	
	tmp2 = Cast(SubString ptr,list->getItem)	
	If tmp2=0 Then Return 0
	If tmp2->IsNumber=0 Then Return 0
	GLOBAL_GRAPHIC_DEFAULT_COLOR_GREEN_EFFECT = Val(tmp2->text)
	logInterpret "CHANGED GLOBAL_GRAPHIC_DEFAULT_COLOR_GREEN_EFFECT to:" + Str(GLOBAL_GRAPHIC_DEFAULT_COLOR_GREEN_EFFECT) 
	
	tmp2 = Cast(SubString ptr,list->getItem)	
	If tmp2=0 Then Return 0
	If tmp2->IsNumber=0 Then Return 0
	GLOBAL_GRAPHIC_DEFAULT_COLOR_BLUE_EFFECT = Val(tmp2->text)
	logInterpret "CHANGED GLOBAL_GRAPHIC_DEFAULT_COLOR_BLUE_EFFECT to:" + Str(GLOBAL_GRAPHIC_DEFAULT_COLOR_BLUE_EFFECT) 	
	Return 1
End Function

Dim As GLOBAL_Interpreter_color_UDT Ptr GLOBAL_Interpreter_color = New GLOBAL_Interpreter_color_UDT 
