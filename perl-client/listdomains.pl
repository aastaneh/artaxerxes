#!/usr/bin/perl -w
use strict;
use warnings;
use SOAP::Lite;
use Config::Simple;

my $cfg = new Config::Simple($ENV{"HOME"} . '/.azclientrc');

my $soap = SOAP::Lite
  -> uri($cfg->param('URI'))
  -> proxy($cfg->param('PROXY'));

my $arg = $ARGV[0];
my $result = $soap->listdomains($arg);

if ($result->result == 0) {
print $result->paramsout . "\n";
exit 1;
}

my @array = @{$result->paramsout};

foreach my $domain (@array) {
	print "$domain\n";
}

