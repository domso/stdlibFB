#Include Once "../util/util.bas"
#Include Once "controllerUDT.bas"

Type controllTreeUDT extends treeUDT
	As UInteger ID
	Declare Constructor(id As UInteger,parent As treeUDT Ptr)
	Declare Virtual Function todo As Byte
End Type

Constructor controllTreeUDT(id As UInteger,parent As treeUDT Ptr)
	base(parent)
	this.ID = id
End Constructor

Function controllTreeUDT.todo As Byte
	Dim As controllerUDT Ptr tmp
	Dim As Byte result
	tmp = Cast(controllerUDT Ptr,controllerUDT_lock.lock(ID))
	If tmp = 0 Then Return -1
	result = tmp->todo
	controllerUDT_lock.unlock(ID,tmp)
	Return result
End Function
