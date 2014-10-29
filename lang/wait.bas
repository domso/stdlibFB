#Include Once "../util/util.bas"
#Include Once "../gui/gui.bas"
#Include Once "graphics.bas"



Type GLOBAL_wait_load_UDT extends commandUDT
	Declare Constructor
	Declare virtual Function action(list As list_type Ptr,parent As Any Ptr=0) As UByte
End Type

Constructor GLOBAL_wait_load_UDT
	base("wait")
End Constructor

Function GLOBAL_wait_load_UDT.action(list As list_type Ptr,parent As Any Ptr=0) As UByte
	If list=0 Then Return 0
	
	list->Reset
	
	Dim As waitUDT Ptr tmp 
	
	Dim As SubString Ptr tmp2
	Dim As SubString Ptr tmp3
	
	Dim As Integer tmp_obj_pos_x = -1 
	Dim As Integer tmp_obj_pos_y = -1
	Dim As Integer tmp_obj_height
	
	
	Do
		tmp2 = Cast(SubString Ptr,list->getItem)
		If tmp2<>0 Then
			If tmp2->isCommand And tmp2->ListInUse Then
				tmp2->list->reset
				tmp3 = Cast(SubString Ptr,tmp2->list->getItem) 
				
						
				If LCase(tmp3->text) = "position" Then
					tmp3 = Cast(SubString Ptr,tmp2->list->getItem)
					If tmp3=0 Then
						logInterpret("no attribute for 'position-x'",1)
						Return 0
					EndIf
					If tmp3->isnumber=0 Then Return 0
					tmp_obj_pos_x = Val(tmp3->text)
					tmp3 = Cast(SubString Ptr,tmp2->list->getItem)
					If tmp3=0 Then
						logInterpret("no attribute for 'position-y'",1)
						Return 0
					EndIf
					If tmp3->isnumber=0 Then Return 0
					tmp_obj_pos_y = Val(tmp3->text)
				EndIf
				
				If LCase(tmp3->text) = "height" Then
					tmp3 = Cast(SubString Ptr,tmp2->list->getItem)
					If tmp3=0 Then
						logInterpret("no attribute for 'height'",1)
						Return 0
					EndIf
					If tmp3->isnumber=0 Then Return 0
					tmp_obj_height = Val(tmp3->text)
					
				EndIf
			End if
			
			
		EndIf
	Loop Until tmp2=0
	
	If tmp_obj_height = 0 Then
		logInterpret("missing attribute 'height' for graphic",1)
		Return 0
	EndIf
	
	
	
	If tmp_obj_pos_x = -1 Or tmp_obj_pos_y = -1 Then ' x,y not set!
		GLOBAL_CURSOR.setModul(tmp_obj_height,tmp_obj_height)
		tmp_obj_pos_x = GLOBAL_CURSOR.x
		tmp_obj_pos_y = GLOBAL_CURSOR.y
	EndIf
	
	If parent<>0 then
		tmp = New waitUDT(New pointUDT(tmp_obj_pos_x,tmp_obj_pos_y),tmp_obj_height)
		If tmp = 0 Then Return 0
		Cast(panelUDT Ptr,parent)->AddGraphic(tmp)
		logInterpret("load waitSymbol on ("+Str(tmp->position.x)+","+Str(tmp->position.y)+") ("+Str(tmp->width_)+"x"+Str(tmp->height)+")",0)
		Return 1
	Else
		logInterpret("no parent object for waitSymbol",1)
		Return 0
	End If
	

End Function

Dim As GLOBAL_wait_load_UDT Ptr GLOBAL_wait_load = New GLOBAL_wait_load_UDT