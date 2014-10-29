#Include Once "../util/util.bas"
#Include Once "graphicUDT.bas"
Type waitUDT extends graphicUDT
	As Double speed=360 'winkel/sec
	As Double lastTime
	As double rotation
	As Double pi=(ACos(0)*2)
	As Integer lineLen
	As Integer useHeight
	Declare Constructor(position As pointUDT Ptr=0,height As Integer=0)
	Declare virtual Function todo As Byte
	Declare virtual Sub Paint
	Declare virtual Sub resize(set_x As double=0,set_y As Double = 0)
End Type

Constructor waitUDT(position As pointUDT Ptr=0,height As Integer=0)
	base(position,height,height)
	base.useAlpha=1
	useHeight=height-1
	lineLen=(((useHeight/2)^2)+((useHeight/2)^2))^0.5
	Paint
End Constructor

Sub waitUDT.resize(set_x As double=0,set_y As Double = 0)
	
End Sub
	
Sub waitUDT.paint
	Line buffer(1),(0,0)-(height,height),RGBa(0,0,0,0),bf
	Line buffer(2),(0,0)-(height,height),RGBa(0,0,0,0),bf
	For x As Integer = -(height/2) To (height/2)
		For y As Integer = -(height/2) To (height/2)
			
			If ((x^2)+(y^2))^0.5>=(useHeight/2)-2 And ((x^2)+(y^2))^0.5<(useHeight/2)  Then
				Dim As double dif = ((Abs((400+x)-(400-(Cos(rotation/(180/pi))*lineLen)))^2+abs((400+y)-(400-(sin(rotation/(180/pi))*lineLen)))^2)^0.5)
				dif/=3
				If dif<1 Then dif=1
				Line buffer(1),((height/2)+x,(height/2)+y)-((height/2)+x,(height/2)+y),RGB(255/dif,0,0)
				Line buffer(2),((height/2)+x,(height/2)+y)-((height/2)+x,(height/2)+y),RGB(255/dif,0,0)
			End If	
			
		Next	
	Next

End Sub

Function waitUDT.todo As Byte
	If enable=0 Then Return 0
	repaint
	Dim As Double difTimer=Timer-lastTime
		wasChanged=1
		rotation+=speed*difTimer
		lastTime=Timer	

	
	
	Return 1
End Function