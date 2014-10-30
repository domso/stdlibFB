#include once "../util/util.bas"
#include once "../store/store.bas"
/'
protocol:
S: server
C: client

Stage 1: C -> S 
	authentication-request
	-> protocol: authstage1
		-> noreply
		-> permission: guest
		-> only client
stage 2: S -> C
	authentication-answer
	-> protocol: authstage2
		-> noreply
		-> permission: guest
		-> only server
stage 3: C -> S
	final authentication
	-> protocol: authstage3
		-> permission: guest
		-> only client
'/
Dim shared As protocolUDT Ptr authstage1
Dim shared As protocolUDT Ptr authstage2
Dim shared As protocolUDT Ptr authstage3

Sub check_authstage
	if authstage1 = 0 then
		FB_CUSTOMERROR_STRING = "missing authstage1"
		FB_CUSTOMERROR(*erfn(),*ermn())
	end if
	if authstage2 = 0 then
		FB_CUSTOMERROR_STRING = "missing authstage2"
		FB_CUSTOMERROR(*erfn(),*ermn())
	end if
	if authstage3 = 0 then
		FB_CUSTOMERROR_STRING = "missing authstage3"
		FB_CUSTOMERROR(*erfn(),*ermn())
	end if
end sub

function authstage1_function(ndata As networkData ptr,nclient as clientUDT ptr) As UBYTE
	check_authstage
	nclient->authstage = 1
	authstage2->send(ndata->V_TSNEID,0,0,"test",0,0) 'TBD!
	nclient->username = ndata->V_STRINGDATA
	Return 1
End function

function authstage2_function(ndata As networkData ptr,nclient as clientUDT ptr) As UBYTE
	check_authstage
	'TBD
	authstage3->send(ndata->V_TSNEID,0,0,"test",0,0) 'TBD!
	'Print ":::>>" + x->V_STRINGDATA
	Return 1
End function

function authstage3_function(ndata As networkData ptr,nclient as clientUDT ptr) As UBYTE
	check_authstage
	nclient->authstage = 2
	nclient->getRights.setRight(NORMAL)
	'Print ":::>>" + x->V_STRINGDATA
	Return 1
End function

'protocolUDT(titel As String,id As UByte,action As Any Ptr,Rights As UByte=NORMAL,noList As UByte=0)
authstage1 = New protocolUDT("authstage1",2,@authstage1_function,GUEST)
authstage1->noreply = 1
authstage1->onlyServer = 1

authstage2 = New protocolUDT("authstage2",3,@authstage2_function,GUEST)
authstage2->noreply = 1
authstage2->onlyClient = 1

authstage3 = New protocolUDT("authstage3",4,@authstage3_function,GUEST)
authstage3->onlyServer = 1

Sub start_authentication(username as String) '...
	check_authstage
	authstage1->send(1,0,0,username,0,0)
end sub

function check_authentication as byte 'returns: 1->success | -1->error | 0->nothing
	if authstage3->getSuccess then return 1
	if authstage3->getError then return -1
	return 0
end function
