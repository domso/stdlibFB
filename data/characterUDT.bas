#Include Once "../util/util.bas"
#Include Once "objUDT.bas"

#define CHARACTERUDT_ATTRIBUTE_BASIC_ID 1
type characterUDT_attribute_basic extends utilUDT
	'etc
	'etc
end type

type characterUDT extends objUDT
	
	Declare Constructor
end type

Constructor characterUDT
	base()
	base.add(CHARACTERUDT_ATTRIBUTE_BASIC_ID,new characterUDT_attribute_basic)
	
end Constructor
