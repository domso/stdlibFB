#Include Once "../util/util.bas"



Type networkData extends utilUDT
	As UInteger V_TSNEID
	As UByte V_TYPE
	As String V_STRINGDATA
	As Integer V_INTEGERDATA
	As Double V_DOUBLEDATA
	
	As UByte V_STATE
	As UByte V_STATE_2
	
	Declare Constructor(V_TSNEID as UInteger,V_STATE As UByte,V_STATE_2 As UByte,V_TYPE As UByte,V_STRINGDATA as String,V_INTEGERDATA As integer,V_DOUBLEDATA As Double)
	Declare Constructor(V_TSNEID as UInteger,V_DATA As String)
	
	Declare Function toString As String
	

End Type

Constructor networkData(V_TSNEID as UInteger,V_STATE As UByte,V_STATE_2 As UByte,V_TYPE As UByte,V_STRINGDATA as String,V_INTEGERDATA As integer,V_DOUBLEDATA As Double)
	this.V_STATE=V_STATE
	this.V_STATE_2=V_STATE_2
	this.V_TSNEID=V_TSNEID
	this.V_TYPE=V_TYPE
	this.V_STRINGDATA=V_STRINGDATA
	this.V_INTEGERDATA=V_INTEGERDATA
	this.V_DOUBLEDATA=V_DOUBLEDATA
End Constructor

Constructor networkData(V_TSNEID as UInteger,V_DATA As String)
	if len(V_DATA)<17 then return
	Dim As Integer sizeoflen=Asc(V_DATA,16)
	this.V_TSNEID=V_TSNEID
	V_TYPE=Asc(Mid(V_DATA,1,1))
	V_INTEGERDATA=cvi(Mid(V_DATA,2,4))
	V_DOUBLEDATA=cvd(Mid(V_DATA,6,8))
	V_STATE=asc(Mid(V_DATA,14,1))
	V_STATE_2=Asc(Mid(V_DATA,15,1))
		
	
	V_STRINGDATA=Mid(V_DATA,17+sizeoflen,Val(Mid(V_DATA,17,SizeOfLen))) 'Mid(V_DATA,23,Asc(  ))
End Constructor


Function networkData.toString As String
	Dim As String tmp=Str(Len(V_STRINGDATA))
	
	Return Chr(V_TYPE)+Mki(V_INTEGERDATA)+Mkd(V_DOUBLEDATA)+Chr(V_STATE)+Chr(V_STATE_2)+chr(Len(tmp))+tmp+V_STRINGDATA

End Function
