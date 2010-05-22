#!/usr/bin/perl
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile (
  NAME          => 'harusame',
  DISTNAME      => 'harusame',
  VERSION       => '20100522',
  ABSTRACT_FROM => 'bin/harusame.pl',
  PM => {
    'bin/harusame.pl' => '$(INST_SCRIPT)/harusame',
  },
  MAN1PODS => {
    'bin/harusame.pl' => 'blib/man1/harusame.1',
  },
  dist         => {COMPRESS => 'gzip', SUFFIX => '.gz'},
  AUTHOR       => q(Wakaba <w@suika.fam.cx>),
);
