#!/bin/sh
find -name ChangeLog | xargs cvs diff | grep "^\+" | sed -e "s/^\+//; s/^\+\+ .\//++ harusame\//" > .cvslog.tmp
cvs commit -F .cvslog.tmp $1 $2 $3 $4 $5 $6 $7 $8 $9 
mkcommitfeed \
    --file-name harusame-commit.en.atom.u8 \
    --feed-url http://suika.fam.cx/www/harusame/harusame-commit \
    --feed-title "Harusame ChangeLog diffs" \
    --feed-lang en \
    --feed-related-url "http://suika.fam.cx/www/harusame/readme" \
    --feed-license-url "http://suika.fam.cx/www/harusame/readme#license" \
    --feed-rights "This feed is free software; you can redistribute it and/or modify it under the same terms as Perl itself." \
    < .cvslog.tmp
cvs commit -m "" harusame-commit.en.atom.u8
rm .cvslog.tmp

## $Date: 2008/11/24 07:14:37 $
## License: Public Domain
