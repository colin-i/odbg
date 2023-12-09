
format elfobj64

include "common.h"

include "header.h"
function line()
	datax nr#1
	datax reg#1
endfunction

einclude  "/usr/include/ocompiler/logs.h"

function files()
	value pointer=0
	return #pointer
endfunction

#-1 err
function memorize_program(ss mem,sd end)
	sd number_of_files=1  #one for null

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
		if pointer=(NULL)
			return -1
		endif
		if mem#=(log_pathname)
			inc number_of_files
		endif
		add pointer t_size
		set mem pointer
	endwhile

	importx "calloc" calloc  #will have mallocs
	sv storer;setcall storer files()
	mult number_of_files (\\file)
	setcall storer# calloc(1,number_of_files)  #here will be tested at frees
	set storer storer#
	if storer!=(NULL)
		sub storer (\\file)  #will add another one at path start
		while cursor!=end
			setcall pointer strstr(cursor,#term)
			#if pointer==(NULL) was checked already
			set pointer# (asciinul)
			sd ret;setcall ret memorize_line(cursor,#storer)
			if ret=-1
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
	valuex samecombiner#1
	if cursor#=(log_line)
		set samecombiner storer#

		sd pos=\\line
		mult pos samecombiner#:file.lnumber
		inc samecombiner#:file.lnumber

		importx "reallocarray" reallocarray
		sd mem;setcall mem reallocarray(samecombiner#:file.lines,samecombiner#:file.lnumber,(\\line))
		if mem=(NULL)
			return -1
		endif
		set samecombiner#:file.lines mem

		inc cursor
		add mem pos
		importx "sscanf" sscanf
		sd items
		setcall items sscanf(cursor,"%u %u",#mem#:line.nr,#mem#:line.reg)
		if items!=2
			return -1
		endif
	elseif cursor#=(log_pathname)
		inc cursor
		importx "realpath" realpath
		sd n;setcall n realpath(cursor,(NULL))
		if n!=(NULL)
			importx "malloc" malloc
			sd lns;setcall lns malloc((NULL))
			if lns!=(NULL)
				add storer# (\\file)
				set samecombiner storer#

				set samecombiner#:file.path n

				#and set for lines
				set samecombiner#:file.lines lns

				set samecombiner#:file.lnumber 0
			else
				importx "free" free
				call free(n)
				return -1
			endelse
		else
			return -1
		endelse
	#log_fileend
	#log_fileend_old
	elseif cursor#=(log_pathfolder)
		inc cursor
		importx "chdir" chdir
		sd ret
		setcall ret chdir(cursor)
		return ret
	endelseif
	return 0
endfunction
