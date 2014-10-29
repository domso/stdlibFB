#Include Once "../util/util.bas"
#Include Once "../gui/gui.bas"
#Include Once "graphics.bas"



Type GLOBAL_textfield_load_UDT extends commandUDT
	Declare Constructor
	Declare virtual Function action(list As list_type Ptr,parent As Any Ptr=0) As UByte
End Type

Constructor GLOBAL_textfield_load_UDT
	base("textfield")
End Constructor

Function GLOBAL_textfield_load_UDT.action(list As list_type Ptr,parent As Any Ptr=0) As UByte
	Dim As textfieldUDT Ptr tmp = New textfieldUDT(New pointUDT(0,0),1,1)	
	If setBasicGraphicStats(tmp,list)=0 Then Return 0
	If list=0 Then Return 0
	
	list->Reset
	Dim As SubString Ptr tmp2
	Dim As SubString Ptr tmp3
	
	Dim As Any Ptr tmpString

	Do
		tmp2 = Cast(SubString Ptr,list->getItem)
		If tmp2<>0 Then
			If tmp2->isCommand And tmp2->ListInUse Then
				tmp2->list->reset
				tmp3 = Cast(SubString Ptr,tmp2->list->getItem) 
				
				If LCase(tmp3->text) = "string" Then
					tmp3 = Cast(SubString Ptr,tmp2->list->getItem)
					If tmp3=0 Then
						logInterpret("no attribute for 'string'",1)
						Return 0
					EndIf
					tmpString = Valint(tmp3->text)
				EndIf
			End if
			
			
		EndIf
	Loop Until tmp2=0
	

	tmp->text = tmpString

	
	
	If tmp->position.x = -1 Or tmp->position.y = -1 Then ' x,y not set!
		GLOBAL_CURSOR.setModul(tmp->Width_,tmp->height)
		tmp->position.x = GLOBAL_CURSOR.x
		tmp->position.y = GLOBAL_CURSOR.y
	EndIf
	
	If parent<>0 then
		'Cast(windowUDT Ptr,parent)->AddGraphic(tmp)
		Cast(panelUDT Ptr,parent)->AddGraphic(tmp)

		logInterpret("load textfield on "+"("+Str(tmp->position.x)+","+Str(tmp->position.y)+") ("+Str(tmp->width_)+"x"+Str(tmp->height)+")",0)
		Return 1
	Else
		logInterpret("no parent object for textfield",1)
		Return 1
	End If
	
End Function

	
	Dim As GLOBAL_textfield_load_UDT Ptr GLOBAL_textfield_load = New GLOBAL_textfield_load_UDT
	