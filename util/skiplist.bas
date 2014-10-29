#Include Once "utilUDT.bas"
#Include Once "linklist.bas"

Type skiplistUDT extends utilUDT
	As utilUDT ptr item
	As list_item_type ptr item_1
	As list_item_type ptr item_10
	As list_item_type ptr item_100
	As list_item_type ptr item_1000
	
	Declare Constructor (item As utilUDT Ptr,item_1 As list_item_type Ptr,item_10 As list_item_type Ptr,item_100 As list_item_type Ptr,item_1000 As list_item_type Ptr)
	Declare virtual Function toString As String
End Type

Constructor skiplistUDT(item As utilUDT Ptr,item_1 As list_item_type Ptr,item_10 As list_item_type Ptr,item_100 As list_item_type Ptr,item_1000 As list_item_type Ptr)
	this.item=item	
	this.item_1=item_1
	this.item_10=item_10
	this.item_100=item_100
	this.item_1000=item_1000	
End Constructor

Function skiplistUDT.toString As String
	If item=0 Then Return ""
	Return item->toString
End Function

Type skiplist
	As Integer itemCount

	As list_type item
	As list_type item_10
	As list_type item_100
	As list_type item_1000
	
	Declare Sub Add(itemPTR As utilUDT Ptr)
	Declare Function search(item As utilUDT Ptr) As utilUDT Ptr
End Type


Sub skiplist.Add(itemPTR As utilUDT ptr)
	Dim As list_item_type ptr item_1PTR
	Dim As list_item_type ptr item_10PTR
	Dim As list_item_type ptr item_100PTR
	Dim As list_item_type ptr item_1000PTR
	
 	itemCount+=1
 	
 	item.add(itemPTR,1)
 	item_1PTR=item.ende
 	If itemCount Mod 10 = 0 Then item_10.add(New skiplistUDT(itemPTR,item_1PTR,item_10PTR,item_100PTR,item_1000PTR),1)
 	item_10PTR=item_10.ende
 	If itemCount Mod 100 = 0 Then item_100.add(New skiplistUDT(itemPTR,item_1PTR,item_10PTR,item_100PTR,item_1000PTR),1)
 	item_100PTR=item_100.ende
 	If itemCount Mod 1000 = 0 Then item_1000.add(New skiplistUDT(itemPTR,item_1PTR,item_10PTR,item_100PTR,item_1000PTR),1)
 	item_1000PTR=item_1000.ende
 	
End Sub

Function skiplist.search(item As utilUDT Ptr) As utilUDT Ptr
	Dim As Byte tmp_return
	Dim As utilUDT Ptr tmp 

	Dim As utilUDT Ptr tmp_1000 
	Dim As utilUDT Ptr tmp_100 
	Dim As utilUDT Ptr tmp_10 
	
	item_1000.reset
	Do
		tmp=item_1000.getItem
		If tmp<>0 Then
			tmp_return=Cast(skiplistUDT Ptr,tmp)->item->compareTo(item) 
			If tmp_return=0 Then Return tmp
			If tmp_return=-1 Then Exit Do		
			tmp_1000=tmp
		End If
	Loop Until tmp=0
	item_100.reset
	If tmp_1000<>0 Then item_100.set=Cast(skiplistUDT Ptr,tmp_1000)->item_100
	Do
		tmp=item_100.getItem
		If tmp<>0 Then
			tmp_return=Cast(skiplistUDT Ptr,tmp)->item->compareTo(item)
			If tmp_return=0 Then Return tmp
			If tmp_return=-1 Then Exit Do		
			tmp_100=tmp
		End if
	Loop Until tmp=0
	item_10.reset
	If tmp_100<>0 Then item_10.set=Cast(skiplistUDT Ptr,tmp_100)->item_10
	
	Do
		tmp=item_10.getItem
		If tmp<>0 Then
			tmp_return=Cast(skiplistUDT Ptr,tmp)->item->compareTo(item)
			If tmp_return=0 Then Return tmp
			If tmp_return=-1 Then Exit Do		
			tmp_10=tmp
		End if
	Loop Until tmp=0
	
	this.item.reset
	If tmp_10<>0 Then this.item.set=Cast(skiplistUDT Ptr,tmp_10)->item_1
	
	Do
		tmp=item_10.getItem
		If tmp<>0 Then
			tmp_return=Cast(skiplistUDT Ptr,tmp)->item->compareTo(item)
			If tmp_return=0 Then Return tmp
		End if
	Loop Until tmp=0
	Return 0
End Function


