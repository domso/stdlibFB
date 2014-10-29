#Include Once "../util/util.bas"
#Include Once "graphicUDT.bas"
#Include Once "scrollUDT.bas"

Type msgboxLineUDT extends utilUDT
	As Integer startY,stopY
	As String text
End Type

Type msgboxUDT extends graphicUDT
	As byte itemHeight=8
	As Byte EnableItemSelect 'TBD
	As String SelectedString
	As list_type Ptr msgLog 
	As list_type lineList 
	As scrollUDT Ptr scroll
	Declare Constructor(position As pointUDT Ptr=0,Width_ As Integer,height As Integer,msgLog As list_type ptr)
	Declare virtual Function todo As Byte
	Declare virtual Sub Paint
End Type

Constructor msgboxUDT(position As pointUDT Ptr=0,Width_ As Integer,height As Integer,msgLog As list_type ptr)
	base(position,width_-width_*0.1+2,height)
	this.msgLog=msgLog
	Paint
	
	scroll = New scrollUDT(New pointUDT(position->x+Width_,position->y),width_*0.1,height,itemHeight)
		base.enablePolling=1
	base.polling=1

End Constructor


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
