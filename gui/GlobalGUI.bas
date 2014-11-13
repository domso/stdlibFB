#Include Once "../util/util.bas"
#Include Once "graphicUDT.bas"
#Include Once "panelUDT.bas"
#Include Once "windowUDT.bas"


Dim Shared As Byte GLOBAL_EVENT_MOUSEOVER
Dim Shared As Byte GLOBAL_EVENT_SET_MOUSE
Dim Shared As list_type GLOBAL_GUI_EVENT_LIST
Dim Shared As Integer GLOBAL_WINDOW_X
Dim Shared As Integer GLOBAL_WINDOW_Y
Dim Shared As UBYTE GLOBAL_WINDOW_BACKGROUND_RED
Dim Shared As UByte GLOBAL_WINDOW_BACKGROUND_GREEN
Dim Shared As UByte GLOBAL_WINDOW_BACKGROUND_BLUE

Sub GUI_SET(windowx As Integer,windowy As Integer,r As UByte,g As UByte,b As UByte)
	GLOBAL_WINDOW_X = windowx
	GLOBAL_WINDOW_Y = windowy
	GLOBAL_WINDOW_BACKGROUND_RED = r
	GLOBAL_WINDOW_BACKGROUND_GREEN = g
	GLOBAL_WINDOW_BACKGROUND_BLUE = b
End Sub

Sub GUI_UPDATE
	If GLOBAL_WINDOW_X<>0 And GLOBAL_WINDOW_Y<>0 then
		Line(0,0)-(GLOBAL_WINDOW_X,GLOBAL_WINDOW_Y),RGB(GLOBAL_WINDOW_BACKGROUND_RED,GLOBAL_WINDOW_BACKGROUND_GREEN,GLOBAL_WINDOW_BACKGROUND_BLUE),bf
	End if
	'GLOBAL_GUI_PANEL_LIST.execute
	GLOBAL_GUI_WINDOW_LIST.execute
	GLOBAL_GUI_EVENT_LIST.execute
	
	GLOBAL_EVENT_MOUSEOVER=0
	Dim As Any Ptr tmp
	
	Dim As graphicUDT ptr tmpA	
	Dim As panelUDT ptr tmpB
	Dim As panelUDT ptr tmpB1=0



	GLOBAL_GUI_WINDOW_LIST.set=GLOBAL_GUI_WINDOW_LIST.ende
	Do
		tmp=GLOBAL_GUI_WINDOW_LIST.getItem(1)
		If tmp<>0 Then
			tmpB=cast(panelUDT Ptr,tmp)
			If tmpB->isFullScreen=0 And ( tmpB->mouseOver(1)=1 Or tmpB->mouseOver()=1 ) Then 
					tmpB1=tmpB
					Exit Do
			EndIf
			
		End If
	Loop Until tmp=0
	If tmpB1<>0 then
		GLOBAL_GUI_WINDOW_LIST.reset
		Do
			tmp=GLOBAL_GUI_WINDOW_LIST.getItem()
			If tmp<>0 Then
				tmpB=cast(panelUDT Ptr,tmp)
				If tmpB<>tmpB1 Then
					If tmpB->isRezing=0 Then tmpB->EnableInactiv(0)
				Else
					tmpB->EnableInactiv(1)
				EndIf
			End If
		Loop Until tmp=0
	Else
		GLOBAL_GUI_WINDOW_LIST.reset
		Do
			tmp=GLOBAL_GUI_WINDOW_LIST.getItem()
			If tmp<>0 Then
				tmpB=cast(panelUDT Ptr,tmp)
					tmpB->EnableInactiv(1)
			End If
		Loop Until tmp=0
		
		
	End if
	

	GLOBAL_GUI_EVENT_LIST.reset
	Do
		tmp=GLOBAL_GUI_EVENT_LIST.getItem()
		If tmp<>0 Then
			tmpB=cast(panelUDT Ptr,tmp)
			If tmpB->mouseOver=1 Then 
				GLOBAL_EVENT_MOUSEOVER=1
				Exit do
			EndIf
		End If
	Loop Until tmp=0
	
	
If GLOBAL_EVENT_MOUSEOVER=1 Then
		GLOBAL_GUI_PANEL_LIST.reset
		Do
			tmp=GLOBAL_GUI_PANEL_LIST.getItem()
			If tmp<>0 Then
				tmpB=cast(panelUDT Ptr,tmp)
				tmpB->EnableMouse(0)
			End If
		Loop Until tmp=0
		GLOBAL_GUI_EVENT_LIST.reset
		Do
			tmp=GLOBAL_GUI_EVENT_LIST.getItem()
			If tmp<>0 Then
				tmpB=cast(panelUDT Ptr,tmp)
				tmpB->EnableMouse(1)
			End If
		Loop Until tmp=0
		GLOBAL_EVENT_SET_MOUSE=1
		
	Else
		If GLOBAL_EVENT_SET_MOUSE=1 Then

			GLOBAL_GUI_PANEL_LIST.reset
			Do
				tmp=GLOBAL_GUI_PANEL_LIST.getItem()
				If tmp<>0 Then
					tmpB=cast(panelUDT Ptr,tmp)
						tmpB->EnableMouse(1)
						GLOBAL_EVENT_SET_MOUSE=0
				End If
			Loop Until tmp=0
		EndIf
	EndIf

updateInkey

End Sub


Sub GLOBAL_EVENT_LIST_CLEAR
	Dim As Any Ptr tmp
	Dim As panelUDT ptr tmpB
	GLOBAL_GUI_EVENT_LIST.reset
	Do
		tmp=GLOBAL_GUI_EVENT_LIST.getItem()
		If tmp<>0 Then
			tmpB=cast(panelUDT Ptr,tmp)
			tmpB->Enable=0
			tmpB->loadOnEventList=0
			'EnableGraphics(0)
		End If
	Loop Until tmp=0
	GLOBAL_GUI_EVENT_LIST.clear(1)
End Sub
