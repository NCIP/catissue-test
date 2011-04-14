#!/usr/bin/perl
#package caTIES_DB_Utilities;

use strict;
use warnings;
use DBI;

########################################################################################
# Funcation Name	: db_connect
# Description		: connects to caTissue DB
# Arguments		: $database_type,$database_host,$database_name,$database_port,
#					   $database_username,$database_password,$oracle_tns_name
# Return Values		: database connectivity
#########################################################################################

sub db_connect {
    my $db_type         = $_[0];
    my $db_host         = $_[1];
    my $db_port         = $_[2];
    my $db_name         = $_[3];
    my $db_user         = $_[4];
    my $db_password     = $_[5];
    my $oracle_tns_name = $_[6];
    my ( $dbh, $drh, $dsn );

    
    if ( $db_type eq 'oracle' ) {
        $dbh = DBI->connect( "dbi:Oracle:host=$db_host;sid=$db_name;port=$db_port",
            $db_user, $db_password )
          or die "\nCould not Connect to database:!", DBI->errstr;
        $drh = DBI->install_driver("Oracle");
    }
    elsif ( $db_type eq 'mysql' ) {
        $dsn = "dbi:mysql:$db_name;$db_host;$db_port";
        $dbh = DBI->connect( $dsn, $db_user, $db_password )
          or die "\nCould not Connect to database:!", DBI->errstr;
        $drh = DBI->install_driver("mysql");
    }
    else {
        die("\nInvalid Database type!");
    }

    return ($dbh);
}

1;