#Include Once "../util/util.bas"



Type characterUDT extends utilUDT
	As Integer InvID
	As Double posX,posY,posZ,speed=1
	As integer  world=1
	As Byte toDEL,isOwnCharacter,changed
	As String* 9 char_Name
	
	Declare Constructor(char_Name As String)
	
	Declare Function equals(o As utilUDT Ptr) As Integer
	
	Declare Function toString As String

End Type

Constructor characterUDT(char_Name As String)
	if len(char_Name)=0 then char_Name="noname"
	this.char_Name=char_Name
End Constructor

Function characterUDT.equals(o As utilUDT Ptr) As Integer
	If o=0 Then Return 0
	If this.char_Name=Cast(characterUDT ptr,o)->char_Name and this.id=Cast(characterUDT ptr,o)->id Then Return 1
	Return 0
End Function

Function characterUDT.toString As String
	Return "Character: ID="+Str(id)+" Name='"+char_Name+"'"
End Function
