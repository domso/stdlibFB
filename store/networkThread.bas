#Include Once "../util/util.bas"
#Include Once "networkData.bas"
#Include Once "clientUDT.bas"
#Include Once "permissionUDT.bas"
#Include Once "networkMSG.bas"
#Include Once "networkUDT.bas"
#Include Once "protocolUDT.bas"


Sub networkThread(tmpType As Any Ptr)
	Dim As networkData ptr tmp
	Dim As ClientUDT ptr client
	
	Do
		
	


		Do
			network.input.reset
			tmp=Cast(networkData Ptr,network.input.getItem)
			If tmp<>0 Then
				client=network.getClient(tmp->V_TSNEID)
				useProtocol(tmp,client)
				network.input.remove(tmp)
			EndIf
		Loop Until tmp = 0
		
		
		
	'/
		Sleep 10,1
	loop
End Sub

Dim Shared As Any Ptr dataUpdateThread
Sub StartnetworkThread
	dataUpdateThread=ThreadCreate(@networkThread)
End Sub

/'
Sub ServerdataThread(tmpType As any ptr)
	Dim As networkData ptr tmp
	
	'Dim As ClientUDT ptr client
	'Dim As CharacterUDT Ptr character
	'Dim As CharacterUDT Ptr character2
	'
	'Dim As InventoryUDT Ptr inventory
	'Dim As objUDT Ptr obj
	'
	'Dim As Byte CharacterPermission
	'Dim As containerUDT Ptr container=Cast(containerUDT Ptr,tmpType)
	
	Dim As Integer freeCharacterSlot
	/'
	Do
		container->objdb.fileUpdate '???
		network.input.reset
		Do
			tmp=Cast(networkData Ptr,network.input.getItem)
			If tmp<>0 Then
				client=network.getClient(tmp->V_TSNEID)
				If client<>0 Then				
					If client->account=0 Then
						Select Case tmp->V_TYPE
							Case protocol.LOGIN
								Var tmp_return = user.login(tmp,container,client)
								If tmp_return>0 Then
									protocol.success_msg(tmp->V_TSNEID,tmp_return)
								Else
									protocol.error_msg(tmp->V_TSNEID,tmp_return*-1)
								EndIf

							Case protocol.REGISTRATION
								Var tmp_return = user.registration(tmp,container)
								If tmp_return>0 Then
									protocol.success_msg(tmp->V_TSNEID,tmp_return)
								Else
									protocol.error_msg(tmp->V_TSNEID,tmp_return*-1)
								EndIf
						End Select 
					Else
						Select Case tmp->V_TYPE
							Case protocol.NEW_CHARACTER
 								freeCharacterSlot=client->account->addNewChar
								If freeCharacterSlot<>0 Then
									character = New CharacterUDT("")
									character->size=SizeOf(CharacterUDT)
									character->fromBinString(tmp->V_STRINGDATA)
									
									Var inv=New InventoryUDT()
									character->InvID=container->createInventory(inv)
									Delete inv
									
									client->account->char(freeCharacterSlot)=container->createcharacter(character)
									container->UpdateAccount(client->account)
									protocol.success_msg(tmp->V_TSNEID,protocol.CREATE_CHARACTER_SUCCESS)
								Else
									protocol.error_msg(tmp->V_TSNEID,protocol.CREATE_CHARACTER_ERROR)									
								EndIf
							Case protocol.SELECT_CHARACTER
									'If client->character<>0 Then
									'	protocol.error_msg(tmp->V_TSNEID,protocol.SELECT_CHARACTER_ERROR)
									'EndIf
									For i As Integer = 1 To 10
										If client->account->char(i)<>0 Then
											character=New CharacterUDT("")
											container->Characterdb.db_get(client->account->char(i),character)
											character->size=SizeOf(CharacterUDT)
 											character->changed=0
 											
 											character2= New CharacterUDT("")
											character2->size=SizeOf(CharacterUDT)
											character2->fromBinString(tmp->V_STRINGDATA)
 											character2->ID=character->id
 											
 											If character->equals(character2)=1 Then
 												protocol.success_msg(tmp->V_TSNEID,protocol.SELECT_CHARACTER_SUCCESS)
 												character->changed=1
 												
 												'container->character(character->world).reset
 												'do
												'	character2=Cast(characterUDT Ptr,container->character(character->world).getItem())					
												'	If character2<>0 Then
												'		'character2->changed=1
												'	End if
												'Loop Until character2=0
 												
 												client->load=0
 												client->character=character
 												container->character(character->world).add(character,1)
 												container->character(0).add(character,1)
 											Else
 												protocol.error_msg(tmp->V_TSNEID,protocol.SELECT_CHARACTER_ERROR)
 											EndIf
 											
 											Delete character2
 											If client->character<>0 Then
 												Exit For
 											Else
 												Delete character
 											EndIf
 											
										EndIf
									Next
						
							Case protocol.GET_OWN_CHARACTER

								If client->account<>0 then
									For i As Integer = 1 To 10
										If client->account->char(i)<>0 Then
											
											character=New CharacterUDT("")
											container->Characterdb.db_get(client->account->char(i),character)
											character->size=SizeOf(CharacterUDT)
 											'network.Send(New  networkData(tmp->V_TSNEID,0,0,protocol.CHARACTER,character->toBINString,0,0))
 											Delete character
										EndIf
									Next

									protocol.success_msg(tmp->V_TSNEID,protocol.GET_OWN_CHARACTER_SUCCESS)
								Else

									protocol.error_msg(tmp->V_TSNEID,protocol.UNKNOWN_ERROR)
								End If
							Case protocol.GET_OWN_INVENTORY
								If client->account<>0 And client->character<>0 Then
									If client->character->invID<>0 Then
										inventory=New InventoryUDT()
										container->inventoryDB.db_get(client->character->invID,inventory)
										inventory->size=SizeOf(inventoryUDT)
										network.Send(New  networkData(tmp->V_TSNEID,0,0,protocol.INVENTORY,inventory->toBINString,0,0))
										Delete inventory
										protocol.success_msg(tmp->V_TSNEID,protocol.GET_OWN_INVENTORY_SUCCESS)
										Exit Select
									EndIf
								EndIf
								protocol.error_msg(tmp->V_TSNEID,protocol.UNKNOWN_ERROR)
							Case protocol.GET_OBJECT
								container->obj(client->character->world).reset

								do
									obj=Cast(objUDT Ptr,container->obj(client->character->world).getItem())	
		
									If obj<>0 Then
										If obj->changed=1 Then

											network.Send(New  networkData(client->tsneID,0,0,protocol.OBJECT,obj->toBINString,0,0))
										End If
									End if
								Loop Until obj=0
								
								protocol.success_msg(tmp->V_TSNEID,protocol.GET_OBJECT_SUCCESS)
							Case protocol.CHARACTER_ACTION
								Select case tmp->V_STATE
									Case protocol.ACTION_CHARACTER_POSITION
										If client->character<>0 then
											character= New characterUDT("")
											character->size=SizeOf(characterUDT)
											character->fromBinString(tmp->V_STRINGDATA)
											client->character->posX=character->posX										
											client->character->posY=character->posY										
											client->character->posZ=character->posZ
											client->character->changed=1
											Delete character	
									
																				
										End if
									Case protocol.ACTION_CHARACTER_USE_ITEM
										'????
									Case protocol.ACTION_CHARACTER_USE_SKILL
										'????
								End Select						
						End Select						
					End if
				End if
				network.input.remove(tmp)
			End if
		Loop Until tmp=0
		container->character(0).reset
		do
			character=Cast(characterUDT Ptr,container->character(0).getItem())
			If character<>0 Then
				If character->toDEL=1 Then
					container->character(0).remove(character,1)
					container->character(character->world).remove(character,1)
					Delete character
				EndIf

			End if
		Loop Until character=0
	
		MutexLock(ClientMutex)  
		network.clientList.reset
		do
			client=Cast(clientUDT Ptr,network.clientList.getItem())
			If client<>0 then
				If client->character<>0 Then
					character=client->character
					container->character(character->world).reset
					do
						character2=Cast(characterUDT Ptr,container->character(character->world).getItem())					
						If character2<>0 Then
							If character2->changed=1 Or client->load=0 Then
								'character2->changed=0
								If character=character2 Then
									character2->isOwnCharacter=1
								Else
									character2->isOwnCharacter=0
								EndIf
								network.Send(New  networkData(client->tsneID,0,0,protocol.CHARACTER,character2->toBINString,0,0))
							End if
						End if
					Loop Until character2=0

					
					container->obj(character->world).reset
					do
						obj=Cast(objUDT Ptr,container->obj(character->world).getItem())					
						If obj<>0 Then
							If obj->changed=1 Or client->load=0 Then
								network.Send(New  networkData(client->tsneID,0,0,protocol.OBJECT,obj->toBINString,0,0))
								'obj->changed=0
							End If
						End if
					Loop Until obj=0


				EndIf
				client->load=1
			End if
		Loop Until client=0

		network.clientList.reset
		do
			client=Cast(clientUDT Ptr,network.clientList.getItem())
			If client<>0 then
				If client->character<>0 Then
					character=client->character
					container->character(character->world).reset
					do
						character2=Cast(characterUDT Ptr,container->character(character->world).getItem())					
						If character2<>0 Then
							character2->changed=0
						End if
					Loop Until character2=0
					container->obj(character->world).reset
					do
						obj=Cast(objUDT Ptr,container->obj(character->world).getItem())					
						If obj<>0 Then
							obj->changed=0
						End if
					Loop Until obj=0
				EndIf
			End if
		Loop Until client=0
		
		MutexUnLock(ClientMutex)  

		Sleep 1,1
	Loop
	'/
	
	Exit Sub
End Sub

Sub ClientdataThread(tmpType As any ptr)
	Dim As networkData ptr tmp
	
	'Dim As ClientUDT ptr client
	'Dim As CharacterUDT Ptr character
	'Dim As InventoryUDT Ptr Inventory
	'Dim As objUDT Ptr obj
	'

	'Dim As containerUDT Ptr container=Cast(containerUDT Ptr,tmpType)
	
/'
	Do
		network.input.reset
		Do
			tmp=Cast(networkData Ptr,network.input.getItem)
			If tmp<>0 Then
				Select Case tmp->V_TYPE
					Case protocol.MESSAGE
						
						
					Case protocol.ERROR_MESSAGE
						protocol.error_log.add(New utilUDT(tmp->V_STATE))
					Case protocol.SUCCESS_MESSAGE
						protocol.success_log.add(New utilUDT(tmp->V_STATE))	
					Case protocol.CHARACTER
						character = New CharacterUDT("")
						character->size=SizeOf(CharacterUDT)
						character->fromBinString(tmp->V_STRINGDATA)
						
						
						'If tmp->V_INTEGERDATA=1 Then'And container->ownCharacter=0 Then
						'	container->ownCharacter=character
						'Else
							container->character(0).add(character,1)
						'EndIf
						
						
					Case protocol.OBJECT
						obj = New objUDT(0)
						obj->size=SizeOf(objUDT)
						obj->fromBinString(tmp->V_STRINGDATA)
						container->obj(0).add(obj,1)
					Case protocol.INVENTORY
						inventory = New InventoryUDT()
						inventory->size=SizeOf(InventoryUDT)
						inventory->fromBINString(tmp->V_STRINGDATA)
						container->inventory.add(inventory)
				End Select			
				network.input.remove(tmp)
			End if
		Loop Until tmp=0
		Sleep 1,1
	loop
	'/
	Exit Sub
End Sub
'
'Dim Shared As Any Ptr dataUpdateThread
'Sub StartDataThread(container As containerUDT Ptr,isServer As byte)
'	If isServer=1 then
'		dataUpdateThread=ThreadCreate(@ServerdataThread,container)
'	Else
'		dataUpdateThread=ThreadCreate(@ClientdataThread,container)
'	End if
'End Sub

'/
