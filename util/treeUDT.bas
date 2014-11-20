#include once "utilUDT.bas"
#include once "linklist.bas"

type treeUDT extends utilUDT
	as utilUDT ptr parent
	as list_type child
	Declare Sub addTree(tree as treeUDT ptr)
	Declare virtual Function equals(o As utilUDT Ptr) As Integer
End type

Sub treeUDT.addTree(tree as treeUDT ptr)
	if tree = 0 then return
	child.add(tree,1)
	tree->parent = @this
end sub

Function treeUDT.equals(o As utilUDT Ptr) As Integer
	If @This = o Then Return 1
	Return 0
End Function