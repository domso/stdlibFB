#include once "utilUDT.bas"
#include once "stackUDT.bas"

type ID_DATA extends utilUDT
	as uinteger id
	Declare Constructor(id as uinteger)
	Declare function equals(o as utilUDT ptr) as Integer
	Declare Function toString as String
end type

Constructor ID_DATA(id as uinteger)
	this.id = id
End Constructor

Function ID_DATA.equals(o as utilUDT ptr) as Integer
	if o = 0 then return 0
	if this.id = cast(ID_DATA ptr,o)->id then return 1
	return 0
end Function

Function ID_DATA.toString as String
	return "ID: "+str(id)
End Function

type idUDT extends utilUDT
	private:
		As utilUDT ptr Ptr data_array
		As UInteger current_data_array_size
		as uinteger current_max_id
		as uinteger min_range = 1
		as uinteger max_range = &hFFFFFFFF
		as stackUDT DELETE_ID_STACK
		As Any Ptr mutex
		
		Declare Sub freeData(id As UInteger)
		Declare Function getData(id As UInteger) As utilUDT Ptr
	Public:
		Declare Constructor(min as uinteger=1,max as uinteger=&hFFFFFFFF)
		Declare Destructor
		Declare Function setMaxRange(max as uinteger) as Ubyte
		Declare Function setMinRange(min as uinteger) as Ubyte
		Declare Function getMinRange as Uinteger
		Declare Function getMaxRange as Uinteger
		Declare Function freeID(id as uinteger) as Ubyte
		
		Declare Function getNext as Uinteger
		Declare Function getLast as Uinteger
		Declare Function getAll as list_type Ptr
		
		Declare Sub store(id As UInteger,data_ptr As utilUDT Ptr)

end Type

Constructor idUDT(min as uinteger=1,max as uinteger=&hFFFFFFFF)
	this.min_range = min
	this.max_range = max
	mutex = mutexcreate
End Constructor

Destructor idUDT
	DELETE_ID_STACK.free
	If data_array <> 0 Then
		DeAllocate data_array
		data_array = 0
	EndIf
	MutexDestroy mutex
End Destructor

Function idUDT.setMaxRange(max as uinteger) as UByte
	MutexLock mutex
	if current_max_id>max then MutexUnLock mutex : Return 0 'error
	max_range = max
	MutexUnLock mutex
	return 1 'no error
End Function

Function idUDT.setMinRange(min as uinteger) as UByte
	MutexLock mutex
	if current_max_id>min_range Or min<1 Then MutexUnLock mutex : Return 0 'error
	min_range = min
	MutexUnLock mutex
	return 1 'no error
End Function

Function idUDT.getMinRange as UInteger
	MutexLock mutex
	Dim As UInteger tmp = min_range
	MutexUnLock mutex
	return tmp
End Function

Function idUDT.getMaxRange as UInteger
	MutexLock mutex
	Dim As UInteger tmp = max_range
	MutexUnLock mutex
	return tmp
End Function

Function idUDT.freeID(id as uinteger) as UByte
	MutexLock mutex
	if id>current_max_id Or id = 0 Then MutexUnLock mutex : Return 0
	freeData(id)
	if current_max_id = id then
		current_max_id-=1
		
		If current_max_id Shl 4 < current_data_array_size And current_data_array_size > 0 Then
			Dim As utilUDT Ptr Ptr tmpArray = Allocate((current_data_array_size Shr 1) * SizeOf(utilUDT ptr))
			For i As Integer = 0 To (current_data_array_size Shr 1)-1
				tmpArray[i] = data_array[i]
			Next
			Delete data_array
			data_array = tmpArray
			current_data_array_size = current_data_array_size Shr 1
		EndIf
		MutexUnLock mutex
		return 1
	end if
	DELETE_ID_STACK.push(new ID_DATA(id))
	MutexUnLock mutex
End Function

Function idUDT.getNext as UInteger
	MutexLock mutex
	Dim As UInteger returnINT
	if current_max_id < min_range then
		current_max_id = min_range
		returnINT = current_max_id
		MutexunLock mutex		
		return returnINT
	end if
	
	if DELETE_ID_STACK.getStackSize>0 then
		var tmp = Cast(ID_DATA Ptr,DELETE_ID_STACK.pop)
		if tmp <> 0 then
			returnINT = tmp->id
			MutexunLock mutex		
			return returnINT
		end if
	end if
	
	if current_max_id=max_range then MutexUnLock mutex : Return 0
	current_max_id+=1
	
	returnINT = current_max_id
	MutexunLock mutex		
	return returnINT
End Function

Function idUDT.getLast as UInteger
	MutexLock mutex	
	Dim As UInteger returnINT
	returnINT = current_max_id
	MutexunLock mutex	
	return returnINT
End Function

Function idUDT.getAll as list_type Ptr
	MutexLock mutex	
	var list = new list_type
	for i as integer = min_range to max_range
		list->add(new ID_DATA(i),1)
	next
	DIm as ID_DATA ptr tmp
	do
		tmp = cast(ID_DATA PTR,DELETE_ID_STACK.pop)
	loop until tmp = 0
	MutexunLock mutex	
	return list
End Function

Sub idUDT.store(id As UInteger,data_ptr As utilUDT Ptr)
	MutexLock mutex
	If id - min_range < 0 Then MutexunLock mutex	: Return
	If id - min_range >= current_data_array_size  Then
		Dim As UInteger oldSize = current_data_array_size
		current_data_array_size = id - min_range + 1
		current_data_array_size = current_data_array_size shl 3
		If data_array <> 0 Then
			Dim As utilUDT Ptr Ptr tmpArray = Allocate(current_data_array_size * SizeOf(utilUDT ptr))
			For i As Integer = 0 To oldSize-1
				tmpArray[i] = data_array[i]
			Next
			DeAllocate data_array
			data_array = tmpArray 
		Else
			data_array = Allocate(current_data_array_size * SizeOf(utilUDT ptr))
		EndIf
	EndIf
	
	data_array[id - min_range] = data_ptr
	MutexunLock mutex
End Sub


Sub idUDT.freeData(id As UInteger)
	If id - min_range >= current_data_array_size  Then Return 
	data_array[id - min_range] = 0
End Sub

Function idUDT.getData(id As UInteger) As utilUDT Ptr
	If id - min_range >= current_data_array_size  Then Return 0
	Return data_array[id - min_range]
End Function

