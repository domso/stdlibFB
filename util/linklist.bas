#Include Once "utilUDT.bas"

Type list_item_type
	As utilUDT ptr head
	As list_item_type Ptr tail
	As list_item_type Ptr front
End Type

Type list_type
	As list_item_type Ptr start=0
	As list_item_type Ptr ende=0
	As list_item_type Ptr set
	As Any Ptr list_mutex
	As Integer itemCount
	Declare Sub Add(item As utilUDT ptr,DisableRemove As Integer=0)
	Declare Sub Add(list As list_type Ptr,noDelete As Integer=0)
	Declare Sub AddFront(item As utilUDT ptr,DisableRemove As Integer=0)
	
	
	Declare Sub Clear(DisableHeadDelete As Byte=0)
	Declare Sub remove(item As utilUDT Ptr,DisableHeadDelete As Byte=0)
	Declare Sub remove_rec(item As utilUDT Ptr,set As list_item_type ptr,last As list_item_type Ptr)
	Declare Function data2list(item As utilUDT Ptr) As list_item_type Ptr
	Declare Sub out
	Declare Sub out_rec(set As list_item_type ptr)
	
	Declare sub Reset(noMutex As UByte=0)
	Declare sub ResetB(noMutex As UByte=0)
	Declare Function getItem(backward As byte=0,index As UInteger=0) As utilUDT Ptr
	
	
	Declare Function search(item As utilUDT Ptr) As utilUDT Ptr
	
	Declare Function lswap(item1 As utilUDT Ptr,item2 As utilUDT Ptr) As byte
	Declare Sub execute
	
	Declare Sub sort
	Declare Sub sort2
	Declare Sub sort3
	Declare Constructor(noMutex As UByte = 0)
	Declare Destructor
End Type

Constructor list_type(noMutex As UByte = 0)
	If noMutex = 0 Then list_mutex = MutexCreate() 
End Constructor

Destructor list_type
	MutexLock list_mutex
	MutexUnLock list_mutex
	MutexDestroy list_mutex
End Destructor


Sub list_type.add(data_item As utilUDT Ptr,DisableRemove As Integer=0)
	

	If data_item=0 Then Return
	MutexLock list_mutex

	Dim As list_item_type Ptr item

	itemCount+=1

	item=data2list(data_item)
'MutexUnLock list_mutex
'	Return
	If DisableRemove=0 Then
		MutexUnLock list_mutex
		remove(data_item,1)
		MutexLock list_mutex
	EndIf
	'If DisableRemove=2 Then remove(data_item,1)

	
	If (start=0 And ende=0) Then
		start=item
		ende=item
		MutexUnLock list_mutex
		return
	EndIf

	If ende<>0 Then
		item->front=ende
		ende->tail=item
	EndIf
	ende=item
	MutexUnLock list_mutex
End Sub

Sub list_type.add(list as list_type Ptr,noDelete As Integer=0)
	if list = 0 then Return
	If list->itemCount = 0 Then Return
	
	If noDelete = 0 then
		MutexLock list_mutex
		MutexLock list->list_mutex
		if this.ende<>0 then
			this.ende->tail = list->start
			this.ende = list->ende
			this.itemcount += list->itemcount
		else
			this.start = list->start
			this.ende = list->ende
			this.itemcount += list->itemcount
		end if
		MutexUnLock list_mutex
		MutexUnLock list->list_mutex
		Delete list
	Else
		list->Reset
		Dim As utilUDT Ptr tmp
		Do
			tmp = list->getItem
			If tmp<>0 Then
				this.add(tmp,1)
			EndIf			
		Loop Until tmp = 0
		
		
	End if
end sub

Sub list_type.addFront(data_item As utilUDT Ptr,DisableRemove As Integer=0)
	

	If data_item=0 Then Return
	MutexLock list_mutex

	Dim As list_item_type Ptr item

	itemCount+=1

	item=data2list(data_item)
'MutexUnLock list_mutex
'	Return
	If DisableRemove=0 Then
		MutexUnLock list_mutex
		remove(data_item,1)
		MutexLock list_mutex
	EndIf
	'If DisableRemove=2 Then remove(data_item,1)

	
	If (start=0 And ende=0) Then
		start=item
		ende=item
		MutexUnLock list_mutex
		return
	EndIf

	If start<>0 Then
		item->tail=start
		start->front=item
	EndIf
	If set = start Then set = item
	start=item
	
	MutexUnLock list_mutex
End Sub


Sub list_type.clear(DisableHeadDelete As Byte=0)
	MutexLock list_mutex
	Dim As list_item_type Ptr tmp
	If set=0 And start=0 And ende=0 Then MutexUnLock list_mutex:Return
	this.Reset(1)
	If set->head=0 Then MutexUnLock list_mutex:Return
	If set=0 Then MutexUnLock list_mutex:Return
	itemCount=0
	Do
		If DisableHeadDelete=0 Then
			If set->head <> 0 Then delete set->head
		Else
			set->head=0
		EndIf
		tmp=set->tail
		Delete set
		set=tmp	
	Loop Until (set=0)
	start=0
	ende=0
	MutexUnLock list_mutex
End Sub

Sub list_type.remove(item As utilUDT Ptr,DisableHeadDelete As Byte=0)
	MutexLock list_mutex
	Dim As list_item_type ptr tmp_old
	If set=0 And start=0 And ende=0 Then MutexUnLock list_mutex: Return
	this.Reset(1)
	If set->head=0 Then MutexUnLock list_mutex: Return
	If set=0 Then MutexUnLock list_mutex: Return
	
	Do

		If set->head=0 Then MutexUnLock list_mutex: Return
	
		If (set->head->equals(item)=1) Then
			If set=start Then
				If start=ende Then ende=0
				start=set->tail
				If start<>0 Then start->front=0
				If DisableHeadDelete=0 Then Delete set->head
				Delete set	
				set=0
				'start=0
				itemCount-=1
				MutexUnLock list_mutex
				return
			Else
				tmp_old->tail=set->tail
				If set->tail<>0 then set->tail->front=tmp_old
				If ende = set Then ende = set->front
				If DisableHeadDelete=0 Then Delete set->head
				Delete set
				set=0
				itemCount-=1
				MutexUnLock list_mutex
				Return
			EndIf		
		EndIf
		tmp_old=set
		set=set->tail	
	Loop Until (set=0)
	MutexUnLock list_mutex
End Sub

Sub list_type.remove_rec(item As utilUDT Ptr,set As list_item_type ptr,last As list_item_type Ptr)
	'mutex fehlt!
	Return 
	/'
	If set=0 Then Return
	If (set->head->id=item->id) Then
		
		If last=0 Then
			start=set->tail
			
		Else
			last->tail=set->tail
		EndIf
		
		
		If set->tail=0 Then ende=0
		If set=start Then start=set->tail
		Delete set	
		set=0
		return
		
	EndIf
	remove_rec(item,set->tail,set)
	'/
End Sub

Function list_type.data2list(item As utilUDT Ptr)  As list_item_type Ptr
	Dim As list_item_type ptr tmpPTR
	tmpPTR = New list_item_type
	tmpPTR->head=item
	
	Return tmpPTR
	
End Function

Sub list_type.out
	MutexLock list_mutex
	out_rec(start)
	MutexUnLock list_mutex
End Sub
Sub list_type.out_rec(set As list_item_type Ptr)
	If set=0 Then Return
	If set->head=0 Then Return
	Print set->head->toString
	Out_rec(set->tail)	
End Sub

Sub list_type.reset(noMutex As UByte=0)
	If noMutex=0 Then mutexLock list_mutex
	set=start
	If noMutex=0 Then MutexUnLock list_mutex
End Sub

Sub list_type.resetB(noMutex As UByte=0)
	If noMutex=0 Then mutexLock list_mutex
	set=ende
	If noMutex=0 Then MutexUnLock list_mutex
End Sub

Function list_type.getItem(backward As byte=0,index As UInteger=0) As utilUDT Ptr
	MutexLock list_mutex
	While(index>0 And set<>0)
		If backward=0 Then
			set=set->tail
		Else
			set=set->front			
		EndIf
	Wend
	
	If set=0 Then MutexUnLock list_mutex: Return 0
	Dim As utilUDT Ptr tmp	
		tmp=set->head
		If backward=0 Then
			set=set->tail
		Else
			set=set->front			
		EndIf
	MutexUnLock list_mutex
	Return tmp

End Function


Function list_type.search(item As utilUDT Ptr)As utilUDT Ptr
	If item=0 Then Return 0
	MutexLock list_mutex
	If set=0 And start=0 And ende=0 Then MutexUnLock list_mutex: Return  0
	Dim As list_item_type Ptr tmp=set
	this.Reset(1)
	Do
		If (set->head->equals(item)=1) Then
			Var tmpReturn = set->head
			MutexUnLock list_mutex
			Return tmpReturn
		EndIf
		set=set->tail
	Loop Until (set=0)
	set=tmp
	MutexUnLock list_mutex
	Return 0
End Function

Sub list_type.execute
	MutexLock list_mutex  
	this.Reset(1)
	If set=0 or start=0 or ende=0 Then MutexUnLock list_mutex: Return
	Do
		If set->head<>0 Then 
			Var tmp = set->head
			MutexUnLock list_mutex 
			tmp->todo
			MutexLock list_mutex
		EndIf
		If set<>0 Then set=set->tail
	Loop Until (set=0)
	MutexUnLock list_mutex
End Sub

Function list_Type.lswap(item1 As utilUDT Ptr,item2 As utilUDT Ptr) As Byte
	if item1 = 0 then return 0
	if item2 = 0 then return 0
	MutexLock list_mutex
	If item1=item2 Then MutexUnLock list_mutex: Return 0
	
	If set=0 And start=0 And ende=0 Then MutexUnLock list_mutex: Return 0
	Dim As list_item_type Ptr tmp1=0,tmp2=0,tmp3=set 
	this.Reset(1)
	If set=0 Then MutexUnLock list_mutex: Return 0
	Do
		If set->head=item1 Then tmp1=set
		If set->head=item2 Then tmp2=set
		set=set->tail
	Loop Until (set=0)
	If tmp1=0 Or tmp2=0 Then MutexUnLock list_mutex: Return 0
	tmp1->head=item2
	tmp2->head=item1
	set=tmp3
	MutexUnLock list_mutex
	Return 1
End Function

Randomize Timer


Type list_sub_search_list_type extends utilUDT
	As list_item_type Ptr start
	As list_item_type Ptr ende
	Declare Constructor(s As list_item_type Ptr,e As list_item_type Ptr)
End Type

Constructor list_sub_search_list_type(s As list_item_type Ptr,e As list_item_type Ptr)
	start = s
	ende = e
End Constructor

Sub list_type.sort
	MutexLock list_mutex
	If itemcount = 0 Or ende = 0 Or start = 0 Then MutexUnLock list_mutex : Return
	Dim As list_item_type Ptr currentItem,pivot,finalStart,finalEnde
	Dim As Byte modus = 0 ' 0: first = last => only 1 element,return ; 1: pivot is last element; -1: pivot is first element
	Dim As Byte ElementModus
	Dim As Byte newElement = 0
	Dim As list_type SubList
	Dim As list_sub_search_list_type Ptr SList
	
	SubList.add(New list_sub_search_list_type(this.start,this.ende))
	
	SubList.reset
	Do
		SList = Cast(list_sub_search_list_type Ptr,SubList.set->head)
		If SList <> 0 Then
		
			this.start = SList->start
			this.ende = SList->ende
			modus = start->head->compareTo(ende->head)
			If modus=1 Then
				pivot = ende
				this.resetB(1)
				Do
					currentItem = set->front
					set = currentItem
					If currentItem <> 0 Then
						If currentItem->head = 0 Then Return 'error WTF no head element in list!
						ElementModus = currentItem->head->compareTo(pivot->head)

						If ElementModus <> -1 then
							Var tmpTail = currentItem->tail
							Var tmpFront = currentItem->front
							If tmpTail<>0 Then tmpTail->front = tmpFront
							If tmpFront<>0 Then tmpFront->tail = tmpTail
							
							set = tmpTail
						
							If currentItem = start Then start = tmpTail

							currentItem->front = ende
							currentItem->tail = ende->tail
							ende->tail = currentItem
							ende = currentItem

						EndIf	
						
					EndIf	
				Loop Until currentItem = 0
			Else
				pivot = start
				this.reset(1)
				do 
					currentItem = set->tail
					set = currentItem
					
					If currentItem<>0 Then		
						
						If currentItem->head = 0 Then Return 'error WTF no head element in list!
						ElementModus = currentItem->head->compareTo(pivot->head)
			
						If ElementModus <> 1 then
							Var tmpTail = currentItem->tail
							Var tmpFront = currentItem->front
							If tmpTail<>0 Then tmpTail->front = tmpFront
							If tmpFront<>0 Then tmpFront->tail = tmpTail
							
							set = tmpFront
							
							If currentItem = ende Then ende = tmpFront
							
							currentItem->tail = start
							currentItem->front = start->front
							start->front = currentItem
							start = currentItem
						EndIf	
						
					EndIf	
		
				Loop Until currentItem = 0 Or set = 0
		EndIf
		
			SList->start = start
			SList->ende = ende
			
			If start <> pivot Then
				Var tmp = new list_item_type 
				tmp->head = New list_sub_search_list_type(this.start,pivot->front)
				
				If pivot->front<>0 Then pivot->front->tail = 0
				this.start->front = 0
				tmp->tail = SubList.set
				tmp->front = SubList.set->front
				SubList.set->front = tmp
				If tmp->front<>0 Then
					tmp->front->tail = tmp
				Else
					SubList.start = tmp
				EndIf
			EndIf
						
			If ende <> pivot Then
				Var tmp = new list_item_type 
				tmp->head = New list_sub_search_list_type(pivot->tail,this.ende)
				If pivot->tail<>0 Then pivot->tail->front = 0
				this.ende->tail = 0
				tmp->front = SubList.set
				tmp->tail = SubList.set->tail
				
				SubList.set->tail = tmp
				If tmp->tail<>0 Then
					tmp->tail->front = tmp
				Else
					SubList.ende = tmp
				EndIf
			EndIf
			
			
			If start = pivot And ende = pivot Then
				If finalStart = 0 Then finalStart = pivot
				if finalEnde <> 0 then 
					finalEnde->tail = pivot
					pivot->front = finalEnde
				EndIf
				finalEnde = pivot
			else
				pivot->tail = 0
				pivot->front = 0
				Var tmp  = New list_item_type
				tmp->head = New list_sub_search_list_type(pivot,pivot)
				tmp->front = SubList.set
				tmp->tail = SubList.set->tail
				SubList.set->tail = tmp
				If tmp->tail<>0 Then
					tmp->tail->front = tmp
				Else
					SubList.ende = tmp
				EndIf
			EndIf

			Var tmpTail = SubList.set->tail
			Var tmpFront = SubList.set->front
			
			If tmpTail<>0 Then tmpTail->front = tmpFront
			If tmpFront<>0 Then tmpFront->tail = tmpTail
			
			If SubList.start = SubList.set Then SubList.start = SubList.set->tail
			If SubList.ende = SubList.set Then SubList.ende = SubList.set->front

			Delete SubList.set->head
			Delete SubList.set
			SubList.set = 0
			SubList.Reset
		End if
	Loop Until SList = 0 Or SubList.set = 0
	
	this.start = finalStart
	this.ende = finalEnde
	
	MutexUnLock list_mutex
End Sub
/' SORT DEMO
Type test extends utilUDT
	As Integer x
	Declare Constructor(x As Integer)
	Declare Function compareTo(o As utilUDT Ptr) As Integer
	Declare Function toString As String
End Type

Constructor test(x As Integer)
	this.x = x
End Constructor

Function test.compareTo(o As utilUDT Ptr) As Integer
	If o = 0 Then Return 0
	Var tmp = Cast(test Ptr,o)
	If tmp = 0 Then Return 0
	If this.x>tmp->x Then Return 1
	If this.x<tmp->x Then Return -1
	Return 0
End Function

Function test.toString As String
	Return ":>" + Str(x)
End Function

Dim As list_type tmp
For i As Integer = 1 To 10
tmp.add(New test(Int(Rnd*100)+1),1)
Next

tmp.out
tmp.sort
Print "---------"
tmp.out
sleep
'/