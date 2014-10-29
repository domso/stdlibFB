#Include Once "../util/util.bas"
#Include Once "graphicUDT.bas"

Dim Shared As list_type GLOBAL_GUI_TEXTFIELD_LIST

Type textfieldUDT extends graphicUDT
	As String Ptr text
	As String highlight
	As Integer CursorPosition
	As Byte status,EnableSecretInput=0,Editable=1
	Declare Constructor(position As pointUDT Ptr=0,Width_ As Integer=0,height As Integer=0)
	Declare virtual Function todo As Byte
	Declare virtual Sub paint
End Type

Constructor textfieldUDT(position As pointUDT Ptr=0,Width_ As Integer=0,height As Integer=0)
	base(position,width_,height)
	Paint
	GLOBAL_GUI_TEXTFIELD_LIST.add(@This)
End Constructor


Sub textfieldUDT.paint
	Line buffer(1),(0,0)-(Width_-1,height-1),RGBa(red,green,blue,255),bf
	Line buffer(1),(1,1)-(Width_-1,height-1),RGB(143,76,25),b
	Line buffer(1),(3,3)-(Width_-1-2,height-1-2),RGB(0,0,0),b
	Line buffer(1),(2,2)-(Width_-1-1,height-1-1),RGB(0,0,0),b
	
	Line buffer(2),(0,0)-(Width_-1,height-1),RGBa(200,green,blue,200),bf
	Line buffer(2),(1,1)-(Width_-1,height-1),RGB(143,76,25),b
	Line buffer(2),(3,3)-(Width_-1-2,height-1-2),RGB(0,0,0),b
	Line buffer(2),(2,2)-(Width_-1-1,height-1-1),RGB(0,0,0),b

	
	If background<>0 Then Put buffer(1),(0,0),background->buffer,alpha
	If background<>0 Then Put buffer(2),(0,0),background->buffer,Alpha
	
	
	For i As Integer = 0 To Len(highlight)
		If Asc(highlight,i)=49 Then
			Line buffer(1),(Width_/2-Len(highlight)*4+i*8-8,height/2-4)-(Width_/2-Len(highlight)*4+i*8,height/2-4+8),RGB(120,120,120),bf
		EndIf
	Next
	If text = 0 Then return
	
	If EnableSecretInput=0 Then
		Draw String  buffer(1),(Width_/2-Len(*text)*4,height/2-4),*text,RGB(255,255,255)
		Draw String  buffer(2),(Width_/2-Len(*text)*4,height/2-4),*text,RGB(255,255,255)
	Else
		Draw String  buffer(1),(Width_/2-Len(*text)*4,height/2-4),String(Len(*text),"*"),RGB(255,255,255)
		Draw String  buffer(2),(Width_/2-Len(*text)*4,height/2-4),String(Len(*text),"*"),RGB(255,255,255)
	End if
	'Draw String  buffer(1),(0,0),text,RGB(255,255,255)
	'Draw String  buffer(2),(0,0),text,RGB(255,255,255)
	'
	If status=1 Then 
		Line buffer(1),(Width_/2-Len(*text)*4+CursorPosition*8,height/2-4)-(Width_/2-Len(*text)*4+CursorPosition*8,height/2-4+8),RGB(255,255,255)
		Line buffer(2),(Width_/2-Len(*text)*4+CursorPosition*8,height/2-4)-(Width_/2-Len(*text)*4+CursorPosition*8,height/2-4+8),RGB(255,255,255)
		
		
		'Line buffer(2),(Width_/2-Len(*text)*4+Len(*text)*8,height/2-4)-(Width_/2-Len(*text)*4+Len(*text)*8,height/2-4+8),RGB(255,255,255)
	'	Draw String  buffer(1),((Len(*text))*7,0),"|",RGB(255,255,255)
	'	Draw String  buffer(2),((Len(*text))*7,0),"|",RGB(255,255,255)
	EndIf
	'
End Sub

Function textfieldUDT.todo As Byte
	If enable=0 Then status=0 : Return 0
	
	repaint
	If text = 0 Then Return 0
	
	If isPressed=1 And Editable=1 Then 
		If status=1 Then
			status=0
		Else
			Dim As Any Ptr tmp
			GLOBAL_GUI_TEXTFIELD_LIST.reset
			Do
				tmp=GLOBAL_GUI_TEXTFIELD_LIST.getItem()
				If tmp<>0 Then
					Var tmpB=cast(textfieldUDT Ptr,tmp)
					tmpB->status=0
			
				End If
			Loop Until tmp=0
			status=1
			DO : LOOP WHILE LEN(INKEY)
		EndIf
	EndIf
	If status=1 Then
		wasChanged=1
		Dim As String key=InKey
		
		If key<>"" Then 
			
			If key=Chr(255)+"M" Then
				CursorPosition+=1
				If CursorPosition>Len(*text) Then CursorPosition=Len(*text)
				If MultiKey(&h36) Or MultiKey(&h2A) Then
				   If Asc(highlight,CursorPosition)<>49 Then
						highlight= Mid(highlight,1,CursorPosition-1)+"1"+Mid(highlight,CursorPosition+1)
				   Else
				   	highlight= Mid(highlight,1,CursorPosition-1)+"0"+Mid(highlight,CursorPosition+1)
	   			EndIf
				End if
			ElseIf key=Chr(255)+"K" Then
				CursorPosition-=1
				If CursorPosition<0 Then CursorPosition=0		
				If MultiKey(&h36) Or MultiKey(&h2A) Then
					If Asc(highlight,CursorPosition)<>49 Then
						highlight= Mid(highlight,1,CursorPosition)+"1"+Mid(highlight,CursorPosition+2)
				   Else
				   	highlight= Mid(highlight,1,CursorPosition)+"0"+Mid(highlight,CursorPosition+2)
	   			EndIf
				EndIf
				
				
				
			ElseIf key=Chr(255)+"S" Then
				 If CursorPosition<>Len(*text) then
	   			*text=Mid(*text,1,CursorPosition)+Mid(*text,CursorPosition+2)
	  
	   			
				 End If
			ElseIf key=Chr(255)+"G" Then
				CursorPosition=0
				
			ElseIf key=Chr(255)+"O" Then
				CursorPosition=Len(*text)				
			ElseIf key>Chr(31) And key<Chr(127)  Then
						'text+=key
						*text= Mid(*text,1,CursorPosition)+key+Mid(*text,CursorPosition+1)
						highlight= Mid(highlight,1,CursorPosition-1)+String(Len(key),"0")+Mid(highlight,CursorPosition)
						'highlight+=String(Len(key),"1")
						CursorPosition+=Len(key)
			ElseIf key=Chr(8) Then
   			'text=Str(Mid(text,1,(Len(*text)-1)))
   			If CursorPosition<>0 Then
   				If InStr(highlight,"1")=0 then
		   			*text=Mid(*text,1,CursorPosition-1)+Mid(*text,CursorPosition+1)
		   			highlight=Mid(highlight,1,CursorPosition-1)+Mid(highlight,CursorPosition+1)
		   			CursorPosition-=1
		   			If CursorPosition<0 Then CursorPosition=0
   				Else
   					end
   					For i As Integer = 0 To Len(highlight)
							If Asc(highlight,i)=49 Then
								highlight=Mid(highlight,1,i-1)+Mid(highlight,i+1)
								*text=Mid(*text,1,i-1)+Mid(*text,i+1)
							EndIf
						Next
   					
   				End if
   			End If
			ElseIf key=Chr(9) And MultiKey(&h36)=0 and MultiKey(&h2A)=0  Then 
				'tab -> switch textfield
				Dim As Any Ptr tmp
				Dim As Byte found
				GLOBAL_GUI_TEXTFIELD_LIST.reset
				Do
					tmp=GLOBAL_GUI_TEXTFIELD_LIST.getItem()	
						If tmp<>0 Then
						Var tmpB=cast(textfieldUDT Ptr,tmp)
						If tmpB->status=1 Then
							Do
								tmp=GLOBAL_GUI_TEXTFIELD_LIST.getItem()
								If tmp=0 Then Exit do	
								tmpB=cast(textfieldUDT Ptr,tmp)
								If tmpB->Editable=1 And tmpB->Enable=1 Then 
									this.status=0
									tmpB->status=1
									found=1
									Exit do
								EndIf
							Loop Until tmp=0
							If found=0 Then
								GLOBAL_GUI_TEXTFIELD_LIST.reset
								Do
									tmp=GLOBAL_GUI_TEXTFIELD_LIST.getItem()
									If tmp=0 Then Exit do	
									tmpB=cast(textfieldUDT Ptr,tmp)
									If tmpB->Editable=1 And tmpB->Enable=1 Then 
										this.status=0
										tmpB->status=1
										found=1
										Exit do
									EndIf
								Loop Until tmp=0
							EndIf
						EndIf
					End If
				Loop Until tmp=0
			
			ElseIf key=Chr(255)+Chr(15) Then
				Dim As Any Ptr tmp
				Dim As Byte found
				GLOBAL_GUI_TEXTFIELD_LIST.set=GLOBAL_GUI_TEXTFIELD_LIST.ende
				Do
					tmp=GLOBAL_GUI_TEXTFIELD_LIST.getItem(1)	
						If tmp<>0 Then
						Var tmpB=cast(textfieldUDT Ptr,tmp)
						If tmpB->status=1 Then

							Do
								tmp=GLOBAL_GUI_TEXTFIELD_LIST.getItem(1)
								If tmp=0 Then Exit do	
								tmpB=cast(textfieldUDT Ptr,tmp)
								If tmpB->Editable=1 And tmpB->Enable=1 Then 
									this.status=0
									tmpB->status=1
									found=1
									Exit do
								EndIf
							Loop Until tmp=0
							If found=0 Then
								GLOBAL_GUI_TEXTFIELD_LIST.set=GLOBAL_GUI_TEXTFIELD_LIST.ende
								Do
									tmp=GLOBAL_GUI_TEXTFIELD_LIST.getItem(1)
									If tmp=0 Then Exit do	
									tmpB=cast(textfieldUDT Ptr,tmp)
									If tmpB->Editable=1 And tmpB->Enable=1 Then 
										this.status=0
										tmpB->status=1
										found=1
										Exit do
									EndIf
								Loop Until tmp=0
							EndIf
						EndIf
					End If
				Loop Until tmp=0
			End If
		EndIf
		If MultiKey(&h1C) Then
			status=0
		EndIf
	EndIf
	
	Return 1
End Function