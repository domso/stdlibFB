#include once "utilUDT.bas"
#include once "linklist.bas"
#Include once "stackUDT.bas"

type treeUDT extends utilUDT
	as treeUDT ptr parent
	as list_type child
	
	Declare Constructor(parent As treeUDT Ptr = 0)
	Declare Destructor
	
	Declare Sub Add(tree as treeUDT ptr)
	Declare Sub remove
	Declare Sub clear
	Declare virtual Function equals(o As utilUDT Ptr) As Integer
	Declare Static Sub BFS(tree As treeUDT Ptr)
	Declare Static Sub DFS(tree As treeUDT Ptr)
	Declare static Function toList(tree As treeUDT Ptr,noMutex As UByte=0) As list_type ptr 
End type

Constructor treeUDT(parent As treeUDT Ptr = 0)
	If parent <> 0 Then parent->add(@This)
End Constructor

Destructor treeUDT
	Dim As treeUDT Ptr tP = this.parent
	this.remove()
	
	If tP <> 0 Then 
	Dim As treeUDT Ptr tPtr
	child.reset

		tPtr = Cast(treeUDT Ptr,child.getItem)
		While(tPtr <> 0)
			tP->Add(tPtr)
			tPtr = Cast(treeUDT Ptr,child.getItem)
		Wend
	
		tP->child.reset
	End If
End Destructor

Sub treeUDT.add(tree as treeUDT ptr)
	if tree = 0 then return
	child.add(tree,1)
	tree->parent = @this
end Sub

Sub treeUDT.remove
	If parent = 0 Then Return
	parent->child.remove(@This,1)
End SuB

Sub treeUDT.clear
	child.clear
End Sub

Function treeUDT.equals(o As utilUDT Ptr) As Integer
	If @This = o Then Return 1
	Return 0
End Function

Sub treeUDT.BFS(tree As treeUDT Ptr)
	If tree = 0 Then Return
	Dim As stackUDT tmp
	Dim As treeUDT Ptr tPtr
	
	tmp.setFIFO
	tmp.push(tree)
	

	tree = Cast(treeUDT Ptr,tmp.pop)
	While (tree <> 0)
		tree->todo
		tree->child.reset
		tPtr = 0
		tPtr = Cast(treeUDT Ptr,tree->child.getItem)
		While(tPtr <> 0)
			tmp.push(tPtr)
			tPtr = Cast(treeUDT Ptr,tree->child.getItem)
		Wend
		
		
		tree = Cast(treeUDT Ptr,tmp.pop)
	Wend
		
	
End Sub

Sub treeUDT.DFS(tree As treeUDT Ptr)
	If tree = 0 Then Return
	Dim As stackUDT tmp
	Dim As treeUDT Ptr tPtr
	
	tmp.setLIFO
	tmp.push(tree)
	
	tree = Cast(treeUDT Ptr,tmp.pop)
	While (tree <> 0)
		tree->todo
		tree->child.resetB
		tPtr = 0
		tPtr = Cast(treeUDT Ptr,tree->child.getItem(1))
		While(tPtr <> 0)
			tmp.push(tPtr)
			tPtr = Cast(treeUDT Ptr,tree->child.getItem(1))
		Wend
		
		
		tree = Cast(treeUDT Ptr,tmp.pop)
	Wend
End Sub

Function treeUDT.toList(tree As treeUDT Ptr,noMutex As UByte=0) As list_type Ptr
	Var list = New list_type(noMutex)
	Dim As stackUDT tmp
	Dim As treeUDT Ptr tPtr
	
	tmp.setLIFO
	tmp.push(tree)
	
	tree = Cast(treeUDT Ptr,tmp.pop)
	While (tree <> 0)
		list->Add(tree,1)
		tree->child.resetB
		tPtr = 0
		tPtr = Cast(treeUDT Ptr,tree->child.getItem(1))
		While(tPtr <> 0)
			tmp.push(tPtr)
			tPtr = Cast(treeUDT Ptr,tree->child.getItem)
		Wend
		tree = Cast(treeUDT Ptr,tmp.pop)
	Wend

	Return list
End Function
