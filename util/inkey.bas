#include once "utilUDT.bas"
#include once "deleteUDT.bas"

Dim shared as any ptr inkeyInputStreamMutex
Dim shared as String inkeyInputStream
inkeyInputStreamMutex = MutexCreate

Sub FreeinkeyInputStreamMutex
	mutexdestroy inkeyInputStreamMutex
end Sub

add_destructor(@FreeinkeyInputStreamMutex)

Sub updateInkey
	Dim as String s
	s +=inkey
	if s = chr(255,107) then
		freeAll
	else
		mutexlock inkeyInputStreamMutex
		inkeyInputStream+=s			
		mutexunlock inkeyInputStreamMutex
	end if
end Sub

Function getInkey as String
	mutexlock inkeyInputStreamMutex
	Dim as String s = mid(inkeyInputStream,1,1)
	if s = chr(255) then
		s += mid(inkeyInputStream,2,1)
		inkeyInputStream = mid(inkeyInputStream,3)
	else
		inkeyInputStream = mid(inkeyInputStream,2)
	end if
	mutexunlock inkeyInputStreamMutex
	return s
end Function

