#Include Once "hashtableUDT.bas"


Type lockUDT extends utilUDT
	Private:
		As utilUDT Ptr keyLock
		As utilUDT Ptr remove
		As utilUDT Ptr removeWithItem
		As hashtableUDT Ptr table
		As Any Ptr mutex
		As Any Ptr mutexWait
	Public:
		
		Declare Constructor(capacity As UInteger)
		Declare Destructor
		
		Declare Sub store(key As UInteger,DataPTR As utilUDT Ptr)
		Declare Function lock(key As UInteger) As utilUDT ptr
		Declare Sub unlock(key As UInteger,DataPTR As utilUDT Ptr)
		Declare Sub free(key As UInteger,itemDelete As UByte=0) 
End Type

Constructor lockUDT(capacity As UInteger)
	table = New hashtableUDT(capacity,1)
	mutex = MutexCreate
	mutexWait = MutexCreate
	MutexLock mutexWait
	keyLock = New utilUDT
	remove = New utilUDT
	removeWithItem = New utilUDT
End Constructor

Destructor lockUDT
	MutexLock mutex
	MutexUnLock mutexWait
	MutexLock mutexWait
	MutexDestroy(mutex)
	MutexDestroy(mutexWait)

	Delete table
	Delete keyLock
	Delete remove
	Delete removeWithItem
End Destructor

Sub lockUDT.store(key As UInteger,DataPTR As utilUDT Ptr)
	MutexLock mutex
	If table <> 0 Then
		If table->Get(key) = 0 then
			table->add(key,DataPTR)
		End if
	End if
	MutexUnLock mutex
End Sub

Function lockUDT.lock(key As UInteger) As utilUDT Ptr
	MutexLock mutex
	Dim As hashtableItemUDT_uint Ptr tmp
	Dim As utilUDT Ptr tmp2
	If table <> 0 Then
		tmp = table->GetItemUDT(key)
		If tmp = 0 Then MutexUnLock mutex : Return 0
		If tmp->data_ <> remove And tmp->data_ <> removeWithItem Then
			tmp2 = tmp->data_
			tmp->data_ = keyLock
		EndIf
		If tmp2 = keyLock Then
			MutexUnLock mutex
			Do
				MutexLock mutexWait
				tmp = table->GetItemUDT(key)
				If tmp = 0 Then Return 0
				If tmp->data_ <> keyLock Then Exit do
				MutexunLock mutexWait
			Loop
			
			If tmp->data_ <> remove And tmp->data_ <> removeWithItem Then
				tmp2 = tmp->data_
				tmp->data_ = keyLock
			Else
				tmp2 = 0
			EndIf
			MutexunLock mutexWait
			Return tmp2
			
		EndIf
	End If
	

	MutexUnLock mutex
	Return tmp2
End Function

Sub lockUDT.unlock(key As UInteger,DataPTR As utilUDT Ptr)
	MutexLock mutex
	Dim As hashtableItemUDT_uint Ptr tmp
	If table <> 0 Then
		tmp = table->GetItemUDT(key)
		If tmp = 0 Then MutexUnLock mutex : Return 
		If tmp->data_ = keyLock Then
			tmp->data_ = DataPTR
		ElseIf tmp->data_ = remove Then
			table->remove(key)
		ElseIf tmp->data_ = removeWithItem Then
			Delete DataPTR
			table->remove(key)
		EndIf
		
		MutexUnLock mutexWait
		MutexLock mutexWait
		
	End If
	MutexUnLock mutex
End Sub

Sub lockUDT.free(key As UInteger,itemDelete As UByte=0) 
	MutexLock mutex
	Dim As hashtableItemUDT_uint Ptr tmp
	If table <> 0 then
		tmp = table->GetItemUDT(key)
		If tmp->data_ <> keyLock Then
			If itemDelete Then Delete tmp->data_
			table->remove(key)
		Else
			If itemDelete Then
				tmp->data_ = removeWithItem 
			Else
				tmp->data_ = remove
			EndIf
		EndIf
	EndIf
	MutexUnLock mutex
End Sub


