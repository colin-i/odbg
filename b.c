
#include "bfd.h"

//.dynsym .rela.dyn .dynstr .text
//Entry point address
//objcopy -O binary --only-section=.text foobar.elf foobar.text
//objcopy f --update-section .text=foobar.text

#include <stdlib.h>

static void define_section(bfd*infile,asection*sec,void* data){
}
static void copy_section(bfd*infile,asection*sec,void* data){
}

void main()
{
  bfd *infile;

  infile = bfd_openr("a.out",NULL);
//!=NULL

bfd_check_format(infile,bfd_object);
//true

bfd*outfile = bfd_openw("b.out",NULL);

//!=NULL

bfd_set_format(outfile,bfd_get_format(infile));

bfd_set_arch_mach(outfile,bfd_get_arch(infile),bfd_get_mach(infile));

bfd_set_file_flags(outfile,bfd_get_file_flags(infile)&bfd_applicable_file_flags(outfile));

bfd_set_start_address(outfile,bfd_get_start_address(infile));

bfd_map_over_sections(infile,define_section,NULL);

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

long count=bfd_canonicalize_symtab(infile, syms);

//count++;

  bfd_set_symtab(outfile, syms, count);

bfd_map_over_sections(infile,copy_section,NULL);

bfd_copy_private_bfd_data(infile,outfile);

  bfd_close(infile);
  bfd_close(outfile);

}
