#Include Once "../util/util.bas"
#Include Once "pointUDT.bas"
#Include Once "../lang/cursor.bas"
#Include Once "../lang/text.bas"
#Include Once "../lang/img.bas"

Var tmpGraphicIMG = New imgUDT("DEFAULT_GRAPHIC_BACKGROUND","gui/test.bmp",800,600)
tmpGraphicIMG = New imgUDT("DEFAULT_WINDOW_BACKGROUND","gui/bild.bmp",900,506)


'crack=ImageCreate(800,800)
'	'BLoad "gui/test.bmp",crack
'	BLoad "test.bmp",crack
'
'Dim Shared As Any Ptr pergament
'pergament=ImageCreate(900,506)
'	'BLoad "gui/bild.bmp",pergament
'	BLoad "bild.bmp",pergament

'Dim Shared As list_Type graphicList


Type graphicUDT extends utilUDT
	As String text,id_name 
	As Any Ptr buffer(1 To 2)
	
	As imgUDT Ptr background
	'As UByte disableBackground
	
	As UByte red=125,green=0,blue=0
	As Sub action
	As Byte wasChanged=1,useAlpha=0
	As Double polling_last
	As Double polling=0.5
	As Byte wasClicked=0,EnablePolling=0
	As Byte isActionSet=0,enable=1,isResizeable=1,isRezing,isgrey,noTextParse=0,isMoveable=1,isMoving,lastMouseWheelState,EnableMouse=1,EnableFullMove=0,AllowMouseOverEffect=1,EnableMouseClick=1,EnableChildObjects=0
	As pointUDT position
	As pointUDT positionBuffer '??
	As integer Width_,height 
	As Integer oldMouseX,oldMouseY
	As list_type Ptr child

	Declare virtual Function mouseOver As Byte
	Declare virtual Function mouseWheel(ignorPosition As UByte=0) As Byte
	Declare virtual Function isPressed(force As Byte=0) As Byte
	Declare virtual Sub repaint
	Declare virtual Sub paint
	Declare virtual Sub paintText
	Declare virtual Sub greyPaint
	Declare virtual Sub resize(set_x As double=0,set_y As Double = 0)
	Declare virtual Sub EnableChild(enable As Ubyte)
	Declare virtual Sub move
	Declare virtual Sub resetChildPosition
	Declare virtual Sub moveChild(x As Integer,y As Integer)
	Declare virtual Function todo As Byte
	Declare virtual Function GetMouseState(ByRef x As Integer=0,ByRef y As Integer=0,ByRef wheel As Integer=0,ByRef button As Integer=0,ByRef clip As Integer=0) As Integer
	As Byte pressed
	
	Declare Constructor(position As pointUDT Ptr=0,Width_ As Integer=0,height As Integer=0,bg As String="")
	
	Declare virtual Function equals(o As utilUDT Ptr) As Integer
	Declare virtual Sub SetEnable(enable As Byte)
End Type

Function graphicUDT.equals(o As utilUDT Ptr) As Integer
	If o=0 Then Return 0
	If Cast(graphicUDT Ptr,o)=@This Then Return 1
	Return 0
End Function

Constructor graphicUDT(position As pointUDT Ptr=0,Width_ As Integer=0,height As Integer=0,bg As String="")
	this.width_=Width_
	this.height=height
	buffer(1)=ImageCreate(width_,height)
	buffer(2)=ImageCreate(width_,height)
	Line buffer(1),(0,0)-(Width_,height),RGBA(0,0,0,0),bf
	Line buffer(2),(0,0)-(Width_,height),RGBA(0,0,0,0),bf
	If position<>0 Then
		this.position.x=position->x		
		this.position.y=position->y		
	EndIf
	If bg="" then
		background = getIMG("DEFAULT_GRAPHIC_BACKGROUND")
	Else
		background = getIMG(bg)
	End if
	'graphicList.add(@This,1)
End Constructor

Function graphicUDT.mouseOver As Byte
	If enable=0 Then Return 0
	Dim As Integer x,y
	If GetMouseState (x,y,0,0,0) = -1 Then Return 0
	If x>=position.x And x<position.x+Width_ And y>=position.y And y<position.y+height Then Return 1
	Return 0
End Function

Function graphicUDT.mouseWheel(ignorPosition As UByte=0) As Byte
	Dim As Integer x,y,r
	If GetMouseState (x,y,r,0,0) = -1 Then Return 0
	
	If (x>=position.x And x<position.x+Width_ And y>=position.y And y<position.y+height) Or ignorPosition=1 Then 
		Dim As Byte tmp=lastMouseWheelstate-r
		lastMouseWheelState=r
		Return tmp
	EndIf
	Return 0
End Function



Sub graphicUDT.painttext
	if noTextParse then
		draw String buffer(1),(Width_/2-Len(text)*4,height/2-4),text,RGB(255,255,255)
		draw String buffer(2),(Width_/2-Len(text)*4,height/2-4),text,RGB(255,255,255)
	end if
	
		Dim As GLOBAL_CURSOR_UDT Ptr GLOBAL_CURSOR_tmp = New GLOBAL_CURSOR_UDT
		GLOBAL_CURSOR_tmp->x = GLOBAL_CURSOR.x
		GLOBAL_CURSOR_tmp->y = GLOBAL_CURSOR.y
		GLOBAL_CURSOR_tmp->height = GLOBAL_CURSOR.height
		GLOBAL_CURSOR_tmp->width = GLOBAL_CURSOR.Width
		GLOBAL_CURSOR_tmp->state = GLOBAL_CURSOR.state
		GLOBAL_CURSOR_tmp->min_x = GLOBAL_CURSOR.min_x
		GLOBAL_CURSOR_tmp->min_y = GLOBAL_CURSOR.min_y
		GLOBAL_CURSOR_tmp->max_x = GLOBAL_CURSOR.max_x
		GLOBAL_CURSOR_tmp->max_y = GLOBAL_CURSOR.max_y
		
		GLOBAL_CURSOR.x = 0
		GLOBAL_CURSOR.y = 0
		GLOBAL_CURSOR.min_x = 0
		GLOBAL_CURSOR.min_y = 0
		GLOBAL_CURSOR.max_x = 0
		GLOBAL_CURSOR.max_y = 0
		GLOBAL_CURSOR.state = 1
		GLOBAL_CURSOR.height = this.height
		GLOBAL_CURSOR.width = this.width_
		
		Dim As list_type Ptr tmpList
		tmpList = New list_type
		tmpList = parseCommand("<"+text+"/>")

		GLOBAL_STRING_OUTPUT_BUFFER(1) = buffer(1)
		GLOBAL_STRING_OUTPUT_BUFFER(2) = buffer(2)
		GLOBAL_IMG_OUTPUT_BUFFER(1) = buffer(1)
		GLOBAL_IMG_OUTPUT_BUFFER(2) = buffer(2)
		interpreter(tmpList)
		tmpList->Clear

		Delete tmpList
		GLOBAL_STRING_OUTPUT_BUFFER(1) = 0
		GLOBAL_STRING_OUTPUT_BUFFER(2) = 0
		GLOBAL_IMG_OUTPUT_BUFFER(1) = 0
		GLOBAL_IMG_OUTPUT_BUFFER(2) = 0
		GLOBAL_CURSOR.x = GLOBAL_CURSOR_tmp->x
		GLOBAL_CURSOR.y = GLOBAL_CURSOR_tmp->y
		GLOBAL_CURSOR.height = GLOBAL_CURSOR_tmp->height
		GLOBAL_CURSOR.width = GLOBAL_CURSOR_tmp->Width
		GLOBAL_CURSOR.state = GLOBAL_CURSOR_tmp->state
		GLOBAL_CURSOR.min_x = GLOBAL_CURSOR_tmp->min_x
		GLOBAL_CURSOR.min_y = GLOBAL_CURSOR_tmp->min_y
		GLOBAL_CURSOR.max_x = GLOBAL_CURSOR_tmp->max_x
		GLOBAL_CURSOR.max_y = GLOBAL_CURSOR_tmp->max_y
		

End Sub
Sub graphicUDT.paint

	If background <> 0 Then
		Put buffer(1),(0,0),background->buffer,alpha
		Put buffer(2),(0,0),background->buffer,Alpha
		
		
		

		
		
	EndIf
	'Line buffer(1),(0,0)-(Width_,height),RGB(255,255,125),bf
	'Line buffer(2),(0,0)-(Width_,height),RGB(255,255,125),bf

	
End Sub

Sub graphicUDT.greyPaint
	if isgrey=0 then return
	for x as integer = 0 to width_
		for y as integer = 0 to height
			dim as integer tmpCol = point(x,y,buffer(1)) 
			dim as integer tmpColGrey = (CUINT(tmpCol) shr 16 and 255)*0.299+(CUINT(tmpCol) shr 8 and 255)*0.587+(CUINT(tmpCol) and 255)*0.114
			line buffer(1),(x,y)-(x,y),rgb(tmpColGrey,tmpColGrey,tmpColGrey)
			
			tmpCol = point(x,y,buffer(2)) 
			tmpColGrey = (CUINT(tmpCol) shr 16 and 255)*0.299+(CUINT(tmpCol) shr 8 and 255)*0.587+(CUINT(tmpCol) and 255)*0.114
			line buffer(2),(x,y)-(x,y),rgb(tmpColGrey,tmpColGrey,tmpColGrey)
		next
	next
end sub

Sub graphicUDT.repaint
	If enable=1 Then
		If wasChanged=1 Then 
			Paint 
			painttext
			greyPaint
		end if
		If EnablePolling=1 then
			If (Timer-polling_last)>polling Then 
				polling_last=timer
				Paint
				painttext
				greyPaint
				
				
			EndIf
		End If
		

		
		
				
		'Draw String  buffer(1),(Width_/2-Len(text)*4,height/2-4),text,RGB(255,255,255)
		'Draw String  buffer(2),(Width_/2-Len(text)*4,height/2-4),text,RGB(255,255,255)
		
		wasChanged=0
		resize
		move
		If useAlpha=0 then
			If mouseOver=1 And AllowMouseOverEffect=1 Then
				If buffer(2)<>0 Then Put (position.x,position.y),buffer(2),pset
			Else
				If buffer(2)<>0 Then Put (position.x,position.y),buffer(1),PSet
			EndIf
		Else
			If mouseOver=1 And AllowMouseOverEffect=1 Then
				If buffer(2)<>0 Then Put (position.x,position.y),buffer(2),Alpha
			Else
				If buffer(2)<>0 Then Put (position.x,position.y),buffer(1),alpha
			EndIf
		endif
	End if
End Sub

Function graphicUDT.isPressed(force As Byte=0) As byte
	If EnableMouseClick=0 Then Return 0
	Dim As Integer mx,my,mb
	If GetMouseState(mx,my,,mb) = -1 Then Return 0
	If mouseOver=1 Then
		If mb=1 Then
			pressed=1
			If force<>0 Then Return 1
		EndIf
		If mb=0 Then
			If pressed=1 Then 
				pressed=0
				wasClicked=1
				wasChanged=1
				Return 1
			End if
		EndIf
	Else
		pressed=0
	EndIf
End Function

Function graphicUDT.todo As Byte
	'wasChanged = 1
	repaint
	Return 1
End Function

Sub graphicUDT.resetChildPosition
	'---
End Sub

Sub graphicUDT.EnableChild(enable As Ubyte)
	If child = 0 Then Return
	Var tmpset = child->set
	child->reset
	Dim As graphicUDT Ptr tmp
	
	Do
		tmp = Cast(graphicUDT Ptr,child->getItem)
		If tmp <> 0 Then
			tmp->enable = enable
			
			'Var tmpset2 = child->set
			'tmp->resize(set_x,set_y)
			'resetChildPosition
			'child->set = tmpset2
			'If tmp->child<>0 Then
				'tmp->resizeChild(set_x,set_y)
			'EndIf
			
		EndIf
	Loop Until tmp = 0
	child->set = tmpset

	EnableChildObjects = enable	
	
End Sub

Sub graphicUDT.resize(set_x As Double=0,set_y As Double = 0)
 
	If set_x>0 And set_y>0 Then
		wasChanged=1
		If width_=set_x And height=set_y Then Return
		If set_x<1 Or set_y<1 Then Return
		
		If buffer(1)<>0 Then ImageDestroy buffer(1)	
		If buffer(2)<>0 Then ImageDestroy buffer(2)	

		width_=set_x
		height=set_y	
		
		EnableChild(0)
				
		'If width_<1 And height<1 Then

		
			buffer(1)=ImageCreate(width_,height)
			buffer(2)=ImageCreate(width_,height)
		'Else
		'	buffer(1)=0
		'	buffer(2)=0
		'End if
		return
	EndIf
	
	
	If isResizeable=1 Then
		Dim As Integer x,y,b
		If GetMouseState(x,y,,b) = -1 Then Return
		If x>=position.x+0.9*width_ And x<position.x+Width_ And y>=position.y+0.9*height And y<position.y+height And b=1 Then 
			isRezing=1
		EndIf
		If isRezing=1 Then
			If position.x<x And position.y<y Then
				If width_<> Abs(position.x-x) or height<>Abs(position.y-y) Then 
		If buffer(1)<>0 Then ImageDestroy buffer(1)	
		If buffer(2)<>0 Then ImageDestroy buffer(2)	
				
					width_=Abs(position.x-x)	
					height=Abs(position.y-y)	
					EnableChild(0)
					
					buffer(1)=ImageCreate(width_,height)
					buffer(2)=ImageCreate(width_,height)
					paint
					painttext
				EndIf
			End if
		EndIf
		'If b=0 and isRezing=1 then wasChanged=1
		If b=0 Then isRezing=0 
	EndIf
End Sub

Sub graphicUDT.moveChild(x As Integer,y As Integer)
	If child = 0 Then return
	child->reset
	Dim As graphicUDT Ptr tmp
	
	Do
		tmp = Cast(graphicUDT Ptr,child->getItem)
		
		If tmp <> 0 Then
			tmp->wasChanged=1
			tmp->position.x+=x
			tmp->position.y+=y
			If tmp->child<>0 Then
				tmp->moveChild(x,y)
			EndIf
			
		EndIf
	Loop Until tmp = 0

End Sub

Sub graphicUDT.move
	Dim As Integer x,y,b
	If isMoveable=1 Then
		If EnableFullMove=0 then
			
			If GetMouseState(x,y,,b) = -1 Then Return
			
			If x>=position.x And x<position.x+Width_*0.1 And y>=position.y And y<position.y+height*0.1 And b=1 Then 
				isMoving=1
			EndIf
			
			If isMoving=1 Then
				
				
				moveChild(x-position.x,y-position.y)
				position.x=x	
				position.y=y	
			EndIf
			If b=0 and isMoving=1 then wasChanged=1
			If b=0 Then isMoving=0 
		Else
			If GetMouseState(x,y,0,b,0) = -1 Then Return 

			If isPressed(1)=1 Then isMoving=1
			If b=0 Then isMoving=0
	
			If isMoving=1 then
				If oldMouseX=0 Then oldMouseX=x-position.x
				If oldMouseY=0 Then oldMouseY=y-position.y
				moveChild((x-oldMouseX)-position.x,(y-oldMouseY)-position.y)
				position.x=x-oldMouseX
				position.y=y-oldMousey
		
			Else
				oldMouseX=0
				oldMouseY=0
			EndIf
		End if
	EndIf
	
	
	
	

End Sub

Function graphicUDT.GetMouseState(ByRef x As Integer,ByRef y As Integer,ByRef wheel As Integer=0,ByRef button As Integer=0,ByRef clip As Integer=0) As Integer
	If EnableMouse=0 Then Return -1

	Return GetMouse(x,y,wheel,button)
	'x=x2
	'y=y2
	'wheel=wheel2
	'button=button2
	Return 0
End Function

Sub graphicUDT.SetEnable(enable As Byte)
	this.enable=enable
End Sub
