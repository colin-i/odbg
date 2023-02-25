
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

all: ${name}

precompile = init

items = init

$(foreach var,$(precompile),$(eval pre += ${var}.h))

$(foreach var,$(items),$(eval obs += ${var}.o))
$(foreach var,$(items),$(eval logs += ${var}.s.log))

libodbg.so: a.out ${pre} ${obs}
	${OLINK} ${logs}
	@echo
	$(CC) ${syms} ${obs} -shared -o ${name}

a.out:
	$(CC) a.c

%.h: %.pre
	./a.out $^ $*

%.o: %.s
	${OCOMP} $< ${OFLAGS}

install: all
	install -D ${name} \
		$(DESTDIR)$(prefix)${outname}

clean-compile:
	-rm -f a.out
	-printf ' %s.h' ${precompile} | xargs rm -f
	-printf ' %s.o' ${items} | xargs rm -f
	-printf ' %s.s.log' ${items} | xargs rm -f

clean-link:
	-rm -f ${name}

clean: clean-compile clean-link
distclean: clean

uninstall:
	-rm -f $(DESTDIR)$(prefix)${outname}

test:
	echo "Nothing"

.PHONY: all install clean distclean uninstall test

#.NOTPARALLEL:
