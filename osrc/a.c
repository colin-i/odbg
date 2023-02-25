
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>

void main(int argc,char**argv){
	char*n=argv[1];
	FILE*pre=fopen(n,"rb");
	char*b1;char*b2;char*b3;size_t s1,s2,s3;
	s1=getline(&b1,&s1,pre);b1[s1-1]='\0';
	s2=getline(&b2,&s2,pre);b2[s2-1]='\0';
	getline(&b3,&s3,pre);
	fclose(pre);
	char*tfile="tempfile.c";
	FILE*f=fopen(tfile,"wb");
	fprintf(f,"#include <%s>\n#include <stddef.h>\nint main(){return offsetof(%s, %s);}",b1,b2,b3);
	free(b1);
	fclose(f);
	system("cc tempfile.c");
	unlink(tfile);
	char*a="./a.out";
	int offset=WEXITSTATUS(system(a));
	unlink(a);
	n=argv[2];
	size_t sz=strlen(n);
	char*buf=malloc(sz+2+1);
	sprintf(buf,"%s.h",n);
	f=fopen(buf,"wb");
	fprintf(f,"const %s_%s=%u\n",b2,b3,offset);
	free(b2);
	free(b3);
	free(buf);
	fclose(f);
}
