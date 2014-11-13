#Include Once "linklist.bas"
#Include Once "CRC32_checksum.bas"
#Include Once "dir.bi"

Type fileUDT extends utilUDT
	As String file_name,path
	As list_type Ptr hashList
	Declare Constructor(path As String,file_name As String)
	Declare Function toString As String
	Declare Function equals(o As utilUDT Ptr) As Integer
	Declare Sub createCheckSum
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

Function fileUDT.equals(o As utilUDT Ptr) As Integer
	If o = 0 Then Return 0
	Dim As fileUDT Ptr tmp = Cast(fileUDT Ptr,o)
	Dim As crc32_hash Ptr tmpHash
	
	If this.file_name <> tmp->file_name Then Return 0
	If this.path <>  tmp->path Then Return 0
		
	If tmp->hashList = 0 Then
		If this.hashList = 0 Then
			Return 1
		EndIf
		Return 0
	EndIf
	If this.hashList = 0 Then
		If tmp->hashList = 0 Then
			Return 1
		EndIf
		Return 0
	EndIf
	
	This.hashlist->Reset
	tmp->hashList->Reset

	Do
		tmpHash = Cast(crc32_hash Ptr,this.hashlist->getItem)
		If tmpHash <> 0 Then
			If tmpHash->equals(Cast(crc32_hash Ptr,tmp->hashlist->getItem)) = 0 Then
				Return 0
			EndIf
		EndIf
	Loop Until tmpHash = 0
	
	
	Return 1
End Function

Sub fileUDT.createCheckSum
	hashList = crc32(path + file_name)
End Sub

Dim shared as list_type GLOBAL_FILE_IGNORE_LIST

type file_ignoreUDT extends utilUDT
	as String pattern
	Declare Constructor (pattern as String)
	Declare Function isValid(pattern as String) as Ubyte
end type

Constructor file_ignoreUDT (pattern as String)
	this.pattern = pattern
end Constructor

Function file_ignoreUDT.isValid(pattern as String) as Ubyte
	if instr(pattern,this.pattern)=0 then return 1
	return 0
end function

Sub addToIgnoreList(filePattern as String)
	GLOBAL_FILE_IGNORE_LIST.add(new file_ignoreUDT(filePattern),1)
	
End Sub

Function file_is_valid (pattern as String) as Ubyte
	Dim as file_ignoreUDT ptr tmp
	GLOBAL_FILE_IGNORE_LIST.reset
	do
		tmp = cast(file_ignoreUDT ptr,GLOBAL_FILE_IGNORE_LIST.getItem)
		if tmp <> 0 then
			if tmp->isValid(pattern)=0 then return 0
		end if
	loop until tmp = 0
	return 1
end Function

Type directoryTreeUDT extends utilUDT
	As String directory_name,path,directory_path
	
	As list_type file_list
	As list_type directory_list

	Declare Constructor(path As String,directory_name As String)
	Declare Destructor
	Declare Sub clearTree
	Declare Sub updateTree
	Declare virtual Function todo As Byte
	Declare virtual Function equals(o As utilUDT Ptr) As Integer
	Declare Function toString As String
	
	Declare Function getAllFiles As list_type ptr
	Declare Function getAllDirectories As list_type ptr
End Type

Constructor directoryTreeUDT(path As String,directory_name As String)
	this.directory_name = directory_name
	this.path = path
	If Right(directory_name,1)<>"/" and Right(directory_name,1)<>"\" Then
		directory_name += "/"
	EndIf
	directory_path = this.path + directory_name

End Constructor

Destructor directoryTreeUDT
	file_list.clear
	directory_list.clear
End Destructor

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
   	If tmp_file_name <> "." And tmp_file_name <> ".." and tmp_file_name <> "" Then
		if file_is_valid(tmp_file_name) then
			file_list.add(New fileUDT(this.path + this.directory_name ,tmp_file_name),1)
   		end if
   	EndIf
      tmp_file_name = DIR("",0)
   LOOP WHILE LEN(tmp_file_name)

   Dim AS String tmp_directory_name
   tmp_directory_name = DIR(directory_path+"*", fbDirectory)
   Do
   	If tmp_directory_name <> "." And tmp_directory_name <> ".." and tmp_directory_name <> "" Then
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
			tmp->Add(tmpl,1)
			Delete tmpl
		EndIf
	Loop Until tmpDTU = 0
	tmp->add(@file_list,1)
	Return tmp
End Function

Function directoryTreeUDT.getAllDirectories As list_type Ptr
	Dim As list_type Ptr tmp = New list_type
	directory_list.reset
	Dim As directoryTreeUDT Ptr tmpDTU
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

