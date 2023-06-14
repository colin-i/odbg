
format elfobj64

include "elf.h"

include "common.h"

#er=-1
function get_section(sd file,sv p_mem,sv p_end)
	sd mem;set mem p_mem#

	sv off=Elf64_Shdr_sh_offset
	add off mem

	sd ret
	setcall ret fseek(file,off#,(SEEK_SET))
	if ret!=-1
		sv size=Elf64_Shdr_sh_size
		add size mem
		set size size#
		setcall mem malloc(size)
		if mem!=(NULL)
			sd sz
			setcall sz fread(mem,size,1,file)
			if sz==1
				set p_mem# mem
				add mem size
				set p_end# mem
				return ret
			endif
			call free(mem)
		endif
	endif

	return -1
endfunction
#same
function get_named_section(sd file,sd secs,sd esize,sd end,sd strings,sd strings_end,sv p_sec,sv p_end)
	sd in;set in p_sec#
	sd start;set start strings
	while strings!=strings_end
		sd c
		importx "strcmp" strcmp
		setcall c strcmp(strings,in)
		if c==0
			sub strings start
			while secs!=end
				sd p;set p secs
				add p (Elf64_Shdr_sh_name)
				#typedef uint32_t Elf64_Word

				if p#==strings
					set p_sec# secs
					sd ret
					setcall ret get_section(file,p_sec,p_end)
					return ret
				endif

				add secs esize
			endwhile
			break
		endif
		importx "strlen" strlen
		addcall strings strlen(strings)
		inc strings
	endwhile
	return -1
endfunction
importx "fopen" fopen
importx "fclose" fclose
#same
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
		setcall sz fread(#sections_offset,(Elf64_Ehdr_e_shoff_size),1,f)
		if sz==1
			setcall ret fseek(f,(Elf64_Ehdr_e_shentsize),(SEEK_SET))
			if ret!=-1
				data section_size=0   #high part will always be 0, words?
				setcall sz fread(#section_size,(Elf64_Ehdr_e_shentsize_size),1,f)
				if sz==1
					setcall ret fseek(f,(Elf64_Ehdr_e_shnum),(SEEK_SET))
					if ret!=-1
						data number_of_sections=0
						setcall sz fread(#number_of_sections,(Elf64_Ehdr_e_shnum_size),1,f)
						if sz==1
							setcall ret fseek(f,(Elf64_Ehdr_e_shstrndx),(SEEK_SET))
							if ret!=-1
								data strings_index=0
								setcall sz fread(#strings_index,(Elf64_Ehdr_e_shstrndx_size),1,f)
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
			sd strings_end
			setcall ret get_section(f,#strings,#strings_end)
			if ret!=-1
				ss dbg=".debug"
				sd dbg_end
				add size mem
				setcall ret get_named_section(f,mem,section_size,size,strings,strings_end,#dbg,#dbg_end)
				if ret!=-1
					import "memorize_program" memorize_program
					setcall ret memorize_program(dbg,dbg_end)
					call free(dbg)
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
