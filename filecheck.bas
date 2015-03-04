Dim Shared As Integer windowx,windowy
windowx = 400
windowy = 280
ScreenRes windowx,windowy,32

#Include Once "util/util.bas"
#Include Once "util/CRC32_checksum.bas"
#Include Once "gui/gui.bas"
#Include Once "lang/lang.bas"


Dim Shared As list_type Ptr fullDirectoryList
Dim Shared As list_type Ptr fullFileList
Dim Shared As list_type Ptr fullFileList_update
Dim Shared As list_type Ptr fullDirectoryList_update
Dim Shared As list_type Ptr fullFileList_difference
Dim Shared As list_type Ptr fulldirectoryList_difference
Dim Shared As list_type ptr fullFileLoadList
Dim Shared As list_type ptr fullDirectoryLoadList
Dim Shared As directoryTreeUDT Ptr directoryTree
Dim Shared As UByte isValid

Dim Shared As String main_path,download_path,version_file,executeable_file,patcher_file
main_path = "."
download_path = "https://github.com/domso/noname/raw/master/"
version_file = "version.txt"
executeable_file = "test"
patcher_file = "filecheck"
GUI_SET(windowx,windowy,125,125,125)

addToIgnoreList(".bas")
addToIgnoreList(".bi")
addToIgnoreList(".txt")
addToIgnoreList(".conf")


'#########################################################################################################
#If Defined(__FB_WIN32__)
	executeable_file +=".exe"
	patcher_file     +=".exe"
#endif

If FileExists("old_"+patcher_file) Then
	Kill("old_"+patcher_file)
EndIf


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

SUb MSGlog_destroy
	MSGlog.clear
end SUb

add_destructor(@MSGlog_destroy)

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

Type GLOBAL_DIR_LOAD_UDT extends commandUDT
	Declare Constructor
	Declare virtual Function action(list As list_type Ptr,parent As Any Ptr=0) As UByte
End Type

Constructor GLOBAL_DIR_LOAD_UDT
	base("dir")
End Constructor

Function GLOBAL_DIR_LOAD_UDT.action(list As list_type Ptr,parent As Any Ptr=0) As UByte
	Dim As utilUDT Ptr tmp
	Dim As SubString Ptr tmp2
	
	Dim As String tmp_directory_name
	Dim As String tmp_directory_path
	Dim As list_type Ptr tmp_hash_list
	If fullDirectoryLoadList = 0 Then Return 0
	If list = 0 Then Return 0
	list->Reset
	tmp2 = Cast(SubString ptr,list->getItem)
	If tmp2->text<>this.CommandString Then Return 0
	tmp2 = Cast(SubString ptr,list->getItem)
	If tmp2=0 Then Return 0
	tmp_directory_name = tmp2->text
	tmp2 = Cast(SubString ptr,list->getItem)
	If tmp2=0 Then Return 0
	tmp_directory_path = tmp2->text
	
	Var F = New directoryTreeUDT(tmp_directory_path,tmp_directory_name)
	fullDirectoryLoadList->add(f,1)
	Return 1
End function

Dim As GLOBAL_FILE_LOAD_UDT Ptr GLOBAL_FILE_LOAD = New GLOBAL_FILE_LOAD_UDT
Dim As GLOBAL_DIR_LOAD_UDT Ptr GLOBAL_directory_LOAD = New GLOBAL_DIR_LOAD_UDT

'#########################################################################################################
Dim shared As Any Ptr action_exit_flag_mutex
action_exit_flag_mutex = mutexCreate
Sub action_exit_flag_mutex_destroy
	mutexdestroy action_exit_flag_mutex
end sub

add_destructor(@action_exit_flag_mutex_destroy)

Dim Shared As UByte action_exit_flag = 1

Function get_action_exit_flag As UByte
	MutexLock action_exit_flag_mutex
	Dim As UByte tmp = action_exit_flag
	MutexUnLock action_exit_flag_mutex
	Return tmp
End Function

Sub set_action_exit_flag(i As UByte)
	MutexLock action_exit_flag_mutex
	action_exit_flag = i
	MutexUnLock action_exit_flag_mutex
End Sub


Dim shared As Any Ptr update_process_mutex
update_process_mutex = mutexCreate
Dim Shared As Double update_process_var

Function get_update_process As Double
	MutexLock update_process_mutex
	Dim As Double tmp = update_process_var
	MutexUnLock update_process_mutex
	Return tmp
End Function

Sub set_update_process(i As Double)
	MutexLock update_process_mutex
	update_process_var = i
	MutexUnLock update_process_mutex
End Sub

Sub add_update_process(i As Double)
	MutexLock update_process_mutex
	update_process_var += i
	MutexUnLock update_process_mutex
End Sub

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
	set_update_process(0.0)
	Dim As Integer i
	Do
		tmp = Cast(fileUDT Ptr,fullFileList->getItem)
		If tmp <> 0 Then
			tmp->createCheckSum
			logMSG("checksum for "+tmp->file_name +" created!" )
			i+=1
			add_update_process(1/fullFileList->itemcount)
		EndIf
		If get_action_exit_flag Then
			logMSG("ABORT!",-2)
			Exit sub
		EndIf
	Loop Until tmp = 0
	set_update_process(1.0)
	logMSG("finish creating checksums",2)
End Sub

Sub saveVersion(file As String)
	logMSG("save version",1)
	If file = "" Then 
		logMSG("no version file",-1)
		Return
	EndIf
	If fullFileList = 0 or fullDirectoryList = 0 Then 
		logMSG("no file list (missing directoryLookUp?)",-1)
		Return
	EndIf
	
	Dim As Integer f = FreeFile
	Dim As fileUDT Ptr tmp	
	Dim As directoryTreeUDT Ptr tmpD	
	Dim As crc32_hash Ptr tmphash	
	Open file For output As #f	
	
		fullDirectoryList->resetB	
		Do
			tmpD = Cast(directoryTreeUDT Ptr,fullDirectoryList->getitem(1))
			If tmpD<>0 Then
				put #f,, "<dir<"+tmpD->directory_name+"/><"+tmpD->path+"/>"
				put #f,, "/>"
				Put #f,, Chr(13)+Chr(10) 'new line
			EndIf
		Loop Until tmpD = 0	
	
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
	fullDirectoryLoadList = New list_type
	Dim As String test
	test =  file2String(file)	
	Dim As list_type Ptr tmp = New list_type
	tmp = parseCommand(test)
	interpreter(tmp)
	tmp->Clear
	If isNew Then
		fullFileList_update = fullFileLoadList
		fullDirectoryList_update = fullDirectoryLoadList
		
		fullFileLoadList = 0
		fullDirectoryLoadList = 0
		logMSG("set new update version")
	Else
		fullFileList = fullFileLoadList
		fullDirectoryList = fullDirectoryLoadList
		fullFileLoadList = 0
		fullDirectoryLoadList = 0
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
	
	Dim As Integer i = fullFileList_update->itemcount
	set_update_process(0.0)
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
			add_update_process(1/fullFileList_update->itemcount)
			
		EndIf
		If get_action_exit_flag Then
			logMSG("ABORT!",-2)
			Exit sub
		EndIf
	Loop Until tmp = 0
	set_update_process(1.0)
'#########################################################
	If fulldirectoryList = 0 Then 
		logMSG("missing current version",-1)
		return
	EndIf
	If fulldirectoryList_update = 0 Then 
		logMSG("missing new version",-1)
		return
	EndIf
	If fulldirectoryList_difference <> 0 Then
		logMSG("delete old differences",-2)
		Delete fulldirectoryList_difference
	EndIf
	fulldirectoryList_difference = New list_type
	
	i = fulldirectoryList_update->itemcount
	set_update_process(0.0)
	fulldirectoryList_update->Reset
	fulldirectoryList->reset
	Dim As directoryTreeUDT Ptr tmpD
	Do
		tmpD = Cast(directoryTreeUDT Ptr,fulldirectoryList_update->getItem)
		If tmpD <> 0 Then
			If fulldirectoryList->search(tmpD) = 0 Then
				fulldirectoryList_difference->Add(tmpD,1)
				logMSG("found differences in: "+tmpD->directory_name)
			EndIf
			add_update_process(1/fulldirectoryList_update->itemcount)
			
		EndIf
		If get_action_exit_flag Then
			logMSG("ABORT!",-2)
			Exit sub
		EndIf
	Loop Until tmpD = 0
	set_update_process(1.0)
	
	logMSG("finish checking",2)
End Sub

Sub versionUpdate
	logMSG("update version",1)
	If fullFileList_difference = 0 Or fulldirectoryList_difference = 0 Then
		logMSG("no differences found (check4differences ?)",-1) 
		Return
	EndIf
	
	Dim As Byte completePatch=1
	Dim As fileUDT Ptr tmp
	Dim As fileUDT Ptr tmp2
	Dim As directoryTreeUDT Ptr tmpD
	fulldirectoryList_difference->Reset
	set_update_process(0)
	
	Do
		tmpD = Cast(directoryTreeUDT Ptr,fulldirectoryList_difference->getItem)
		If tmpD <> 0 Then
			
			If MkDir(tmpD->directory_path) Then
				logMSG("Could not create directory: "+tmpD->directory_path)
				completePatch = 0
			Else
				logMSG("Create directory: "+tmpD->directory_path)
			EndIf
			add_update_process(1/fulldirectoryList_difference->itemcount)		
		EndIf
	Loop Until tmpD = 0
	
	set_update_process(1)
	
	If fullDirectoryList_update <> 0 Then
		fullDirectoryList_update->Clear(1)
	EndIf
	
	
	fullFileList_difference->reset

	set_update_process(0.0)
	
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
					Name tmp2->path+tmp2->file_name,tmp2->path+"old_"+tmp2->file_name
				EndIf
			EndIf
			logMSG("start download: "+download_path + tmp->path + tmp->file_name)
			If download(download_path + tmp->path + tmp->file_name,tmp->path + tmp->file_name)=1 Then
				logMSG("download finished") 
				
				fullFileList->Add(tmp,1)
				saveVersion(version_file)
				
				If tmp2<>0 Then
					If tmp2->file_name = tmp->file_name Then
						logMSG("delete old file: "+"old_"+tmp2->file_name)
						If patcher_file = tmp2->file_name Then
							Run patcher_file
							FreeAll
						else
							Kill(tmp2->path+"old_"+tmp2->file_name)
						EndIf  
						fullFileList->remove(tmp2)
						
					EndIf
				EndIf
			Else
				logMSG("could not download file",-1)
				completePatch = 0
				If tmp2<>0 Then
					If tmp2->file_name = tmp->file_name Then
						Name (tmp2->path+"old_"+tmp2->file_name,tmp2->path+tmp2->file_name)
						logMSG("rename "+tmp2->path + "old_"+tmp2->file_name + " to " + tmp2->path + tmp2->file_name)
					End If
					fullFileList->remove(tmp2)
				End if
			EndIf

			add_update_process(1/fullFileList_difference->itemcount)
			'renameFile(
		EndIf
		If get_action_exit_flag Then
			logMSG("ABORT!",-2)
		EndIf
	Loop Until tmp = 0
	fullFileList_difference->clear(1)
	set_update_process(1.0)
	If fullFileList_update <> 0 Then
		fullFileList_update->Clear(1)
	EndIf
	
	If completePatch then
		logMSG("finish updating",2)
		isValid = 1
	Else
		logMSG("finish updating, but could not download all files",-1)
		isValid = 0
	End if
End Sub

'#########################################################################################################

Var NewGraphicIMG = New imgUDT(800,600,"NEW_GRAPHIC_BACKGROUND")
Line NewGraphicIMG->buffer,(0,0)-(800,600),RGBA(0,0,0,0),bf


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
	If isValid = 0 Then return
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
	set_action_exit_flag(0)
	
	disable_play_button
	disable_update_button
	directoryLookUp
	createCheckSum
	
	saveVersion(version_file)
	
	enable_play_button
	enable_update_button
	set_action_exit_flag(1)
End Sub

Sub repair
	If get_action_exit_flag = 1 Then
		set_update_process(0)
		Var i = ThreadCreate(@repairSub)
	Else
		set_action_exit_flag(1)
		set_update_process(0)
	End if
End Sub

Sub updateSub(x As Any Ptr)

	set_action_exit_flag(0)
	disable_play_button
	disable_repair_button
	
	'directoryLookUp
	'createCheckSum
	If download(download_path+"version.txt","./version_neu.txt") = 0 then
		logMSG("could not download version file",-1)
	Else
		loadVersion("version.txt")
		loadVersion("version_neu.txt",1)
		kill("version_neu.txt")
		check4differences
		versionUpdate
	End if
	enable_play_button
	enable_repair_button
	set_action_exit_flag(1)
End Sub

Sub update
	If get_action_exit_flag = 1 Then
		set_update_process(0)
		Var i = ThreadCreate(@updateSub)
	Else
		set_action_exit_flag(1)
		set_update_process(0)
	End If
End Sub

Sub play
	'startprogram(executeable_file)
	If Run(executeable_file) = -1 Then
		logMSG("could not execute client! Please repair version!",-1)
	EndIf
End Sub

Dim As variableUDT repairVar = "repair"
repairVar.data = @repair
repairVar.setPTR

Dim As variableUDT updateVar = "update"
updateVar.data = @update
updateVar.setPTR

Dim As variableUDT playVar = "play"
playVar.data = @play
playVar.setPTR

Dim As variableUDT msglist = "msglist"
msglist.data = @msgLog
msglist.setList

Dim shared As Double tmp_update_process
Dim As variableUDT update_process = "update_process"
update_process.data = @tmp_update_process
update_process.setPTR

'#########################################################################################################
Dim As String graphic_input_code 
graphic_input_code += "<setAll<0/><0/><"+Str(windowx)+"/><"+Str(windowy)+"/><0/><0/><8/><8/>/>"
graphic_input_code += "<color<52/><80/><101/><78/><89/><95/>/>"
graphic_input_code += "<window<<id_name<mainframe/>/><isfullscreen/>/>"
graphic_input_code +=  "<"

graphic_input_code +=  "<button<id_name<play/>/><background<NEW_GRAPHIC_BACKGROUND/>/><height<50/>/><width<"+Str(windowx-16)+"/>/><moveable<0/>/><resizeable<0/>/><action<var<play/>/>/><text<<text<test1/>/>/>/>/>"

graphic_input_code +=  "<button<id_name<update/>/><background<NEW_GRAPHIC_BACKGROUND/>/><height<50/>/><width<"+Str((windowx-24)/2)+"/>/><moveable<0/>/><resizeable<0/>/><action<var<update/>/>/><text<<text<test2/>/>/>/>/>"
graphic_input_code +=  "<r/>"
graphic_input_code +=  "<button<id_name<repair/>/><background<NEW_GRAPHIC_BACKGROUND/>/><height<50/>/><width<"+Str((windowx-24)/2)+"/>/><moveable<0/>/><resizeable<0/>/><action<var<repair/>/>/><text<<text<test2/>/>/>/>/>"

graphic_input_code +=  "<progressbar<height<25/>/><background<NEW_GRAPHIC_BACKGROUND/>/><width<"+Str(windowx-16)+"/>/><process<var<update_process/>/>/><moveable<0/>/><resizeable<0/>/><text<<text<test1/>/>/>/>/>"

graphic_input_code +=  "<msgbox<id_name<log/>/><background<NEW_GRAPHIC_BACKGROUND/>/><height<100/>/><width<"+Str(windowx-36)+"/>/><list<var<msglist/>/>/><moveable<0/>/><resizeable<0/>/><text<<text<test1/>/>/>/>/>"



graphic_input_code +="/>"
graphic_input_code +="/>"


Dim As list_type Ptr graphicList
graphicList = New list_type
graphicList = parseCommand(graphic_input_code)
interpreter(graphicList)
graphicList->Clear
Delete graphicList


'#########################################################################################################
disable_play_button

Sub gui

	Dim As Double zeit
	Do
		zeit = timer
		ScreenLock
		Cls
		GUI_UPDATE
		
		tmp_update_process = get_update_process
		
		ScreenUnLock
		Do
			Sleep 1,1
		Loop While (Timer-zeit) < (1/60)
	Loop
End Sub

gui
