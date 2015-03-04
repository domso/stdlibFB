'ScreenRes 800,600,32

Do
	Dim As integer char = GetKey
	
	If (char And 255)=255 Then
		Print (char Shr 8) And 255 
	EndIf

Loop Until MultiKey(1)