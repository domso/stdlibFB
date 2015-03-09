#Include Once "../util/util.bas"
#Include Once "../util/lockUDT.bas"
#Include Once "../store/clientUDT.bas"
#Include Once "objUDT.bas"

Dim Shared As lockUDT controllerUDT_lock = 10
Dim Shared As idUDT controllerUDT_ID

Type controllerUDT extends treeUDT
	Private:
		As UByte update
		As UByte remove
		As byte result
	
		As UInteger ID
		As clientUDT Ptr Access
		As objUDT Ptr obj 
	Public:
		Declare Constructor(data_ As objUDT ptr,id As UInteger=0)
		Declare Destructor

		Declare Function getAccess(client As clientUDT Ptr) As UByte 
		Declare Function getClient As clientUDT Ptr
		Declare Function getID As UInteger
		Declare Sub closeAccess
		
		Declare Virtual Function todo As byte
End Type

Constructor controllerUDT(data_ As objUDT ptr,id As UInteger=0)

	this.obj = Data_
	If id = 0 Then
		this.ID = controllerUDT_ID.getNext
	Else
		this.ID = id
	EndIf
	controllerUDT_lock.store(id,@This)
End Constructor

Destructor controllerUDT
	controllerUDT_lock.free(id)
	controllerUDT_ID.freeID(ID)
	If obj <> 0 Then Delete obj
End Destructor

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
	If obj = 0 Then Return 0
	If obj->isEnable = 0 Then Return 0
	
	result = 0 : update = 0 : remove = 0
	obj->controller = @this
	
	
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

