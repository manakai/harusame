#!/usr/bin/perl
use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->subdir ('modules')->subdir ('*')->subdir ('lib');

use Getopt::Long;
use Pod::Usage;

my $lang;

GetOptions (
  'lang=s' => \$lang,
  'help' => sub {
    pod2usage (-exitval => 0, -verbose => 2);
  },
) or pod2usage (-exitval => 1, -verbose => 1);

pod2usage (-exitval => 1, -verbose => 1,
           -msg => "Required argument --lang is not specified.\n")
      unless defined $lang;
$lang =~ tr/A-Z/a-z/; ## ASCII case-insensitive.

sub get_content_element ($) {
  my $container = shift;
  
  my $c_el;
  for my $e (@{$container->child_nodes}) {
    next unless $e->node_type == $e->ELEMENT_NODE;
    my $e_lang = $e->manakai_html_language;
    $e_lang =~ tr/A-Z/a-z/; ## ASCII case-insensitive.
    if ($e_lang eq $lang) {
      $c_el = $e;
      last;
    } else {
      $c_el ||= $e;
    }
  }
  
  return $c_el;
} # get_content_element

require Message::DOM::DOMImplementation;
my $dom = Message::DOM::DOMImplementation->new;

my $doc = $dom->create_document;
$doc->manakai_is_html (1);

{
  binmode STDIN, ':encoding(utf8)';
  local $/ = undef;
  $doc->inner_html (scalar <STDIN>);
}

my @remove;

my $containers = $doc->query_selector_all
    ('[data-lang-container], [data-lang-content]');
for my $el (@$containers) {
  next unless $el->parent_node;

  if ($el->has_attribute ('data-lang-container')) {
    my $content = get_content_element ($el);
    next unless $content;
    if ($el->get_attribute ('data-lang-container') eq 'replace') {
      $el->parent_node->replace_child ($content, $el);
    } else {
      $el->text_content ('');
      $el->append_child ($content);
    }
  } elsif ($el->has_attribute ('data-lang-content')) {
    my $idref = $el->get_attribute ('data-lang-content');
    my $container = $doc->get_element_by_id ($idref);
    unless ($container) {
      warn "Element with ID $idref not found\n";
      next;
    }

    my $content = get_content_element ($container);
    $el->text_content ($content->text_content);
    $el->manakai_html_language ($content->manakai_html_language);
    
    if ($container->has_attribute ('data-lang-declaration')) {
      push @remove, $container;
    }
  }
}

for (@remove) {
  next unless $_->parent_node;
  $_->parent_node->remove_child ($_);
}

$doc->document_element->manakai_html_language ($lang);

binmode STDOUT, ':encoding(utf8)';
print STDOUT $doc->inner_html;

__END__

=head1 NAME

harusame - Multilingual Web page management tool

=head1 SYNOPSIS

  perl harusame.pl --lang LANGCODE < input.html > output.html

  perl harusame.pl --help

=head1 DESCRIPTION

The C<harusame.pl> script extracts a version of the HTML document
written in the specified natural language, from a source HTML document
that contains paragraphs in multiple natural languages.

The document management of a multilingual Web site where there are
multiple versions of a (conceptually same) document is somewhat
difficult in general.  If the author of an HTML document wants to edit
a part of the document, then he or she has to ensure not to forget
updating translations at the same time, otherwise documents in
different language versions also differ in their content versions.

Using the C<harusame.pl>, one can generate versions of an HTML
document in different language from one source HTML document that
contains paragraphs written in all of those languages, such that
authors no longer have to manage different content versions and
different language versions in separate files.

=head1 ARGUMENTS

The source document must be provided to the script using the
I<standard input>.  It must be encoded in UTF-8.

The script outputs the generated document encoded in UTF-8 to the
I<standard output>.

Following command-line options are available to this script:

=over 4

=item C<--help>

Show the help message and exit.

=item C<--lang I<LANGCODE>> (B<REQUIRED>)

The language of the version to generate.  This option must be
specified.  The value must be a value that is valid for HTML
C<lang=""> attribute.

=back

=head1 SEE ALSO

Readme L<http://suika.fam.cx/www/harusame/readme>.  How to mark up the
source HTML document is described in this document.

=head1 AUTHOR

Wakaba <w@suika.fam.cx>.

=head1 LICENSE

Copyright 2008, 2010 Wakaba <w@suika.fam.cx>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
