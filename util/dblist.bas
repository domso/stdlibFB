#Include Once "file.bi"
#Include Once "linklist.bas"
#Include Once "utilUDT.bas"
#Include Once "dateUDT.bas"

Type db_meta_type extends utilUDT
	As dateUDT lastChange
	As dateUDT lastBackup
	As Integer size
End Type

Type db_type
	As Integer MaxIndex=0,fdata,findex,fmeta
	As Byte isOpen,useBackup
	As Integer backUpIntervall=7 'days
	As db_meta_type db_meta
	As list_type del_list
	
	As Integer size,old_size
	As String title
	As String directory
	Declare Sub db_put(index As Integer,item As any Ptr)
	Declare Sub db_get(index As Integer,item As Any Ptr)
	
	Declare Function db_get_itemcount As Integer
	Declare Function db_get_index As integer
	Declare Function db_put_index_value(index As Integer,item As byte) As byte
	Declare Function db_get_index_value(index As Integer) As byte
	Declare Sub db_del_index(index As Integer)
	Declare Sub db_resize
	Declare Sub Backup(title As String)
	Declare Sub fileUpdate
	
	
End Type



Sub db_type.fileUpdate
	If size=0 Then return
	If isOpen=0 Then
		If directory="" Then directory="."
		If Right(directory,1)<>"/" And Right(directory,1)<>"\"  Then directory+="/"
		MkDir directory+title
		MkDir directory+title+"/"+"backup"
	EndIf
	
	Dim As String tmp = CurDir
	chdir directory+title+"/"
	
	If isOpen=1 Then Close #fdata
	fdata=FreeFile	
	Open "data.db" For Binary As #fdata
	
	If isOpen=1 Then Close #findex
	findex=freefile
	Open "index.db" For Binary As #findex

	If isOpen=1 Then Close #fmeta
	fmeta=freefile
	Open "meta.db" For Binary As #fmeta	

	If isOpen=0 Then
		Dim As db_meta_type Ptr item
		item = New db_meta_type

		Get #fmeta,SizeOf(Any Ptr),*(Cast(UByte Ptr,Cast(Any Ptr,item))+SizeOf(Any Ptr)),SizeOf(db_meta_type)-SizeOf(Any Ptr)
		
		Var tmp = New dateUDT
		utilUDTrepair(tmp,@item->lastBackup)
		utilUDTrepair(tmp,@item->lastChange)
		Delete tmp


		If item->lastBackup.diff>=backUpIntervall Then
			Dim As dateUDT Ptr tmp = New dateUDT
			Backup(tmp->toString)
			item->lastBackup=*tmp
			Delete tmp
		EndIf
				
		'If item->size<>size And item->size<>0 Then
		'	old_size=item->size
		'	db_resize
		'EndIf
		item->size=size
		item->lastChange.today
	
		Put #fmeta,SizeOf(Any Ptr),*(Cast(UByte Ptr,Cast(Any Ptr,item))+SizeOf(Any Ptr)),SizeOf(db_meta_type)-SizeOf(Any Ptr)
		
	EndIf
	
	
	isOpen=1
	ChDir tmp
End Sub


Sub db_type.db_put(index As Integer,item As Any Ptr) 
	'Dim As integer f=FreeFile
	'Open title+".db" For Binary As #f
		Put #fdata,size*index,*Cast(UByte Ptr,item),size
	'Close #f	
End Sub

Sub db_type.db_get(index As Integer,item As any Ptr)
	'Dim As integer f=FreeFile		
	'Open title+".db" For Binary As #f
		get #fdata,size*index+SizeOf(Any Ptr),*(Cast(UByte Ptr,item)+SizeOf(Any Ptr)),size-SizeOf(Any Ptr)
	'Close #f
End Sub

Function db_type.db_get_itemcount As Integer
	'Dim As integer f=FreeFile	
	Dim As Integer count=1
	Dim As Byte tmp
	'Open title+"_index.db" For Binary As #f
			Do
				Get #findex,count,tmp
				If tmp=0 then  del_list.add(New utilUDT(count))
				count+=1

			Loop Until Eof(findex)

	'Close #f
	
	MaxIndex=count-1
	Return count-1
End Function

Function db_type.db_get_index As Integer
	del_list.reset
	Dim As Integer tmpINT
	Dim As utilUDT ptr tmp=del_list.getItem
	If tmp<>0 Then
		tmpINT=tmp->id
		del_list.remove(New utilUDT(tmp->id))
		db_put_index_value(tmpINT,1)
		Return tmpINT
	EndIf
	
	
	
	MaxIndex+=1
	db_put_index_value(MaxIndex,1)
	Return MaxIndex

	
End Function

Function db_type.db_put_index_value(index As Integer,item As byte) As Byte
	'Dim As integer f=FreeFile
	'Open title+"_index.db" For Binary As #f
		put #findex,index,item,1
	'Close #f	
	Return 0
End Function

Function db_type.db_get_index_value(index As Integer) As byte
	'Dim As integer f=FreeFile
	Dim As Byte tmp
	'Open title+"_index.db" For Binary As #f
		get #findex,index,tmp,1
		
	'Close #f	
	Return tmp
End Function

Sub db_type.db_del_index(index As Integer)
	db_put_index_value(index,0)
	del_list.add(New utilUDT(index))
End Sub

Sub db_type.db_resize
	
	Dim As Integer tmp=db_get_itemcount
	If size=0 Or old_size=0 Or tmp=0 Then Return

	For i As Integer = 0 To tmp-1
		Dim As Integer index = tmp-i
		Dim As Any Ptr item = Allocate(old_size)
		
		get #fmeta,old_size*index,*(Cast(UByte Ptr,item)+SizeOf(Any Ptr)),old_size
			
		Put #fmeta,size*index,*Cast(UByte Ptr,item),old_size
		DeAllocate(item)
	next


	'old_size=size
	'Put #fmeta,0,size
	'fileUpdate
End Sub
	
Sub db_type.Backup(title As String)
	If title="" Then Return
	MkDir directory+"backup/"+title
	Close #fdata
	Close #findex
	Close #fmeta

	FileCopy("data.db",directory+"backup/"+title+"/"+"data.db")
	FileCopy("index.db",directory+"backup/"+title+"/"+"index.db")
	FileCopy("meta.db",directory+"backup/"+title+"/"+"meta.db")
		

	fdata=FreeFile	
	Open "data.db" For Binary As #fdata
	findex=freefile
	Open "index.db" For Binary As #findex
	fmeta=freefile
	Open "meta.db" For Binary As #fmeta	
	
End Sub
