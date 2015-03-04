#Include once "utilUDT.bas"
#Include Once "linklist.bas"

Type hashtableItemUDT_String extends utilUDT
	As String key
	As utilUDT Ptr data_
	Declare Constructor(key As String,data_ As utilUDT Ptr)
	Declare Function equals(o As utilUDT Ptr) As Integer
End Type

Function hashtableItemUDT_String.equals(o As utilUDT Ptr) As Integer
	If Cast(hashtableItemUDT_String Ptr,o)=0 Then Return 0
	If this.key = Cast(hashtableItemUDT_String Ptr,o)->key Then Return 1
	Return 0
End Function

Constructor hashtableItemUDT_String(key As String,data_ As utilUDT Ptr)
	this.key = key
	this.data_ = Data_
End Constructor

Type hashtableItemUDT_uint extends utilUDT
	As uinteger key
	As utilUDT Ptr data_
	Declare Constructor(key As UInteger,data_ As utilUDT Ptr)
	Declare Function equals(o As utilUDT Ptr) As Integer
End Type

Function hashtableItemUDT_uint.equals(o As utilUDT Ptr) As Integer
	If Cast(hashtableItemUDT_String Ptr,o)=0 Then Return 0
	If this.key = Cast(hashtableItemUDT_uint Ptr,o)->key Then Return 1
	Return 0
End Function

Constructor hashtableItemUDT_uint(key As UInteger,data_ As utilUDT Ptr)
	this.key = key
	this.data_ = Data_
End Constructor


Type hashtableUDT extends utilUDT
	Private:
		As list_type Ptr Ptr Data_ 
		As double load = 0.75
		As UInteger capacity = 0
		As UInteger count = 0
		As UByte noMutex
	Public:
		Declare Constructor(capacity As UInteger,noMutex As UByte=0)
		Declare Destructor
		
		Declare Sub Add(key As String,item As utilUDT Ptr)
		Declare Sub Add(key As uinteger,item As utilUDT Ptr)
		
		Declare Sub remove(key As String)
		Declare Sub remove(key As UInteger)
		
		Declare Function get(key As String) As utilUDT Ptr
		Declare Function get(key As UInteger) As utilUDT Ptr
		
		Declare Sub clear(noHeadDelete As UByte=0)
		
		Declare Sub changeCapacity(factor As Double)
End Type

Constructor hashtableUDT(capacity As UInteger,noMutex As UByte=0)
	this.noMutex = noMutex
	this.capacity = capacity
	Dim As UInteger costs = this.capacity*SizeOf(list_type ptr)
	Data_ = Allocate(this.capacity*SizeOf(list_type ptr))
	
	For i As Integer = 0 To this.capacity-1
		Data_[i] = New list_type(noMutex)
		costs +=SizeOf(list_type)
	Next
	Print costs
End Constructor

Destructor hashtableUDT
	this.clear
	
	For i As Integer = 0 To this.capacity-1
		Delete Data_[i]
	Next
	
	DeAllocate Data_
End Destructor

Sub hashtableUDT.add(key As String,item As utilUDT Ptr)
	Data_[String2Hash(key,capacity)]->Add(New hashtableItemUDT_String(key,item),1)
	count+=1
	If (count/capacity > load) Then
		changeCapacity(1.5)
	EndIf
End Sub

Sub hashtableUDT.add(key As uinteger,item As utilUDT Ptr)
	Data_[key Mod capacity]->Add(New hashtableItemUDT_uint(key,item),1)
	count+=1
	If (count/capacity > load) Then
		changeCapacity(1.5)
	EndIf
End Sub

Sub hashtableUDT.remove(key As String)
	Dim As list_type ptr tmpList = Data_[String2Hash(key,capacity)]
	Dim As hashtableItemUDT_String Ptr tmp = New hashtableItemUDT_String(key,0)
	tmpList->remove(tmp)
	Delete tmp	
End Sub

Sub hashtableUDT.remove(key As uinteger)
	Dim As list_type ptr tmpList = Data_[key Mod capacity]
	Dim As hashtableItemUDT_uint Ptr tmp = New hashtableItemUDT_uint(key,0)
	tmpList->remove(tmp)
	Delete tmp	
End Sub

Function hashtableUDT.get(key As String) As utilUDT Ptr
	Dim As list_type ptr tmpList = Data_[String2Hash(key,capacity)]
	Dim As hashtableItemUDT_String Ptr tmp = New hashtableItemUDT_String(key,0)
	Dim As hashtableItemUDT_String Ptr result = Cast(hashtableItemUDT_String Ptr,tmpList->search(tmp))
	Delete tmp
	If result<>0 Then
		Return result->data_
	EndIf
	Return 0
End Function

Function hashtableUDT.get(key As uinteger) As utilUDT Ptr
	Dim As list_type ptr tmpList = Data_[key Mod capacity]
	Dim As hashtableItemUDT_uint Ptr tmp = New hashtableItemUDT_uint(key,0)
	Dim As hashtableItemUDT_uint Ptr result = Cast(hashtableItemUDT_uint Ptr,tmpList->search(tmp))
	Delete tmp
	If result<>0 Then
		Return result->data_
	EndIf
	Return 0
End Function

Sub hashtableUDT.clear(noHeadDelete As UByte=0)
	For i As Integer = 0 To this.capacity-1
		Data_[i]->Clear(noHeadDelete)
	Next
End Sub

Sub hashtableUDT.changeCapacity(factor As Double)
		Dim As list_type ptr tmpList = New list_type(1)
		Dim As object Ptr item
		For i As Integer = 0 To this.capacity-1
			tmpList->Add(Data_[i])
		Next
		
		capacity = capacity*factor
		DeAllocate Data_
		Data_ = Allocate(this.capacity*SizeOf(list_type ptr))
		For i As Integer = 0 To this.capacity-1
			Data_[i] = New list_type(noMutex)
		Next
		count = tmpList->itemCount
		tmpList->Reset
		Do
			item = tmpList->getItem
			If item <> 0 Then
				If *item Is hashtableItemUDT_String Then
					Data_[String2Hash(Cast(hashtableItemUDT_String Ptr,item)->key,capacity)]->Add(Cast(hashtableItemUDT_String Ptr,item),1)
				Else
					Data_[Cast(hashtableItemUDT_uint Ptr,item)->key Mod capacity]->Add(Cast(hashtableItemUDT_uint Ptr,item),1)					
				EndIf
			End if
		Loop Until item = 0
		tmpList->Clear(1)
		Delete tmpList
End Sub
