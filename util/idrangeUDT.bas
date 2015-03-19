#Include Once "utilUDT.bas"
#Include Once "stackUDT.bas"

Type idrangeUDT extends utilUDT
	Private:
		As Any Ptr mutex
		As UInteger min = 0,max = 0
		As stackUDT stack
	Public:
		
	Declare Constructor
	Declare Destructor
	
	Declare Sub Add(id As UInteger)
	Declare Sub free(id As UInteger)
End Type

Constructor idrangeUDT
	mutex = mutexcreate
End Constructor

Destructor idrangeUDT
	MutexLock mutex
	MutexDestroy mutex
	stack.free
End Destructor

Sub Add(id As UInteger)
	MutexLock mutex
	If min = 0 Then min = id
	If max = 0 Or max<id Then max = id
	MutexunLock mutex
End Sub

Sub free(id As UInteger)
	MutexLock mutex
	If id = min Then
		min+=1
		If min>max Then min = 0 : max = 0
	elseIf id = max Then
		max-=1
		If min>max Or max<1 Then min = 0 : max = 0
	Else
		
	EndIf	
	MutexunLock mutex
End Sub
