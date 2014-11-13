ScreenRes 800,600,32

#Include Once "gui/buttonUDT.bas"
#Include Once "gui/panelUDT.bas"
#Include Once "gui/choiceUDT.bas"
#Include Once "gui/textfieldUDT.bas"
#Include Once "gui/checkboxUDT.bas"
#Include Once "gui/menuUDT.bas"
#Include Once "gui/groupUDT.bas"
#Include Once "gui/msgboxUDT.bas"
#Include Once "gui/windowUDT.bas"
#Include Once "gui/waitUDT.bas"
#Include Once "gui/progressBarUDT.bas"



Dim Shared As list_type Ptr tmpList
tmpList = New list_type()
Sub sub_beep
	tmpList->Clear
	beep
End Sub

Sub beenden
	end
End Sub

Dim Shared As textfieldUDT Ptr test2

Sub test_dis
	test2->enable=0	
End Sub

Sub test_en
	test2->enable=1	
End Sub

Dim As windowUDT Ptr p = New windowUDT()

Var test=New buttonUDT("BEEP",New pointUDT(100,100),50,30,@sub_beep)

p->AddGraphic(test)
test=New buttonUDT("BEEP",New pointUDT(200,100),50,30,@sub_beep)
p->AddGraphic(test)


Dim as double ttt
var tbar = new progressBarUDT(new pointUDT(100,400),200,50,@ttt)
p->AddGraphic(tbar)


var tt = new timerUDT(@ttt,0.5,0.01)



'####################################################################


Var testasd=New windowUDT("rhrzj","###3###",New pointUDT(200,400),200,200)


Var test3= New menuUDT("menu",New pointUDT(50,50),50,20,1)
testasd->AddGraphic(test3)
test3->Add("123")
test3->Add("456")
test3->Add("789")


Var test5=New menuUDT("menu2",New pointUDT(0,0),50,20,0)
test5->Add("abc")
test5->Add("end",@beenden)
test3->Add(test5)

Var test5a=New menuUDT("menu2",New pointUDT(0,0),50,20,0)
test5a->Add("sidfh")
test5a->Add("sub_beep",@sub_beep)
test3->Add(test5a)

Var test5b=New menuUDT("menu2",New pointUDT(0,0),50,20,0)
test5b->Add("sidfh")
test5b->Add("sub_beep",@sub_beep)
test5a->Add(test5b)




'####################################################################

Var test6= New ChoiceUDT(New pointUDT(250,50),100,20)
test6->Add("test_1")
test6->Add("test_2")
test6->Add("test_3")
test6->Add("BEEP",@sub_beep)
test6->Add("test_5")
test6->Add("test_6")
test6->Add("test_7")
test6->Add("test_8")
test6->Add("test_9")
test6->Add("FreeBASIC rules!")

'p->AddGraphic(test6)
'test5->Add(test6)

'####################################################################





Var test7= New groupUDT(New pointUDT(500,200),2,10)
test7->Add(New CheckboxUDT(New pointUDT(0,0),10,10,@test_en,@test_dis))
test7->Add(New CheckboxUDT(New pointUDT(0,0),10,10,@test_en,@test_dis))
test7->Add(New CheckboxUDT(New pointUDT(0,0),10,10,@test_en,@test_dis))
test7->Add(New CheckboxUDT(New pointUDT(0,0),10,10,@test_en,@test_dis))
p->AddGraphic(test7) 

'####################################################################

Var nix = New waitUDT(New pointUDT(500,300),10)
p->addGraphic(nix)
'####################################################################


Dim As  windowUDT Ptr  test9a=New windowUDT("asd0","###1###",New pointUDT(500,400),400,400)
Var test9b=New windowUDT("asd1","###2###",New pointUDT(500,200),100,100)
Var test9c=New windowUDT("asd2","###3###",New pointUDT(200,400),100,100)

'test9a->AddGraphic(test3)
	
test2=New textfieldUDT(New pointUDT(0,0),100,20)
test9c->AddGraphic(test2)
test2->noTextParse = 1
test2=0

test2=New textfieldUDT(New pointUDT(0,30),100,20)
test2->EnableSecretInput=1

test9c->AddGraphic(test2)
'
test2=New textfieldUDT(New pointUDT(0,60),100,20)
	'test2->Editable=0
test9c->AddGraphic(test2)

test9a->AddGraphic(test6)


Var test8= New msgboxUDT(New pointUDT(0,0),200,200,tmpList)
test8->EnableFullMove=1

test9a->AddGraphic(test8)


For i As Integer = 1 To 100
	tmpList->Add(New UtilUDT(i))
			
			'test8->wasChanged=1
Next


Dim As Integer i
Dim As Double zeit
Dim As Integer fps,fpscount


p->EnableMouse(1)

Do
	ScreenLock
	zeit=timer
	
	
	'test3->panel.update
	
	i+=1

	If i Mod 100=0 Then
		'tmpList->Add(New utilUDT(i),1)
			'test8->wasChanged=1
	EndIf
	'test8->wasChanged=1
	If i Mod 10=0 Then
		Cls
		Line(0,0)-(800,600),RGB(125,125,125),bf
		GUI_UPDATE
		'WindowTitle Str(GLOBAL_GUI_WINDOW_LIST.itemCount)
		fpscount+=1
		fps+=int(1/(Timer-zeit))
		WindowTitle(Str(int(fps/fpscount)))
	EndIf
	
	screenunlock
	Sleep 1,1
Loop


