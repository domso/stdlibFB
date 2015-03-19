#Include Once "util/util.bas"
#Include Once "store/store.bas"
#Include Once "data/data.bas"
'#Include Once "3d/3d.bas"

 Print "init"
 'Dim As containerUDT container

'startdatathread(@container,1)
 
 Print "start server"
 
 network.CreateServer(9834,10)
 
 
 Var thread = StartnetworkThread(10)
 Var Thread2 = createControllerThread(1)

 Var tmpController = New controllerUDT(New objUDT(SizeOf(objUDT)))
 tmpController->worldID = 5
 '
 network.log.out
Sleep
thread->Stop
thread2->Stop
Delete thread
Delete thread2
network.CloseServerConnection





'Do
'	Sleep 10,1
'loop
'	
'loop
 'Do
 '	'cls
	'network.log.out
	'container.Account.out
	'Sleep 
 'Loop

