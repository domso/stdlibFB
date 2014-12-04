#include once "interpreter.bas"

Function internal_StringInterpreter(in as String,parent as any ptr=0) as String
	GLOBAL_COMMAND_LIST.reset
	Dim As commandUDT Ptr tmp 	
	do
		tmp = cast(commandUDT ptr,GLOBAL_COMMAND_LIST.getItem)
		if tmp <> 0 then
			if isPrefixString(in,tmp->commandstring) then
				in = mid(in,len(tmp->commandString)+1)
				if tmp->action(0,parent) then return in
				logInterpret("Error in action",1)
				return in
			end if
		end if
	loop until tmp = 0	
	return in
End Function

Sub StringInterpreter(in as String,parent as any ptr=0,onlyStep as ubyte=0)
	Dim as String tmp,tmp2
	do
		tmp2 = tmp
		tmp = internal_StringInterpreter(in,parent)
	loop until onlyStep or tmp = tmp2
end sub
