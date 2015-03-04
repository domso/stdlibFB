#Include Once "../util/util.bas"


Type GLOBAL_Img_load_UDT extends commandUDT
	Declare Constructor
	Declare virtual Function action(list As list_type Ptr,parent As Any Ptr=0) As UByte
End Type

Constructor GLOBAL_Img_load_UDT
	base("imgload")
End Constructor

Function GLOBAL_Img_load_UDT.action(list As list_type Ptr,parent As Any Ptr=0) As UByte
	Dim As SubString Ptr tmp2
	Dim As SubString Ptr tmp3
	
	Dim As String tmp_id_name
	Dim As String tmp_file
	Dim As Integer tmp_width
	Dim As Integer tmp_height
	
	If list = 0 Then Return 0
	list->Reset
	tmp2 = Cast(SubString ptr,list->getItem)
	If tmp2->text<>this.CommandString Then Return 0
	
	
	Do
		tmp2 = Cast(SubString ptr,list->getItem)	
		If tmp2<>0 Then		
			If tmp2->isCommand And tmp2->ListInUse Then
				tmp2->list->reset
				tmp3 = Cast(SubString Ptr,tmp2->list->getItem) 
				
				If LCase(tmp3->text) = "id_name" Then
					tmp3 = Cast(SubString Ptr,tmp2->list->getItem)
					If tmp3=0 Then
						logInterpret("no attribute for 'id_name'",1)
						Return 0
					EndIf
					tmp_id_name = tmp3->text
				EndIf
				If LCase(tmp3->text) = "file" Then
					tmp3 = Cast(SubString Ptr,tmp2->list->getItem)
					If tmp3=0 Then
						logInterpret("no attribute for 'file'",1)
						Return 0
					EndIf
					tmp_file = tmp3->text
				EndIf
				If LCase(tmp3->text) = "width" Then
					tmp3 = Cast(SubString Ptr,tmp2->list->getItem)
					If tmp3=0 Then
						logInterpret("no attribute for 'width'",1)
						Return 0
					EndIf
					If tmp3->IsNumber=0 Then Return 0
					tmp_width = Val(tmp3->text)
				EndIf
				If LCase(tmp3->text) = "height" Then
					tmp3 = Cast(SubString Ptr,tmp2->list->getItem)
					If tmp3=0 Then
						logInterpret("no attribute for 'height'",1)
						Return 0
					EndIf
					If tmp3->IsNumber=0 Then Return 0
					tmp_height = Val(tmp3->text)
				EndIf
				
				 
			EndIf
			
			
			
			
		
		End if
	Loop Until tmp2 = 0

	If tmp_id_name="" Then
		logInterpret("missing attribute 'id_name' for image",1)
		Return 0
	EndIf
	If tmp_file="" Then
		logInterpret("missing attribute 'file' for image",1)
		Return 0
	EndIf
	If tmp_width=0 Then
		logInterpret("missing attribute 'width' for image",1)
		Return 0
	EndIf
	If tmp_height=0 Then
		logInterpret("missing attribute 'height' for image",1)
		Return 0
	EndIf
	
	Dim As imgUDT ptr tmpIMG = New imgUDT(tmp_width,tmp_height,tmp_file,tmp_id_name)
	
	
	If tmpIMG->isError<>0 Then
		logInterpret ("failed to load image '"+tmp_id_name+"' from '"+tmp_file+"' ("+Str(tmp_width)+"x"+Str(tmp_height)+")",1)
		logInterpret ("->"+getFBerrorMSG(tmpIMG->isError),1)
		Return 0
	Else
		logInterpret "load image '"+tmp_id_name+"' from '"+tmp_file+"' ("+Str(tmp_width)+"x"+Str(tmp_height)+")"
	EndIf

	
	
	'logInterpret "GLOBAL_CURSOR newLine to:" + Str(GLOBAL_CURSOR.newLine) 
	Return 1
End Function

Dim As GLOBAL_Img_load_UDT Ptr GLOBAL_Img_load = New GLOBAL_Img_load_UDT 