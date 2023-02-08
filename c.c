
/*
  ptr_inspect.c

  Demonstration code; shows how to trace the system calls in a child
  process with ptrace.  Only works on 64-bit x86 Linux for now, I'm
  afraid.

  I got inspiration and a starting point from this old LJ article:
    http://www.linuxjournal.com/article/6100

  I release this code to the public domain.  Share and enjoy.
*/

#include <sys/ptrace.h>
//#include <sys/types.h>
#include <sys/wait.h>
#include <sys/user.h>

//#include <syscall.h>

#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

//const char* callname(long call);

//#if __WORDSIZE == 64
#define REG(reg) reg.orig_rax
//#else
//#define REG(reg) reg.orig_eax
//#endif

#define SHOW(call) ({ int _ret = (int)(call); printf("%s -> %d\n", #call, _ret); if (_ret < 0) { perror(NULL); }})

int main(int argc, char* argv[]) {
  pid_t child;

  if (argc == 1) {
    exit(0);
  }

  char* chargs[argc];
  int i = 0;

  while (i < argc - 1) {
    chargs[i] = argv[i+1];
    i++;
  }
  chargs[i] = NULL;

  child = fork();
  if(child == 0) {
    ptrace(PTRACE_TRACEME, 0, NULL, NULL);
    execvp(chargs[0], chargs);
  } else {
    int status;

    while(waitpid(child, &status, 0) && ! WIFEXITED(status)) {
//usleep(100000);
      struct user_regs_struct regs;
      ptrace(PTRACE_GETREGS, child, NULL, &regs);
      //fprintf(stderr, "system call %s from pid %d\n", callname(REG(regs)), child);
if(REG(regs)==-1){
      printf("%lld \n", REG(regs));
	SHOW(ptrace(PTRACE_POKETEXT, child, 0x1160, 0x90909090909090cc));
}
      ptrace(PTRACE_SYSCALL, child, NULL, NULL);//tested
    }
  }
  return 0;
}
