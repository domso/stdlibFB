#Include Once "../util/util.bas"
#Include Once "../store/store.bas"

#Include Once "objUDT.bas"
#Include Once "controllerUDT.bas"

Dim Shared As stackUDT clientActionStack

Dim As protocolUDT Ptr clientAction
function clientAction_function(ndata As networkData ptr,nclient as clientUDT ptr) As UByte
	If nclient = 0 Or ndata = 0 Then Return 2
	clientActionStack.push(New clientActionUDT(nClient->tsneID,ndata->V_INTEGERDATA,Cvi(Mid(ndata->V_STRINGDATA,1,SizeOf(uinteger))),Cvi(Mid(ndata->V_STRINGDATA,1+SizeOf(uinteger),1+(SizeOf(UInteger) Shl 1)))))
		 
	'check_authstage
	
	
	'nclient->authstage = 1
	'authstage2->send(ndata->V_TSNEID,0,0,"test",0,0) 'TBD!
	'nclient->username = ndata->V_STRINGDATA
	Return 1
End Function

clientAction = New protocolUDT("clientAction",@clientAction_function,NORMAL)
clientAction->noreply = 1
clientAction->onlyServer = 1



Sub clientAction_Thread(tmp As Any Ptr)
	Dim As threadControllUDT Ptr thread
	Dim As clientActionUDT Ptr action
	Dim As clientUDT Ptr client
	Dim As controllerUDT Ptr objController
	Dim As controllerUDT Ptr targetController
	Dim As objUDT Ptr obj
	Dim As objUDT Ptr target
	Dim As objUDT_instance Ptr instance = New objUDT_instance
	
	thread = Cast(threadControllUDT Ptr,tmp)
	If thread = 0 Then return
	Do
		action = Cast(clientActionUDT Ptr,clientActionStack.pop)
		If action <> 0 Then
			If action->clientID <> 0 Then client = network.lockClient(action->clientID)
			If action->objID <> 0 Then objController = Cast(controllerUDT Ptr,controllerUDT_lock.lock(action->objID))
			If action->targetID <> 0 and action->objID <> action->targetID Then targetController = Cast(controllerUDT Ptr,controllerUDT_lock.lock(action->targetID))
			
			If client <> 0 And objController <> 0 Then
				objController->setInstance(instance)
				
				
				obj = objController->getObj
				If objController->getClient = client And obj<>0 Then
					If targetController = 0 Then
						Select case obj->ActionUpdate(action->actionID,0)
							Case Is > 0
								objController->setUpdate
							Case Is < 0
								objController->setRemove
						End Select
					Else
						targetController->setInstance(instance)
						Select case obj->ActionUpdate(action->actionID,targetController->getObj)			
							Case Is > 0
								objController->setUpdate
							Case Is < 0
								objController->setRemove
						End Select			
					EndIf
				End if
			EndIf
			
			If client <> 0 Then network.unlockClient(action->clientID,client)
			If objController <> 0 Then controllerUDT_lock.unlock(action->objID,objController)
			If targetController <> 0 Then controllerUDT_lock.unlock(action->targetID,targetController)
		EndIf
	Loop While thread->check
	Delete instance
End Sub

Function createClientActionThread(count As UInteger) As threadControllUDT ptr
	Dim As threadControllUDT Ptr c = New threadControllUDT
	c->setDelay(10)
	For i As Integer = 1 To count
		c->startThread(@clientAction_Thread)
	Next
	Return c
End Function


