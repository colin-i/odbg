
format elfobj64

include "../include/common.h"

warning off
include  "/usr/include/ocompiler/log.h"
warning on

#-1 err
function memorize_program(ss mem,sd end)
	sd number_of_files=0

	char term="\r\n"
	importx "strlen" strlen
	sd t_size
	setcall t_size strlen(#term)

	while mem!=end
		importx "strstr" strstr
		sd pointer
		setcall pointer strstr(mem,#term)
		if pointer==(NULL)
			return -1
		endif
		if mem#==(log_pathname)
			inc number_of_files
		endif
		add pointer t_size
		set mem pointer
	endwhile
	return 0
endfunction
