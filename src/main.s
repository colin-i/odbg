
format elfobj64

const NULL=0
const TRUE=1
const FALSE=0

importx "initCDKScreen" initCDKScreen
importx "destroyCDKScreen" destroyCDKScreen
importx "endCDK" endCDK

importx "newCDKSwindow" newCDKSwindow
importx "_destroyCDKObject" destroyCDKObject
importx "activateCDKSwindow" activateCDKSwindow

importx "printf" printf

entry main(sd argc,sd *argv)
	if argc<2
		call printf("Usage: odbg program")
		chars n={10,0}
		call printf(#n)
	else
		sd cdkscreen;setcall cdkscreen initCDKScreen((NULL))
		sd CDKSwindow;setcall CDKSwindow newCDKSwindow(cdkscreen,0,0,0,0,"O Debugger",0,(TRUE),(FALSE))
		if CDKSwindow!=(NULL)
			call activateCDKSwindow(CDKSwindow,(NULL))
		endif
		call destroyCDKObject(CDKSwindow)
		call destroyCDKScreen(cdkscreen)
		call endCDK()
	endelse
	return 0
