#!/usr/bin/perl
use SOAP::Lite;

my $soap = SOAP::Lite
  -> uri('http://localhost/Xerxes')
  -> proxy('http://localhost:8080');

if (($#ARGV + 1) != 3) {
	print "Usage: changeacct address attribute value\n";
	exit 1;
}

my $address  = $ARGV[0];
my $attribute = $ARGV[1];
my $value = $ARGV[2];


my @params = ($address, $attribute, $value);

$result = $soap->setacctattributes(@params);

if ($result->result == 0) {
print $result->paramsout . "\n";
exit 1;
}
exit 0;

