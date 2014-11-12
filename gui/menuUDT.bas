#Include Once "../util/util.bas"
#Include Once "graphicUDT.bas"
#Include Once "panelUDT.bas"
#Include Once "buttonUDT.bas"
#Include Once "GlobalGUI.bas"

Type menuUDT extends graphicUDT
	As panelUDT panel
	As Byte isClickOnly
	Declare Constructor(text As String,position As pointUDT Ptr=0,Width_ As Integer=0,height As Integer=0,isClickOnly As Byte=0)
	Declare virtual Function todo As Byte
	Declare virtual Sub Paint
	Declare virtual Sub Add(text As String,sb As Any Ptr=0)
	Declare virtual Sub Add(item As graphicUDT ptr,sb As Any Ptr=0)
	Declare virtual Function mouseOver As Byte
	Declare virtual Sub SetEnable(enable As Byte)
	Declare virtual Sub resetChildPosition 
End Type

Constructor menuUDT(text As String,position As pointUDT Ptr=0,Width_ As Integer=0,height As Integer=0,isClickOnly As Byte=0)
	base(position,width_,height)
	base.text=text
	panel.enable=0
	this.isClickOnly = isClickOnly
	base.EnableMouseClick= isClickOnly
	Paint
End Constructor

Sub menuUDT.add(text As String,sb As Any Ptr=0)
	Var tmp = New buttonUDT(text,New pointUDT(0,0),width_,height,sb)
	panel.AddGraphic(tmp)

End Sub

Sub menuUDT.add(item As graphicUDT ptr,sb As Any Ptr=0)
	panel.AddGraphic(item)
End Sub

Sub menuUDT.paint
	

	Line buffer(1),(0,0)-(Width_-1,height-1),RGBa(red,green,blue,255),bf
	Line buffer(1),(0,0)-(Width_-1,height-1),RGB(143,76,25),b
	Line buffer(1),(2,2)-(Width_-1-2,height-1-2),RGB(0,0,0),b
	Line buffer(1),(1,1)-(Width_-1-1,height-1-1),RGB(0,0,0),b
	
	Line buffer(2),(0,0)-(Width_-1,height-1),RGBa(redE,greenE,blueE,200),bf
	Line buffer(2),(0,0)-(Width_-1,height-1),RGB(143,76,25),b
	Line buffer(2),(2,2)-(Width_-1-2,height-1-2),RGB(0,0,0),b
	Line buffer(2),(1,1)-(Width_-1-1,height-1-1),RGB(0,0,0),b

	
	If background<>0 Then Put buffer(1),(0,0),background->buffer,alpha
	If background<>0 Then Put buffer(2),(0,0),background->buffer,Alpha
	


End Sub

Sub menuUDT.resetChildPosition
	Dim As Integer i=0
	Dim As Any Ptr tmp
	Dim As graphicUDT Ptr tmpB
	panel.graphicList.reset
	Do
		tmp=panel.graphicList.getItem
			If tmp<>0 Then
				tmpB=cast(graphicUDT Ptr,tmp)
				tmpB->position.x=this.position.x+width_
				tmpB->position.y=this.position.y+(i)
				i+=tmpB->height
			EndIf
	Loop Until tmp=0
End Sub

Function menuUDT.todo As Byte
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
	Dim As Byte mouseOverStatus=mouseOver
	Dim As graphicUDT Ptr tmpB
	repaint

	panel.graphicList.reset
	Do
		tmp=panel.graphicList.getItem
		If tmp<>0 Then
			tmpB=cast(buttonUDT Ptr,tmp)
			If tmpB->wasClicked=1 Then
				GLOBAL_EVENT_LIST_CLEAR
				panel.enable=0
				tmpB->wasClicked=0
				wasChanged=1
				repaint
				'Return 0
			EndIf
		EndIf
	Loop Until tmp=0

	
	If isPressed=1 Or (isClickOnly=0 And mouseOverStatus=1) Then 
		If panel.enable=0 Or EnableChildObjects=0 Then
			EnableChildObjects = 1
			resetChildPosition
			panel.EnableGraphics(1)
			panel.enable=1
		Else
			If isClickOnly=1 Then
				panel.enable=0
			End If
		End If
	Else
		If isClickOnly=0 And panel.enable=1 then
			panel.EnableGraphics(0) 
			panel.graphicList.reset
			
			Do
				tmp=panel.graphicList.getItem
					If tmp<>0 Then
						tmpB=cast(graphicUDT Ptr,tmp)				
						If tmpB->mouseOver=1 Then
							panel.enable=1'EnableGraphics(1)
						EndIf
					EndIf
			Loop Until tmp=0
			
		End if
	EndIf

	Return 1
End Function

Function menuUDT.mouseOver As Byte
	If enable=0 Then Return 0
	Dim As Integer x,y
	If this.GetMouseState(x,y) = -1 Then Return 0
	If x>=position.x And x<position.x+Width_ And y>=position.y And y<position.y+height Then Return 1
	If panel.mouseOver=1 Then Return 1
	
	Return 0
End Function


Sub menuUDT.SetEnable(enable As Byte)
	base.enable=enable
	If enable=0 Then this.panel.enable=enable
End Sub
