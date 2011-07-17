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
	print "Usage: deleteacct email\n";
	exit 1;
}

my $email =$ARGV[0];
my $result = $soap->deleteacct($email);
if ($result->result == 0) {
print $result->paramsout . "\n";
exit 1;
}
exit 0;
