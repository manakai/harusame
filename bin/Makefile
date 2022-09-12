SED = sed
POD2HTML = pod2html --css "https://suika.suikawiki.org/www/style/html/pod.css" \
  --htmlroot "../../manakai-core/lib/"

all: build

build: harusame.html

harusame.html: harusame.pl
	$(POD2HTML) $< | $(SED) -e 's/<link rev="made" href="mailto:[^"]\+" \/>/<link rel=author href="#AUTHOR">/' > $@

## License: Public Domain.
