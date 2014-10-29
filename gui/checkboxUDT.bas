#Include Once "../util/util.bas"
#Include Once "graphicUDT.bas"

Type checkboxUDT extends graphicUDT
	As Byte status=0
	As Sub activ
	As Sub inactiv
	As Byte EnableStatic=0
	Declare Constructor(position As pointUDT Ptr=0,Width_ As Integer=0,height As Integer=0,sba As Any Ptr=0,sbi As Any Ptr=0)
	Declare virtual Function todo As Byte
	Declare virtual Sub paint
End Type

Constructor checkboxUDT(position As pointUDT Ptr=0,Width_ As Integer=0,height As Integer=0,sba As Any Ptr=0,sbi As Any Ptr=0)
	base(position,width_,height)
	isResizeable = 0
	If sba<>0 And sbi<>0 Then
		this.activ=sba
		this.inactiv=sbi
		isActionSet=1
	End If
	
	Paint
End Constructor


Sub checkboxUDT.paint

	
	Line buffer(1),(0,0)-(Width_-1,height-1),RGB(125,0,0),bf
	Line buffer(1),(0,0)-(Width_-1,height-1),RGB(0,0,0),b
	'Line buffer(1),(2,2)-(Width_-1-2,height-1-2),RGB(0,0,0),b
	
	Line buffer(2),(0,0)-(Width_-1,height-1),RGB(255,0,0),bf
	Line buffer(2),(0,0)-(Width_-1,height-1),RGB(0,0,0),b
	'Line buffer(2),(2,2)-(Width_-1-2,height-1-2),RGB(0,0,0),b
	
	If status=1 Then
		Line buffer(1),(0,0)-(Width_-1,height-1),RGB(0,0,0)
		Line buffer(1),(0,height-1)-(Width_-1,0),RGB(0,0,0)
		Line buffer(2),(0,0)-(Width_-1,height-1),RGB(0,0,0)
		Line buffer(2),(0,height-1)-(Width_-1,0),RGB(0,0,0)
	EndIf
	
	
	
End Sub

Function checkboxUDT.todo As Byte
	If enable=0 Then Return 0
	repaint
	If  EnableStatic=0 Then
		If isPressed=1 Then 
			If status=1 Then
				status=0
				If isActionSet=1 Then inactiv()
			Else
				status=1
				If isActionSet=1 Then activ()
			EndIf
		EndIf
	EndIf
	
	
	Return 1
End Function