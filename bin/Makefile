POD2HTML = pod2html --css "http://suika.fam.cx/www/style/html/pod.css" \
  --htmlroot "../../manakai-core/lib/"

all: harusame.html

harusame.html: harusame.pl
	$(POD2HTML) $< > $@

## $Date: 2008/10/21 10:14:26 $
## License: Public Domain.
