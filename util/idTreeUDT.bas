Type IDtreeUDT_node
	As IDtreeUDT_node Ptr one
	As IDtreeUDT_node Ptr zero
	As Any Ptr Data
End Type


Type IDtreeUDT
	As IDtreeUDT_node parent 
	
	Declare Sub insert(id As UInteger,item As Any Ptr)
	Declare Function Get(id As UInteger) As Any Ptr
	Declare Sub free(id As UInteger)
End Type


Sub IDtreeUDT.insert(id As UInteger,item As Any Ptr)
	If item = 0 Then Return
	Dim As IDtreeUDT_node Ptr currentPosition
	Dim As UByte sizeOfID = SizeOf(id)*8,level = 0
	currentPosition = @parent
	While(level<sizeOfID)
		If (id Shl level) Shr (sizeOfID-1) Then
			If currentPosition->one = 0 Then currentPosition->one = New IDtreeUDT_node	
			currentPosition = currentPosition->one
			level+=1		
		Else
			If currentPosition->zero = 0 Then currentPosition->zero = New IDtreeUDT_node	
			currentPosition = currentPosition->zero
			level+=1		
		EndIf
	Wend	
	currentPosition->Data = item
End Sub

Function IDtreeUDT.Get(id As UInteger) As Any Ptr
	Dim As IDtreeUDT_node Ptr currentPosition
	Dim As UByte sizeOfID = SizeOf(id)*8,level = 0
	
	currentPosition = @parent
	While(level<sizeOfID)
		If (id Shl level) Shr (sizeOfID-1) Then
			If currentPosition->one = 0 Then Return 0
			currentPosition = currentPosition->one
			level+=1		
		Else
			If currentPosition->zero = 0 Then Return 0
			currentPosition = currentPosition->zero
			level+=1		
		EndIf
	Wend	
	
	Return currentPosition->Data
		
End Function

Sub IDtreeUDT.free(id As UInteger)
	Dim As IDtreeUDT_node Ptr currentPosition
	Dim As UByte sizeOfID = SizeOf(id)*8,level = 0
	
	ReDim path(0 To sizeOfID-1) As IDtreeUDT_node Ptr
	
	currentPosition = @parent
	While(level<sizeOfID)
		If (id Shl level) Shr (sizeOfID-1) Then
			If currentPosition->one = 0 Then Exit While
			currentPosition = currentPosition->one
			path(level) = currentPosition
			level+=1		
		Else
			If currentPosition->zero = 0 Then Exit While
			path(level) = currentPosition
			currentPosition = currentPosition->zero
			path(level) = currentPosition
			level+=1		
		EndIf
	Wend
	'Print path(level-1)->data
	
	If currentPosition = @parent Then return
	
	if path(level-2)->one = path(level-1) Then   path(level-2)->one = 0
	If path(level-2)->zero = path(level-1) Then  path(level-2)->zero = 0
	Delete path(level-1)
	

	For i As Integer = level-2 To 1 Step -1
		If path(i)->one = 0 And path(i)->zero = 0 Then
			If path(i-1)->zero = path(i) Then path(i-1)->zero = 0
			If path(i-1)->one = path(i) Then path(i-1)->one = 0
			Delete path(i)
		EndIf
	Next
	
	If path(0)->zero = 0 And path(0)->one = 0 Then
		If parent.zero = path(0) Then parent.zero = 0
		If parent.one = path(0) Then parent.one = 0
		Delete path(0)
	EndIf
	
	
	
End Sub

Randomize Timer
Dim As IDtreeUDT Ptr tree = New IDtreeUDT

'471624
Print tree


Sleep 1000,1
For i As Integer = 1 To 10000000
	tree->insert(i,tree)
Next
Sleep 1000,1

For i As Integer = 1 To 10000000
	tree->free(i)
Next
Print "finish"
Print tree->Get(1654)

Delete tree

Sleep
