#Include Once "../util/util.bas"
#Include Once "graphicUDT.bas"
#Include Once "pointUDT.bas"

Dim Shared As list_type GLOBAL_GUI_PANEL_LIST

Type panelUDT  extends utilUDT
	As Byte enable=1,setDisableMouse=0,EnableEvent=0,isRezing=0,loadOnEventList=0,isFullScreen=0
	As pointUDT position
	
	As Integer Width_,height 
	
	As list_Type graphicList

	 
	As Any Ptr buffer
	Declare Sub AddGraphic(item As graphicUDT ptr)
	Declare Sub RemoveGraphic(item As graphicUDT ptr,NodeleteHead as Ubyte)
	Declare virtual Sub update
	Declare Function mouseOver(UseDimension As Byte=0) As Byte
	Declare Function isPressed(status As Byte=0) As Byte

	Declare Sub EnableMouse(status As Byte)
	Declare Sub EnableGraphics(status As Byte)
	Declare virtual Sub EnableInactiv(status As Byte)
	Declare virtual Function todo As Byte
	Declare Constructor (position As pointUDT Ptr=0,Width_ As Integer=0,height As Integer=0)
	Declare virtual Function equals(o As utilUDT Ptr) As Integer
End Type

Constructor panelUDT(position As pointUDT Ptr=0,Width_ As Integer=0,height As Integer=0)
	GLOBAL_GUI_PANEL_LIST.add(@This,1)
	this.Width_=Width_
	this.height=height
	If position<>0 Then
		this.position.x=position->x		
		this.position.y=position->y		
	EndIf
End Constructor

Function panelUDT.equals(o As utilUDT Ptr) As Integer
	If o=0 Then Return 0
	If Cast(panelUDT Ptr,o)=@This Then Return 1
	Return 0
End Function

Function panelUDT.todo As Byte
	If enable=0 Then Return 0
	this.update
	Return 0
End Function

Sub panelUDT.AddGraphic(item As graphicUDT ptr)
	'item->isResizeable=0
	'item->isMoveAble=0
	graphicList.add(item,1)	
End Sub

Sub panelUDT.RemoveGraphic(item As graphicUDT ptr,NodeleteHead as Ubyte=0)
	graphicList.remove(item,NodeleteHead)	
End Sub

Sub panelUDT.update
	If enable=1 Then
			graphicList.execute
	End if
End Sub

Function panelUDT.mouseOver(UseDimension As Byte=0) As Byte
	If enable=0 Then Return 0
	If isRezing=1 Then Return 1
	If UseDimension =0 then
		Dim As Any Ptr tmp
			graphicList.reset
			Do
				
				tmp=graphicList.getItem()
				
				If tmp<>0 Then
					Var tmpB=cast(graphicUDT Ptr,tmp)
					If tmpB->mouseOver Then Return 1
					If tmpB->isRezing Then Return 1
						
				End If
			Loop Until tmp=0
	Else
		Dim As Integer x,y
		If GetMouse(x,y,0,0)  = -1 Then Return 0
		If x>=position.x And x<position.x+Width_ And y>=position.y And y<position.y+height Then Return 1 
	End If
	
	Return 0
End Function

Function panelUDT.isPressed(status As Byte=0) As Byte
	If enable=0 Then Return 0
	Dim As Any Ptr tmp
	graphicList.reset
	Do
		tmp=graphicList.getItem()
		If tmp<>0 Then
			Var tmpB=cast(graphicUDT Ptr,tmp)
			If tmpB->isPressed(status)=1 Then Return 1
			
		End If
	Loop Until tmp=0

	
	Return 0
End Function

Sub panelUDT.EnableMouse(status As Byte)
	Dim As Any Ptr tmp
		graphicList.reset
		Do
			tmp=graphicList.getItem()
			If tmp<>0 Then
				Var tmpB=cast(graphicUDT Ptr,tmp)
				tmpB->EnableMouse=status
				
			End If
		Loop Until tmp=0
End Sub

Sub panelUDT.EnableGraphics(status As Byte)
	Dim As Any Ptr tmp
		graphicList.reset
		Do
			tmp=graphicList.getItem()
			If tmp<>0 Then
				Var tmpB=cast(graphicUDT Ptr,tmp)
				tmpB->SetEnable(status)
				tmpB->wasChanged=1
			End If
		Loop Until tmp=0
		graphicList.execute
		enable=status
End Sub

Sub panelUDT.EnableInactiv(status As Byte)
	EnableMouse(status)
End Sub

