
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
				sd section_size=0
				setcall sz fread(#section_size,(wsz),1,f)
				if sz==1
					setcall ret fseek(f,(Elf64_Ehdr_e_shnum),(SEEK_SET))
					if ret!=-1
						sd number_of_sections=0
						setcall sz fread(#number_of_sections,(wsz),1,f)
						if sz==1
							setcall ret fseek(f,(Elf64_Ehdr_e_shstrndx),(SEEK_SET))
							if ret!=-1
								sd strings_index=0
								setcall sz fread(#strings_index,(wsz),1,f)
								if sz==1
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
