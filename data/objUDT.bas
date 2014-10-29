#Include Once "../util/util.bas"



Type objUDT extends utilUDT
	As Integer world
	As UByte posX,posY,posZ,typ,health,rot_x,rot_y,rot_z,changed
	Declare Constructor(world As Integer=0)
End Type

Constructor objUDT(world As Integer=0)
	this.world=world
	changed=1
End Constructor

