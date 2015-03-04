#include once "../util/util.bas"
#include once "objUDT.bas"

type worldUDT extends objUDT
	As UInteger worldID
	Declare Constructor(id As UInteger)
	Declare Function toString as String
	Declare virtual Function todo As byte
end Type

Constructor worldUDT(id As UInteger)
	base(SizeOf(worldUDT),0)
	worldID = id
End Constructor

Function worldUDT.toString as String
	return "WorldID: "+str(getID)
End Function

Function worldUDT.todo As Byte
	Return 0
End Function
