
#include "bfd.h"

//.dynsym .rela.dyn .dynstr .text
//Entry point address
//objcopy -O binary --only-section=.text foobar.elf foobar.text
//objcopy f --update-section .text=foobar.text

#include <stdlib.h>
#include <stdio.h>

static int skip_section(bfd*b,asection*s){
	return 0;
//implicit declaration of function ‘bfd_get_section_flags’
	if(s->flags & SEC_DEBUGGING){
		printf("bfd flags");
		return 1;
	}
	char*c=".comment";
	size_t cs=strlen(c);
	if (strncmp(s->name,c,cs)==0){
		printf(".comment");
		return 1;
	}
	char*n=".note";
	size_t ns=strlen(n);
	if (strncmp(s->name,n,ns)==0){
		printf(".note");
		return 1;
	}
	return 0;
}
int one=0;
static void define_section(bfd*infile,asection*section,void*v){
	if(skip_section(infile,section))return;

	bfd*outfile=(bfd*)v;

	asection*s=bfd_make_section_anyway(outfile,section->name);

	bfd_set_section_size(s,bfd_section_size(section));//infile, expected 'const asection *'
	//outfile, expected 'asection *'

	s->vma=section->vma;
	s->lma=section->lma;
	s->alignment_power=section->alignment_power;
	bfd_set_section_flags(s,section->flags);//outfile,

	//link output to input. needed at copy
	section->output_section=s;
	//
	section->output_offset=0;
	bfd_copy_private_section_data(infile,section,outfile,s);


if(section->flags==283){
one++;if(one==5){
asection* s2=bfd_make_section(outfile,".text2");
//!=NULL
//bfd_perror(NULL);
//asection*prev=bfd_get_section_by_name(infile, ".text");
s2->alignment_power=section->alignment_power;
//bfd_set_section_size(s,bfd_section_size(section));
s2->vma=section->vma;
s2->lma=section->lma;
bfd_set_section_flags(s2,section->flags);
bfd_copy_private_section_data(infile,section,outfile,s2);//important
bfd_perror(NULL);
}}

}

typedef struct{
	bfd*output;
	asymbol**syms;
	//int sz_syms,count_syms;
}COPYDATA;

static void copy_section(bfd*infile,asection*section,void*v){
	if(skip_section(infile,section))return;

	COPYDATA* data=(COPYDATA*)v;

	asection*s=section->output_section;
printf("%s %u\n",section->name,section->flags);
	//#define bfd_get_section_size_before_reloc(section) \
	//(section->reloc_done ? (abort(),1): (section)->_raw_size)   //,1 do nothing ,a=1 can be something
	//long sz=bfd_get_section_size_before_reloc(section);//implicit declaration
	long sz;
	//if(section->reloc_done)abort();//has no member named 'reloc_done'; did you mean 'reloc_count'
	//else
	//__asm("int $3");
	sz=section->size;//has no member named '_raw_size'; did you mean 'rawsize' //rawsize is always 0

//	long sz_reloc=bfd_get_reloc_upper_bound(infile,section);

	unsigned char*buf;

//	if (!sz_reloc){
//printf("reloc bound 0\n");
//exit(1);//never here
//		bfd_set_reloc(data->output,s,(arelent**)NULL,0);
//	}else if(sz_reloc>0){//maybe no relocs at -1 error
//printf("reloc bound>0\n");
//		buf=malloc(sz_reloc);
		//!=NULL
//		long count=bfd_canonicalize_reloc(infile,section,(arelent**)buf,data->syms);
//		bfd_set_reloc(data->output,s,(arelent**)(count?buf:NULL),count);
//		free(buf);
//	}

	//"for no apparent reason"
	//section->_cooked_size=sz;//has no member named '_cooked_size'
	//section->reloc_done=true;

	if(section->flags&SEC_HAS_CONTENTS){
//printf("HAS_CONTENTS %lu\n",sz);
		buf=malloc(sz);
		//!=NULL
		bfd_get_section_contents(infile,section,buf,0,sz);
		bfd_set_section_contents(data->output,s,buf,0,sz);
		free(buf);
	}
}

void main()
{
  bfd *infile;

  infile = bfd_openr("a.out",NULL);
//!=NULL

//You need to call bfd_check_format() on each element in the archive before attempting to process it
//example bfd_get_symtab_upper_bound will SIGSEGV
bfd_check_format(infile,bfd_object);
//true

bfd*outfile = bfd_openw("b.out",NULL);

//!=NULL

int format=bfd_get_format(infile);
bfd_set_format(outfile,format);

int arch=bfd_get_arch(infile);
int mach=bfd_get_mach(infile);
bfd_set_arch_mach(outfile,arch,mach);

bfd_set_file_flags(outfile,bfd_get_file_flags(infile));//&bfd_applicable_file_flags(outfile)

bfd_set_start_address(outfile,bfd_get_start_address(infile));

bfd_map_over_sections(infile,define_section,outfile);

/*asymbol *new;
new = bfd_make_empty_symbol(abfd);
new->name = "dummy_symbol";
new->section = bfd_get_section_by_name(abfd, ".text");
new->flags = BSF_GLOBAL;
new->value = 0x12345;
*/
long storage_needed = bfd_get_symtab_upper_bound(infile);
//storage_needed+=sizeof(asymbol*);
asymbol **syms= malloc(storage_needed);
//!=NULL

long count=bfd_canonicalize_symtab(infile, syms);

//count++;

  bfd_set_symtab(outfile, syms, count);

COPYDATA dt;dt.output=outfile;dt.syms=syms;
//dt.sz_syms=storage_needed;dt.count_syms=count;
bfd_map_over_sections(infile,copy_section,&dt);

bfd_copy_private_bfd_data(infile,outfile);

  bfd_close(infile);
  bfd_close(outfile);

}
