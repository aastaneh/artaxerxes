#!/usr/bin/perl
use SOAP::Lite;

my $soap = SOAP::Lite
  -> uri('http://localhost/Xerxes')
  -> proxy('http://localhost:8080');

if (($#ARGV + 1) != 1) {
	print "Usage: deletedomain domain\n";
	exit 1;
}

my $name =$ARGV[0];
$result = $soap->deletedomain($name);

