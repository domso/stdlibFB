#include once "utilUDT.bas"
#include once "linklist.bas"

type pda_relation extends utilUDT
	as String state
	as String in
	as String stack
	as string new_state
	as String new_stack_pre
	as String new_stack_post
	as ubyte isValid = 1
	Declare Constructor(state as String,in as String,stack as String,new_state as String,new_stack_pre as String,new_stack_post as String)
end Type

Constructor pda_relation(state as String,in as String,stack as String,new_state as String,new_stack_pre as String,new_stack_post as String)
	if state = "" or new_state = "" then isValid = 0 : return 
	this.state = state
	this.in = in
	this.stack = stack
	this.new_state = new_state
	this.new_stack_pre = new_stack_pre
	this.new_stack_post = new_stack_post
End Constructor

type pda extends utilUDT
	as String in
	as String stack
	as String state
	as String start_state
	as String end_state
	as String start_stack
	as list_type ptr relations
	as ubyte isNoValidPDA = 0, pdaError = 0,pdaSuccess=0
	Declare Constructor(relations as list_type ptr,start_state as String,end_state as String,start_stack as String)
	
	Declare Function runComplete(in as String) as Ubyte
	Declare Sub runStep()
end type

Constructor pda(relations as list_type ptr,start_state as String,end_state as String,start_stack as String)
	if relations = 0 then isNoValidPDA = 1 : return 
	this.relations = relations
	this.start_state = start_state
	this.end_state = end_state
	this.start_stack = start_stack
End constructor

Function pda.runComplete(in as String) as Ubyte
	if isNoValidPDA then return 0
	state = start_state
	pdaSuccess = 0
	Dim as ubyte found
	Dim as pda_relation ptr R
	do
		found = 0
		this.relations->reset
		do
			R = cast(pda_relation ptr,this.relations->getItem)
			if R<>0 then		
				if R->isValid then
					if this.state = R->state then
						if (R->in <> "" and left(in,len(R->in))=R->in) or R->in = "*" or (R->in = "" and in = R->in) then
							if (R->stack <> "" and left(stack,len(R->stack))=R->stack) or R->stack = "*" or (R->stack = "" and stack = R->stack) then
								if R->in <> "" then in = mid(in,len(R->in)+1)
								if R->stack <>  "" then stack = mid(stack,len(R->stack)+1)
								state = R->new_state
								stack = R->new_stack_pre + stack + R->new_stack_post
								found = 1
							end if
						end if
					end if
				end if
			end if
		loop until R = 0
	loop until found = 0
	if state = end_state and pdaError = 0 then return 1
	pdaError = 1
	return 0
end Function

Sub pda.runStep
	if isNoValidPDA then return
	state = start_state
	pdaSuccess = 0
	pdaError = 0
	Dim as pda_relation ptr R
	this.relations->reset
	Dim as ubyte found = 0
	do
		R = cast(pda_relation ptr,this.relations->getItem)
		if R<>0 then		
			if R->isValid then
				if this.state = R->state then
					if (R->in <> "" and left(in,len(R->in))=R->in) or R->in = "*" or (R->in = "" and in = R->in) then
						if (R->stack <> "" and left(stack,len(R->stack))=R->stack) or R->stack = "*" or (R->stack = "" and stack = R->stack) then
							if R->in <> "" then in = mid(in,len(R->in)+1)
							if R->stack <>  "" then stack = mid(stack,len(R->stack)+1)
							state = R->new_state
							stack = R->new_stack_pre + stack + R->new_stack_post
							found = 1
						end if
					end if
				end if
			end if
		end if
	loop until R = 0
	if found = 1 then
		if state = end_state then pdaSuccess = 1
	else
		pdaError = 1
	end if
end Sub

/' DEMO
var tmp = new list_type
tmp->add(new pda_relation("z0","a","","z0","a",""),1)
tmp->add(new pda_relation("z0","a","a","z0","aa",""),1)
tmp->add(new pda_relation("z0","b","a","z1","",""),1)
tmp->add(new pda_relation("z1","b","a","z1","",""),1)
tmp->add(new pda_relation("z1","","","z2","",""),1)

Dim as String test = string(50,"a")+string(50,"b")
var p = new pda(tmp,"z0","z2","")
p->in = test
do 
	p->runStep
	if p->pdaSuccess then print "yeah!" : exit do
	if p->pdaError then print "nope!" : exit do
loop
delete tmp
delete p
sleep
'/
