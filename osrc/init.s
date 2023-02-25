
format elfobj64

include "init.h"

include "../include/common.h"

const PTRACE_TRACEME=0
const dwordstr=10
const asciiminus=0x2D

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
			else
				importx "_exit" exit

				call exit(0) #we are ignoring first argument since it is not used here
				#same like at ptrace+exit status is not ignored inside
			endelse
		else
			datax status#1
			sd proc;set proc ret

			importx "waitpid" waitpid

			setcall ret waitpid(proc,#status,0)  #WNOHANG 1
			if ret!=-1
				and status 0x7f
				if status!=0
					#orig_rax==0x3b  execve
					setcall ret stop_at_entry(proc)
				else
					return -1
				endelse
			endif
		endelse
	endif

	return ret
endfunction

function stop_at_entry(sd proc)
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

#rip+=0x1160;entry point with simple read predefined or bfd
#Elf64_Ehdr_e_entry

#importx "printf" printf
#call printf(line)
#chars qwe={10,0}
#call printf(#qwe)

#printf("%lx", rip);
#	SHOW(ptrace(PTRACE_POKETEXT, child, rip, 0x90909090909090cc));//0xcc is at start

#ptrace(PTRACE_CONT, child, NULL, NULL);//PTRACE_SYSCALL will have many interrupts

#wait
		endif

		importx "free" free
		importx "fclose" fclose

		call free(line)
		call fclose(file)
		return ret
	endif

	return -1
endfunction
