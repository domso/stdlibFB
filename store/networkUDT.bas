#Include Once "../util/util.bas"
#Include Once "clientUDT.bas"
#Include Once "networkMSG.bas"
#Include Once "networkData.bas"
#include once "TSNE_V3.bi"
'##############################################################################################################
Dim Shared G_Server     as UInteger                 'Eine Variable für den Server-Handel erstellen
Dim Shared ClientMutex  as Any Ptr                 'Wir erstellen ein MUTEX welches verhindert das mehrere verbindugen gleichzeitg auf das UDT zugreifen



'##############################################################################################################
'   Deklarationen für die Empfänger Sub Routinen erstellen
Declare Sub TSNE_Disconnected           (ByVal V_TSNEID as UInteger)
Declare Sub TSNE_Connected              (ByVal V_TSNEID as UInteger)
Declare Sub TSNE_NewData                (ByVal V_TSNEID as UInteger, ByRef V_Data as String)
Declare Sub TSNE_NewConnection          (ByVal V_TSNEID as UInteger, ByVal V_RequestID as Socket, ByVal V_IPA as String)
Declare Sub TSNE_NewConnectionCanceled  (ByVal V_TSNEID as UInteger, ByVal V_IPA as String)


Type networkUDT
	as Long RV 
	As UInteger G_Client
	as Integer BV 
	As UByte IsServer
	As list_type log
	As list_type Input
	As clientUDT Ptr serverCLIENT 
	Declare Function CreateServer(port As UShort,max_connection As UShort) As Byte 
	Declare Function CloseServerConnection As Byte 
	
	Declare Function CreateClient(adresse As String,port As UShort) As Byte 
	Declare Function CloseClientConnection As Byte 

	
	Declare Function Send(item As networkData Ptr,is2delete As Byte=0) As UByte 
	
	
	
	'Client
	As list_type clientList	
	Declare Function getClient(id As Integer) As clientUDT ptr
End Type


Dim Shared As networkUDT network


Function networkUDT.Send(item As networkData Ptr,is2delete As Byte=0) As UByte
	Dim As String tmp=item->toString 
	RV=TSNE_Data_Send(item->V_TSNEID,chr(Len(Str(Len(tmp))))+Str(Len(tmp))+tmp)
	If RV <> TSNE_Const_NoError Then                  
	    log.add(new networkMSG(TSNE_GetGURUCode(RV),0),1)        
	    If is2delete=1 Then Delete item                    
	    Return 0                                         
	End If
	If is2delete=1 Then Delete item	
	Return 1
End Function

Function networkUDT.CreateServer(port As UShort,max_connection As UShort) As Byte 
	IsServer=1
	ClientMutex = MutexCreate()                                                              
	Log.add(new networkMSG("[SERVER] Init...",1),1)                         
	RV = TSNE_Create_Server(G_Server,port, max_connection, @TSNE_NewConnection, @TSNE_NewConnectionCanceled)
	
	If RV <> TSNE_Const_NoError Then                  
	    log.add(new networkMSG(TSNE_GetGURUCode(RV),0),1)  
	    MutexDestroy(ClientMutex)                       
	    log.add(new networkMSG( "[END]",1),1)                                
	    Return 0                                         
	End If
	
	log.add(new networkMSG( "[OK]",1 ),1)                            
	
	RV = TSNE_BW_SetEnable(G_Server, TSNE_BW_Mode_Black)   
	If RV <> TSNE_Const_NoError Then                 
	    log.add(new networkMSG(TSNE_GetGURUCode(RV),0),1)  
	    MutexDestroy(ClientMutex)                       
	    log.add(new networkMSG( "[END]",1),1)                              
	    Return 0                                           
	End If	

	Return 1
End function

Function networkUDT.CloseServerConnection As Byte
	log.add(new networkMSG( "Disconnecting...",1),1)                
	RV = TSNE_Disconnect(G_Server)                     
	
	If RV <> TSNE_Const_NoError Then log.add(new networkMSG(TSNE_GetGURUCode(RV),0),1)   
	log.add(new networkMSG( "Wait disconnected...",1 ),1)            

	TSNE_WaitClose(G_Server)   
	                      
	log.add(new networkMSG( "Disconnected!",1),1)                     
	MutexLock(ClientMutex)                              
	Dim TID as UInteger                                
	'For X as UInteger = 1 to ClientC                    
	'    If ClientD(X).V_InUse = 1 Then                  
	'        TID = ClientD(X).V_TSNEID                   
	'        MutexUnLock(ClientMutex)                    
	'        TSNE_Disconnect(TID)                       
	'        MutexLock(ClientMutex)                     
	'    End IF
	'Next
	MutexUnLock(ClientMutex)                            
	MutexDestroy(ClientMutex)                          
	log.add(new networkMSG( "[END]",1),1)                                 
	Return 1   
End Function

Function networkUDT.CreateClient(adresse As String,port As UShort) As Byte 
	IsServer=0
	log.add(new networkMSG(  "[INIT] Client...",1),1)                       'Programm beginnen
  
	
	log.add(new networkMSG(  "[Connecting]",1),1)
	BV = TSNE_Create_Client(G_Client,adresse, port, @TSNE_Disconnected, @TSNE_Connected, @TSNE_NewData, 60)
	
	If BV <> TSNE_Const_NoError Then
	    log.add(new networkMSG(TSNE_GetGURUCode(BV),0),1)
	    Return 0
	End If
	
	log.add(new networkMSG(  "[OK]",1  ),1)
	Return 1
End Function

Function networkUDT.CloseClientConnection As Byte
	log.add(new networkMSG( "[WAIT] ...",1),1)
	TSNE_WaitClose(G_Client)
	log.add(new networkMSG( "[WAIT] OK",1),1)
	log.add(new networkMSG( "[END]",1),1)
	
	Return 1 
End Function

Function networkUDT.getClient(id As Integer) As clientUDT Ptr
	If this.isServer=1 then
		Dim As clientUDT Ptr tmp,tmp2
		tmp=New clientUDT(id)
		tmp2=Cast(ClientUDT Ptr,clientList.search(tmp))
		Delete tmp
		Return tmp2
	Else
		If serverCLIENT = 0 Then
			serverCLIENT = New ClientUDT(1)
		EndIf
		Return serverCLIENT
	End if
End Function
