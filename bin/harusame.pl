#!/usr/bin/perl
use strict;

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

use Message::DOM::DOMImplementation;
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

## $Date: 2008/10/21 08:36:59 $
