#Include Once "utilUDT.bas"

Type arrayList
	private:
	As Uinteger maxIndex,size
	As utilUDT Ptr ptr data
	
	
	public:
	Declare Sub clear(noItemRemove as Ubyte=0)
	Declare Sub resize(size as uinteger)
	Declare Sub add(item As utilUDT Ptr)
	Declare Sub add(index as uinteger,item As utilUDT Ptr,deleteOldItem as Ubyte=0)
	Declare Sub remove(item as utilUDT ptr)
	Declare Sub remove(index as uinteger)
	Declare Function get(index as uinteger) as utilUDT ptr
	Declare Function contains(item as utilUDT ptr,byref index as uinteger=0) as Ubyte
End Type

Sub arrayList.clear(noItemRemove as Ubyte=0)
	if data = 0 then return
	if noItemRemove = 0 then
		for i as uinteger = 0 to MaxIndex
			if data[i] <> 0 then
				delete data[i]
				data[i] = 0
			end if
		next
	end if
	deallocate(data)
	data = 0
End Sub

Sub arrayList.resize(size as uinteger)
	if data = 0 then
		data = allocate(size*sizeof(utilUDT ptr))
		maxIndex = size-1
		this.size = size
	else
		data = reallocate(data,(size)*sizeof(utilUDT ptr))
		maxIndex = size-1
		this.size = size
	end if
End Sub

Sub arrayList.add(item As utilUDT Ptr )
	resize(size+1)
	data[MaxIndex] = item
End Sub

Sub arrayList.add(index as uinteger,item as utilUDT ptr,deleteOldItem as Ubyte=0)
	if index>maxIndex then return
	if deleteOldItem and data[index]<>0 then Delete data[index]
	data[index] = item
end Sub

Sub arrayList.remove(index as uinteger)
	if data = 0 then return
	if index>maxIndex then return
	if data[index] <> 0 then delete data[index]
	data[index] = 0
End Sub

Sub arrayList.remove(item as utilUDT ptr)
	if data = 0 or item = 0 then return 
	for i as uinteger = 0 to MaxIndex
		if data[i] <> 0 then
			if data[i]->equals(item) then delete data[i] : data[i] = 0
		end if
	next
	return 
End Sub

Function arrayList.get(index as uinteger) as utilUDT ptr
	if index>maxIndex then return 0
	return data[index]
end Function

Function arrayList.contains(item as utilUDT ptr,byref index as uinteger=0) as Ubyte
	if data = 0 or item = 0 then return 0
	for i as uinteger = 0 to MaxIndex
		if data[i] <> 0 then
			if data[i]->equals(item) then index = i : return 1
		end if
	next
	return 0
End Function
