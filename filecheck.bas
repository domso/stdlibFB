#Include Once "util/util.bas"
#Include Once "util/CRC32_checksum.bas"

Dim Shared As list_type Ptr fullDirectoryList
Dim Shared As list_type Ptr fullFileList

Dim Shared As list_type Ptr fullFileList_update
Dim Shared As list_type Ptr fullFileList_difference

Dim Shared As list_type ptr fullFileLoadList

Dim Shared As directoryTreeUDT Ptr directoryTree

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

Dim Shared As String main_path,download_path
main_path = "."
download_path = "https://github.com/domso/noname/raw/master/"

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
	fullFileList = directoryTree->getAllFiles
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

Sub msgLogThread(x As Any Ptr)
	do
		msgLog.out
		msgLog.clear
		Sleep 100,1
	loop
End Sub

Var x = ThreadCreate(@msgLogThread)
beep
directoryLookUp
createCheckSum
loadVersion("version.txt",1)
check4differences
'fullFileList_difference->out
versionUpdate
SaveVersion("version.txt")
'
'fullFileLoadList.out


sleep
