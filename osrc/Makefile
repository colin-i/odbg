
OCOMP=o
OLINK=ounused
syms=-s

name=libodbg.so
outname=/lib/${name}

all: ${name}

items = init

$(foreach var,$(items),$(eval obs += ${var}.o))
$(foreach var,$(items),$(eval logs += ${var}.s.log))

libodbg.so: ${obs}
	${OLINK} ${logs}
	@echo
	$(CC) ${syms} ${obs} -shared -o ${name}

%.o: %.s
	${OCOMP} $< ${OFLAGS}

install: all
	install -D ${name} \
		$(DESTDIR)$(prefix)${outname}

clean-compile:
	-printf ' %s.s.log' ${items} | xargs rm -f
	-printf ' %s.o' ${items} | xargs rm -f

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
