#!/usr/bin/perl
use SOAP::Lite;

my $soap = SOAP::Lite
  -> uri('http://localhost/Xerxes')
  -> proxy('http://localhost:8080');

my $arg ='test.com';
$result = $soap->listdomains();

@array = @{$result->paramsout};

foreach my $domain (@array) {
	print "$domain\n";
}
