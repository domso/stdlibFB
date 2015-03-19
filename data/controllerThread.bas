#Include Once "../util/util.bas"
#Include Once "../store/store.bas"
#Include Once "controllerUDT.bas"
#Include Once "clientOBJ.bas"

Type ConUDTthreadControllUDT extends threadControllUDT
	As UInteger currentID = 1
	As Double lastTime
	Declare Function getID As UInteger
	Declare Function getTime As double
End Type

Function ConUDTthreadControllUDT.getID As UInteger
	Dim As UInteger tmp
	this.Lock()
	tmp = currentID
	If currentID = controllerUDT_ID.getLast Then
		currentID = 1
	Else
		currentID+=1
	EndIf
	this.unLock()
	Return tmp
End Function

Function ConUDTthreadControllUDT.getTime As Double
	Dim As Double tmp
	this.lock()
		Do
			tmp = timer
		Loop Until tmp>lastTime
		lastTime = tmp
	this.unlock()
	Return tmp
End Function

Sub controllerThread(tmp As Any Ptr)
	Dim As ConUDTthreadControllUDT Ptr thread
	Dim As UInteger ID,i
	Dim As UInteger maxClientID,ClientID
	Dim As controllerUDT ptr controller
	Dim As clientUDT Ptr client
	Dim As Double maxTime
	thread = Cast(ConUDTthreadControllUDT Ptr,tmp)
	Dim As objUDT_instance Ptr instance = New objUDT_instance
	
	
	Do
		Print "." ;
		ID = thread->getID
		maxTime = 0
		controller = Cast(controllerUDT Ptr,controllerUDT_lock.lock(ID))
		If controller <> 0 Then
			'Print "checkpoint-a"
			controller->setInstance(instance)
			controller->todo
			maxClientID = clientUDT_idUDT.getLast
			For i = 1 To maxClientID
				ClientID = clientUDT_IDmap.get(i)
				client = network.lockClient(clientID) 
				If client <> 0 And clientID <> 0 Then
					If client->world = controller->worldID Then
						If controller->updateTime < client->updateTime Or client->updateTime = 0  Then
							'full - update
							sendObj(clientID,controller->id,controller->parent,controller->getObj)
							If client->updateTime = 0 Then client->updateTime = thread->getTime
							If client->updateTime > maxTime Then maxTime = client->updateTime
						Else
							'diff - update		
							sendObj(clientID,controller->id,controller->parent,controller->getObj,1)
							If client->updateTime > maxTime Then maxTime = client->updateTime		
						EndIf		
						
						
						
					EndIf				
					network.unlockClient(clientID,client)
				EndIf
			Next
			If maxTime <> 0 Then controller->updateTime = maxTime
			'controller->lastTSNE_ID = clientID
			
			controllerUDT_lock.unlock(ID,controller)
			
		EndIf
		
		
	Loop While thread->check
	Delete instance
End Sub

Function createControllerThread(count As UInteger) As threadControllUDT ptr
	Dim As threadControllUDT Ptr c = New ConUDTthreadControllUDT
	c->setDelay(1000)
	For i As Integer = 1 To count
		c->startThread(@controllerThread)
	Next
	Return c
End Function







