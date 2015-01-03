#Include Once "utilUDT.bas"


Type staticstackUDT extends utilUDT
	As UInteger startPos,endePos,size,current
	
	As Any Ptr Ptr Data
	As Any Ptr mutex
	
	Declare Sub push(item As utilUDT Ptr)
	Declare Function pop As utilUDT ptr
	
	Declare Constructor(size As UInteger)
End Type


Constructor staticstackUDT(size As UInteger)
	This.size = size
	Data = Allocate(size * SizeOf(utilUDT Ptr))
	mutex = mutexCreate
End Constructor

Sub staticstackUDT.push(item As utilUDT Ptr)
	If item = 0 Then Return
	MutexLock mutex
	If current = size Then MutexUnLock mutex : Return
	Data[endePos] = item
	current+=1
	endePos+=1
	endePos = endePos Mod size
	MutexUnLock mutex
End Sub

Function staticstackUDT.pop As utilUDT Ptr
	MutexLock mutex
	Var tmp = Data[startPos]
	Data[startPos] = 0
	startPos+=1
	startPos = startPos Mod size
	current-=1
	MutexUnLock mutex
	Return tmp
End Function


Dim Shared As staticstackUDT tmp = 100
Dim Shared As UtilUDT Ptr tmpOut
Dim Shared As UtilUDT Ptr tmpIn
tmpIn = New utilUDT

Sub push(x As Any Ptr)
	For i As Integer = 1 To 1000000
	tmp.push(tmpIn)
	next
End Sub

Sub pop(x As Any Ptr)
	For i As Integer = 1 To 1000000
	tmpOut = tmp.pop
	next
End Sub



Dim As Double zeit,diff,sum,comTime
Dim As Integer count
comTime = timer
	zeit = Timer
	Var t1 = ThreadCreate(@push)
	Var t2 = ThreadCreate(@pop)
	
	ThreadWait t1
	ThreadWait t2
	diff = Timer - zeit
	'diff = Timer - zeit
	'sum+=Abs(diff)
	'count+=1

'Print Timer-comTime
Print diff

'Print sum/count

Sleep
