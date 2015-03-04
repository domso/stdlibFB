#Include Once "../util/utilUDT.bas"

Type FwdController As controllerUDT

' Enable : 1
' enableTimeUpdate : 2
' enableActionUpdate : 4
' enableGlobalUpdate : 8
 

Type objUDT extends utilUDT
	Private:
		As UByte config
		Static As Any ptr diffArray
		Static As Integer diffArraySize
		Static As Integer objUDTCount
	Public:
		
		Static As FwdController Ptr controller
		
		Declare Constructor(size As Integer)
		Declare Destructor
		
		Declare virtual Function TimeUpdate(diffTime As Integer) As byte
		Declare virtual Function ActionUpdate(actionID As Integer) As byte
		Declare virtual Function GlobalUpdate As byte
		
		Declare Sub set(AttributePTR As any Ptr,data_ As any Ptr,size As UInteger)
		Declare Function packBINDIF As String
		
		Declare Sub Enable
		Declare Sub Disable
		Declare Function isEnable As ubyte
		
		Declare Sub EnableTimeUpdate
		Declare Sub DisableTimeUpdate
		Declare Function isEnableTimeUpdate As UByte
		
		Declare Sub EnableActionUpdate
		Declare Sub DisableActionUpdate
		Declare Function isEnableActionUpdate As UByte
		
		Declare Sub EnableGlobalUpdate
		Declare Sub DisableGlobalUpdate
		Declare Function isEnableGlobalUpdate As UByte
End Type

Dim As Integer objUDT.diffArraySize
Dim As Integer objUDT.objUDTCount
Dim As Any ptr objUDT.diffArray
Dim As FwdController Ptr objUDT.controller

Constructor objUDT(size As Integer)
	this.Enable
	
	base.size = size
	
	If size > diffArraySize Or diffArray = 0 Then
		DeAllocate(diffArray)
		diffArray = Callocate(size)		
		diffArraySize = size
	EndIf
	objUDTCount+=1
	
End Constructor

Destructor objUDT
	objUDTCount-=1
	if objUDTCount = 0 Then
		DeAllocate(diffArray)
		diffArray = 0
	EndIf
End Destructor

Function objUDT.TimeUpdate(diffTime As Integer) As Byte
	Return 0
End Function

Function objUDT.ActionUpdate(actionID As Integer) As Byte
 	Return 0
End Function

Function objUDT.GlobalUpdate As Byte
 	Return 0
End Function

Sub objUDT.set(AttributePTR As any Ptr,data_ As any Ptr,size As UInteger)
	If AttributePTR = 0 Or data_ = 0 Or size = 0  Then Return
	Dim As Integer ptr_ = Cast(Integer,attributePTR) - Cast(Integer,@this)
	'Print ptr_
	
	For i As Integer = 0 To size-1
		*Cast(UByte Ptr,diffArray + ptr_ + i) = *(Cast(UByte Ptr,AttributePTR)+i) Xor *(Cast(UByte Ptr,data_)+i)
		*(Cast(UByte Ptr,AttributePTR)+i) = *(Cast(UByte Ptr,data_)+i)
	Next
End Sub

Function objUDT.packBINDIF As String
	If diffArray = 0 Then Return ""
	
	Dim As UByte tmp2
	Dim As Integer i
	Dim As Integer last
	Dim As String tmp
	tmp=String(size,Chr(0))

	For toString_i As Integer = 0 To size-1
		tmp2 = *Cast(UByte Ptr,diffArray + toString_i)
		If tmp2 Then
			*Cast(UByte Ptr,diffArray + toString_i) = 0
			If tmp[i] Then i+=1
			tmp[i] = tmp2
			last = i
			i+=1
		Else
			If tmp[i]=0 Then i+=1
			If tmp[i]=255 Then i+=2 
			tmp[i]+=1
		EndIf
		If i>=Len(tmp)-1 Then tmp+=String(2,Chr(0))
	Next
	Return Left(tmp,last+1)
End Function


Sub objUDT.Enable
	config = config Or 1
End Sub

Sub objUDT.Disable
	config = config Xor 1
End Sub

Function objUDT.isEnable As ubyte
	If config And 1 Then Return 1
	Return 0
End Function


Sub objUDT.EnableTimeUpdate
	config = config Or 2
End Sub

Sub objUDT.DisableTimeUpdate
	config = config Xor 2
End Sub

Function objUDT.isEnableTimeUpdate As UByte
	If config And 2 Then Return 1
	Return 0
End Function

Sub objUDT.EnableActionUpdate
	config = config Or 4
End Sub

Sub objUDT.DisableActionUpdate
	config = config Xor 4
End Sub

Function objUDT.isEnableActionUpdate As UByte
	If config And 4 Then Return 1
	Return 0
End Function

Sub objUDT.EnableGlobalUpdate
	config = config Or 8
End Sub

Sub objUDT.DisableGlobalUpdate
	config = config Xor 8
End Sub

Function objUDT.isEnableGlobalUpdate As UByte
	If config And 8 Then Return 1
	Return 0
End Function