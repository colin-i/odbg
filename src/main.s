
#!
o language debugger
cui
!

format elfobj64

importx "opy_initialize" opy_initialize
importx "opy_finalize" opy_finalize
importx "opy_import" opy_import

importx "odbg_init" odbg_init
importx "odbg_free" odbg_free

entry main(sd argc,sv argv)
	if argc==2
		incst argv
		sd r;setcall r odbg_init(argv)
		if r!=-1
			sd err;setcall err opy_initialize()
			if err==0
				setcall err opy_import("urwid")
				if err==0
				endif
				call opy_finalize()
			endif

			call odbg_free()
		endif
	endif
	return 0
