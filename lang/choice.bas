#Include Once "../util/util.bas"
#Include Once "../gui/gui.bas"
#Include Once "graphics.bas"



Type GLOBAL_choice_load_UDT extends commandUDT
	Declare Constructor
	Declare virtual Function action(list As list_type Ptr,parent As Any Ptr=0) As UByte
End Type

Constructor GLOBAL_choice_load_UDT
	base("choice")
End Constructor

 
Function GLOBAL_choice_load_UDT.action(list As list_type Ptr,parent As Any Ptr=0) As UByte
	Dim As graphicUDT Ptr tmp = New choiceUDT(New pointUDT(0,0),1,1)
	If setBasicGraphicStats(tmp,list)=0 Then Return 0
	If list=0 Then Return 0
	
	list->Reset
	Dim As SubString Ptr tmp2
	Dim As SubString Ptr tmp3
	
	Dim As list_type Ptr tmpList
	Do
		tmp2 = Cast(SubString Ptr,list->getItem)
		If tmp2<>0 Then
			If tmp2->isCommand And tmp2->ListInUse Then
				tmp2->list->reset
				tmp3 = Cast(SubString Ptr,tmp2->list->getItem) 
				
				If LCase(tmp3->text) = "list" Then
					tmp3 = Cast(SubString Ptr,tmp2->list->getItem)
					If tmp3=0 Then
						logInterpret("no attribute for 'list'",1)
						Return 0
					EndIf
					logInterpret(tmp3->text,2)
					tmpList = cast(any ptr,Valint(tmp3->text))
				EndIf

			End if
			
			
		EndIf
	Loop Until tmp2=0
	


	
	If tmp->position.x = -1 Or tmp->position.y = -1 Then ' x,y not set!
		GLOBAL_CURSOR.setModul(tmp->Width_,tmp->height)
		tmp->position.x = GLOBAL_CURSOR.x
		tmp->position.y = GLOBAL_CURSOR.y
	EndIf
	
	If tmpList<>0 Then
		
		tmpList->reset
		Dim As utilUDT Ptr tmpItem
		do
			tmpItem = tmpList->getItem
			If tmpItem <> 0 Then
				Cast(choiceUDT Ptr,tmp)->Add("text<"+tmpItem->toString+"/>")
			EndIf
		Loop Until tmpItem = 0
	EndIf
	
	
	If parent<>0 then
		'Cast(windowUDT Ptr,parent)->AddGraphic(tmp)
		Cast(panelUDT Ptr,parent)->AddGraphic(tmp)

		logInterpret("load choice on "+"("+Str(tmp->position.x)+","+Str(tmp->position.y)+") ("+Str(tmp->width_)+"x"+Str(tmp->height)+")",0)
		Return 1
	Else
		logInterpret("no parent object for choice",1)
		Return 1
	End If
End Function

Dim As GLOBAL_choice_load_UDT Ptr GLOBAL_choice_load = New GLOBAL_choice_load_UDT
