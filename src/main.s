
#!
o language debugger
cdk cui
!

format elfobj64

include "../include/common.h"

const TRUE=1
const FALSE=0

importx "initCDKScreen" initCDKScreen
importx "destroyCDKScreen" destroyCDKScreen
importx "endCDK" endCDK

importx "newCDKSwindow" newCDKSwindow
importx "_destroyCDKObject" destroyCDKObject
importx "activateCDKSwindow" activateCDKSwindow

importx "printf" printf

importx "odbg_init" odbg_init

entry main(sd argc,sv argv)
	if argc<2
		call printf("Usage: odbg program")
		chars n={10,0}
		call printf(#n)
	else
		incst argv
		sd r;setcall r odbg_init(argv)
		if r!=-1
			sd cdkscreen;setcall cdkscreen initCDKScreen((NULL))
			sd CDKSwindow;setcall CDKSwindow newCDKSwindow(cdkscreen,0,0,0,0,"O Debugger",0,(TRUE),(FALSE))
			if CDKSwindow!=(NULL)
				call activateCDKSwindow(CDKSwindow,(NULL))
			endif
			call destroyCDKObject(CDKSwindow)
			call destroyCDKScreen(cdkscreen)
			call endCDK()
		endif
	endelse
	return 0
