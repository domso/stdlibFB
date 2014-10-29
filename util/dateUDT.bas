#Include Once "utilUDT.bas" 
#INCLUDE Once "vbcompat.bi"

Type dateUDT extends utilUDT
	As Integer Day_, Month_,Year_
	Declare virtual Function equals(o As utilUDT Ptr) As Integer
	Declare Constructor(day_ As Integer=0,month_ As Integer=0, Year_ As Integer=0)
	Declare Sub today
	Declare Function serial As double
	Declare Function diff(item As dateUDT Ptr=0) As Integer
	Declare virtual Function toString As String
End Type


Function dateUDT.equals(o As utilUDT Ptr) As Integer
	Dim As dateUDT Ptr tmp = Cast(dateUDT Ptr,o)
	If tmp->Day_=This.day_ And tmp->Month_=This.month_ And tmp->Year_=this.year_ Then
		Return 1
	EndIf
	Return 0
End Function

Sub dateUDT.today
	this.day_ = Day(Now)
	this.Month_ = month(Now)
	this.Year_ = year(Now)
End Sub

Constructor dateUDT(day_ As Integer=0,month_ As Integer=0, Year_ As Integer=0)
	If day_=0 Then day_=Day(Now)
	If month_=0 Then month_=Month(Now)
	If Year_=0 Then Year_=Year(Now)
	
	this.day_ = day_
	this.Month_ = month_
	this.Year_ = Year_
End Constructor

Function dateUDT.serial As Double
	Return DateSerial(year_,month_,day_) 
End Function

Function dateUDT.diff(item As dateUDT Ptr=0) As Integer
	If item=0 Then 
		Return DateDiff("d",this.serial,Now)
	Else
		Return DateDiff("d",this.serial,item->serial)	
	EndIf
	
End Function
Function dateUDT.toString As String
	Return Str(Day_)+"-"+MonthName(month_,1)+"-"+Str(year_)
End Function
