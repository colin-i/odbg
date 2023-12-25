
ifndef OCOMP
OCOMP=o
endif

ifndef OLINK
OLINK=ounused
endif

ifndef linkerflags
linkerflags=-O3 -s
#             1
endif

all: odbg

items = main

$(foreach var,$(items),$(eval obs += ${var}.o))
$(foreach var,$(items),$(eval logs += ${var}.oc.log))

odbg: ${obs}
	${OLINK} ${logs}
	@echo
	$(CC) ${linkerflags} ${obs} -o odbg -lopython -L../osrc -lodbg

%.o: %.oc
	${OCOMP} $< ${OFLAGS}

install: all
	install -D odbg \
		$(DESTDIR)$(prefix)/bin/odbg

clean-compile:
	-rm -f ${logs}
	-rm -f ${obs}

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
