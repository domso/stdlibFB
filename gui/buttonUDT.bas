#Include Once "../util/util.bas"
#Include Once "graphicUDT.bas"
Type buttonUDT extends graphicUDT
	Declare Constructor(text As String,position As pointUDT Ptr=0,Width_ As Integer=0,height As Integer=0,sb As Any Ptr=0)
	Declare virtual Function todo As Byte
	Declare virtual Sub Paint
	Declare virtual Function toString As String
End Type

Constructor buttonUDT(text As String,position As pointUDT Ptr=0,Width_ As Integer=0,height As Integer=0,sb As Any Ptr=0)
	base(position,width_,height)
	base.text=text
	If sb<>0 Then action=sb : isActionSet=1
	Paint
End Constructor


Sub buttonUDT.paint
	Line buffer(1),(0,0)-(Width_-1,height-1),RGBa(red,green,blue,255),bf
	If background<>0 Then Put buffer(1),(0,0),background->buffer,alpha
	
		
	Line buffer(1),(0,0)-(Width_-1,height-1),RGB(143,76,25),b
	Line buffer(1),(2,2)-(Width_-1-2,height-1-2),RGB(0,0,0),b
	Line buffer(1),(1,1)-(Width_-1-1,height-1-1),RGB(0,0,0),b
	
	Line buffer(2),(0,0)-(Width_-1,height-1),RGBa(redE,greenE,blueE,200),bf
	If background<>0 Then Put buffer(2),(0,0),background->buffer,Alpha
	
	Line buffer(2),(0,0)-(Width_-1,height-1),RGB(143,76,25),b
	Line buffer(2),(2,2)-(Width_-1-2,height-1-2),RGB(0,0,0),b
	Line buffer(2),(1,1)-(Width_-1-1,height-1-1),RGB(0,0,0),b

	'If useBackGround=0 Then
	'	Put buffer(1),(0,0),crack,alpha
	'	Put buffer(2),(0,0),crack,Alpha
	'End If
	'
End Sub

Function buttonUDT.todo As Byte
	If enable=0 Then Return 0
	repaint
	If isPressed=1 Then
		If isActionSet=1 Then action()
	End if	
	
	
	Return 1
End Function

Function buttonUDT.toString As String
	Return text
End Function
