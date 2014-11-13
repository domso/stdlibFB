#include once "utilUDT.bas"
#include once "linklist.bas"

Dim shared as list_type GLOBAL_DELETEUDT_LIST

type deleteUDT extends utilUDT
	private:
		as Sub action
		as Ubyte set_action
	public:
	
	Declare Constructor(action as any ptr)
	Declare Function todo as Byte
end type

Constructor deleteUDT(action as any ptr)
	this.action = action
	set_action = 1
	GLOBAL_DELETEUDT_LIST.add(@this,1)
end Constructor

Function deleteUDT.todo as byte
	if set_action = 0 then return 0
	action()
	return 1
end function

Sub add_Destructor(action as any ptr)
	var tmp = new deleteUDT(action)
end sub

Sub freeAll
	GLOBAL_DELETEUDT_LIST.execute
	GLOBAL_DELETEUDT_LIST.clear
	screenunlock
	cls
	end 0
end Sub

