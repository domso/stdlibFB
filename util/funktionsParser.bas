Randomize timer
'#################################################################################################################################
'liste
type functionVarType
	as String zeichen
	as double wert
	as functionVarType ptr nextVar
	Declare Constructor(zeichen as String,wert as double)
end Type

Constructor functionVarType(zeichen as String,wert as double)
	this.zeichen = lcase(zeichen)
	this.wert = wert
end Constructor

Dim shared as functionVarType ptr functionVarType_list_start

Function search_functionVarType_list(zeichen as String) as functionVarType ptr
	Dim as functionVarType ptr tmp
	tmp = functionVarType_list_start
	do
		if tmp = 0 then return 0
		if tmp->zeichen = zeichen then return tmp
		tmp = tmp->nextVar
	loop
end Function

Sub add_functionVarType_list(zeichen as String,wert as Double)
	if zeichen = "" then return
	zeichen = lcase(zeichen)
	for i as integer = 0 to len(zeichen)-1
		if zeichen[i]<97 or zeichen[i]>122 then return
	next
	var tmp = search_functionVarType_list(zeichen)
	if tmp = 0 then
		var tmpVar = new functionVarType(zeichen,wert)
		tmpVar->nextVar = functionVarType_list_start
		functionVarType_list_start = tmpVar
	else
		tmp->wert = wert
	end if
End Sub
'#################################################################################################################################
Dim shared as UByte PARSER_SYNTAX_ERROR = 0
Dim shared as UByte PARSER_MATH_ERROR = 0

function fPars_intern(in as String) as Double
	if in = "" then 
		PARSER_SYNTAX_ERROR = 1
		return 0
	end if
	in = lcase(in)
	'entferne außenklammern
	while left(in,1) = "(" and right(in,1) = ")"
		in = mid(in,2,len(in)-2)
	wend
	'zuweisungen
	if instr(in,"=") then
		dim as string varName = mid(in,1,instr(in,"=")-1)	
		dim as double varCount = fPars_intern(mid(in,instr(in,"=")+1))	
		add_functionVarType_list(varName,varCount)
		return varCount	
	end if
	dim as ubyte zeichen,istZahl = 1
	dim as integer pos_zeichen,klammer_zaehler
	for i as integer = 0 to len(in)-1
		
		if in[i]>57 or in[i]<48 then
			if in[i]<>46 then istZahl = 0
		end if
		if in[i] = 40 then klammer_zaehler+=1
		if in[i] = 41 then klammer_zaehler-=1
		if klammer_zaehler = 0 then
			if in[i] = 43 or in[i] = 45 or in[i] = 42 or in[i] = 47 or in[i] = 94 or in[i] = 37 then
				if zeichen = 0 then
					zeichen = in[i]
					pos_zeichen = i
				elseif zeichen <> in[i] then
					Select case zeichen
						case 42
							if in[i] = 43 or in[i] = 45 then
								zeichen = in[i]
								pos_zeichen = i
							end if
						case 47
							if in[i] = 43 or in[i] = 45 then
								zeichen = in[i]
								pos_zeichen = i
							end if
						case 94
							zeichen = in[i]
							pos_zeichen = i
					end Select
					if in[i] = 37 then
						zeichen = in[i]
						pos_zeichen = i
					end if
				end if 
			end if
		end if
	next
	if zeichen <> 0 then
		dim as double a
		dim as double b
		a = fPars_intern(mid(in,1,pos_zeichen))
		b = fPars_intern(mid(in,pos_zeichen+2))
		Select case zeichen
			case 43
				return a+b
			case 45
				return a-b
			case 42
				return a*b
			case 47
				return a/b
			case 94
				return a^b
			case 37
				return a mod b
		end Select
	else
		if istZahl then
			return val(in)
		end if
		if left(in,3) = "sin" then return sin(fPars_intern(mid(in,4)))
		if left(in,3) = "cos" then return cos(fPars_intern(mid(in,4)))
		if left(in,3) = "tan" then return tan(fPars_intern(mid(in,4)))
		if left(in,4) = "asin" then return asin(fPars_intern(mid(in,5)))
		if left(in,4) = "acos" then return acos(fPars_intern(mid(in,5)))
		if left(in,3) = "atn" then return atn(fPars_intern(mid(in,4)))
		if left(in,3) = "log" then return log(fPars_intern(mid(in,4)))
		if left(in,2) = "ln" then return log(fPars_intern(mid(in,4)))
		if left(in,3) = "exp" then return exp(fPars_intern(mid(in,4)))
		if left(in,3) = "abs" then return abs(fPars_intern(mid(in,4)))
		if left(in,3) = "sgn" then return sgn(fPars_intern(mid(in,4)))
		if left(in,3) = "sqr" then return sqr(fPars_intern(mid(in,4)))
		if left(in,3) = "int" then return int(fPars_intern(mid(in,4)))
		if left(in,4) = "cint" then return cint(fPars_intern(mid(in,5)))
		if left(in,3) = "fix" then return fix(fPars_intern(mid(in,4)))
		if left(in,4) = "frac" then return frac(fPars_intern(mid(in,5)))
		if in = "rnd" then return rnd()
		if in = "rnd()" then return rnd()
		if left(in,3) = "rnd" then return rnd(fPars_intern(mid(in,4)))

		if in = "pi" then return 3.141592653589793
		if in = "e" then return 2.718281828459045
		
		var tmp = search_functionVarType_list(in)
		if tmp <> 0 then return tmp->wert
		
	end if
	PARSER_SYNTAX_ERROR = 1
	return 0
end function

Function fpars(in as String) as Double
	'entferne leerzeichen
	dim as integer tmp = instr(in," ")
	while tmp
		in = mid(in,1,tmp-1)+mid(in,tmp+1)
		tmp = instr(in," ")
	wend
	'teile in ;-blöcke auf
	if instr(in,";") then
		var tmp = fpars_intern(mid(in,1,instr(in,";")-1))
		return fPars_intern(mid(in,instr(in,";")+1))
	end if
	return fpars_intern(in)
end Function

print fpars("x=int(rnd()*100x")
print fpars("x*x")
print fpars("y=x;y"));
print fpars("y*2+5")

print fpars("122%100")
sleep
