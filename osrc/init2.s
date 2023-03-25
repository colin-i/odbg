
format elfobj64

include "elf.h"

include "../include/common.h"
include "common.h"

importx "fopen" fopen
importx "fclose" fclose
#er=-1
function collect_program(ss program)
	sd f;setcall f fopen(program,"rb")
	if f!=(NULL)
		#collect .debug section
		sd ret
		setcall ret collect_program2(f)
		call fclose(f)
		return ret
	endif
	return -1
endfunction
importx "fseek" fseek
importx "fread" fread
#same
function collect_program2(sd f)
	sd ret
	setcall ret fseek(f,(Elf64_Ehdr_e_shoff),(SEEK_SET))
	if ret!=-1
		sd sections_offset
		sd sz
		setcall sz fread(#sections_offset,:,1,f)
		if sz==1
			setcall ret fseek(f,(Elf64_Ehdr_e_shentsize),(SEEK_SET))
			if ret!=-1
				data section_size=0   #high part will always be 0, words?
				setcall sz fread(#section_size,(wsz),1,f)
				if sz==1
					setcall ret fseek(f,(Elf64_Ehdr_e_shnum),(SEEK_SET))
					if ret!=-1
						data number_of_sections=0
						setcall sz fread(#number_of_sections,(wsz),1,f)
						if sz==1
							setcall ret fseek(f,(Elf64_Ehdr_e_shstrndx),(SEEK_SET))
							if ret!=-1
								data strings_index=0
								setcall sz fread(#strings_index,(wsz),1,f)
								if sz==1
									setcall ret fseek(f,sections_offset,(SEEK_SET))
									if ret!=-1
										setcall ret collect_program3(f,number_of_sections,section_size,strings_index)
									endif
								endif
							endif
						endif
					endif
				endif
			endif
		endif
		if sz!=1
			return -1
		endif
		return ret
	endif
	return -1
endfunction
importx "malloc" malloc
importx "free" free
#same
function collect_program3(sd f,sd size,sd section_size,sd strings)
	mult size section_size
	sd mem
	setcall mem malloc(size)
	if mem!=(NULL)
		sd ret
		sd sz
		setcall sz fread(mem,size,1,f)
		if sz==1
			mult strings section_size
			add strings mem
			setcall ret get_section(f,#strings)
			if ret!=-1
				ss dbg=".debug"
				setcall ret get_named_section(f,strings,#dbg)
				if ret!=-1
					#call free(dbg)
				endif
				call free(strings)
			endif
		endif
		call free(mem)
		if sz!=1
			return -1
		endif
		return ret
	endif
	return -1
endfunction
#same
function get_section(sd file,sv p_mem)
	sd mem;set mem p_mem#
	sv off=Elf64_Shdr_sh_offset
	sv size=Elf64_Shdr_sh_size

	add off mem
	add size mem

	sd ret
	setcall ret fseek(file,off#,(SEEK_SET))
	if ret!=-1
		setcall mem malloc(size#)
		if mem!=(NULL)
			sd sz
			setcall sz fread(mem,size#,1,file)
			if sz==1
				set p_mem# mem
				return ret
			endif
			call free(mem)
		endif
	endif

	return -1
endfunction
#same
function get_named_section(sd *file,sd *strings,sv *p_sec)
	return 0
endfunction
