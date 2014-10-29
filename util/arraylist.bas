Type array_data extends object
	As Integer id=0
End Type

Type array_type
	As Integer itemcount,size
	As array_data Ptr Ptr item
	
	Declare Sub Add(item As array_data Ptr)
	Declare Function getItem(index As Integer) As array_data ptr
End Type

Sub array_type.Add(itemdata As array_data Ptr )
	
	itemcount+=1
	
	If this.item=0 Then
		this.item=Allocate(size*itemcount)
	Else
		this.item=ReAllocate(this.item,size*itemcount)		
	EndIf
	
	this.item[itemcount-1]=itemdata
	
	
End Sub

Function array_type.getItem(index As Integer) As array_data ptr
	If index<0 Or index>=itemcount Then Return 0
	Return this.item[index]
End Function
