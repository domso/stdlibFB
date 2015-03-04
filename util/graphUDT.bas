#Include Once "arraylist.bas"


Function vName(id As Integer) As String
	Select Case id
		Case 0
			Return "Frankfurt"
		Case 1
			Return "Mannheim"
		Case 2
			Return "Wuerzburg"
		Case 3
			Return "Stuttgart"
		Case 4
			Return "Kassel"
		Case 5
			Return "Karlsruhe"
		Case 6
			Return "Erfurt"
		Case 7
			Return "Nuernberg"
		Case 8
			Return "Augsburg"
		Case 9
			Return "Muenchen"
	End Select
End Function



Type weightedGraphUDT extends utilUDT
	As Integer N
	As any Ptr matrix
	
	Declare Function Get(x As Integer,y As Integer) As Integer
	Declare Sub set(x As Integer,y As Integer,value As integer)
	Declare Sub path(start As Integer,dest As Integer)
	Declare Constructor(N As Integer)
End Type

Constructor weightedGraphUDT( N As Integer)
	this.N = N
	Print "max " ;
	Print N*N*SizeOf(Integer)
	matrix = Allocate((N)*(N)*SizeOf(Integer))


	For x As Integer = 0 To N-1
		For y As Integer = 0 To N-1
			set(x,y,16000)
		Next
	Next
	
End Constructor

Function weightedGraphUDT.Get(x As Integer,y As Integer) As Integer
	Return *Cast(integer Ptr,matrix+x*N*SizeOf(Integer)+y*SizeOf(Integer))
End Function

Sub weightedGraphUDT.set(x As Integer,y As Integer,value As integer)

	*Cast(integer Ptr,matrix+x*N*SizeOf(Integer)+y*SizeOf(Integer)) = value
End Sub

Sub weightedGraphUDT.path(start As Integer,dest As Integer)
	Print "path from " + vName(start) +" to "+vName(dest)
	
	ReDim dd(0 To N-1) As integer
	ReDim OK(0 To N-1) As integer
	ReDim pre(0 To N-1) As integer
	
	
	
	For x As Integer = 0 To N-1
		dd(x) = Get(start,x)
		pre(x) = start
	Next
	dd(start) = 0
	OK(start) = 1
	
	Dim As ubyte finish = 1
	Dim As Integer min_dd,w
	Do
		finish = 1
		For x As Integer = 0 To N-1
			If ok(x) = 0 Then finish = 0
		Next
		If finish = 0 Then
			min_dd = 0
			w = 0 
			For x As Integer = 0 To N-1
				If ok(x) = 0 And dd(x)>0 Then 
					If min_dd = 0 Or min_dd>dd(x) Then min_dd = dd(x) : w = x
				EndIf
			Next	
			ok(w) = 1
			For x As Integer = 0 To N-1
				If ok(x) = 0 And Get(w,x)>0 Then 
					If dd(w)+Get(w,x) < dd(x) Then
						dd(x) = dd(w) + Get(w,x)
						pre(x) = w
					EndIf
				EndIf
			Next	
			
			
			
			
			
		EndIf
	Loop Until finish = 1
	Dim As Integer tmp = dest
	Print vName(dest)
	Do 
		tmp = pre(tmp)
		Print vName(tmp)
	Loop Until tmp = start
	
	
End Sub



Dim As weightedGraphUDT test = 10
test.set(0,1,85)
test.set(0,2,217)
test.set(0,4,173)
test.set(1,5,80)
test.set(5,8,250)
test.set(8,9,84)

test.set(2,6,186)
test.set(2,7,103)
test.set(7,3,183)
test.set(7,9,167)
test.set(4,9,502)



test.path(0,9)

sleep