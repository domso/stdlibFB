#Include Once "../util/util.bas"
#Include Once "graphicUDT.bas"
#Include Once "panelUDT.bas"
#Include Once "buttonUDT.bas"
#Include Once "groupUDT.bas"

Type tableUDT extends graphicUDT
	As Integer maxCountRow
	As Integer maxCountColumn

	As groupUDT Ptr row


	Declare Constructor()
	Declare virtual Function todo As Byte
	Declare virtual Sub Paint
	Declare virtual Sub Add(item As graphicUDT Ptr,column As Integer,row As integer)
End Type

Constructor tableUDT()
	base(0,0,0)
	row =New groupUDT()
	Paint
End Constructor

Sub tableUDT.add(item As graphicUDT Ptr,column As Integer,row As integer)
	'panel.AddGraphic(item)
	this.row->Add(item)
End Sub

Sub tableUDT.paint

End Sub

Function tableUDT.todo As Byte
	If enable=0 Then Return 0
	repaint
	
	row->todo
	

	'		Dim As Any Ptr tmp
	'		Dim As Integer i=0
	'		panel.graphicList.reset
	'		Do
	'			tmp=panel.graphicList.getItem
	'				If tmp<>0 Then
	'					Var tmpB=cast(graphicUDT Ptr,tmp)
	'					If isHorizontal=1 then
	'						tmpB->position.x=this.position.x+i+distance
	'						tmpB->position.y=this.position.y
	'						i+=tmpB->width_+distance
	'					Else
	'						tmpB->position.x=this.position.x
	'						tmpB->position.y=this.position.y+i+distance
	'						i+=tmpB->height+distance		
	'					End if
	'					
	'				EndIf
	'		Loop Until tmp=0
	'panel.update
	
	Return 1
End Function


