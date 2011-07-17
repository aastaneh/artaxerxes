#!/usr/bin/perl
use strict;
use warnings;
use SOAP::Lite;
use Config::Simple;
use Digest::MD5 qw(md5 md5_hex md5_base64);

my $cfg = new Config::Simple($ENV{"HOME"} . '/.azclientrc');

my $soap = SOAP::Lite
  -> uri($cfg->param('URI'))
  -> proxy($cfg->param('PROXY'));

if (($#ARGV + 1) != 2) {
	print "Usage: createacct address password\n";
	exit 1;
}

my $address  =$ARGV[0];
my $password =$ARGV[1];

my $hash = md5_hex($password);

my @params = ($address, $hash);

my $result = $soap->createacct(@params);

if ($result->result == 0) {
print $result->paramsout . "\n";
exit 1;
}
exit 0;

