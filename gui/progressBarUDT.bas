#Include Once "../util/util.bas"
#Include Once "graphicUDT.bas"
#Include Once "buttonUDT.bas"
Type progressBarUDT extends graphicUDT
	as double old_value=0
	as double process=0
	as double ptr updater
	as buttonUDT ptr bar
	Declare Constructor(position As pointUDT Ptr=0,Width_ As Integer=0,height As Integer=0,updater as double ptr=0)
	Declare virtual Function todo As Byte
	Declare virtual Sub Paint
End Type

Constructor progressBarUDT(position As pointUDT Ptr=0,Width_ As Integer=0,height As Integer=0,updater as double ptr=0)
	base(position,width_,height)
	noTextParse = 1
	this.updater = updater
	Paint
End Constructor


Sub progressBarUDT.paint
	Line buffer(1),(0,0)-(Width_-1,height-1),RGBa(red,green,blue,255),bf
	Line buffer(1),(1,1)-(Width_-1,height-1),RGB(143,76,25),b
	Line buffer(1),(3,3)-(Width_-1-2,height-1-2),RGB(0,0,0),b
	Line buffer(1),(2,2)-(Width_-1-1,height-1-1),RGB(0,0,0),b
	
	Line buffer(2),(0,0)-(Width_-1,height-1),RGBa(200,green,blue,200),bf
	Line buffer(2),(1,1)-(Width_-1,height-1),RGB(143,76,25),b
	Line buffer(2),(3,3)-(Width_-1-2,height-1-2),RGB(0,0,0),b
	Line buffer(2),(2,2)-(Width_-1-1,height-1-1),RGB(0,0,0),b
	
	
	'line buffer(1),(width_-4,4)-(width_-4-(width_-8)*(1-process)-1,height-4),rgba(red/3,green/3,blue/3,100),bf
	'line buffer(2),(width_-4,4)-(width_-4-(width_-8)*(1-process)-1,height-4),rgba(red/3,green/3,blue/3,100),bf
	line buffer(1),(Width_*process-1,4)-(width_-4,height-4),rgba(red/3,green/3,blue/3,100),bf
	line buffer(2),(Width_*process-1,4)-(width_-4,height-4),rgba(red/3,green/3,blue/3,100),bf
	
	Line buffer(1),(1,1)-(Width_*process-1,height-1),RGB(143,76,25),b
	Line buffer(1),(3,3)-(Width_*process-1-2,height-1-2),RGB(0,0,0),b
	Line buffer(1),(2,2)-(Width_*process-1-1,height-1-1),RGB(0,0,0),b

	Line buffer(2),(1,1)-(Width_*process-1,height-1),RGB(143,76,25),b
	Line buffer(2),(3,3)-(Width_*process-1-2,height-1-2),RGB(0,0,0),b
	Line buffer(2),(2,2)-(Width_*process-1-1,height-1-1),RGB(0,0,0),b	
	

	
	If background<>0 Then Put buffer(1),(0,0),background->buffer,alpha
	If background<>0 Then Put buffer(2),(0,0),background->buffer,Alpha
	

	'If useBackGround=0 Then
	'	Put buffer(1),(0,0),crack,alpha
	'	Put buffer(2),(0,0),crack,Alpha
	'End If
	'
End Sub

Function progressBarUDT.todo As Byte
	If enable=0 Then Return 0
	if updater <> 0 then
		process = *updater
	end if
	if old_value <> process then
		old_value = process
		text = str(int(100*process))+"%"
		wasChanged=1
	end if
	repaint
	
	
	Return 1
End Function
