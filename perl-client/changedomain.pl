#!/usr/bin/perl
use SOAP::Lite;

my $soap = SOAP::Lite
  -> uri('http://localhost/Xerxes')
  -> proxy('http://localhost:8080');

if (($#ARGV + 1) != 3) {
	print "Usage: changedomain domain attribute value\n";
	exit 1;
}

my $domain  = $ARGV[0];
my $attribute = $ARGV[1];
my $value = $ARGV[2];


my @params = ($domain, $attribute, $value);

$result = $soap->setdomainattributes(@params);

if ($result->result == 0) {
print $result->paramsout . "\n";
exit 1;
}
exit 0;

