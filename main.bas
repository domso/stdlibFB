#Include Once "util/util.bas"
#Include Once "store/store.bas"
#Include Once "data/data.bas"
'#Include Once "3d/3d.bas"

 Print "init"
 'Dim As containerUDT container

'startdatathread(@container,1)
 
 Print "start server"
 network.CreateServer(9834,10)

startNetworkThread()
do
loop
'	
'loop
 'Do
 '	'cls
	'network.log.out
	'container.Account.out
	'Sleep 
 'Loop

