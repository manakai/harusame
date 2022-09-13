all: build

WGET = wget
CURL = curl
GIT = git

updatenightly: local/bin/pmbp.pl
	$(CURL) -s -S -L https://gist.githubusercontent.com/wakaba/34a71d3137a52abb562d/raw/gistfile1.txt | sh
	$(GIT) add modules
	perl local/bin/pmbp.pl --update
	$(GIT) add config
	$(CURL) -sSLf https://raw.githubusercontent.com/wakaba/ciconfig/master/ciconfig | RUN_GIT=1 REMOVE_UNUSED=1 perl

## ------ Setup ------

deps: git-submodules pmbp-install

git-submodules:
	$(GIT) submodule update --init

PMBP_OPTIONS=

local/bin/pmbp.pl:
	mkdir -p local/bin
	$(CURL) -s -S -L https://raw.githubusercontent.com/wakaba/perl-setupenv/master/bin/pmbp.pl > $@
pmbp-upgrade: local/bin/pmbp.pl
	perl local/bin/pmbp.pl $(PMBP_OPTIONS) --update-pmbp-pl
pmbp-update: git-submodules pmbp-upgrade
	perl local/bin/pmbp.pl $(PMBP_OPTIONS) --update
pmbp-install: pmbp-upgrade
	perl local/bin/pmbp.pl $(PMBP_OPTIONS) --install \
            --create-perl-command-shortcut @perl \
            --create-perl-command-shortcut @prove

## ------ Build ------

PERL = ./perl
HARUSAME = ./harusame
P2H = local/p2h

build: deps build-harusame build-docs build-bin

build-bin: $(P2H)
	cd bin && $(MAKE) build

build-docs: readme.en.html readme.ja.html

%.en.html: %.html.src $(HARUSAME)
	$(HARUSAME) --lang en < $< > $@
%.ja.html: %.html.src $(HARUSAME)
	$(HARUSAME) --lang ja < $< > $@

build-harusame: deps-fatpack $(HARUSAME)

deps-fatpack:
	$(PERL) local/bin/pmbp.pl $(PMBP_OPTIONS) \
	    --install-module App::FatPacker \
	    --create-perl-command-shortcut @local/fatpack=fatpack

## For modules that have .packlist
local/fatpacker.trace: bin/harusame.pl
	local/fatpack trace --to=$@ bin/harusame.pl
## For the other modules
local/module-list.sh: bin/create-module-list.pl bin/harusame.pl
	$(PERL) $< > $@
local/fatpacker.packlists: local/fatpacker.trace
	local/fatpack packlists-for `cat $<` > $@

PERL_ARCHNAME = $(shell $(PERL) -MConfig -e 'print $$Config{archname}')

local/fatlib-files: local/fatpacker.packlists local/module-list.sh
	cd local && ./fatpack tree `cat ../local/fatpacker.packlists`
	bash local/module-list.sh
	cp -a local/fatlib/$(PERL_ARCHNAME)/* local/fatlib/
	rm -fr local/fatlib/$(PERL_ARCHNAME)
	rm -fr local/fatlib/Encode.pm local/fatlib/Encode/
	rm -fr local/fatlib/auto/Encode/
	ls -R local/fatlib

$(HARUSAME): bin/harusame.pl local/fatlib-files
	echo '#!/usr/bin/env perl' > $@
	cd local && ./fatpack file ../$< >> ../$@
	-git diff harusame | cat
	perl -c $@
	chmod u+x $@

local/p2h:
	$(CURL) -sSfL https://raw.githubusercontent.com/manakai/manakai.github.io/master/p2h > $@
	chmod u+x $@

## ------ Tests ------

PROVE = ./prove

test: test-deps test-main

test-deps: deps

test-main:
	$(HARUSAME) --lang ja < readme.html.src > /dev/null

## License: Public Domain
