#Include Once "../util/util.bas"
#Include Once "../gui/gui.bas"
#Include Once "graphics.bas"
Type GLOBAL_button_load_UDT extends commandUDT
	Declare Constructor
	Declare virtual Function action(list As list_type Ptr,parent As Any Ptr=0) As UByte
End Type

Constructor GLOBAL_button_load_UDT
	base("button")
End Constructor

Function GLOBAL_button_load_UDT.action(list As list_type Ptr,parent As Any Ptr=0) As UByte
	Dim As graphicUDT Ptr tmp = New buttonUDT("",New pointUDT(0,0),1,1)	
	If setBasicGraphicStats(tmp,list)=0 Then Return 0
	If list=0 Then Return 0
	list->Reset
	
	Dim As SubString Ptr tmp2
	Dim As SubString Ptr tmp3
	Dim As Any Ptr tmpAction
	Dim As String tmptext
	
	Do
	
		tmp2 = Cast(SubString Ptr,list->getItem)
		If tmp2<>0 Then
			If tmp2->isCommand And tmp2->ListInUse Then
				tmp2->list->reset
				tmp3 = Cast(SubString Ptr,tmp2->list->getItem)
				If LCase(tmp3->text) = "action" Then
					tmp3 = Cast(SubString Ptr,tmp2->list->getItem)
					If tmp3=0 Then
						logInterpret("no attribute for 'action'",1)
						Return 0
					EndIf
					tmpAction = cast(any ptr,Valint(tmp3->text))
				EndIf
				If LCase(tmp3->text) = "text" Then
					tmp3 = Cast(SubString Ptr,tmp2->list->getItem)
					If tmp3=0 Then
						logInterpret("no attribute for 'text'",1)
						Return 0
					End If
					tmptext = tmp3->text
				EndIf
			End if
		End If
	Loop Until tmp2=0
	
	tmp->text = tmptext
	tmp->action = tmpAction
	if tmpAction<>0 then
		tmp->isActionSet = 1
	end if
	If tmp->position.x = -1 Or tmp->position.y = -1 Then ' x,y not set!
		GLOBAL_CURSOR.setModul(tmp->Width_,tmp->height)
		tmp->position.x = GLOBAL_CURSOR.x
		tmp->position.y = GLOBAL_CURSOR.y
	EndIf
	
	If parent<>0 then
		'Cast(windowUDT Ptr,parent)->AddGraphic(tmp)
		Cast(panelUDT Ptr,parent)->AddGraphic(tmp)
		logInterpret("load button on "+"("+Str(tmp->position.x)+","+Str(tmp->position.y)+") ("+Str(tmp->width_)+"x"+Str(tmp->height)+")",0)
		Return 1
	Else
		logInterpret("no parent object for button",1)
		Return 1
	End If
End Function
Dim As GLOBAL_button_load_UDT Ptr GLOBAL_button_load = New GLOBAL_button_load_UDT
