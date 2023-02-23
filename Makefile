
TOPTARGETS := all install clean distclean uninstall test

SUBDIRS := osrc src

$(TOPTARGETS): $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)
.PHONY: $(TOPTARGETS) $(SUBDIRS)

#all:
#	@echo

#.NOTPARALLEL:
