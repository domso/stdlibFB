#Include Once "../util/util.bas"

Type itemUDT extends utilUDT
	As String*9 item_name
	As UByte item_type
	As UByte skin
	As UByte weight
	As UByte warmth
	As UByte quality
	As UByte isUse
	'Declare Constructor(world As Integer)
	Declare Function equals(o As utilUDT Ptr) As Integer
End Type

Function itemUDT.equals(o As utilUDT Ptr) As Integer
	If o=0 Then Return 0
	If this.item_name=Cast(itemUDT ptr,o)->item_name And this.item_type=Cast(itemUDT ptr,o)->item_type Then Return 1
	Return 0
End Function