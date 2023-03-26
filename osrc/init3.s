
format elfobj64

include "../include/common.h"

#-1 err
function memorize_program(sd mem)
	char term="\r\n"
	importx "strlen" strlen
	sd t_size
	setcall t_size strlen(#term)
	while 1==1
		importx "strstr" strstr
		sd pointer
		setcall pointer strstr(mem,#term)
		if pointer==(NULL)
			return 0
		endif
		add pointer t_size
		set mem pointer
	endwhile
endfunction
