#!/usr/bin/perl
use SOAP::Lite;

my $soap = SOAP::Lite
  -> uri('http://localhost/Xerxes')
  -> proxy('http://localhost:8080');

if (($#ARGV + 1) != 1) {
        print "Usage: listaccts pattern\n";
        exit 1;
}

$domain = $ARGV[0];

$result = $soap->getdomainattributes($domain);

if ($result->result == 0) {
print $result->paramsout . "\n";
exit 1;
}

%hash = %{$result->paramsout};

while ( my ($key, $value) = each(%hash) ) {
        print "$key => $value\n";
}

exit 0;
