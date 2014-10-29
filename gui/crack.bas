ScreenRes 800,800,32
Randomize timer
#define RGBA_R(c) (CUInt(c) Shr 16 And 255)
#define RGBA_G(c) (CUInt(c) Shr  8 And 255)
#define RGBA_B(c) (CUInt(c)        And 255)
#define RGBA_A(c) (CUInt(c) Shr 24        )

Dim As Any Ptr img=ImageCreate(800,800)
Line (0,0)-(800,800),RGB(255,255,0),bf
Line img,(0,0)-(800,800),RGBa(0,0,0,0),bf
For i As Integer = 1 To 100000
Dim As Integer x1=Int(Rnd*800),y1=Int(Rnd*800)
Dim As Integer x2=x1,y2=y1
Dim As Integer a=255
For j As Integer = 1 To Int(Rnd*100)
	x1=(x1-1)+Int(Rnd*3)
	y1=(y1-1)+Int(Rnd*3)
	Line img,(x2,y2)-(x1,y1),RGBa(0,0,0,a)
	x2=x1
	y2=y1
	a-=2
	a=Abs(a)
	'If x1<0 Or x1>800 Then Exit do
	'If y1<0 Or y1>800 Then Exit do
	
next
next
'Color RGB(255,255,255),RGB(125,125,125)
'cls
		Dim Shared As Integer map(0 To 800,0 To 800)
For i As Integer = 1 To 800
	For j As Integer = 1 To 800
		Dim As double f
		For x As Integer = -1 To 1
			For y As Integer = -1 To 1
				f+=point(i+x,j+y,img)
			Next
			Next
		f/=9
		map(i,j)=RGBA_A(f)
		'Line img,(i,j)-(i,j),RGBa(0,0,0,)
			
	Next
Next

For i As Integer = 0 To 800
		For j As Integer = 0 To 800
			'Line img,(i,j)-(i,j),RGBA(0,0,0,map(i,j))
			Line img,(i,j)-(i,j),RGBa(0,0,0,255-RGBA_A(Point(i,j,img)))
			If RGBA_A(Point(i,j,img))>150 then
				Line img,(i,j)-(i,j),RGBA(0,0,0,0)
			EndIf
		Next
next	
		



Put(0,0), img,alpha
BSave "test.bmp",img

sleep