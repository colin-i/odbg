
ifndef OCOMP
OCOMP=o
endif

ifndef OLINK
OLINK=ounused
endif

ifndef linkerflags
linkerflags=-O3 -s
endif

name = odbgbot

all: ${name}

items = main

$(foreach var,$(items),$(eval obs += ${var}.o))
$(foreach var,$(items),$(eval logs += ${var}.oc.log))

${name}: ${obs}
	${OLINK} ${logs}
	@echo
	$(CC) ${linkerflags} ${obs} -o ${name}

%.o: %.oc
	${OCOMP} $< ${OFLAGS}

install: all
	install -D ${name} \
		$(DESTDIR)$(prefix)/bin/${name}

clean-compile:
	-rm -f ${logs}
	-rm -f ${obs}

clean-link:
	-rm -f ${name}

clean: clean-compile clean-link
distclean: clean

uninstall:
	-rm -f $(DESTDIR)$(prefix)/bin/${name}

test:
	echo "Nothing"

.PHONY: all install clean clean-compile clean-link distclean uninstall test

#.NOTPARALLEL:
