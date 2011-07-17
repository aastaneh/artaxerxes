#!/usr/bin/perl
use strict;
use warnings;
use SOAP::Lite;
use Config::Simple;

my $cfg = new Config::Simple($ENV{"HOME"} . '/.azclientrc');

my $soap = SOAP::Lite
  -> uri($cfg->param('URI'))
  -> proxy($cfg->param('PROXY'));

if (($#ARGV + 1) != 1) {
	print "Usage: deletedomain domain\n";
	exit 1;
}

my $name =$ARGV[0];
my $result = $soap->deletedomain($name);

if ($result->result == 0) {
print $result->paramsout . "\n";
exit 1;
}
exit 0;
