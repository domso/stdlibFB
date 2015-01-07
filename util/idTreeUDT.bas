Type IDtreeUDT_node
	As IDtreeUDT_node Ptr one
	As IDtreeUDT_node Ptr zero
	As Any Ptr Data
	Declare Constructor
	Declare DEstructor
End Type

Dim Shared As UInteger counter,delcounter

Constructor IDTREEudt_NODE
	counter+=1
End Constructor

Destructor IDtreeUDT_node
	delcounter += 1
End Destructor

Type IDtreeUDT
	Private:
		As UByte useMutex = 0
		As IDtreeUDT_node parent 
		As Any Ptr mutex
	Public:
	Declare Constructor
	Declare Destructor
	Declare Sub setMutex(enable As UByte)
	Declare Sub insert(id As UInteger,item As Any Ptr)
	Declare Function Get(id As UInteger) As Any Ptr
	Declare Sub free(id As UInteger)
End Type

Constructor IDtreeUDT
	mutex = mutexcreate
End Constructor

Destructor IDtreeUDT
	MutexDestroy mutex
End Destructor

Sub IDtreeUDT.setMutex(enable As UByte)
	MutexLock Mutex
	this.useMutex = enable
	MutexUnLock mutex
End Sub

Sub IDtreeUDT.insert(id As UInteger,item As Any Ptr)
	If item = 0 Then Return
	If useMutex Then MutexLock mutex
	Dim As IDtreeUDT_node Ptr currentPosition
	Dim As UByte sizeOfID = SizeOf(id)*8,level = 0
	currentPosition = @parent
	
	While(level<sizeofID)
		If (id Shl level) Shr (sizeOfID-1) Then
			Exit while
		Else
			level+=1
		EndIf
	Wend
	
	
	While(level<sizeOfID)
		If (id Shl level) Shr (sizeOfID-1) Then
			If currentPosition->one = 0 Then currentPosition->one = New IDtreeUDT_node	
			currentPosition = currentPosition->one
			level+=1		
		Else
			If currentPosition->zero = 0 Then currentPosition->zero = New IDtreeUDT_node	
			currentPosition = currentPosition->zero
			level+=1		
		EndIf
	Wend	
	currentPosition->Data = item
	If useMutex Then MutexUnLock mutex
End Sub

Function IDtreeUDT.Get(id As UInteger) As Any Ptr
	If useMutex Then MutexLock mutex
	Dim As IDtreeUDT_node Ptr currentPosition
	Dim As UByte sizeOfID = SizeOf(id)*8,level = 0
	
	currentPosition = @parent
	
	While(level<sizeofID)
		If (id Shl level) Shr (sizeOfID-1) Then
			Exit while
		Else
			level+=1
		EndIf
	Wend
	
	
	While(level<sizeOfID)
		If (id Shl level) Shr (sizeOfID-1) Then
			If currentPosition->one = 0 Then
				If useMutex Then MutexUnLock mutex
				Return 0
			EndIf
			currentPosition = currentPosition->one
			level+=1		
		Else
			If currentPosition->zero = 0 Then 
				If useMutex Then MutexUnLock mutex
				Return 0
			EndIf
			currentPosition = currentPosition->zero
			level+=1		
		EndIf
	Wend	
	Var tmp = currentPosition->Data 
	If useMutex Then MutexUnLock mutex
	Return tmp
End Function

Sub IDtreeUDT.free(id As UInteger)
	If useMutex Then MutexLock mutex
	Dim As IDtreeUDT_node Ptr currentPosition
	Dim As UByte sizeOfID = SizeOf(id)*8,level = 0,startPos
	
	ReDim path(0 To sizeOfID-1) As IDtreeUDT_node Ptr
	
	currentPosition = @parent
	While(level<sizeofID)
		If (id Shl level) Shr (sizeOfID-1) Then
			Exit while
		Else
			level+=1
		EndIf
	Wend
	startPos = level
	
	While(level<sizeOfID)
		If (id Shl level) Shr (sizeOfID-1) Then
			If currentPosition->one = 0 Then Exit While
			currentPosition = currentPosition->one
			path(level) = currentPosition
			level+=1		
		Else
			If currentPosition->zero = 0 Then Exit While
			path(level) = currentPosition
			currentPosition = currentPosition->zero
			path(level) = currentPosition
			level+=1		
		EndIf
	Wend

	If currentPosition = @parent Then
		parent.data =0
		If useMutex Then MutexUnLock mutex
		return
	EndIf
	
	
	path(level-1)->Data = 0
	
	
	For i As Integer = level-1 To startPos+1 Step -1
		If path(i)->one = 0 And path(i)->zero = 0 And path(i)->Data = 0 Then
			If path(i-1)->zero = path(i) Then path(i-1)->zero = 0
			If path(i-1)->one = path(i) Then path(i-1)->one = 0
			Delete path(i)
		EndIf
	Next
	
	If path(startPos)->zero = 0 And path(startPos)->one = 0 Then
		If parent.zero = path(startPos) Then parent.zero = 0
		If parent.one = path(startPos) Then parent.one = 0
		Delete path(startPos)
	EndIf
	
	If useMutex Then MutexUnLock mutex
End Sub

Randomize Timer
Dim As IDtreeUDT Ptr tree = New IDtreeUDT
Print tree

tree->setMutex(0)
For i As Integer = 0 To 10000000
	tree->insert(i,tree)
Next
For i As Integer = 0 To 10000000
	tree->free(i)
Next
Print "finish"

Print tree->Get(54)

Print counter
Print delcounter

Delete tree

Sleep
