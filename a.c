
#include <signal.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

//CDK stands for "Curses Development Kit"

//ld --omagic -e main a.o

static void __attribute__((noreturn)) signalHandler(int sig,siginfo_t *info,void* ucontext){
(void)sig;(void)info;
printf("wqeqwe\n");
	//CaptureBacktraceUsingLibUnwind(ucontext);
      exit(0);
}

void main(){

//char*a=main;
//__asm("int $3");
//a[0x1e]=0xcc;
//a[0x1f]=0xcc;


struct sigaction signalhandlerDescriptor;
memset(&signalhandlerDescriptor, 0, sizeof(signalhandlerDescriptor));
signalhandlerDescriptor.sa_flags = SA_SIGINFO;//SA_RESTART | SA_ONSTACK;
signalhandlerDescriptor.sa_sigaction = signalHandler;
sigaction(SIGTRAP, &signalhandlerDescriptor, NULL);

__asm("int $3");

}
