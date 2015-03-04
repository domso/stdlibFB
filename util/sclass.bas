#Include once "utilUDT.bas"
#Include once "variableUDT.bas"


Type sclass extends utilUDT
	Private:
		As Any Ptr data_
		As UInteger attributeCount
	Public:
		As String*10 test		
		Declare Constructor(attributeCount As UInteger)
		Declare Destructor
		Declare Function get(index As UInteger) As Any ptr
End Type

Constructor sclass(attributeCount As UInteger)
	data_ = Allocate(attributeCount * SizeOf(variableUDT ptr))
End Constructor

Destructor sclass
	DeAllocate(data_)
End Destructor

Function sclass.get(index As UInteger) As Any Ptr
	If index >= attributeCount Or data_ = 0 Then Return 0
	Return Cast(variableUDT Ptr,data_ + index)->data 
End Function



Function setAttribute(ClassPTR As Any Ptr,AttributePTR As any Ptr,data_ As any Ptr,size As UInteger) As String
	If ClassPTR = 0 Or AttributePTR = 0 Or data_ = 0 Or size = 0 Then Return ""
	Dim As String tmp = Space(size)
	Dim As Integer ptr_ = Cast(Integer,attributePTR) - Cast(Integer,ClassPTR)
	Print ptr_
	
	
	For i As Integer = 0 To size-1
		tmp[i] = *(Cast(UByte Ptr,AttributePTR)+i) Xor *(Cast(UByte Ptr,data_)+i)
		*(Cast(UByte Ptr,AttributePTR)+i) = *(Cast(UByte Ptr,data_)+i)
	Next
	Return tmp
End Function

Dim As sclass nix = 0
Dim As string tn = "hallo"
Print setAttribute(@nix,@nix.test,@tn,5)
Print nix.test
sleep



