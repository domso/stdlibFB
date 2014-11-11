#Include Once "../util/util.bas"
#Include Once "../gui/gui.bas"
#Include Once "graphics.bas"



Type GLOBAL_progressBar_load_UDT extends commandUDT
	Declare Constructor
	Declare virtual Function action(list As list_type Ptr,parent As Any Ptr=0) As UByte
End Type

Constructor GLOBAL_progressBar_load_UDT
	base("progressbar")
End Constructor

Function GLOBAL_progressBar_load_UDT.action(list As list_type Ptr,parent As Any Ptr=0) As UByte
	Dim As progressBarUDT Ptr tmp = New progressBarUDT(New pointUDT(0,0),1,1)	
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
				
				If LCase(tmp3->text) = "process" Then
					tmp3 = Cast(SubString Ptr,tmp2->list->getItem)
					If tmp3=0 Then
						logInterpret("no attribute for 'process'",1)
						Return 0
					EndIf
					tmpString = Valint(tmp3->text)
				EndIf
			End if
			
			
		EndIf
	Loop Until tmp2=0
	

	tmp->updater = tmpString
	'logInterpret("WERT:"+str(*cast(double ptr,tmpString)))
	
	
	If tmp->position.x = -1 Or tmp->position.y = -1 Then ' x,y not set!
		GLOBAL_CURSOR.setModul(tmp->Width_,tmp->height)
		tmp->position.x = GLOBAL_CURSOR.x
		tmp->position.y = GLOBAL_CURSOR.y
	EndIf
	
	If parent<>0 then
		'Cast(windowUDT Ptr,parent)->AddGraphic(tmp)
		Cast(panelUDT Ptr,parent)->AddGraphic(tmp)

		logInterpret("load progressBar on "+"("+Str(tmp->position.x)+","+Str(tmp->position.y)+") ("+Str(tmp->width_)+"x"+Str(tmp->height)+")",0)
		Return 1
	Else
		logInterpret("no parent object for progressBar",1)
		Return 1
	End If
	
End Function

	
	Dim As GLOBAL_progressBar_load_UDT Ptr GLOBAL_progressBar_load = New GLOBAL_progressBar_load_UDT
	
