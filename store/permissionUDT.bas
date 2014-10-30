	
#Include Once "../util/util.bas"

Const ROOT As UByte = 128
Const ADMINISTRATOR As UByte = 64
Const XXX As UByte = 32
Const MODERATOR As UByte = 16
Const DEVELOPER As UByte = 8
Const NORMAL As UByte = 4
Const GUEST As UByte = 2
Const BANNED As UByte = 1
Function getRightsText(stageID As UByte ) As String
	Select Case stageID
		Case ROOT
			Return "ROOT"
		Case ADMINISTRATOR
			Return "ADMINISTRATOR"
		Case XXX
			Return "XXX"
		Case MODERATOR
			Return "MODERATOR"
		Case DEVELOPER
			Return "DEVELOPER"
		Case NORMAL
			Return "REGISTERED"
		Case GUEST
			Return "GUEST"
		Case BANNED
			Return "BANNED"
	End Select	
End Function

Type permissionUDT extends utilUDT
	Private:
		minimum_right As UByte
	Public:
	Declare Function getMinimumRight As UByte
	Declare Constructor(rightID As UByte)
End Type

Constructor permissionUDT(rightID As UByte)
	minimum_right=rightID
End Constructor

Function permissionUDT.getMinimumRight As UByte
	Return minimum_right
End Function

Type rightsUDT extends utilUDT
	Private:
		rights As UByte
	Public:
	Declare Function check(permission As permissionUDT Ptr) As UByte
	Declare Sub setRight(rightID As UByte)
	Declare function getRight as Ubyte
	Declare Sub removeRight(rightID As UByte)
End Type

Function rightsUDT.check(permission As permissionUDT Ptr) As UByte
	If permission = 0 Then Return 0 
	If this.rights = 0 Then Return 0 
	If this.rights = 1 Then Return 0
	If this.rights>=permission->getMinimumRight Then Return 1
	Return 0
End Function

Sub rightsUDT.setRight(rightID As UByte)
	this.rights = this.rights Or rightID
End Sub

Sub rightsUDT.removeRight(rightID As UByte)
	this.rights = this.rights Or not rightID
End Sub

Function rightsUDT.getRight as Ubyte
	return rights
end function
