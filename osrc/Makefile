
ifndef OCOMP
OCOMP=o
endif

ifndef OLINK
OLINK=ounused
endif

ifndef linkerflags
linkerflags=-O3 -s
#-O (same as actionswf)
endif

name=libodbg.so
outname=/lib/${name}
exte=libexte.a
prebin=pre.out
#there is a.out in pre.out run

all: ${name}

precompile = elf

items = init
aritems = init1 init2 init3

$(foreach var,$(precompile),$(eval pre += ${var}.h))
$(foreach var,$(aritems),$(eval aobs += ${var}.o))
$(foreach var,$(aritems),$(eval alogs += ${var}.oc.log))
$(foreach var,$(items),$(eval obs += ${var}.o))
$(foreach var,$(items),$(eval logs += ${var}.oc.log))

${name}: ${exte} ${obs}
	${OLINK} ${alogs} ${logs}
	@echo
	$(CC) ${linkerflags} ${obs} -shared -o ${name} -L. -l:${exte} -Wl,--exclude-libs ${exte}

${exte}: ${prebin} ${pre} ${aobs}
	$(AR) cr ${exte} ${aobs}

${prebin}:
	$(CC) a.c -o ${prebin}

%.h: %.pre
	#./${prebin} $^ $*
	./${prebin} $^ $@

%.o: %.oc
	${OCOMP} $< ${OFLAGS}

install: all
	install -D ${name} \
		$(DESTDIR)$(prefix)${outname}

clean-compile:
	-rm -f ${prebin}
	-rm -f ${pre}
	-rm -f ${aobs}
	-rm -f ${alogs}
	-rm -f ${obs}
	-rm -f ${logs}

clean-link:
	-rm -f ${exte}
	-rm -f ${name}

clean: clean-compile clean-link
distclean: clean

uninstall:
	-rm -f $(DESTDIR)$(prefix)${outname}

test:
	echo "Nothing"

.PHONY: all install clean clean-compile clean-link distclean uninstall test

#.NOTPARALLEL:
