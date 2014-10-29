#Include Once "panelUDT.bas"
#Include Once "graphicUDT.bas"
#Include Once "buttonUDT.bas"
#Include Once "pointUDT.bas"
#Include Once "groupUDT.bas"
#Include Once "checkboxUDT.bas"

Dim Shared As list_type GLOBAL_GUI_WINDOW_LIST





Type windowUDT extends panelUDT
	As Byte isMoving
	As buttonUDT  Ptr main
	As buttonUDT  Ptr topBar
	As checkboxUDT  Ptr close
	As String text
	As String id_name
	
	Declare Sub AddGraphic(item As graphicUDT ptr)
	Declare Constructor(id_name As String="",text As String="",position As pointUDT Ptr=0,Width_ As Integer=0,height As Integer=0,noList As UByte=0)
	Declare virtual Sub update
	Declare virtual Sub move
	
	Declare virtual Function equals(o As utilUDT Ptr) As Integer
	Declare virtual Sub WindowClose
	Declare virtual Sub EnableInactiv(status As Byte)
End Type

Function get_window(id_name As String) As windowUDT Ptr
	If id_name = "" Then Return 0
	
	Dim As windowUDT Ptr tmp = New windowUDT(id_name,"",0,0,0,1)
	Dim As windowUDT ptr tmp2 = Cast(windowUDT Ptr,GLOBAL_GUI_WINDOW_LIST.search(tmp))
	Delete tmp
	Return tmp2
End Function


Sub windowUDT.AddGraphic(item As graphicUDT ptr)
	If isFullScreen=0 then
		item->position.x+=position.x
		item->position.y+=position.y
		item->position.y+=topbar->height
		item->isResizeable=0
		item->isMoveAble=0
	Else
		item->isResizeable=1
		item->isMoveAble=1
	End if
	
	graphicList.add(item,1)	
End Sub

Constructor windowUDT(id_name As String="",text As String="",position As pointUDT Ptr=0,Width_ As Integer=0,height As Integer=0,noList As UByte=0)
	base(position,width_,height)
	this.id_name = id_name
	
	
	If position<>0 then
		this.text=""
		main = New buttonUDT("",position,width_,height)
		main->isMoveable=0
		main->isResizeable=1
		main->EnableMouse=1
		main->AllowMouseOverEffect=0
		main->red=125
		main->green=80
		main->blue=40
		'main->useBackground=1
		main->background = getIMG("DEFAULT_WINDOW_BACKGROUND")
		
		topBar = New buttonUDT(text,position,width_-10,10)
		topBar->EnableFullMove=1
		topBar->isResizeable=0
		topBar->red=125
		topBar->green=80
		topBar->blue=40
	
		close = New checkboxUDT(New pointUDT(position->x+width_-10,position->y),10,10)
		Close->status=1
		Close->EnableStatic=1
		Close->isResizeable=0
		Close->isMoveAble=0
	Else
		base.isFullScreen=1
		ScreenInfo base.width_,base.height 
		
	End If
	If noList = 0 then 
		GLOBAL_GUI_WINDOW_LIST.add(@This,1)
	End If
	EnableEvent=1
End Constructor

Sub windowUDT.update
	If enable=1 Then
		If isFullScreen=0 Then
			move
			main->todo
			isRezing=main->isRezing
			topBar->resize(main->Width_,topBar->height)
			If width_<>main->width_ Or height<>(main->height) Then '+topbar->height
				Dim As Any Ptr tmp
				graphicList.reset
				Do
					tmp=graphicList.getItem()
					If tmp<>0 Then
						Var tmpB=cast(graphicUDT Ptr,tmp)
						If tmpB->isResizeable = 1 then
							tmpB->resize(tmpB->width_*(main->width_ / Width_),tmpB->height*((main->height)/ height))
						End if						
						tmpB->position.x = position.x+(tmpB->position.x-position.x)*(main->width_ / Width_)
						tmpB->position.y = position.y+(tmpB->position.y-position.y)*((main->height)/ height)	
					End If
				Loop Until tmp=0
			End If
			Width_=main->width_
			height=main->height '+topbar->height
			
			
			Close->position.x=position.x+width_-10
			Close->position.y=position.y
			
			graphicList.execute
			
			topBar->todo
			Close->todo
			If topBar->isPressed(1)=1 Then 
				GLOBAL_GUI_WINDOW_LIST.lswap(@this,GLOBAL_GUI_WINDOW_LIST.ende->head) 
			EndIf
			If Close->isPressed=1  Then windowClose
		Else
			graphicList.execute
		End if
	End If	
End Sub

Sub windowUDT.move
	Dim As Integer x,y,b
	topBar->move
	
	If topBar->position.x <> position.x Or topBar->position.y <> position.y Then
		
		main->position.x +=  topBar->position.x - position.x
		main->position.y +=  topBar->position.y - position.y
		Dim As Any Ptr tmp
		graphicList.reset
		Do
			tmp=graphicList.getItem()
			If tmp<>0 Then
				Var tmpB=cast(graphicUDT Ptr,tmp)
				'tmpB->isMoving=1
				tmpB->position.x +=  topBar->position.x - position.x
				tmpB->position.y +=  topBar->position.y - position.y
			
			
			
				If tmpB->child<>0 Then
					tmpB->moveChild(topBar->position.x - position.x,topBar->position.y - position.y)
					
				EndIf
			
			
			End If
		Loop Until tmp=0
		
		position.x = topBar->position.x
		position.y = topBar->position.y
		
	EndIf
	
	
	
End Sub

Function windowUDT.equals(o As utilUDT Ptr) As Integer
	If o = 0 Then Return 0
	If this.id_name = Cast(WindowUDT Ptr,o)->id_name Then Return 1
	Return 0
End Function

Sub windowUDT.windowClose
	enable=0
End Sub

Sub windowUDT.EnableInactiv(status As Byte)
	
	If isFullScreen=0 Then
		topbar->EnableMouse=status
		Close->enableMouse=status
		main->enableMouse=status
	End if
	EnableMouse(status)
End Sub

