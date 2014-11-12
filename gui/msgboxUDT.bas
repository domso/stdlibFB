#Include Once "../util/util.bas"
#Include Once "graphicUDT.bas"
#Include Once "scrollUDT.bas"

Type msgboxUDT extends graphicUDT
	As byte itemHeight=8

	
	As String front_string
	As String main_string
	
	As list_type Ptr msgLog 

	As scrollUDT Ptr scroll
	As Integer line_x,line_y
	as integer current_scroll_status=0
	As Byte last_r
	Declare Constructor(position As pointUDT Ptr=0,Width_ As Integer,height As Integer,msgLog As list_type ptr)
	Declare virtual Function todo As Byte
	Declare virtual Sub Paint
	Declare Function calc_line_y(s As String) As Ubyte
	Declare Function calcStringLastLine(s As String) As Integer
	Declare Function calcStringFirstLine(s As String) As Integer
	Declare Sub pushUp
	Declare Sub pushDown
End Type

Constructor msgboxUDT(position As pointUDT Ptr=0,Width_ As Integer,height As Integer,msgLog As list_type ptr)
	base(position,width_-width_*0.1+2,height)
	this.msgLog=msgLog
	Paint
	
	scroll = New scrollUDT(New pointUDT(position->x+Width_,position->y),20,height,itemheight)
	
	base.enablePolling=1
	base.polling=1

End Constructor

Sub msgboxUDT.paint
	Line buffer(1),(0,0)-(Width_-1,height-1),RGBa(red,green,blue,255),bf
	Line buffer(1),(0,0)-(Width_-1,height-1),RGB(143,76,25),b
	Line buffer(1),(2,2)-(Width_-1-2,height-1-2),RGB(0,0,0),b
	Line buffer(1),(1,1)-(Width_-1-1,height-1-1),RGB(0,0,0),b
	
	Line buffer(2),(0,0)-(Width_-1,height-1),RGBa(redE,greenE,blueE,200),bf
	Line buffer(2),(0,0)-(Width_-1,height-1),RGB(143,76,25),b
	Line buffer(2),(2,2)-(Width_-1-2,height-1-2),RGB(0,0,0),b
	Line buffer(2),(1,1)-(Width_-1-1,height-1-1),RGB(0,0,0),b

	If background<>0 Then Put buffer(1),(0,0),background->buffer,alpha
	If background<>0 Then Put buffer(2),(0,0),background->buffer,Alpha
	
	Dim As Integer x_c,y_c
	
	If main_string <> "" then
		For i As Integer = 0 To Len(main_string)-1
			If main_string[i] <> 10 then
				Draw String buffer(1),(itemHeight+x_c*itemHeight,itemHeight+y_c*itemHeight),chr(main_string[i]),RGB(255,255,255)	
				Draw String buffer(2),(itemHeight+x_c*itemHeight,itemHeight+y_c*itemHeight),chr(main_string[i]),RGB(255,255,255)	
				x_c+=1
				If x_c+1>line_x Then
					x_c = 0 
					y_c +=1
				EndIf
			Else
					x_c = 0 
					y_c +=1
			End If
			If y_c>Line_y Then Exit for
		Next
	End if
	
	
End Sub

Function msgboxUDT.todo As Byte
	If enable = 0 Then Return 0
	line_x = (Width_-2*itemHeight)/itemHeight
	line_y = (height-2*itemHeight)/itemHeight
	repaint
	If scroll<>0 Then
		scroll->todo
		If scroll->background <> this.background Then
			scroll->background = this.background
		EndIf
		
		If mouseover Then
			Dim As Integer r=mouseWheel(1)
			If r<>0 Then
				If last_r <> r Then
					r*=2	
				EndIf
				
				scroll->setStatus(scroll->status+r*itemHeight)
				If r>0 Then last_r = 1
				If r<0 Then last_r = -1
				
				wasChanged=1
			End If				
		EndIf
		
		If current_scroll_status-itemHeight>=scroll->status Then
			Do
				current_scroll_status-=itemHeight
				pushDown
			Loop until current_scroll_status-itemHeight<=scroll->status
		EndIf
		If current_scroll_status+itemHeight<=scroll->status Then
			Do
				current_scroll_status+=itemHeight
				pushUp
			Loop until current_scroll_status+itemHeight>=scroll->status
		EndIf
		
		If scroll->height<>height Then
			scroll->resize(20,height)
		EndIf
		
		scroll->position.x=position.x+Width_'-scroll->width_
		scroll->position.y=position.y
		
		'scroll->maxstatus = (calc_line_y(main_string) + calc_line_y(front_string))*itemHeight
				
		If scroll->maxstatus <> (calc_line_y(main_string) + calc_line_y(front_string))*itemHeight Then
			scroll->maxstatus = (calc_line_y(main_string) + calc_line_y(front_string))*itemHeight
			'scroll->status = 0
			'current_scroll_status = 0
			scroll->resize(20,height)
		EndIf
	
		if scroll->wasChanged=1 then wasChanged=1
		
		
		
		
	EndIf
	
	If msgLog <> 0 Then
		msgLog->Reset
		Dim As utilUDT Ptr tmp
		Do
			tmp = msgLog->getItem
			If tmp <> 0 Then
				
				If main_string = "" then
						main_string = tmp->toString
				Else
						main_string += Chr(10)+tmp->toString
				End If
				Do
					pushUp
					scroll->setStatus(scroll->status+itemHeight)
				Loop Until calc_line_y(main_string)<=line_y
				
				'If calc_line_y(main_string)<line_y Then
				'	If main_string = "" then
				'		main_string = tmp->toString
				'	Else
				'		main_string = tmp->toString+Chr(10)+main_string
				'	End If
				'Else
				'	If front_string = "" then
				'		front_string = tmp->toString
				'	Else
				'		front_string = front_string+Chr(10)+tmp->toString
				'	End If
				'EndIf
				

				
				
				
				msgLog->remove(tmp)
			EndIf
		Loop Until tmp=0
	EndIf
	
	
End Function

Function msgboxUDT.calc_line_y(s As String) As Ubyte
	Dim As Integer x_c,y_c
	If s <> "" then
		For i As Integer = 0 To Len(s)-1
			If s[i] <> 10 then
				x_c+=1
				If x_c+1>line_x Then
					x_c = 0 
					y_c +=1
				EndIf
			Else
					x_c = 0 
					y_c +=1
			End If
			'If y_c>Line_y Then Return 0
		Next
	End If
	Return y_c
End Function

Function msgboxUDT.calcStringLastLine(s As String) As Integer
	If s = "" Then Return 0 ' ??
	Dim As Integer x
	For i As Integer =  Len(s)-1 To 0 Step -1
		x+=1
		If s[i] = 10 And i<>Len(s)-1 Then x-=1 : Exit For
		'if x = line_x Then Exit for
	Next
	
	x = x Mod line_x
	If x = 0 Then x = line_x
	
	Return Len(s)-x
	
End Function

Function msgboxUDT.calcStringFirstLine(s As String) As Integer
	If s = "" Then Return 0 ' ??
	Dim As Integer x
	For i As Integer = 0 To Len(s)-1
		x+=1
		If s[i] = 10 And i<>0 Then Exit For
		if x = line_x Then Exit For
	Next
	
	Return x
	
End Function

Sub msgboxUDT.pushUp
	If calc_line_y(main_string)<=line_y Then return
	Dim As Integer tmp = calcStringFirstLine(main_string)
	If tmp = 0 Then Return 
	front_string += Mid(main_string,1,tmp)
	main_string = Mid(main_string,tmp+1)
End Sub

Sub msgboxUDT.pushDown
	Dim As Integer tmp = calcStringLastLine(front_string)
	If tmp = 0 Then
		main_string = front_string + main_string
		'If main_string[0] = 10 Then main_string = Mid(main_string,2)
		front_string = ""
		Return 
	EndIf
	main_string = Mid(front_string,tmp+1) + main_string
	front_string = Mid(front_string,1,tmp)
	'If main_string[0] = 10 Then main_string = Mid(main_string,2)
End Sub


/'
Sub msgboxUDT.paint
	If scroll=0 Then Return
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
	
	
	'Draw String  buffer(1),(0,0),"",RGB(255,255,255)
	'Draw String  buffer(2),(0,0),"",RGB(255,255,255)
	Dim As Integer i=2,j=0
	Dim As Integer a,b
	Dim As Any Ptr tmp
	Dim As msgboxLineUDT Ptr  lineListItem
	If msgLog<>0 Then
		
		scroll->maxstatus=0
		msgLog->Reset
		lineList.clear
		Do
			If width_<(5*8) Then return
			tmp=msgLog->getItem()
			If tmp<>0 Then

				Var tmpB=cast(utilUDT Ptr,tmp)
				j=Len(tmpB->toString)
				
				
				
				a=width_/8
				b=scroll->status+1
				Do
					

					If (i-scroll->status+1)*8>0 or (i-scroll->status+1)*8<height Then
						If (i-b)*8>0 And ((i-b)*8+8)<=height Then
							'If lineListItem->startY=0 Then
							
							If SelectedString=tmpB->toString Then
								Line buffer(1),(4,(i-b)*8)-(width_-4,(i-b+1)*8),RGB(143,76,25),bf
								Line buffer(2),(4,(i-b)*8)-(width_-4,(i-b+1)*8),RGB(143,76,25),bf
								
								
							EndIf
							
							lineListItem=New msgboxLineUDT()
							lineListItem->startY=(i-b)*8 
							lineListItem->stopY=(i-b+1)*8
							lineListItem->text=tmpB->toString
							Draw String  buffer(1),(8,(i-b)*8),Mid(tmpB->toString,Len(tmpB->toString)-j+1,(a)-2),RGB(255,255,255)
							Draw String  buffer(2),(8,(i-b)*8),Mid(tmpB->toString,Len(tmpB->toString)-j+1,(a)-2),RGB(255,255,255)
							lineList.add(lineListItem,1)	
						End If
					End If

					i+=1
					j-=(a-2)
				Loop Until j<=0' Or ((i-b)*8)>height
				
	
				'scroll->maxstatus=i+1
				'If msgLog->itemCount Mod (height/itemHeight) = 0 Then
					scroll->maxstatus+=Int(Len(tmpB->toString)/(a-2))+1
					'msgLog->itemCount
				'Else
					 'scroll->maxStatus =  msgLog->itemCount - ( msgLog->itemCount Mod (height/itemHeight) ) +  (height/itemHeight)
				'EndIf
				
				
				
			EndIf
		Loop Until tmp=0 'Or ((i-b)*8)>height
	End if
	scroll->maxstatus+=1
End Sub

Function msgboxUDT.todo As Byte
	'If enable=0 Then Return 0
	'wasChanged=1
	
	repaint

	scroll->ismoving =isMoving

	If mouseOver=1 Then
		Dim As Integer r=mouseWheel
		If r<>0 Then
			wasChanged=1
			scroll->setStatus(scroll->status+r)
		EndIf
		Dim As Integer listItemcount=0
		If EnableItemSelect=1 Then
			lineList.reset
			Dim As Any Ptr tmp
			Dim As Byte found
			Do
				tmp=lineList.getItem()
				If tmp<>0 Then
					listItemcount+=1
					Var tmpI=Cast(msgboxLineUDT Ptr,tmp)
					Dim As Integer x,y
					If GetMouseState (x,y,0,0,0) = -1 Then Exit Do
					If y>position.y+tmpI->startY And y<position.y+tmpI->stopY Then
						If SelectedString<>tmpI->text Then
							SelectedString=tmpI->text
							wasChanged=1
						EndIf
						found=1						
					EndIf
				EndIf	
			Loop Until tmp=0
			'WindowTitle Str(listItemcount)
			If found=0 Then
				SelectedString=""
				wasChanged=1
			EndIf
			
		EndIf
	Else
		If SelectedString<>"" Then
			SelectedString=""
			wasChanged=1
		EndIf
			
	EndIf
	

	'If scroll->button->wasClicked=1 Then scroll->wasChanged=1 : scroll->button->wasClicked=0
	scroll->position.x=position.x+Width_'-scroll->width_
	scroll->position.y=position.y
	
	scroll->resize(width_*0.1,height)
		
	scroll->todo
	if scroll->wasChanged=1 then wasChanged=1
	Return 1
End Function
'/