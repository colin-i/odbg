
format elfobj64

include "init.h"

include "../include/common.h"

const PTRACE_TRACEME=0
#const PTRACE_POKETEXT=4
const PTRACE_CONT=7
const dwordstr=10
const asciiminus=0x2D
const SEEK_SET=0

#-1 or different
functionx odbg_init(sv argv)
	#vfork is not cloning the memory like fork, but same 0,pid return and maybe same -1 error

	sd ret

	importx "vfork" vfork
	setcall ret vfork()

	if ret!=-1
		if ret==0
			importx "ptrace" ptrace

			setcall ret ptrace((PTRACE_TRACEME),0,0,0)
			#"pid, addr, and data are ignored."
			#on conv64 is not required to pass them but on 32 an implementation can overwrite them and pass them further
			#it's better to mimic c and pass them all instead of divide them further for 64, for understandability

			if ret!=-1
				#will return to parent at this call, child will never return
				importx "execve" execve
				importx "__environ" environ
				sv env^environ
				call execve(argv#,argv,env#)
			endif

			importx "_exit" exit
			call exit(0) #we are ignoring first argument since it is not used here
			#same like at ptrace+exit status is not ignored inside
		endif

		datax status#1
		sd proc;set proc ret

		importx "waitpid" waitpid

		setcall ret waitpid(proc,#status,0)  #WNOHANG 1
		if ret!=-1
			and status 0x7f
			if status!=0
				#orig_rax==0x3b  execve
				setcall ret trap_at_entry(proc,argv#)
				if ret!=-1
					setcall ret waitpid(proc,#status,0)
					if ret!=-1
						and status 0x7f
						if status!=0
						#	importx "printf" p;call p("x");chars qwe={10,0};call p(#qwe)
						else
							return -1
						endelse
					else
						return -1
					endelse
				else
					return -1
				endelse
			else
				return -1
			endelse
		endif
	endif

	return ret
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
				sd a=0xcc;sd b^a;inc b
				importx "memset" memset
				call memset(b,0x90,(:-1))
				setcall ret ptrace((PTRACE_POKETEXT),proc,rip,a)
				if ret!=-1
					setcall ret ptrace((PTRACE_CONT),proc,(NULL),(NULL))
					#PTRACE_SYSCALL will have many interrupts
				endif
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
