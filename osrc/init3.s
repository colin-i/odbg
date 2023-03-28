
format elfobj64

include "../include/common.h"

einclude  "/usr/include/ocompiler/log.h"

function files()
	value pointer=0
	return #pointer
endfunction

#-1 err
function memorize_program(ss mem,sd end)
	sd number_of_files=0

	char term="\r\n"
	importx "strlen" strlen
	sd t_size
	setcall t_size strlen(#term)

	#store for main iteration
	ss cursor;set cursor mem

	while mem!=end
		importx "strstr" strstr
		sd pointer
		setcall pointer strstr(mem,#term)
		if pointer==(NULL)
			return -1
		endif
		if mem#==(log_pathname)
			add number_of_files :
		endif
		add pointer t_size
		set mem pointer
	endwhile

	importx "malloc" malloc
	sv p;setcall p files()
	setcall p# malloc(number_of_files)
	if p#!=(NULL)
		while cursor!=end
			setcall pointer strstr(cursor,#term)
			#if pointer==(NULL) was checked already
			#log_pathfolder
			#log_pathname
			#log_fileend
			#log_fileend_old
			#log_line
			add pointer t_size
			set cursor pointer
		endwhile
		return 0
	endif

	return -1
endfunction
