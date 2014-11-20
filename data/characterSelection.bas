#include once "../util/util.bas"
#include once "../store/store.bas"
/'
protocol:
S: server
C: client

	C -> S 
	characterSelection-request
	-> protocol: charSelrequest
		->onlyServer

	S -> C
	characterSelectionData
	-> protocol: charSelData
		-> noreply
		->onlyClient
	
	C-> S
	characterSelectionLoad
	-> protocol: charSelLoad
			->onlyServer
	
	C->S
	characterSelectionPlay
	->protocol: charSelPlay
		->onlyServer
		

'/
Dim shared as protocolUDT ptr charSelrequest
Dim shared as protocolUDT ptr charSelData
Dim shared as protocolUDT ptr charSelload
Dim shared as protocolUDT ptr charSelPlay

Sub check_charSelection
	if charSelrequest = 0 then
		FB_CUSTOMERROR_STRING = "missing charSelrequest"
		FB_CUSTOMERROR(*erfn(),*ermn())
	end if
	if charSelData = 0 then
		FB_CUSTOMERROR_STRING = "missing charSelData"
		FB_CUSTOMERROR(*erfn(),*ermn())
	end if
	if charSelload = 0 then
		FB_CUSTOMERROR_STRING = "missing charSelload"
		FB_CUSTOMERROR(*erfn(),*ermn())
	end if
	if charSelPlay = 0 then
		FB_CUSTOMERROR_STRING = "missing charSelPlay"
		FB_CUSTOMERROR(*erfn(),*ermn())
	end if
end sub

function charSelrequest_function(ndata As networkData ptr,nclient as clientUDT ptr) As UBYTE
	check_charSelection
	Return 1
End function

function charSeldata_function(ndata As networkData ptr,nclient as clientUDT ptr) As UBYTE
	check_charSelection
	Return 1
End function

function charSelload_function(ndata As networkData ptr,nclient as clientUDT ptr) As UBYTE
	check_charSelection
	Return 1
End function

function charSelplay_function(ndata As networkData ptr,nclient as clientUDT ptr) As UBYTE
	check_charSelection
	Return 1
End function

charSelrequest = New protocolUDT("charSelrequest",5,@charSelrequest_function)
charSelrequest->onlyServer = 1

charSelData = New protocolUDT("charSelData",6,@charSelData_function)
charSelData->onlyClient = 1
charSelData->noreply = 1

charSelload = New protocolUDT("charSelload",7,@charSelData_function)

charSelplay = New protocolUDT("charSelplay",8,@charSelData_function)
