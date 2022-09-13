SED = sed
P2H = ../local/p2h

all: build

build: harusame.html

harusame.html: harusame.pl $(P2H)
	$(P2H) Harusame $< > $@

## License: Public Domain.
