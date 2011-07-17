#!/usr/bin/perl
use strict;
use warnings;
use SOAP::Lite;
use Config::Simple;

my $cfg = new Config::Simple($ENV{"HOME"} . '/.azclientrc');

my $soap = SOAP::Lite
  -> uri($cfg->param('URI'))
  -> proxy($cfg->param('PROXY'));

if (($#ARGV + 1) != 3) {
	print "Usage: changedomain domain attribute value\n";
	exit 1;
}

my $domain  = $ARGV[0];
my $attribute = $ARGV[1];
my $value = $ARGV[2];


my @params = ($domain, $attribute, $value);

my $result = $soap->setdomainattributes(@params);

if ($result->result == 0) {
print $result->paramsout . "\n";
exit 1;
}
exit 0;

