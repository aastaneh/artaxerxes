#!/usr/bin/perl
use SOAP::Lite;

if (($#ARGV + 1) != 1) {
        print "Usage: listaccts pattern\n";
        exit 1;
}

my $soap = SOAP::Lite
  -> uri('http://localhost/Xerxes')
  -> proxy('http://localhost:8080');

my $arg = $ARGV[0];
$result = $soap->listaccts($arg);

@array = @{$result->paramsout};

foreach my $addr (@array) {
	print "$addr\n";
}
