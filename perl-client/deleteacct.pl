#!/usr/bin/perl
use SOAP::Lite;

my $soap = SOAP::Lite
  -> uri('http://localhost/Xerxes')
  -> proxy('http://localhost:8080');

if (($#ARGV + 1) != 1) {
	print "Usage: deleteacct email\n";
	exit 1;
}

my $email =$ARGV[0];
$result = $soap->deleteacct($email);

