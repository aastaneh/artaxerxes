#!/usr/bin/perl
use SOAP::Lite;

my $soap = SOAP::Lite
  -> uri('http://localhost/Xerxes')
  -> proxy('http://localhost:8080');

if (($#ARGV + 1) != 2) {
	print "Usage: createacct address password\n";
	exit 1;
}

my $address  =$ARGV[0];
my $password =$ARGV[1];


my @params = ($address, $password);

$result = $soap->createacct(@params);

if ($result->result == 0) {
print $result->paramsout . "\n";
exit 1;
}
exit 0;

