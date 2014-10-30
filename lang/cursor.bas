#Include Once "../util/util.bas"
Type GLOBAL_CURSOR_UDT extends utilUDT
	As Integer x,y
	As Integer margin_x,margin_y
	As Integer Width,height
	As Integer min_x,min_y
	As Integer max_x,max_y
	As UByte state=1 '1-rechts,2-unten
	As UByte isTmpSet
	As UByte newLine
	As Byte tmp_state '1-rechts,2-unten
	As Integer tmp_x,tmp_y	
	
	Declare Function setModul(Width As Integer,height As Integer) As UByte
End Type

Function GLOBAL_CURSOR_UDT.setModul(Width_ As Integer,height As Integer) As UByte
	
	If tmp_state = -1 Then
		x = tmp_x
		y = tmp_y
		tmp_x = 0
		tmp_y = 0
		tmp_state = 0
		isTmpSet = 0
	EndIf

	If tmp_state = 0 Then

		Select Case state
			Case 1
				'And newLine=0 
				
				If max_x+Width_>this.width Or newline Then 
					x = min_x + margin_x
					y = max_y + margin_y 				
					max_x = x + Width_
					max_y = y + height
					
				Else
					x = max_x + margin_x
					If y = 0 Then y = margin_y		
					max_x = x + Width_
					If max_y < (y + height) Then
						max_y = y + height
					End if
					
				EndIf
				newLine = 0
				
				
				
				
				If x+Width_>this.width Or y+height>this.height Then Return 0
				Return 1
				
			Case 2
				If max_y+height>this.height Or newline Then 
					y = min_y + margin_y
					x = max_x + margin_x 				
					max_x = x + Width_
					max_y = y + height
					
				Else

					y = max_y + margin_y
					If x = 0 Then x = margin_x		
					max_y = y + height
					If max_x < (x + width_) Then
						max_x = x + width_
					End if
					
				EndIf
				newLine = 0
				If x+Width_>this.width Or y+height>this.height Then Return 0
				Return 1
				
		End Select
	Else
		If tmp_state <> -1 And isTmpSet = 0 Then 'TBD
			tmp_x = x
			tmp_y = y
			isTmpSet = 1
			
		End if
		Select Case tmp_state
			Case 1
				'And newLine=0 
				

					If  newline Then 
						Select Case state
							Case 1
								x = min_x + margin_x
								y = max_y + margin_y 				
								max_x = x + Width_
								max_y = y + height
							Case 2
								y = min_y + margin_y
								x = max_x + margin_x 				
								max_x = x + Width_
								max_y = y + height
						End Select
						
						

					
				Else
					x = max_x + margin_x
					If y = 0 Then y = margin_y		
					max_x = x + Width_
					If max_y < (y + height) Then
						max_y = y + height
					End if
					
				EndIf
				newLine = 0
				
				
				
				tmp_state = -1
				If x+Width_>this.width Or y+height>this.height Then Return 0
				Return 1
				
			Case 2
				If newline Then 
						Select Case state
							Case 1
								x = min_x + margin_x
								y = max_y + margin_y 				
								max_x = x + Width_
								max_y = y + height
							Case 2
								y = min_y + margin_y
								x = max_x + margin_x 				
								max_x = x + Width_
								max_y = y + height
						End Select
					
				Else

					y = max_y + margin_y
					If x = 0 Then x = margin_x		
					max_y = y + height
					If max_x < (x + width_) Then
						max_x = x + width_
					End if
					
				EndIf
				newLine = 0
				tmp_state = -1
				If x+Width_>this.width Or y+height>this.height Then Return 0
				Return 1
				
		End Select
	End if
	
End Function

Dim Shared As GLOBAL_CURSOR_UDT GLOBAL_CURSOR





Type GLOBAL_CURSOR_setX_UDT extends commandUDT
	Declare Constructor
	Declare virtual Function action(list As list_type Ptr,parent As Any Ptr=0) As UByte
End Type

Constructor GLOBAL_CURSOR_setX_UDT
	base("setX")
End Constructor

Function GLOBAL_CURSOR_setX_UDT.action(list As list_type Ptr,parent As Any Ptr=0) As UByte
	Dim As utilUDT Ptr tmp
	Dim As SubString Ptr tmp2
	
	If list = 0 Then Return 0
	list->Reset
	tmp2 = Cast(SubString ptr,list->getItem)
	If tmp2->text<>this.CommandString Then Return 0
	tmp2 = Cast(SubString ptr,list->getItem)	
	If tmp2=0 Then Return 0
	If tmp2->IsNumber=0 Then Return 0
	GLOBAL_CURSOR.x = Val(tmp2->text)
	logInterpret "GLOBAL_CURSOR x to:" + Str(GLOBAL_CURSOR.x) 
	
	Return 1
End Function

Type GLOBAL_CURSOR_setY_UDT extends commandUDT
	Declare Constructor
	Declare virtual Function action(list As list_type Ptr,parent As Any Ptr=0) As UByte
End Type

Constructor GLOBAL_CURSOR_setY_UDT
	base("setY")
End Constructor

Function GLOBAL_CURSOR_setY_UDT.action(list As list_type Ptr,parent As Any Ptr=0) As UByte
	Dim As utilUDT Ptr tmp
	Dim As SubString Ptr tmp2
	
	If list = 0 Then Return 0
	list->Reset
	tmp2 = Cast(SubString ptr,list->getItem)
	If tmp2->text<>this.CommandString Then Return 0
	tmp2 = Cast(SubString ptr,list->getItem)	
	If tmp2=0 Then Return 0
	If tmp2->IsNumber=0 Then Return 0
	GLOBAL_CURSOR.y = Val(tmp2->text)
	logInterpret "GLOBAL_CURSOR y to:" + Str(GLOBAL_CURSOR.y) 
	
	Return 1
End Function

Type GLOBAL_CURSOR_setXY_UDT extends commandUDT
	Declare Constructor
	Declare virtual Function action(list As list_type Ptr,parent As Any Ptr=0) As UByte
End Type

Constructor GLOBAL_CURSOR_setXY_UDT
	base("setXY")
End Constructor

Function GLOBAL_CURSOR_setXY_UDT.action(list As list_type Ptr,parent As Any Ptr=0) As UByte
	Dim As utilUDT Ptr tmp
	Dim As SubString Ptr tmp2
	
	If list = 0 Then Return 0
	list->Reset
	tmp2 = Cast(SubString ptr,list->getItem)
	If tmp2->text<>this.CommandString Then Return 0
	tmp2 = Cast(SubString ptr,list->getItem)	
	If tmp2=0 Then Return 0
	If tmp2->IsNumber=0 Then Return 0
	GLOBAL_CURSOR.x = Val(tmp2->text)
	logInterpret "GLOBAL_CURSOR x to:" + Str(GLOBAL_CURSOR.x) 
	tmp2 = Cast(SubString ptr,list->getItem)	
	If tmp2=0 Then Return 0
	If tmp2->IsNumber=0 Then Return 0
	GLOBAL_CURSOR.y = Val(tmp2->text)
	logInterpret "GLOBAL_CURSOR y to:" + Str(GLOBAL_CURSOR.y) 
	
	Return 1
End Function

Type GLOBAL_CURSOR_setMinX_UDT extends commandUDT
	Declare Constructor
	Declare virtual Function action(list As list_type Ptr,parent As Any Ptr=0) As UByte
End Type

Constructor GLOBAL_CURSOR_setMinX_UDT
	base("setMinX")
End Constructor

Function GLOBAL_CURSOR_setMinX_UDT.action(list As list_type Ptr,parent As Any Ptr=0) As UByte
	Dim As utilUDT Ptr tmp
	Dim As SubString Ptr tmp2
	
	If list = 0 Then Return 0
	list->Reset
	tmp2 = Cast(SubString ptr,list->getItem)
	If tmp2->text<>this.CommandString Then Return 0
	tmp2 = Cast(SubString ptr,list->getItem)	
	If tmp2=0 Then Return 0
	If tmp2->IsNumber=0 Then Return 0
	GLOBAL_CURSOR.min_x = Val(tmp2->text)
	logInterpret "GLOBAL_CURSOR min_x to:" + Str(GLOBAL_CURSOR.min_x) 
	
	Return 1
End Function

Type GLOBAL_CURSOR_setMinY_UDT extends commandUDT
	Declare Constructor
	Declare virtual Function action(list As list_type Ptr,parent As Any Ptr=0) As UByte
End Type

Constructor GLOBAL_CURSOR_setMinY_UDT
	base("setMinY")
End Constructor

Function GLOBAL_CURSOR_setMinY_UDT.action(list As list_type Ptr,parent As Any Ptr=0) As UByte
	Dim As utilUDT Ptr tmp
	Dim As SubString Ptr tmp2
	
	If list = 0 Then Return 0
	list->Reset
	tmp2 = Cast(SubString ptr,list->getItem)
	If tmp2->text<>this.CommandString Then Return 0
	tmp2 = Cast(SubString ptr,list->getItem)	
	If tmp2=0 Then Return 0
	If tmp2->IsNumber=0 Then Return 0
	GLOBAL_CURSOR.min_y = Val(tmp2->text)
	logInterpret "GLOBAL_CURSOR min_y to:" + Str(GLOBAL_CURSOR.min_y) 
	
	Return 1
End Function

Type GLOBAL_CURSOR_setMinXY_UDT extends commandUDT
	Declare Constructor
	Declare virtual Function action(list As list_type Ptr,parent As Any Ptr=0) As UByte
End Type

Constructor GLOBAL_CURSOR_setMinXY_UDT
	base("setMinXY")
End Constructor

Function GLOBAL_CURSOR_setMinXY_UDT.action(list As list_type Ptr,parent As Any Ptr=0) As UByte
	Dim As utilUDT Ptr tmp
	Dim As SubString Ptr tmp2
	
	If list = 0 Then Return 0
	list->Reset
	tmp2 = Cast(SubString ptr,list->getItem)
	If tmp2->text<>this.CommandString Then Return 0
	tmp2 = Cast(SubString ptr,list->getItem)	
	If tmp2=0 Then Return 0
	If tmp2->IsNumber=0 Then Return 0
	GLOBAL_CURSOR.min_x = Val(tmp2->text)
	logInterpret "GLOBAL_CURSOR min_x to:" + Str(GLOBAL_CURSOR.min_x) 
	tmp2 = Cast(SubString ptr,list->getItem)	
	If tmp2=0 Then Return 0
	If tmp2->IsNumber=0 Then Return 0
	GLOBAL_CURSOR.min_y = Val(tmp2->text)
	logInterpret "GLOBAL_CURSOR min_y to:" + Str(GLOBAL_CURSOR.min_y) 
	
	Return 1
End Function


Type GLOBAL_CURSOR_setMarginX_UDT extends commandUDT
	Declare Constructor
	Declare virtual Function action(list As list_type Ptr,parent As Any Ptr=0) As UByte
End Type

Constructor GLOBAL_CURSOR_setMarginX_UDT
	base("setMarginX")
End Constructor

Function GLOBAL_CURSOR_setMarginX_UDT.action(list As list_type Ptr,parent As Any Ptr=0) As UByte
	Dim As utilUDT Ptr tmp
	Dim As SubString Ptr tmp2
	
	If list = 0 Then Return 0
	list->Reset
	tmp2 = Cast(SubString ptr,list->getItem)
	If tmp2->text<>this.CommandString Then Return 0
	tmp2 = Cast(SubString ptr,list->getItem)	
	If tmp2=0 Then Return 0
	If tmp2->IsNumber=0 Then Return 0
	GLOBAL_CURSOR.margin_x = Val(tmp2->text)
	logInterpret "GLOBAL_CURSOR margin_x to:" + Str(GLOBAL_CURSOR.margin_x) 
	
	Return 1
End Function

Type GLOBAL_CURSOR_setMarginY_UDT extends commandUDT
	Declare Constructor
	Declare virtual Function action(list As list_type Ptr,parent As Any Ptr=0) As UByte
End Type

Constructor GLOBAL_CURSOR_setMarginY_UDT
	base("setMarginY")
End Constructor

Function GLOBAL_CURSOR_setMarginY_UDT.action(list As list_type Ptr,parent As Any Ptr=0) As UByte
	Dim As utilUDT Ptr tmp
	Dim As SubString Ptr tmp2
	
	If list = 0 Then Return 0
	list->Reset
	tmp2 = Cast(SubString ptr,list->getItem)
	If tmp2->text<>this.CommandString Then Return 0
	tmp2 = Cast(SubString ptr,list->getItem)	
	If tmp2=0 Then Return 0
	If tmp2->IsNumber=0 Then Return 0
	GLOBAL_CURSOR.margin_y = Val(tmp2->text)
	logInterpret "GLOBAL_CURSOR margin_y to:" + Str(GLOBAL_CURSOR.margin_y) 
	
	Return 1
End Function

Type GLOBAL_CURSOR_setMarginXY_UDT extends commandUDT
	Declare Constructor
	Declare virtual Function action(list As list_type Ptr,parent As Any Ptr=0) As UByte
End Type

Constructor GLOBAL_CURSOR_setMarginXY_UDT
	base("setMarginXY")
End Constructor

Function GLOBAL_CURSOR_setMarginXY_UDT.action(list As list_type Ptr,parent As Any Ptr=0) As UByte
	Dim As utilUDT Ptr tmp
	Dim As SubString Ptr tmp2
	
	If list = 0 Then Return 0
	list->Reset
	tmp2 = Cast(SubString ptr,list->getItem)
	If tmp2->text<>this.CommandString Then Return 0
	tmp2 = Cast(SubString ptr,list->getItem)	
	If tmp2=0 Then Return 0
	If tmp2->IsNumber=0 Then Return 0
	GLOBAL_CURSOR.margin_x = Val(tmp2->text)
	logInterpret "GLOBAL_CURSOR margin_x to:" + Str(GLOBAL_CURSOR.margin_x) 
	tmp2 = Cast(SubString ptr,list->getItem)	
	If tmp2=0 Then Return 0
	If tmp2->IsNumber=0 Then Return 0
	GLOBAL_CURSOR.margin_y = Val(tmp2->text)
	logInterpret "GLOBAL_CURSOR margin_y to:" + Str(GLOBAL_CURSOR.margin_y) 
	
	Return 1
End Function


Type GLOBAL_CURSOR_setwidth_UDT extends commandUDT
	Declare Constructor
	Declare virtual Function action(list As list_type Ptr,parent As Any Ptr=0) As UByte
End Type

Constructor GLOBAL_CURSOR_setwidth_UDT
	base("setwidth")
End Constructor

Function GLOBAL_CURSOR_setwidth_UDT.action(list As list_type Ptr,parent As Any Ptr=0) As UByte
	Dim As utilUDT Ptr tmp
	Dim As SubString Ptr tmp2
	
	If list = 0 Then Return 0
	list->Reset
	tmp2 = Cast(SubString ptr,list->getItem)
	If tmp2->text<>this.CommandString Then Return 0
	tmp2 = Cast(SubString ptr,list->getItem)	
	If tmp2=0 Then Return 0
	If tmp2->IsNumber=0 Then Return 0
	GLOBAL_CURSOR.width = Val(tmp2->text)
	logInterpret "GLOBAL_CURSOR width to:" + Str(GLOBAL_CURSOR.width) 
	
	Return 1
End Function

Type GLOBAL_CURSOR_setheight_UDT extends commandUDT
	Declare Constructor
	Declare virtual Function action(list As list_type Ptr,parent As Any Ptr=0) As UByte
End Type

Constructor GLOBAL_CURSOR_setheight_UDT
	base("setheight")
End Constructor

Function GLOBAL_CURSOR_setheight_UDT.action(list As list_type Ptr,parent As Any Ptr=0) As UByte
	Dim As utilUDT Ptr tmp
	Dim As SubString Ptr tmp2
	
	If list = 0 Then Return 0
	list->Reset
	tmp2 = Cast(SubString ptr,list->getItem)
	If tmp2->text<>this.CommandString Then Return 0
	tmp2 = Cast(SubString ptr,list->getItem)	
	If tmp2=0 Then Return 0
	If tmp2->IsNumber=0 Then Return 0
	GLOBAL_CURSOR.height = Val(tmp2->text)
	logInterpret "GLOBAL_CURSOR height to:" + Str(GLOBAL_CURSOR.height) 
	
	Return 1
End Function

Type GLOBAL_CURSOR_setWH_UDT extends commandUDT
	Declare Constructor
	Declare virtual Function action(list As list_type Ptr,parent As Any Ptr=0) As UByte
End Type

Constructor GLOBAL_CURSOR_setWH_UDT
	base("setWH")
End Constructor

Function GLOBAL_CURSOR_setWH_UDT.action(list As list_type Ptr,parent As Any Ptr=0) As UByte
	Dim As utilUDT Ptr tmp
	Dim As SubString Ptr tmp2
	
	If list = 0 Then Return 0
	list->Reset
	tmp2 = Cast(SubString ptr,list->getItem)
	If tmp2->text<>this.CommandString Then Return 0
	tmp2 = Cast(SubString ptr,list->getItem)	
	If tmp2=0 Then Return 0
	If tmp2->IsNumber=0 Then Return 0
	GLOBAL_CURSOR.width = Val(tmp2->text)
	logInterpret "GLOBAL_CURSOR width to:" + Str(GLOBAL_CURSOR.width) 
	tmp2 = Cast(SubString ptr,list->getItem)	
	If tmp2=0 Then Return 0
	If tmp2->IsNumber=0 Then Return 0
	GLOBAL_CURSOR.height = Val(tmp2->text)
	logInterpret "GLOBAL_CURSOR height to:" + Str(GLOBAL_CURSOR.height) 
	
	Return 1
End Function

Type GLOBAL_CURSOR_setAll_UDT extends commandUDT
	Declare Constructor
	Declare virtual Function action(list As list_type Ptr,parent As Any Ptr=0) As UByte
End Type

Constructor GLOBAL_CURSOR_setAll_UDT
	base("setAll")
End Constructor

Function GLOBAL_CURSOR_setAll_UDT.action(list As list_type Ptr,parent As Any Ptr=0) As UByte
	Dim As utilUDT Ptr tmp
	Dim As SubString Ptr tmp2
	
	If list = 0 Then Return 0
	list->Reset
	tmp2 = Cast(SubString ptr,list->getItem)
	If tmp2->text<>this.CommandString Then Return 0
		tmp2 = Cast(SubString ptr,list->getItem)	
	If tmp2=0 Then Return 0
	If tmp2->IsNumber=0 Then Return 0
	GLOBAL_CURSOR.x = Val(tmp2->text)
	logInterpret "GLOBAL_CURSOR x to:" + Str(GLOBAL_CURSOR.x) 
	tmp2 = Cast(SubString ptr,list->getItem)	
	If tmp2=0 Then Return 0
	If tmp2->IsNumber=0 Then Return 0
	GLOBAL_CURSOR.y = Val(tmp2->text)
	logInterpret "GLOBAL_CURSOR y to:" + Str(GLOBAL_CURSOR.y) 
	tmp2 = Cast(SubString ptr,list->getItem)	
	If tmp2=0 Then Return 0
	If tmp2->IsNumber=0 Then Return 0
	GLOBAL_CURSOR.width = Val(tmp2->text)
	logInterpret "GLOBAL_CURSOR width to:" + Str(GLOBAL_CURSOR.width) 
	tmp2 = Cast(SubString ptr,list->getItem)
	If tmp2=0 Then Return 0
	If tmp2->IsNumber=0 Then Return 0
	GLOBAL_CURSOR.height = Val(tmp2->text)
	logInterpret "GLOBAL_CURSOR height to:" + Str(GLOBAL_CURSOR.height) 
	tmp2 = Cast(SubString ptr,list->getItem)	
	If tmp2=0 Then Return 0
	If tmp2->IsNumber=0 Then Return 0
	GLOBAL_CURSOR.min_x = Val(tmp2->text)
	logInterpret "GLOBAL_CURSOR min_x to:" + Str(GLOBAL_CURSOR.min_x) 
	tmp2 = Cast(SubString ptr,list->getItem)	
	If tmp2=0 Then Return 0
	If tmp2->IsNumber=0 Then Return 0
	GLOBAL_CURSOR.min_y = Val(tmp2->text)
	logInterpret "GLOBAL_CURSOR min_y to:" + Str(GLOBAL_CURSOR.min_y) 
	tmp2 = Cast(SubString ptr,list->getItem)	
	If tmp2=0 Then Return 0
	If tmp2->IsNumber=0 Then Return 0
	GLOBAL_CURSOR.margin_x = Val(tmp2->text)
	logInterpret "GLOBAL_CURSOR margin_x to:" + Str(GLOBAL_CURSOR.margin_x) 
	tmp2 = Cast(SubString ptr,list->getItem)	
	If tmp2=0 Then Return 0
	If tmp2->IsNumber=0 Then Return 0
	GLOBAL_CURSOR.margin_y = Val(tmp2->text)
	logInterpret "GLOBAL_CURSOR margin_y to:" + Str(GLOBAL_CURSOR.margin_y) 
	
	Return 1
End Function

Type GLOBAL_CURSOR_setState_UDT extends commandUDT
	Declare Constructor
	Declare virtual Function action(list As list_type Ptr,parent As Any Ptr=0) As UByte
End Type

Constructor GLOBAL_CURSOR_setState_UDT
	base("setState")
End Constructor

Function GLOBAL_CURSOR_setState_UDT.action(list As list_type Ptr,parent As Any Ptr=0) As UByte
	Dim As utilUDT Ptr tmp
	Dim As SubString Ptr tmp2
	
	If list = 0 Then Return 0
	list->Reset
	tmp2 = Cast(SubString ptr,list->getItem)
	If tmp2->text<>this.CommandString Then Return 0
	tmp2 = Cast(SubString ptr,list->getItem)	
	If tmp2=0 Then Return 0
	
	If LCase(tmp2->text)="r" Then
		GLOBAL_CURSOR.state = 1
		logInterpret "GLOBAL_CURSOR state to:" + Str(GLOBAL_CURSOR.state) 
		Return 1
	EndIf
	If LCase(tmp2->text)="d" Then
		GLOBAL_CURSOR.state = 2
		logInterpret "GLOBAL_CURSOR state to:" + Str(GLOBAL_CURSOR.state) 
		Return 1
	EndIf
	
	Return 0
End Function

Type GLOBAL_CURSOR_setRight_UDT extends commandUDT
	Declare Constructor
	Declare virtual Function action(list As list_type Ptr,parent As Any Ptr=0) As UByte
End Type

Constructor GLOBAL_CURSOR_setRight_UDT
	base("r")
End Constructor

Function GLOBAL_CURSOR_setRight_UDT.action(list As list_type Ptr,parent As Any Ptr=0) As UByte
	GLOBAL_CURSOR.tmp_state = 1
	logInterpret "GLOBAL_CURSOR tmp_state to:" + Str(GLOBAL_CURSOR.tmp_state) 
	Return 1
End Function

Type GLOBAL_CURSOR_setDown_UDT extends commandUDT
	Declare Constructor
	Declare virtual Function action(list As list_type Ptr,parent As Any Ptr=0) As UByte
End Type

Constructor GLOBAL_CURSOR_setDown_UDT
	base("d")
End Constructor

Function GLOBAL_CURSOR_setDown_UDT.action(list As list_type Ptr,parent As Any Ptr=0) As UByte
	GLOBAL_CURSOR.tmp_state = 2
	logInterpret "GLOBAL_CURSOR tmp_state to:" + Str(GLOBAL_CURSOR.tmp_state) 
	Return 1
End Function

Type GLOBAL_CURSOR_setNewLine_UDT extends commandUDT
	Declare Constructor
	Declare virtual Function action(list As list_type Ptr,parent As Any Ptr=0) As UByte
End Type

Constructor GLOBAL_CURSOR_setNewLine_UDT
	base("n")
End Constructor

Function GLOBAL_CURSOR_setNewLine_UDT.action(list As list_type Ptr,parent As Any Ptr=0) As UByte
	GLOBAL_CURSOR.newLine = 1
	logInterpret "GLOBAL_CURSOR newLine to:" + Str(GLOBAL_CURSOR.newLine) 
	Return 1
End Function

Dim As GLOBAL_CURSOR_setX_UDT Ptr GLOBAL_CURSOR_setX = New GLOBAL_CURSOR_setX_UDT
Dim As GLOBAL_CURSOR_setY_UDT Ptr GLOBAL_CURSOR_setY = New GLOBAL_CURSOR_setY_UDT
Dim As GLOBAL_CURSOR_setXY_UDT Ptr GLOBAL_CURSOR_setXY = New GLOBAL_CURSOR_setXY_UDT

Dim As GLOBAL_CURSOR_setMinX_UDT Ptr GLOBAL_CURSOR_setMinX = New GLOBAL_CURSOR_setMinX_UDT
Dim As GLOBAL_CURSOR_setMinY_UDT Ptr GLOBAL_CURSOR_setMinY = New GLOBAL_CURSOR_setMinY_UDT
Dim As GLOBAL_CURSOR_setMinXY_UDT Ptr GLOBAL_CURSOR_setMinXY = New GLOBAL_CURSOR_setMinXY_UDT


Dim As GLOBAL_CURSOR_setwidth_UDT Ptr GLOBAL_CURSOR_setwidth = New GLOBAL_CURSOR_setwidth_UDT
Dim As GLOBAL_CURSOR_setHEIGHT_UDT Ptr GLOBAL_CURSOR_setHeight = New GLOBAL_CURSOR_setHEIGHT_UDT
Dim As GLOBAL_CURSOR_setWH_UDT Ptr GLOBAL_CURSOR_setWH = New GLOBAL_CURSOR_setWH_UDT


Dim As GLOBAL_CURSOR_setMarginX_UDT Ptr GLOBAL_CURSOR_setMarginX = New GLOBAL_CURSOR_setMarginX_UDT
Dim As GLOBAL_CURSOR_setMarginY_UDT Ptr GLOBAL_CURSOR_setMarginY = New GLOBAL_CURSOR_setMarginY_UDT
Dim As GLOBAL_CURSOR_setMarginXY_UDT Ptr GLOBAL_CURSOR_setMarginXY = New GLOBAL_CURSOR_setMarginXY_UDT

Dim As GLOBAL_CURSOR_setAll_UDT Ptr GLOBAL_CURSOR_setAll = New GLOBAL_CURSOR_setAll_UDT
Dim As GLOBAL_CURSOR_setState_UDT Ptr GLOBAL_CURSOR_setState = New GLOBAL_CURSOR_setState_UDT
Dim As GLOBAL_CURSOR_setRight_UDT Ptr GLOBAL_CURSOR_setRight = New GLOBAL_CURSOR_setRight_UDT
Dim As GLOBAL_CURSOR_setDown_UDT Ptr GLOBAL_CURSOR_setDown = New GLOBAL_CURSOR_setDown_UDT
Dim As GLOBAL_CURSOR_setNewLine_UDT Ptr GLOBAL_CURSOR_setNewLine = New GLOBAL_CURSOR_setNewLine_UDT


