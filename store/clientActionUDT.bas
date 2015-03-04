#Include Once "../util/util.bas"


Type clientActionUDT extends utilUDT
	As UInteger objID,actionID,targetID
	Declare Constructor(objID As UInteger,actionID As UInteger,targetID As UInteger)
End Type

Constructor clientActionUDT(objID As UInteger,actionID As UInteger,targetID As UInteger)
	this.objID = objID
	this.actionID = actionID
	this.targetID = targetID
End Constructor

