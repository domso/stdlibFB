#Include once "utilUDT.bas"
#include once "linklist.bas"
#Include once "stackUDT.bas"
#Include once "idUDT.bas"
#Include once "lockUDT.bas"

type idTreeUDT extends utilUDT
	As UInteger ID
	as list_type child = 1
	
	Declare Constructor(ID As UInteger = 0)
	Declare Destructor
	
	Declare Sub Add(ID as UInteger)
	Declare Sub removeChild(id As UInteger)
	Declare Sub clear
	Declare virtual Function equals(o As utilUDT Ptr) As Integer
	Declare Function toString As String
	'Declare Sub BFS(lockPTR As lockUDT Ptr,stackPTR As stackUDT Ptr = 0)
	'Declare Sub DFS(lockPTR As lockUDT Ptr)
	'Declare Function toList(tree As treeUDT Ptr,noMutex As UByte=0) As list_type ptr
	
	Declare Function  lockChild(lockPTR As lockUDT Ptr,stackPTR As stackUDT Ptr = 0,list As list_type Ptr = 0) As list_type Ptr
	Declare Sub  unlockChild(lockPTR As lockUDT Ptr,list As list_type Ptr = 0)
End type

Constructor idTreeUDT(ID As UInteger = 0)
	this.ID = ID	
End Constructor

Destructor idTreeUDT
	this.clear
End Destructor

Sub idTreeUDT.add(ID as UInteger)
	if ID = 0 then return
	child.add(New ID_DATA(ID),1)
End Sub

Sub idTreeUDT.removeChild(id As UInteger)
	Dim As ID_DATA Ptr tmp
	child.reset
	
	tmp = Cast(ID_DATA Ptr,child.getItem)
	While(tmp <> 0)
		If tmp->id = id Then
			child.removeLast(tmp)
			return
		EndIf
		tmp = Cast(ID_DATA Ptr,child.getItem)	
	Wend
	
End SuB

Sub idTreeUDT.clear
	child.clear
End Sub

Function idTreeUDT.equals(o As utilUDT Ptr) As Integer
	If o = 0 Or Cast(idTreeUDT Ptr,o) = 0 Then Return 0
	If this.id = Cast(idTreeUDT Ptr,o)->id Then Return 1
	Return 0
End Function

Function idTreeUDT.toString as String
	return "ID: "+str(id)
End Function

Function idTreeUDT.lockChild(lockPTR As lockUDT Ptr,stackPTR As stackUDT Ptr = 0,list As list_type Ptr = 0) As list_type Ptr
	If lockPTR = 0 Then Return 0
	If stackPTR = 0 Then stackPTR = New stackUDT
	If list = 0 Then list = New list_type
	
	stackPTR->setLIFO
	stackPTR->push(@this)
	
	Dim As idTreeUDT Ptr tree
	Dim As idTreeUDT Ptr tPtr
	Dim As id_Data Ptr tPtrID

	'lockPTR
	
	tree = Cast(idTreeUDT Ptr,stackPTR->pop)
	While (tree <> 0)
		If tree<>@This Then list->Add(tree,1)
		tree->child.resetB
		
		tPtrID = Cast(ID_Data Ptr,tree->child.getItem(1))
		If tPtrID <> 0 Then
			tPtr = Cast(idTreeUDT Ptr,lockPTR->Lock(tPtrID->id))
		Else
			tPtr = 0
		EndIf
		
		While(tPtr <> 0)
			stackPTR->push(tPtr)
			tPtrID = Cast(ID_Data Ptr,tree->child.getItem(1))
			If tPtrID <> 0 Then
				tPtr = Cast(idTreeUDT Ptr,lockPTR->Lock(tPtrID->id))
			Else
				tPtr = 0
			EndIf
		Wend
		
		
		tree = Cast(idTreeUDT Ptr,stackPTR->pop)
	Wend
	Return list
End Function
	
Sub idTreeUDT.unlockChild(lockPTR As lockUDT Ptr,list As list_type Ptr)
	If lockPTR = 0 Or list = 0 Then Return
	'
	Dim As idTreeUDT Ptr tree
	
	list->reset
	
	tree = Cast(idTreeUDT Ptr,list->getItem)
	While(tree <> 0)
		lockPTR->UnLock(tree->ID,tree)
		tree = Cast(idTreeUDT Ptr,list->getItem)
	Wend
	list->Clear(1)
End Sub

'Var tmpStack = New stackUDT
'Var tmpLock = New lockUDT(10)
'Var tmpList = New list_type
'Dim As idTreeUDT Ptr tmp
'
'Dim As idTreeUDT ptr obj(1 To 7)
'For i As Integer = 1 To 7
'	obj(i) = New idTreeUDT(i)
'	tmpLock->store(i,obj(i))
'Next
'
'obj(1)->Add(2)
'obj(1)->Add(3)
'
'obj(2)->Add(4)
'obj(2)->Add(5)
'
'obj(3)->Add(6)
'obj(3)->Add(7)
'
'Dim As Double diff,zeit
'
'zeit = timer
'tmpList = obj(1)->lockChild(tmpLock,tmpStack,tmpList)
'obj(1)->unlockChild(tmpLock,tmpList)
'diff = Timer - zeit
'Print diff
'Print "finish"
'
'sleep
/'

Sub idTreeUDT.BFS(lockPTR As lockUDT Ptr,stackPTR As stackUDT Ptr = 0)
	If lockPTR = 0 Then Return
	If stackPTR = 0 Then stackPTR = New stackUDT
	
	stackPTR->setFIFO
	stackPTR->push(@this)
	
	Dim As idTreeUDT Ptr tree
	Dim As idTreeUDT Ptr tPtr

	
	
	tree = Cast(idTreeUDT Ptr,stackPTR->pop)
	While (tree <> 0)
		tree->todo
		tree->child.reset
		tPtr = 0
		tPtr = Cast(idTreeUDT Ptr,tree->child.getItem)
		While(tPtr <> 0)
			stackPTR->push(tPtr)
			tPtr = Cast(idTreeUDT Ptr,tree->child.getItem)
		Wend
		
		
		tree = Cast(idTreeUDT Ptr,stackPTR->pop)
	Wend
		
End Sub

Sub idTreeUDT.DFS(tree As treeUDT Ptr)
	If tree = 0 Then Return
	Dim As stackUDT tmp
	Dim As treeUDT Ptr tPtr
	
	tmp.setLIFO
	tmp.push(tree)
	
	Do
		tree = Cast(treeUDT Ptr,tmp.pop)
		If tree <> 0 Then
			tree->todo
			tree->child.resetB
			tPtr = 0
			do
				tPtr = Cast(treeUDT Ptr,tree->child.getItem(1))
				If tPtr <> 0 Then
					tmp.push(tptr)
				EndIf
			Loop Until tPtr = 0
			
			
		EndIf
	Loop Until tree = 0
End Sub

Function idTreeUDT.toList(tree As treeUDT Ptr,noMutex As UByte=0) As list_type Ptr
	Var list = New list_type(noMutex)
	Dim As stackUDT tmp
	Dim As treeUDT Ptr tPtr
	
	tmp.setLIFO
	tmp.push(tree)
	
	Do
		tree = Cast(treeUDT Ptr,tmp.pop)
		If tree <> 0 Then
			list->Add(tree,1)
			tree->child.resetB
			tPtr = 0
			do
				tPtr = Cast(treeUDT Ptr,tree->child.getItem(1))
				If tPtr <> 0 Then
					tmp.push(tptr)
				EndIf
			Loop Until tPtr = 0
			
			
		EndIf
	Loop Until tree = 0
	Return list
End Function

'/



'crap:
/'Type IDtreeUDT_node
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
'/
