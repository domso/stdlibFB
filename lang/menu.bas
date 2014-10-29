#Include Once "../util/util.bas"
#Include Once "cursor.bas"
#Include Once "graphics.bas"
#Include Once "../gui/menuUDT.bas"

Type GLOBAL_Interpreter_menu_UDT extends commandUDT
	Declare Constructor
	Declare virtual Function action(list As list_type Ptr,parent As Any Ptr=0) As UByte
End Type

Constructor GLOBAL_Interpreter_menu_UDT
	base("menu")
End Constructor

Function GLOBAL_Interpreter_menu_UDT.action(list As list_type Ptr,parent As Any Ptr=0) As UByte

	 
		'Dim As graphicUDT Ptr tmp = New graphicUDT(New pointUDT(0,0),1,1)

		'Var test3= New graphicUDT(New PointUDT(0,0),50,50)

			
	
	If list=0 Then Return 0
	list->reset
	Dim As SubString Ptr tmp1
	Dim As SubString Ptr tmp2
	Dim As SubString Ptr tmp3
	Dim As UByte tmpisClickOnly
	Dim As String tmptext
	
	tmp1 = Cast(SubString Ptr,list->getItem)
	
	If tmp1->text<>this.CommandString Then Return 0
	
	tmp1 = Cast(SubString Ptr,list->getItem)
	
	If tmp1->listinuse=0 Or tmp1->list = 0 Then 
		logInterpret(tmp1->text)
		Return 0
	EndIf
	
	tmp1->list->reset
	Do
		tmp2 = Cast(SubString Ptr,tmp1->list->getItem)
		If tmp2<>0 Then
			
			If tmp2->isCommand And tmp2->ListInUse Then
				tmp2->list->reset
				tmp3 = Cast(SubString Ptr,tmp2->list->getItem) 
				
				If LCase(tmp3->text) = "isclickonly" Then
					tmpisClickOnly = 1
					
				EndIf
				If LCase(tmp3->text) = "text" Then
					tmp3 = Cast(SubString Ptr,tmp2->list->getItem)
					If tmp3=0 Then
						logInterpret("no attribute for 'text'",1)
						Return 0
					EndIf
					tmptext = tmp2->text
					
				EndIf
			End if
			
			
		EndIf
	Loop Until tmp2=0

	tmp1->list->Reset
	'tmp2 = Cast(SubString Ptr,list->getItem)
	Dim As graphicUDT Ptr tmp = New menuUDT(tmptext,New pointUDT(0,0),1,1,tmpisClickOnly)	
	'loginterpret(tmp2->text)
	If setBasicGraphicStats(tmp,tmp1->list)=0 Then Return 0

	If tmp->position.x = -1 Or tmp->position.y = -1 Then ' x,y not set!
		GLOBAL_CURSOR.setModul(tmp->Width_,tmp->height)
		tmp->position.x = GLOBAL_CURSOR.x
		tmp->position.y = GLOBAL_CURSOR.y
	EndIf
	
	
	
	If parent = 0 Then
		loginterpret("no parent object for menu",1)
	Else
		Cast(panelUDT Ptr,parent)->AddGraphic(tmp)

		logInterpret("load menu '"+Cast(menuUDT Ptr,tmp)->text+"' ("+Str(tmp->position.x)+","+Str(tmp->position.y)+") ("+Str(tmp->width_)+"x"+Str(tmp->height)+")",0)
		
	EndIf
	
	tmp2 = Cast(SubString Ptr,list->getItem)
	If tmp2 = 0 Then
		logInterpret("no items in menu",2)
		Return 1
	EndIf
	If tmp2->listinuse Then
		interpreter(tmp2->list,@Cast(menuUDT Ptr,tmp)->panel)
	EndIf
	Return 1	
	
End Function

Dim As GLOBAL_Interpreter_menu_UDT Ptr GLOBAL_Interpreter_menu = New GLOBAL_Interpreter_menu_UDT