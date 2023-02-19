
OCOMP=o
OLINK=ounused
syms=-s

all: odbg

items = main

$(foreach var,$(items),$(eval obs += ${var}.o))
$(foreach var,$(items),$(eval logs += ${var}.s.log))

odbg: ${obs}
	${OLINK} ${logs}
	@echo
	$(CC) ${syms} ${obs} -o odbg -lcdk -lc

%.o: %.s
	${OCOMP} $< ${OFLAGS}

install: all
	install -D ostrip \
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
