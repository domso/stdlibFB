#Include Once "utilUDT.bas"
#Include Once "linklist.bas"
#Include Once "hashtableUDT.bas"

Dim Shared As hashtableUDT GLOBAL_IMG_TABLE = 100

Type imgUDT extends utilUDT
	As Any Ptr buffer,imgPixData
	As String id_name
	As Integer Width,height,imgPitch
	As UInteger Ptr pixel
	As UByte isError
	
	Declare Sub set(x As UInteger,y As uinteger,r As UByte,g As UByte,b As UByte,a As UByte=0)
	Declare function getR(x As UInteger,y As UInteger) As ubyte
	Declare function getG(x As UInteger,y As UInteger) As ubyte
	Declare function getB(x As UInteger,y As UInteger) As ubyte
	Declare function getA(x As UInteger,y As UInteger) As UByte
	Declare Function copy As imgUDT Ptr
	Declare Sub convert2Grey
	Declare Function useINTKernel(matrix As Integer Ptr,sizeY As Integer,sizeX As Integer,anchorY As Integer=-1,anchorX As Integer=-1,sum As Integer=-1) As imgUDT ptr
	
	Declare virtual Function equals(o As utilUDT Ptr) As Integer	
	Declare Constructor(Width_ As Integer,height As Integer,file As String="",id_name As String="")
	Declare Destructor
End Type

Sub imgUDT.set(x As UInteger,y As uinteger,r As UByte,g As UByte,b As UByte,a As UByte=0)
	If x>=this.width Or y>=this.height Then Return 
	pixel = imgPixData + y * imgPitch
	pixel[x] = RGBA(r,g,b,a)
End Sub

Function imgUDT.getR(x As UInteger,y As UInteger) As UByte
	If x>=this.width Or y>=this.height Then Return 0 
	Return (CUInt(Cast(uinteger Ptr,(imgPixData + y * imgPitch))[x]) Shr 16 And 255)
End Function

Function imgUDT.getG(x As UInteger,y As UInteger) As UByte
	If x>=this.width Or y>=this.height Then Return 0
	Return (CUInt(Cast(uinteger Ptr,(imgPixData + y * imgPitch))[x]) Shr 8 And 255)
End Function

Function imgUDT.getB(x As UInteger,y As UInteger) As UByte
	If x>=this.width Or y>=this.height Then Return 0
	Return (CUInt(Cast(uinteger Ptr,(imgPixData + y * imgPitch))[x])       And 255)
End Function

Function imgUDT.getA(x As UInteger,y As UInteger) As UByte
	If x>=this.width Or y>=this.height Then Return 0
	Return (CUInt(Cast(uinteger Ptr,(imgPixData + y * imgPitch))[x]) Shr 24)
End Function

Function imgUDT.copy As imgUDT Ptr
	Var tmp = New imgUDT(this.width,this.height)
	For y As Integer = 0 To this.height-1
		For x As Integer = 0 To this.width-1
			tmp->set(x,y,this.getR(x,y),this.getG(x,y),this.getB(x,y),this.getA(x,y))
		Next		
	Next
	Return tmp
End Function

Sub imgUDT.convert2Grey
	Dim As double col
	For y As Integer = 0 To this.height-1
		For x As Integer = 0 To this.width-1
			col = this.getR(x,y)*0.2126 + this.getG(x,y)*0.7152 + this.getB(x,y)*0.0722
			this.set(x,y,col,col,col,this.getA(x,y))
		Next		
	Next
End Sub

Function imgUDT.useINTKernel(matrix As Integer Ptr,sizeY As Integer,sizeX As Integer,anchorX As Integer=-1,anchorY As Integer=-1,sum As Integer=-1) As imgUDT ptr
	If matrix = 0 Then Return 0
	If anchorX<0 Then anchorX = (sizeX-1)/2
	If anchorY<0 Then anchorY = (sizeY-1)/2
	
	If sum<0 Then
		sum = 0
		
		For y As Integer = 0 To sizeY-1
			For x As Integer = 0 To sizeX-1
				sum += matrix[y*sizeX+x]
			Next
		Next
	EndIf
	
	If sum = 0 Then sum = 1
	Var tmp = New imgUDT(this.width,this.height)
	Dim As double R,G,B,A

	
	For y As Integer = 0 To this.height-1
		For x As Integer = 0 To this.width-1
			r = 0 : G = 0 : B = 0 : A = 0
			For ky As Integer = sizeY-1 To 0 Step -1
				For kx As Integer = sizeX-1 To 0 Step -1 

					R +=  matrix[ky*sizeX+kx]*this.getR(x-anchorX+((sizeX-1)-kx),y-anchorY+((sizeY-1)-ky))
					G +=  matrix[ky*sizeX+kx]*this.getG(x-anchorX+((sizeX-1)-kx),y-anchorY+((sizeY-1)-ky))
					B +=  matrix[ky*sizeX+kx]*this.getB(x-anchorX+((sizeX-1)-kx),y-anchorY+((sizeY-1)-ky))
					A +=  matrix[ky*sizeX+kx]*this.getA(x-anchorX+((sizeX-1)-kx),y-anchorY+((sizeY-1)-ky))		
				Next

			Next
			R/=sum : G/=sum : B/=sum : A/=sum

			tmp->set(x,y,Abs(R),Abs(G),Abs(B),Abs(A))
			
		Next
	Next
	Return tmp
	
End Function

Function imgUDT.equals(o As utilUDT Ptr) As Integer
	If this.id_name = Cast(imgUDT Ptr,o)->id_name Then Return 1
	Return 0
End Function

Constructor imgUDT(Width_ As Integer,height As Integer,file As String="",id_name As String="")
						
	this.id_name = id_name
	this.width = Width_
	this.height = height
	buffer = ImageCreate(this.width,This.height)
	ImageInfo buffer, ,,,imgPitch,imgPixData
	
	For y As Integer = 0 To this.height-1
		For x As Integer = 0 To this.width-1
			this.set(x,y,0,0,0)
		Next	
	Next
	
	If file<>"" Then isError = BLoad (file,buffer)
	If id_name<>"" Then GLOBAL_IMG_TABLE.add(id_name,@This)
End Constructor


Destructor imgUDT
	If buffer <> 0 Then
		ImageDestroy buffer
	EndIf
End Destructor

Function getIMG(id_name As String) As imgUDT Ptr
	Dim As imgUDT Ptr tmp
	tmp = Cast(imgUDT Ptr, GLOBAL_IMG_TABLE.get(id_name))
	Return tmp
End Function

Sub freeIMG(id_name As String)
	GLOBAL_IMG_TABLE.remove("id_name")
End Sub

Sub freeAllIMG
	GLOBAL_IMG_TABLE.clear
End Sub
