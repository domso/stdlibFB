#Include Once "../util/util.bas"

type objUDT extends treeUDT
	
end Type

/'
Type obj_attributeUDT extends utilUDT
	Private:
		As utilUDT Ptr item
	Public:
	As UByte changed
	As Integer id
	As Any Ptr obj_mutex
	Declare Constructor (item As utilUDT Ptr,id As Integer)
	Declare Destructor
	Declare Function getItem As utilUDT Ptr	
	Declare Sub writeItem(item As utilUDT Ptr,noDelete As UByte=0)	
	Declare Function equals(o As utilUDT Ptr) As Integer
	Declare Function toString As String	
End Type

Constructor obj_attributeUDT(item As utilUDT Ptr,id As Integer)
	this.id = id
	this.item = item
	changed = 1
	obj_mutex = MutexCreate()
End Constructor

Destructor obj_attributeUDT
	MutexDestroy obj_mutex
End Destructor

Function obj_attributeUDT.getItem As utilUDT Ptr
	MutexLock(obj_mutex)
	Var tmp = this.item
	MutexunLock(obj_mutex)
	Return tmp
End Function

Sub obj_attributeUDT.writeItem(item As utilUDT Ptr,noDelete As UByte=0)
	If item = 0 Then Return
	MutexLock(obj_mutex)
	If noDelete=0 Then
		Delete this.item
		this.item = 0
	EndIf
	this.changed = 1
	this.item = item
	MutexunLock(obj_mutex)	
End Sub

Function obj_attributeUDT.equals(o As utilUDT Ptr) As integer
	If o = 0 Then Return 0
	If this.id = Cast(obj_attributeUDT Ptr,o)->id Then Return 1
	Return 0
End Function

Function obj_attributeUDT.toString As String
	Dim As String tmp ="object attribute"
	If item<>0 Then tmp+=" : "+item->toString
	Return tmp
End Function

Type objUDT extends utilUDT
	Private:
		As list_type attribute
	Public:
		As Integer world
		Declare Constructor(world As Integer=0)
		Declare Sub update(item As obj_attributeUDT Ptr)
		Declare Sub add(id as integer,item as utilUDT ptr)
		Declare Function getChanges As list_type ptr
		Declare Function getAll As list_type ptr
		Declare Function getAttribute(id As Integer) As obj_attributeUDT Ptr
		Declare Function writeItem(id As Integer,item As utilUDT Ptr,noDelete As UByte=0) As UByte
		
End Type

Constructor objUDT(world As Integer=0)
	this.world=world
End Constructor

Sub objUDT.update(item As obj_attributeUDT Ptr)
	attribute.add(item)
	item->changed = 1
End Sub

Sub objUDT.add(id as integer,item as utilUDT ptr)
	attribute.add(new obj_attributeUDT(item,id))
end sub

Function objUDT.getChanges As list_type Ptr
	Dim As list_type Ptr tmp = New list_type
	attribute.reset
	Dim As obj_attributeUDT Ptr o
	Do
		o = Cast(obj_attributeUDT Ptr,attribute.getItem)
		If o<>0 Then
			If o->changed Then
				tmp->Add(o,1)
				o->changed = 0
			EndIf
		EndIf
	Loop Until o = 0
	Return tmp
End Function

Function objUDT.getAll as list_type ptr
	Dim As list_type Ptr tmp = New list_type
	tmp->add(@attribute)
	return tmp
end function

Function objUDT.getAttribute(id As Integer) As obj_attributeUDT ptr
	Var tmp = New obj_attributeUDT(0,id)
	Var tmp2 = Cast(obj_attributeUDT Ptr,attribute.search(tmp))
	Delete tmp
	Return tmp2
End Function

Function objUDT.writeItem(id As Integer,item As utilUDT Ptr,noDelete As UByte=0) As Ubyte
	Var tmp = getAttribute(id)
	If tmp = 0 Then Return 0
	tmp->writeItem(item,noDelete)
End Function

'/
