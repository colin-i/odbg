
ifndef OCOMP
OCOMP=o
endif

ifndef OLINK
OLINK=ounused
endif

ifndef syms
syms=-s
endif

all: odbg

items = main

$(foreach var,$(items),$(eval obs += ${var}.o))
$(foreach var,$(items),$(eval logs += ${var}.s.log))

odbg: ${obs}
	${OLINK} ${logs}
	@echo
	$(CC) ${syms} ${obs} -o odbg -lcdk -L../osrc -lodbg

%.o: %.s
	${OCOMP} $< ${OFLAGS}

install: all
	install -D odbg \
		$(DESTDIR)$(prefix)/bin/odbg

clean-compile:
	-printf ' %s.s.log' ${items} | xargs rm -f
	-printf ' %s.o' ${items} | xargs rm -f

clean-link:
	-rm -f odbg

clean: clean-compile clean-link
distclean: clean

uninstall:
	-rm -f $(DESTDIR)$(prefix)/bin/odbg

test:
	echo "Nothing"

.PHONY: all install clean distclean uninstall test

#.NOTPARALLEL:
