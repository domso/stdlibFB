#Include Once "../util/util.bas"
#Include Once "permissionUDT.bas"

Type clientUDT extends utilUDT
	Private:
		As rightsUDT rights
	Public:
		As integer tsneID
		as UByte authstage
		as String username
		As Double con_time
		
		Declare Constructor(tsneID As integer)
	
		Declare Function equals(o As utilUDT Ptr) As Integer
		Declare Function getRights As rightsUDT ptr
End Type

Constructor clientUDT(tsneID As integer)
	this.tsneID=tsneID
	rights.setRight(GUEST)
End Constructor


Function clientUDT.equals(o As utilUDT Ptr) As Integer
	If o=0 Then Return 0
	'If this.accountID=Cast(clientUDT ptr,o)->accountID Then Return 1
	If this.tsneID=Cast(clientUDT ptr,o)->tsneID Then Return 1
	Return 0
End Function

Function clientUDT.getRights As rightsUDT ptr
	Return @rights
End Function
