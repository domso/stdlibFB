#Include Once "../util/util.bas"
#Include Once "networkData.bas"

Declare Function getProtocolName(id As uinteger) As String

Type networkMSG extends utilUDT
	Private:
		As UByte msgState
		As UByte protocol
		As UByte errorType '0 = no error | 1 = permission-error | 2 = action-error | 3 = unknown-error
		As String net_msg
	Public:
		Declare Constructor(item As networkData ptr)
		Declare Constructor(item As String,msgState As UByte)
		Declare Constructor(protocol as Ubyte,msgState As UByte)
		Declare Function toString As String
		Declare Function isError As UByte
		Declare Function isSuccess As UByte
		Declare virtual Function equals(o As utilUDT Ptr) As Integer
End Type

Constructor networkMSG(item As networkData ptr)
	If item<>0 Then
		If item->V_STATE = 0 Then
			msgState = 1
			protocol = item->V_STATE_2
			net_msg = "[SERVER][SUCCESS] Protocol: "+getProtocolName(protocol)
		Else
			errorType = item->V_STATE
			msgState = 0	
			protocol = item->V_STATE_2
			If errorType = 1 Then
				net_msg = "[SERVER][ERROR] Permission denied! Protocol: "+getProtocolName(protocol)
			elseIf errorType = 2 Then
				net_msg = "[SERVER][ERROR] Action failed! Protocol: "+getProtocolName(protocol)
			Else
				net_msg = "[SERVER][ERROR] Unknown reason! Protocol: "+getProtocolName(protocol)
			EndIf
			
		EndIf
	EndIf
End Constructor

Constructor networkMSG(item As String,msgState As UByte)
	net_msg = "[CLIENT]"
	If msgState=0 Then net_msg += "[ERROR]"
	net_msg += item
	this.msgState = msgState
End Constructor

Constructor networkMSG(protocol as Ubyte,msgState As UByte)
	this.protocol = protocol
	this.msgState = msgState
end constructor

Function networkMSG.toString As String
	Return net_msg
End Function

Function networkMSG.isError As UByte
	If msgState = 0 Then Return 1
	Return 0
End Function

Function networkMSG.isSuccess As UByte
	Return msgState
End Function

Function networkMSG.equals(o As utilUDT Ptr) As Integer
	if o = 0 then return 0
	if this.protocol = cast(networkMSG ptr,o)->protocol then
		if this.msgState = cast(networkMSG ptr,o)->msgState then
			return 1
		end if
	end if
	return 0
end function
