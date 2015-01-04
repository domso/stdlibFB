
Type Bnode
	As Integer s(0 To 1)
	As Integer sa
	As Bnode Ptr p(0 To 2)
	As Bnode Ptr v
	
	As Any Ptr data
	
	Declare Constructor(s0 As Integer,v As Bnode Ptr,p0 As Bnode Ptr,p1 As Bnode Ptr)
	Declare Sub add(key As Integer,l As Bnode Ptr,r As Bnode Ptr)
End Type 

Constructor Bnode(s0 As Integer,v As Bnode Ptr,p0 As Bnode Ptr,p1 As Bnode Ptr)
	p(0) = p0
	p(1) = p1
	p(2) = 0
	s(0) = s0
	sa = 1
	this.v = v	
End Constructor

Sub Bnode.add(key As Integer,l As Bnode Ptr,r As Bnode Ptr)
	If (sa=2) Then Return
	sa = 2
	If key<s(0) Then
		s(1) = s(0)
		s(0) = key
		p(0) = l
		p(2) = p(1)
		p(1) = r
	Else
		s(1) = key
		p(1) = l
		p(2) = r
	EndIf
End Sub

Type Btree
	As Bnode ptr root
	
	Declare Constructor
	Declare Function search(key As Integer) As ubyte
	Declare Function search(key As Integer,k As Bnode ptr) As UByte
	
	Declare Function get(key As Integer) As Any ptr
	Declare Function get(key As Integer,k As Bnode Ptr) As Any ptr
	Declare Sub add(key As Integer,Data_ As Any ptr)
	Declare Sub insert(key As Integer,k As bnode Ptr)
	Declare Sub divide(key As Integer,k As Bnode Ptr,l As Bnode Ptr,r As Bnode Ptr)
End Type

Constructor Btree
	root = 0
End Constructor

Function Btree.search(key As Integer) As UByte
	Return search(key,root)
End Function

Function Btree.get(key As Integer) As Any Ptr
	Return this.get(key,root)
End Function
Function Btree.get(key As Integer,k As Bnode Ptr=0) As Any ptr
	If k = 0 Then Return 0
	If k->sa = 1 Then
		If k->s(0) = key Then Return k->data
		If key<k->s(0) Then Return this.get(key,k->p(0))
		If key>k->s(0) Then Return this.get(key,k->p(1))
	EndIf
	If key<k->s(0) Then Return this.get(key,k->p(0))
	If key>k->s(0) And key<k->s(1) Then Return this.get(key,k->p(1))
	If key>k->s(1) Then Return this.get(key,k->p(2))
	Return k->Data
End Function

Function Btree.search(key As Integer,k As Bnode ptr) As UByte
	If k = 0 Then Return 0
	If k->sa = 1 Then
		If k->s(0) = key Then Return 1
		If key<k->s(0) Then Return search(key,k->p(0))
		If key>k->s(0) Then Return search(key,k->p(1))
	EndIf
	If key<k->s(0) Then Return search(key,k->p(0))
	If key>k->s(0) And key<k->s(1) Then Return search(key,k->p(1))
	If key>k->s(1) Then Return search(key,k->p(2))
	Return 1
End Function

Sub Btree.add(key As Integer,Data_ As Any Ptr)
	If search(key) Then Return
	If root = 0 Then 
		root = New Bnode(key,0,0,0)
		root->Data = data_
		return
	EndIf
	insert(key,root)
End Sub

Sub Btree.insert(key As Integer,k As bnode Ptr)
	If k = 0 Then Return 
	If k->sa = 1 Then
		If key<k->s(0) Then
			If k->p(0) = 0 Then
				k->Add(key,0,0) : Return
			Else
				insert(key,k->p(0)) : return
			EndIf
		Else
			if k->p(1) = 0 Then
				k->Add(key,0,0) : Return
			Else
				insert(key,k->p(1)) : return
			EndIf
			
		EndIf
	EndIf
	
	If key<k->s(0) Then
		If k->p(0) = 0 Then
			divide(key,k,0,0) : return
		Else
			insert(key,k->p(0)) : return
		EndIf
	EndIf
	
	If key>k->s(1) Then
		If k->p(2) = 0 Then
			divide(key,k,0,0) : return
		Else
			insert(key,k->p(2)) : return
		EndIf
	EndIf
	
	If k->p(1) = 0 Then
		divide(key,k,0,0) : return
	Else
		insert(key,k->p(1)) : return

	EndIf
End Sub

Sub Btree.divide(key As Integer,k As Bnode Ptr,l As Bnode Ptr,r As Bnode Ptr)
	Dim As Bnode ptr k0,k1,k2,v
	If k = 0 Then
		root = New bnode(key,0,l,r)
		l->v = root
		r->v = root
		return
	EndIf
	If k->sa = 1 Then
		k->Add(key,l,r)
		return
	EndIf
	
	v = k->v
	If key<k->s(0) Then
		k0 = New Bnode(key,v,l,r)
		k1 = New Bnode(k->s(1),v,k->p(1),k->p(2))
		k0->v = v
		k1->v = v
		divide(k->s(0),v,k0,k1)
		return
	EndIf
	If key>k->s(1) Then
		k0 = New Bnode(k->s(0),v,k->p(0),k->p(1))
		k1 = New Bnode(key,v,l,r)
		k0->v = v
		k1->v = v
		divide(k->s(1),v,k0,k1)
		return
	EndIf
	k0 = New Bnode(k->s(0),v,k->p(0),l)
	k1 = New Bnode(k->s(1),v,r,l->p(2))
	k0->v = v
	k1->v = v
	divide(key,v,k0,k1)
	Return
End Sub


Dim As Btree tree 
   
Print @tree
For i As Integer = 1 To 10000000
tree.add(i,@tree)
Next
Print "finish"
Print tree.Get(1654)
Sleep
