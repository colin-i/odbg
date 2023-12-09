
#include <stdio.h>
#include <unistd.h>  //unlink
#include <stdlib.h>
#include <string.h>

void main(int argc,char**argv){
	char*n=argv[1];
	FILE*pre=fopen(n,"rb");
	char*bf=NULL;size_t sz;
	sz=getline(&bf,&sz,pre);
	bf[sz-1]='\0';
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
#define member_size(type, member) sizeof(((type *)0)->member)
void main(){
char*file="%s";
FILE*f=fopen(file,"wb");
)",bf,argv[2]);
	free(bf);

	char*s=mem;char*ante;
	for(int i=0;i<p2;i++)if(mem[i]=='\n'){
		mem[i]='\0';
		if('A'<=*s&&*s<='Z')ante=s;
		else{
			int j=i-1;
			int show_size=mem[j]==',';
			if(show_size)mem[j]='\0';
			fprintf(f,"fprintf(f,\"const %s_%s=%%lu\\n\",offsetof(%s, %s));\n",ante,s,ante,s);
			if(show_size)fprintf(f,"fprintf(f,\"const %s_%s_size=%%lu\\n\",member_size(%s, %s));\n",ante,s,ante,s);
		}
		s=&mem[i+1];
	}
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
