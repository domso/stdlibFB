#include once "utilUDT.bas"
#include once "linklist.bas"

type treeUDT extends utilUDT
	as integer id
	as utilUDT ptr item
	as utilUDT ptr parent
	as list_type child
	Declare Constructor(item as utilUDT ptr=0)
	Declare Sub addTree(tree as treeUDT ptr)
	Declare Sub addItem(item as utilUDT ptr)
end type

Constructor treeUDT(item as utilUDT ptr=0)
	this.item = item
End Constructor

Sub treeUDT.addTree(tree as treeUDT ptr)
	if tree = 0 then return
	child.add(tree,1)
	tree->parent = @this
end sub

Sub treeUDT.addItem(item as utilUDT ptr)
	if item = 0 then return
	var tree = new treeUDT(item)
	child.add(tree,1)
	tree->parent = @this
end sub
