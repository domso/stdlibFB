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
	
	Declare Sub Clear(DisableHeadDelete As Byte=0)
	Declare Sub remove(item As utilUDT Ptr,DisableHeadDelete As Byte=0)
	Declare Sub remove_rec(item As utilUDT Ptr,set As list_item_type ptr,last As list_item_type Ptr)
	Declare Function data2list(item As utilUDT Ptr) As list_item_type Ptr
	Declare Sub out
	Declare Sub out_rec(set As list_item_type ptr)
	
	Declare sub reset
	Declare Function getItem(backward As byte=0) As utilUDT Ptr
	
	
	Declare Function search(item As utilUDT Ptr) As utilUDT Ptr
	
	Declare Function lswap(item1 As utilUDT Ptr,item2 As utilUDT Ptr) As byte
	Declare Sub execute
	Declare Constructor
End Type

Constructor list_type
	list_mutex = MutexCreate()
End Constructor



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
		remove(data_item)
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



Sub list_type.clear(DisableHeadDelete As Byte=0)
	MutexLock list_mutex
	Dim As list_item_type Ptr tmp
	If set=0 And start=0 And ende=0 Then MutexUnLock list_mutex:Return
	this.Reset
	If set->head=0 Then MutexUnLock list_mutex:Return
	If set=0 Then MutexUnLock list_mutex:Return
	itemCount=0
	Do
		If DisableHeadDelete=0 Then
			Delete set->head
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
	this.Reset
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

Sub list_type.reset
	
	set=start	
End Sub

Function list_type.getItem(backward As byte=0) As utilUDT Ptr
	MutexLock list_mutex
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
	this.Reset
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
	this.Reset
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
	
	MutexLock list_mutex
	If item1=item2 Then MutexUnLock list_mutex: Return 0
	If set=0 And start=0 And ende=0 Then MutexUnLock list_mutex: Return 0
	Dim As list_item_type Ptr tmp1=0,tmp2=0,tmp3=set 
	this.Reset
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
