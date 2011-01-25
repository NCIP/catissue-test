#!/usr/bin/perl
#package BO_DB_Utilities;

use strict;
use warnings;
use DBI;

########################################################################################
# Funcation Name	: db_connect
# Description		:
# Arguments			: $database_type,$database_host,$database_name,$database_port,
#					   $database_username,$database_password,$oracle_tns_name
# Return Values		: -
#########################################################################################

sub db_connect {
    my $db_type         = $_[0];
    my $db_server       = $_[1];
    my $db_name         = $_[2];
    my $db_port         = $_[3];
    my $db_user         = $_[4];
    my $db_password     = $_[5];
    my $oracle_tns_name = $_[6];
    my ( $dbh, $drh, $dsn );

    
    if ( $db_type eq 'oracle' ) {
        $dbh = DBI->connect( "dbi:Oracle:host=$db_server;sid=$db_name",
            $db_user, $db_password )
          or die "\nCould not Connect to database:!", DBI->errstr;
        $drh = DBI->install_driver("Oracle");
    }
    elsif ( $db_type eq 'mysql' ) {
        $dsn = "DBI:$db_type:database=$db_name;host=$db_server;port=$db_port";
        $dbh = DBI->connect( $dsn, $db_user, $db_password )
          or die "\nCould not Connect to database:!", DBI->errstr;
        $drh = DBI->install_driver("mysql");
    }
    else {
        die("\nInvalid Database type!");
    }

    return ($dbh);
}

########################################################################################
# Funcation Name	: db_execute_sql
# Description		:
# Arguments			:
# Return Values		: -
#########################################################################################

sub db_execute_sql {
    my $a   = $_[0];
    my $sql = $_[1];
    my $sth;
    my ( $numRows,    $scaler_row );
    my ( @result_row, @result_table );

    $sth = $a->prepare($sql);
    $sth->execute or die("could not execute query.");

    # Forming a result table in single dimentaional list
    # for example
    #			Row1 -  col_1|col_2\n
    #			Row2  - col_1|col_2\n
    # Column is separated by "|" and rows can be separted by "\n"

    while ( @result_row = $sth->fetchrow_array() ) {
        $scaler_row = join( "|", @result_row );
#print "\n$scaler_row ";
        push( @result_table, "$scaler_row\n" );

    }

    $numRows = $sth->rows;
    $sth->finish;

    #print "\nROW:@result";
    return (@result_table);
}

########################################################################################
# Funcation Name	: db_disconnect
# Description		:
# Arguments			: Database Handle
# Return Values		: -
#########################################################################################

sub db_disconnect {
    $a = $_[0];
    $a->disconnect or die("Failed to disconnect");
}

########################################################################################
# Funcation Name: get_sql_query
# Description:
# Arguments:
# Return Values:
#########################################################################################

sub get_sql_query {
    my $tc_id    = $_[0];
    my $sql_file = $_[1];
    my $i        = 0;
    my $line;
    my ( @sql_data, @tmp );

    #Reading file cotaining SQL queries

    open( FP, "$sql_file" ) or die("\nCould not open file $sql_file $!");
    $line = <FP>;    # skipping Header
                     #Extracting required SQL quries for varification
                     #print "\nTest Case ID:$tc_id";
    while ( $line = <FP> ) {
        chomp($line);

        #print "$line\n";
        @tmp = split( '\|', $line );    #Separating values by "|"
                                        #print "\nIds:$tmp[0]";
        if ( $tmp[0] eq $tc_id ) {
            $sql_data[$i] =
              $tmp[1]; #Storing SQL quries of perticular Test case into an array
            $i++;
        }
    }
    return @sql_data;

}

########################################################################################
# Funcation Name	: get_main_object_id
# Description		:
# Arguments			:
# Return Values		:
#########################################################################################

sub get_main_object_id {
    my $file_name = $_[0];
    my $header    = $_[1];
    my ( @a, $i, $length, $line );

    open( FP, $file_name ) or die("\ncould not open file $file_name $!");
    $line = <FP>;
    chomp($line);
    @a = split( ',', $line );
    $length = @a;

    #print "\nArray:",@a;

    for ( $i = $length - 1 ;
        $i >= 0 ;
        $i
        -- ) # reverse intration used as ID element is mostly expected as last column
    {
        if ( $a[$i] =~ m/$header/ ) {
            $line = <FP>;    # Reading second line
            chomp($line);
            @a = split( ',', $line );

            #print "\nArray:",@a;
            close(FP);
            return ( $a[$i] );    # Returning ID
        }

    }

    return "-1";

}

########################################################################################
# Funcation Name: prepare_sql
# Description:
# Arguments:
# Return Values:
#########################################################################################

sub prepare_sql {
    my $sql_query = $_[0];    # popping up last element from the list
    my $id        = $_[1];

    #substituting ID into SQL query
    $sql_query =~ s/\?/$id/;
    return $sql_query;
}

########################################################################################
# Funcation Name	: get_csv_column_index_list
# Description		:
# Arguments			:
# Return Values		:
#########################################################################################

sub get_csv_column_index_list {
    my $row = $_[0];
    my @column_list;
    my @csv_col_index;
    my $element;

    @column_list = split( '\|', $row );

    shift(@column_list);
    shift(@column_list);

    foreach $element (@column_list) {

        if ( $element =~ m/(\w+=\#)/ ) {
            push( @csv_col_index, $' );
        }
    }
    return (@csv_col_index);
}

########################################################################################
# Funcation Name	: db_verfication
# Description		:
# Arguments			: test case id, main Object id, Database handle, CSV file, SQL file
# Return Values		:
#########################################################################################

sub db_verfication {
    my $tc_id     = $_[0];
    my $object_id = $_[1];
    my $db_handle = $_[2];
    my $csv_file  = $_[3];
    my $sql_file  = $_[4];
    my ( $sql,      @sql_row,    @query_result, @sql_query,    $final_sql );
    my ( @csv_data, $csv_length, $csv_index,    @csv_elements, $element );
    my $result_data;
    my ( $line, @tmp, $i, $j );
    my ( $length, $found_match );
    my @column_list;
    my (
        @db_row,    $db_row_index, $db_col_index,
        @db_result, $db_max_row,   $db_max_col
    );
    my $db_chk = "Pass";
	###########################################################################################################
    # Validating function arguments
    ###########################################################################################################
	if ($tc_id eq "")
	{
		print ("\n Database Verification: Test case id is blank");
		$db_chk="N/A";
		return ($db_chk);
	 }
	if (trim($object_id) eq "")
	{ 
		print ("\n Database Verification: Object id is blank") ;
		$db_chk="N/A";
		return ($db_chk);
	
	}
	if (trim($sql_file) eq "")
	{	 
		print ("\n Database Verification: SQL file name  blank");
		$db_chk="N/A";
		return ($db_chk);
	}
	if (trim($csv_file) eq "")
	{
		print ("\n Database Verification: CSV file name blank") ;
		$db_chk="N/A";
		return ($db_chk);
	}
   if (trim($db_handle) eq "")
	{
		print ("\n Database Verification: db handle name blank");
		$db_chk="N/A";
		return ($db_chk);
	}
	
    ###########################################################################################################
    # Reading file containing SQLs
    ###########################################################################################################

    open( FP, $sql_file ) or die("could not open file $sql_file $!");
    $line = <FP>;    # skipping Header
                     #Extracting required SQL quries for varification
                     #print "\nTest Case ID:$tc_id";
    while ( $line = <FP> ) {
        chomp($line);
		# Ignore SQL query if it starts with '#'.'#' symbol can used to commentout SQL Query
		next if ( $line =~ m/^\s*#/); 

		# Ignore Blank line 
		next if ( $line =~ m/^$/);

        #print "$line\n";
        @tmp = split( '\|', $line );    #Separating values by "|"
                                        #print "\nIds:$tmp[0]";
        if ( $tmp[0] eq $tc_id ) {
            $sql_query[$i] =
              $tmp[1]; #Storing SQL quries of perticular Test case into an array
            push( @sql_row, $line );
            $i++;
        }

    }
    close(FP);

    ###########################################################################################################
    # Check if SQL query exist in SQL file for a given Test case
    ###########################################################################################################

    $length = @sql_query;
    if ( $length < 1 ) {
        print "\nNo SQL query found for the given Test case ($tc_id)";
        $db_chk = "N/A"
          ; # N/A stands for database verification is not applicable for given test case
        print "\nDB Check Flag:$db_chk";
        return ($db_chk);
    }

    ###########################################################################################################
# Executing SQL quries. There can be a muliple queries for same test case. Hence looping all the quries.
    ###########################################################################################################

    foreach $sql (@sql_query) {
		print "\n################ Database verirfication ########\n";
        $final_sql = prepare_sql( $sql, $object_id );
        #print "\nSQL Query: $final_sql";
        @query_result=db_execute_sql($db_handle,$final_sql);

		 # Expected data structure of @query_result
		 #	@query_result = (
         #						 "12|Institue of Cancer Research US_058\n",
         #						 "13|Institue of Cancer Research US_059\n"
		 #		  			);

        $db_max_row = @query_result;
		@db_result=(); #clear @db_result for next intretion
        foreach (@query_result) {
            chomp($_);
            @tmp = split( '\|', $_ );
            $db_max_col = @tmp;
		    push( @db_result, [@tmp] );    # Storing refernce of an array
        } # end foreach (@query_result) 

        #print "\nDB Max Row:$db_max_row \nDB Max Column:$db_max_col";

		 # Expected data structure of @db_result
		 #	@db_result = (
         #						 row1|data1|data2
         #						 row2|data3|data4
		 #		  			);

        #Check if a query doen't retrun any record.

        if ( $db_max_row < 1 ) {
            print "\nNo record found in database";
            $db_chk = "Fail";
            print "\nDB Check Flag:$db_chk";
            #return ($db_chk);

        } #end if

        else {

            $line = shift(@sql_row);    #Fectch  the 1st SQL line
            @column_list = get_csv_column_index_list($line);
            #print "\nCSV Column Index: @column_list";

            open( FP, $csv_file ) or warn("could not open file $csv_file $!");
            $line       = <FP>;                  # skipping Header
            $line       = <FP>;
            @csv_data   = split( ',', $line );
            $csv_length = @csv_data;
            #print "\nCSV Data:@csv_data";

            $db_col_index = 0;
            foreach $csv_index (@column_list) {
                $csv_index--;    # element starts from 0th position

				#$csv_data[$csv_index] - is to get the required element from the row

                @csv_elements = split( '\#', $csv_data[$csv_index] );

  # Follwing loop will iterate for all the CSV elements which are '#' separated.
  # And compare it with respective data of query

                foreach $element (@csv_elements) {

                  
                    # Reset for each comparison
                    $found_match = "false";

                    #Itrating appropriate column for comparision
                    #print "\nDatabase result array:@db_result";
                    for (
                        $db_row_index = 0 ;
                        $db_row_index < $db_max_row ;
                        $db_row_index++
                      )
                    {

                        print ("\n(Data comparison CSV-->DB):$element -- > $db_result[$db_row_index][$db_col_index]");
                        if (
                            $element eq $db_result[$db_row_index][$db_col_index]
                          )
                        {
                            $found_match = "true";
                          last:    #breaking loop on finding match
                        } #end if
                    } #end for

                    #print "\nFound Match: $found_match";
                    if ( $found_match ne "true" ) {
                        $db_chk = "Fail";
                    } #end if

                } #end foreach

                $db_col_index++;

            } #end foreach $csv_index (@column_list)
			 
        }# end else
    } # end foreach $sql (@sql_query)

    return ($db_chk);
}

########################################################################################
# Funcation Name	: db_get_record_count
# Description		:
# Arguments			: $db_handle,$sql
# Return Values		:
#########################################################################################

sub db_get_record_count {
    my $db_handle = $_[0];
    my $sql       = $_[1];
    my $sth;
    my @result_row;
    $sth = $db_handle->prepare($sql);
    $sth->execute or die("\ncould not execute query.");
    @result_row = $sth->fetchrow_array();
    $sth->finish;
    #print("\nTotal available records: @result_row");
    return ( $result_row[0] );
}

########################################################################################
# Funcation Name	: query_count_comparison
# Description		:
# Arguments			: pre execution query count and post execution query count
# Return Values		:
#########################################################################################

sub query_count_comparison {
my $tmp;
my $length;
my $i;
my $status="Pass";

$tmp = shift;  #extracting first argument
my @prev_cnt = @$tmp;
$tmp = shift; 
my @post_cnt = @$tmp; #extracting second argument

$length=@prev_cnt;

for($i=0;$i<$length;$i++)
{
	if ($prev_cnt[$i] ne $post_cnt[$i])
	{
		$status="Fail";
		return $status;
	}
}
return ($status);
}

########################################################################################
# Funcation Name: audit_event_verification
# Description   : Verification Bulk Operation Audit Actions
#				  Following DB columns to be verified
#
#				  DB Table	:	catissue_audit_event
#				  Cloumns	:	IP_ADDRESS, EVNET_TIMESTAMP, USER_ID, EIVENT_TYPE 
#
#				  DB Table	:	catissue_data_audit_event_log
#				  Cloumns	:	OBJECT_NAME
#
#				  DB Table	:	catissue_audit_event_details
#				  Cloumns	:	CURRENT_VALUE
#
# Arguments		: Test case Id, db_handle, BO_Audit_SQL.properties,BO_Audit_Verification.csv
#				: $csv_file
# Return Values : Audit_check_status
#########################################################################################


sub audit_event_verification
{

my $test_case_id=$_[0];
my $handle=$_[1];
my $sql_file=$_[2];
my $csv_file=$_[3];
my $test_data_csv_file=$_[4];
my ($i, $line, $length, @db_data, @csv_data, @audit_sql, @domain_objects, @db_result, @audit_objects);
my $tm = localtime;
my $audit_check_status="Pass";
my ($user_id,$time_stamp,$event_type,$audit_ip,); 
my $total_objects;
my $found;

$time_stamp = sprintf( "%02d/%02d/%04d", $tm->mday, $tm->mon + 1, $tm->year + 1900 );
$audit_ip = "caCore IP issue";

@audit_sql=read_audit_conf($sql_file);

#executing Audit SQLs
#print "\nAudit SQLs: @audit_sql";


#Getting User ID

#@db_result=db_execute_sql($handle,$audit_sql[0]);
@db_result=("1");

$user_id=$db_result[0];

@audit_objects=get_csv_row($test_case_id,$csv_file);
#die "Audit objects are not found for test case ($test_case_id). Please check BO_Audit_verification file" if ($#audit_objects eq "0");

$event_type=uc($audit_objects[1]);
@domain_objects=split('#',$audit_objects[2]);;
$total_objects=@domain_objects;

#CATISSUE_AUDIT_EVENT  Verification

@db_result=db_execute_sql($handle,$audit_sql[1]);
#@db_result=("caCore IP issue|07/07/2010|1|INSERT");
@db_data=split("|",$db_result[0]);


$audit_check_status = "Fail" if ($audit_ip ne $db_data[0]); 
$audit_check_status = "Fail" if ($time_stamp ne $db_data[1]); 
$audit_check_status = "Fail" if ($user_id ne $db_data[2]);
$audit_check_status = "Fail" if ($event_type ne $db_data[3]); 


#CATISSUE_DATA_AUDIT_EVENT Verification

@db_result=db_execute_sql($handle,$audit_sql[0]);
#@db_result=("CATISSUE_CAPACITY","CATISSUE_STORAGE_CONTAINER","CATISSUE_CONTAINER_POSITION");

for($i=0;$i<$total_objects;$i++)
{
	$found = grep { $_ eq uc($domain_objects[$i]) } @db_result;
	if ($found !=1 )
	{
		print "Domain Objects are not getting audited.";
		$audit_check_status="Fail";
		last;
	}
	
}

#CATISSUE_DATA_AUDIT_EVENT_DETAIL Verification

#@db_result=db_execute_sql($handle,$audit_sql[0]);
@db_result=("24","10");

open (FP, "$test_data_csv_file") or warn ("File doesn't exist. Error $!");

$line=<FP>; #Skipping header 
$line=<FP>;
chomp ($line);
@csv_data=split(",",$line);
$length=@csv_data;
print ("\nCSV data: @csv_data");
close (FP);

$found=1;
for($i=0;$i<$length;$i++)
{
	$found = grep { $_ eq $csv_data[$i] } @db_result;
	if ($found !=1 )
	{
		print "Current values are not matching.";
		$audit_check_status="Fail";
		last;
	}
	
}

#print "\n\n\n ## Audit Check Status: $audit_check_status";
return $audit_check_status;

}

1;
