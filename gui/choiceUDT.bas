#Include Once "../util/util.bas"
#Include Once "graphicUDT.bas"
#Include Once "panelUDT.bas"
#Include Once "buttonUDT.bas"
#Include Once "GlobalGUI.bas"

Type choiceUDT extends graphicUDT
	As panelUDT panel
	Declare Constructor(position As pointUDT Ptr=0,Width_ As Integer=0,height As Integer=0)
	Declare virtual Function todo As Byte
	Declare virtual Sub Paint
	Declare virtual Sub resetChildPosition
	Declare virtual Sub Add(text As String,sb As Any Ptr=0)

End Type

Constructor choiceUDT(position As pointUDT Ptr=0,Width_ As Integer=0,height As Integer=0)
	base(position,width_,height)
	panel.enable=0
	Paint
End Constructor

Sub choiceUDT.add(text As String,sb As Any Ptr=0)
	Var tmp = New buttonUDT(text,New pointUDT(0,0),width_,height,sb)
	panel.AddGraphic(tmp)
	
End Sub

Sub choiceUDT.paint
	Line buffer(1),(0,0)-(Width_-1,height-1),RGBa(red,green,blue,255),bf
	Line buffer(1),(1,1)-(Width_-1,height-1),RGB(143,76,25),b
	Line buffer(1),(3,3)-(Width_-1-2,height-1-2),RGB(0,0,0),b
	Line buffer(1),(2,2)-(Width_-1-1,height-1-1),RGB(0,0,0),b
	
	Line buffer(2),(0,0)-(Width_-1,height-1),RGBa(200,green,blue,200),bf
	Line buffer(2),(1,1)-(Width_-1,height-1),RGB(143,76,25),b
	Line buffer(2),(3,3)-(Width_-1-2,height-1-2),RGB(0,0,0),b
	Line buffer(2),(2,2)-(Width_-1-1,height-1-1),RGB(0,0,0),b

	If background<>0 Then Put buffer(1),(0,0),background->buffer,alpha
	If background<>0 Then Put buffer(2),(0,0),background->buffer,alpha

End Sub

Sub choiceUDT.resetChildPosition
	Dim As Integer i=1
	Dim As Any Ptr tmp
	Dim As graphicUDT Ptr tmpB
	panel.graphicList.reset
	Do
		tmp=panel.graphicList.getItem
			If tmp<>0 Then
				tmpB=cast(buttonUDT Ptr,tmp)
				tmpB->position.x=this.position.x
				tmpB->position.y=this.position.y+(i*height)
				If tmpB->width_<>width_ Or tmpB->height<>height Then
					tmpB->resize(width_,height)
				EndIf
				i+=1
			EndIf
	Loop Until tmp=0
	

End Sub


Function choiceUDT.todo As Byte
	
	If panel.enable=1 Then
		If panel.loadOnEventList=0 Then
			panel.EnableGraphics(1)
				GLOBAL_GUI_EVENT_LIST.add(@panel,1)
				panel.loadOnEventList=1
		End If
	End If
	
	If enable=0 Then Return 0
	child = @panel.graphicList
	Dim As Any Ptr tmp
	Dim As buttonUDT Ptr tmpB
	repaint
	'panel.update
	If isPressed=1 Then 
		If panel.enable=0 Or EnableChildObjects = 0 Then
			EnableChildObjects = 1
			panel.graphicList.reset
			resetChildPosition
			this.text=""
			panel.enable=1
			panel.EnableGraphics(1)
		Else
			this.text=""
			panel.enable=0
		End if
	EndIf
	If panel.enable=1 then
		panel.graphicList.reset
		Do
			tmp=panel.graphicList.getItem
				If tmp<>0 Then
					tmpB=cast(buttonUDT Ptr,tmp)
					If tmpB->wasClicked=1 Then
						panel.enable=0
						wasChanged=1
						this.text=tmpB->text
						tmpB->wasClicked=0
						GLOBAL_EVENT_LIST_CLEAR
					EndIf
				EndIf
		Loop Until tmp=0
	End if
	Return 1
End Function
