ScreenRes 800,800,32
Randomize timer
#define RGBA_R(c) (CUInt(c) Shr 16 And 255)
#define RGBA_G(c) (CUInt(c) Shr  8 And 255)
#define RGBA_B(c) (CUInt(c)        And 255)
#define RGBA_A(c) (CUInt(c) Shr 24        )

Dim As Any Ptr img=ImageCreate(800,800)


For i As Integer = 1 To 2000000
	Dim As Integer c=Int(Rnd*255)
	Circle img,(Int(Rnd*800),Int(Rnd*800)),1,RGBA(c,c/2,c/4,255), , ,Int(Rnd*10)/Int(Rnd*10), F

	
Next

		Dim Shared As Integer map_R(0 To 800,0 To 800)
		Dim Shared As Integer map_G(0 To 800,0 To 800)
		Dim Shared As Integer map_B(0 To 800,0 To 800)
'For i As Integer = 1 To 800
'	For j As Integer = 1 To 800
'		Dim As integer r
'		Dim As integer g
'		Dim As integer b
'		For x As Integer = -5 To 5
'			For y As Integer = -5 To 5
'				r+=rgba_R(Point(i+x,j+y,img))
'				g+=rgba_G(Point(i+x,j+y,img))
'				b+=rgba_B(Point(i+x,j+y,img))
'			Next
'			Next
'		r/=121
'		g/=121
'		b/=121
'		map_R(i,j)=(r)
'		map_G(i,j)=(G)
'		map_B(i,j)=(B)
'		'Line img,(i,j)-(i,j),RGBa(0,0,0,)
'			
'	Next
'Next

For i As Integer = 0 To 800
		For j As Integer = 0 To 800
			'Line img,(i,j)-(i,j),RGBa(map_r(i,j),map_g(i,j),map_b(i,j),255)
			'Line img,(i,j)-(i,j),RGBa(0,0,0,255-RGBA_A(Point(i,j,img)))
			'If RGBA_A(Point(i,j,img))>150 then
			'	Line img,(i,j)-(i,j),RGBA(0,0,0,0)
			'EndIf
		Next
next	
		


Put(0,0), img,alpha
BSave "test.bmp",img

Sleep