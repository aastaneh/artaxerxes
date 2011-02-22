#!/usr/bin/perl
use SOAP::Lite;

my $soap = SOAP::Lite
  -> uri('http://localhost/Xerxes')
  -> proxy('http://localhost:8080');

my $arg ='test.com';
$result = $soap->listdomains();

@array = @{$result->paramsout};

#%hash = %{$result->paramsout};

#while ( my ($key, $value) = each(%hash) ) {
#        print "$key => $value\n";
#}

foreach my $domain (@array) {
	print "$domain\n";
}
