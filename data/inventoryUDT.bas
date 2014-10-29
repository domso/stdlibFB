#Include Once "../util/util.bas"
#Include Once "itemUDT.bas"

Type inventoryUDT extends utilUDT
	As itemUDT item_array(1 To 100)
	As list_type item
	Declare Sub save
	Declare Sub load 
End Type

Sub inventoryUDT.save
	For ii As Integer = 1 To UBound(item_array)
		item_array(ii).id=0
	Next
	Dim As Integer ii=1
	Dim As utilUDT Ptr it
	Do
		it=item.getItem
		If it<>0 Then
			item_array(ii)=*Cast(itemUDT Ptr,it)
			ii+=1
			If ii>UBound(item_array) Then return
		EndIf
	Loop Until it = 0
	
	
End Sub

Sub inventoryUDT.load
	For ii As Integer = 1 To UBound(item_array)
		If item_array(ii).isEmpty=1 Then
			item.add(@item_array(ii),1)
		EndIf
	Next
	
End Sub

