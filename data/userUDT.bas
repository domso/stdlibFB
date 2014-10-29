#Include Once "../store/store.bas"
#Include Once "containerUDT.bas"
'#Include Once "protocolUDT.bas"

Type userUDT
	As accountUDT Ptr acc
	As accountUDT Ptr tmp
	
	Declare Function login(item As networkData ptr,container As containerUDT ptr,client As clientUDT Ptr) As byte
	Declare Function registration(item As networkData ptr,container As containerUDT Ptr) As byte
End Type

Function userUDT.login(item As networkData Ptr,container As containerUDT Ptr,client As clientUDT ptr) As Byte
	'If network.IsServer=0 Then Return protocol.LOGIN_ERROR*-1
	'If item=0 Then Return protocol.LOGIN_ERROR*-1

	tmp= New accountUDT("")
	tmp->size=SizeOf(accountUDT)
	tmp->fromBinString(item->V_STRINGDATA)
	acc=Cast(accountUDT Ptr,container->Account.search(tmp))
	Delete tmp
	
	If acc<>0 Then
		'If client=0 Then Return protocol.LOGIN_ERROR*-1
		'if acc->inUse=1 then return protocol.LOGIN_INUSE_ERROR*-1
		'client->account=acc
		'acc->inUse=1
		'Return protocol.LOGIN_SUCCESS
	End If
	'Return protocol.LOGIN_ERROR*-1
	Return 0
End Function

Function userUDT.registration(item As networkData ptr,container As containerUDT Ptr) As Byte
	'If network.IsServer=0 Then Return  protocol.REGISTRATION_ERROR*-1
	'If item=0 Then Return  protocol.REGISTRATION_ERROR*-1
	
	tmp= New accountUDT("")
	tmp->size=SizeOf(accountUDT)
	tmp->fromBinString(item->V_STRINGDATA)
	acc=Cast(accountUDT Ptr,container->Account.search(tmp))
	Print tmp->acc_name
	If acc<>0 Then
		'Return  protocol.REGISTRATION_ERROR*-1
	Else
		Print container->CreateAccount(tmp)	
		'Return  protocol.REGISTRATION_SUCCESS
	EndIf
	'Return  protocol.UNKNOWN_ERROR*-1
	Return 0
End Function

Dim Shared As userUDT user

					
	