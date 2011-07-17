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
	print "Usage: createdomain name quota max_accounts\n";
	exit 1;
}

my $name =$ARGV[0];
my $quota =$ARGV[1];
my $maxaccts =$ARGV[2];

my @params = ($name, $quota, $maxaccts);

my $result = $soap->createdomain(@params);

if ($result->result == 0) {
print $result->paramsout . "\n";
exit 1;
}
exit 0;
