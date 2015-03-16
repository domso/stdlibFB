#Include Once "../util/util.bas"
#Include Once "controllerUDT.bas"

Type ConUDTthreadControllUDT extends threadControllUDT
	As UInteger currentID = 1
	Declare Function getID As UInteger
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


Sub controllerThread(tmp As Any Ptr)
	Dim As ConUDTthreadControllUDT Ptr thread
	Dim As UInteger ID
	Dim As controllerUDT ptr controller
	
	thread = Cast(ConUDTthreadControllUDT Ptr,tmp)
	
	Do
		ID = thread->getID
		
		controller = Cast(controllerUDT Ptr,controllerUDT_lock.lock(ID))
		If controller <> 0 Then
			controller->todo
			controllerUDT_lock.unlock(ID,controller)
		EndIf
		
		
	Loop While thread->check
	
End Sub

Function createControllerThread(count As UInteger) As threadControllUDT ptr
	Dim As threadControllUDT Ptr c = New ConUDTthreadControllUDT
	c->setDelay(100)
	For i As Integer = 1 To count
		c->startThread(@controllerThread)
	Next
	Return c
End Function

Var tmpThread = createControllerThread(10)

Var tmpObj = New controllerUDT(0)
tmpObj = New controllerUDT(0)
tmpObj = New controllerUDT(0)
tmpObj = New controllerUDT(0)
tmpObj = New controllerUDT(0)
tmpObj = New controllerUDT(0)
tmpObj = New controllerUDT(0)
tmpObj = New controllerUDT(0)
tmpObj = New controllerUDT(0)
tmpObj = New controllerUDT(0)
tmpObj = New controllerUDT(0)



sleep
tmpThread->Stop
Delete tmpThread





