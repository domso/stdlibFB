#Include Once "utilUDT.bas"
#Include Once "linklist.bas"

Dim Shared As list_type GLOBAL_VARIABLE_LIST

Type variableUDT extends utilUDT
	Private:
		As integer varTyp
	Public:
		As String title
		As any Ptr Data
		
		Declare Constructor(title As String,noList As UByte=0)
		Declare virtual Function toValString As String
		Declare virtual Function toString As String
		Declare virtual Function equals(o As utilUDT Ptr) As Integer
		
		
		Declare Sub setByte '1
		Declare Sub setUByte '2
		Declare Sub setShort '4
		Declare Sub setUShort '8
		Declare Sub setInteger '16
		Declare Sub setUInteger '32
		Declare Sub setLong '64
		Declare Sub setULong '128
		Declare Sub setLongINT '256
		Declare Sub setULongINT '512
		Declare Sub setSingle '1024
		Declare Sub setDouble '2048
		Declare Sub setString '4096
		Declare Sub setUtilUDT '8192
		Declare Sub setList '16384
		Declare Sub setPTR '32768
		
		Declare Function isByte As UByte
		Declare Function isUbyte As UByte
		Declare Function isShort As UByte
		Declare Function isUShort As UByte
		Declare Function isInteger As UByte
		Declare Function isUInteger As UByte
		Declare Function isLong As UByte
		Declare Function isULong As UByte
		Declare Function isLongINT As UByte
		Declare Function isULongINT As UByte
		Declare Function isSingle As UByte
		Declare Function isDouble As UByte
		Declare Function isString As UByte
		Declare Function isUtilUDT As UByte
		Declare Function isList As UByte
		Declare Function isPTR As UByte
		
End Type

Constructor variableUDT(title As String,noList As UByte=0)
	This.title = title
	If noList=0 then
		GLOBAL_VARIABLE_LIST.add(@This,1)
	End if
End Constructor

Function variableUDT.toValString As String
	If Data = 0 Then Return "#ndef"
	'Var tmp = this.data

	If isByte Then
		Return Str(*Cast(Byte ptr,this.data))
	EndIf
	If isUbyte Then
		Return Str(*Cast(UByte ptr,this.data))
	EndIf	
	If isShort Then
		Return Str(*Cast(Short Ptr,this.data))
	EndIf
	If isUShort Then
		Return Str(*Cast(UShort ptr,this.data))
	EndIf		
	If isInteger Then
		Return Str(*Cast(Integer ptr,this.data))
	EndIf
	If isUInteger Then
		Return Str(*Cast(Uinteger ptr,this.data))
	EndIf	
	If isLong Then
		Return Str(*Cast(Long ptr,this.data))
	EndIf
	If isULong Then
		Return Str(*Cast(ULong ptr,this.data))
	EndIf		
	If isLongINT Then
		Return Str(*Cast(LongInt Ptr,this.data))
	EndIf
	If isULongINT Then
		Return Str(*Cast(ULongInt ptr,this.data))
	EndIf	
	If isSingle Then
		Return Str(*Cast(Single ptr,this.data))
	EndIf
	If isDouble Then
		Return Str(*Cast(Double ptr,this.data))
	EndIf		
	If isString Then
		Return Str(*Cast(String ptr,this.data))
	EndIf
	If isUtilUDT Then
		Return Str(*Cast(utilUDT ptr,this.data).toString)
	EndIf	
	If isPTR Then
		Return Str(this.data)
	EndIf	
	
	
	If isList Then
		Return Str(this.data)'"no value for list"'Str(*Cast(list_type ptr,this.data))
	EndIf

	'Return Str(tmp)
End Function

Function variableUDT.toString As String
	Return title+": "+this.toValString 
End Function

Function variableUDT.equals(o As utilUDT Ptr) As Integer
	If o = 0 Then Return 0
	If this.title = Cast(variableUDT Ptr,o)->title Then Return 1
	Return 0
End Function

Sub variableUDT.setByte
	varTyp=1
End Sub

Sub variableUDT.setUByte
	varTyp=2
End Sub

Sub variableUDT.setShort
	varTyp=4
End Sub

Sub variableUDT.setUShort
	varTyp=8
End Sub

Sub variableUDT.setInteger
	varTyp=16
End Sub

Sub variableUDT.setUInteger
	varTyp=32
End Sub

Sub variableUDT.setLong
	varTyp=64
End Sub

Sub variableUDT.setULong
	varTyp=128
End Sub

Sub variableUDT.setLongINT
	varTyp=256
End Sub

Sub variableUDT.setULongINT
	varTyp=512
End Sub

Sub variableUDT.setSingle
	varTyp=1024
End Sub

Sub variableUDT.setDouble
	varTyp=2048
End Sub

Sub variableUDT.setString
	varTyp=4096
End Sub

Sub variableUDT.setUtilUDT
	varTyp=8192
End Sub

Sub variableUDT.setList
	varTyp=16384
End Sub

Sub variableUDT.setPTR
	varTyp=32768
End Sub

Function variableUDT.isByte As UByte
	Return (varTyp And 1)
End Function

Function variableUDT.isUbyte As UByte
	Return (varTyp And 2)Shr 1
End Function

Function variableUDT.isShort As UByte
	Return (varTyp And 4)Shr 2
End Function

Function variableUDT.isUShort As UByte
	Return (varTyp And 8)Shr 3
End Function

Function variableUDT.isInteger As UByte
	Return (varTyp And 16)Shr 4
End Function

Function variableUDT.isUInteger As UByte
	Return (varTyp And 32)Shr 5
End Function

Function variableUDT.isLong As UByte
	Return (varTyp And 64)Shr 6
End Function

Function variableUDT.isULong As UByte
	Return (varTyp And 128)Shr 7
End Function

Function variableUDT.isLongINT As UByte
	Return (varTyp And 256)Shr 8
End Function

Function variableUDT.isULongINT As UByte
	Return (varTyp And 512)Shr 9
End Function

Function variableUDT.isSingle As UByte
	Return (varTyp And 1024)Shr 10
End Function

Function variableUDT.isDouble As UByte
	Return (varTyp And 2048)Shr 11
End Function

Function variableUDT.isString As UByte
	Return (varTyp And 4096)Shr 12
End Function

Function variableUDT.isUtilUDT As UByte
	Return (varTyp And 8192)Shr 13
End Function

Function variableUDT.isList As UByte
	Return (varTyp And 16384)Shr 14
End Function

Function variableUDT.isPTR As UByte
	Return (varTyp And 32768)Shr 15
End Function
