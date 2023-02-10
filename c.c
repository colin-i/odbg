
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

#include <syscall.h>

#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

//#include <signal.h>

//const char* callname(long call);

//#if __WORDSIZE == 64
//#define REG(reg) reg.orig_rax
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
    execv(chargs[0], chargs);
//printf("%s",changedata);
  } else {
    int status;
int a=0;
    while(waitpid(child, &status, 0) && ! WIFEXITED(status)) {
//usleep(100000);
//      struct user_regs_struct regs;
//      ptrace(PTRACE_GETREGS, child, NULL, &regs);

struct user* user_space = (struct user*)0;
long long unsigned*addr=&user_space->regs.orig_rax;
long long unsigned orig_rax = ptrace(PTRACE_PEEKUSER, child, addr, NULL);
addr=&user_space->regs.rip;
long rip=ptrace(PTRACE_PEEKUSER, child, addr, NULL);
//long aa=regs.orig_rax;
      printf("system call %lx %llx\n",rip,orig_rax);// %s", callname(aa)
//      printf("system call %lx %llx %s\n",rip,orig_rax,callname(orig_rax));

if(orig_rax==0x3b){
	char qwer[100];
	sprintf(qwer,"cat /proc/%u/maps | head -1 | cut -d'-' -f1",child);//cut -d' ' -f1 |

  FILE *fp;
  char path[100];

  /* Open the command for reading. */
  fp = popen(qwer, "r");
  if (fp == NULL) {
    printf("Failed to run command\n" );
    exit(1);
  }

  /* Read the output a line at a time - output it. */
//  while (
fgets(path, sizeof(path), fp);
// != NULL) {
//printf("%s", path);
//  }
  /* close */
  pclose(fp);
	//printf(qwer);
	//system(qwer);//all sections are from the first call(execve)
	//sleep(20);
sscanf(path,"%lx",&rip);
rip+=0x1160;
printf("%lx", rip);
	SHOW(ptrace(PTRACE_POKETEXT, child, rip, 0x90909090909090cc));//0xcc is at start
}
//      printf("%llx \n", regs.rip);

//siginfo_t ss;
//SHOW(ptrace(PTRACE_GETSIGINFO, child, NULL, &ss));

if(orig_rax==-1){//
      printf("is 0xcc \n");
//	if(a==0){
//		a=1;
//		SHOW(ptrace(PTRACE_POKETEXT, child, rip, 0x90909090909090cc));//0xcc is at start
		//regs.rip
		//data is in same virtual address difference than text
//	}
}
//      ptrace(PTRACE_SYSCALL, child, NULL, NULL);//tested
      ptrace(PTRACE_CONT, child, NULL, NULL);//this is one execve(0x3b) and -1(the i3)
    }
  }
  return 0;
}
