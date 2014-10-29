#Include Once "../util/util.bas"
#Include Once "accountUDT.bas"
#Include Once "objUDT.bas"
#Include Once "characterUDT.bas"
#Include Once "inventoryUDT.bas"



Type containerUDT
	'Account
	As list_type Account
	As db_type Accountdb
	Declare Function CreateAccount(item As accountUDT Ptr) As Integer
	Declare Sub UpdateAccount(item As accountUDT Ptr) 
	
	
	As list_type obj(0 To 10000)
	As db_type objdb
	Declare Function createobj(item As objUDT Ptr) As Integer
	Declare Sub UpdateObj(item As objUDT Ptr) 
	
	As list_type character(0 To 10000) '0 -> client
	As characterUDT Ptr ownCharacter
	As db_type Characterdb
	Declare Function createcharacter(item As characterUDT Ptr) As Integer
	Declare Sub UpdateCharacter(item As characterUDT Ptr) 
	
	As list_type inventory 'only for client
	As db_type inventoryDB
	Declare Function createInventory(item As inventoryUDT Ptr) As Integer
	Declare Sub UpdateInventory(item As inventoryUDT Ptr) 
	
	Declare Constructor	
End Type




Constructor containerUDT
	Accountdb.size=SizeOf(accountUDT)
	Accountdb.title="accountdb"
	Accountdb.fileUpdate
	
	
	For i As Integer = 1 To  this.Accountdb.db_get_itemcount 'alle Accounts aus db setzen
		If this.Accountdb.db_get_index_value(i)=1 Then
			 	Dim as accountUDT Ptr tmp=New accountUDT("")
				
				Accountdb.db_get(i,tmp)
			
				tmp=Cast(accountUDT Ptr,tmp)
				
				If tmp->acc_name="" Then 
					'Accountdb.db_put_index_value(i,0)
				Else
					tmp->inUse=0
					Account.Add(tmp,1)	
				EndIf		
		EndIf
	Next
	objdb.size=SizeOf(objUDT)
	objdb.title="objdb"
	objdb.fileUpdate
	
	For i As Integer = 1 To  this.objdb.db_get_itemcount 'alle objs aus db setzen
		If this.objdb.db_get_index_value(i)=1 Then
			 	Dim As objUDT ptr tmp=New objUDT(0)
				objdb.db_get(i,tmp)
				If tmp->world=0 Then 
					'objdb.db_put_index_value(i,0)
				Else
					obj(tmp->world).Add(tmp,1)	
				EndIf		
		EndIf
	Next
	
	characterdb.size=SizeOf(characterUDT)
	characterdb.title="characterdb"
	characterdb.fileupdate
	characterdb.db_get_itemcount
	
	
	''inventoryDB.size=SizeOf(inventoryUDT)
	'inventoryDB.title="characterdb"
	'inventoryDB.fileupdate
End Constructor

Function containerUDT.createaccount(item As accountUDT Ptr) As Integer
	if item=0 then return 0
	If this.Account.search(item)<>0 Then Return 0
	Dim As Integer x=this.Accountdb.db_get_index
	item->id=x
	this.Accountdb.db_put(x,item)
	this.Account.add(item)
	Return item->id
End Function

Sub containerUDT.UpdateAccount(item As accountUDT Ptr)
	if item=0 then return
	Dim As Integer x=item->id
	this.Accountdb.db_put(x,item)
End Sub


Function containerUDT.createobj(item As objUDT Ptr) As Integer
	If item=0 Then Return 0
	If item->world=0 Then Return 0
	If item->world>UBound(this.obj) Then Return 0
	If this.obj(item->world).search(item)<>0 Then Return 0
	Dim As Integer x=this.objdb.db_get_index
	item->id=x
	this.objdb.db_put(x,item)
	this.obj(item->world).add(item)
	Return item->id
End Function
Sub containerUDT.UpdateObj(item As objUDT Ptr)
	if item=0 then return
	Dim As Integer x=item->id
	this.objdb.db_put(x,item)
End Sub

Function containerUDT.createcharacter(item As characterUDT Ptr) As Integer
	If item=0 Then Return 0
	Dim As Integer x=this.Characterdb.db_get_index
	item->id=x
	this.Characterdb.db_put(x,item)
	Return item->id
End Function

Sub containerUDT.UpdateCharacter(item As characterUDT Ptr)
	if item=0 then return
	Dim As Integer x=item->id
	this.Characterdb.db_put(x,item)
End Sub

Function containerUDT.createInventory(item As inventoryUDT Ptr) As Integer
	If item=0 Then Return 0
	Dim As Integer x=this.inventoryDB.db_get_index
	item->id=x
	this.inventoryDB.db_put(x,item)
	Return item->id
End Function


Sub containerUDT.UpdateInventory(item As inventoryUDT Ptr)
	if item=0 then return
	Dim As Integer x=item->id
	this.inventoryDB.db_put(x,item)
End Sub
'Dim Shared As containerUDT Ptr container