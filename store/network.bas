'##############################################################################################################
'TEST-SERVER für TSNE Version 3
'##############################################################################################################



'##############################################################################################################
#include once "TSNE_V3.bi"                          'Die TCP Netzwerkbibliotek integrieren
#Include Once "../util/util.bas"
#Include Once "networkMSG.bas"
#Include Once "networkData.bas"
#Include Once "networkUDT.bas"


'##############################################################################################################
Sub TSNE_Disconnected(ByVal V_TSNEID as UInteger)   'Empfänger für das Disconnect Signal (Verbindung beendet)
                           
	network.clientTable.free(V_TSNEID,1)
                       

End Sub



'##############################################################################################################
Sub TSNE_Connected(ByVal V_TSNEID as UInteger)         
	Dim As clientUDT Ptr tmp_client = New clientUDT(V_TSNEID)
	If tmp_client <> 0 then
		tmp_client->con_time = timer
	End If
	network.storeClient(V_TSNEID,tmp_client)                   
End Sub



'##############################################################################################################
Sub TSNE_NewConnection(ByVal V_TSNEID as UInteger, ByVal V_RequestID as Socket, ByVal V_IPA as String)      'Empfänger für das NewConnection Signal (Neue Verbindung)
	Dim TNewTSNEID as UInteger                         
	Dim TReturnIPA as String                            
	                            
	Dim RV as Long       
                             
	'MutexLock(ClientMutex)



	RV = TSNE_Create_Accept(V_RequestID, TNewTSNEID, TReturnIPA, @TSNE_Disconnected, @TSNE_Connected, @TSNE_NewData)    'Da wir noch platz haben akzeptieren wir die verbindung mit den Callbacks
	


	

	If RV <> TSNE_Const_NoError Then                  
	    network.log.Add(New networkMSG(TSNE_GetGURUCode(RV),1),1)
	End If
	'MutexUnLock(ClientMutex)
End Sub



'##############################################################################################################
Sub TSNE_NewConnectionCanceled(ByVal V_TSNEID as UInteger, ByVal V_IPA as String)
	network.log.Add(New networkMSG("Request Blocked   IPA:" & V_IPA,0),1)
End Sub


Dim Shared As Integer zahl=0
Dim Shared As String TSNE_NEWDATA_STRING
'##############################################################################################################
Sub TSNE_NewData(ByVal V_TSNEID as UInteger, ByRef V_Data as String)    'Empfänger für neue Daten
Dim As String tmp = V_Data
'TSNE_NEWDATA_STRING+= V_DATA


	Do
		If tmp="" Then Exit do
		Dim As Integer SizeOfLen=Asc(tmp,1)
		Dim As Integer size=Val(Mid(tmp,2,SizeOfLen))
		If network.isServer=0 Then
			If V_TSNEID<>1 Then
				tmp=Mid(tmp,2+SizeOflen+size)
				Continue do
			EndIf
		EndIf
		
		network.input.push(New networkData(V_TSNEID,Mid(tmp,2+SizeOflen,size)))
		tmp=Mid(tmp,2+SizeOflen+size)
	Loop Until tmp=""
	

End Sub
