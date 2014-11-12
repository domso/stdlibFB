Dim Shared As Integer windowx,windowy
windowx = 400
windowy = 400
ScreenRes windowx,windowy,32

#Include Once "util/util.bas"
#Include Once "util/CRC32_checksum.bas"
#Include Once "gui/gui.bas"
#Include Once "lang/lang.bas"


Dim Shared As list_type Ptr fullDirectoryList
Dim Shared As list_type Ptr fullFileList
Dim Shared As list_type Ptr fullFileList_update
Dim Shared As list_type Ptr fullFileList_difference
Dim Shared As list_type ptr fullFileLoadList
Dim Shared As directoryTreeUDT Ptr directoryTree


Dim Shared As String main_path,download_path
main_path = "."
download_path = "https://github.com/domso/noname/raw/master/"


GUI_SET(windowx,windowy,125,125,125)

addToIgnoreList(".bas")
addToIgnoreList(".bi")
addToIgnoreList(".txt")
addToIgnoreList(".conf")


'#########################################################################################################

 Dim Shared As list_type MSGlog
Type MSGlogUDT extends utilUDT
	As String msg
	Declare Constructor(msg As String,msg_type As Byte)
	Declare Function toString As String
End Type

Constructor MSGlogUDT(msg As String,msg_type As Byte)
	this.msg = "[" + Str(Time) + "]"
	If msg_type = 1 Then this.msg += "[START]"
	If msg_type = 2 Then this.msg += "[SUCCESS]"
	If msg_type = -1 Then this.msg += "[ERROR]"
	If msg_type = -2 Then this.msg += "[WARNING]"
	this.msg += ":>" + msg
End Constructor

Function MSGlogUDt.toString As String
	Return msg
End Function

Sub logMSG(msg As String,msg_type As Byte=0)
	MSGlog.add(New MSGlogUDT(msg,msg_type),1)
End Sub

'#########################################################################################################

Type GLOBAL_FILE_LOAD_UDT extends commandUDT
	Declare Constructor
	Declare virtual Function action(list As list_type Ptr,parent As Any Ptr=0) As UByte
End Type

Constructor GLOBAL_FILE_LOAD_UDT
	base("file")
End Constructor

Function GLOBAL_FILE_LOAD_UDT.action(list As list_type Ptr,parent As Any Ptr=0) As UByte
	Dim As utilUDT Ptr tmp
	Dim As SubString Ptr tmp2
	
	Dim As String tmp_file_name
	Dim As String tmp_file_path
	Dim As list_type Ptr tmp_hash_list
	If fullFileLoadList = 0 Then Return 0
	If list = 0 Then Return 0
	list->Reset
	tmp2 = Cast(SubString ptr,list->getItem)
	If tmp2->text<>this.CommandString Then Return 0
	tmp2 = Cast(SubString ptr,list->getItem)
	If tmp2=0 Then Return 0
	tmp_file_name = tmp2->text
	tmp2 = Cast(SubString ptr,list->getItem)
	If tmp2=0 Then Return 0
	tmp_file_path = tmp2->text
	tmp_hash_list = New list_type
	Do
		tmp2 = Cast(SubString ptr,list->getItem)
		If tmp2<>0 Then
			tmp_hash_list->Add(New crc32_hash(ValUInt(tmp2->text)),1)
		EndIf
	Loop Until tmp2 = 0
	Var F = New fileUDT(tmp_file_path,tmp_file_name)
	f->hashlist = tmp_hash_list
	fullFileLoadList->add(f,1)
	Return 1
End Function

Dim As GLOBAL_FILE_LOAD_UDT Ptr GLOBAL_FILE_LOAD = New GLOBAL_FILE_LOAD_UDT

'#########################################################################################################

Sub directoryLookUp
	logMSG("look up directory",1)
	If directoryTree <> 0 Then 
		logMSG("delete old directory tree",-2)
		Delete directoryTree
	EndIf
	logMSG("create new directory tree")
	directoryTree = New directoryTreeUDT(main_path,"")
	logMSG("update directory tree")
	directoryTree->updateTree
	logMSG("get all directories")
	If fullDirectoryList <> 0 Then
		logMSG("delete old directory List",-2)
		Delete fullDirectoryList
	EndIf
	fullDirectoryList = directoryTree->getAllDirectories
	logMSG("get all files")
	If fullFileList <> 0 Then
		logMSG("delete old file list",-2)
		Delete fullFileList
	EndIf
	FullFileList = directoryTree->getAllFiles
	logMSG("finish look up",2)
End Sub

Sub createCheckSum
	logMSG("create checksums",1)
	If fullFileList = 0 Then
		logMSG("no file list (missing directoryLookUp?)",-1)
		return
	EndIf
	Dim As fileUDT Ptr tmp
	fullFileList->Reset
	Do
		tmp = Cast(fileUDT Ptr,fullFileList->getItem)
		If tmp <> 0 Then
			tmp->createCheckSum
			logMSG("checksum for "+tmp->file_name +" created!" )
		EndIf
	Loop Until tmp = 0
	logMSG("finish creating checksums",2)
End Sub

Sub saveVersion(file As String)
	logMSG("save version",1)
	If file = "" Then 
		logMSG("no version file",-1)
		Return
	EndIf
	If fullFileList = 0 Then 
		logMSG("no file list (missing directoryLookUp?)",-1)
		Return
	EndIf
	
	Dim As Integer f = FreeFile
	Dim As fileUDT Ptr tmp	
	Dim As crc32_hash Ptr tmphash	
	Open file For output As #f	
		fullFileList->reset		
		Do
			tmp = Cast(fileUDT Ptr,fullFileList->getitem)
			If tmp<>0 Then
				put #f,, "<file<"+tmp->file_name+"/><"+tmp->path+"/>"
				If tmp->hashList<>0 then
					tmp->hashList->Reset
					Do
						tmphash = Cast(crc32_hash Ptr,tmp->hashList->getItem)
						If tmpHash <> 0 Then
							Put #f,,"<"
							Put #f,,Str(tmpHash->hash)							
							Put #f,,"/>"
						EndIf
					Loop Until tmpHash = 0
				End if
				put #f,, "/>"
				Put #f,, Chr(13)+Chr(10) 'new line
			EndIf
		Loop Until tmp = 0	
	Close #f
	logMSG("finish saving",2)
End Sub

Sub loadVersion(file As String,isNew As UByte=0)
	logMSG("load version",1)
	If file = "" Then
		logMSG("no version file",-1)
		Return
	EndIf
	fullFileLoadList = New list_type
	Dim As String test
	test =  file2String(file)	
	Dim As list_type Ptr tmp = New list_type
	tmp = parseCommand(test)
	interpreter(tmp)
	tmp->Clear
	If isNew Then
		fullFileList_update = fullFileLoadList
		fullFileLoadList = 0
		logMSG("set new update version")
	Else
		fullFileList = fullFileLoadList
		fullFileLoadList = 0
		logMSG("set new current version")
	EndIf
	logMSG("finish loading",2)
End Sub

Sub check4differences
	logMSG("check for version differences",1)
	If fullFileList = 0 Then 
		logMSG("missing current version",-1)
		return
	EndIf
	If fullFileList_update = 0 Then 
		logMSG("missing new version",-1)
		return
	EndIf
	If fullFileList_difference <> 0 Then
		logMSG("delete old differences",-2)
		Delete fullFileList_difference
	EndIf
	fullFileList_difference = New list_type
	
	fullFileList_update->Reset
	fullFileList->reset
	Dim As fileUDT Ptr tmp
	Do
		tmp = Cast(fileUDT Ptr,fullFileList_update->getItem)
		If tmp <> 0 Then
			If fullFileList->search(tmp) = 0 Then
				fullFileList_difference->Add(tmp,1)
				logMSG("found differences in: "+tmp->file_name)
			EndIf
		EndIf
	Loop Until tmp = 0
	
	
	
	logMSG("finish checking",2)
End Sub

Sub versionUpdate
	logMSG("update version",1)
	If fullFileList_difference = 0 Then
		logMSG("no differences found (check4differences ?)",-1) 
		Return
	EndIf
	
	fullFileList_difference->reset
	Dim As Byte completePatch=1
	Dim As fileUDT Ptr tmp
	Dim As fileUDT Ptr tmp2
	Do
		tmp = Cast(fileUDT Ptr,fullFileList_difference->getItem)
		If tmp <> 0 Then
			fullFileList->Reset
			Do
				tmp2 = Cast(fileUDT Ptr,fullFileList->getItem)
				If tmp2 <> 0 Then
					If tmp2->file_name = tmp->file_name Then
						Exit do
					EndIf
				EndIf
			Loop Until tmp2 = 0
			If tmp2<>0 Then
				If tmp2->file_name = tmp->file_name Then
					logMSG("rename "+tmp2->path + tmp2->file_name + " to " + tmp2->path + "old_"+tmp2->file_name)
					renameFile(tmp2->file_name,"old_"+tmp2->file_name,tmp2->path)
				EndIf
			EndIf
			logMSG("start download: "+download_path + tmp->path + tmp->file_name)
			If download(download_path + tmp->path + tmp->file_name,tmp->path + tmp->file_name)=1 Then
				logMSG("download finished") 
				
				If tmp2<>0 Then
					If tmp2->file_name = tmp->file_name Then
						logMSG("delete old file: "+"old_"+tmp2->file_name)
						deleteFile(tmp2->path+"old_"+tmp2->file_name)  
						fullFileList->remove(tmp2)
						fullFileList->Add(tmp,1)
					EndIf
				EndIf
			Else
				logMSG("could not download file",-1)
				completePatch = 0
				If tmp2<>0 Then
					If tmp2->file_name = tmp->file_name Then
						renameFile("old_"+tmp2->file_name,tmp2->file_name,tmp2->path)
						logMSG("rename "+tmp2->path + "old_"+tmp2->file_name + " to " + tmp2->path + tmp2->file_name)
					End If
					fullFileList->remove(tmp2)
				End if
			EndIf
			
			
			'renameFile(
		EndIf
	Loop Until tmp = 0
	fullFileList_difference->clear(1)
	If fullFileList_update <> 0 Then
		fullFileList_update->Clear(1)
	EndIf
	
	
	If completePatch then
		logMSG("finish updating",2)
	Else
		logMSG("finish updating, but could not download all files",-1)
	End if
End Sub

'#########################################################################################################

Sub msgLogThread(x As Any Ptr)
	do
		msgLog.out
		msgLog.clear
		Sleep 100,1
	loop
End Sub

'Var x = ThreadCreate(@msgLogThread)
'#########################################################################################################

Sub disable_play_button
	Dim As buttonUDT Ptr tmp = Cast(buttonUDT Ptr,get_window_graphic("mainframe","play"))
	If tmp = 0 Then Return
	tmp->isGrey = 1
	tmp->EnableMouseClick=0
	tmp->AllowMouseOverEffect=0
	tmp->wasChanged=1
End Sub

Sub enable_play_button
	Dim As buttonUDT Ptr tmp = Cast(buttonUDT Ptr,get_window_graphic("mainframe","play"))
	If tmp = 0 Then Return
	tmp->isGrey = 0
	tmp->EnableMouseClick=1
	tmp->AllowMouseOverEffect=1
	tmp->wasChanged=1
End Sub

Sub disable_update_button
	Dim As buttonUDT Ptr tmp = Cast(buttonUDT Ptr,get_window_graphic("mainframe","update"))
	If tmp = 0 Then Return
	tmp->isGrey = 1
	tmp->EnableMouseClick=0
	tmp->AllowMouseOverEffect=0
	tmp->wasChanged=1
End Sub

Sub enable_update_button
	Dim As buttonUDT Ptr tmp = Cast(buttonUDT Ptr,get_window_graphic("mainframe","update"))
	If tmp = 0 Then Return
	tmp->isGrey = 0
	tmp->EnableMouseClick=1
	tmp->AllowMouseOverEffect=1
	tmp->wasChanged=1
End Sub

Sub disable_repair_button
	Dim As buttonUDT Ptr tmp = Cast(buttonUDT Ptr,get_window_graphic("mainframe","repair"))
	If tmp = 0 Then Return
	tmp->isGrey = 1
	tmp->EnableMouseClick=0
	tmp->AllowMouseOverEffect=0
	tmp->wasChanged=1
End Sub

Sub enable_repair_button
	Dim As buttonUDT Ptr tmp = Cast(buttonUDT Ptr,get_window_graphic("mainframe","repair"))
	If tmp = 0 Then Return
	tmp->isGrey = 0
	tmp->EnableMouseClick=1
	tmp->AllowMouseOverEffect=1
	tmp->wasChanged=1
End Sub

Sub repairSub(x As Any Ptr)
	disable_play_button
	disable_update_button
	
	directoryLookUp
	createCheckSum
	
	saveVersion("version.txt")
	
	enable_play_button
	enable_update_button
End Sub

Sub repair

	Var i = ThreadCreate(@repairSub)

End Sub


Sub updateSub(x As Any Ptr)
	disable_play_button
	disable_repair_button
	
	'directoryLookUp
	'createCheckSum
	download(download_path+"version.txt","./version_neu.txt")
	loadVersion("version.txt")
	loadVersion("version_neu.txt",1)
	check4differences
	
	enable_play_button
	enable_repair_button
End Sub

Sub update

	Var i = ThreadCreate(@updateSub)

End Sub

Sub test_push
	Dim As msgboxUDT Ptr tmp = Cast(buttonUDT Ptr,get_window_graphic("mainframe","log"))
	If tmp = 0 Then Return
	tmp->pushUp
	tmp->wasChanged=1
End Sub

Sub test_pushd
	Dim As msgboxUDT Ptr tmp = Cast(buttonUDT Ptr,get_window_graphic("mainframe","log"))
	If tmp = 0 Then Return
	tmp->pushDown
	tmp->wasChanged=1
End Sub

Dim As variableUDT repairVar = "repair"
repairVar.data = @repair
repairVar.setPTR

Dim As variableUDT updateVar = "update"
updateVar.data = @update
updateVar.setPTR

Dim As variableUDT beep1 = "disable_play_button"
beep1.Data = @test_push
beep1.setPTR

Dim As variableUDT beep2 = "disable_play_button2"
beep2.Data = @test_pushd
beep2.setPTR

Dim As variableUDT msglist = "msglist"
msglist.data = @msgLog
msglist.setList

Dim As Double update_process_var = 0.5
Dim As variableUDT update_process = "update_process"
update_process.data = @update_process_var
update_process.setPTR

'#########################################################################################################
Dim As String graphic_input_code 
graphic_input_code += "<setAll<0/><0/><"+Str(windowx)+"/><"+Str(windowy)+"/><0/><0/><8/><8/>/>"
graphic_input_code += "<window<<id_name<mainframe/>/><isfullscreen/>/>"
graphic_input_code +=  "<"

graphic_input_code +=  "<button<id_name<play/>/><height<50/>/><width<"+Str(windowx-16)+"/>/><moveable<0/>/><resizeable<0/>/><action<var<disable_play_button/>/>/><text<<text<test1/>/>/>/>/>"

graphic_input_code +=  "<button<id_name<update/>/><height<50/>/><width<"+Str((windowx-24)/2)+"/>/><moveable<0/>/><resizeable<0/>/><action<var<update/>/>/><text<<text<test2/>/>/>/>/>"
graphic_input_code +=  "<r/>"
graphic_input_code +=  "<button<id_name<repair/>/><height<50/>/><width<"+Str((windowx-24)/2)+"/>/><moveable<0/>/><resizeable<0/>/><action<var<repair/>/>/><text<<text<test2/>/>/>/>/>"

graphic_input_code +=  "<progressbar<height<25/>/><width<"+Str(windowx-16)+"/>/><process<var<update_process/>/>/><moveable<0/>/><resizeable<0/>/><text<<text<test1/>/>/>/>/>"

graphic_input_code +=  "<msgbox<id_name<log/>/><height<100/>/><width<"+Str(windowx-36)+"/>/><list<var<msglist/>/>/><moveable<0/>/><resizeable<0/>/><text<<text<test1/>/>/>/>/>"



graphic_input_code +="/>"
graphic_input_code +="/>"



Dim As list_type Ptr graphicList
graphicList = New list_type
graphicList = parseCommand(graphic_input_code)
interpreter(graphicList)
graphicList->Clear
Delete graphicList

'#########################################################################################################
cls
GLOBAL_INTERPRET_LOG.out
Sleep
Sub gui

	Dim As Double zeit
	Do
		zeit = timer
		ScreenLock
		Cls
		GUI_UPDATE
		
		ScreenUnLock
		Do
			Sleep 1,1
		Loop While (Timer-zeit) < (1/60)
	Loop
End Sub

gui
