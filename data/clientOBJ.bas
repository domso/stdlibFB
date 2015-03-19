#Include Once "../util/util.bas"
#Include Once "../store/store.bas"
#Include Once "objUDT.bas"


Dim Shared As protocolUDT Ptr clientObjProtocol
function clientObjProtocol_function(ndata As networkData ptr,nclient as clientUDT ptr) As UByte
	If ndata = 0 Then Return 2
	'clientActionStack.push(New clientActionUDT(nClient->tsneID,ndata->V_INTEGERDATA,Cvi(Mid(ndata->V_STRINGDATA,1,SizeOf(uinteger))),Cvi(Mid(ndata->V_STRINGDATA,1+SizeOf(uinteger),1+(SizeOf(UInteger) Shl 1)))))
	Dim As UInteger ID,parent,size
	Dim As utilUDT Ptr obj
	
	If ndata->V_STATE = 0 then
	
		id = ndata->V_INTEGERDATA
		parent = Cvi(Mid(ndata->V_STRINGDATA,1,SizeOf(uinteger)))
		
		size = Len(ndata->V_STRINGDATA)-4
		obj = Allocate(size)
		obj->size = size
		
		obj->fromBINString(Mid(ndata->V_STRINGDATA,5))
		
		Print "full-update !"
	
	Else
		Print "only update!"
	End if
	'check_authstage
	
	
	'nclient->authstage = 1
	'authstage2->send(ndata->V_TSNEID,0,0,"test",0,0) 'TBD!
	'nclient->username = ndata->V_STRINGDATA
	Return 1
End Function

clientObjProtocol = New protocolUDT("clientObjProtocol",@clientObjProtocol_function,NORMAL)
clientObjProtocol->noreply = 1
clientObjProtocol->onlyClient = 1


Sub sendObj(tsneID As UInteger,ID As UInteger,parent As UInteger,obj As objUDT Ptr,diff As UByte = 0)
	If obj = 0 Then Return
	
	Dim As String tmp,tmp2
	
	If diff = 0 Then
		Dim As UByte Ptr item=Cast(UByte Ptr,Cast(any Ptr,obj))
		Dim As Integer toString_i
		
		If obj->size=0 Then Return
		tmp=Space(obj->size+4)
		For toString_i = SizeOf(Any Ptr) To obj->size-1
			tmp[toString_i + 4 ]=item[toString_i + 4]
		Next
		tmp2 = Mki(parent)
		For toString_i = 0 To 3
			tmp[toString_i] = tmp2[toString_i]
		Next
		
		
	Else
		tmp = obj->packBINDIF
	End if
	clientObjProtocol->send(tsneID,diff,0,tmp,id,0)
	Print ">>"
	
	
	
End Sub
