#Include Once "../util/util.bas"
#Include Once "../store/store.bas"


Dim As protocolUDT Ptr clientAction
function clientAction_function(ndata As networkData ptr,nclient as clientUDT ptr) As UByte
	If nclient = 0 Or ndata = 0 Then Return 2
	nclient->actionList.add(New clientActionUDT(ndata->V_INTEGERDATA,Cvi(Mid(ndata->V_STRINGDATA,1,SizeOf(uinteger))),Cvi(Mid(ndata->V_STRINGDATA,1+SizeOf(uinteger),1+(SizeOf(UInteger) Shl 1)))),1)
		 
	'check_authstage
	
	
	'nclient->authstage = 1
	'authstage2->send(ndata->V_TSNEID,0,0,"test",0,0) 'TBD!
	'nclient->username = ndata->V_STRINGDATA
	Return 1
End Function

clientAction = New protocolUDT("clientAction",@clientAction_function,NORMAL)
clientAction->noreply = 1
clientAction->onlyServer = 1
