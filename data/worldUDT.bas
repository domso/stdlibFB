#include once "../util/util.bas"
#include once "objUDT.bas"
#include once "clientOBJ.bas"

type worldUDT extends utilUDT
	As UInteger worldID
	As idtreeUDT root
	Declare Constructor(id As UInteger)
	Declare Function toString as String
	Declare virtual Function todo As byte
end Type

Constructor worldUDT(id As UInteger)
	worldID = id
End Constructor

Function worldUDT.toString as String
	return "WorldID: "+str(worldID)
End Function

Function worldUDT.todo As Byte
	Return 0
End Function


