#Include Once "utilUDT.bas"
#Include Once "stackUDT.bas"

Type threadStackItemUDT extends utilUDT
	As Any Ptr threadPTR
	Declare Constructor(threadPTR As Any Ptr)
End Type

Constructor threadStackItemUDT(threadPTR As Any Ptr)
	this.threadPTR = threadPTR
End Constructor



Type threadControllUDT extends utilUDT
	Private:
		As UInteger sleepTime
		As UInteger waitUpdateTime
		As UByte state
		As Any Ptr mutex
		As stackUDT threads
	Public:
		Declare Constructor
		Declare Destructor
		
		Declare Sub Resume ' 0
		Declare Sub Stop   ' 1
		Declare Sub Wait(waitUpdateTime As UInteger = 200)   ' 2
		
		Declare Sub setDelay(delay As UInteger)
		
		Declare Function isRunning As UByte
		Declare Function isStopped As UByte
		Declare Function isWaiting As UByte
		
		Declare Sub lock
		Declare Sub unlock
		
		Declare Function check As UByte
		
		Declare Sub startThread(threadSub As Sub(x As Any Ptr))
End Type

Constructor threadControllUDT
	mutex = mutexcreate
End Constructor

Destructor threadControllUDT
	Stop
	MutexDestroy mutex
End Destructor

Sub threadControllUDT.Resume
	MutexLock mutex
	state = 0
	MutexunLock mutex
End Sub

Sub threadControllUDT.Stop
	Dim As Any Ptr threadHandle
	Dim As threadStackItemUDT Ptr thread
	do
		MutexLock mutex
		If state <> 1 Then state = 1
		thread = Cast(threadStackItemUDT Ptr, threads.pop)
		If thread = 0 Then MutexUnLock mutex : return
		threadHandle = thread->threadPTR
		Delete thread
		MutexunLock mutex
		ThreadWait(threadHandle)
	loop
End Sub

Sub threadControllUDT.Wait(waitUpdateTime As UInteger = 200)
	MutexLock mutex
	state = 2
	this.waitUpdateTime = waitUpdateTime
	MutexunLock mutex
End Sub

Sub threadControllUDT.setDelay(delay As UInteger)
	MutexLock mutex
	this.sleepTime = delay
	MutexUnLock mutex
End Sub

Function threadControllUDT.isRunning As UByte
	MutexLock mutex
	If state = 0 Then MutexunLock mutex : Return 1
	MutexunLock mutex
	Return 0
End Function

Function threadControllUDT.isStopped As UByte
	MutexLock mutex
	If state = 1 Then MutexunLock mutex : Return 1
	MutexunLock mutex
	Return 0
End Function

Function threadControllUDT.isWaiting As UByte
	MutexLock mutex
	If state = 2 Then MutexunLock mutex : Return 1
	MutexunLock mutex
	Return 0
End Function

Sub threadControllUDT.lock
	MutexLock mutex
End Sub

Sub threadControllUDT.unlock
	MutexunLock mutex
End Sub

Function threadControllUDT.check As UByte
	MutexLock mutex
	If sleepTime <> 0 Then
		Dim As UInteger tmpSleep = sleepTime
		MutexunLock mutex
		Sleep tmpSleep,1
		MutexLock mutex
	EndIf
	
	If state = 0 Then MutexunLock mutex : Return 1
	If state = 1 Then MutexunLock mutex : Return 0
	
	If state = 2 Then
		Dim As UInteger tmp = waitUpdateTime
		MutexunLock mutex
		Do
			Sleep tmp,1
			MutexLock mutex
			If state = 0 Then MutexunLock mutex : Return 1
			If state = 1 Then MutexunLock mutex : Return 0
			MutexunLock mutex
		Loop
		
		
	EndIf
	
	MutexunLock mutex
End Function

Sub threadControllUDT.startThread(threadSub As Sub(x As Any Ptr))
	MutexLock mutex
	threads.push(New threadStackItemUDT(ThreadCreate(threadSub,@This))) 
	MutexunLock mutex
End Sub





