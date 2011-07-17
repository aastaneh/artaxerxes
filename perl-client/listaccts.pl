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
        print "Usage: listaccts pattern\n";
        exit 1;
}

my $arg = $ARGV[0];
my $result = $soap->listaccts($arg);

if ($result->result == 0) {
print $result->paramsout . "\n";
exit 1;
}

my @array = @{$result->paramsout};

foreach my $addr (@array) {
	print "$addr\n";
}

exit 0;
