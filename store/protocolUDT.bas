#Include Once "../util/util.bas"
#Include Once "networkData.bas"
#Include Once "clientUDT.bas"
#Include Once "permissionUDT.bas"
#Include Once "networkMSG.bas"
#Include Once "networkUDT.bas"


Dim Shared As idUDT protocolUDT_ID
Dim Shared As list_type protocolMSGList
Dim Shared As hashTableUDT protocolTable = 10

Type protocolUDT extends utilUDT
	Private:
		As permissionUDT Ptr permission
			
	Public:
		As UInteger id
		As UByte useAction=0,onlyServer=0,onlyClient=0,noReply=0
		As function(As networkData Ptr=0,as clientUDT ptr=0) As UBYTE action
		As String titel
		Declare Constructor(titel As String,action As Any Ptr,Rights As UByte=NORMAL)
		Declare Destructor
		
		Declare virtual Function equals(o As utilUDT Ptr) As Integer
		Declare virtual Function toString As String
		Declare Function getPermission As permissionUDT Ptr
		Declare virtual Function Send(V_TSNEID as UInteger,V_STATE As UByte,V_STATE_2 As UByte,V_STRINGDATA as String,V_INTEGERDATA As integer,V_DOUBLEDATA As Double) As UByte 
		Declare virtual Function getSuccess as Ubyte
		Declare virtual Function getError as UByte
		
		Declare Static Function getProtocol(id As UInteger) As protocolUDT ptr
		Declare Static Function getProtocolName(id As UInteger) As String
End Type


Constructor protocolUDT(titel As String,action As Any Ptr,Rights As UByte=NORMAL)
	this.action = action
	useAction = 1
	this.titel = titel
	this.id = protocolUDT_ID.getNext
	this.permission = New permissionUDT(rights)
	protocolTable.add(this.id,@This)

End Constructor

Destructor protocolUDT
	protocolUDT_ID.freeID(id)
	If permission<>0 then
		Delete permission
	End If
End Destructor

Function protocolUDT.equals(o As utilUDT Ptr) As Integer
	If o = 0 Then Return 0
	If Cast(protocolUDT Ptr,o)->id = this.id Then Return 1
	Return 0
End Function

Function protocolUDT.toString As String
	If useAction Then
		Return "Protocol: '"+titel+"' --> 'sub'"	
	EndIf
End Function

Function protocolUDT.getPermission As permissionUDT Ptr
	Return permission
End Function

Function protocolUDT.Send(V_TSNEID as UInteger,V_STATE As UByte,V_STATE_2 As UByte,V_STRINGDATA as String,V_INTEGERDATA As integer,V_DOUBLEDATA As Double) As UByte
	Return network.Send(New networkData(V_TSNEID,V_STATE,V_STATE_2,this.id,V_STRINGDATA,V_INTEGERDATA,V_DOUBLEDATA),1)
End Function

Function protocolUDT.getSuccess as ubyte
	dim as networkMSG ptr tmp = new networkMSG(this.id,1)
	Dim as networkMSG ptr tmp2 = cast(networkMSG ptr,protocolMSGList.search(tmp))
	delete tmp
	if tmp2 <>0 then
		protocolMSGList.remove(tmp)
		return 1
	end if
	return 0
end function

Function protocolUDT.getError as ubyte
	dim as networkMSG ptr tmp = new networkMSG(this.id,0)
	
	Dim as networkMSG ptr tmp2 = cast(networkMSG ptr,protocolMSGList.search(tmp))
	delete tmp
	
	if tmp2 <>0 then
		protocolMSGList.remove(tmp)
		return 1
	end if
	return 0
end function

Function protocolUDT.getProtocol(id As UInteger) As protocolUDT Ptr
	Return Cast(protocolUDT Ptr,protocolTable.get(id))
End Function

Function protocolUDT.getProtocolName(id As uinteger) As String
	Dim As protocolUDT Ptr tmp = getProtocol(id)
	If tmp = 0 Then Return ""
	Return tmp->titel
End Function

Function getProtocolName(id As uinteger) As String
	Return protocolUDT.getProtocolName(id)
End Function


Function useProtocol_internal(item As networkData Ptr,client As clientUDT ptr) As UByte
	If item = 0 Then Return 4
	'If client = 0 Then Return 3

	If item->V_TYPE=0 Then
		'success error ?
		protocolMSGList.add(New networkMSG(item),1)
		Return 4
	EndIf

	Dim As protocolUDT Ptr tmp2 =Cast(protocolUDT Ptr,protocolTable.get(item->V_TYPE)) 'protocolUDT.getProtocol(item->V_TYPE)
	If tmp2=0 Then Return 3

	If tmp2->onlyServer Then
		If network.IsServer=0 Then Return 3
	EndIf
	If tmp2->onlyClient Then
		If network.IsServer=1 Then Return 3
	EndIf

	'If tmp2->getPermission = 1 Then Return 1
	
	If client <> 0 then 
		If client->getRights->check(tmp2->getPermission) Then
			Return 1
		EndIf
	EndIf
	
	If tmp2->useAction Then
		If tmp2->action(item,client)=1 Then 
			If tmp2->noReply Then Return 4
			Return 0
		EndIf
		Return 2

	EndIf


	Return 1
End Function

Sub useProtocol(item As networkData Ptr,client As clientUDT ptr)
	Dim As UByte tmp = useProtocol_internal(item,client)
	If tmp = 4 Then Return '??
	
	
	network.Send(New networkData(item->V_TSNEID,tmp,item->V_TYPE,0,"",0,0),1)
	Return 
	
End Sub


function foo(x As networkData ptr) As UBYTE
	Print ":::>>" + x->V_STRINGDATA
	Return 1
End function


'
Dim As protocolUDT Ptr tmp = New protocolUDT("GLOBAL_SET_IRGENDWAS_FOOL",@foo)

