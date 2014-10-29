#Include Once "utilUDT.bas"
#Include Once "linklist.bas"

Dim Shared As list_type GLOBAL_IMG_LIST

Type imgUDT extends utilUDT
	As Any Ptr buffer
	As String id_name
	As Integer Width,height
	As UByte isError
	Declare virtual Function equals(o As utilUDT Ptr) As Integer	
	Declare Constructor(id_name As String,file As String,Width As Integer,height As Integer,noList As UByte=0)
	Declare Destructor
End Type

Function imgUDT.equals(o As utilUDT Ptr) As Integer
	If this.id_name = Cast(imgUDT Ptr,o)->id_name Then Return 1
	Return 0
End Function

Constructor imgUDT(id_name As String,file As String,Width As Integer,height As Integer,noList As UByte=0)
	this.id_name = id_name
	this.width = Width
	this.height = height
	buffer = ImageCreate(this.width,This.height)
	isError = BLoad (file,buffer)
	If noList=0 Then GLOBAL_IMG_LIST.add(@This,1)
End Constructor


Destructor imgUDT
	If buffer <> 0 Then
		ImageDestroy buffer
	EndIf
End Destructor

Dim Shared As imgUDT Ptr GLOBAL_IMG_NOT_FOUND 
GLOBAL_IMG_NOT_FOUND= New imgUDT("GLOBAL_IMG_NOT_FOUND","",400,400)

Function getIMG(id_name As String) As imgUDT Ptr
	Dim As imgUDT Ptr tmp
	Dim As imgUDT Ptr tmp2
	tmp = New imgUDT(id_name,"",0,0,1)
	'tmp->id_name = id_name
		
	tmp2 = Cast(imgUDT Ptr, GLOBAL_IMG_LIST.search(tmp))
	
	If tmp2 = 0 Then 
		tmp2 = GLOBAL_IMG_NOT_FOUND
		Return tmp2
	EndIf

	Delete tmp
	Return tmp2
End Function
