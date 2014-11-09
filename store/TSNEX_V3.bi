'#####################################################################################################
'#####################################################################################################
' TSNEX_V3 - Extension Modul für TSNE_V3
'#####################################################################################################
'#####################################################################################################
' 2009 By.: /_\ DeltaLab's - Deutschland
' Autor: Martin Wiemann
'#####################################################################################################





#IFNDEF _TSNEX_
    #DEFINE _TSNEX_
'>...

'##############################################################################################################
#include once "TSNE_V3.bi"
#include once "vbcompat.bi"



'##############################################################################################################
#IF DEFINED(__FB_LINUX__)
    Const TSNEX_Seperator = "/"
#ELSEIF DEFINED(__FB_WIN32__)
    Const TSNEX_Seperator = "\"
#ELSE
    #error "Unsupported platform"
#ENDIF



'##############################################################################################################
#IF DEFINED(TSNEX_DEF_FileMutex)
    Dim Shared TSNEX_FileMutex as Any Ptr
#ENDIF



'##############################################################################################################
Private Const TSNEX_Const_NoError                       as Integer = 1
Private Const TSNEX_Const_UnknowError                   as Integer = 0
Private Const TSNEX_Const_URLorHostDataMissing          as Integer = -1000
Private Const TSNEX_Const_DisconnectedBeforSuccess      as Integer = -1001
Private Const TSNEX_Const_TimeOutBeforSuccess           as Integer = -1002
Private Const TSNEX_Const_TransmissionError             as Integer = -1003
Private Const TSNEX_Const_PathFileError                 as Integer = -1004
Private Const TSNEX_Const_TargetAlreadyExist            as Integer = -1005
Private Const TSNEX_Const_TargetPathNotFound            as Integer = -1006
Private Const TSNEX_Const_ProtocolNotSupported          as Integer = -1007
Private Const TSNEX_Const_EMailSyntaxError              as Integer = -1008
Private Const TSNEX_Const_MissingParameter              as Integer = -1009
Private Const TSNEX_Const_CantResolveWANIPA             as Integer = -1010
'--------------------------------------------------------------------------------------------------------------
Private Const TSNEX_Const_TRXE_DataLen                  as Integer = -1100
Private Const TSNEX_Const_TRXE_CantOpenTarget           as Integer = -1101
Private Const TSNEX_Const_TRXE_SyntaxError              as Integer = -1102
Private Const TSNEX_Const_TRXE_IncompleteTransmission   as Integer = -1103



'##############################################################################################################
#IFNDEF URL_Type
    Type URL_Type
        V_Protocol  as String
        V_Host      as String
        V_Port      as UShort
        V_Path      as String
        V_File      as String
        V_FileType  as String
        V_Username  as String
        V_Password  as String
        V_SubData   as String
    End Type
#ENDIF



'##############################################################################################################
Enum TSNEX_ConType_Enum
    TSNEX_CE_Unknown                = 0
    TSNEX_CE_HTTP                   = 1
    TSNEX_CE_FTP                    = 2
    TSNEX_CE_FTP_Data               = 3
    TSNEX_CE_SMTP                   = 4
End Enum

'--------------------------------------------------------------------------------------------------------------
Enum TSNEX_CMDType_Enum
    TSNEX_ME_FTP_List               = 0
    TSNEX_ME_FTP_Download           = 1
    TSNEX_ME_FTP_UpLoad             = 2
    TSNEX_ME_FTP_Delete             = 3
    TSNEX_ME_SMTP_Send              = 4
    TSNEX_ME_HTTP_GET               = 5
End Enum

'--------------------------------------------------------------------------------------------------------------
Enum TSNEX_State_Enum
    TSNEX_SE_Init                   = 0
    TSNEX_SE_Connected              = 1
    TSNEX_SE_Login                  = 2
    TSNEX_SE_Ready                  = 3
    TSNEX_SE_Info                   = 4
    TSNEX_SE_TX1                    = 5
    TSNEX_SE_TX2                    = 6
    TSNEX_SE_TX3                    = 7
    TSNEX_SE_TX4                    = 8
    TSNEX_SE_TX5                    = 9
    TSNEX_SE_TX6                    = 10
End Enum

'--------------------------------------------------------------------------------------------------------------
Type TSNEX_Mem_Type
    V_Next          as TSNEX_Mem_Type Ptr
    V_Data          as String
End Type
'--------------------------------------------------------------------------------------------------------------
Type TSNEX_Con_Type
    V_InUse         as UByte
    V_TSNEID        as UInteger
    V_State         as TSNEX_State_Enum

    V_URLType       as URL_Type

    V_Type          as TSNEX_ConType_Enum
    V_CMD           as TSNEX_CMDType_Enum
    V_Target        as String
    V_Data(8)       as String

    T_TimeOut       as Double
    T_Data          as String

    T_FID           as Integer
    T_MemF          as TSNEX_Mem_Type Ptr
    T_MemL          as TSNEX_Mem_Type Ptr
    T_FileSize      as UInteger

    T_SubTID        as UInteger
    T_PreTID        as UInteger
    T_HolTID        as UInteger

    T_CallBack      as Sub (V_Max as UInteger, V_Value as UInteger)

    T_ErrorCode     as Integer
End Type

'--------------------------------------------------------------------------------------------------------------
Dim Shared G_TSNEX_CD()     as TSNEX_Con_Type
Dim Shared G_TSNEX_CC       as UInteger
Dim Shared G_TSNEX_Mutex    as Any Ptr



'##############################################################################################################
Sub TSNEX_Construct () Constructor
G_TSNEX_Mutex = MutexCreate()
End Sub

'--------------------------------------------------------------------------------------------------------------
Sub TSNEX_Destruct () Destructor
MutexLock(G_TSNEX_Mutex)
MutexUnLock(G_TSNEX_Mutex)
MutexDestroy(G_TSNEX_Mutex)
End Sub



'##############################################################################################################
Function TSNEX_GetGURUCode(V_GuruCode as Integer) as String
Select Case V_GuruCode
    Case TSNEX_Const_URLorHostDataMissing:              Return "URL corrupt or Host / Port / Username / Passwort missing / corrupt!"
    Case TSNEX_Const_DisconnectedBeforSuccess:          Return "Dissconnected befor operation was successfully!"
    Case TSNEX_Const_TimeOutBeforSuccess:               Return "Operation Timeout befor operation successfully!"
    Case TSNEX_Const_TransmissionError:                 Return "Error while communication!"
    Case TSNEX_Const_PathFileError:                     Return "Path or / and File error!"
    Case TSNEX_Const_TargetAlreadyExist:                Return "Target / Source path / file already exist!"
    Case TSNEX_Const_TargetPathNotFound:                Return "Target / Source path / file not found!"
    Case TSNEX_Const_ProtocolNotSupported:              Return "Selected protocol was not supported by this function! (SMTP:// FTP:// HTTP:// ...)"
    Case TSNEX_Const_EMailSyntaxError:                  Return "E-Mail address syntax is wrong!"
    Case TSNEX_Const_MissingParameter:                  Return "Missing function parameter(s)!"
    Case TSNEX_Const_CantResolveWANIPA:                 Return "Can't resolve WAN IP-Address!"
'--------------------------------------------------------------------------------------------------------------
    Case TSNEX_Const_TRXE_DataLen:                      Return "TX/RX Error: To much incomming data!"
    Case TSNEX_Const_TRXE_CantOpenTarget:               Return "TX/RX Error: Can't open Target!"
    Case TSNEX_Const_TRXE_SyntaxError:                  Return "TX/RX Error: Syntaxerror in incomming data!"
    Case TSNEX_Const_TRXE_IncompleteTransmission:       Return "TX/RX Error: Disconnectet befor data transmission success!"
'--------------------------------------------------------------------------------------------------------------
    Case Else:                                          Return TSNE_GetGURUCode(V_GuruCode)
End Select
End Function



'##############################################################################################################
#IFNDEF URL_Split
    Private Function URL_Split(V_URL as String, ByRef B_Cut as URL_Type) as Integer
    Dim TCut as URL_Type
    With TCut
        Dim XPos as UInteger
        Dim D as String = V_URL
        XPos = InStr(1, D, "://")
        If XPos <= 0 Then Return 1
        .V_Protocol = lcase(mid(D, 1, XPos - 1))
        If InStr(1, .V_Protocol, " ") > 0 Then Return 1
        If InStr(1, .V_Protocol, Chr(9)) > 0 Then Return 1
        D = Mid(D, XPos + 3)
        XPos = InStr(1, D, "/")
        If XPos > 0 Then
            .V_Host = Mid(D, 1, XPos - 1): .V_Path = Mid(D, XPos)
        Else: .V_Host = D
        End If
        XPos = InStr(1, .V_Host, "@")
        If XPos > 0 Then .V_Username = Mid(.V_Host, 1, XPos - 1): .V_Host = Mid(.V_Host, XPos + 1)
        XPos = InStr(1, .V_Host, ":")
        If XPos > 0 Then .V_Port = Val(Mid(.V_Host, XPos + 1)): .V_Host = Mid(.V_Host, 1, XPos - 1)
        XPos = InStr(1, .V_Username, ":")
        If XPos > 0 Then .V_Password = Mid(.V_Username, XPos + 1): .V_Username = Mid(.V_Username, 1, XPos - 1)
        XPos = InStrRev(.V_Path, "/")
        If XPos > 0 Then
            .V_File = Mid(.V_Path, XPos + 1): .V_Path = Mid(.V_Path, 1, XPos)
        Else: .V_File = .V_Path: .V_Path = ""
        End If
        XPos = InStr(1, .V_File, "?")
        If XPos > 0 Then .V_SubData = Mid(.V_File, XPos + 1): .V_File = Mid(.V_File, 1, XPos - 1)
        XPos = InStr(1, .V_File, ".")
        If XPos > 0 Then .V_FileType = Mid(.V_File, XPos + 1): .V_File = Mid(.V_File, 1, XPos - 1)
    End With
    B_Cut = TCut
    Return 0
    End Function
#ENDIF





'###############################################################################################################
Function TSNEX_Base64_Decode(ByRef V_Source As String) As String
If V_Source = "" Then Return ""
Dim X as UInteger
Dim Base64_String as String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
Dim Code(0 to 255) As UByte
For X = 0 to Len(Base64_String) - 1
    Code(Base64_String[X]) = X
Next
Dim D as String = V_Source
Dim XLen As UInteger = Len(D)
Dim XRest As UInteger = XLen Mod 4
If XRest > 0 Then D += String(4 - XRest, 0): XLen = Len(D)
Dim XCNT As UInteger
Dim Result(0 to XLen - 1) As UByte
For X = 0 To XLen - 1 Step 4
    Result(XCNT) = ((Code(D[X]) * 4 + Int(Code(D[X + 1]) / 16)) And 255): XCNT += 1
    Result(XCNT) = ((Code(D[X + 1]) * 16 + Int(Code(D[X + 2]) / 4)) And 255): XCNT += 1
    Result(XCNT) = ((Code(D[X + 2]) * 64 + Code(D[X + 3])) And 255): XCNT += 1
Next
ReDim Preserve Result(0 to XCNT - 1) as UByte
D = Space(XCNT)
For X = 0 to XCNT - 1
    If Result(X) = 0 Then Exit For
    D[X] = Result(X)
Next
Return D
End Function



'---------------------------------------------------------------------------------------------------------------
Function TSNEX_Base64_Encode(ByRef V_Source As String) As String
If V_Source = "" Then Return ""
Dim X as UInteger
Dim Base64_String as String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
Dim XLen As UInteger = Len(V_Source)
Dim XRest As UInteger = XLen Mod 3
Dim XN As UInteger = XLen
If XRest > 0 Then XN = ((XLen \ 3) + 1) * 3
Dim D as String = String(4 * XN / 3, 0)
For X = 0 To XN / 3 - 1
    D[4 * X] = Base64_String[Int(V_Source[3 * X] / 4)]
    D[4 * X + 1] = Base64_String[(V_Source[3 * X] And 3) * 16 + Int(V_Source[3 * X + 1] / 16)]
    D[4 * X + 2] = Base64_String[(V_Source[3 * X + 1] And 15) * 4 + Int(V_Source[3 * X + 2] / 64)]
    D[4 * X + 3] = Base64_String[V_Source[3 * X + 2] And 63]
Next
Select Case XRest
    Case 1: D[Len(D) - 1] = 61: D[Len(D) - 2] = 61
    Case 2: D[Len(D) - 1] = 61
End Select
Return D
End Function



'##############################################################################################################
Function TSNEX_WaitState(V_TID as UInteger, V_State as UInteger) as Integer
MutexLock(G_TSNEX_Mutex)
G_TSNEX_CD(V_TID).T_TimeOut = Timer() + 60
MutexUnLock(G_TSNEX_Mutex)
Do
    MutexLock(G_TSNEX_Mutex)
    If G_TSNEX_CD(V_TID).V_State = V_State Then MutexUnLock(G_TSNEX_Mutex): Return TSNEX_Const_NoError
    If TSNE_IsClosed(G_TSNEX_CD(V_TID).V_TSNEID) = 1 Then
        Dim TErrC as Integer = G_TSNEX_CD(V_TID).T_ErrorCode
        MutexUnLock(G_TSNEX_Mutex)
        If TErrC <> 0 Then
            Return TErrC
        Else: Return TSNEX_Const_DisconnectedBeforSuccess
        End If
    End If
    If G_TSNEX_CD(V_TID).T_TimeOut < Timer() Then MutexUnLock(G_TSNEX_Mutex): Return TSNEX_Const_TimeOutBeforSuccess
    MutexUnLock(G_TSNEX_Mutex)
    Sleep 1, 1
Loop
End Function



'##############################################################################################################
Sub TSNEX_Disconnected(ByVal V_TSNEID as UInteger)
'Print "DIS:"; V_TSNEID
'if V_TSNEID = 1 then
'   Dim X as uinteger ptr
'   Print *X
'End If
MutexLock(G_TSNEX_Mutex)
For X as UInteger = 1 to G_TSNEX_CC
    If G_TSNEX_CD(X).V_InUse = 1 Then
        If G_TSNEX_CD(X).V_TSNEID = V_TSNEID Then
            G_TSNEX_CD(X).V_InUse = 0
            Select Case G_TSNEX_CD(X).V_Type
                Case TSNEX_CE_HTTP
                    If G_TSNEX_CD(X).V_Data(4) = "200" Then
                        Dim TMX as UInteger = G_TSNEX_CD(X).T_FileSize
                        Dim TMV as UInteger
                        If G_TSNEX_CD(X).T_FID > 0 Then
                            TMV = Lof(G_TSNEX_CD(X).T_FID)
                        Else: TMV = Len(G_TSNEX_CD(X).V_Data(8))
                        End If
                        Dim TCallBack as Sub (V_Max as UInteger, V_Value as UInteger) = G_TSNEX_CD(X).T_CallBack
                        If G_TSNEX_CD(X).T_FID <> 0 Then Close G_TSNEX_CD(X).T_FID: G_TSNEX_CD(X).T_FID = 0
                        If TCallBack <> 0 Then
                            If TMX > 0 Then
                                MutexUnLock(G_TSNEX_Mutex)
                                TCallBack(TMX, TMV)
                                MutexLock(G_TSNEX_Mutex)
                                If TMX = TMV Then
                                    G_TSNEX_CD(X).V_State = TSNEX_SE_Ready
                                Else: G_TSNEX_CD(X).T_ErrorCode = TSNEX_Const_TRXE_IncompleteTransmission
                                End If
                                MutexUnLock(G_TSNEX_Mutex)
                            Else
                                MutexUnLock(G_TSNEX_Mutex)
                                TCallBack(1, 1)
                                MutexLock(G_TSNEX_Mutex)
                                G_TSNEX_CD(X).V_State = TSNEX_SE_Ready
                                MutexUnLock(G_TSNEX_Mutex)
                            End If
                        Else
                            If TMX > 0 Then
                                If TMX = TMV Then
                                    G_TSNEX_CD(X).V_State = TSNEX_SE_Ready
                                Else: G_TSNEX_CD(X).T_ErrorCode = TSNEX_Const_TRXE_IncompleteTransmission
                                End If
                            Else: G_TSNEX_CD(X).V_State = TSNEX_SE_Ready
                            End If
                            G_TSNEX_CD(X).V_State = TSNEX_SE_Ready
                            MutexUnLock(G_TSNEX_Mutex)
                        End If
                    Else
                        If G_TSNEX_CD(X).T_FID <> 0 Then Close G_TSNEX_CD(X).T_FID: G_TSNEX_CD(X).T_FID = 0
                        MutexUnLock(G_TSNEX_Mutex)
                    End If
                Case Else
                    If G_TSNEX_CD(X).T_FID <> 0 Then Close G_TSNEX_CD(X).T_FID: G_TSNEX_CD(X).T_FID = 0
                    MutexUnLock(G_TSNEX_Mutex)
            End Select
            Exit Sub
        End If
    EndIf
Next
MutexUnLock(G_TSNEX_Mutex)
End Sub

'--------------------------------------------------------------------------------------------------------------
Sub TSNEX_Connected(ByVal V_TSNEID as UInteger)
'Print "CON:"; V_TSNEID
MutexLock(G_TSNEX_Mutex)
For X as UInteger = 1 to G_TSNEX_CC
    If G_TSNEX_CD(X).V_InUse <> 0 Then
        If G_TSNEX_CD(X).V_TSNEID = V_TSNEID Then
            G_TSNEX_CD(X).V_State = TSNEX_SE_Connected
            Dim T as String
            Select Case G_TSNEX_CD(X).V_Type
                Case TSNEX_CE_HTTP
                    T = G_TSNEX_CD(X).V_Data(1)
                    MutexUnLock(G_TSNEX_Mutex)
                    TSNE_Data_Send(V_TSNEID, T)
                Case Else: MutexUnLock(G_TSNEX_Mutex)
            End Select
            Exit Sub
        End If
    EndIf
Next
MutexUnLock(G_TSNEX_Mutex)
End Sub

'--------------------------------------------------------------------------------------------------------------
Sub TSNEX_NewData(ByVal V_TSNEID as UInteger, ByRef V_Data as String)
MutexLock(G_TSNEX_Mutex)
Dim XID as UInteger
For X as UInteger = 1 to G_TSNEX_CC
    If G_TSNEX_CD(X).V_InUse <> 0 Then
        If G_TSNEX_CD(X).V_TSNEID = V_TSNEID Then XID = X: Exit For
    EndIf
Next
If XID = 0 Then MutexUnLock(G_TSNEX_Mutex): Exit Sub
Dim XFBCRLF as String = Chr(13, 10)
Dim T as String
Dim T1 as String
Dim T2 as UShort
Dim T3 as String
Dim XCMD as UInteger
Dim XPos as UInteger
Dim RV as Integer
Dim XLCMD as UByte
Dim TData as String = G_TSNEX_CD(XID).T_Data & V_Data
Dim TCMDE as TSNEX_CMDType_Enum = G_TSNEX_CD(XID).V_CMD
Dim XURL as URL_Type = G_TSNEX_CD(XID).V_URLType
Dim XTSNEID as UInteger
Dim TXID as UInteger
Dim TCC as TSNEX_Con_Type
Dim TFID as Integer = G_TSNEX_CD(XID).T_FID
G_TSNEX_CD(XID).T_TimeOut = Timer() + 30
If G_TSNEX_CD(XID).T_PreTID <> 0 Then G_TSNEX_CD(G_TSNEX_CD(XID).T_PreTID).T_TimeOut = Timer() + 30
G_TSNEX_CD(XID).T_Data = ""
Dim TMX as UInteger
Dim TMV as UInteger
Dim TCallBack as Sub (V_Max as UInteger, V_Value as UInteger)
MutexUnLock(G_TSNEX_Mutex)
Select Case G_TSNEX_CD(XID).V_Type
    Case TSNEX_CE_FTP_Data
'       Print "NDA:"; V_TSNEID; " >"; V_Data; "<"
        If TFID = 0 Then
            MutexLock(G_TSNEX_Mutex)
            With G_TSNEX_CD(XID)
                If .T_MemL <> 0 Then
                    .T_MemL->V_Next = CAllocate(SizeOf(TSNEX_Mem_Type))
                    .T_MemL = .T_MemL->V_Next
                Else
                    .T_MemL = CAllocate(SizeOf(TSNEX_Mem_Type))
                    .T_MemF = .T_MemL
                EndIf
                .T_MemL->V_Data = TData
            End With
            MutexUnLock(G_TSNEX_Mutex)
        Else
            Print #TFID, TData;
            MutexLock(G_TSNEX_Mutex)
            G_TSNEX_CD(XID).T_FileSize += Len(TData)
            TMV = G_TSNEX_CD(XID).T_FileSize
            If G_TSNEX_CD(XID).T_PreTID <> 0 Then
                TMX = G_TSNEX_CD(G_TSNEX_CD(XID).T_PreTID).T_FileSize
                TCallBack = G_TSNEX_CD(G_TSNEX_CD(XID).T_PreTID).T_CallBack
            End If
            MutexUnLock(G_TSNEX_Mutex)
            If TCallBack <> 0 Then TCallBack(TMX, TMV)
        EndIf

    Case TSNEX_CE_FTP
'       Print "NDA:"; V_TSNEID; " >"; V_Data; "<"
        If Len(TData) > 100000 Then MutexLock(G_TSNEX_Mutex): G_TSNEX_CD(XID).T_ErrorCode = TSNEX_Const_TRXE_DataLen: MutexUnLock(G_TSNEX_Mutex): TSNE_Disconnect(V_TSNEID): Exit Sub
        Do
            XPos = InStr(1, TData, XFBCRLF)
            If XPos = 0 Then MutexLock(G_TSNEX_Mutex): G_TSNEX_CD(XID).T_Data = TData: MutexUnLock(G_TSNEX_Mutex): Exit Sub
            T = Mid(TData, 1, XPos - 1): TData = Mid(TData, XPos + 2)
            If Mid(T, 4, 1) = "-" Then XLCMD = 0 Else XLCMD = 1
            XCMD = Val(Left(T, 3)): T = Mid(T, 5)
'           Print "     >"; V_TSNEID; "<___>"; XCMD; "<___>"; T; "<"
            If XLCMD = 1 Then
                Print "CMD: >"; V_TSNEID; "<___>"; XCMD; "<___>"; T; "<"
                Select Case XCMD
                    case 150
                        Select case TCMDE
                            case TSNEX_ME_FTP_UpLoad
                                MutexLock(G_TSNEX_Mutex)
                                If G_TSNEX_CD(XID).V_State = TSNEX_SE_Info Then
                                    XTSNEID = G_TSNEX_CD(XID).T_HolTID
                                    #IF DEFINED(TSNEX_DEF_FileMutex)
                                        MutexLock(TSNEX_FileMutex)
                                    #ENDIF
                                    TFID = FreeFile
                                    If Open(G_TSNEX_CD(XID).V_Target for Binary as #TFID) <> 0 Then
                                        #IF DEFINED(TSNEX_DEF_FileMutex)
                                            MutexUnLock(TSNEX_FileMutex)
                                        #ENDIF
                                        G_TSNEX_CD(XID).T_ErrorCode = TSNEX_Const_TRXE_CantOpenTarget
                                        MutexUnLock(G_TSNEX_Mutex)
                                        TSNE_Disconnect(XTSNEID)
                                        TSNE_Disconnect(V_TSNEID)
                                        Exit Sub
                                    End If
                                    #IF DEFINED(TSNEX_DEF_FileMutex)
                                        MutexUnLock(TSNEX_FileMutex)
                                    #ENDIF
                                    TCallBack = G_TSNEX_CD(XID).T_CallBack
                                    MutexUnLock(G_TSNEX_Mutex)
                                    TMX = Lof(TFID)
                                    T = Space(TSNE_INT_BufferSize)
                                    If TCallBack <> 0 Then TCallBack(TMX, 0)
                                    For X as UInteger = 1 to TMX Step TSNE_INT_BufferSize
                                        If TMX - X < TSNE_INT_BufferSize Then T = Space(TMX - X + 1)
                                        Get #TFID, X, T
                                        RV = TSNE_Data_Send(XTSNEID, T)
                                        If RV <> TSNE_Const_NoError Then
                                            MutexLock(G_TSNEX_Mutex): G_TSNEX_CD(XID).T_ErrorCode = RV: MutexUnLock(G_TSNEX_Mutex)
                                            Close TFID
                                            TSNE_Disconnect(XTSNEID)
                                            TSNE_Disconnect(V_TSNEID)
                                            Exit Sub
                                        End If
                                        If TCallBack <> 0 Then TCallBack(TMX, X)
                                    Next
                                    If TCallBack <> 0 Then TCallBack(TMX, TMX)
                                    TSNE_Disconnect(XTSNEID)
                                Else: MutexUnLock(G_TSNEX_Mutex)
                                End If
                        End select
                    case 200
                        Select case TCMDE
                            case TSNEX_ME_FTP_List, TSNEX_ME_FTP_Download, TSNEX_ME_FTP_UpLoad
                                TSNE_Data_Send(V_TSNEID, "PASV" & XFBCRLF)
                        End select
                    case 220: TSNE_Data_Send(V_TSNEID, "USER " & XURL.V_Username & XFBCRLF)
                    case 221'Quit
                    case 226
                        Select case TCMDE
                            Case TSNEX_ME_FTP_List, TSNEX_ME_FTP_DownLoad
                            case TSNEX_ME_FTP_UpLoad
                                MutexLock(G_TSNEX_Mutex)
                                If G_TSNEX_CD(XID).V_State = TSNEX_SE_Info Then
                                    MutexUnLock(G_TSNEX_Mutex)
                                    MutexLock(G_TSNEX_Mutex): G_TSNEX_CD(XID).V_State = TSNEX_SE_Ready: MutexUnLock(G_TSNEX_Mutex)
                                    TSNE_Disconnect(V_TSNEID): Exit Sub
                                Else
                                    G_TSNEX_CD(XID).V_State = TSNEX_SE_Info
                                    MutexUnLock(G_TSNEX_Mutex)
                                    TSNE_Data_Send(V_TSNEID, "PASV" & XFBCRLF)
                                End If
                            Case Else
                                MutexLock(G_TSNEX_Mutex): G_TSNEX_CD(XID).V_State = TSNEX_SE_Ready: MutexUnLock(G_TSNEX_Mutex)
                                TSNE_Disconnect(V_TSNEID): Exit Sub
                        End Select
                    case 227
                        'Print "FTP LINE: >"; T; "<"
                        XPos = InStr(1, T, "("): If XPos <= 0 Then MutexLock(G_TSNEX_Mutex): G_TSNEX_CD(XID).T_ErrorCode = TSNEX_Const_TRXE_SyntaxError: MutexUnLock(G_TSNEX_Mutex): TSNE_Disconnect(V_TSNEID): Exit Sub
                        T = Mid(T, XPos + 1)
                        XPos = InStr(1, T, ")"): If XPos <= 0 Then MutexLock(G_TSNEX_Mutex): G_TSNEX_CD(XID).T_ErrorCode = TSNEX_Const_TRXE_SyntaxError: MutexUnLock(G_TSNEX_Mutex): TSNE_Disconnect(V_TSNEID): Exit Sub
                        T = Mid(T, 1, XPos - 1)
                        For Y as UInteger = 1 to Len(T)
                            XPos = InStr(1, T, ",")
                            If XPos > 0 Then
                                Select Case Y
                                    Case 1 To 4: T1 += Left(T, XPos - 1) & ".": T = Mid(T, XPos + 1)
                                    Case Else: T2 = (256 * Val(Left(T, XPos - 1))) + Val(Mid(T, XPos + 1)): Exit For
                                End Select
                            End If
                        Next
                        If (T1 = "") or (T2 <= 0) Then MutexLock(G_TSNEX_Mutex): G_TSNEX_CD(XID).T_ErrorCode = TSNEX_Const_TRXE_SyntaxError: MutexUnLock(G_TSNEX_Mutex): TSNE_Disconnect(V_TSNEID): Exit Sub
                        T1 = Left(T1, Len(T1) - 1)
                        MutexLock(G_TSNEX_Mutex)
                        RV = TSNE_Create_Client(XTSNEID, T1, T2, @TSNEX_Disconnected, @TSNEX_Connected, @TSNEX_NewData)
                        If RV <> TSNE_Const_NoError Then G_TSNEX_CD(XID).T_ErrorCode = TSNEX_Const_TRXE_SyntaxError: MutexUnLock(G_TSNEX_Mutex): TSNE_Disconnect(V_TSNEID): Exit Sub
                        For X as UInteger = 1 to G_TSNEX_CC
                            If G_TSNEX_CD(X).V_InUse = 0 Then TXID = X: Exit For
                        Next
                        If TXID = 0 Then G_TSNEX_CC += 1: TXID = G_TSNEX_CC: Redim Preserve G_TSNEX_CD(G_TSNEX_CC) as TSNEX_Con_Type
                        G_TSNEX_CD(TXID) = TCC
                        With G_TSNEX_CD(TXID)
                            .V_InUse    = 2
                            .V_TSNEID   = XTSNEID
                            .V_State    = TSNEX_SE_Init
                            .V_URLType  = XURL
                            .T_PreTID   = XID
                            .V_Type     = TSNEX_CE_FTP_Data
                        End With
                        MutexUnLock(G_TSNEX_Mutex)
                        RV = TSNEX_WaitState(TXID, TSNEX_SE_Connected)
                        If RV <> TSNEX_Const_NoError Then MutexLock(G_TSNEX_Mutex): G_TSNEX_CD(XID).T_ErrorCode = RV: MutexUnLock(G_TSNEX_Mutex): TSNE_Disconnect(V_TSNEID): Exit Sub
                        Select case TCMDE
                            case TSNEX_ME_FTP_List:         TSNE_Data_Send(V_TSNEID, "LIST" & XFBCRLF)
                            case TSNEX_ME_FTP_Download, TSNEX_ME_FTP_UpLoad
                                MutexLock(G_TSNEX_Mutex)
                                If G_TSNEX_CD(XID).V_State <> TSNEX_SE_Info Then
                                    MutexUnLock(G_TSNEX_Mutex)
                                    If XURL.V_FileType <> "" Then
                                        TSNE_Data_Send(V_TSNEID, "LIST " & XURL.V_File & "." & XURL.V_FileType & XFBCRLF)
                                    Else: TSNE_Data_Send(V_TSNEID, "LIST " & XURL.V_File & XFBCRLF)
                                    End If
                                Else
                                    Select case TCMDE
                                        case TSNEX_ME_FTP_Download
                                            #IF DEFINED(TSNEX_DEF_FileMutex)
                                                MutexLock(TSNEX_FileMutex)
                                            #ENDIF
                                            G_TSNEX_CD(TXID).T_FID = FreeFile
                                            If Open(G_TSNEX_CD(XID).V_Target for Binary as #G_TSNEX_CD(TXID).T_FID) <> 0 Then
                                                #IF DEFINED(TSNEX_DEF_FileMutex)
                                                    MutexUnLock(TSNEX_FileMutex)
                                                #ENDIF
                                                G_TSNEX_CD(TXID).T_FID = 0
                                                G_TSNEX_CD(XID).T_ErrorCode = TSNEX_Const_TRXE_CantOpenTarget
                                                MutexUnLock(G_TSNEX_Mutex)
                                                TSNE_Disconnect(V_TSNEID)
                                                Exit Sub
                                            End If
                                            #IF DEFINED(TSNEX_DEF_FileMutex)
                                                MutexUnLock(TSNEX_FileMutex)
                                            #ENDIF
                                            MutexUnLock(G_TSNEX_Mutex)
                                            If XURL.V_FileType <> "" Then
                                                TSNE_Data_Send(V_TSNEID, "RETR " & XURL.V_File & "." & XURL.V_FileType & XFBCRLF)
                                            Else: TSNE_Data_Send(V_TSNEID, "RETR " & XURL.V_File & XFBCRLF)
                                            End If
                                        case TSNEX_ME_FTP_UpLoad
                                            G_TSNEX_CD(XID).T_HolTID = XTSNEID
                                            MutexUnLock(G_TSNEX_Mutex)
                                            If XURL.V_FileType <> "" Then
                                                TSNE_Data_Send(V_TSNEID, "STOR " & XURL.V_File & "." & XURL.V_FileType & XFBCRLF)
                                            Else: TSNE_Data_Send(V_TSNEID, "STOR " & XURL.V_File & XFBCRLF)
                                            End If
                                        Case Else: MutexUnLock(G_TSNEX_Mutex)
                                    End Select
                                End If
                        End select
                        Select Case TCMDE
                            case TSNEX_ME_FTP_List, TSNEX_ME_FTP_Download, TSNEX_ME_FTP_UpLoad
                                Select case TCMDE
                                    case TSNEX_ME_FTP_List
                                        TSNE_WaitClose(XTSNEID)
                                        MutexLock(G_TSNEX_Mutex)
                                        G_TSNEX_CD(XID).T_SubTID = TXID
                                        G_TSNEX_CD(XID).V_State = TSNEX_SE_Ready
                                        MutexUnLock(G_TSNEX_Mutex)
                                    case TSNEX_ME_FTP_DownLoad
                                        TSNE_WaitClose(XTSNEID)
                                        MutexLock(G_TSNEX_Mutex)
                                        G_TSNEX_CD(XID).T_SubTID = TXID
                                        If G_TSNEX_CD(XID).V_State <> TSNEX_SE_Info Then
                                            If G_TSNEX_CD(TXID).T_MemF = 0 Then G_TSNEX_CD(XID).T_ErrorCode = TSNEX_Const_TRXE_SyntaxError: MutexUnLock(G_TSNEX_Mutex): TSNE_Disconnect(V_TSNEID): Exit Sub
                                            T1 = G_TSNEX_CD(TXID).T_MemF->V_Data
                                            DeAllocate(G_TSNEX_CD(TXID).T_MemF)
                                            G_TSNEX_CD(TXID).V_InUse = 0
                                            T1 = Trim(Mid(T1, 11))
                                            XPos = InStr(1, T1, " "): If XPos = 0 Then G_TSNEX_CD(XID).T_ErrorCode = TSNEX_Const_TRXE_SyntaxError: MutexUnLock(G_TSNEX_Mutex): TSNE_Disconnect(V_TSNEID): Exit Sub
                                            T1 = Trim(Mid(T1, XPos + 1))
                                            XPos = InStr(1, T1, " "): If XPos = 0 Then G_TSNEX_CD(XID).T_ErrorCode = TSNEX_Const_TRXE_SyntaxError: MutexUnLock(G_TSNEX_Mutex): TSNE_Disconnect(V_TSNEID): Exit Sub
                                            T1 = Trim(Mid(T1, XPos + 1))
                                            XPos = InStr(1, T1, " "): If XPos = 0 Then G_TSNEX_CD(XID).T_ErrorCode = TSNEX_Const_TRXE_SyntaxError: MutexUnLock(G_TSNEX_Mutex): TSNE_Disconnect(V_TSNEID): Exit Sub
                                            T1 = Trim(Mid(T1, XPos + 1))
                                            XPos = InStr(1, T1, " "): If XPos = 0 Then G_TSNEX_CD(XID).T_ErrorCode = TSNEX_Const_TRXE_SyntaxError: MutexUnLock(G_TSNEX_Mutex): TSNE_Disconnect(V_TSNEID): Exit Sub
                                            T1 = Trim(Left(T1, XPos - 1))
                                            G_TSNEX_CD(XID).T_FileSize = ValUInt(T1)
                                            G_TSNEX_CD(XID).V_State = TSNEX_SE_Info
                                            MutexUnLock(G_TSNEX_Mutex)
                                            TSNE_Data_Send(V_TSNEID, "PASV" & XFBCRLF)
                                        Else: G_TSNEX_CD(XID).V_State = TSNEX_SE_Ready: MutexUnLock(G_TSNEX_Mutex)
                                        End If
                                    Case TSNEX_ME_FTP_UpLoad
                                        MutexLock(G_TSNEX_Mutex)
                                        If G_TSNEX_CD(XID).V_State <> TSNEX_SE_Info Then
                                            MutexUnLock(G_TSNEX_Mutex)
                                            TSNE_WaitClose(XTSNEID)
                                            MutexLock(G_TSNEX_Mutex)
                                            G_TSNEX_CD(XID).T_SubTID = TXID
                                            If G_TSNEX_CD(TXID).T_MemF <> 0 Then
                                                DeAllocate(G_TSNEX_CD(TXID).T_MemF)
                                                G_TSNEX_CD(XID).T_ErrorCode = TSNEX_Const_TargetAlreadyExist
                                                MutexUnLock(G_TSNEX_Mutex)
                                                TSNE_Disconnect(V_TSNEID)
                                                Exit Sub
                                            End If
                                            MutexUnLock(G_TSNEX_Mutex)
                                        Else: MutexUnLock(G_TSNEX_Mutex)
                                        End If
                                    Case Else: MutexUnLock(G_TSNEX_Mutex)
                                End Select
                        End Select
                    case 230: TSNE_Data_Send(V_TSNEID, "CWD " & XURL.V_Path & XFBCRLF)
                    case 250
                        Select case TCMDE
                            case TSNEX_ME_FTP_List
                                TSNE_Data_Send(V_TSNEID, "TYPE A" & XFBCRLF)
                            Case TSNEX_ME_FTP_DownLoad, TSNEX_ME_FTP_Upload
                                TSNE_Data_Send(V_TSNEID, "TYPE L 8" & XFBCRLF)
                            Case TSNEX_ME_FTP_Delete
                                MutexLock(G_TSNEX_Mutex)
                                If G_TSNEX_CD(XID).V_State <> TSNEX_SE_Info Then
                                    G_TSNEX_CD(XID).V_State = TSNEX_SE_Info
                                    MutexUnLock(G_TSNEX_Mutex)
                                    If XURL.V_FileType <> "" Then
                                        TSNE_Data_Send(V_TSNEID, "DELE " & XURL.V_File & "." & XURL.V_FileType & XFBCRLF)
                                    Else: TSNE_Data_Send(V_TSNEID, "DELE " & XURL.V_File & XFBCRLF)
                                    End If
                                Else
                                    G_TSNEX_CD(XID).V_State = TSNEX_SE_Ready
                                    MutexUnLock(G_TSNEX_Mutex)
                                End If
                        End Select
                    case 226
                    case 331: TSNE_Data_Send(V_TSNEID, "PASS " & XURL.V_Password & XFBCRLF)
                    Case Else: MutexLock(G_TSNEX_Mutex): G_TSNEX_CD(XID).T_ErrorCode = TSNEX_Const_TRXE_SyntaxError: MutexUnLock(G_TSNEX_Mutex): TSNE_Disconnect(V_TSNEID): Exit Sub
                End Select
            End If
        Loop

    Case TSNEX_CE_SMTP
        If Len(TData) > 100000 Then MutexLock(G_TSNEX_Mutex): G_TSNEX_CD(XID).T_ErrorCode = TSNEX_Const_TRXE_DataLen: MutexUnLock(G_TSNEX_Mutex): TSNE_Disconnect(V_TSNEID): Exit Sub
        Do
            XPos = InStr(1, TData, XFBCRLF)
            If XPos = 0 Then MutexLock(G_TSNEX_Mutex): G_TSNEX_CD(XID).T_Data = TData: MutexUnLock(G_TSNEX_Mutex): Exit Sub
            T = Mid(TData, 1, XPos - 1): TData = Mid(TData, XPos + 2)
            If Mid(T, 4, 1) = "-" Then XLCMD = 0 Else XLCMD = 1
            XCMD = Val(Left(T, 3)): T = Mid(T, 5)
            If XLCMD = 1 Then
                Select Case XCMD
                    Case 220
                        XPos = InStrRev(T, " ")
                        If XPos > 0 Then T = Mid(T, XPos + 1)
                        MutexLock(G_TSNEX_Mutex)
                        Select Case UCase(T)
                            Case "ESMTP"
                                G_TSNEX_CD(XID).V_State = TSNEX_SE_TX1
                                MutexUnLock(G_TSNEX_Mutex)
                                TSNE_Data_Send(V_TSNEID, "EHLO TSNEX_E-Mail-Function" & Chr(13, 10))
                            Case Else
                                G_TSNEX_CD(XID).V_State = TSNEX_SE_TX3
                                MutexUnLock(G_TSNEX_Mutex)
                                TSNE_Data_Send(V_TSNEID, "HELO TSNEX_E-Mail-Function" & Chr(13, 10))
                        End Select
                    Case 221
                        MutexLock(G_TSNEX_Mutex)
                        G_TSNEX_CD(XID).V_State = TSNEX_SE_Ready
                        MutexUnLock(G_TSNEX_Mutex)
                        TSNE_Disconnect(V_TSNEID)
                    Case 235
                        MutexLock(G_TSNEX_Mutex)
                        G_TSNEX_CD(XID).V_State = TSNEX_SE_TX4
                        T = G_TSNEX_CD(XID).V_Data(1)
                        MutexUnLock(G_TSNEX_Mutex)
                        TSNE_Data_Send(V_TSNEID, "MAIL FROM:<" & T & ">" & Chr(13, 10))
                    Case 250
                        MutexLock(G_TSNEX_Mutex)
                        Select Case G_TSNEX_CD(XID).V_State
                            Case TSNEX_SE_TX1
                                MutexUnLock(G_TSNEX_Mutex)
                                TSNE_Data_Send(V_TSNEID, "AUTH LOGIN" & Chr(13, 10))
                            Case TSNEX_SE_TX3
                                G_TSNEX_CD(XID).V_State = TSNEX_SE_TX4
                                T = G_TSNEX_CD(XID).V_Data(1)
                                MutexUnLock(G_TSNEX_Mutex)
                                TSNE_Data_Send(V_TSNEID, "MAIL FROM:<" & T & ">" & Chr(13, 10))
                            Case TSNEX_SE_TX4
                                G_TSNEX_CD(XID).V_State = TSNEX_SE_TX5
                                T = G_TSNEX_CD(XID).V_Data(2)
                                MutexUnLock(G_TSNEX_Mutex)
                                TSNE_Data_Send(V_TSNEID, "RCPT TO:<" & T & ">" & Chr(13, 10))
                            Case TSNEX_SE_TX5
                                G_TSNEX_CD(XID).V_State = TSNEX_SE_TX6
                                MutexUnLock(G_TSNEX_Mutex)
                                TSNE_Data_Send(V_TSNEID, "DATA" & Chr(13, 10))
                            Case TSNEX_SE_TX6
                                MutexUnLock(G_TSNEX_Mutex)
                                TSNE_Data_Send(V_TSNEID, "QUIT" & Chr(13, 10))
                            Case Else: MutexUnLock(G_TSNEX_Mutex)
                        End Select
                    Case 334
                        MutexLock(G_TSNEX_Mutex)
                        Select Case G_TSNEX_CD(XID).V_State
                            Case TSNEX_SE_TX1
                                G_TSNEX_CD(XID).V_State = TSNEX_SE_TX2
                                T = TSNEX_Base64_Encode(XURL.V_Username)
                                MutexUnLock(G_TSNEX_Mutex)
                                TSNE_Data_Send(V_TSNEID, T & Chr(13, 10))
                            Case TSNEX_SE_TX2
                                T = TSNEX_Base64_Encode(XURL.V_Password)
                                MutexUnLock(G_TSNEX_Mutex)
                                TSNE_Data_Send(V_TSNEID, T & Chr(13, 10))
                            Case Else: MutexUnLock(G_TSNEX_Mutex)
                        End Select
                    Case 354
                        MutexLock(G_TSNEX_Mutex)
                        T = "From: " & G_TSNEX_CD(XID).V_Data(1) & Chr(13, 10)
                        T += "To: " & G_TSNEX_CD(XID).V_Data(2) & Chr(13, 10)
                        T += "Subject: " & G_TSNEX_CD(XID).V_Data(3) & Chr(13, 10)
                        T += "Date: " & Format(Now(), "ddd, dd mmm yyyy hh:mm:ss") & Chr(13, 10)
                        T += Chr(13, 10)
                        MutexUnLock(G_TSNEX_Mutex)
                        TSNE_Data_Send(V_TSNEID, T)
                        MutexLock(G_TSNEX_Mutex)
                        T = G_TSNEX_CD(XID).V_Data(4) & Chr(13, 10) & "." & Chr(13, 10)
                        MutexUnLock(G_TSNEX_Mutex)
                        TSNE_Data_Send(V_TSNEID, T)
                    Case Else: MutexLock(G_TSNEX_Mutex): G_TSNEX_CD(XID).T_ErrorCode = TSNEX_Const_TRXE_SyntaxError: MutexUnLock(G_TSNEX_Mutex): TSNE_Disconnect(V_TSNEID): Exit Sub
                End Select
            End If
        Loop

    Case TSNEX_CE_HTTP
'       Print "NDA:"; V_TSNEID; " >"; V_Data; "<"
        MutexLock(G_TSNEX_Mutex)
        Select Case G_TSNEX_CD(XID).V_State
            Case TSNEX_SE_Connected
                If Len(TData) > 100000 Then G_TSNEX_CD(XID).T_ErrorCode = TSNEX_Const_TRXE_DataLen: MutexUnLock(G_TSNEX_Mutex): TSNE_Disconnect(V_TSNEID): Exit Sub
                MutexUnLock(G_TSNEX_Mutex)
                XPos = InStr(1, TData, Chr(13, 10, 13, 10))
                If XPos <= 0 Then Exit Sub
                T = Left(TData, XPos - 1)
                TData = Mid(TData, XPos + 4)
                XPos = InStr(1, T, Chr(13, 10))
                If XPos <= 0 Then MutexLock(G_TSNEX_Mutex): G_TSNEX_CD(XID).T_ErrorCode = TSNEX_Const_TRXE_SyntaxError: MutexUnLock(G_TSNEX_Mutex): TSNE_Disconnect(V_TSNEID): Exit Sub
                T1 = Mid(T, XPos + 2)
                T = Left(T, XPos - 1)
                XPos = InStr(1, T, " ")
                If XPos <= 0 Then MutexLock(G_TSNEX_Mutex): G_TSNEX_CD(XID).T_ErrorCode = TSNEX_Const_TRXE_SyntaxError: MutexUnLock(G_TSNEX_Mutex): TSNE_Disconnect(V_TSNEID): Exit Sub
                T = Mid(T, XPos + 1)
                XPos = InStr(1, T, " ")
                MutexLock(G_TSNEX_Mutex)
                If XPos <= 0 Then G_TSNEX_CD(XID).T_ErrorCode = TSNEX_Const_TRXE_SyntaxError: MutexUnLock(G_TSNEX_Mutex): TSNE_Disconnect(V_TSNEID): Exit Sub
                G_TSNEX_CD(XID).V_Data(4) = Left(T, XPos - 1)
                For X as UInteger = 1 to Len(T1)
                    XPos = InStr(1, T1, Chr(13, 10))
                    If XPos = 0 Then Exit For
                    T3 = Left(T1, XPos - 1)
                    T1 = Mid(T1, XPos + 2)
                    XPos = InStr(1, T3, ":")
                    If XPos > 0 Then
                        Select Case LCase(Trim(Left(T3, XPos - 1)))
                            Case "content_length"
                                G_TSNEX_CD(XID).T_FileSize = ValUInt(Trim(Mid(T3, XPos + 1)))
                                Exit For
                        End Select
                    End If
                Next
                If G_TSNEX_CD(XID).V_Data(4) = "200" Then
                    If G_TSNEX_CD(XID).V_Target <> "" Then
                        #IF DEFINED(TSNEX_DEF_FileMutex)
                            MutexLock(TSNEX_FileMutex)
                        #ENDIF
                        TFID = FreeFile
                        If Open(G_TSNEX_CD(XID).V_Target for Binary as #TFID) <> 0 Then
                            #IF DEFINED(TSNEX_DEF_FileMutex)
                                MutexUnLock(TSNEX_FileMutex)
                            #ENDIF
                            G_TSNEX_CD(XID).T_ErrorCode = TSNEX_Const_TRXE_CantOpenTarget
                            MutexUnLock(G_TSNEX_Mutex)
                            TSNE_Disconnect(V_TSNEID)
                            Exit Sub
                        End If
                        #IF DEFINED(TSNEX_DEF_FileMutex)
                            MutexUnLock(TSNEX_FileMutex)
                        #ENDIF
                        G_TSNEX_CD(XID).T_FID = TFID
                        Print #TFID, TData;
                    Else: G_TSNEX_CD(XID).V_Data(8) = TData
                    End If
                    G_TSNEX_CD(XID).V_State = TSNEX_SE_TX1
                    TMX = G_TSNEX_CD(XID).T_FileSize
                    TMV = Len(TData)
                    TCallBack = G_TSNEX_CD(XID).T_CallBack
                    MutexUnLock(G_TSNEX_Mutex)
                    If TCallBack <> 0 Then
                        If TMX > 0 Then
                            TCallBack(TMX, 0)
                            TCallBack(TMX, TMV)
                        Else: TCallBack(1, 0)
                        End If
                    End If
                End If
            Case TSNEX_SE_TX1
                If G_TSNEX_CD(XID).V_Target <> "" Then
                    Print #TFID, TData;
                    TMV = Lof(TFID)
                Else
                    G_TSNEX_CD(XID).V_Data(8) += TData
                    TMV = Len(G_TSNEX_CD(XID).V_Data(8))
                End If
                TMX = G_TSNEX_CD(XID).T_FileSize
                TCallBack = G_TSNEX_CD(XID).T_CallBack
                MutexUnLock(G_TSNEX_Mutex)
                If TCallBack <> 0 Then
                    If TMX > 0 Then
                        TCallBack(TMX, TMV)
                    Else: TCallBack(1, 0)
                    End If
                End If
            Case Else: MutexUnLock(G_TSNEX_Mutex)
        End Select

End Select
MutexUnLock(G_TSNEX_Mutex)
End Sub



'##############################################################################################################
Function TSNEX_FTP_List(V_HostOrURL as String, V_Port as UShort = 0, V_Username as String = "anonymous", V_Password as String = "anynomous@ano.nym", V_Path as String = "", R_FolderD() as String, ByRef R_FolderC as UInteger, R_FileD() as String, ByRef R_FileC as UInteger) as Integer
Dim XURL as URL_Type
If URL_Split(V_HostOrURL, XURL) = 1 Then
    With XURL
        .V_Protocol     = "ftp"
        .V_Host         = V_HostOrURL
        .V_Port         = V_Port
        .V_Username     = V_Username
        .V_Password     = V_Password
        .V_Path         = V_Path
    End With
End If
With XURL
    If LCase(.V_Protocol) <> "ftp" Then Return TSNEX_Const_ProtocolNotSupported
    If .V_Port = 0 Then .V_Port = 21
    If .V_Path = "" Then .V_Path = "/"
    If (.V_Host = "") or (.V_Port = 0) or (.V_Username = "") or (.V_Password = "") Then Return TSNEX_Const_URLorHostDataMissing
    MutexLock(G_TSNEX_Mutex)
    Dim XTSNEID as UInteger
    Dim RV as Integer = TSNE_Create_Client(XTSNEID, .V_Host, .V_Port, @TSNEX_Disconnected, @TSNEX_Connected, @TSNEX_NewData)
    If RV <> TSNE_Const_NoError Then MutexUnLock(G_TSNEX_Mutex): Return RV
End With
Dim XID as UInteger
For X as UInteger = 1 to G_TSNEX_CC
    If G_TSNEX_CD(X).V_InUse = 0 Then XID = X: Exit For
Next
If XID = 0 Then G_TSNEX_CC += 1: XID = G_TSNEX_CC: Redim Preserve G_TSNEX_CD(G_TSNEX_CC) as TSNEX_Con_Type
Dim TCC as TSNEX_Con_Type
G_TSNEX_CD(XID) = TCC
With G_TSNEX_CD(XID)
    .V_InUse    = 1
    .V_TSNEID   = XTSNEID
    .V_State    = TSNEX_SE_Init
    .V_URLType  = XURL
    .V_Type     = TSNEX_CE_FTP
    .V_CMD      = TSNEX_ME_FTP_List
End With
MutexUnLock(G_TSNEX_Mutex)
R_FolderC = 0
R_FileC = 0
RV = TSNEX_WaitState(XID, TSNEX_SE_Ready): If RV <> TSNEX_Const_NoError Then MutexLock(G_TSNEX_Mutex): If G_TSNEX_CD(XID).V_TSNEID = XTSNEID Then G_TSNEX_CD(XID) = TCC: MutexUnLock(G_TSNEX_Mutex): Return RV
MutexLock(G_TSNEX_Mutex)
If G_TSNEX_CD(XID).T_SubTID = 0 Then MutexUnLock(G_TSNEX_Mutex): Return TSNEX_Const_TransmissionError
Dim D as String
Dim T as String
Dim TPtr as TSNEX_Mem_Type Ptr = G_TSNEX_CD(G_TSNEX_CD(XID).T_SubTID).T_MemF
Dim NPtr as TSNEX_Mem_Type Ptr
Dim XPos as UInteger
Dim TFC1 as UInteger
Dim TFC2 as UInteger
Do Until TPtr = 0
    D += TPtr->V_Data
    Do
        XPos = InStr(1, D, Chr(10))
        If XPos = 0 Then Exit Do
        T = Left(D, XPos - 1)
        D = Mid(D, XPos + 1)
        If Right(T, 1) = Chr(13) Then T = Left(T, Len(T) - 1)
        If T <> "" Then
            If Left(T, 1) = "-" Then
                R_FileC += 1
                If TFC1 < R_FileC Then
                    TFC1 += 25
                    Redim Preserve R_FileD(TFC1) as String
                End If
                R_FileD(R_FileC) = Mid(T, 56)
            Else
                R_FolderC += 1
                If TFC2 < R_FolderC Then
                    TFC2 += 25
                    Redim Preserve R_FolderD(TFC2) as String
                End If
                R_FolderD(R_FolderC) = Mid(T, 56)
            End If
        End If
    Loop
    NPtr = TPtr->V_Next
    DeAllocate(TPtr)
    TPtr = NPtr
Loop
If G_TSNEX_CD(XID).T_SubTID <> 0 Then G_TSNEX_CD(G_TSNEX_CD(XID).T_SubTID).V_InUse = 0
MutexUnLock(G_TSNEX_Mutex)
TSNE_Disconnect(XTSNEID)
Redim Preserve R_FileD(R_FileC) as String
Redim Preserve R_FolderD(R_FolderC) as String
Return TSNEX_Const_NoError
End Function

'--------------------------------------------------------------------------------------------------------------
Function TSNEX_FTP_Download(V_HostOrURL as String, V_Port as UShort = 0, V_Username as String = "anonymous", V_Password as String = "anynomous@ano.nym", V_PathFile as String = "", V_TargetPathFile as String = "", V_ProgressCallback as Any Ptr = 0) as Integer
Dim XURL as URL_Type
Dim XPos as UInteger
If URL_Split(V_HostOrURL, XURL) = 1 Then
    With XURL
        .V_Protocol     = "ftp"
        .V_Host         = V_HostOrURL
        .V_Port         = V_Port
        .V_Username     = V_Username
        .V_Password     = V_Password
        XPos = InStr(1, V_PathFile, "/"): If XPos = 0 Then XPos = InStr(1, V_PathFile, "\")
        If XPos = 0 Then Return TSNEX_Const_PathFileError
        .V_Path         = Left(V_PathFile, XPos - 1)
        .V_File         = Mid(V_PathFile, XPos + 1)
        XPos = InStr(1, .V_File, ".")
        If XPos > 0 Then
            .V_FileType = Mid(.V_File, XPos + 1)
            .V_File = Left(.V_File, XPos - 1)
        End If
    End With
End If
Dim TTarget as String
With XURL
    If LCase(.V_Protocol) <> "ftp" Then Return TSNEX_Const_ProtocolNotSupported
    If .V_Port = 0 Then .V_Port = 21
    If (.V_Host = "") or (.V_Port = 0) or (.V_Username = "") or (.V_Password = "") Then Return TSNEX_Const_URLorHostDataMissing
    If .V_Path = "" Then Return TSNEX_Const_PathFileError
    If Right(.V_Path, 1) = "\" Then Return TSNEX_Const_PathFileError
    TTarget = V_TargetPathFile
    If (Right(TTarget, 1) = "*") Then Return TSNEX_Const_PathFileError
    If (Right(TTarget, 1) = "/") or (Right(TTarget, 1) = "\") Then
        TTarget += .V_File
        If .V_FileType <> "" Then TTarget += "." & .V_FileType
    End If
    If TTarget = "" Then
        TTarget = .V_File
        If .V_FileType <> "" Then TTarget += "." & .V_FileType
    End if
    If (Right(TTarget, 1) = "/") or (Right(TTarget, 1) = "\") or (Right(TTarget, 1) = "*") Then Return TSNEX_Const_PathFileError
    XPos = InStrRev(TTarget, "/"): If XPos = 0 Then XPos = InStrRev(TTarget, "\")
    If XPos > 0 Then If Dir(Left(TTarget, XPos) & "*", -1) = "" Then Return TSNEX_Const_TargetPathNotFound
    If Dir(TTarget, -1) <> "" Then Return TSNEX_Const_TargetAlreadyExist
    MutexLock(G_TSNEX_Mutex)
    Dim XTSNEID as UInteger
    Dim RV as Integer = TSNE_Create_Client(XTSNEID, .V_Host, .V_Port, @TSNEX_Disconnected, @TSNEX_Connected, @TSNEX_NewData)
    If RV <> TSNE_Const_NoError Then MutexUnLock(G_TSNEX_Mutex): Return RV
End With
Dim XID as UInteger
For X as UInteger = 1 to G_TSNEX_CC
    If G_TSNEX_CD(X).V_InUse = 0 Then XID = X: Exit For
Next
If XID = 0 Then G_TSNEX_CC += 1: XID = G_TSNEX_CC: Redim Preserve G_TSNEX_CD(G_TSNEX_CC) as TSNEX_Con_Type
Dim TCC as TSNEX_Con_Type
G_TSNEX_CD(XID) = TCC
With G_TSNEX_CD(XID)
    .V_InUse    = 1
    .V_TSNEID   = XTSNEID
    .V_State    = TSNEX_SE_Init
    .V_URLType  = XURL
    .V_Target   = TTarget
    .V_Type     = TSNEX_CE_FTP
    .V_CMD      = TSNEX_ME_FTP_Download
    .T_CallBack = V_ProgressCallback
End With
MutexUnLock(G_TSNEX_Mutex)
RV = TSNEX_WaitState(XID, TSNEX_SE_Ready): If RV <> TSNEX_Const_NoError Then MutexLock(G_TSNEX_Mutex): If G_TSNEX_CD(XID).V_TSNEID = XTSNEID Then G_TSNEX_CD(XID) = TCC: MutexUnLock(G_TSNEX_Mutex): Return RV
TSNE_Disconnect(XTSNEID)
Return TSNEX_Const_NoError
End Function

'--------------------------------------------------------------------------------------------------------------
Function TSNEX_FTP_Upload(V_HostOrURL as String, V_Port as UShort = 0, V_Username as String = "anonymous", V_Password as String = "anynomous@ano.nym", V_PathFile as String = "", V_SourcePathFile as String = "", V_ProgressCallback as Any Ptr = 0) as Integer
If V_SourcePathFile = "" Then Return TSNEX_Const_TargetPathNotFound
If Right(V_SourcePathFile, 1) = "*" Then Return TSNEX_Const_TargetPathNotFound
If Right(V_SourcePathFile, 1) = "/" Then Return TSNEX_Const_TargetPathNotFound
If Right(V_SourcePathFile, 1) = "\" Then Return TSNEX_Const_TargetPathNotFound
Dim XURL as URL_Type
Dim XPos as UInteger
If URL_Split(V_HostOrURL, XURL) = 1 Then
    With XURL
        .V_Protocol     = "ftp"
        .V_Host         = V_HostOrURL
        .V_Port         = V_Port
        .V_Username     = V_Username
        .V_Password     = V_Password
        XPos = InStr(1, V_PathFile, "/"): If XPos = 0 Then XPos = InStr(1, V_PathFile, "\")
        If XPos = 0 Then Return TSNEX_Const_PathFileError
        .V_Path         = Left(V_PathFile, XPos - 1)
        .V_File         = Mid(V_PathFile, XPos + 1)
        XPos = InStr(1, .V_File, ".")
        If XPos > 0 Then
            .V_FileType = Mid(.V_File, XPos + 1)
            .V_File = Left(.V_File, XPos - 1)
        End If
    End With
End If
With XURL
    If LCase(.V_Protocol) <> "ftp" Then Return TSNEX_Const_ProtocolNotSupported
    If .V_Port = 0 Then .V_Port = 21
    If (.V_Host = "") or (.V_Port = 0) or (.V_Username = "") or (.V_Password = "") Then Return TSNEX_Const_URLorHostDataMissing
    If .V_Path = "" Then Return TSNEX_Const_PathFileError
    If (.V_File = "") and (.V_FileType = "") Then
        XPos = InStrRev(V_SourcePathFile, "/"): If XPos = 0 Then XPos = InStrRev(V_SourcePathFile, "\")
        If XPos > 0 Then
            .V_File = Mid(V_SourcePathFile, XPos + 1)
        Else: .V_File = V_SourcePathFile
        End If
        XPos = InStrRev(V_SourcePathFile, ".")
        If XPos > 0 Then
            .V_FileType = Mid(.V_File, XPos + 1)
            .V_File = Left(.V_File, XPos - 1)
        End If
    End If
    MutexLock(G_TSNEX_Mutex)
    Dim XTSNEID as UInteger
    Dim RV as Integer = TSNE_Create_Client(XTSNEID, .V_Host, .V_Port, @TSNEX_Disconnected, @TSNEX_Connected, @TSNEX_NewData)
    If RV <> TSNE_Const_NoError Then MutexUnLock(G_TSNEX_Mutex): Return RV
End With
Dim XID as UInteger
For X as UInteger = 1 to G_TSNEX_CC
    If G_TSNEX_CD(X).V_InUse = 0 Then XID = X: Exit For
Next
If XID = 0 Then G_TSNEX_CC += 1: XID = G_TSNEX_CC: Redim Preserve G_TSNEX_CD(G_TSNEX_CC) as TSNEX_Con_Type
Dim TCC as TSNEX_Con_Type
G_TSNEX_CD(XID) = TCC
With G_TSNEX_CD(XID)
    .V_InUse    = 1
    .V_TSNEID   = XTSNEID
    .V_State    = TSNEX_SE_Init
    .V_URLType  = XURL
    .V_Target   = V_SourcePathFile
    .V_Type     = TSNEX_CE_FTP
    .V_CMD      = TSNEX_ME_FTP_UpLoad
    .T_CallBack = V_ProgressCallback
End With
MutexUnLock(G_TSNEX_Mutex)
RV = TSNEX_WaitState(XID, TSNEX_SE_Ready): If RV <> TSNEX_Const_NoError Then MutexLock(G_TSNEX_Mutex): If G_TSNEX_CD(XID).V_TSNEID = XTSNEID Then G_TSNEX_CD(XID) = TCC: MutexUnLock(G_TSNEX_Mutex): Return RV
TSNE_Disconnect(XTSNEID)
Return TSNEX_Const_NoError
End Function

'--------------------------------------------------------------------------------------------------------------
Function TSNEX_FTP_Delete(V_HostOrURL as String, V_Port as UShort = 0, V_Username as String = "anonymous", V_Password as String = "anynomous@ano.nym", V_PathFile as String = "") as Integer
Dim XURL as URL_Type
Dim XPos as UInteger
If URL_Split(V_HostOrURL, XURL) = 1 Then
    With XURL
        .V_Protocol     = "ftp"
        .V_Host         = V_HostOrURL
        .V_Port         = V_Port
        .V_Username     = V_Username
        .V_Password     = V_Password
        XPos = InStr(1, V_PathFile, "/"): If XPos = 0 Then XPos = InStr(1, V_PathFile, "\")
        If XPos = 0 Then Return TSNEX_Const_PathFileError
        .V_Path         = Left(V_PathFile, XPos - 1)
        .V_File         = Mid(V_PathFile, XPos + 1)
        XPos = InStr(1, .V_File, ".")
        If XPos > 0 Then
            .V_FileType = Mid(.V_File, XPos + 1)
            .V_File = Left(.V_File, XPos - 1)
        End If
    End With
End If
With XURL
    If LCase(.V_Protocol) <> "ftp" Then Return TSNEX_Const_ProtocolNotSupported
    If .V_Port = 0 Then .V_Port = 21
    If (.V_Host = "") or (.V_Port = 0) or (.V_Username = "") or (.V_Password = "") Then Return TSNEX_Const_URLorHostDataMissing
    If .V_Path = "" Then Return TSNEX_Const_PathFileError
    If Right(.V_Path, 1) = "\" Then Return TSNEX_Const_PathFileError
    If (.V_File = "") and (.V_FileType = "") Then Return TSNEX_Const_PathFileError
    MutexLock(G_TSNEX_Mutex)
    Dim XTSNEID as UInteger
    Dim RV as Integer = TSNE_Create_Client(XTSNEID, .V_Host, .V_Port, @TSNEX_Disconnected, @TSNEX_Connected, @TSNEX_NewData)
    If RV <> TSNE_Const_NoError Then MutexUnLock(G_TSNEX_Mutex): Return RV
End With
Dim XID as UInteger
For X as UInteger = 1 to G_TSNEX_CC
    If G_TSNEX_CD(X).V_InUse = 0 Then XID = X: Exit For
Next
If XID = 0 Then G_TSNEX_CC += 1: XID = G_TSNEX_CC: Redim Preserve G_TSNEX_CD(G_TSNEX_CC) as TSNEX_Con_Type
Dim TCC as TSNEX_Con_Type
G_TSNEX_CD(XID) = TCC
With G_TSNEX_CD(XID)
    .V_InUse    = 1
    .V_TSNEID   = XTSNEID
    .V_State    = TSNEX_SE_Init
    .V_URLType  = XURL
    .V_Type     = TSNEX_CE_FTP
    .V_CMD      = TSNEX_ME_FTP_Delete
End With
MutexUnLock(G_TSNEX_Mutex)
RV = TSNEX_WaitState(XID, TSNEX_SE_Ready): If RV <> TSNEX_Const_NoError Then MutexLock(G_TSNEX_Mutex): If G_TSNEX_CD(XID).V_TSNEID = XTSNEID Then G_TSNEX_CD(XID) = TCC: MutexUnLock(G_TSNEX_Mutex): Return RV
TSNE_Disconnect(XTSNEID)
Return TSNEX_Const_NoError
End Function



'##############################################################################################################
Function TSNEX_SMTP_SendMail(V_RelayServer as String, V_RelayPort as UShort = 0, V_Username as String = "", V_Password as String = "", V_FromMailAdr as String, V_ToMailAdr as String, V_Subject as String, V_Message as String) as Integer
If V_FromMailAdr = "" Then Return TSNEX_Const_MissingParameter
If V_ToMailAdr = "" Then Return TSNEX_Const_MissingParameter
If V_Subject = "" Then Return TSNEX_Const_MissingParameter
If V_Message = "" Then Return TSNEX_Const_MissingParameter
Dim XPos as UInteger
XPos = InStr(1, V_FromMailAdr, "@"): If XPos = 0 Then Return TSNEX_Const_EMailSyntaxError
XPos = InStr(1, Mid(V_FromMailAdr, XPos + 1), "."): If XPos = 0 Then Return TSNEX_Const_EMailSyntaxError
XPos = InStr(1, V_ToMailAdr, "@"): If XPos = 0 Then Return TSNEX_Const_EMailSyntaxError
XPos = InStr(1, Mid(V_ToMailAdr, XPos + 1), "."): If XPos = 0 Then Return TSNEX_Const_EMailSyntaxError
Dim XURL as URL_Type
Dim T as String
If V_RelayServer <> "" Then
    If URL_Split(V_RelayServer, XURL) = 1 Then
        With XURL
            .V_Protocol     = "smtp"
            .V_Host         = V_RelayServer
            .V_Port         = V_RelayPort
            .V_Username     = V_Username
            .V_Password     = V_Password
        End With
    End If
Else
    XPos = InStr(1, V_ToMailAdr, "@"): If XPos = 0 Then Return TSNEX_Const_EMailSyntaxError
    With XURL
        .V_Protocol     = "smtp"
        .V_Host         = Mid(V_ToMailAdr, XPos + 1)
        .V_Port         = V_RelayPort
        .V_Username     = V_Username
        .V_Password     = V_Password
    End With
End If
With XURL
    If LCase(.V_Protocol) <> "smtp" Then Return TSNEX_Const_ProtocolNotSupported
    If .V_Port = 0 Then .V_Port = 25
    If (.V_Host = "") or (.V_Port = 0) Then Return TSNEX_Const_URLorHostDataMissing
    MutexLock(G_TSNEX_Mutex)
    Dim XTSNEID as UInteger
    Dim RV as Integer = TSNE_Create_Client(XTSNEID, .V_Host, .V_Port, @TSNEX_Disconnected, @TSNEX_Connected, @TSNEX_NewData)
    If RV <> TSNE_Const_NoError Then MutexUnLock(G_TSNEX_Mutex): Return RV
End With
Dim XID as UInteger
For X as UInteger = 1 to G_TSNEX_CC
    If G_TSNEX_CD(X).V_InUse = 0 Then XID = X: Exit For
Next
If XID = 0 Then G_TSNEX_CC += 1: XID = G_TSNEX_CC: Redim Preserve G_TSNEX_CD(G_TSNEX_CC) as TSNEX_Con_Type
Dim TCC as TSNEX_Con_Type
G_TSNEX_CD(XID) = TCC
With G_TSNEX_CD(XID)
    .V_InUse    = 1
    .V_TSNEID   = XTSNEID
    .V_State    = TSNEX_SE_Init
    .V_URLType  = XURL
    .V_Type     = TSNEX_CE_SMTP
    .V_CMD      = TSNEX_ME_SMTP_Send
    .V_Data(1)  = V_FromMailAdr
    .V_Data(2)  = V_ToMailAdr
    .V_Data(3)  = V_Subject
    .V_Data(4)  = V_Message
End With
MutexUnLock(G_TSNEX_Mutex)
RV = TSNEX_WaitState(XID, TSNEX_SE_Ready): If RV <> TSNEX_Const_NoError Then MutexLock(G_TSNEX_Mutex): If G_TSNEX_CD(XID).V_TSNEID = XTSNEID Then G_TSNEX_CD(XID) = TCC: MutexUnLock(G_TSNEX_Mutex): Return RV
Return TSNEX_Const_NoError
End Function



'##############################################################################################################
Function TSNEX_HTTP_Get(V_HostOrURL as String, V_Port as UShort = 0, V_Username as String = "", V_Password as String = "", V_PathFile as String = "", V_TargetPathFile as String = "", ByRef R_HTTPCode as UShort = 0, V_RefererURL as String = "", V_ProxyHost as String = "", V_ProxyPort as UShort = 0, V_ProgressCallback as Any Ptr = 0) as Integer
Dim XURL as URL_Type
Dim XPos as UInteger
If URL_Split(V_HostOrURL, XURL) = 1 Then
    With XURL
        .V_Protocol     = "http"
        .V_Host         = V_HostOrURL
        .V_Port         = V_Port
        .V_Username     = V_Username
        .V_Password     = V_Password
        XPos = InStr(1, V_PathFile, "/"): If XPos = 0 Then XPos = InStr(1, V_PathFile, "\")
        If XPos = 0 Then Return TSNEX_Const_PathFileError
        .V_Path         = Left(V_PathFile, XPos - 1)
        .V_File         = Mid(V_PathFile, XPos + 1)
        XPos = InStr(1, .V_File, ".")
        If XPos > 0 Then
            .V_FileType = Mid(.V_File, XPos + 1)
            .V_File = Left(.V_File, XPos - 1)
        End If
    End With
End If
Dim TTarget as String
With XURL
    If LCase(.V_Protocol) <> "http" Then Return TSNEX_Const_ProtocolNotSupported
    If .V_Port = 0 Then .V_Port = 80
    If (.V_Host = "") or (.V_Port = 0) Then Return TSNEX_Const_URLorHostDataMissing
    If .V_Path = "" Then Return TSNEX_Const_PathFileError
    If Right(.V_Path, 1) = "\" Then Return TSNEX_Const_PathFileError
    TTarget = V_TargetPathFile
    If (Right(TTarget, 1) = "*") Then Return TSNEX_Const_PathFileError
    If (Right(TTarget, 1) = "/") or (Right(TTarget, 1) = "\") Then
        TTarget += .V_File
        If .V_FileType <> "" Then TTarget += "." & .V_FileType
    End If
    If TTarget = "" Then
        TTarget = .V_File
        If .V_FileType <> "" Then TTarget += "." & .V_FileType
        If TTarget = "" Then TTarget = "index.html"
    End if
    If (Right(TTarget, 1) = "/") or (Right(TTarget, 1) = "\") Then TTarget = "index.html"
    If (Right(TTarget, 1) = "/") or (Right(TTarget, 1) = "\") or (Right(TTarget, 1) = "*") Then Return TSNEX_Const_PathFileError
    XPos = InStrRev(TTarget, "/"): If XPos = 0 Then XPos = InStrRev(TTarget, "\")
    If XPos > 0 Then If Dir(Left(TTarget, XPos) & "*", -1) = "" Then Return TSNEX_Const_TargetPathNotFound
    If Dir(TTarget, -1) <> "" Then Return TSNEX_Const_TargetAlreadyExist
    MutexLock(G_TSNEX_Mutex)
    Dim XTSNEID as UInteger
    Dim RV as Integer = TSNE_Create_Client(XTSNEID, .V_Host, .V_Port, @TSNEX_Disconnected, @TSNEX_Connected, @TSNEX_NewData)
    If RV <> TSNE_Const_NoError Then MutexUnLock(G_TSNEX_Mutex): Return RV
End With
Dim XID as UInteger
For X as UInteger = 1 to G_TSNEX_CC
    If G_TSNEX_CD(X).V_InUse = 0 Then XID = X: Exit For
Next
If XID = 0 Then G_TSNEX_CC += 1: XID = G_TSNEX_CC: Redim Preserve G_TSNEX_CD(G_TSNEX_CC) as TSNEX_Con_Type
Dim TCC as TSNEX_Con_Type
G_TSNEX_CD(XID) = TCC
Dim T as String
With G_TSNEX_CD(XID)
    .V_InUse    = 1
    .V_TSNEID   = XTSNEID
    .V_State    = TSNEX_SE_Init
    .V_URLType  = XURL
    .V_Target   = TTarget
    .V_Type     = TSNEX_CE_HTTP
    .V_CMD      = TSNEX_ME_HTTP_GET
    .T_CallBack = V_ProgressCallback
    With XURL
        T = "GET " & .V_Path & .V_File
        If .V_FileType <> "" Then T += "." & .V_FileType
        If .V_SubData <> "" Then T += "?" & .V_SubData
        T += " HTTP/1.0" & Chr(13, 10)
        T += "Host: " & .V_Host
        If .V_Port <> 80 Then T += ":" & Str(.V_Port)
        T += Chr(13, 10)
        T += "Referer: " & V_RefererURL & Chr(13, 10)
        T += "User-Agent: TSNEX HTTP_GET-Function" & Chr(13, 10)
        T += "Connection: close" & Chr(13, 10)
        T += Chr(13, 10)
    End With
    .V_Data(1)  = T
End With
MutexUnLock(G_TSNEX_Mutex)
RV = TSNEX_WaitState(XID, TSNEX_SE_Ready): If RV <> TSNEX_Const_NoError Then MutexLock(G_TSNEX_Mutex): If G_TSNEX_CD(XID).V_TSNEID = XTSNEID Then G_TSNEX_CD(XID) = TCC: MutexUnLock(G_TSNEX_Mutex): Return RV
MutexLock(G_TSNEX_Mutex)
R_HTTPCode = CShort(ValUInt(G_TSNEX_CD(XID).V_Data(4)))
MutexUnLock(G_TSNEX_Mutex)
TSNE_Disconnect(XTSNEID)
Return TSNEX_Const_NoError
End Function



'##############################################################################################################
Function TSNEX_HTTPS_Get(V_HostOrURL as String, V_Port as UShort = 0, V_Username as String = "", V_Password as String = "", V_PathFile as String = "", V_TargetPathFile as String = "", ByRef R_HTTPCode as UShort = 0, V_RefererURL as String = "", V_ProxyHost as String = "", V_ProxyPort as UShort = 0, V_ProgressCallback as Any Ptr = 0) as Integer
Dim XURL as URL_Type
Dim XPos as UInteger
If URL_Split(V_HostOrURL, XURL) = 1 Then
    With XURL
        .V_Protocol     = "https"
        .V_Host         = V_HostOrURL
        .V_Port         = V_Port
        .V_Username     = V_Username
        .V_Password     = V_Password
        XPos = InStr(1, V_PathFile, "/"): If XPos = 0 Then XPos = InStr(1, V_PathFile, "\")
        If XPos = 0 Then Return TSNEX_Const_PathFileError
        .V_Path         = Left(V_PathFile, XPos - 1)
        .V_File         = Mid(V_PathFile, XPos + 1)
        XPos = InStr(1, .V_File, ".")
        If XPos > 0 Then
            .V_FileType = Mid(.V_File, XPos + 1)
            .V_File = Left(.V_File, XPos - 1)
        End If
    End With
End If
Dim TTarget as String
With XURL
    If LCase(.V_Protocol) <> "https" Then Return TSNEX_Const_ProtocolNotSupported
    If .V_Port = 0 Then .V_Port = 443
    If (.V_Host = "") or (.V_Port = 0) Then Return TSNEX_Const_URLorHostDataMissing
    If .V_Path = "" Then Return TSNEX_Const_PathFileError
    If Right(.V_Path, 1) = "\" Then Return TSNEX_Const_PathFileError
    TTarget = V_TargetPathFile
    If (Right(TTarget, 1) = "*") Then Return TSNEX_Const_PathFileError
    If (Right(TTarget, 1) = "/") or (Right(TTarget, 1) = "\") Then
        TTarget += .V_File
        If .V_FileType <> "" Then TTarget += "." & .V_FileType
    End If
    If TTarget = "" Then
        TTarget = .V_File
        If .V_FileType <> "" Then TTarget += "." & .V_FileType
        If TTarget = "" Then TTarget = "index.html"
    End if
    If (Right(TTarget, 1) = "/") or (Right(TTarget, 1) = "\") Then TTarget = "index.html"
    If (Right(TTarget, 1) = "/") or (Right(TTarget, 1) = "\") or (Right(TTarget, 1) = "*") Then Return TSNEX_Const_PathFileError
    XPos = InStrRev(TTarget, "/"): If XPos = 0 Then XPos = InStrRev(TTarget, "\")
    If XPos > 0 Then If Dir(Left(TTarget, XPos) & "*", -1) = "" Then Return TSNEX_Const_TargetPathNotFound
    If Dir(TTarget, -1) <> "" Then Return TSNEX_Const_TargetAlreadyExist
    MutexLock(G_TSNEX_Mutex)
    Dim XTSNEID as UInteger
    Dim RV as Integer = TSNE_Create_Client(XTSNEID, .V_Host, .V_Port, @TSNEX_Disconnected, @TSNEX_Connected, @TSNEX_NewData)
    If RV <> TSNE_Const_NoError Then MutexUnLock(G_TSNEX_Mutex): Return RV
End With
Dim XID as UInteger
For X as UInteger = 1 to G_TSNEX_CC
    If G_TSNEX_CD(X).V_InUse = 0 Then XID = X: Exit For
Next
If XID = 0 Then G_TSNEX_CC += 1: XID = G_TSNEX_CC: Redim Preserve G_TSNEX_CD(G_TSNEX_CC) as TSNEX_Con_Type
Dim TCC as TSNEX_Con_Type
G_TSNEX_CD(XID) = TCC
Dim T as String
With G_TSNEX_CD(XID)
    .V_InUse    = 1
    .V_TSNEID   = XTSNEID
    .V_State    = TSNEX_SE_Init
    .V_URLType  = XURL
    .V_Target   = TTarget
    .V_Type     = TSNEX_CE_HTTP
    .V_CMD      = TSNEX_ME_HTTP_GET
    .T_CallBack = V_ProgressCallback
    With XURL
        T = "GET " & .V_Path & .V_File
        If .V_FileType <> "" Then T += "." & .V_FileType
        T += " HTTP/1.0" & Chr(13, 10)
        T += "Host: " & .V_Host
        If .V_Port <> 80 Then T += ":" & Str(.V_Port)
        T += Chr(13, 10)
        T += "Referer: " & V_RefererURL & Chr(13, 10)
        T += "User-Agent: TSNEX HTTP_GET-Function" & Chr(13, 10)
        T += "Connection: close" & Chr(13, 10)
        T += Chr(13, 10)
    End With
    .V_Data(1)  = T
End With
MutexUnLock(G_TSNEX_Mutex)
RV = TSNEX_WaitState(XID, TSNEX_SE_Ready): If RV <> TSNEX_Const_NoError Then MutexLock(G_TSNEX_Mutex): If G_TSNEX_CD(XID).V_TSNEID = XTSNEID Then G_TSNEX_CD(XID) = TCC: MutexUnLock(G_TSNEX_Mutex): Return RV
MutexLock(G_TSNEX_Mutex)
R_HTTPCode = CShort(ValUInt(G_TSNEX_CD(XID).V_Data(4)))
MutexUnLock(G_TSNEX_Mutex)
TSNE_Disconnect(XTSNEID)
Return TSNEX_Const_NoError
End Function



'##############################################################################################################
Function TSNEX_GetWANIPA(R_WANIPA as String) as Integer
MutexLock(G_TSNEX_Mutex)
Dim XTSNEID as UInteger
Dim RV as Integer = TSNE_Create_Client(XTSNEID, "checkip.dyndns.org", 80, @TSNEX_Disconnected, @TSNEX_Connected, @TSNEX_NewData)
If RV <> TSNE_Const_NoError Then MutexUnLock(G_TSNEX_Mutex): Return RV
Dim XID as UInteger
For X as UInteger = 1 to G_TSNEX_CC
    If G_TSNEX_CD(X).V_InUse = 0 Then XID = X: Exit For
Next
If XID = 0 Then G_TSNEX_CC += 1: XID = G_TSNEX_CC: Redim Preserve G_TSNEX_CD(G_TSNEX_CC) as TSNEX_Con_Type
Dim TCC as TSNEX_Con_Type
G_TSNEX_CD(XID) = TCC
Dim T as String
With G_TSNEX_CD(XID)
    .V_InUse    = 1
    .V_TSNEID   = XTSNEID
    .V_State    = TSNEX_SE_Init
    .V_Target   = ""
    .V_Type     = TSNEX_CE_HTTP
    .V_CMD      = TSNEX_ME_HTTP_GET
    T = "GET / HTTP/1.0" & Chr(13, 10)
    T += "Host: checkip.dyndns.org" & Chr(13, 10)
    T += "User-Agent: TSNEX GetWANIPA-Function" & Chr(13, 10)
    T += "Connection: close" & Chr(13, 10)
    T += Chr(13, 10)
    .V_Data(1)  = T
End With
MutexUnLock(G_TSNEX_Mutex)
RV = TSNEX_WaitState(XID, TSNEX_SE_Ready)
If RV <> TSNEX_Const_NoError Then
    MutexLock(G_TSNEX_Mutex)
    If G_TSNEX_CD(XID).V_TSNEID = XTSNEID Then
        Print G_TSNEX_CD(XID).V_State
        G_TSNEX_CD(XID) = TCC
        MutexUnLock(G_TSNEX_Mutex)
        Return RV
    End If
End If
MutexLock(G_TSNEX_Mutex)
T = ""
If CShort(ValUInt(G_TSNEX_CD(XID).V_Data(4))) = 200 Then T = G_TSNEX_CD(XID).V_Data(8)
MutexUnLock(G_TSNEX_Mutex)
If T = "" Then Return TSNEX_Const_CantResolveWANIPA
Dim XPos as UInteger = InStr(1, T, "IP Address:")
If XPos <= 0 Then Return TSNEX_Const_CantResolveWANIPA
T = Trim(Mid(T, XPos + 11))
If T = "" Then Return TSNEX_Const_CantResolveWANIPA
XPos = InStr(1, T, "<"): If XPos <= 0 Then Return TSNEX_Const_CantResolveWANIPA
R_WANIPA = Trim(Left(T, XPos - 1))
Return TSNEX_Const_NoError
End Function




'##############################################################################################################
'...<
#EndIf