#Include Once "../util/util.bas"
#Include Once "networkData.bas"
#Include Once "clientUDT.bas"
#Include Once "permissionUDT.bas"
#Include Once "networkMSG.bas"
#Include Once "networkUDT.bas"

Dim Shared As list_type protocolList
Dim Shared As list_type protocolMSGList

Type protocolUDT extends utilUDT
	Private:
		As permissionUDT Ptr permission
	Public:
		As UByte useAction=0,id,onlyServer=0,onlyClient=0,noReply=0
		As function(As networkData Ptr=0,as clientUDT ptr=0) As UBYTE action
		As String titel
		Declare Constructor(titel As String,id As UByte,action As Any Ptr,Rights As UByte=NORMAL,noList As UByte=0)
		Declare Destructor
		
		Declare virtual Function equals(o As utilUDT Ptr) As Integer
		Declare virtual Function toString As String
		Declare Function getPermission As permissionUDT Ptr
		Declare virtual Function Send(V_TSNEID as UInteger,V_STATE As UByte,V_STATE_2 As UByte,V_STRINGDATA as String,V_INTEGERDATA As integer,V_DOUBLEDATA As Double) As UByte 
		Declare virtual Function getSuccess as Ubyte
		Declare virtual Function getError as Ubyte
End Type

Constructor protocolUDT(titel As String,id As UByte,action As Any Ptr,Rights As UByte=NORMAL,noList As UByte=0)
	this.action = action
	useAction = 1
	this.titel = titel
	this.id = id
	this.permission = New permissionUDT(rights)
	
	If noList=0 Then 
		Dim As protocolUDT Ptr tmp = Cast(protocolUDT Ptr,protocolList.search(@this))
		if tmp <> 0 then
			FB_CUSTOMERROR_STRING = "Duplicated protocol id between "+titel+" and "+tmp->titel+"!"
			FB_CUSTOMERROR(*erfn(),*ermn())
		end if
		protocolList.add(@This,1)
	end if
End Constructor

Destructor protocolUDT
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

Function useProtocol_internal(item As networkData Ptr,client As clientUDT ptr) As UByte
	If item = 0 Then Return 4
	If client = 0 Then Return 3
	If item->V_TYPE=0 Then
		'success error ?
		protocolMSGList.add(New networkMSG(item),1)
		Return 4
	EndIf
	
	Dim As protocolUDT Ptr tmp = New protocolUDT("---",item->V_TYPE,0,0,1)
	Delete tmp
	Dim As protocolUDT Ptr tmp2 = Cast(protocolUDT Ptr,protocolList.search(tmp))
	


	If tmp2=0 Then Return 3
	If tmp2->onlyServer Then
		If network.IsServer=0 Then Return 3
	EndIf
	If tmp2->onlyClient Then
		If network.IsServer=1 Then Return 3
	EndIf
		
	
	'If tmp2->getPermission = 1 Then Return 1
	
	
	If client->getRights->check(tmp2->getPermission) Then
		If tmp2->useAction Then
			If tmp2->action(item,client)=1 Then 
				If tmp2->noReply Then Return 4
				Return 0
			EndIf
			Return 2

		EndIf
	EndIf

	Return 1
End Function

Sub useProtocol(item As networkData Ptr,client As clientUDT ptr)
	Dim As UByte tmp = useProtocol_internal(item,client)
	If tmp = 4 Then Return '??
	
	
	network.Send(New networkData(item->V_TSNEID,tmp,item->V_TYPE,0,"",0,0),1)
	Return 
	
End Sub

Function getProtocolName(id As Integer) As String
	Dim As protocolUDT Ptr tmp = New protocolUDT("---",id,0,0,1)
	Dim As protocolUDT Ptr tmp2 = Cast(protocolUDT Ptr,protocolList.search(tmp))
	Delete tmp
	If tmp2 = 0 Then Return "PROTOCOL NOT FOUND!"
	Return tmp2->titel	
End Function


function foo(x As networkData ptr) As UBYTE
	Print ":::>>" + x->V_STRINGDATA
	Return 1
End function


'
Dim As protocolUDT Ptr tmp = New protocolUDT("GLOBAL_SET_IRGENDWAS_FOOL",1,@foo)
'Dim As protocolUDT Ptr tmp2 = New protocolUDT("GLOBAL_SET_IRGENDWAS_FOOL2",5,@foo,DEVELOPER)




'Function fooBeep(x As networkData Ptr) As Integer
'	Beep
'	Return 1
'End Function
'tmp = New protocolUDT("keine ahnung doofes protocol",2,@fooBeep)



'
'Print tmp->action(0)
'Print tmp->toString
'sleep

/'

Type GLobalProtocolUDT extends utilUDT
	Declare Sub error_msg(toID As Integer,errorState As Integer)
	Declare Sub success_msg(toID As Integer,successState As Integer)

	Declare Function error_string(errorState As Integer) As String
	
	Declare Function getError(errorState As Integer) As byte
	Declare Function getSuccess(successState As Integer) As byte
End Type

Sub GLobalProtocolUDT.error_msg(toID As Integer,errorState As Integer)
	network.Send(New networkData(toID,errorState,0,ERROR_MESSAGE,"",0,0),1)	
End Sub
Sub GLobalProtocolUDT.success_msg(toID As Integer,successState As Integer)
	network.Send(New networkData(toID,successState,0,SUCCESS_MESSAGE,"",0,0),1)	
End Sub


Function protocolUDT.getError(errorState As Integer) As Byte
	Dim As utilUDT Ptr tmp=New utilUDT(errorState)
	Dim As utilUDT Ptr search=error_log.Search(tmp)
	Delete tmp
	If search=0 Then Return 0
	
	error_log.remove(tmp)
	Return 1
End Function

Function protocolUDT.getSuccess(successState As Integer) As Byte
	Dim As utilUDT Ptr tmp=New utilUDT(successState)
	Dim As utilUDT Ptr search=success_log.Search(tmp)
	Delete tmp
	If search=0 Then Return 0
	
	success_log.remove(tmp)
	Return 1
End Function

Dim Shared As GLobalProtocolUDT protocol
'/
