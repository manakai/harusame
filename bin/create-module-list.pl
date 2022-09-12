use strict;
use warnings;
use Path::Tiny;

{
  use Message::DOM::DOMImplementation;
  my $dom = Message::DOM::DOMImplementation->new;
  my $doc = $dom->create_document;
  $doc->query_selector ('dummy');
  $doc->inner_html (q{<!DOCTYPE p><p y=""><![CDATA[x]]>o</p><!----><?x?>});
  scalar $doc->inner_html;
  $doc->manakai_is_html (1);
  $doc->inner_html (q{<!DOCTYPE p><p y=""><![CDATA[x]]>o</p><!----><?x?>});
  scalar $doc->inner_html;
}

my $RootPath = path (__FILE__)->parent->parent->absolute;

my $pattern = join '|', map { "\Q$_\E" }
    $RootPath->child ('lib'),
    (glob $RootPath->child ('modules/*/lib')),
    (glob $RootPath->child ('local/perl-*/pm/lib/perl5'));

my $dest = q{local/fatlib};
print qq{#!/bin/bash\x0A};
print qq{set -eo pipefail\x0A};
my $dirs = {};
my $cp_files = join "", sort { $a cmp $b } map {
  my $abs_path = $_;
  my $rel_path = $abs_path;
  $rel_path =~ s{^(?:$pattern)/}{};
  my $dir = $rel_path;
  $dir =~ s{[^/]*$}{};
  $dirs->{$dir} = 1;
  "cp \Q$abs_path\E \Q$dest/$rel_path\E\x0A";
} grep { m{^(?:$pattern)/} } values %INC;
delete $dirs->{''};
print join '', map { "mkdir -p \Q$dest/$_\E\x0A" } sort { $a cmp $b } keys %$dirs;
print $cp_files;

=head1 LICENSE

Copyright 2022 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
