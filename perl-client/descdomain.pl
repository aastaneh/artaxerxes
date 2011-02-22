#!/usr/bin/perl
use SOAP::Lite;

my $soap = SOAP::Lite
  -> uri('http://localhost/Xerxes')
  -> proxy('http://localhost:8080');

$result = $soap->getdomainattributes('test.com');

%hash = %{$result->paramsout};

while ( my ($key, $value) = each(%hash) ) {
        print "$key => $value\n";
}

