#Include Once "../util/util.bas"
#Include Once "../gui/gui.bas"
#Include Once "cursor.bas"

'####functions
Dim Shared As Any Ptr GLOBAL_GRAPHIC_OUTPUT_BUFFER(1 To 2)
Function setBasicGraphicStats(obj As graphicUDT Ptr,list As list_type ptr) as graphicUDT Ptr
	Dim As SubString Ptr tmp
	Dim As SubString Ptr tmp2
	
	Dim As Integer tmp_obj_pos_x = -1
	Dim As Integer tmp_obj_pos_y = -1
	Dim As Integer tmp_obj_width
	Dim As Integer tmp_obj_height
	Dim As Integer tmp_obj_polling
	Dim As String tmp_obj_background
	
	If obj=0 Then Return 0
	If list = 0 Then Return 0
	list->Reset
	tmp = Cast(SubString ptr,list->getItem)

	Do
		tmp = Cast(SubString ptr,list->getItem)	
		If tmp<>0 Then	
			If tmp->isCommand And tmp->ListInUse Then
				tmp->list->reset
				tmp2 = Cast(SubString Ptr,tmp->list->getItem) 

				If LCase(tmp2->text) = "position" Then
					tmp2 = Cast(SubString Ptr,tmp->list->getItem)
					If tmp2=0 Then
						logInterpret("no attribute for 'position-x'",1)
						Return 0
					EndIf
					If tmp2->isnumber=0 Then Return 0
					tmp_obj_pos_x = Val(tmp2->text)
					tmp2 = Cast(SubString Ptr,tmp->list->getItem)
					If tmp2=0 Then
						logInterpret("no attribute for 'position-y'",1)
						Return 0
					EndIf
					If tmp2->isnumber=0 Then Return 0
					tmp_obj_pos_y = Val(tmp2->text)
				EndIf
				If LCase(tmp2->text) = "width" Then
					tmp2 = Cast(SubString Ptr,tmp->list->getItem)
					If tmp2=0 Then
						logInterpret("no attribute for 'width'",1)
						Return 0
					EndIf
					If tmp2->IsNumber=0 Then Return 0
					tmp_obj_width = Val(tmp2->text)
				EndIf
				If LCase(tmp2->text) = "height" Then
					tmp2 = Cast(SubString Ptr,tmp->list->getItem)
					If tmp2=0 Then
						logInterpret("no attribute for 'height'",1)
						Return 0
					EndIf
					If tmp2->IsNumber=0 Then Return 0
					tmp_obj_height = Val(tmp2->text)
				EndIf
				If LCase(tmp2->text) = "background" Then
					tmp2 = Cast(SubString Ptr,tmp->list->getItem)
					If tmp2=0 Then
						logInterpret("no attribute for 'background'",1)
						Return 0
					EndIf
					tmp_obj_background = tmp2->text
				EndIf
				If LCase(tmp2->text) = "polling" Then
					tmp2 = Cast(SubString Ptr,tmp->list->getItem)
					If tmp2=0 Then
						logInterpret("no attribute for 'polling'",1)
						Return 0
					EndIf
					If tmp2->IsNumber=0 Then Return 0
					tmp_obj_polling = Val(tmp2->text)
				EndIf
			EndIf
		End if
	Loop Until tmp = 0


	If tmp_obj_width = 0 Then
		logInterpret("missing attribute 'width' for graphic",1)
		Return 0	
	EndIf
	If tmp_obj_height = 0 Then
		logInterpret("missing attribute 'height' for graphic",1)
		Return 0	
	EndIf
	'obj->position = New PointUDT(tmp_obj_pos_x,tmp_obj_pos_y)
	obj->position.x = tmp_obj_pos_x
	obj->position.y = tmp_obj_pos_y
	'obj->Width_ = tmp_obj_width
	'obj->height = tmp_obj_height
	obj->resize(tmp_obj_width,tmp_obj_height)
	if tmp_obj_polling <> 0 then
		obj->enablePolling = 1
		obj->polling = tmp_obj_polling / 1000 
	end if
	
	If tmp_obj_background<>"" Then

		obj->background = getIMG(tmp_obj_background)
	
	End if

	Return obj'New graphicUDT(New pointUDT(tmp_obj_pos_x,tmp_obj_pos_y),tmp_obj_width,tmp_obj_height,tmp_obj_background)
	
End Function



'####
Type GLOBAL_graphic_load_UDT extends commandUDT
	Declare Constructor
	Declare virtual Function action(list As list_type Ptr,parent As Any Ptr=0) As UByte
End Type

Constructor GLOBAL_graphic_load_UDT
	base("graphic")
End Constructor

Function GLOBAL_graphic_load_UDT.action(list As list_type Ptr,parent As Any Ptr=0) As UByte
	Dim As graphicUDT Ptr tmp = New graphicUDT(New pointUDT(0,0),1,1)

		'Var test3= New graphicUDT(New PointUDT(0,0),50,50)
'(text As String,position As pointUDT Ptr=0,Width_ As Integer=0,height As Integer=0,sb As Any Ptr=0)
			
	If setBasicGraphicStats(tmp,list)=0 Then Return 0
	
	
	If tmp->position.x = -1 Or tmp->position.y = -1 Then ' x,y not set!
		GLOBAL_CURSOR.setModul(tmp->Width_,tmp->height)
		tmp->position.x = GLOBAL_CURSOR.x
		tmp->position.y = GLOBAL_CURSOR.y
	EndIf
	
	If parent<>0 Then
	
		'Cast(windowUDT Ptr,parent)->AddGraphic(tmp)
		Cast(panelUDT Ptr,parent)->AddGraphic(tmp)

		'logInterpret("load graphic on "+Cast(windowUDT Ptr,parent)->id_name+"("+Str(tmp->position.x)+","+Str(tmp->position.y)+") ("+Str(tmp->width_)+"x"+Str(tmp->height)+")",0)
		
		Return 1
	Else
			
		
		logInterpret("no parent object for graphic",1)
		Return 1
	End if
	'GLOBAL_CURSOR_UDT
	
	
End Function

Dim As GLOBAL_graphic_load_UDT Ptr GLOBAL_graphic_load = New GLOBAL_graphic_load_UDT
