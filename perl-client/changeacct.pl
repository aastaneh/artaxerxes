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

if (($#ARGV + 1) != 3) {
	print "Usage: changeacct address attribute value\n";
	exit 1;
}

my $address  = $ARGV[0];
my $attribute = $ARGV[1];
my $value = $ARGV[2];


my @params = ($address, $attribute, $value);

my $result = $soap->setacctattributes(@params);

if ($result->result == 0) {
print $result->paramsout . "\n";
exit 1;
}
exit 0;

