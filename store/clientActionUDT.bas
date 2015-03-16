#Include Once "../util/util.bas"



Type clientActionUDT extends utilUDT
	As UInteger objID,actionID,targetID,clientID
	Declare Constructor(clientID As UInteger, objID As UInteger,actionID As UInteger,targetID As UInteger)
End Type

Constructor clientActionUDT(clientID As uinteger, objID As UInteger,actionID As UInteger,targetID As UInteger)
	this.clientID = clientID
	this.objID = objID
	this.actionID = actionID
	this.targetID = targetID
End Constructor

