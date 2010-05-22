HARUSAME_DIR = ./
HARUSAME_BIN_DIR = $(HARUSAME_DIR)bin/
HARUSAME = $(HARUSAME_BIN_DIR)harusame.pl

PERL_ = perl
PERL_INC_OPTIONS = 
PERL = $(PERL_) $(PERL_INC_OPTIONS)

all: readme.en.html readme.ja.html

%.en.html: %.html.src
	$(PERL) $(HARUSAME) --lang en < $< > $@
%.ja.html: %.html.src
	$(PERL) $(HARUSAME) --lang ja < $< > $@
