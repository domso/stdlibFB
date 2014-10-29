#Include Once "../util/util.bas"
#Include Once "graphicUDT.bas"
#Include Once "panelUDT.bas"
#Include Once "buttonUDT.bas"

Type groupUDT extends graphicUDT
	As Integer distance
	As Byte isHorizontal
	As panelUDT panel
	Declare Constructor(position As pointUDT Ptr=0,isHorizontal As byte=0,distance As Integer=0)
	Declare virtual Function todo As Byte
	Declare virtual Sub Paint
	Declare virtual Sub Add(item As graphicUDT ptr,sb As Any Ptr=0)
End Type

Constructor groupUDT(position As pointUDT Ptr=0,isHorizontal As byte=0,distance As Integer = 0)
	base(position,10,10)
	panel.enable=1
	this.isHorizontal = isHorizontal
	this.distance = distance
	Paint
End Constructor

Sub groupUDT.add(item As graphicUDT ptr,sb As Any Ptr=0)
	panel.AddGraphic(item)
End Sub

Sub groupUDT.paint
	'Line buffer(1),(0,0)-(Width_-1,height-1),RGB(125,0,0),bf
	'Line buffer(2),(0,0)-(Width_-1,height-1),RGB(125,125,0),bf
	'
	'Draw String  buffer(1),(0,0),text,RGB(255,255,255)
	'Draw String  buffer(2),(0,0),text,RGB(255,255,255)
	
	
End Sub

Function groupUDT.todo As Byte
	panel.enable=enable
	If enable=0 Then	Return 0
	repaint

			Dim As Any Ptr tmp
			Dim As Integer i=0
			panel.graphicList.reset
			Do
				tmp=panel.graphicList.getItem
					If tmp<>0 Then
						Var tmpB=cast(graphicUDT Ptr,tmp)
						If isHorizontal=1 then
							tmpB->position.x=this.position.x+i+distance
							tmpB->position.y=this.position.y
							i+=tmpB->width_+distance
							this.width_=i
						Else
							tmpB->position.x=this.position.x
							tmpB->position.y=this.position.y+i+distance
							i+=tmpB->height+distance
							this.height=i		
						End if
						
					EndIf
			Loop Until tmp=0
	panel.update
	
	Return 1
End Function

