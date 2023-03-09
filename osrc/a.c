
#include <stdio.h>
#include <unistd.h>  //unlink
#include <stdlib.h>
#include <string.h>

void main(int argc,char**argv){
	char*n=argv[1];
	FILE*pre=fopen(n,"rb");
	char*b1;char*b2;size_t s1,s2;
	s1=getline(&b1,&s1,pre);b1[s1-1]='\0';
	s2=getline(&b2,&s2,pre);b2[s2-1]='\0';
	long p=ftell(pre);
	fseek(pre,0,SEEK_END);
	long p2=ftell(pre);
	fseek(pre,p,SEEK_SET);
	p2-=p;
	char*mem=malloc(p2);
	fread(mem,p2,1,pre);
	fclose(pre);

	char*tfile="tempfile.c";
	FILE*f=fopen(tfile,"wb");

	fprintf(f,R"(
#include <%s>
#include <stddef.h>
#include <stdio.h>
void main(){
char*file="%s";
char*ante="%s";
FILE*f=fopen(file,"wb");
)",b1,argv[2],b2);
	free(b1);

	char*s=mem;
	for(int i=0;i<p2;i++)if(mem[i]=='\n'){
		mem[i]='\0';
		fprintf(f,"fprintf(f,\"const %%s_%%s=%%lu\\n\",ante,\"%s\",offsetof(%s, %s));\n",s,b2,s);
		s=&mem[i+1];
	}
	free(b2);
	free(mem);

	fprintf(f,R"(fclose(f);
})");

	fclose(f);
	system("cc tempfile.c");
	unlink(tfile);
	char*a="./a.out";
//	int offset=WEXITSTATUS(system(a));
	system(a);
	unlink(a);
}
