
format elfobj64

include "../include/common.h"
include "common.h"

einclude  "/usr/include/ocompiler/log.h"

function files()
	value pointer=0
	return #pointer
endfunction

#-1 err
function memorize_program(ss mem,sd end)
	sd number_of_files=:  #one for null

	char term="\r\n"
	importx "strlen" strlen
	sd t_size
	setcall t_size strlen(#term)

	#store for main iteration
	ss cursor;set cursor mem
	ss pointer

	while mem!=end
		importx "strstr" strstr
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

	importx "calloc" calloc  #will have mallocs
	sv p;setcall p files()
	setcall p# calloc(1,number_of_files)
	sd storer;set storer p#
	if p#!=(NULL)
		while cursor!=end
			setcall pointer strstr(cursor,#term)
			#if pointer==(NULL) was checked already
			set pointer# (asciinul)
			sd ret;setcall ret memorize_line(cursor,#storer)
			if ret==-1
				import "odbg_free" odbg_free
				call odbg_free()
				return -1
			endif
			add pointer t_size
			set cursor pointer
		endwhile
		return 0
	endif

	return -1
endfunction
#same
function memorize_line(ss cursor,sv storer)
	#log_line
	if cursor#==(log_pathname)
		inc cursor
		importx "realpath" realpath
		sd n;setcall n realpath(cursor,(NULL))
		if n!=(NULL)
			sv aux;set aux storer#
			set aux# n
			incst storer#
		else
			return -1
		endelse
	#log_fileend
	#log_fileend_old
	elseif cursor#==(log_pathfolder)
		inc cursor
		importx "chdir" chdir
		sd ret
		setcall ret chdir(cursor)
		return ret
	endelseif
	return 0
endfunction
