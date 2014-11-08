#include once "../util/util.bas"
#include once "objUDT.bas"

Type worldUDT
	As String*9 world_name
	'... TBD
	As list_type obj
	As list_type player
	Declare Function getChanges as list_type ptr
	Declare Function getAll as list_type ptr
End Type


Function worldUDT.getChanges as list_type ptr
	Dim as objUDT ptr tmp	
	Dim as list_type ptr return_list = new list_type
	Dim as list_type ptr tmp_list
	
	obj.reset
	do
		tmp = cast(objUDT ptr,obj.getItem)
		if tmp <> 0 then
			tmp_list = tmp->getChanges
			return_list->add(tmp_list,1)
			delete tmp_list
			tmp_list = 0
			
		end if
	loop until tmp = 0
	player.reset
	do
		tmp = cast(objUDT ptr,player.getItem)
		if tmp <> 0 then
			tmp_list = tmp->getChanges
			return_list->add(tmp_list,1)
			delete tmp_list
			tmp_list = 0
			
		end if
	loop until tmp = 0
	
	return return_list
end Function

Function worldUDT.getAll as list_type ptr
	Dim as objUDT ptr tmp	
	Dim as list_type ptr return_list = new list_type
	Dim as list_type ptr tmp_list
	
	obj.reset
	do
		tmp = cast(objUDT ptr,obj.getItem)
		if tmp <> 0 then
			tmp_list = tmp->getAll
			return_list->add(tmp_list,1)
			delete tmp_list
			tmp_list = 0
			
		end if
	loop until tmp = 0
	player.reset
	do
		tmp = cast(objUDT ptr,player.getItem)
		if tmp <> 0 then
			tmp_list = tmp->getAll
			return_list->add(tmp_list,1)
			delete tmp_list
			tmp_list = 0
			
		end if
	loop until tmp = 0
	
	return return_list
end Function
