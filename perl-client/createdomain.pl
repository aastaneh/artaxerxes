#!/usr/bin/perl
use SOAP::Lite;

my $soap = SOAP::Lite
  -> uri('http://localhost/Xerxes')
  -> proxy('http://localhost:8080');

if (($#ARGV + 1) != 3) {
	print "Usage: createdomain name quota max_accounts\n";
	exit 1;
}

my $name =$ARGV[0];
my $quota =$ARGV[1];
my $maxaccts =$ARGV[2];

my @params = ($name, $quota, $maxaccts);

$result = $soap->createdomain(@params);

if ($result->result == 0) {
print $result->paramsout . "\n";
exit 1;
}
exit 0;
