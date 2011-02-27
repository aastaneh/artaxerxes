#!/usr/bin/perl -w
use SOAP::Transport::HTTP;
use strict;
use warnings;
use Switch;
use Cyrus::IMAP::Admin;
use DBI;
use DBD::mysql;
#################################################
# server.pl - Artaxerxes SOAP daemon
#
# Amin Astaneh
# amin@aminastaneh.net
#################################################

BEGIN { require "config.pl"; }

# Connect to MySQL 
my $dsn = "dbi:mysql:$dbname:$dbhost:3306";
my $dbhandle = DBI->connect($dsn, $dbuser, $dbpass) or die "Unable to connect: $DBI::errstr\n";
$dbhandle->{mysql_auto_reconnect} = 1;

# Authenticate to the IMAP server
my $imap = Cyrus::IMAP::Admin->new($mailhost) || die "Unable to connect to $mailhost";

if (! $imap) {
        die "Error creating IMAP connection object\n";
}
$imap->authenticate(
	-user => $mailadminuser,
	-mechanism => "PLAIN",
	-password => $mailadminpass,
) || die "Authentication Failure";

my $daemon = SOAP::Transport::HTTP::Daemon
 -> new (LocalPort => 8080,
         Reuse     => 1)
 -> dispatch_to('Xerxes')        
;

$daemon->handle;

##############################
# Begin Functions
##############################

sub END {
	if (defined $dbhandle){
		$dbhandle->do("UNLOCK TABLES");
		$dbhandle->disconnect;
	}
}

package Xerxes;

sub listaccts {
	my ($class, $pattern) = @_;
	my @userlist;
	my $query = "SELECT addr from acct where addr LIKE " . 
                    "'%" . $pattern . "%' AND addr != 'cyrus'";
        my $sth = $dbhandle->prepare($query);
        $sth->execute();
        while (my $result = $sth->fetchrow_hashref()) {
                push (@userlist, $result->{addr});
        }
	
	return (1, \@userlist);
}

sub listdomains {
	my @domainlist;
	my $query = "SELECT name from domain";
	my $sth = $dbhandle->prepare($query);
	$sth->execute();
	while (my $result = $sth->fetchrow_hashref()) {
		push (@domainlist, $result->{name});
	}
	return (1, \@domainlist);
}

sub getdomainattributes {
	my ($class, $domain) = @_;
	my $query = "SELECT * FROM domain WHERE name = '$domain'";
	my $sth = $dbhandle->prepare($query);
        $sth->execute();
	if ($sth->rows == 0){
                return (0, "ERROR: Domain $domain not present.");
        }
	my $result = $sth->fetchrow_hashref();
	my %attr = ( 'id'       => $result->{id},
		     'name'     => $result->{name},
		     'quota'    => $result->{quota},
		     'max_acct' => $result->{max_acct},
		     'active'   => $result->{active}
        );

	return (1,\%attr);
}

sub createdomain {
	use Regexp::Common qw /net/;
	my ($class, $name, $quota, $maxaccts) = @_;
	if ($name !~ /(?! )$RE{net}{domain}/){
		return (0, "Error: Domain must be a valid hostname.");
	}
	my $query = "INSERT INTO domain (name, quota, max_acct) VALUES ('$name', '$quota', '$maxaccts')";
	my $sth = $dbhandle->prepare($query);
        $sth->execute();
	return (1, "OK");

	# FIXME: Verify the domain was created.
}

sub deletedomain {
	my ($class, $domain) = @_;
	my $userquery = "SELECT acct.addr as addr from acct, domain where " .
                        "domain.id = acct.domain and domain.name = '$domain'";
	my $sth = $dbhandle->prepare($userquery);
        $sth->execute();
        while (my $result = $sth->fetchrow_hashref()) {
                deleteacct(undef, $result->{addr});
        }
	my $query = "DELETE FROM domain WHERE name = '$domain'";
        $sth = $dbhandle->prepare($query);
        $sth->execute();

	# FIXME: Verify the domain is deleted.
	# FIXME: Verify all accounts are deleted
	return (1, "OK");
}

sub createacct {
	my ($class, $address, $password) = @_;

	my ($acct, $domain) = split("@", $address);

	# Does this account exist already?	
	my $addrquery = "SELECT COUNT(id) as count FROM acct WHERE addr = '$address'";
	my $sth = $dbhandle->prepare($addrquery);
        $sth->execute();
	my $result = $sth->fetchrow_hashref();
	if ($result->{count} > 0){
		return (0, "ERROR: Account $address already exists.");
	}
	
	# Does the domain exist?
	my $domainquery = "SELECT id, quota, max_acct from domain where name = '$domain'";
	$sth = $dbhandle->prepare($domainquery);
        $sth->execute();
	if ($sth->rows == 0){
                return (0, "ERROR: Domain $domain not present.");
        }
	$result = $sth->fetchrow_hashref();
	my $domainid = $result->{id};
	my $quota = $result->{quota};
	my $max_acct = $result->{max_acct};

	# Are we over our account limit?
	my $countquery = "SELECT id FROM acct where acct.domain = '$domainid'";
	
	$sth = $dbhandle->prepare($countquery);
        $sth->execute();
	if ($sth->rows >= $max_acct){
        	return (0, "ERROR: Max Accounts Reached for this Domain.");
	}

	my $query = "INSERT INTO acct (addr, domain, quota, password) " . 
                    "VALUES ('$address', '$domainid', '$quota', '$password')";
        $sth = $dbhandle->prepare($query);
        $sth->execute();
	$imap->create("user/$address");

	# FIXME: Verify the account was created
	# FIXME: Add one-way hashing function for password storage. (SHA2)
	return (1, "OK");
}

sub deleteacct {
	my ($class, $addr) = @_;
	my $fullname = "user/" . $addr;
	my $query = "DELETE FROM acct WHERE addr = '$addr'";
        my $sth = $dbhandle->prepare($query);
        $sth->execute();
	$imap->setacl("$fullname", 'cyrus' =>  'all');
	$imap->delete("$fullname");

	# FIXME: Verify the account was deleted
	return (1, "OK");
}

sub setdomainattributes {
	my ($class, $domain, $attr, $val) = @_;

	# Verify domain exists
	my $domainquery = "SELECT name FROM domain WHERE name ='$domain'";
	my $sth = $dbhandle->prepare($domainquery);
        $sth->execute();
	if ($sth->rows == 0){
                return (0, "ERROR: Domain $domain not present.");
        }
	
	# Validate inputs
	switch ($attr) {
		case "quota"{
			if (($val =~ /\D/) || ($val <= 0 )) {
				return (0, "ERROR: Domain attribute quota can only be a positive integer.");
			}
		}
		case "max_acct"{
			if (($val =~ /\D/) || ($val <= 0 )) {
                                return (0, "ERROR: Domain attribute max_acct can only be a positive integer.");
                        }
		}
		case "active" {
			if (($val != 0) && ($val != 1)){
				return (0, "ERROR: Domain attribute active can only be 1 (true) or 0 (false).");
			} 
		}
		case "name" {
			return (0, "ERROR: Domain attribute name cannot be changed.");
		}
		else {
			return (0, "ERROR: No such domain attribute.");
		}
	}	

	my $query = "UPDATE domain SET $attr = '$val' WHERE name = '$domain'";
        $sth = $dbhandle->prepare($query);
        $sth->execute();
	return (1, "OK");
}

sub getacctattributes {
        my ($class, $addr) = @_;
        my $query = "SELECT * FROM acct WHERE addr = '$addr'";
        my $sth = $dbhandle->prepare($query);
        $sth->execute();
        if ($sth->rows == 0){
                return (0, "ERROR: Account $addr not present.");
        }
        my $result = $sth->fetchrow_hashref();
        my %attr = ( 'id'       => $result->{id},
                     'addr'     => $result->{addr},
                     'quota'    => $result->{quota},
                     'active'   => $result->{active}
        );

        return (1,\%attr);
}

sub setacctattributes {
        my ($class, $addr, $attr, $val) = @_;

        # Verify domain exists
        my $acctquery = "SELECT addr FROM acct WHERE addr ='$addr'";
        my $sth = $dbhandle->prepare($acctquery);
        $sth->execute();
        if ($sth->rows == 0){
                return (0, "ERROR: Account $addr not present.");
        }

        # Validate inputs
        switch ($attr) {
                case "quota"{
                        if (($val !~ /^\d+$/) || ($val <= 0 )) {
                                return (0, "ERROR: Account attribute quota can only be a positive integer.");
                        }
                }
                case "password"{
			# somehow validate this
                }
                case "active" {
                        if (($val != 0) && ($val != 1)){
                                return (0, "ERROR: Account attribute active can only be 1 (true) or 0 (false).");
                        }
                }
                else {
                        return (0, "ERROR: Account attribute cannot be changed or no such account attribute");
                }
        }

        my $query = "UPDATE acct SET $attr = '$val' WHERE addr = '$addr'";
        $sth = $dbhandle->prepare($query);
        $sth->execute();
        return (1, "OK");
}

# Functions yet to be implemented

# createforward
# listforwards
# deleteforward

##############################
# End Functions
##############################
