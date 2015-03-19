'##############################################################################################################
'##############################################################################################################
' TSNE_V3 - TCP Socket Networking [Eventing] Version: (see line 18 till 20)
'##############################################################################################################
'##############################################################################################################
' (c) 2009-.... By.: /_\ DeltaLab's Germany - Experimental Computing
' Autor: Martin Wiemann
' IRC: IRC://DeltaLabs.de/#mln
'##############################################################################################################
' Free for NON-comercial use! For comercial usage send me a mail -> FreeBasic[at]DeltaLabs.de or IRC and u get a free usage
'##############################################################################################################




#IFNDEF _TSNE_
    #DEFINE _TSNE_
    #Define TSNE_Version 3.7
    #Define TSNE_VersionDate 20131223
    #Define TSNE_VersionFull 3.7_20131223 (0.18.5 -> 0.91.0)
'>...

'Änderungen:
'TSNE_Version
'TSNE_GetHost, TSNE_GetIPA, TSNE_GetPort
'TSNE_NOSTRUCTOR (z.B. wenn tsne in win-dll, dann nötig & tsne init + term von hand)
'TCPQueSend


'##############################################################################################################
'BUGFIX for 0.18.5 fbc version inspired by: TJF -> http://www.freebasic.net/forum/viewtopic.php?f=3&t=19889&p=174666&hilit=tsne#p174535
#IF __FB_VERSION__ = "0.18.5"
    TYPE timeval
        tv_sec AS __time_t
        tv_usec AS __suseconds_t
    END TYPE
#ENDIF



'##############################################################################################################
#IF DEFINED(TSNE_SleepLock)
    Dim Shared TSNE_INT_SleepMutex      as Any Ptr
#ENDIF



'##############################################################################################################
#define EMFILE 24
#define ENFILE 23
#define ENOMEM 12
#IF DEFINED(TSNE_ERRNO)
    declare function errno cdecl alias "__errno_location" () as integer ptr ptr
#ENDIF

#IF DEFINED(__FB_LINUX__)
    #INCLUDE once "crt/stdlib.bi"
    #INCLUDE once "crt/unistd.bi"
    #INCLUDE once "crt/netdb.bi"
    #INCLUDE once "crt/sys/types.bi"
    #INCLUDE once "crt/sys/socket.bi"
    #INCLUDE once "crt/sys/select.bi"
    #INCLUDE once "crt/netinet/in.bi"
    #INCLUDE once "crt/arpa/inet.bi"
    #DEFINE IOCPARM_MASK &h7f
    #DEFINE IOC_IN &h80000000
    #DEFINE _IOW(x,y,t) (IOC_IN or ((t and IOCPARM_MASK) shl 16) or ((x) shl 8) or (y))
    #DEFINE FIONBIO _IOW(asc("f"), 126, sizeof(UInteger))
    #DEFINE h_addr h_addr_list[0]
    #DEFINE CloseSocket_(_a_) close_(_a_)
    #DEFINE INVALID_SOCKET (Cast(Socket, -1))
    #DEFINE TSNE_MSG_NOSIGNAL &h4000
    #DEFINE EINPROGRESS 36
#ELSEIF DEFINED(__FB_WIN32__)
    #DEFINE WIN_INCLUDEALL
    #INCLUDE once "windows.bi"
    #INCLUDE once "win\winsock.bi"
    #DEFINE close_(_a_) closesocket(_a_)
    #DEFINE memcpy(x__, y__, z__) movememory(x__, y__, z__)
    #DEFINE TSNE_MSG_NOSIGNAL &h0
    #DEFINE EINPROGRESS WSAEINPROGRESS
    Const IP_SUCCESS                = 0
    Const IP_DEST_NET_UNREACHABLE   = 1102
    Const IP_DEST_HOST_UNREACHABLE  = 1103
    Const IP_DEST_PROT_UNREACHABLE  = 1104
    Const IP_DEST_PORT_UNREACHABLE  = 1105
    Const IP_REQ_TIMED_OUT          = 11010
    Const IP_TTL_EXPIRED_TRANSIT    = 11013
    Type IP_Option_Information
        Ttl             as UByte
        Tos             as UByte
        Flags           as UByte
        OptionsSize     as UByte
        OptionsData     as UByte Ptr
    End type
    Type ICMP_Echo_Reply
        Adress          as in_addr
        Status          as UInteger
        RoundTripTime   as UInteger
        DataSize        as UShort
        Reserved        as UShort
        Data            as Any Ptr
        Options         as IP_Option_Information
    End Type
    #IF DEFINED(TSNE_PINGICMP)
        Declare Function IcmpCreateFile Lib "icmp.dll" () As Integer
        Declare Function IcmpCloseHandle Lib "icmp.dll" (ByVal IcmpHandle As Integer) As Integer
        Declare Function IcmpSendEcho Lib "icmp.dll" (ByVal IcmpHandle As Integer, ByVal DestinationAddress As in_addr, ByVal RequestData As String, ByVal RequestSize As Short, ByVal RequestOptions As Integer, ReplyBuffer As ICMP_Echo_Reply Ptr, ByVal ReplySize As Integer, ByVal TimeOut As Integer) As Integer
    #ENDIF
    #IFNDEF TSNE_NOSTRUCTOR
        Private Sub TSNE_INT_StartWinsock() CONSTRUCTOR 102
            Dim xwsa as WSADATA
            WSAStartup(MAKEWORD(2, 0), @xwsa)
        End Sub
        Private Sub TSNE_INT_EndWinsock() DESTRUCTOR 102
            WSAcleanup()
        End Sub
    #ENDIF
#ELSE
    #error "Unsupported platform"
#ENDIF
#INCLUDE once "crt/sys/time.bi"
#INCLUDE once "crt/fcntl.bi"
#Include once "vbcompat.bi"



#IFNDEF icmp
    Type icmphdr
        type        as UByte
        code        as UByte
        cksum       as UShort
        icd_id      as UShort
        icd_seq     as UShort
        ih_gateway  as UInteger
        unused      as UInteger
        mtu         as UInteger
    End Type

    #define ICMP_ECHOREPLY      0
    #define ICMP_DEST_UNREACH   3
    #define ICMP_SOURCE_QUENCH  4
    #define ICMP_REDIRECT       5
    #define ICMP_ECHO           8
    #define ICMP_TIME_EXCEEDED  11
    #define ICMP_PARAMETERPROB  12
    #define ICMP_TIMESTAMP      13
    #define ICMP_TIMESTAMPREPLY 14
    #define ICMP_INFO_REQUEST   15
    #define ICMP_INFO_REPLY     16
    #define ICMP_ADDRESS        17
    #define ICMP_ADDRESSREPLY   18
    #define NR_ICMP_TYPES       18

    #define ICMP_NET_UNREACH    0
    #define ICMP_HOST_UNREACH   1
    #define ICMP_PROT_UNREACH   2
    #define ICMP_PORT_UNREACH   3
    #define ICMP_FRAG_NEEDED    4
    #define ICMP_SR_FAILED      5
    #define ICMP_NET_UNKNOWN    6
    #define ICMP_HOST_UNKNOWN   7
    #define ICMP_HOST_ISOLATED  8
    #define ICMP_NET_ANO        9
    #define ICMP_HOST_ANO       10
    #define ICMP_NET_UNR_TOS    11
    #define ICMP_HOST_UNR_TOS   12
    #define ICMP_PKT_FILTERED   13
    #define ICMP_PREC_VIOLATION 14
    #define ICMP_PREC_CUTOFF    15
    #define NR_ICMP_UNREACH     15

    #define ICMP_REDIR_NET      0
    #define ICMP_REDIR_HOST     1
    #define ICMP_REDIR_NETTOS   2
    #define ICMP_REDIR_HOSTTOS  3

    #define ICMP_EXC_TTL        0
    #define ICMP_EXC_FRAGTIME   1

    Type ICMP
        icmp_type       as UByte
        icmp_code       as UByte
        icmp_cksum      as UShort
        icd_id          as UShort
        icd_seq         as UShort
        ih_pptr         as UByte
        ih_gwaddr       as in_addr
        ih_void         as UInteger
        ipm_void        as UShort
        ipm_nextmtu     as UShort
        irt_num_addrs   as UByte
        irt_wpa         as UByte
        irt_lifetime    as UShort

        #Define icmp_pptr       ih_pptr
        #Define icmp_gwadr      ih_gwadr
        #Define icmp_id         icd_id
        #Define icmp_seq        icd_seq
        #Define icmp_void       ih_void
        #Define icmp_pmvoid     ipm_void
        #Define icmp_nextmtu    ipm_nextmtu
        #Define icmp_num_addrs  irt_num_addrs
        #Define icmp_wpa        irt_wpa
        #Define icmp_lifetiem   irt_lifetime
    End Type
#ENDIF



'##############################################################################################################
'#DEFINE _TSNE_DODEBUG_
'#DEFINE _TSNE_DEBUG_IO_
'#DEFINE _TSNE_DEBUG_I_
'#DEFINE _TSNE_DEBUG_O_
#IF DEFINED(_TSNE_DEBUG_IO_)
    #IFNDEF _TSNE_DEBUG_I_
        #DEFINE _TSNE_DEBUG_I_
    #ENDIF
    #IFNDEF _TSNE_DEBUG_O_
        #DEFINE _TSNE_DEBUG_O_
    #ENDIF
#ENDIF




'##############################################################################################################
Dim Shared TSNE_INT_Thread_Master_Ptr           as Any PTR
Dim Shared TSNE_INT_Thread_Master_Close         as UByte
Dim Shared TSNE_INT_Mutex_Master                as Any PTR





'##############################################################################################################
Private Const TSNE_INT_BufferSize               as UInteger = 7936
Private Const TSNE_INT_TXSize                   as UInteger = 1440
Dim Shared    TSNE_INT_StackSize                as UInteger = 512000
#IF Defined(TSNE_ConstStackSizeOverride)
    TSNE_INT_StackSize = TSNE_ConstStackSizeOverride
#ENDIF
'--------------------------------------------------------------------------------------------------------------
Private Const TSNE_Const_UnknowError            as Integer = 0
Private Const TSNE_Const_NoError                as Integer = -1
Private Const TSNE_Const_UnknowEventID          as Integer = -2
Private Const TSNE_Const_NoSocketFound          as Integer = -3
Private Const TSNE_Const_CantCreateSocket       as Integer = -4
Private Const TSNE_Const_CantBindSocket         as Integer = -5
Private Const TSNE_Const_CantSetListening       as Integer = -6
Private Const TSNE_Const_SocketAlreadyInit      as Integer = -7
Private Const TSNE_Const_MaxSimConReqOutOfRange as Integer = -8
Private Const TSNE_Const_PortOutOfRange         as Integer = -9
Private Const TSNE_Const_CantResolveIPfromHost  as Integer = -10
Private Const TSNE_Const_CantConnectToRemote    as Integer = -11
Private Const TSNE_Const_TSNEIDnotFound         as Integer = -12
Private Const TSNE_Const_MissingEventPTR        as Integer = -13
Private Const TSNE_Const_IPAalreadyInList       as Integer = -14
Private Const TSNE_Const_IPAnotInList           as Integer = -15
Private Const TSNE_Const_ReturnErrorInCallback  as Integer = -16
Private Const TSNE_Const_IPAnotFound            as Integer = -17
Private Const TSNE_Const_ErrorSendingData       as Integer = -18
Private Const TSNE_Const_UnknowGURUcode         as Integer = -19
Private Const TSNE_Const_TSNENoServer           as Integer = -20
Private Const TSNE_Const_NoIPV6                 as Integer = -21
Private Const TSNE_Const_CantCreateSocketLimit  as Integer = -22
Private Const TSNE_Const_UnstableState          as Integer = -23
Private Const TSNE_Const_InternalError          as Integer = -99
'--------------------------------------------------------------------------------------------------------------
Private Enum TSNE_BW_Mode_Enum
    TSNE_BW_Mode_None   = 0
    TSNE_BW_Mode_Black  = 1
    TSNE_BW_Mode_White  = 2
End Enum




'##############################################################################################################
Private Enum TSNE_Event
    TSNE_E_Disconnect = 0
    TSNE_E_Connect = 1
    TSNE_E_NewConnection = 2
    TSNE_E_NewData = 3
End Enum
'--------------------------------------------------------------------------------------------------------------
Private Type TSNE_Event_Type
    #IF DEFINED(TSNE_SUBCALLBACK)
        'THX an TheMuh für die Idee.
        TSNE_Disconnected           as Sub  (ByVal V_TSNEID as UInteger, ByVal V_CallBackPtr as Any Ptr)
        TSNE_Connected              as Sub  (ByVal V_TSNEID as UInteger, ByVal V_CallBackPtr as Any Ptr)
        TSNE_NewData                as Sub  (ByVal V_TSNEID as UInteger, ByRef V_Data as String, ByVal V_CallBackPtr as Any Ptr)
    #ELSE
        TSNE_Disconnected           as Sub  (ByVal V_TSNEID as UInteger)
        TSNE_Connected              as Sub  (ByVal V_TSNEID as UInteger)
        TSNE_NewData                as Sub  (ByVal V_TSNEID as UInteger, ByRef V_Data as String)
    #ENDIF
    TSNE_NewConnection              as Sub  (ByVal V_TSNEID as UInteger, ByVal V_RequestID as Socket, ByVal V_IPA as String)
    TSNE_NewConnectionCanceled      as Sub  (ByVal V_TSNEID as UInteger, ByVal V_IPA as String)
    TSNE_NewDataUDP                 as Sub  (ByVal V_TSNEID as UInteger, ByVal V_IPA as String, ByRef V_Data as String)
    V_AnyPtr                        as Any Ptr
End Type





'##############################################################################################################
Private Type TSNE_INT_DNSIPA_Type
    V_Next                          as TSNE_INT_DNSIPA_Type Ptr
    V_Prev                          as TSNE_INT_DNSIPA_Type Ptr
    V_HostIPA                       as String
    V_InAddr                        as in_addr
    V_TimeOut                       as Double
End Type
'--------------------------------------------------------------------------------------------------------------
Dim Shared TSNE_INT_DNSIPAD         as TSNE_INT_DNSIPA_Type Ptr
Dim Shared TSNE_INT_DNSIPAL         as TSNE_INT_DNSIPA_Type Ptr
Dim Shared TSNE_INT_DNSIPA_Mutex    as Any Ptr




'##############################################################################################################
Private Type TSNE_BWL_Type
    V_Next                          as TSNE_BWL_Type Ptr
    V_Prev                          as TSNE_BWL_Type Ptr
    V_IPA                           as String
    V_LockTill                      as Double
End Type
'--------------------------------------------------------------------------------------------------------------
Private Enum TSNE_Protocol
    TSNE_P_TCP                       = 0
    TSNE_P_UDP                       = 1
End Enum





'##############################################################################################################
Private Type TSNE_Socket_Que
    V_Next                          as TSNE_Socket_Que Ptr
    V_Prev                          as TSNE_Socket_Que Ptr
    V_Data                          as String
End Type

Private Type TSNE_Socket
    V_Next                          as TSNE_Socket Ptr
    V_Prev                          as TSNE_Socket Ptr

    V_TSNEID                        as UInteger

    V_Event                         as TSNE_Event_Type
    V_Socket                        as Socket

    V_Prot                          as TSNE_Protocol
    V_IsServer                      as UByte
    V_Host                          as String
    V_IPA                           as String
    V_Port                          as UShort
    V_USP                           as SOCKADDR_IN

    T_DataIn                        as ULongInt
    T_DataOut                       as ULongInt

    T_ThreadOn                      as Integer
    T_Thread                        as Any Ptr

    V_BWL_UseType                   as UByte
    V_BWL_IPAD                      as TSNE_BWL_Type Ptr
    V_BWL_IPAL                      as TSNE_BWL_Type Ptr

    V_Que_F                         as TSNE_Socket_Que Ptr
    V_Que_L                         as TSNE_Socket_Que Ptr
End Type
'--------------------------------------------------------------------------------------------------------------
Dim Shared TSNE_INT_D               as TSNE_Socket Ptr
Dim Shared TSNE_INT_L               as TSNE_Socket Ptr
Dim Shared TSNE_INT_C               as UInteger
Dim Shared TSNE_INT_CC              as UInteger
Dim Shared TSNE_INT_Mutex           as Any Ptr





'##############################################################################################################
Declare Sub         TSNE_INT_Thread_Master      (ByVal I_Nothing as Any Ptr)
Declare Sub         TSNE_INT_Thread_Event       (ByVal V_TSNEID as Any Ptr)





'##############################################################################################################
Declare Function    TSNE_GetGURUCode                (ByRef V_GURUID as Integer) as String

Declare Function    TSNE_Stats                      (ByRef V_TSNEID as UInteger, ByRef R_RX as ULongInt, ByRef R_TX as ULongInt) as Integer
Declare Function    TSNE_Disconnect                 (ByRef V_TSNEID as UInteger) as Integer
Declare Function    TSNE_Create_Server              (ByRef R_TSNEID as UInteger, ByRef V_Port as UShort, ByRef V_MaxSimConReq as UShort = 10, ByVal V_Event_NewConPTR as Any Ptr, ByVal V_Event_NewConCancelPTR as Any Ptr = 0, ByVal V_StackSizeOverride as UInteger = TSNE_INT_StackSize) as Integer
Declare Function    TSNE_Create_ServerWithBindIPA   (ByRef R_TSNEID as UInteger, ByRef V_Port as UShort, ByRef V_IPA as String, ByRef V_MaxSimConReq as UShort = 10, ByVal V_Event_NewConPTR as Any Ptr, ByVal V_Event_NewConCancelPTR as Any Ptr = 0, ByVal V_StackSizeOverride as UInteger  = TSNE_INT_StackSize) as Integer
Declare Function    TSNE_Create_Client              (ByRef R_TSNEID as UInteger, ByVal V_IPA as String, ByVal V_Port as UShort, ByVal V_Event_DisconPTR as Any Ptr = 0, ByVal V_Event_ConPTR as Any Ptr = 0, ByVal V_Event_NewDataPTR as Any Ptr, ByVal V_TimeoutSecs as UInteger = 60, ByVal V_StackSizeOverride as UInteger = TSNE_INT_StackSize, ByVal V_WaitThreadRunning as UByte = 1, ByVal V_CallbackBackPtr as Any Ptr = 0) as Integer
Declare Function    TSNE_Create_Accept              (ByVal V_RequestID as Socket, ByRef R_TSNEID as UInteger, ByRef R_IPA as String = "", ByVal V_Event_DisconPTR as Any Ptr = 0, ByVal V_Event_ConPTR as Any Ptr = 0, ByVal V_Event_NewDataPTR as Any Ptr, ByRef R_RemoteShownServerIPA as String = "", ByVal V_StackSizeOverride as UInteger = TSNE_INT_StackSize, ByVal V_WaitThreadRunning as UByte = 1, ByVal V_CallbackBackPtr as Any Ptr = 0) as Integer
Declare Function    TSNE_Create_UDP_RX              (ByRef R_TSNEID as UInteger, ByVal V_Port as UShort, ByVal V_Event_NewDataUDPPTR as Any Ptr, ByVal V_StackSizeOverride as UInteger = TSNE_INT_StackSize, ByVal V_WaitThreadRunning as UByte = 1) as Integer
Declare Function    TSNE_Create_UDP_TX              (ByRef R_TSNEID as UInteger, ByVal V_DoBroadcast as UByte = 0) as Integer
Declare Function    TSNE_Data_Send                  (ByRef V_TSNEID as UInteger, ByRef V_Data as String, ByRef R_BytesSend as UInteger = 0, ByVal V_IPA as String = "", ByVal V_Port as UShort = 0, ByVal V_TCPQueSend as Integer = 0) as Integer

Declare Function    TSNE_Ping                       (ByVal V_IPA as String, ByRef R_Runtime as Double, ByVal V_TimeoutSecs as UByte = 10, ByVal V_ForceRAWPing as UByte = 0, ByVal V_FileIOMutex as Any Ptr = 0) as Integer

Declare Sub         TSNE_WaitClose                  (ByRef V_TSNEID as UInteger)
Declare Function    TSNE_WaitConnected              (ByRef V_TSNEID as UInteger, V_TimeOut as UInteger = 60) as Integer
Declare Function    TSNE_IsClosed                   (ByRef V_TSNEID as UInteger) as Integer

Declare Function    TSNE_BW_SetEnable               (ByVal V_Server_TSNEID as UInteger, V_Type as TSNE_BW_Mode_Enum) as Integer
Declare Function    TSNE_BW_GetEnable               (ByVal V_Server_TSNEID as UInteger, R_Type as TSNE_BW_Mode_Enum) as Integer
Declare Function    TSNE_BW_Clear                   (ByVal V_Server_TSNEID as UInteger) as Integer
Declare Function    TSNE_BW_Add                     (ByVal V_Server_TSNEID as UInteger, V_IPA as String, V_BlockTimeSeconds as UInteger = 3600) as Integer
Declare Function    TSNE_BW_Del                     (ByVal V_Server_TSNEID as UInteger, V_IPA as String) as Integer
Declare Function    TSNE_BW_List                    (ByVal V_Server_TSNEID as UInteger, ByRef R_IPA_List as TSNE_BWL_Type Ptr) as Integer




'##############################################################################################################
Private Function TSNE_INT_BW_GetPtr(ByRef V_TSNE as TSNE_Socket Ptr, ByRef V_IPA as String) as TSNE_BWL_Type Ptr
If V_TSNE = 0 Then Return 0
Dim TPtr as TSNE_BWL_Type Ptr = V_TSNE->V_BWL_IPAD
Do Until TPtr = 0
    If TPtr->V_IPA = V_IPA Then
'       If TPtr->V_LockTill
        Return TPtr
    End If
    TPtr = TPtr->V_Next
Loop
Return 0
End Function

'---------------------------------------------------------------------------------------------------------------
Private Sub TSNE_INT_BW_Clear(ByRef V_TSNE as TSNE_Socket Ptr)
If V_TSNE = 0 Then Exit Sub
Dim TPtr as TSNE_BWL_Type Ptr = V_TSNE->V_BWL_IPAD
Dim TNPtr as TSNE_BWL_Type Ptr
Do Until TPtr = 0
    TNPtr = TPtr->V_Next
    DeAllocate(TPtr)
    TPtr = TNPtr
Loop
End Sub

'---------------------------------------------------------------------------------------------------------------
Private Function TSNE_INT_BW_Del(ByRef V_TSNE as TSNE_Socket Ptr, ByRef V_IPA as String) as UByte
If V_TSNE = 0 Then Return 0
Dim TPtr as TSNE_BWL_Type Ptr = TSNE_INT_BW_GetPtr(V_TSNE, V_IPA)
If TPtr = 0 Then Return 0
If V_TSNE->V_BWL_IPAD = TPtr Then V_TSNE->V_BWL_IPAD = TPtr->V_Next
If V_TSNE->V_BWL_IPAL = TPtr Then V_TSNE->V_BWL_IPAL = TPtr->V_Prev
If TPtr->V_Prev <> 0 Then TPtr->V_Prev->V_Next = TPtr->V_Next
If TPtr->V_Next <> 0 Then TPtr->V_Next->V_Prev = TPtr->V_Prev
DeAllocate(TPtr)
Return 1
End Function

'---------------------------------------------------------------------------------------------------------------
Private Function TSNE_INT_BW_Add(ByRef V_TSNE as TSNE_Socket Ptr, ByRef V_IPA as String, ByVal V_BlockTimeSeconds as UInteger = 3600) as UByte
If V_TSNE = 0 Then Return 0
If TSNE_INT_BW_GetPtr(V_TSNE, V_IPA) <> 0 Then Return 0
If V_TSNE->V_BWL_IPAL <> 0 Then
    V_TSNE->V_BWL_IPAL->V_Next = CAllocate(SizeOf(TSNE_BWL_Type))
    V_TSNE->V_BWL_IPAL->V_Next->V_PreV = V_TSNE->V_BWL_IPAL
    V_TSNE->V_BWL_IPAL = V_TSNE->V_BWL_IPAL->V_Next
Else
    V_TSNE->V_BWL_IPAL = CAllocate(SizeOf(TSNE_BWL_Type))
    V_TSNE->V_BWL_IPAD = V_TSNE->V_BWL_IPAL
End If
V_TSNE->V_BWL_IPAL->V_IPA = V_IPA
V_TSNE->V_BWL_IPAL->V_LockTill = Now() + V_BlockTimeSeconds
Return 1
End Function





'##############################################################################################################
Private Function TSNE_INT_GetPtr(ByRef V_TSNEID as UInteger) as TSNE_Socket Ptr
If V_TSNEID = 0 Then Return 0
Dim TPtr as TSNE_Socket Ptr = TSNE_INT_D
Do Until TPtr = 0
    If TPtr->V_TSNEID = V_TSNEID Then Return TPtr
    TPtr = TPtr->V_Next
Loop
Return 0
End Function

'---------------------------------------------------------------------------------------------------------------
Private Function TSNE_INT_Del(ByRef V_TSNE as TSNE_Socket Ptr) as UByte
MutexLock(TSNE_INT_Mutex)
If V_TSNE = 0 Then MutexUnLock(TSNE_INT_Mutex): Return 0
If TSNE_INT_D = V_TSNE Then TSNE_INT_D = V_TSNE->V_Next
If TSNE_INT_L = V_TSNE Then TSNE_INT_L = V_TSNE->V_Prev
If V_TSNE->V_Prev <> 0 Then V_TSNE->V_Prev->V_Next = V_TSNE->V_Next
If V_TSNE->V_Next <> 0 Then V_TSNE->V_Next->V_Prev = V_TSNE->V_Prev
With *V_TSNE
    Do Until .V_Que_F = 0
        .V_Que_L = .V_Que_F->V_Next
        DeAllocate(.V_Que_F)
        .V_Que_F = .V_Que_L
    Loop
End With
TSNE_INT_BW_Clear(V_TSNE)
DeAllocate(V_TSNE)
V_TSNE = 0
MutexUnLock(TSNE_INT_Mutex)
Return 1
End Function

'---------------------------------------------------------------------------------------------------------------
Private Function TSNE_INT_Add() as TSNE_Socket Ptr
MutexLock(TSNE_INT_Mutex)
TSNE_INT_CC += 1
If TSNE_INT_CC = 0 Then TSNE_INT_CC += 1
Do Until TSNE_INT_GetPtr(TSNE_INT_CC) = 0
    TSNE_INT_CC += 1
    If TSNE_INT_CC = 0 Then TSNE_INT_CC += 1
Loop
If TSNE_INT_L <> 0 Then
    TSNE_INT_L->V_Next = CAllocate(SizeOf(TSNE_Socket))
    TSNE_INT_L->V_Next->V_PreV = TSNE_INT_L
    TSNE_INT_L = TSNE_INT_L->V_Next
Else
    TSNE_INT_L = CAllocate(SizeOf(TSNE_Socket))
    TSNE_INT_D = TSNE_INT_L
End If
Dim TPtr as TSNE_Socket Ptr = TSNE_INT_L
TPtr->V_TSNEID = TSNE_INT_CC
MutexUnLock(TSNE_INT_Mutex)
Return TPtr
End Function





'##############################################################################################################
#IF DEFINED(TSNE_NOSTRUCTOR)
    Private Sub TSNE_INT_Init()
    #IF DEFINED(__FB_WIN32__)
        Dim xwsa as WSADATA
        WSAStartup(MAKEWORD(2, 0), @xwsa)
    #ENDIF
#ELSE
    Private Sub TSNE_INT_Init() CONSTRUCTOR 101
#ENDIF
#IF DEFINED(TSNE_SleepLock)
    TSNE_INT_SleepMutex = MutexCreate
#ENDIF
TSNE_INT_Mutex = MutexCreate
TSNE_INT_Mutex_Master = MutexCreate
TSNE_INT_DNSIPA_Mutex = MutexCreate
MutexLock(TSNE_INT_Mutex_Master)
TSNE_INT_Thread_Master_Ptr = ThreadCreate(cast(Any Ptr, @TSNE_INT_Thread_Master), , TSNE_INT_StackSize)
MutexLock(TSNE_INT_Mutex_Master)
MutexUnLock(TSNE_INT_Mutex_Master)
End Sub

'--------------------------------------------------------------------------------------------------------------
#IF DEFINED(TSNE_NOSTRUCTOR)
    Private Sub TSNE_INT_Term()
    #IF DEFINED(__FB_WIN32__)
        WSAcleanup()
    #ENDIF
#ELSE
    Private Sub TSNE_INT_Term() DESTRUCTOR 101
#ENDIF
MutexLock(TSNE_INT_Mutex)
Dim TPtr as TSNE_Socket Ptr = TSNE_INT_D
Dim TNPtr as TSNE_Socket Ptr
Dim XTID as UInteger
Do until TPtr = 0
    TNPtr = TPtr->V_Next
    If TPtr->T_Thread <> 0 Then
        XTID = TPtr->V_TSNEID
        MutexUnLock(TSNE_INT_Mutex)
        TSNE_Disconnect(XTID)
        MutexLock(TSNE_INT_Mutex)
    End If
    TPtr = TNPtr
Loop
MutexUnLock(TSNE_INT_Mutex)
MutexLock(TSNE_INT_Mutex_Master)
TSNE_INT_Thread_Master_Close = 1
MutexUnLock(TSNE_INT_Mutex_Master)
ThreadWait(TSNE_INT_Thread_Master_Ptr)
MutexLock(TSNE_INT_DNSIPA_Mutex)
Dim TDNSPtr as TSNE_INT_DNSIPA_Type Ptr = TSNE_INT_DNSIPAD
Dim NDNSPtr as TSNE_INT_DNSIPA_Type Ptr
Do Until TDNSPtr = 0
    NDNSPtr = TDNSPtr->V_Next
    DeAllocate(TDNSPtr)
    TDNSPtr = NDNSPtr
Loop
MutexUnLock(TSNE_INT_DNSIPA_Mutex)
MutexDestroy(TSNE_INT_DNSIPA_Mutex):    TSNE_INT_DNSIPA_Mutex = 0
MutexDestroy(TSNE_INT_Mutex_Master):    TSNE_INT_Mutex_Master = 0
MutexDestroy(TSNE_INT_Mutex):           TSNE_INT_Mutex = 0
#IF DEFINED(TSNE_SleepLock)
    MutexDestroy(TSNE_INT_SleepMutex)
#ENDIF
End Sub





'##############################################################################################################
Private Function TSNE_INT_GetHostEnd(ByRef V_HostIPA as String, ByRef R_InAddr as in_addr) as Integer
MutexLock(TSNE_INT_DNSIPA_Mutex)
Dim TDNSPtr as TSNE_INT_DNSIPA_Type Ptr = TSNE_INT_DNSIPAD
Dim NDNSPtr as TSNE_INT_DNSIPA_Type Ptr
Do Until TDNSPtr = 0
    If TDNSPtr->V_TimeOut <= Timer() Then
        If TDNSPtr->V_Prev <> 0 Then TDNSPtr->V_Prev->V_Next = TDNSPtr->V_Next
        If TDNSPtr->V_Next <> 0 Then TDNSPtr->V_Next->V_Prev = TDNSPtr->V_Prev
        If TSNE_INT_DNSIPAD = TDNSPtr Then TSNE_INT_DNSIPAD = TDNSPtr->V_Next
        If TSNE_INT_DNSIPAL = TDNSPtr Then TSNE_INT_DNSIPAL = TDNSPtr->V_Prev
        NDNSPtr = TDNSPtr->V_Next
        DeAllocate(TDNSPtr)
        TDNSPtr = NDNSPtr
    Else: TDNSPtr = TDNSPtr->V_Next
    End If
Loop
TDNSPtr = TSNE_INT_DNSIPAD
Do Until TDNSPtr = 0
    If TDNSPtr->V_HostIPA = V_HostIPA Then
        R_InAddr = TDNSPtr->V_InAddr
        MutexUnLock(TSNE_INT_DNSIPA_Mutex)
        Return TSNE_Const_NoError
    End If
    TDNSPtr = TDNSPtr->V_Next
Loop
Dim TADDRIN as in_addr
TADDRIN.s_addr = inet_addr(StrPtr(V_HostIPA))
If (TADDRIN.s_addr = -1) Then
    Dim XHost as hostent Ptr = gethostbyname(StrPtr(V_HostIPA))
    If XHost = 0 Then
        MutexUnLock(TSNE_INT_DNSIPA_Mutex)
        Return TSNE_Const_CantResolveIPfromHost
    End If
    TADDRIN = *Cast(in_addr Ptr, XHost->h_addr_list[0])
    If TADDRIN.s_addr = INADDR_NONE Then MutexUnLock(TSNE_INT_DNSIPA_Mutex): Return TSNE_Const_CantResolveIPfromHost
End If
If TSNE_INT_DNSIPAL <> 0 Then
    TSNE_INT_DNSIPAL->V_Next = CAllocate(SizeOf(TSNE_INT_DNSIPA_Type))
    TSNE_INT_DNSIPAL->V_Next->V_Prev = TSNE_INT_DNSIPAL
    TSNE_INT_DNSIPAL = TSNE_INT_DNSIPAL->V_Next
Else
    TSNE_INT_DNSIPAL = CAllocate(SizeOf(TSNE_INT_DNSIPA_Type))
    TSNE_INT_DNSIPAD = TSNE_INT_DNSIPAL
End If
TSNE_INT_DNSIPAL->V_HostIPA = V_HostIPA
TSNE_INT_DNSIPAL->V_InAddr = TADDRIN
TSNE_INT_DNSIPAL->V_TimeOut = Timer() + 60
R_InAddr = TADDRIN
MutexUnLock(TSNE_INT_DNSIPA_Mutex)
Return TSNE_Const_NoError
End Function





'##############################################################################################################
Private Sub TSNE_INT_Thread_Master(ByVal I_Nothing as Any Ptr) 'THX dkl
MutexUnLock(TSNE_INT_Mutex_Master)
Dim TPtr as TSNE_Socket Ptr
Dim TNPtr as TSNE_Socket Ptr
Dim TThPtr as Any Ptr
Dim TID as UInteger
Dim TEvent as TSNE_Event_Type
Do
    #IF DEFINED(_TSNE_DODEBUG_)
'       Print Fix(Timer()) & "=[TSNE]=[TMA]= Lock..."
    #ENDIF
    MutexLock(TSNE_INT_Mutex)
    #IF DEFINED(_TSNE_DODEBUG_)
'       Print Fix(Timer()) & "=[TSNE]=[TMA]= Lock-K"
    #ENDIF
    TPtr = TSNE_INT_D
    Do Until TPtr = 0
        TNPtr = TPtr->V_Next
        If TPtr->T_ThreadOn = 3 Then
            TID = TPtr->V_TSNEID
            #IF DEFINED(_TSNE_DODEBUG_)
                Print Fix(Timer()) & "=[" & Str(TID) & "]=[TSNE]=[TMA]= ThreadON 3"
            #ENDIF
            TPtr->T_ThreadOn = 4
            #IF DEFINED(_TSNE_DODEBUG_)
                Print Fix(Timer()) & "=[" & Str(TID) & "]=[TSNE]=[TMA]= ThreadON 4"
            #ENDIF
            TThPtr = TPtr->T_Thread
            TEvent = TPtr->V_Event
            MutexUnLock(TSNE_INT_Mutex)
            #IF DEFINED(_TSNE_DODEBUG_)
                Print Fix(Timer()) & "=[" & Str(TID) & "]=[TSNE]=[TMA]= Unlock"
                Print Fix(Timer()) & "=[" & Str(TID) & "]=[TSNE]=[TMA]= Wait..."
            #ENDIF
            ThreadWait(TThPtr)
            #IF DEFINED(_TSNE_DODEBUG_)
                Print Fix(Timer()) & "=[" & Str(TID) & "]=[TSNE]=[TMA]= Wait-K"
                Print Fix(Timer()) & "=[" & Str(TID) & "]=[TSNE]=[TMA]= Call-Dis..."
            #ENDIF
            #IF DEFINED(TSNE_SUBCALLBACK)
                If TEvent.TSNE_Disconnected <> 0 Then TEvent.TSNE_Disconnected(TID, TEvent.V_AnyPtr)
            #ELSE
                If TEvent.TSNE_Disconnected <> 0 Then TEvent.TSNE_Disconnected(TID)
            #ENDIF
            #IF DEFINED(_TSNE_DODEBUG_)
                Print Fix(Timer()) & "=[" & Str(TID) & "]=[TSNE]=[TMA]= Call-Dis-K"
            #ENDIF
            TSNE_INT_Del(TPtr)
            #IF DEFINED(_TSNE_DODEBUG_)
                Print Fix(Timer()) & "=[" & Str(TID) & "]=[TSNE]=[TMA]= Lock..."
            #ENDIF
            MutexLock(TSNE_INT_Mutex)
            #IF DEFINED(_TSNE_DODEBUG_)
                Print Fix(Timer()) & "=[" & Str(TID) & "]=[TSNE]=[TMA]= Lock-K"
            #ENDIF
        End If
        TPtr = TNPtr
    Loop
    #IF DEFINED(_TSNE_DODEBUG_)
'       Print Fix(Timer()) & "=[TSNE]=[TMA]= M-Lock..."
    #ENDIF
    MutexLock(TSNE_INT_Mutex_Master)
    #IF DEFINED(_TSNE_DODEBUG_)
'       Print Fix(Timer()) & "=[TSNE]=[TMA]= M-Lock-K"
    #ENDIF
    If TSNE_INT_Thread_Master_Close = 1 Then If TSNE_INT_D = 0 Then MutexUnLock(TSNE_INT_Mutex): MutexUnLock(TSNE_INT_Mutex_Master): Exit Do
    MutexUnLock(TSNE_INT_Mutex_Master)
    #IF DEFINED(_TSNE_DODEBUG_)
'       Print Fix(Timer()) & "=[TSNE]=[TMA]= M-Unlock"
    #ENDIF
    MutexUnLock(TSNE_INT_Mutex)
    #IF DEFINED(_TSNE_DODEBUG_)
'       Print Fix(Timer()) & "=[TSNE]=[TMA]= Unlock"
    #ENDIF
    #IF DEFINED(TSNE_SleepLock)
'       MutexLock(TSNE_INT_SleepMutex)
    #ENDIF
    'USleep 1000
    Sleep 1, 1
    #IF DEFINED(TSNE_SleepLock)
'       MutexUnLock(TSNE_INT_SleepMutex)
    #ENDIF
Loop
#IF DEFINED(_TSNE_DODEBUG_)
    Print Fix(Timer()) & "=[TSNE]=[TMA]= END SUB"
#ENDIF
End Sub





'##############################################################################################################
Private Function TSNE_Stats(ByRef V_TSNEID as UInteger, ByRef R_RX as ULongInt, ByRef R_TX as ULongInt) as Integer
MutexLock(TSNE_INT_Mutex)
Dim TPtr as TSNE_Socket Ptr = TSNE_INT_GetPtr(V_TSNEID)
If TPtr = 0 Then MutexUnLock(TSNE_INT_Mutex): Return TSNE_Const_TSNEIDnotFound
R_RX = TPtr->T_DataIn
R_TX = TPtr->T_DataOut
MutexUnLock(TSNE_INT_Mutex)
Return TSNE_Const_NoError
End Function





'##############################################################################################################
Private Function TSNE_GetHost(ByRef V_TSNEID as UInteger) as String
MutexLock(TSNE_INT_Mutex)
Dim TPtr as TSNE_Socket Ptr = TSNE_INT_GetPtr(V_TSNEID)
If TPtr = 0 Then MutexUnLock(TSNE_INT_Mutex): Return ""
Function = TPtr->V_Host
MutexUnLock(TSNE_INT_Mutex)
End Function

'--------------------------------------------------------------------------------------------------------------
Private Function TSNE_GetIPA(ByRef V_TSNEID as UInteger) as String
MutexLock(TSNE_INT_Mutex)
Dim TPtr as TSNE_Socket Ptr = TSNE_INT_GetPtr(V_TSNEID)
If TPtr = 0 Then MutexUnLock(TSNE_INT_Mutex): Return ""
Function = TPtr->V_IPA
MutexUnLock(TSNE_INT_Mutex)
End Function

'--------------------------------------------------------------------------------------------------------------
Private Function TSNE_GetPort(ByRef V_TSNEID as UInteger) as UShort
MutexLock(TSNE_INT_Mutex)
Dim TPtr as TSNE_Socket Ptr = TSNE_INT_GetPtr(V_TSNEID)
If TPtr = 0 Then MutexUnLock(TSNE_INT_Mutex): Return 0
Function = TPtr->V_Port
MutexUnLock(TSNE_INT_Mutex)
End Function





'##############################################################################################################
'### !!! TSNE_Ping is EXPERIMENTAL !!! ###
'#########################################
Private Function TSNE_Ping(ByVal V_IPA as String, ByRef R_Runtime as Double, ByVal V_TimeoutSecs as UByte = 10, ByVal V_ForceRAWPing as UByte = 0, ByVal V_FileIOMutex as Any Ptr = 0) as Integer
If V_IPA = "" Then Return TSNE_Const_IPAnotFound
If InStr(1, V_IPA, ":") > 0 Then Return TSNE_Const_NoIPV6
Dim TADDRIN as in_addr
Dim RV as Integer = TSNE_INT_GetHostEnd(V_IPA, TADDRIN)
If RV <> TSNE_Const_NoError Then Return RV
Dim XFN as Integer
#IF DEFINED(__FB_LINUX__)
    If V_ForceRAWPing = 0 Then
        If Dir("/bin/ping", -1) <> "" Then
            If V_FileIOMutex <> 0 Then MutexLock(V_FileIOMutex)
            XFN = FreeFile
            If Open Pipe ("/bin/ping -t " & Str(V_TimeoutSecs) & " -c 1 -qU " & V_IPA for Input as XFN) = 0 Then
                If V_FileIOMutex <> 0 Then MutexUnLock(V_FileIOMutex)
                Dim T as String
                Dim TL as String
                Do Until EOF(XFN)
                    Line Input #XFN, TL
                    If Trim(TL) <> "" Then T = TL
                Loop
                Close #XFN
                XFN = InStr(1, T, "=")
                If XFN = 0 Then Return TSNE_Const_InternalError
                T = Trim(Mid(T, XFN + 1))
                XFN = InStr(1, T, "/")
                If XFN = 0 Then Return TSNE_Const_InternalError
                R_Runtime = Val(Trim(Left(T, XFN - 1))) / 1000
                Return TSNE_Const_NoError
            End If
            If V_FileIOMutex <> 0 Then MutexUnLock(V_FileIOMutex)
        End If
    End If
#ELSEIF DEFINED(__FB_WIN32__)
    If V_ForceRAWPing = 0 Then
        #IF DEFINED(TSNE_PINGICMP)
            Dim TBuff as ICMP_Echo_Reply Ptr = CAllocate(SizeOf(ICMP_Echo_Reply) + 4)
            XFN = IcmpCreateFile()
            If IcmpSendEcho(XFN, TADDRIN, "PING", 4, 0, TBuff, SizeOf(TBuff), (V_TimeoutSecs * 1000)) >= 1 Then
                IcmpCloseHandle(XFN)
                With *TBuff
                    Select Case .Status
                        Case IP_SUCCESS
                            R_Runtime = .RoundTripTime / 1000
                            DeAllocate(TBuff)
                            Return TSNE_Const_NoError
                        Case IP_DEST_NET_UNREACHABLE, IP_DEST_HOST_UNREACHABLE, IP_DEST_PROT_UNREACHABLE, IP_DEST_PORT_UNREACHABLE, IP_REQ_TIMED_OUT, IP_TTL_EXPIRED_TRANSIT
                            DeAllocate(TBuff)
                            Return TSNE_Const_CantConnectToRemote
                        Case Else: DeAllocate(TBuff): Return TSNE_Const_InternalError
                    End Select
                End With
            Else
                DeAllocate(TBuff)
        #ENDIF
                If V_FileIOMutex <> 0 Then MutexLock(V_FileIOMutex)
                XFN = FreeFile
                If Open Pipe ("ping -w " & Str(V_TimeoutSecs) & " -n 1 " & V_IPA for Input as XFN) = 0 Then
                    If V_FileIOMutex <> 0 Then MutexUnLock(V_FileIOMutex)
                    Dim T as String
                    Dim TL as String
                    Do Until EOF(XFN)
                        Line Input #XFN, TL
                        If Trim(TL) <> "" Then T = TL
                    Loop
                    Close #XFN
                    XFN = InStr(1, T, "=")
                    If XFN = 0 Then Return TSNE_Const_InternalError
                    T = Trim(Mid(T, XFN + 1))
                    XFN = InStr(1, T, "ms")
                    If XFN = 0 Then Return TSNE_Const_InternalError
                    R_Runtime = Val(Trim(Left(T, XFN - 1))) / 1000
                    Return TSNE_Const_NoError
                End If
                If V_FileIOMutex <> 0 Then MutexUnLock(V_FileIOMutex)
        #IF DEFINED(TSNE_PINGICMP)
            End If
        #ENDIF
    End If
#ENDIF
Dim TADDR as SOCKADDR_IN
With TADDR
    .sin_family = AF_INET
    .sin_addr = TADDRIN
End With
Dim TSock as Socket = opensocket(PF_INET, SOCK_RAW, IPPROTO_ICMP)
If TSock = INVALID_SOCKET Then
    #IF DEFINED(TSNE_ERRNO)
        Select Case errno
            Case EMFILE, ENFILE, ENOMEM: Return TSNE_Const_CantCreateSocketLimit
            Case Else: Return TSNE_Const_CantCreateSocket
        End Select
    #ELSE
        Return TSNE_Const_CantCreateSocket
    #ENDIF
End If
Dim XMode as UInteger
#IF DEFINED(__FB_LINUX__)
    Dim XFlag as Integer = fcntl(TSock, F_GETFL, 0)
    If XFlag = -1 Then close_(TSock): Return TSNE_Const_ReturnErrorInCallback
'|  If fcntl(TSock, F_SETFL, XFlag or O_NONBLOCK) = -1 Then close_(TSock): Return TSNE_Const_ReturnErrorInCallback
    If fcntl(TSock, F_SETFL, XFlag) = -1 Then close_(TSock): Return TSNE_Const_ReturnErrorInCallback
#ELSEIF DEFINED(__FB_WIN32__)
    XMode = 1
'   Dim XFlag as Integer = ioctlsocket(TSock, FIONBIO, @XMode)
    Dim XFlag as Integer = ioctlsocket(TSock, FIONBIO, Cast(Any Ptr, 1))
#ENDIF
Dim TICMP as ICMP
With TICMP
    .icmp_type  = ICMP_ECHO
    .icmp_code  = 0
    .icmp_seq   = 1
    .icmp_id    = 0
End With
Dim TUBP as UByte Ptr = Cast(UByte Ptr, @TICMP)
Dim TSum as UInteger
For X as UInteger = 0 To SizeOf(ICMP) -1
    TSum += *(TUBP + X)
Next
TSum = (TSum shr 16) + (TSum and &HFFFF)
TSum += (TSum shr 16)
TSum = &HFFFF - TSum
TICMP.icmp_cksum = TSum
Dim TBuffer as ZString * TSNE_INT_BufferSize
Dim TLenB as Integer
Dim TFDSet as fd_Set
Dim TTLen as UInteger = SizeOf(TADDR)
Dim TTV AS TimeVal
With TTV
    .tv_sec = CUInt(V_TimeoutSecs)
    .tv_usec = 0
End With
fd_set_(TSock, @TFDSet)
Dim TRTT as Double = Timer()
RV = sendto(TSock, Cast(UByte Ptr, @TICMP), SizeOf(ICMP), 0, Cast(SOCKADDR Ptr, @TADDR), SizeOf(SOCKADDR_IN))
If RV <> SizeOf(ICMP) Then close_(TSock): Return TSNE_Const_ErrorSendingData
Do
    RV = select_(TSock + 1, @TFDSet, 0, 0, @TTV)
    If RV <> 1 Then close_(TSock): Return TSNE_Const_CantConnectToRemote
    If TSock = INVALID_SOCKET Then close_(TSock): Return TSNE_Const_InternalError
    TLenB = recvfrom(TSock, StrPtr(TBuffer), TSNE_INT_BufferSize, 0, Cast(SOCKADDR Ptr, @TADDR), @TTLen)
    If TLenB <= 0 Then close_(TSock): Return TSNE_Const_InternalError
    If TLenB >= 2 Then
        If (((TBuffer[0] and &B11110000) shr 4) = &H4) and (TBuffer[1] = &H00) Then
            Dim TIHL as UInteger = (TBuffer[0] and &B00001111) * 4
            If TIHL >= 16 Then
                If TBuffer[TIHL + 0] = ICMP_ECHOREPLY Then
                    Dim TSN as UShort = (TBuffer[TIHL + 6] shl 8) or TBuffer[TIHL + 7]
                    If TSN = 256 Then
                        close_(TSock)
                        R_Runtime = Timer() - TRTT
                        Return TSNE_Const_NoError
                    End If
                End If
            End If
        End If
    End If
Loop
Return TSNE_Const_CantConnectToRemote
End Function





'##############################################################################################################
Private Function TSNE_Disconnect(ByRef V_TSNEID as UInteger) as Integer
'|if V_TSNEID = 1 then
'|  Dim X as uinteger ptr
'|  Print *X
'|End If
#IF DEFINED(_TSNE_DODEBUG_)
    Print Fix(Timer()) & "=[" & Str(V_TSNEID) & "]=[TSNE]=[DIS]= Lock..."
#ENDIF
MutexLock(TSNE_INT_Mutex)
#IF DEFINED(_TSNE_DODEBUG_)
    Print Fix(Timer()) & "=[" & Str(V_TSNEID) & "]=[TSNE]=[DIS]= Lock-K"
#ENDIF
Dim TPtr as TSNE_Socket Ptr = TSNE_INT_GetPtr(V_TSNEID)
If TPtr = 0 Then MutexUnLock(TSNE_INT_Mutex): Return TSNE_Const_TSNEIDnotFound
If TPtr->V_Socket = INVALID_SOCKET Then MutexUnLock(TSNE_INT_Mutex): Return TSNE_Const_NoSocketFound
If TPtr->T_ThreadOn <> 2 Then MutexUnLock(TSNE_INT_Mutex): Return TSNE_Const_UnstableState
Dim TSock as Socket = TPtr->V_Socket
TPtr->V_Socket = INVALID_SOCKET
TPtr->T_ThreadOn = 3
MutexUnLock(TSNE_INT_Mutex)
#IF DEFINED(_TSNE_DODEBUG_)
    Print Fix(Timer()) & "=[" & Str(V_TSNEID) & "]=[TSNE]=[DIS]= Unlock"
#ENDIF
close_(TSock)
Return TSNE_Const_NoError
End Function

'--------------------------------------------------------------------------------------------------------------
'Private Sub TSNE_DisconnectAll(ByRef V_ServerTSNEID as UInteger)

'End Sub


'--------------------------------------------------------------------------------------------------------------
Private Function TSNE_Create_Server(ByRef R_TSNEID as UInteger, ByRef V_Port as UShort, ByRef V_MaxSimConReq as UShort = 10, ByVal V_Event_NewConPTR as Any Ptr, ByVal V_Event_NewConCancelPTR as Any Ptr = 0, ByVal V_StackSizeOverride as UInteger = TSNE_INT_StackSize) as Integer
R_TSNEID = 0
If (V_MaxSimConReq <= 0) or (V_MaxSimConReq > 4096) Then Return TSNE_Const_MaxSimConReqOutOfRange
If (V_Port < 0) or (V_Port > 65535) Then Return TSNE_Const_PortOutOfRange
If V_Event_NewConPTR = 0 Then Return TSNE_Const_MissingEventPTR
Dim TSock as Socket = opensocket(AF_INET, SOCK_STREAM, IPPROTO_IP)
If TSock = INVALID_SOCKET Then
    #IF DEFINED(TSNE_ERRNO)
        Select Case errno
            Case EMFILE, ENFILE, ENOMEM: Return TSNE_Const_CantCreateSocketLimit
            Case Else: Return TSNE_Const_CantCreateSocket
        End Select
    #ELSE
        Return TSNE_Const_CantCreateSocket
    #ENDIF
End If
Dim TTADDR as SOCKADDR_IN
With TTADDR
    .sin_family = AF_INET
    .sin_port = htons(V_Port)
    .sin_addr.s_addr = INADDR_ANY
End With
#IF DEFINED(TSNE_DEF_REUSER)
    Dim XV as Integer = 1
    #IF DEFINED(__FB_LINUX__)
        If setsockopt(TSock, SOL_SOCKET, SO_REUSEADDR, @XV, SizeOf(Integer)) = -1 then close_(TSock): Return TSNE_Const_CantBindSocket
    #ELSEIF DEFINED(__FB_WIN32__)
        If setsockopt(TSock, SOL_SOCKET, SO_REUSEADDR, Cast(ZString Ptr, @XV), SizeOf(Integer)) = -1 then close_(TSock): Return TSNE_Const_CantBindSocket
    #ENDIF
#ENDIF
Dim BV as Integer = bind(TSock, CPtr(SOCKADDR Ptr, @TTADDR), SizeOf(SOCKADDR_IN))
If BV = SOCKET_ERROR Then close_(TSock): Return TSNE_Const_CantBindSocket
BV = listen(TSock, V_MaxSimConReq)
If BV = SOCKET_ERROR Then Return TSNE_Const_CantSetListening
Dim TSD as TSNE_Socket Ptr = TSNE_INT_Add()
MutexLock(TSNE_INT_Mutex)
With *TSD
    .V_Socket = TSock
    .V_IPA = ""
    .V_Host = ""
    .V_Port = V_Port
    .V_Prot = TSNE_P_TCP
    .V_IsServer = 1
    .T_ThreadOn = 1
    .V_Event.TSNE_NewConnection = V_Event_NewConPTR
    .V_Event.TSNE_NewConnectionCanceled = V_Event_NewConCancelPTR
End With
R_TSNEID = TSD->V_TSNEID
TSD->T_Thread = ThreadCreate(cast(Any Ptr, @TSNE_INT_Thread_Event), cast(Any Ptr, R_TSNEID), V_StackSizeOverride)
MutexUnLock(TSNE_INT_Mutex)
Return TSNE_Const_NoError
End Function


'--------------------------------------------------------------------------------------------------------------
Private Function TSNE_Create_ServerWithBindIPA(ByRef R_TSNEID as UInteger, ByRef V_Port as UShort, ByRef V_IPA as String, ByRef V_MaxSimConReq as UShort = 10, ByVal V_Event_NewConPTR as Any Ptr, ByVal V_Event_NewConCancelPTR as Any Ptr = 0, ByVal V_StackSizeOverride as UInteger = TSNE_INT_StackSize) as Integer
R_TSNEID = 0
If (V_MaxSimConReq <= 0) or (V_MaxSimConReq > 4096) Then Return TSNE_Const_MaxSimConReqOutOfRange
If (V_Port < 0) or (V_Port > 65535) Then Return TSNE_Const_PortOutOfRange
If V_IPA = "" Then Return TSNE_Const_IPAnotFound
If InStr(1, V_IPA, ":") > 0 Then Return TSNE_Const_NoIPV6
If V_Event_NewConPTR = 0 Then Return TSNE_Const_MissingEventPTR
Dim TADDRIN as in_addr
Dim RV as Integer = TSNE_INT_GetHostEnd(V_IPA, TADDRIN)
If RV <> TSNE_Const_NoError Then Return RV
Dim TSock as Socket = opensocket(AF_INET, SOCK_STREAM, IPPROTO_IP)
If TSock = INVALID_SOCKET Then
    #IF DEFINED(TSNE_ERRNO)
        Select Case errno
            Case EMFILE, ENFILE, ENOMEM: Return TSNE_Const_CantCreateSocketLimit
            Case Else: Return TSNE_Const_CantCreateSocket
        End Select
    #ELSE
        Return TSNE_Const_CantCreateSocket
    #ENDIF
End If
Dim TTADDR as SOCKADDR_IN
With TTADDR
    .sin_family = AF_INET
    .sin_port = htons(V_Port)
    .sin_addr = TADDRIN
End With
#IF DEFINED(TSNE_DEF_REUSER)
    Dim XV as Integer = 1
    #IF DEFINED(__FB_LINUX__)
        If setsockopt(TSock, SOL_SOCKET, SO_REUSEADDR, @XV, SizeOf(Integer)) = -1 then close_(TSock): Return TSNE_Const_CantBindSocket
    #ELSEIF DEFINED(__FB_WIN32__)
        If setsockopt(TSock, SOL_SOCKET, SO_REUSEADDR, Cast(ZString Ptr, @XV), SizeOf(Integer)) = -1 then close_(TSock): Return TSNE_Const_CantBindSocket
    #ENDIF
#ENDIF
Dim BV as Integer = bind(TSock, CPtr(SOCKADDR Ptr, @TTADDR), SizeOf(SOCKADDR_IN))
If BV = SOCKET_ERROR Then close_(TSock): Return TSNE_Const_CantBindSocket
BV = listen(TSock, V_MaxSimConReq)
If BV = SOCKET_ERROR Then Return TSNE_Const_CantSetListening
Dim TSD as TSNE_Socket Ptr = TSNE_INT_Add()
MutexLock(TSNE_INT_Mutex)
With *TSD
    .V_Socket = TSock
    .V_IPA = V_IPA
    .V_Host = V_IPA
    .V_Port = V_Port
    .V_Prot = TSNE_P_TCP
    .V_IsServer = 1
    .T_ThreadOn = 1
    .V_Event.TSNE_NewConnection = V_Event_NewConPTR
    .V_Event.TSNE_NewConnectionCanceled = V_Event_NewConCancelPTR
End With
R_TSNEID = TSD->V_TSNEID
TSD->T_Thread = ThreadCreate(cast(Any Ptr, @TSNE_INT_Thread_Event), cast(Any Ptr, R_TSNEID), V_StackSizeOverride)
MutexUnLock(TSNE_INT_Mutex)
Return TSNE_Const_NoError
End Function


'--------------------------------------------------------------------------------------------------------------
Private Function TSNE_Create_Client(ByRef R_TSNEID as UInteger, ByVal V_HostOrIPA as String, ByVal V_Port as UShort, ByVal V_Event_DisconPTR as Any Ptr = 0, ByVal V_Event_ConPTR as Any Ptr = 0, ByVal V_Event_NewDataPTR as Any Ptr, ByVal V_TimeoutSecs as UInteger = 60, ByVal V_StackSizeOverride as UInteger = TSNE_INT_StackSize, ByVal V_WaitThreadRunning as UByte = 1, ByVal V_CallbackBackPtr as Any Ptr = 0) as Integer
R_TSNEID = 0
If (V_Port < 0) or (V_Port > 65535) Then Return TSNE_Const_PortOutOfRange
If V_HostOrIPA = "" Then Return TSNE_Const_IPAnotFound
If InStr(1, V_HostOrIPA, ":") > 0 Then Return TSNE_Const_NoIPV6
Dim TADDRIN as in_addr
Dim RV as Integer = TSNE_INT_GetHostEnd(V_HostOrIPA, TADDRIN)
If RV <> TSNE_Const_NoError Then Return RV
Dim TADDR as SOCKADDR_IN
With TADDR
    .sin_family = AF_INET
    .sin_port = htons(V_Port)
    .sin_addr = TADDRIN
End With
Dim TIPA as String = *inet_ntoa(TADDRIN)
Dim TSock as Socket = opensocket(PF_INET, SOCK_STREAM, 0)
If TSock = INVALID_SOCKET Then
    #IF DEFINED(TSNE_ERRNO)
        Select Case errno
            Case EMFILE, ENFILE, ENOMEM: Return TSNE_Const_CantCreateSocketLimit
            Case Else: Return TSNE_Const_CantCreateSocket
        End Select
    #ELSE
        Return TSNE_Const_CantCreateSocket
    #ENDIF
End If
#IF DEFINED(TSNE_DEF_REUSER)
    Dim XV as Integer = 1
    #IF DEFINED(__FB_LINUX__)
        If setsockopt(TSock, SOL_SOCKET, SO_REUSEADDR, @XV, SizeOf(Integer)) = -1 then close_(TSock): Return TSNE_Const_CantBindSocket
    #ELSEIF DEFINED(__FB_WIN32__)
        If setsockopt(TSock, SOL_SOCKET, SO_REUSEADDR, Cast(ZString Ptr, @XV), SizeOf(Integer)) = -1 then close_(TSock): Return TSNE_Const_CantBindSocket
    #ENDIF
#ENDIF
Dim XMode as UInteger
Dim XModeUnsign as Integer
#IF DEFINED(__FB_LINUX__)
    Dim XFlag as Integer = fcntl(TSock, F_GETFL, 0)
    If XFlag = -1 Then close_(TSock): Return TSNE_Const_ReturnErrorInCallback
    If fcntl(TSock, F_SETFL, XFlag or O_NONBLOCK) = -1 Then close_(TSock): Return TSNE_Const_ReturnErrorInCallback
#ELSEIF DEFINED(__FB_WIN32__)
    XModeUnsign = 1
'   Dim XFlag as Integer = ioctlsocket(TSock, FIONBIO, @XModeUnsign)
    Dim XFlag as Integer = ioctlsocket(TSock, FIONBIO, Cast(Any Ptr, 1))
#ENDIF
Dim BV as Integer = connect(TSock, CPtr(SOCKADDR Ptr, @TADDR), SizeOf(SOCKADDR))
If BV <> 0 Then
    Dim TTV as timeval
    Dim TFDSet as fd_Set
    Dim TFDSetW as fd_Set
    With TTV
        .tv_sec = 1
        .tv_usec = 0
    End With
    #IF DEFINED(__FB_LINUX__)
        Dim XTot as Double = Timer + V_TimeoutSecs
        Do
            If connect(TSock, CPtr(SOCKADDR PTR, @TADDR), SizeOf(SOCKADDR)) = 0 Then Exit Do
            If XTot < Timer Then close_(TSock): Return TSNE_Const_CantConnectToRemote
            If TSock = INVALID_SOCKET Then Return TSNE_Const_CantConnectToRemote
            With TTV
                .tv_sec = 0
                .tv_usec = 1000
            End With
            select_ 0, 0, 0, 0, @TTV
        Loop
    #ELSEIF DEFINED(__FB_WIN32__)
        FD_SET_(TSock, @TFDSet)
        With TTV
            .tv_sec = V_TimeoutSecs
            .tv_usec = 0
        End With
        FD_ZERO(@TFDSet)
        If select_(TSock + 1, 0, @TFDSet, 0, @TTV) = (INVALID_SOCKET or 0) Then Return TSNE_Const_CantConnectToRemote
        If Not (FD_ISSET(TSock, @TFDSet)) Then close_(TSock): Return TSNE_Const_CantConnectToRemote
        If TSock = INVALID_SOCKET Then Return TSNE_Const_CantConnectToRemote
    #ENDIF
End If
#IF DEFINED(__FB_LINUX__)
    fcntl(TSock, F_SETFL, XFlag)
#ELSEIF DEFINED(__FB_WIN32__)
    XMode = 0
'   XFlag = ioctlsocket(TSock, FIONBIO, @XMode)
    XFlag = ioctlsocket(TSock, FIONBIO, Cast(Any Ptr, 1))
#ENDIF
Dim TSD as TSNE_Socket Ptr = TSNE_INT_Add()
MutexLock(TSNE_INT_Mutex)
With *TSD
    .V_Socket = TSock
    .V_IPA = TIPA
    .V_Host = V_HostOrIPA
    .V_Port = V_Port
    .V_Prot = TSNE_P_TCP
    .V_IsServer = 0
    .T_ThreadOn = 1
    .V_Event.TSNE_Disconnected = V_Event_DisconPTR
    .V_Event.TSNE_Connected = V_Event_ConPTR
    .V_Event.TSNE_NewData = V_Event_NewDataPTR
    .V_Event.V_AnyPtr = V_CallbackBackPtr
End With
R_TSNEID = TSD->V_TSNEID
TSD->T_Thread = ThreadCreate(cast(Any Ptr, @TSNE_INT_Thread_Event), cast(Any Ptr, R_TSNEID), V_StackSizeOverride)
MutexUnLock(TSNE_INT_Mutex)
#IFNDEF TSNE_SUBCALLBACK
    If V_WaitThreadRunning = 1 Then
        Dim TTot as Double = Timer() + V_TimeoutSecs
        Do
            MutexLock(TSNE_INT_Mutex)
            TSD = TSNE_INT_GetPtr(R_TSNEID)
            If TSD = 0 Then MutexUnLock(TSNE_INT_Mutex): Return TSNE_Const_InternalError
            If TTot < Timer() Then MutexUnLock(TSNE_INT_Mutex): Return TSNE_Const_InternalError
            If TSD->T_ThreadOn = 2 Then MutexUnLock(TSNE_INT_Mutex): Return TSNE_Const_NoError
            MutexUnLock(TSNE_INT_Mutex)
            #IF DEFINED(TSNE_SleepLock)
                MutexLock(TSNE_INT_SleepMutex)
            #ENDIF
            'USleep 1000
            Sleep 1, 1
            #IF DEFINED(TSNE_SleepLock)
                MutexUnLock(TSNE_INT_SleepMutex)
            #ENDIF
        Loop
    End If
#ENDIF
Return TSNE_Const_NoError
End Function


'--------------------------------------------------------------------------------------------------------------
Private Function TSNE_Create_Accept(ByVal V_RequestID as Socket, ByRef R_TSNEID as UInteger, ByRef R_IPA as String = "", ByVal V_Event_DisconPTR as Any Ptr = 0, ByVal V_Event_ConPTR as Any Ptr = 0, ByVal V_Event_NewDataPTR as Any Ptr, ByRef R_RemoteShownServerIPA as String = "", ByVal V_StackSizeOverride as UInteger = TSNE_INT_StackSize, ByVal V_WaitThreadRunning as UByte = 1, ByVal V_CallbackBackPtr as Any Ptr = 0) as Integer
Dim TADDR as SOCKADDR_IN
Dim XSize as Integer = 16
Dim OADDR as SOCKADDR_IN
If getsockname(V_RequestID, Cast(sockaddr PTR, @OADDR), @XSize) = 0 Then R_RemoteShownServerIPA = *inet_ntoa(OADDR.sin_addr)
If getpeername(V_RequestID, Cast(sockaddr PTR, @TADDR), @XSize) = 0 Then R_IPA = *inet_ntoa(TADDR.sin_addr)
Dim TSD as TSNE_Socket Ptr = TSNE_INT_Add()
MutexLock(TSNE_INT_Mutex)
With *TSD
    .V_Socket = V_RequestID
    .V_Prot = TSNE_P_TCP
    .V_IPA = R_IPA
    .V_Host = R_IPA
    .T_ThreadOn = 1
    .V_Event.TSNE_Disconnected = V_Event_DisconPTR
    .V_Event.TSNE_Connected = V_Event_ConPTR
    .V_Event.TSNE_NewData = V_Event_NewDataPTR
    .V_Event.V_AnyPtr = V_CallbackBackPtr
End With
R_TSNEID = TSD->V_TSNEID
TSD->T_Thread = ThreadCreate(cast(Any Ptr, @TSNE_INT_Thread_Event), cast(Any Ptr, R_TSNEID), V_StackSizeOverride)
MutexUnLock(TSNE_INT_Mutex)
#IFNDEF TSNE_SUBCALLBACK
    If V_WaitThreadRunning = 1 Then
        Dim TTot as Double = Timer() + 60
        Do
            MutexLock(TSNE_INT_Mutex)
            TSD = TSNE_INT_GetPtr(R_TSNEID)
            If TSD = 0 Then MutexUnLock(TSNE_INT_Mutex): Return TSNE_Const_InternalError
            If TTot < Timer() Then MutexUnLock(TSNE_INT_Mutex): Return TSNE_Const_InternalError
            If TSD->T_ThreadOn = 2 Then MutexUnLock(TSNE_INT_Mutex): Return TSNE_Const_NoError
            MutexUnLock(TSNE_INT_Mutex)
            #IF DEFINED(TSNE_SleepLock)
                MutexLock(TSNE_INT_SleepMutex)
            #ENDIF
            'USleep 1000
            Sleep 1, 1
            #IF DEFINED(TSNE_SleepLock)
                MutexUnLock(TSNE_INT_SleepMutex)
            #ENDIF
        Loop
    End If
#ENDIF
Return TSNE_Const_NoError
End Function


'--------------------------------------------------------------------------------------------------------------
Private Function TSNE_Create_UDP_RX(ByRef R_TSNEID as UInteger, ByVal V_Port as UShort, ByVal V_Event_NewDataUDPPTR as Any Ptr, ByVal V_StackSizeOverride as UInteger = TSNE_INT_StackSize, ByVal V_WaitThreadRunning as UByte = 1) as Integer
R_TSNEID = 0
If (V_Port < 0) or (V_Port > 65535) Then Return TSNE_Const_PortOutOfRange
If V_Event_NewDataUDPPTR = 0 Then Return TSNE_Const_MissingEventPTR
Dim TSock as Socket = opensocket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)
If TSock = INVALID_SOCKET Then
    #IF DEFINED(TSNE_ERRNO)
        Select Case errno
            Case EMFILE, ENFILE, ENOMEM: Return TSNE_Const_CantCreateSocketLimit
            Case Else: Return TSNE_Const_CantCreateSocket
        End Select
    #ELSE
        Return TSNE_Const_CantCreateSocket
    #ENDIF
End If
#IF DEFINED(TSNE_DEF_REUSER)
    Dim XV as Integer = 1
    #IF DEFINED(__FB_LINUX__)
        If setsockopt(TSock, SOL_SOCKET, SO_REUSEADDR, @XV, SizeOf(Integer)) = -1 then close_(TSock): Return TSNE_Const_CantBindSocket
    #ELSEIF DEFINED(__FB_WIN32__)
        If setsockopt(TSock, SOL_SOCKET, SO_REUSEADDR, Cast(ZString Ptr, @XV), SizeOf(Integer)) = -1 then close_(TSock): Return TSNE_Const_CantBindSocket
    #ENDIF
#ENDIF
Dim TTADDR as SOCKADDR_IN
With TTADDR
    .sin_family = AF_INET
    .sin_port = htons(V_Port)
    .sin_addr.s_addr = INADDR_ANY
End With
Dim BV as Integer = bind(TSock, CPtr(SOCKADDR Ptr, @TTADDR), SizeOf(SOCKADDR_IN))
If BV = SOCKET_ERROR Then close_(TSock): Return TSNE_Const_CantBindSocket
Dim TSD as TSNE_Socket Ptr = TSNE_INT_Add()
MutexLock(TSNE_INT_Mutex)
With *TSD
    .V_Socket = TSock
    .V_IPA = ""
    .V_Host = ""
    .V_USP = TTADDR
    .V_Port = V_Port
    .V_Prot = TSNE_P_UDP
    .V_IsServer = 1
    .T_ThreadOn = 1
    .V_Event.TSNE_NewDataUDP = V_Event_NewDataUDPPTR
End With
R_TSNEID = TSD->V_TSNEID
TSD->T_Thread = ThreadCreate(cast(Any Ptr, @TSNE_INT_Thread_Event), cast(Any Ptr, R_TSNEID), V_StackSizeOverride)
MutexUnLock(TSNE_INT_Mutex)
If V_WaitThreadRunning = 1 Then
    Dim TTot as Double = Timer() + 60
    Do
        MutexLock(TSNE_INT_Mutex)
        TSD = TSNE_INT_GetPtr(R_TSNEID)
        If TSD = 0 Then MutexUnLock(TSNE_INT_Mutex): Return TSNE_Const_InternalError
        If TTot < Timer() Then MutexUnLock(TSNE_INT_Mutex): Return TSNE_Const_InternalError
        If TSD->T_ThreadOn = 2 Then MutexUnLock(TSNE_INT_Mutex): Return TSNE_Const_NoError
        MutexUnLock(TSNE_INT_Mutex)
        #IF DEFINED(TSNE_SleepLock)
            MutexLock(TSNE_INT_SleepMutex)
        #ENDIF
        'USleep 1000
        Sleep 1, 1
        #IF DEFINED(TSNE_SleepLock)
            MutexUnLock(TSNE_INT_SleepMutex)
        #ENDIF
    Loop
End If
Return TSNE_Const_NoError
End Function


'--------------------------------------------------------------------------------------------------------------
Private Function TSNE_Create_UDP_TX(ByRef R_TSNEID as UInteger, ByVal V_DoBroadcast as UByte = 0) as Integer
R_TSNEID = 0
Dim TSock as Socket = opensocket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)
If TSock = INVALID_SOCKET Then
    #IF DEFINED(TSNE_ERRNO)
        Select Case errno
            Case EMFILE, ENFILE, ENOMEM: Return TSNE_Const_CantCreateSocketLimit
            Case Else: Return TSNE_Const_CantCreateSocket
        End Select
    #ELSE
        Return TSNE_Const_CantCreateSocket
    #ENDIF
End If
#IF DEFINED(TSNE_DEF_REUSER)
    Dim XV as Integer = 1
    #IF DEFINED(__FB_LINUX__)
        If setsockopt(TSock, SOL_SOCKET, SO_REUSEADDR, @XV, SizeOf(Integer)) = -1 then close_(TSock): Return TSNE_Const_CantBindSocket
    #ELSEIF DEFINED(__FB_WIN32__)
        If setsockopt(TSock, SOL_SOCKET, SO_REUSEADDR, Cast(ZString Ptr, @XV), SizeOf(Integer)) = -1 then close_(TSock): Return TSNE_Const_CantBindSocket
    #ENDIF
#ENDIF
If V_DoBroadcast = 1 Then
    Dim TBD as Integer = 1
    #IF DEFINED(__FB_LINUX__)
        If setsockopt(TSock, SOL_SOCKET, SO_BROADCAST, @TBD, sizeof(TBD)) = -1 Then close_(TSock): Return TSNE_Const_CantCreateSocket
    #ELSEIF DEFINED(__FB_WIN32__)
        If setsockopt(TSock, SOL_SOCKET, SO_BROADCAST, Cast(ZString Ptr, @TBD), sizeof(TBD)) = -1 Then close_(TSock): Return TSNE_Const_CantCreateSocket
    #ENDIF
End If
Dim TSD as TSNE_Socket Ptr = TSNE_INT_Add()
MutexLock(TSNE_INT_Mutex)
With *TSD
    .V_Socket = TSock
    .V_IPA = ""
    .V_Host = ""
    .V_Port = 0
    .V_Prot = TSNE_P_UDP
    .V_IsServer = 1
    .T_ThreadOn = 2
End With
R_TSNEID = TSD->V_TSNEID
MutexUnLock(TSNE_INT_Mutex)
Return TSNE_Const_NoError
End Function





'##############################################################################################################
Private Function TSNE_Data_Send(ByRef V_TSNEID as UInteger, ByRef V_Data as String, ByRef R_BytesSend as UInteger = 0, ByVal V_IPA as String = "", ByVal V_Port as UShort = 0, ByVal V_TCPQueSend as Integer = 0) as Integer
'Print "TSNE_SEND >" & V_Data & "<"
#IF DEFINED(_TSNE_DEBUG_O_)
    Print "[TSNE-DEBUG] [...] SENDDATA:>" & V_Data & "<"
#ENDIF

#IF Defined(_TSNE_DODEBUG_TX_)
    Print Str(Timer()) & "=[" & Str(V_TSNEID) & "]=[TSNE]=[TDS]= Len:" & Len(V_Data) & Chr(13, 10)
#ENDIF
R_BytesSend = 0
MutexLock(TSNE_INT_Mutex)
Dim TSD as TSNE_Socket Ptr = TSNE_INT_GetPtr(V_TSNEID)
If TSD = 0 Then MutexUnLock(TSNE_INT_Mutex): Return TSNE_Const_TSNEIDnotFound
If TSD->V_Socket = INVALID_SOCKET Then MutexUnLock(TSNE_INT_Mutex): Return TSNE_Const_TSNEIDnotFound
If V_TCPQueSend = 1 Then
    With *TSD
        If .V_Que_L <> 0 Then
            .V_Que_L->V_Next = CAllocate(SizeOf(TSNE_Socket_Que))
            .V_Que_L->V_Next->V_Prev = .V_Que_L
            .V_Que_L = .V_Que_L->V_Next
        Else
            .V_Que_L = CAllocate(SizeOf(TSNE_Socket_Que))
            .V_Que_F = .V_Que_L
        End If
        .V_Que_L->V_Data = V_Data
    End With
    MutexUnLock(TSNE_INT_Mutex)
    Return TSNE_Const_NoError
End If

Dim TSock as Socket = TSD->V_Socket
Dim TProt as TSNE_Protocol = TSD->V_Prot
Dim TTState as UInteger = TSD->T_ThreadOn
MutexUnLock(TSNE_INT_Mutex)
Dim XTemp as String = V_Data
Dim XLen as UInteger = Len(XTemp)
Dim BV as Integer
Dim TLByte as UInteger
Dim TFlag as Integer
#IF Defined(__fb_linux__)
    TFlag = TSNE_MSG_NOSIGNAL
#ELSEIF Defined(__fb_win32__)
#ENDIF
Select Case TProt
    Case TSNE_P_UDP
        If V_IPA = "" Then Return TSNE_Const_IPAnotFound
        If (V_Port < 0) or (V_Port > 65535) Then Return TSNE_Const_PortOutOfRange
        Dim TTADDR as SOCKADDR_IN
        With TTADDR
            .sin_family = AF_INET
            .sin_port = htons(V_Port)
            If V_IPA <> "0" Then
                Dim XHost as hostent Ptr
                If InStr(1, V_IPA, ":") > 0 Then Return TSNE_Const_NoIPV6
                Dim TADDRIN as in_addr
                Dim RV as Integer = TSNE_INT_GetHostEnd(V_IPA, TADDRIN)
                If RV <> TSNE_Const_NoError Then Return RV
                .sin_addr = TADDRIN
            Else: .sin_addr.s_addr = INADDR_BROADCAST
            End If
        End With
        Do Until R_BytesSend = XLen
            BV = sendto(TSock, StrPtr(XTemp) + R_BytesSend, XLen - R_BytesSend, TFlag, Cast(SOCKADDR Ptr, @TTADDR), SizeOf(SOCKADDR_IN))
            If BV > 0 Then
                R_BytesSend += BV
            ElseIf BV = 0 Then
            Else: Exit Do
            End If
        Loop
    Case TSNE_P_TCP
        If TTState <> 2 Then Return TSNE_Const_UnstableState
        #IF Defined(_TSNE_DODEBUG_TX_)
            Print Str(Timer()) & "=[" & Str(V_TSNEID) & "]=[TSNE]=[TDS]= Init Loop! (" & Str(XLen) & ")"
        #ENDIF
        Do Until R_BytesSend >= XLen
            BV = send(TSock, StrPtr(XTemp) + R_BytesSend, XLen - R_BytesSend, TFlag)
            #IF Defined(_TSNE_DODEBUG_TX_)
                Print Str(Timer()) & "=[" & Str(V_TSNEID) & "]=[TSNE]=[TDS]= TX! (" & Str(TSock) & " | " & Str(TFlag) & " | " & Str(BV) & " | " & Str(R_BytesSend) & " | " & Str(XLen) & ")"
            #ENDIF
            If BV > 0 Then
                R_BytesSend += BV
            ElseIf BV = 0 Then
            Else
                Return TSNE_Const_ErrorSendingData
                Exit Do
            End If
        Loop
End Select
MutexLock(TSNE_INT_Mutex)
TSD = TSNE_INT_GetPtr(V_TSNEID)
If TSD = 0 Then MutexUnLock(TSNE_INT_Mutex): Return TSNE_Const_TSNEIDnotFound
If TSD->V_Socket = INVALID_SOCKET Then MutexUnLock(TSNE_INT_Mutex): Return TSNE_Const_TSNEIDnotFound
TSD->T_DataOut += R_BytesSend
MutexUnLock(TSNE_INT_Mutex)
If R_BytesSend <> XLen Then   Return TSNE_Const_ErrorSendingData
#IF Defined(_TSNE_DODEBUG_TX_)
    Print Str(Timer()) & "=[" & Str(V_TSNEID) & "]=[TSNE]=[TDS]= NO-ERROR! (" & Str(R_BytesSend) & ")"
#ENDIF
Return TSNE_Const_NoError
End Function





'##############################################################################################################
Private Sub TSNE_WaitClose(ByRef V_TSNEID as UInteger)
Dim TSD as TSNE_Socket Ptr
MutexLock(TSNE_INT_Mutex)
MutexUnLock(TSNE_INT_Mutex)
Do
    MutexLock(TSNE_INT_Mutex)
    TSD = TSNE_INT_GetPtr(V_TSNEID)
    If TSD = 0 Then Exit Do
    If TSD->T_ThreadOn = 0 Then Exit Do
    MutexUnLock(TSNE_INT_Mutex)
    #IF DEFINED(TSNE_SleepLock)
        MutexLock(TSNE_INT_SleepMutex)
    #ENDIF
    'USleep 1000
    Sleep 1, 1
    #IF DEFINED(TSNE_SleepLock)
        MutexUnLock(TSNE_INT_SleepMutex)
    #EndIf
Loop
MutexUnLock(TSNE_INT_Mutex)
End Sub


'--------------------------------------------------------------------------------------------------------------
Private Function TSNE_WaitConnected(ByRef V_TSNEID as UInteger, V_TimeOut as UInteger = 60) as Integer
Dim TSD as TSNE_Socket Ptr
Dim TTot as Double = Timer() + V_TimeOut
MutexLock(TSNE_INT_Mutex)
MutexunLock(TSNE_INT_Mutex)
Do
    MutexLock(TSNE_INT_Mutex)
    TSD = TSNE_INT_GetPtr(V_TSNEID)
    If TSD = 0 Then Exit Do
    If TTot < Timer() Then Exit Do
    If TSD->T_ThreadOn = 2 Then MutexUnLock(TSNE_INT_Mutex): Return TSNE_Const_NoError
    MutexUnLock(TSNE_INT_Mutex)
    #IF DEFINED(TSNE_SleepLock)
        MutexLock(TSNE_INT_SleepMutex)
    #ENDIF
    'USleep 1000
    Sleep 1, 1
    #IF DEFINED(TSNE_SleepLock)
        MutexUnLock(TSNE_INT_SleepMutex)
    #ENDIF
Loop
MutexUnLock(TSNE_INT_Mutex)
Return TSNE_Const_CantConnectToRemote
End Function


'--------------------------------------------------------------------------------------------------------------
Private Function TSNE_IsClosed(ByRef V_TSNEID as UInteger) as Integer
Dim TSD as TSNE_Socket Ptr
MutexLock(TSNE_INT_Mutex)
TSD = TSNE_INT_GetPtr(V_TSNEID)
If TSD = 0 Then MutexUnLock(TSNE_INT_Mutex): Return 1
If TSD->T_ThreadOn = 0 Then MutexUnLock(TSNE_INT_Mutex): Return 1
MutexUnLock(TSNE_INT_Mutex)
Return 0
End Function





'##############################################################################################################
Private Sub TSNE_INT_Thread_Event(ByVal V_TSNEID as Any Ptr)
#IF DEFINED(_TSNE_DODEBUG_)
    Print Fix(Timer()) & "=[" & Str(Cast(UInteger, V_TSNEID)) & "]=[TSNE]=[EVT]= Lock..."
#ENDIF
MutexLock(TSNE_INT_Mutex)
#IF DEFINED(_TSNE_DODEBUG_)
    Print Fix(Timer()) & "=[" & Str(Cast(UInteger, V_TSNEID)) & "]=[TSNE]=[EVT]= Lock-K"
#ENDIF
Dim TTSNEID as UInteger = Cast(UInteger, V_TSNEID)
Dim TSD as TSNE_Socket Ptr = TSNE_INT_GetPtr(TTSNEID)
If TSD = 0 Then MutexUnLock(TSNE_INT_Mutex): Exit Sub
Dim TSock as Socket = TSD->V_Socket
Dim TEvent as TSNE_Event_Type = TSD->V_Event
Dim TTV AS TimeVal
With TTV
    .tv_sec = 0
    .tv_usec = 0
End With
Dim TFDSet as fd_Set
Dim TLenB as Integer
Dim TBuffer as ZString * TSNE_INT_BufferSize
Dim TIPA as String
Dim T as String
Dim TADDR as SOCKADDR_IN
Dim XSize as Integer = SizeOf(sockaddr_in)
Dim TSockQue as TSNE_Socket_Que Ptr
If TSD->T_ThreadOn = 1 Then
    TSD->T_ThreadOn = 2
    Dim TProt as TSNE_Protocol = TSD->V_Prot
    Select Case TProt
        Case TSNE_P_UDP
            Dim TTADDRC as SOCKADDR_IN
            Dim TTLen as UInteger = SizeOf(TADDR)
            MutexUnLock(TSNE_INT_Mutex)
            Do
                MutexLock(TSNE_INT_Mutex)
                TSD = TSNE_INT_GetPtr(TTSNEID): If TSD = 0 Then MutexUnLock(TSNE_INT_Mutex): Exit Do
                TSock = TSD->V_Socket: If TSock = INVALID_SOCKET Then MutexUnLock(TSNE_INT_Mutex): Exit Do
                MutexUnLock(TSNE_INT_Mutex)
                fd_set_(TSock, @TFDSet)
                If TSock = INVALID_SOCKET Then Exit Do
                With TTV
                    .tv_sec = 1
                    .tv_usec = 0
                End With
'|              If select_(TSock + 1, @TFDSet, 0, 0, @TTV) = -1 Then Exit Do
                select_(TSock + 1, @TFDSet, 0, 0, @TTV)
                If (FD_ISSET(TSock, @TFDSet)) <> 0 Then
                    If TSock = INVALID_SOCKET Then Exit Do
                    TADDR = TTADDRC
                    TLenB = recvfrom(TSock, StrPtr(TBuffer), TSNE_INT_BufferSize, 0, Cast(SOCKADDR Ptr, @TADDR), @TTLen)
                    If TLenB <= 0 Then Exit Do
                    TBuffer[TLenB] = 0
                    T = Space(TLenB + 1)
                    MemCpy(StrPtr(T), StrPtr(TBuffer), TLenB)
                    MutexLock(TSNE_INT_Mutex)
                    TSD = TSNE_INT_GetPtr(TTSNEID): If TSD = 0 Then MutexUnLock(TSNE_INT_Mutex): Exit Do
                    TSD->T_DataIn += TLenB
                    MutexUnLock(TSNE_INT_Mutex)
                    T = Mid(T, 1, Len(T) - 1)
                    TIPA = *inet_ntoa(TADDR.sin_addr)
                    If TEvent.TSNE_NewDataUDP <> 0 Then
                        #IF DEFINED(_TSNE_DEBUG_I_)
                            Print "[TSNE-DEBUG] [UDP] NEWDATA: >" & T & "<"
                        #ENDIF
                        TEvent.TSNE_NewDataUDP(TTSNEID, TIPA, T)
                    End If
                End If
            Loop

        Case TSNE_P_TCP
            If TSD->V_IsServer <> 1 Then
                MutexUnLock(TSNE_INT_Mutex)
                #IF DEFINED(_TSNE_DODEBUG_)
                    Print Fix(Timer()) & "=[" & Str(TTSNEID) & "]=[TSNE]=[EVT]=[TCP-C]= Unlocked"
                #ENDIF
                #IF DEFINED(TSNE_SUBCALLBACK)
                    If TEvent.TSNE_Connected <> 0 Then TEvent.TSNE_Connected(TTSNEID, TEvent.V_AnyPtr)
                #ELSE
                    If TEvent.TSNE_Connected <> 0 Then TEvent.TSNE_Connected(TTSNEID)
                #ENDIF
                Do
                    MutexLock(TSNE_INT_Mutex)
                    TSD = TSNE_INT_GetPtr(TTSNEID): If TSD = 0 Then MutexUnLock(TSNE_INT_Mutex): Exit Do
                    TSock = TSD->V_Socket: If TSock = INVALID_SOCKET Then MutexUnLock(TSNE_INT_Mutex): Exit Do
                    TSockQue = 0
                    With *TSD
                        If .V_Que_F <> 0 Then
                            TSockQue = .V_Que_F
                            If TSockQue->V_Next <> 0 Then TSockQue->V_Next->V_Prev = TSockQue->V_Prev
                            If TSockQue->V_Prev <> 0 Then TSockQue->V_Prev->V_Next = TSockQue->V_Next
                            If .V_Que_F = TSockQue Then .V_Que_F = TSockQue->V_Next
                            If .V_Que_L = TSockQue Then .V_Que_L = TSockQue->V_Prev
                        End If
                    End With
                    MutexUnLock(TSNE_INT_Mutex)
                    If TSockQue <> 0 Then TSNE_Data_Send(TTSNEID, TSockQue->V_Data)
                    fd_set_(TSock, @TFDSet)
                    If TSock = INVALID_SOCKET Then Exit Do
                    With TTV
                        If TSockQue <> 0 Then
                            .tv_sec = 0
                            .tv_usec = 1
                            DeAllocate(TSockQue)
                        Else
                            #IF DEFINED(TSNE_FastEventThread)
                                .tv_sec = 0
                                .tv_usec = 5000
                            #ELSE
                                .tv_sec = 1
                                .tv_usec = 0
                            #ENDIF
                        End If
                    End With
'|                  If select_(TSock + 1, @TFDSet, 0, 0, @TTV) = -1 Then Exit Do
                    select_(TSock + 1, @TFDSet, 0, 0, @TTV)
                    If (FD_ISSET(TSock, @TFDSet)) <> 0 Then
                        #IF DEFINED(_TSNE_DODEBUG_)
                            Print Fix(Timer()) & "=[" & Str(TTSNEID) & "]=[TSNE]=[EVT]=[TCP-C]= Event"
                        #ENDIF
                        If TSock = INVALID_SOCKET Then Exit Do
                        #IF DEFINED(_TSNE_DODEBUG_)
                            Print Fix(Timer()) & "=[" & Str(TTSNEID) & "]=[TSNE]=[EVT]=[TCP-C]= Dat"
                        #ENDIF
                        TLenB = recv(TSock, StrPtr(TBuffer), TSNE_INT_BufferSize, 0)
                        If TLenB <= 0 Then Exit Do
                        TBuffer[TLenB] = 0
                        T = Space(TLenB + 1)
                        MemCpy(StrPtr(T), StrPtr(TBuffer), TLenB)
                        #IF DEFINED(_TSNE_DODEBUG_)
                            Print Fix(Timer()) & "=[" & Str(TTSNEID) & "]=[TSNE]=[EVT]=[TCP-C]= Dat Lock..."
                        #ENDIF
                        MutexLock(TSNE_INT_Mutex)
                        #IF DEFINED(_TSNE_DODEBUG_)
                            Print Fix(Timer()) & "=[" & Str(TTSNEID) & "]=[TSNE]=[EVT]=[TCP-C]= Dat Lock-K"
                        #ENDIF
                        TSD = TSNE_INT_GetPtr(TTSNEID): If TSD = 0 Then MutexUnLock(TSNE_INT_Mutex): Exit Do
                        TSD->T_DataIn += TLenB
                        MutexUnLock(TSNE_INT_Mutex)
                        #IF DEFINED(_TSNE_DODEBUG_)
                            Print Fix(Timer()) & "=[" & Str(TTSNEID) & "]=[TSNE]=[EVT]=[TCP-C]= Dat Unlock"
                        #ENDIF
                        T = Mid(T, 1, Len(T) - 1)
                        #IF DEFINED(_TSNE_DODEBUG_)
                            Print Fix(Timer()) & "=[" & Str(TTSNEID) & "]=[TSNE]=[EVT]=[TCP-C]= Dat Call... (" & Str(Len(T)) & ")"
                        #ENDIF
                        #IF DEFINED(_TSNE_DEBUG_I_)
                            Print "[TSNE-DEBUG] [TCP] NEWDATA: >" & T & "<"
                        #ENDIF
                        #IF DEFINED(TSNE_SUBCALLBACK)
                            If TEvent.TSNE_NewData <> 0 Then TEvent.TSNE_NewData(TTSNEID, T, TEvent.V_AnyPtr)
                        #ELSE
                            If TEvent.TSNE_NewData <> 0 Then TEvent.TSNE_NewData(TTSNEID, T)
                        #ENDIF
                        #IF DEFINED(_TSNE_DODEBUG_)
                            Print Fix(Timer()) & "=[" & Str(TTSNEID) & "]=[TSNE]=[EVT]=[TCP-C]= Dat Call-K"
                        #ENDIF
                    End If
                Loop
            Else
                MutexUnLock(TSNE_INT_Mutex)
                #IF DEFINED(_TSNE_DODEBUG_)
                    Print Fix(Timer()) & "=[" & Str(TTSNEID) & "]=[TSNE]=[EVT]=[TCP-S]= Unlocked"
                #ENDIF
                Dim TNSock as Socket
                Dim Y as UInteger
                Dim XOK as Integer
                'Dim XFX as UInteger
                Dim XV as Integer = 1
                Do
                    'XFX += 1
                    MutexLock(TSNE_INT_Mutex)
                    TSD = TSNE_INT_GetPtr(TTSNEID): If TSD = 0 Then MutexUnLock(TSNE_INT_Mutex): Exit Do
                    TSock = TSD->V_Socket: If TSock = INVALID_SOCKET Then MutexUnLock(TSNE_INT_Mutex): Exit Do
                    MutexUnLock(TSNE_INT_Mutex)
                    fd_set_(TSock, @TFDSet)
                    With TTV
                        .tv_sec = 1
                        .tv_usec = 0
                    End With
'|                  If selectsocket(TSock + 1, @TFDSet, 0, 0, @TTV) = SOCKET_ERROR Then
                    'Print "=[" & Str(TTSNEID) & "]CON_SELECT"
                    selectsocket(TSock + 1, @TFDSet, 0, 0, @TTV)
                    'Print "=[" & Str(TTSNEID) & "]CON_SELECT_DONE"
                    If (FD_ISSET(TSock, @TFDSet)) Then
'                       Print "=[" & Str(TTSNEID) & "]CON_REQ"
                        #IF DEFINED(_TSNE_DODEBUG_)
                            Print Fix(Timer()) & "=[" & Str(TTSNEID) & "]=[TSNE]=[EVT]=[TCP-S]=  ACP..."
                        #ENDIF
                        TNSock = accept(TSock, 0, 0)
                        #IF DEFINED(_TSNE_DODEBUG_)
                            Print Fix(Timer()) & "=[" & Str(TTSNEID) & "]=[TSNE]=[EVT]=[TCP-S]=  ACP:" & Str(TNSock)
                        #ENDIF
                        IF TNSock = INVALID_SOCKET Then Exit Do
                        #IF DEFINED(TSNE_DEF_REUSER)
                            #IF DEFINED(__FB_LINUX__)
                                setsockopt(TNSock, SOL_SOCKET, SO_REUSEADDR, @XV, SizeOf(Integer))
                            #ELSEIF DEFINED(__FB_WIN32__)
                                setsockopt(TNSock, SOL_SOCKET, SO_REUSEADDR, Cast(ZString Ptr, @XV), SizeOf(Integer))
                            #ENDIF
                        #ENDIF
                        TIPA = ""
                        If getpeername(TNSock, Cast(sockaddr Ptr, @TADDR), @XSize) = 0 Then TIPA = *inet_ntoa(TADDR.sin_addr)
                        #IF DEFINED(_TSNE_DODEBUG_)
                            Print Fix(Timer()) & "=[" & Str(TTSNEID) & "]=[TSNE]=[EVT]=[TCP-S]= BWL Lock..."
                        #ENDIF
                        MutexLock(TSNE_INT_Mutex)
                        #IF DEFINED(_TSNE_DODEBUG_)
                            Print "=[" & Str(TTSNEID) & "]=[TSNE]=[EVT]=[TCP-S]= BWL Lock-K"
                        #ENDIF
                        Select Case TSD->V_BWL_UseType
                            Case 1
                                If TSNE_INT_BW_GetPtr(TSD, TIPA) = 0 Then
                                    MutexUnLock(TSNE_INT_Mutex): If TEvent.TSNE_NewConnection <> 0 Then TEvent.TSNE_NewConnection(TTSNEID, TNSock, TIPA)
                                Else: MutexUnLock(TSNE_INT_Mutex): close_(TNSock): If TEvent.TSNE_NewConnectionCanceled <> 0 Then TEvent.TSNE_NewConnectionCanceled(TTSNEID, TIPA)
                                End If
                            Case 2
                                If TSNE_INT_BW_GetPtr(TSD, TIPA) = 0 Then
                                    MutexUnLock(TSNE_INT_Mutex): close_(TNSock): If TEvent.TSNE_NewConnectionCanceled <> 0 Then TEvent.TSNE_NewConnectionCanceled(TTSNEID, TIPA)
                                Else: MutexUnLock(TSNE_INT_Mutex): If TEvent.TSNE_NewConnection <> 0 Then TEvent.TSNE_NewConnection(TTSNEID, TNSock, TIPA)
                                End If
                            Case Else: MutexUnLock(TSNE_INT_Mutex): If TEvent.TSNE_NewConnection <> 0 Then TEvent.TSNE_NewConnection(TTSNEID, TNSock, TIPA)
                        End Select
                        #IF DEFINED(_TSNE_DODEBUG_)
                            Print Fix(Timer()) & "=[" & Str(TTSNEID) & "]=[TSNE]=[EVT]=[TCP-S]= BWL Unlock"
                        #ENDIF
                    End If
                Loop
                ExitPoint:
            End If

        Case Else: MutexUnLock(TSNE_INT_Mutex)
    End Select
    #IF DEFINED(_TSNE_DODEBUG_)
        Print Fix(Timer()) & "=[" & Str(TTSNEID) & "]=[TSNE]=[EVT]= Exit Lock"
    #ENDIF
    MutexLock(TSNE_INT_Mutex)
    #IF DEFINED(_TSNE_DODEBUG_)
        Print Fix(Timer()) & "=[" & Str(TTSNEID) & "]=[TSNE]=[EVT]= Exit Lock-K"
    #ENDIF
End If
TSD = TSNE_INT_GetPtr(TTSNEID)
If TSD <> 0 Then
    TSock = TSD->V_Socket
    If TSock <> INVALID_SOCKET Then
        TSD->V_Socket = INVALID_SOCKET
        close_(TSock)
    End If
    TSD->T_ThreadOn = 3
    #IF DEFINED(_TSNE_DODEBUG_)
        Print Fix(Timer()) & "=[" & Str(TTSNEID) & "]=[TSNE]=[EVT]= Exit ThreadON 3"
    #ENDIF
End If
MutexUnLock(TSNE_INT_Mutex)
#IF DEFINED(_TSNE_DODEBUG_)
    Print Fix(Timer()) & "=[" & Str(TTSNEID) & "]=[TSNE]=[EVT]= Exit Unlocked"
#ENDIF
End Sub





'##############################################################################################################
Private Function TSNE_BW_SetEnable(ByVal V_Server_TSNEID as UInteger, V_Type as TSNE_BW_Mode_Enum) as Integer
MutexLock(TSNE_INT_Mutex)
Dim TSD as TSNE_Socket Ptr = TSNE_INT_GetPtr(V_Server_TSNEID)
If TSD = 0 Then MutexUnLock(TSNE_INT_Mutex): Return TSNE_Const_TSNEIDnotFound
If TSD->V_IsServer <> 1 Then MutexUnLock(TSNE_INT_Mutex): Return TSNE_Const_TSNENoServer
TSD->V_BWL_UseType = V_Type
MutexUnLock(TSNE_INT_Mutex)
Return TSNE_Const_NoError
End Function

'--------------------------------------------------------------------------------------------------------------
Private Function TSNE_BW_GetEnable(ByVal V_Server_TSNEID as UInteger, R_Type as TSNE_BW_Mode_Enum) as Integer
MutexLock(TSNE_INT_Mutex)
Dim TSD as TSNE_Socket Ptr = TSNE_INT_GetPtr(V_Server_TSNEID)
If TSD = 0 Then MutexUnLock(TSNE_INT_Mutex): Return TSNE_Const_TSNEIDnotFound
If TSD->V_IsServer <> 1 Then MutexUnLock(TSNE_INT_Mutex): Return TSNE_Const_TSNENoServer
R_Type = TSD->V_BWL_UseType
MutexUnLock(TSNE_INT_Mutex)
Return TSNE_Const_NoError
End Function

'--------------------------------------------------------------------------------------------------------------
Private Function TSNE_BW_Clear(ByVal V_Server_TSNEID as UInteger) as Integer
MutexLock(TSNE_INT_Mutex)
Dim TSD as TSNE_Socket Ptr = TSNE_INT_GetPtr(V_Server_TSNEID)
If TSD = 0 Then MutexUnLock(TSNE_INT_Mutex): Return TSNE_Const_TSNEIDnotFound
If TSD->V_IsServer <> 1 Then MutexUnLock(TSNE_INT_Mutex): Return TSNE_Const_TSNENoServer
TSNE_INT_BW_Clear(TSD)
MutexUnLock(TSNE_INT_Mutex)
Return TSNE_Const_NoError
End Function

'--------------------------------------------------------------------------------------------------------------
Private Function TSNE_BW_Add(ByVal V_Server_TSNEID as UInteger, V_IPA as String, V_BlockTimeSeconds as UInteger = 3600) as Integer
MutexLock(TSNE_INT_Mutex)
Dim TSD as TSNE_Socket Ptr = TSNE_INT_GetPtr(V_Server_TSNEID)
If TSD = 0 Then MutexUnLock(TSNE_INT_Mutex): Return TSNE_Const_TSNEIDnotFound
If TSD->V_IsServer <> 1 Then MutexUnLock(TSNE_INT_Mutex): Return TSNE_Const_TSNENoServer
If TSNE_INT_BW_Add(TSD, V_IPA, Now() + V_BlockTimeSeconds) = 1 Then
    MutexUnLock(TSNE_INT_Mutex): Return TSNE_Const_NoError
Else: MutexUnLock(TSNE_INT_Mutex): Return TSNE_Const_IPAalreadyInList
End if
MutexUnLock(TSNE_INT_Mutex)
Return TSNE_Const_NoError
End Function

'--------------------------------------------------------------------------------------------------------------
Private Function TSNE_BW_Del(ByVal V_Server_TSNEID as UInteger, V_IPA as String) as Integer
MutexLock(TSNE_INT_Mutex)
Dim TSD as TSNE_Socket Ptr = TSNE_INT_GetPtr(V_Server_TSNEID)
If TSD = 0 Then MutexUnLock(TSNE_INT_Mutex): Return TSNE_Const_TSNEIDnotFound
If TSD->V_IsServer <> 1 Then MutexUnLock(TSNE_INT_Mutex): Return TSNE_Const_TSNENoServer
If TSNE_INT_BW_Del(TSD, V_IPA) = 1 Then
    MutexUnLock(TSNE_INT_Mutex): Return TSNE_Const_NoError
Else: MutexUnLock(TSNE_INT_Mutex): Return TSNE_Const_IPAnotInList
End if
End Function

'--------------------------------------------------------------------------------------------------------------
Private Function TSNE_BW_List(ByVal V_Server_TSNEID as UInteger, ByRef R_IPA_List as TSNE_BWL_Type Ptr) as Integer
MutexLock(TSNE_INT_Mutex)
Dim TSD as TSNE_Socket Ptr = TSNE_INT_GetPtr(V_Server_TSNEID)
If TSD = 0 Then MutexUnLock(TSNE_INT_Mutex): Return TSNE_Const_TSNEIDnotFound
If TSD->V_IsServer <> 1 Then MutexUnLock(TSNE_INT_Mutex): Return TSNE_Const_TSNENoServer
Dim TPtr as TSNE_BWL_Type Ptr = TSD->V_BWL_IPAD
Dim TNPtrL as TSNE_BWL_Type Ptr
Do Until TPtr = 0
    If TNPtrL <> 0 Then
        TNPtrL->V_Next = CAllocate(SizeOf(TSNE_Socket))
        TNPtrL->V_Next->V_PreV = TNPtrL
        TNPtrL = TNPtrL->V_Next
    Else
        TNPtrL = CAllocate(SizeOf(TSNE_Socket))
        R_IPA_List = TNPtrL
    End If
    TNPtrL->V_IPA = TPtr->V_IPA
    TNPtrL->V_LockTill = TPtr->V_LockTill
    TPtr = TPtr->V_Next
Loop
MutexUnLock(TSNE_INT_Mutex)
Return TSNE_Const_NoError
End Function





'##############################################################################################################
Private Function TSNE_GetGURUCode(ByRef V_GURUID as Integer) as String
Select Case V_GURUID
    Case TSNE_Const_UnknowError:                Return "Unknown error."
    Case TSNE_Const_NoError:                    Return "No error."
    Case TSNE_Const_UnknowEventID:              Return "Unknown EventID."
    Case TSNE_Const_NoSocketFound:              Return "No Socket found in 'V_SOCKET'."
    Case TSNE_Const_CantCreateSocket:           Return "Can't create socket."
    Case TSNE_Const_CantBindSocket:             Return "Can't bind port on socket."
    Case TSNE_Const_CantSetListening:           Return "Can't set socket into listening-mode."
    Case TSNE_Const_SocketAlreadyInit:          Return "Socket is already initalized."
    Case TSNE_Const_MaxSimConReqOutOfRange:     Return "'V_MaxSimConReq' is out of range."
    Case TSNE_Const_PortOutOfRange:             Return "Port out of range."
    Case TSNE_Const_CantResolveIPfromHost:      Return "Can't resolve IPA from host."
    Case TSNE_Const_CantConnectToRemote:        Return "Can't connect to remote computer [Timeout?]."
    Case TSNE_Const_TSNEIDnotFound:             Return "TSNE-ID not found."
    Case TSNE_Const_MissingEventPTR:            Return "Missing pointer of 'V_Event...'."
    Case TSNE_Const_IPAalreadyInList:           Return "IPA already in list."
    Case TSNE_Const_IPAnotInList:               Return "IPA is not in list."
    Case TSNE_Const_ReturnErrorInCallback:      Return "Return error in callback."
    Case TSNE_Const_IPAnotFound:                Return "IPA not found."
    Case TSNE_Const_ErrorSendingData:           Return "Error while sending data. Not sure all data transmitted. Maybe connection lost or disconnected."
    Case TSNE_Const_TSNENoServer:               Return "TSNEID is not a server."
    Case TSNE_Const_NoIPV6:                     Return "No IPV6 supported!"
    Case TSNE_Const_CantCreateSocketLimit:      Return "Can't create socket. No more file descriptors available for this process or the system."
    Case TSNE_Const_UnstableState:              Return "Unstable Thread-State!"
    Case TSNE_Const_InternalError:              Return "Internal Error! Please contact support/programmer!"
    Case Else:                                  Return "Unknown GURU-Code [" & Str(V_GURUID) & "]"
End Select
End Function



'##############################################################################################################
'...<
#EndIf