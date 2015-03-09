
#Include Once "util/util.bas"
#Include Once "store/store.bas"
#Include Once "data/data.bas"
'#Include Once "gui/gui.bas"


network.CreateClient("127.0.0.1",9834)
'sleep
StartnetworkThread()
start_authentication("Domso")

dim as byte r
do
	cls
	network.log.out
 
 
 protocolMSGList.out
 
 if r = 0 then
	r = check_authentication
	if r = 1 then
		print "yeah!"
		tmp->Send(1,0,0,"",0,0)
		sleep
	end if
	if r = -1 then
		print "error"
		tmp->Send(1,0,0,"",0,0)
		sleep
	end if
end if
	Sleep 100,1
loop
sleep
/'

Do
	cls
 network.log.out
 
 protocolMSGList.out
 Sleep 100,1
 'Sleep 1000,1
Loop
Dim As Double zeit
Do
	cls
 network.log.out
 
 protocolMSGList.out
 Print "---"
 Dim As String text
 Input text
 tmp->send(1,0,0,text,0,0)
 Sleep 100,1
 'Sleep 1000,1
Loop
'/
/'
#Include "3d/openb3d.bi"
#Define Render_opengl
#Include "3d/2d.bi"

ScreenRes 800 ,600 , 32 ', , &h10002
Graphics3d 800 ,600 ,32 ',2,1

#Include Once "util/util.bas"
#Include Once "store/store.bas"
#Include Once "data/data.bas"
#Include Once "gui/gui.bas"
#Include Once "3d/3d.bas"



 Dim shared As container3d container
 #Include Once "view/view.bas"
 startdatathread(@container,0)
 StartdataThread3D(@container)

 network.CreateClient("127.0.0.1",9834)
 loginView->enable=1
 'RegistrationView->enable=1
 
 load_loginView
 load_RegistrationView
 load_CharacterView
 load_CharacterCreateView
 load_MainGameView
 load_waitView
 load_networkView
 
 mainGameView3D.load
 
 
 Dim As Double zeit
Do
	zeit=timer
	'ScreenLock
	Cls	
		'Line(0,0)-(800,600),RGB(0,0,0),bf
		GUI_UPDATE
	
	If mainGameView3D.ownCharacter=0 then
		mainGameView3D.ownCharacter=container.ownCharacter3D
	End if
	'screenunlock
	mainGameView3D.update

	updateworld
	
	renderworld
	'
	ScreenSync
	WindowTitle Str(1/(Timer-zeit))
	Sleep 1,1
Loop

 
 '''''
 end
 '''''
 network.log.out
 

 
 Var tmp=New accountUDT("testblub")
 
 tmp->size=SizeOf(accountUDT)
 
 network.Send(New  networkData(1,0,0,protocol.LOGIN,tmp->toBINString,5,2.5))
 Do
 	cls
 	Print "wait!"
	Sleep 100,1
	If protocol.getError(protocol.LOGIN_ERROR)=1 Then Print protocol.error_string(protocol.LOGIN_ERROR) : Exit do
 Loop Until protocol.getSuccess(protocol.LOGIN_SUCCESS)=1
' 
' Var tmp2=New CharacterUDT("domso3")
' tmp2->size=SizeOf(characterUDT)
'network.Send(New  networkData(1,0,0,protocol.NEW_CHARACTER,tmp2->toBINString,5,2.5)) 

 do
 cls

 'container.character.out
Sleep 1000,1
 Loop

network.log.out 
 sleep '
 '/
