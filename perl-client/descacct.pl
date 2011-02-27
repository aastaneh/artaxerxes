#!/usr/bin/perl
use SOAP::Lite;

my $soap = SOAP::Lite
  -> uri('http://localhost/Xerxes')
  -> proxy('http://localhost:8080');

if (($#ARGV + 1) != 1) {
        print "Usage: descacct address\n";
        exit 1;
}

my $acct = $ARGV[0];

$result = $soap->getacctattributes($acct);

if ($result->result == 0) {
print $result->paramsout . "\n";
exit 1;
}

%hash = %{$result->paramsout};

while ( my ($key, $value) = each(%hash) ) {
        print "$key => $value\n";
}

exit 0;
