
format elfobj64

const PTRACE_TRACEME=0

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
		#else
			#thread, waitpid
		endif
	endif

	return ret
endfunction
