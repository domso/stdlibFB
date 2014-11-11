#Include Once "linklist.bas"

Dim Shared As list_type GLOBAL_TIMER_UPDATE_LIST

Type timerUDT extends utilUDT
	As Byte useINT=0,finish=0,noDiff
	As Integer Ptr int_data
	As Integer int_diff,int_target
	As Double Ptr double_data
	As Double double_diff,speed,double_target,time_len
	As Double startTime,lastTime
	
	Declare Constructor(int_data As Integer ptr,int_diff As Integer,speed As Double,NoDiff As Byte=0)
	Declare Constructor(double_data As double ptr,double_diff As Double,speed As Double,NoDiff As Byte=0)
	Declare virtual Function todo As Byte
	Declare virtual Function equals(o As utilUDT Ptr) As Integer
End Type

Constructor timerUDT(int_data As Integer ptr,int_diff As Integer,speed As Double,NoDiff As Byte=0)
	startTime=Timer
	lastTime=startTime
	this.int_data=int_data
	this.int_diff=int_diff
	this.speed=speed
	this.int_target=*int_data+int_diff
	this.noDiff=NoDiff
	time_len = int_diff/speed
	useINT=1
	GLOBAL_TIMER_UPDATE_LIST.add(@This,1)
End Constructor

Constructor timerUDT(double_data As Double ptr,double_diff As Double,speed As Double,NoDiff As Byte=0)
	startTime=Timer
	lastTime=startTime
	this.double_data=double_data
	this.double_diff=double_diff
	this.speed=speed
	this.double_target=*double_data+double_diff
	this.noDiff=NoDiff
	time_len = double_diff/speed
	GLOBAL_TIMER_UPDATE_LIST.add(@This,1)
End Constructor

Function timerUDT.equals(o As utilUDT Ptr) As Integer
	If o=0 Then Return 0
	If @This = Cast(timerUDT Ptr,o) Then Return 1
	Return 0
End Function

Function timerUDT.todo As Byte
	If this.noDiff=0 then
		If useINT=0 Then
			Dim As Double tmp=speed*(Timer-lastTime)
			lastTime=Timer
			If tmp<=double_diff Then
				*double_data+=tmp
				double_diff-=tmp
			Else
				*double_data=double_target
				double_diff=0
			EndIf
			
			If double_diff=0 Then
				finish=1
			EndIf	
		Else
			Dim As Double tmp=speed*(Timer-lastTime)
			lastTime=Timer
			If tmp<=int_diff Then
				*int_data+=tmp
				int_diff-=tmp
			Else
				*int_data=int_target
				int_diff=0
			EndIf
			If int_diff=0 Then
				finish=1
			EndIf		
		EndIf
	Else
		If useINT=0 Then
			If Timer-startTime>=time_len Then
				*double_data=double_target
			EndIf
		Else
			If Timer-startTime>=time_len Then
				*INT_data=INT_target
			EndIf		
		EndIf	
	End if
	Return 1
End Function


Sub GLOBAL_TIMER_UPDATE_THREAD(param As Any Ptr)
	do
		GLOBAL_TIMER_UPDATE_LIST.execute
		GLOBAL_TIMER_UPDATE_LIST.reset
		Dim As timerUDT Ptr tmp
		do
			tmp = Cast(timerUDT Ptr,GLOBAL_TIMER_UPDATE_LIST.getItem())
			If tmp<>0 Then
				If tmp->finish=1 Then
					GLOBAL_TIMER_UPDATE_LIST.remove(tmp)
				EndIf
			EndIf
		Loop Until tmp=0
		Sleep 1,1
	loop
End Sub

Dim Shared As Any Ptr GLOBAL_TIMER_THREAD
GLOBAL_TIMER_THREAD = ThreadCreate(@GLOBAL_TIMER_UPDATE_THREAD)
