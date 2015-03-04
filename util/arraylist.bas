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


Function mergeSort(s As String) As String
	Dim As ubyte tmpC,blockSize,blockStep,tmpPos
	blockStep=1
	Do 
		blockStep*=2
		For i As Integer = 0 To Len(s)-1 Step blockStep
			blockSize = blockStep/2
			tmpPos = i
			For j As Integer = blockSize To blockstep-1
				If i+j<Len(s) Then
					tmpC = s[i+j]
					For t As Integer = tmpPos To i+(blockSize-1)
						If s[i+j]<s[t] Then	
							tmpPos = t+1
							For ti As Integer = i+(blockSize-1) To t Step -1 
								s[ti+1] = s[ti]	
							Next
							blockSize +=1
							s[t] = tmpC
							Exit for
						EndIf
					Next
				End If
			Next
		Next
	Loop Until blockstep > Len(s)		
	Return s
End Function


Function HeapSift(s As String,i As Integer,l As Integer) As String 
	Dim As Integer child,parent
	Dim As UByte tmpSwap
	parent = i
	child = 2*i + 1
	While (child <= l)	
		If (child+1<=l) Then
			If s[child] < s[child+1] Then
				child+=1
			EndIf
		EndIf
		If s[parent] < s[child] Then
			tmpSwap = s[parent]
			s[parent] = s[child]
			s[child] = tmpSwap
			
			parent = child
			child = 2 * parent + 1
		
		Else
			Exit While
		EndIf			
	Wend
	Return s
End Function

Function buildMaxHeap(s As String,l As integer) As String
	for i As Integer = l To 0 Step -1 
		s = HeapSift(s,i,l)
	Next
	Return s
End Function

Function heapsort(s As String) As String
	Dim As UByte tmpSwap
	s = buildMaxHeap(s,Len(s)-1)
	
	For j As Integer = Len(s)-1 To 1 Step -1
		tmpSwap = s[0]
		s[0] = s[j]
		s[j] = tmpSwap
		s = HeapSift(s,0,j-1)
	Next
	Return s
End Function

'
'Dim As String tmp,tmp2
'Print "start"
'For i As Integer = 1 To 100000
'	tmp+=Chr(Int(Rnd*255))
'Next
'Print "len: " + Str(Len(tmp))
'tmp2 = heapsort(tmp)
'
'For i As Integer = 0 To Len(tmp2)-2
'	If tmp2[i]>tmp2[i+1] Then Print "[ERROR]"
'Next
'Print "finish"
'sleep



'Print heapsort("an example")
'Print mergeSort("an example")
'Sleep