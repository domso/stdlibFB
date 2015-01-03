#Include Once "utilUDT.bas"
#Include Once "linklist.bas"
#Include Once "stackUDT.bas"

Type ressourceManagerFunctionUDT extends utilUDT
	Private:
		As String fileExtension
		As function(path As String) As Any ptr actionVar
		As Sub(data_ As Any ptr) actionVarDEL
	Public:
		Declare Constructor(fileExtension As String,action As function(path As String) As Any ptr,actionVarDEL As Sub(data_ As Any ptr))
		Declare Function equals(o As utilUDT Ptr) As Integer
		Declare Function getFileExtension As String
		Declare Function action(path As String) As Any ptr
		Declare Sub actionDEL(data_ As Any ptr)
End Type

Constructor ressourceManagerFunctionUDT(fileExtension As String,actionVar As function(path As String) As Any Ptr,actionVarDEL As Sub(data_ As Any ptr))
	this.fileExtension = fileExtension
	this.actionVar = actionVar
	this.actionVarDEL = actionVarDEL
End Constructor

Function ressourceManagerFunctionUDT.equals(o As utilUDT Ptr) As Integer
	If o=0 Then Return 0
	Var tmp = Cast(ressourceManagerFunctionUDT ptr,o)
	If tmp = 0 Then Return 0
	
	If this.fileExtension<>tmp->fileExtension Then Return 0
	If this.actionVar<>tmp->actionVar Then Return 0
	If this.actionVarDEL<>tmp->actionVarDEL Then Return 0
	Return 1
End Function

Function ressourceManagerFunctionUDT.getFileExtension As String
	Return fileExtension
End Function

Function ressourceManagerFunctionUDT.action(path As String) As Any Ptr
	If actionVar = 0 Then Return 0
	Return actionVar(path)
End Function

Sub ressourceManagerFunctionUDT.actionDEL(data_ As Any ptr)
	If data_ = 0 Or actionVarDEL = 0 Then Return
	actionVarDEL(data_)
End Sub


Type ressourceManagerDataUDT extends utilUDT
	Private:
		As String path,title,fileExtension
		As Any Ptr resData
		As Any Ptr mutex
	Public:
		Declare Constructor(title As String,path As String,fileExtension As String,resData As Any Ptr=0)
		Declare Destructor
		Declare Function equals(o As utilUDT Ptr) As Integer
		Declare Function getFileExtension As String
		Declare Function getpath As String
		Declare Sub setData(resData As Any Ptr)
		Declare Function getData As Any Ptr
		Declare Function getTitle As String
		Declare Sub Lock	
		Declare Sub unLock	
End Type

Constructor ressourceManagerDataUDT(title As String,path As String,fileExtension As String,resData As Any Ptr=0)
	this.title = title
	this.path = path
	this.fileExtension = fileExtension
	this.resData = resData
	mutex = mutexcreate
End Constructor

Destructor ressourceManagerDataUDT
	MutexDestroy mutex
End Destructor

Function ressourceManagerDataUDT.equals(o As utilUDT Ptr) As Integer
	If o=0 Then Return 0
	Var tmp = Cast(ressourceManagerDataUDT ptr,o)
	If tmp = 0 Then Return 0
	
	If this.title<>tmp->title Then Return 0
	If this.path<>tmp->path Then Return 0
	If this.fileExtension<>tmp->fileExtension Then Return 0
	If this.resData<>tmp->resData Then Return 0
	Return 1
End Function

Function ressourceManagerDataUDT.getFileExtension As String
	Return fileExtension
End Function

Function ressourceManagerDataUDT.getpath As String
	Return path
End Function

Function ressourceManagerDataUDT.getTitle As String
	Return title
End Function

Function ressourceManagerDataUDT.getData As Any ptr
	Return resData
End Function

Sub ressourceManagerDataUDT.setData(resData As Any Ptr)
	this.resData = resData
End Sub

Sub ressourceManagerDataUDT.Lock
	MutexLock mutex
End Sub

Sub ressourceManagerDataUDT.UnLock
	MutexUnLock mutex
End Sub

Type ressourceManagerUDT extends utilUDT
	Private:
		As stackUDT todoStack
		As UInteger size = 101
		As list_Type resList(0 To 100)
		As list_Type FuncList
	
		Declare Function getData(title As String) As ressourceManagerDataUDT	ptr	
	Public:
		Declare Sub load(title As String,path As String,fileExtension As String)
		Declare Sub loadFunction(fileExtension As String,actionVar As function(path As String) As Any ptr,actionVarDEL As Sub(data_ As Any ptr))
		Declare Sub update
		Declare Sub updateAll
		
		Declare Function getRessource(title As String) As Any Ptr
		Declare Sub LockRessource(title As String)
		Declare Sub UnLockRessource(title As String)
		Declare Sub freeRessource(title As String)
		Declare Sub freeAll
End Type

Function ressourceManagerUDT.getData(title As String) As ressourceManagerDataUDT Ptr
	Dim As ressourceManagerDataUDT Ptr r
	Dim As UInteger key = String2Hash(title,size)
	resList(key).reset
	
	Do
		r = Cast(ressourceManagerDataUDT Ptr,resList(key).getItem)
		If r <> 0 Then
			If r->getTitle = title Then
				Return r
			EndIf
		EndIf
	Loop Until r = 0
	
	Return 0
End Function

Sub ressourceManagerUDT.load(title As String,path As String,fileExtension As String)
	todoStack.push(New ressourceManagerDataUDT(title,path,fileExtension,0))
End Sub

Sub ressourceManagerUDT.loadFunction(fileExtension As String,actionVar As function(path As String) As Any ptr,actionVarDEL As Sub(data_ As Any ptr))
	FuncList.add(New ressourceManagerFunctionUDT(fileExtension,actionVar,actionVarDEL),1)
End Sub

Sub ressourceManagerUDT.update
	Var tmp = Cast(ressourceManagerDataUDT Ptr,todoStack.pop)
	If tmp = 0 Then Return
	Dim As UInteger key = String2Hash(tmp->getTitle,size)
	Dim As ressourceManagerFunctionUDT Ptr r
	FuncList.reset
	
	Do
		r = Cast(ressourceManagerFunctionUDT Ptr,FuncList.getItem)
		If r <> 0 Then
			If r->getFileExtension = tmp->getFileExtension Then
				tmp->setData(r->action(tmp->getPath))
				resList(key).add(tmp,1)
				Return 
			EndIf
		EndIf
	Loop Until r = 0
	
End Sub

Sub ressourceManagerUDT.updateAll
	do
		Var tmp = Cast(ressourceManagerDataUDT Ptr,todoStack.pop)
		If tmp = 0 Then Return
		Dim As UInteger key = String2Hash(tmp->getTitle,size)
		Dim As ressourceManagerFunctionUDT Ptr r
		FuncList.reset
		
		Do
			r = Cast(ressourceManagerFunctionUDT Ptr,FuncList.getItem)
			If r <> 0 Then
				If r->getFileExtension = tmp->getFileExtension Then
					tmp->setData(r->action(tmp->getPath))
					resList(key).add(tmp,1)
					Return 
				EndIf
			EndIf
		Loop Until r = 0
	loop
End Sub

Function ressourceManagerUDT.getRessource(title As String) As Any Ptr
	If title = "" Then Return 0
	Var tmp = getData(title)
	If tmp = 0 Then Return 0
	Return tmp->getData
End Function

Sub ressourceManagerUDT.freeRessource(title As String)
	If title = "" Then Return
	Dim As ressourceManagerDataUDT Ptr r
	Dim As ressourceManagerFunctionUDT Ptr f
	Dim As UInteger key = String2Hash(title,size)
	resList(key).reset
	Do
		r = Cast(ressourceManagerDataUDT Ptr,resList(key).getItem)
		If r <> 0 Then
			If r->getTitle = title Then
				resList(key).remove(r,1)			
				FuncList.reset
				Do
					f = Cast(ressourceManagerFunctionUDT Ptr,FuncList.getItem)
					If f <> 0 Then
						If f->getFileExtension = r->getFileExtension then
							f->actionDEL(r->getData)
							Return													
						EndIf
					EndIf
				Loop Until f = 0				
			EndIf
		EndIf
	Loop Until r = 0
End Sub

Sub ressourceManagerUDT.freeAll
	Dim As ressourceManagerDataUDT Ptr r
	Dim As ressourceManagerFunctionUDT Ptr f
	For key As Integer = 0 To UBound(resList)
		resList(key).reset
		Do
			r = Cast(ressourceManagerDataUDT Ptr,resList(key).getItem)
			If r <> 0 Then
				resList(key).remove(r,1)			
				FuncList.reset
				Do
					f = Cast(ressourceManagerFunctionUDT Ptr,FuncList.getItem)
					If f <> 0 Then
						If f->getFileExtension = r->getFileExtension then
							f->actionDEL(r->getData)
							Return													
						EndIf
					EndIf
				Loop Until f = 0				
			EndIf
		Loop Until r = 0
	next
End Sub

Type test extends utilUDT
	Declare Function toString As String
End Type

Function test.toString As String
	Return "oshrguioh"
End Function

Function test1(path As String) As Any Ptr
	Return New test
End Function

Sub test2(data_ As Any Ptr)
	Delete Cast(utilUDT Ptr,data_)
End Sub

Dim Shared As ressourceManagerUDT resMan
resMan.loadFunction(".test",@test1,@test2)
resMan.load("hallo","",".test")

resMan.updateAll
Dim As Double zeit = timer
Var t = Cast(utilUDT Ptr,resMan.getRessource("hallo"))
Dim As Double diff = Timer - zeit
Print diff
If t<>0 Then Print t->toString

sleep

