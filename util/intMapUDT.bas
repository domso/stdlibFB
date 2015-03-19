#Include Once "utilUDT.bas"
#Include Once "hashtableUDT.bas"


Type intMapUDT extends utilUDT
	Private:
		As hashtableUDT table = 10
	Public:
		Declare Sub store(pre As Integer,post As integer)
		Declare function Get(pre As Integer) As Integer
		Declare Sub free(pre As Integer)
		Declare Sub clear(noHeadDelete As UByte=0)
End Type

Sub intMapUDT.store(pre As Integer,post As integer)
	table.add(pre,Cast(utilUDT Ptr,post))
End Sub

Function intMapUDT.Get(pre As Integer) As Integer
	Return Cast(Integer,table.get(pre))
End Function

Sub intMapUDT.free(pre As Integer)
	table.remove(pre)
End Sub

Sub intMapUDT.Clear(noHeadDelete As UByte=0)
	table.clear(noHeadDelete)
End Sub


Type uintMapUDT extends utilUDT
	Private:
		As hashtableUDT table = 10
	Public:
		Declare Sub store(pre As uinteger,post As UInteger)
		Declare function Get(pre As uinteger) As UInteger
		Declare Sub free(pre As UInteger)
		Declare Sub clear(noHeadDelete As UByte=0)
End Type

Sub uintMapUDT.store(pre As uinteger,post As UInteger)
	table.add(pre,Cast(utilUDT Ptr,post))
End Sub

Function uintMapUDT.Get(pre As uinteger) As UInteger
	Return Cast(UInteger,table.get(pre))
End Function

Sub uintMapUDT.free(pre As UInteger)
	table.remove(pre)
End Sub

Sub uintMapUDT.Clear(noHeadDelete As UByte=0)
	table.clear(noHeadDelete)
End Sub
