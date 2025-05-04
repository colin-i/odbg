
#include <stdio.h>
#include <unistd.h>  //unlink
#include <stdlib.h>
#include <string.h>

int main(int argc,char**argv){
	char*n=argv[1];
	FILE*pre=fopen(n,"rb");if(pre==NULL)exit(EXIT_FAILURE);
	char*bf=NULL;ssize_t sz;
	sz=getline(&bf,&sz,pre);if(sz==-1)exit(EXIT_FAILURE);
	bf[sz-1]='\0';
	long p=ftell(pre);if(p==-1)exit(EXIT_FAILURE);
	fseek(pre,0,SEEK_END);
	long p2=ftell(pre);if(p2==-1)exit(EXIT_FAILURE);
	fseek(pre,p,SEEK_SET);
	p2-=p;
	char*mem=malloc(p2);if(mem==NULL)exit(EXIT_FAILURE);
	fread(mem,p2,1,pre);
	fclose(pre);

	char*tfile="tempfile.c";
	FILE*f=fopen(tfile,"wb");if(f==NULL)exit(EXIT_FAILURE);

	int whatout=fprintf(f,R"(
#include <%s>
#include <stddef.h>
#include <stdio.h>
#define member_size(type, member) sizeof(((type *)0)->member)
void main(){
char*file="%s";
FILE*f=fopen(file,"wb");
)",bf,argv[2]);if(whatout<0)exit(EXIT_FAILURE);
	free(bf);

	char*s=mem;char*ante;
	for(int i=0;i<p2;i++)if(mem[i]=='\n'){
		mem[i]='\0';
		if('A'<=*s&&*s<='Z')ante=s;
		else{
			int j=i-1;
			int show_size=mem[j]==',';
			if(show_size)mem[j]='\0';
			whatout=fprintf(f,"fprintf(f,\"const %s_%s=%%lu\\n\",offsetof(%s, %s));\n",ante,s,ante,s);if(whatout<0)exit(EXIT_FAILURE);
			if(show_size){
				whatout=fprintf(f,"fprintf(f,\"const %s_%s_size=%%lu\\n\",member_size(%s, %s));\n",ante,s,ante,s);if(whatout<0)exit(EXIT_FAILURE);
			}
		}
		s=&mem[i+1];
	}
	free(mem);

	whatout=fprintf(f,R"(fclose(f);
})");if(whatout<0)exit(EXIT_FAILURE);

	fclose(f);
	int ws=system("cc tempfile.c");if(WIFEXITED(ws))if(WEXITSTATUS(ws)!=0)exit(EXIT_FAILURE);
	unlink(tfile);
	char*a="./a.out";
//	int offset=WEXITSTATUS(system(a));
	ws=system(a);if(WIFEXITED(ws))if(WEXITSTATUS(ws)!=0)exit(EXIT_FAILURE);
	unlink(a);
	return EXIT_SUCCESS;
}
