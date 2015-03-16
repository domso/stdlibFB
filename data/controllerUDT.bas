#Include Once "../util/util.bas"
#Include Once "../store/clientUDT.bas"
#Include Once "objUDT.bas"


Dim Shared As lockUDT controllerUDT_lock = 10
Dim Shared As idUDT controllerUDT_ID

Type controllerUDT extends idTreeUDT
	Private:
		As UByte update
		As UByte remove
		As byte result
		
		As clientUDT Ptr Access
		As objUDT Ptr obj 
	Public:
		Declare Constructor(data_ As objUDT ptr,id As UInteger=0)
		Declare Destructor
	
		Declare Sub setUpdate
		Declare Sub setRemove
		
		Declare Function getAccess(client As clientUDT Ptr) As UByte 
		Declare Function getClient As clientUDT Ptr
		Declare Function getID As UInteger
		Declare Sub closeAccess
		Declare Function getObj As objUDT ptr
		Declare Virtual Function todo As byte
End Type

Constructor controllerUDT(data_ As objUDT ptr,id As UInteger=0)

	this.obj = Data_
	If id = 0 Then
		base.ID = controllerUDT_ID.getNext
	Else
		base.ID = id
	EndIf
	controllerUDT_lock.store(base.ID,@This)
End Constructor

Destructor controllerUDT
	controllerUDT_lock.free(id)
	controllerUDT_ID.freeID(ID)
	If obj <> 0 Then Delete obj
End Destructor

Sub controllerUDT.setUpdate
	update = 1
End Sub

Sub controllerUDT.setRemove 
	remove = 1
End Sub

Function controllerUDT.getAccess(client As clientUDT Ptr) As ubyte
	If client = 0 Or this.access<> 0 Then Return 0
	this.access = client
	Return 1 
End Function

Function controllerUDT.getClient As clientUDT ptr
	Return this.access
End Function

Function controllerUDT.getID As UInteger
	Return this.id
End Function

Sub controllerUDT.closeAccess
	this.access = 0
End Sub

Function controllerUDT.todo As Byte
	Print id ;
	If obj = 0 Then Return 0
	If obj->isEnable = 0 Then Return 0
	if obj->hasInstance = 0 then return 0
	result = 0 : update = 0 : remove = 0
	'obj->
	'obj->controller = @this
	
	If obj->isEnableTimeUpdate Then
		
	EndIf
	
	If obj->isEnableActionUpdate Then
		
	EndIf
	
	If obj->isEnableGlobalUpdate Then
		result = obj->GlobalUpdate
		If result>0 Then update = 1
		If result<0 Then remove = 1
	EndIf
	
	If update Then
		
		Dim As String tbd = obj->packBINDIF
		
	EndIf
	
	If remove Then
		
	EndIf
	
	Return 0
End Function

Function controllerUDT.getObj As objUDT ptr
	Return obj
End Function
