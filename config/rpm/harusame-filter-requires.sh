#!/bin/sh

"$@" |
  awk '
	$0 !~ /^perl\(Error\)/ &&
	$0 !~ /^perl\(Error::/ &&
	$0 !~ /^perl\(Char::/ &&
	$0 !~ /^perl\(CGI::/ &&
	$0 !~ /^perl\(SuikaWiki::/ &&
	$0 !~ /^perl\(Whatpm::/ &&
	$0 !~ /^perl\(Message::/
  '
