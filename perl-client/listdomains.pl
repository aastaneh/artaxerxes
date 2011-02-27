#!/usr/bin/perl
use SOAP::Lite;

my $soap = SOAP::Lite
  -> uri('http://localhost/Xerxes')
  -> proxy('http://localhost:8080');

my $arg = $ARGV[0];
$result = $soap->listdomains($arg);

if ($result->result == 0) {
print $result->paramsout . "\n";
exit 1;
}

@array = @{$result->paramsout};

foreach my $domain (@array) {
	print "$domain\n";
}

