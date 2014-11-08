#Include Once "linklist.bas"
#Include Once "dir.bi"

Type fileUDT extends utilUDT
	As String file_name,path
	Declare Constructor(path As String,file_name As String)
	Declare Function toString As String
End Type

Constructor fileUDT(path As String,file_name As String)
	this.file_name = file_name
	this.path = path
	If Right(this.path,1)<>"/" and Right(this.path,1)<>"\" Then
		this.path += "/"
	EndIf
End Constructor

Function fileUDT.toString As String
	Return "File: " + path + file_name
End Function

Type directoryTreeUDT extends utilUDT
	As String directory_name,path,directory_path
	
	As list_type file_list
	As list_type directory_list

	Declare Constructor(path As String,directory_name As String)
	Declare Sub clearTree
	Declare Sub updateTree
	Declare Sub update_direct_directory_list
	Declare virtual Function todo As Byte
	Declare virtual Function equals(o As utilUDT Ptr) As Integer
	Declare Function toString As String
	
	Declare Function getAllFiles As list_type ptr
	Declare Function getAllDirectories As list_type ptr
End Type

Constructor directoryTreeUDT(path As String,directory_name As String)
	this.directory_name = directory_name
	this.path = path
	If Right(this.path,1)<>"/" and Right(this.path,1)<>"\" Then
		this.path += "/"
	EndIf
	If Right(directory_name,1)<>"/" and Right(directory_name,1)<>"\" Then
		directory_name += "/"
	EndIf
	directory_path = this.path + directory_name
End Constructor

Function directoryTreeUDT.equals(o As utilUDT Ptr) As Integer
	If o = 0 Then Return 0
	If this.directory_path = Cast(directoryTreeUDT Ptr,o)->directory_path Then Return 1
	Return 0
End Function

Function directoryTreeUDT.toString As String
	Return "Directory: " + directory_path
End Function

Sub directoryTreeUDT.clearTree
	file_list.clear
	directory_list.clear
End Sub

Function directoryTreeUDT.todo As Byte
	updateTree
	Return 1
End Function

Sub directoryTreeUDT.updateTree
	clearTree
	
	Dim AS String tmp_file_name
   tmp_file_name = DIR(directory_path+"*", 0)
   Do
   	If tmp_file_name <> "." And tmp_file_name <> ".." Then
   		file_list.add(New fileUDT(this.path + this.directory_name ,tmp_file_name),1)
   	EndIf
      tmp_file_name = DIR("",0)
   LOOP WHILE LEN(tmp_file_name)
   
   Dim AS String tmp_directory_name
   tmp_directory_name = DIR(directory_path+"*", fbDirectory)
   Do
   	If tmp_directory_name <> "." And tmp_directory_name <> ".." Then
   		Var tmp = New directoryTreeUDT(directory_path ,tmp_directory_name)
   		directory_list.add(tmp,1)
   	EndIf
      tmp_directory_name = DIR("",fbDirectory)
   LOOP WHILE LEN(tmp_directory_name)
   directory_list.execute
End Sub


Function directoryTreeUDT.getAllFiles As list_type Ptr
	Dim As list_type Ptr tmp = New list_type
	directory_list.reset
	Dim As directoryTreeUDT Ptr tmpDTU
	Do
		tmpDTU = Cast(directoryTreeUDT Ptr,directory_list.getItem)
		If tmpDTU <> 0 Then
			Var tmpl = tmpDTU->getAllFiles
			tmp->Add(tmpl)
			Delete tmpl
		EndIf
	Loop Until tmpDTU = 0
	tmp->add(@file_list)
	Return tmp
End Function

Function directoryTreeUDT.getAllDirectories As list_type Ptr
	Dim As list_type Ptr tmp = New list_type
	directory_list.reset
	Dim As directoryTreeUDT Ptr tmpDTU
	Dim As directoryTreeUDT Ptr tmpDTU2
	Do
		tmpDTU = Cast(directoryTreeUDT Ptr,directory_list.getItem)
		If tmpDTU <> 0 Then
			Var tmpl = tmpDTU->getAllDirectories
			tmp->Add(tmpl,1)
			Delete tmpl		
		EndIf
	Loop Until tmpDTU = 0
	
	tmp->add(@directory_list,1)
	Return tmp
End Function


Dim As directoryTreeUDT Ptr tmp = New directoryTreeUDT("../../../../","fbcc")
tmp->updateTree

tmp->getAllDirectories->out

Print "--"
sleep

