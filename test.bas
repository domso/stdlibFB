ScreenRes 800,600,32
#Include Once "util/util.bas"
#Include Once "lang/cursor.bas"
#Include Once "lang/imgLoad.bas"
#Include Once "lang/graphics.bas"
#Include Once "lang/variables.bas"
#Include Once "lang/text.bas"
#Include Once "lang/window.bas"
#Include Once "lang/button.bas"
#Include Once "lang/menu.bas"
#Include Once "lang/choice.bas"
#Include Once "lang/checkbox.bas"
#Include Once "lang/img.bas"
#Include Once "lang/wait.bas"
#Include Once "lang/textfield.bas"
#Include Once "lang/msgbox.bas"
#Include Once "lang/progressBar.bas"
#Include Once "gui/gui.bas"




'Dim As String test = "hier wollen wir etwas herausparsen! <code <hallo/>  blub <hier auch noch/> /> und das auch <code2/>noch fett <code3/> schnell"
'Dim As String test = "sdfsdf <0/> abc123 <1<1.1/><1.1/><1.1<1.1<1.1/>/>/>/>"
'Dim As String test = "hallo <0/> <<<a/>b/>asdc/> du bob"
'<Window<attribute/><button<data/>/><textfield<data/>/>/> <img/>
'Dim As String test = "hier langer <setx<setX<345/>/>/> <r/><l/><n/><setState<r/>/><setAll<0/><0/><1600/><900/><0/><0/><25/><25/>/>     text"
Dim As String test = "<link<blub/>/>"   
'<<setX<450/>/><setY<125/>/> <setXY<125/><481/>/>/>text"
'asdasd<1<2/>/>sdgfsdg"

Dim As variableUDT testvar = "dings"
Dim As Integer testint = 100
testvar.Data = @testint
testvar.setInteger

Dim As variableUDT testvar2 = "blub"
Dim As String testString = "toller text"
testvar2.data = @testString
testvar2.setString


Dim As variableUDT testvar21 = "blub2"
testvar21.data = @testString
testvar21.setPTR

Dim As variableUDT testvarString = "tmpString"
Dim As String testString3 = "abc2"
testvarString.data = @testString3
testvarString.setstring

Sub testbeep
	Beep
End Sub

Dim As variableUDT testvar3 = "beep"
testvar3.Data = @testbeep
testvar3.setPTR

DIm as double processvar_double = 0
var tmpTimer = new timerUDT(@processvar_double,1,0.01)


Dim as variableUDT processvar = "processvar"
processvar.data = @processvar_double
processvar.setPTR


Dim As Double zeit = timer
test =  file2String("util/test.txt")	

'Print test
Dim As list_type Ptr tmp
'tmp = New list_type
tmp = parseCommand(test)


'tmp->Out

Dim As variableUDT testvar32  = "ilist"
testvar32.setList
'testvar32.Data = tmp 



Dim As variableUDT testvar322  = "ilist2"
testvar322.setList
Dim As list_type testvar322_list
for i as integer = 1 to 10 
	testvar322_list.add(New utilUDT())

next

testvar322.Data = @testvar322_list 

testvar32.Data = @testvar322_list 

interpreter(tmp)
tmp->Clear
Delete tmp


'interpreter(tmp)
'interpreter(tmp)
'tmp->Out
'sleep
'Print Timer-zeit
cls
GLOBAL_INTERPRET_LOG.out
sleep
'Dim As  windowUDT Ptr  test9a=New windowUDT("asd0","###1###",New pointUDT(500,400),400,400)
Dim As Integer i

Dim As Double fps
Do
	ScreenLock
	zeit=timer
	
	Cls
	Line(0,0)-(800,600),RGB(125,125,125),bf
	GUI_UPDATE
	'
	ScreenUnLock
	'Sleep ((100/6)-1000*(Timer-zeit)),1
	WindowTitle Str(1/(Timer-zeit))
	'Sleep 1,1
Loop

	Sleep
	
