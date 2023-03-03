
ifndef OCOMP
OCOMP=o
endif

ifndef OLINK
OLINK=ounused
endif

ifndef syms
syms=-s
endif

name=libodbg.so
outname=/lib/${name}
exte=libexte.a
prebin=pre.out
#prebin can't be a.out, will be removed

all: ${name}

precompile = init1

items = init
aritems = init1

$(foreach var,$(precompile),$(eval pre += ${var}.h))
$(foreach var,$(aritems),$(eval aobs += ${var}.o))
$(foreach var,$(aritems),$(eval alogs += ${var}.s.log))
$(foreach var,$(items),$(eval obs += ${var}.o))
$(foreach var,$(items),$(eval logs += ${var}.s.log))

${name}: ${exte} ${obs}
	${OLINK} ${alogs} ${logs}
	@echo
	$(CC) ${syms} ${obs} -shared -o ${name} -L. -l:${exte} -Wl,--exclude-libs ${exte}

${exte}: ${prebin} ${pre} ${aobs}
	$(AR) cr ${exte} ${aobs}

${prebin}:
	$(CC) a.c -o ${prebin}

%.h: %.pre
	./${prebin} $^ $*

%.o: %.s
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

.PHONY: all install clean distclean uninstall test

#.NOTPARALLEL:
