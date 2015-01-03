#Include Once "linklist.bas"

Type SubString extends utilUDT
	As String text
	As UByte isCommand,ListInUse,IsNumber
	As list_type Ptr list
	Declare Constructor(text As String,isCommand As UByte)
	Declare Destructor
	Declare Function toString As String
End Type

Constructor SubString(text As String,isCommand As UByte)
	this.text=text
	this.isNumber = ContainsNumber(text)
	this.isCommand=isCommand
End Constructor

Destructor SubString
	If listInUse Then
		list->Clear
		Delete list
	EndIf
End Destructor

Function SubString.toString As String
		Return text	
End Function

Function parseInternalBy(ByRef mainString As String,item As String,itemClose As String,list As list_type Ptr,Modus As UByte=0,noRec As UByte=0) As UByte
	If list=0 Then Return 0
	If mainString="" Then Return 0
	Dim As String tmp	
	Dim As String tmpItem
	
	If Modus=0 then
		tmpItem = item
	Else
		tmpItem = itemClose
	End if	
	
	
	Dim As Integer tmp2 = InStr(mainString,tmpItem)
	
	Dim As Integer start,ende
	
	
	If modus=0 Then
		start = 1
		ende  = InStr(mainString,item)
		If ende<>start Then
			Dim As String tmp = Mid(mainString,start,ende-start)		
			mainString = Mid(mainString,ende)
			Dim As Integer instrI = InStr(tmp,"=")
			If instrI<>0 Then
				mainString = "<"+Mid(tmp,instrI+1)+mainString+"/>"
				tmp = Mid(tmp,1,instrI-1)		
			EndIf
			
			list->Add(New SubString(tmp,modus),1)
		Else
			mainString = Mid(mainString,Len(item)+1)
			modus=1
		End if
	Else
		start=1
		Dim As Integer j=1
		For i As Integer = 1 To Len(mainString)
			If Mid(mainString,i,Len(item)) = item Then j+=1 
			If Mid(mainString,i,Len(itemClose)) = itemClose Then j-=1
			If j = 0 Then
				ende=i
				Exit for
			EndIf
		Next
		Dim As String tmp = Mid(mainString,start,ende-1)
		mainString = Mid(mainString,ende+Len(itemClose))
		
		If modus=0 Then
			'nicht erreichbar! TBD
			list->Add(New SubString(tmp,modus),1)
		Else
			Dim As SubString Ptr tmpSubString = New SubString(tmp,modus)
			Dim As list_type Ptr tmpList = New list_type
			list->Add(tmpSubString,1)
			tmpSubString->list = tmpList
			parseInternalBy(tmp,item,itemClose,tmpList)
			tmpSubString->ListInuse=1
		End if
		
		modus=0
		
	End If
	parseInternalBy(mainString,item,itemClose,list,modus)

End Function


Function parseBy(mainString As String,item As String,itemClose As String,list As list_type Ptr=0) As list_type Ptr

	If list=0 Then list = New list_type
	mainString = item+mainString
	mainString = mainString+itemClose
	parseInternalBy(mainString,item,itemClose,list)
	Return list
End Function

Function parseCommand(mainString As String) As list_type Ptr
	Dim As list_type Ptr tmp
	tmp = New list_type
	tmp = parseBy(mainString,"<","/>",tmp)
	Return tmp
End Function


	
	
	
	
	
	
	
	