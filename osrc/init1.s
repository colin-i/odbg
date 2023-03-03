
format elfobj64

include "init1.h"

include "../include/common.h"

const PTRACE_PEEKTEXT=1
const PTRACE_POKETEXT=4
const PTRACE_CONT=7
const dwordstr=10
const asciiminus=0x2D
const SEEK_SET=0

#same
function wait_pid(sd proc)
	datax status#1
	sd ret
	importx "waitpid" waitpid
	setcall ret waitpid(proc,#status,0)  #WNOHANG 1
	if ret!=-1
		and status 0x7f
		if status!=0
			return ret
		endif
		return -1
	endif
	return -1
endfunction
#same
function trap_at_entry(sd proc,sd fname)
	charsx buf#1+4+1+dwordstr+1+4+1

	importx "sprintf" sprintf
	importx "fopen" fopen

	call sprintf(#buf,"/proc/%u/maps",proc)

	sd file;setcall file fopen(#buf,"r")
	if file!=(NULL)
		sd line=NULL
		sd size
		#This  buffer  should  be freed by the user program even if getline() failed

		importx "getdelim" getdelim
		sd ret;setcall ret getdelim(#line,#size,(asciiminus),file)
		if ret!=-1
			importx "sscanf" sscanf
			sd rip
			call sscanf(line,"%lx",#rip) #the "ordinary character" - is after %lx

			setcall ret add_elf_entry(fname,#rip)
			if ret!=-1
				setcall ret break_at_entry(proc,rip)
			endif
		endif

		importx "free" free
		importx "fclose" fclose

		call free(line)
		call fclose(file)
		return ret
	endif

	return -1
endfunction
#same
function add_elf_entry(sd fname,sv prip)
	sd f;setcall f fopen(fname,"rb")
	if f!=(NULL)
		sd ret
		importx "fseek" fseek
		setcall ret fseek(f,(Elf64_Ehdr_e_entry),(SEEK_SET))
		if ret!=-1
			sd entry
			importx "fread" fread
			sd sz;setcall sz fread(#entry,:,1,f)
			if sz==1
				add prip# entry
			else
				set ret -1
			endelse
		endif
		call fclose(f)
		return ret
	endif
	return -1
endfunction
#same
function break_at_entry(sd proc,sd rip)
	importx "ptrace" ptrace
	importx "__errno_location" errno
	#errno = 0;
	sd err;setcall err errno()
	set err# 0
	sd back
	setcall back ptrace((PTRACE_PEEKTEXT),proc,rip,0)
	if err#==0
		sd ret
		#call memset(b,0x90,(:-1))
		setcall ret ptrace((PTRACE_POKETEXT),proc,rip,(0xcc))
		if ret!=-1
			setcall ret ptrace((PTRACE_CONT),proc,(NULL),(NULL))
			#PTRACE_SYSCALL will have many interrupts
			if ret!=-1
				setcall ret wait_pid(proc)
				if ret!=-1
					setcall ret ptrace((PTRACE_POKETEXT),proc,rip,back)
					#importx "printf" p;call p("x");chars qwe={10,0};call p(#qwe)
				endif
			endif
		endif
		return ret
	endif
	return -1
endfunction
