RPMBUILD = rpmbuild
RPM_DIR = `$(RPMBUILD) --eval '%{_topdir}' harusame.spec`

HARUSAME_TARBALL_DIR = ../../
HARUSAME_TARBALL_NAME = harusame-20100522.tar.gz
HARUSAME_TARBALL = $(HARUSAME_TARBALL_DIR)$(HARUSAME_TARBALL_NAME)

all:

$(HARUSAME_TARBALL_DIR)/Makefile: $(HARUSAME_TARBALL_DIR)/Makefile.PL
	cd $(HARUSAME_TARBALL_DIR) && perl Makefile.PL

$(HARUSAME_TARBALL): $(HARUSAME_TARBALL_DIR)/Makefile
	rm -fv $(HARUSAME_TARBALL)
	cd $(HARUSAME_TARBALL_DIR) && make dist

copy: $(HARUSAME_TARBALL) harusame.spec harusame-filter-requires.sh
	cp $(HARUSAME_TARBALL) $(RPM_DIR)/SOURCES/$(HARUSAME_TARBALL_NAME)
	cp harusame.spec $(RPM_DIR)/SPECS/harusame.spec
	cp harusame-filter-requires.sh $(RPM_DIR)/SOURCES/harusame-filter-requires.sh

build: copy
	cd $(RPM_DIR) && rpmbuild -ba SPECS/harusame.spec

## License: Public Domain.
