
format elfobj64

const PTRACE_TRACEME=0

importx "vfork" vfork

functionx odbg_init(sv argv)
	#vfork is not cloning the memory like fork, but same 0,pid return and maybe same -1 error

	sd ret

	setcall ret vfork()

	if ret!=-1
		if ret==0
			importx "ptrace" ptrace
			setcall ret ptrace((PTRACE_TRACEME)) #pid, addr, and data are ignored.
			if ret==-1
				#will return to parent at this call, child will never return
				importx "execve" execve
				importx "__environ" environ
				sv env^environ
				call execve(argv#,argv,env#);
			else
				importx "_exit" exit
				call exit() #we are ignoring first argument since it is not used here
			endelse
		#else
			#thread, waitpid
		endif
	endif

	return ret
endfunction
