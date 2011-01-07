#!/usr/bin/perl
#package BO_Common_Utilities;

use strict;
use warnings;
use File::Copy;
use Time::localtime;
use File::Path;        # used to delete non-empty folder
use LWP::UserAgent;    #used to fire HTTP request

########################################################################################
# Funcation Name: Read_bo_conf_file
# Description   : Reads Configuration paramters from config file
# Arguments		: Config file name
# Return Values : caTissue.Home,read_bo_conf_file, Summary.Report, Detail.Report,HTML.Report
#########################################################################################

sub read_bo_conf_file {
    my $file_name = $_[0];
    my @file_data;
    my $line;
    my ( $val_1, $val_2, $val_3, $val_4, $val_5, $val_6, $val_7, $val_8, $val_9, $val_10, $val_11, $val_12, $val_13);
	my $os=$^O;
	
	#Converting file into Linux format. Its required if file is edited on Windows and run on Linux. 
	system ("dos2unix $file_name") if ( $os =~ m/lin/i ); 

    open( FP, "$file_name" )
      || die("\nCould not open $file_name file.\nError: $!");
    @file_data = <FP>;
    close(FP1);

    foreach $line (@file_data) {
        chomp($line);
        if ( $line =~ /^(Application.Home=)/g ) {
            $val_1 = $';
        }
        elsif ( $line =~ /^(Test.Suite=)/g ) {
            $val_2 = $';
        }
        elsif ( $line =~ /^(Test.Sql=)/g ) {
            $val_3 = $';
        }
        elsif ( $line =~ /^(Summary.Report=)/g ) {
            $val_4 = $';
        }
        elsif ( $line =~ /^(Detail.Report=)/g ) {
            $val_5 = $';
        }
        elsif ( $line =~ /^(HTML.Report=)/g ) {
            $val_6 = $';
        }
		elsif ( $line =~ /^(Application.Name=)/g ) {
            $val_7 = $';
        }
		elsif ( $line =~ /^(Propertyfile.Name=)/g ) {
            $val_8 = $';
        }
		elsif ( $line =~ /^(CSVData.Dir=)/g ) {
            $val_9 = $';
        }
		elsif ( $line =~ /^(XMLTemplate.Dir=)/g ) {
            $val_10 = $';
        }
		elsif ( $line =~ /^(Audit.Sql=)/g ) {
            $val_11 = $';
        }
		elsif ( $line =~ /^(Audit.Verification.Data=)/g ) {
            $val_12 = $';
        }
		elsif ( $line =~ /^(emailable.report=)/g ) {
            $val_13 = $';
        }


    }
    if (   $val_1 eq ""
        || $val_2 eq ""
        || $val_3 eq ""
        || $val_4 eq ""
        || $val_5 eq ""
        || $val_6 eq ""
		|| $val_7 eq ""
		|| $val_8 eq ""
		|| $val_9 eq ""
		|| $val_10 eq ""
		|| $val_11 eq ""
		|| $val_12 eq ""
		|| $val_13 eq "" )
    {
		print "\n$val_1, $val_2, $val_3, $val_4, $val_5, $val_6, $val_7, $val_8,$val_9 ,$val_10, $val_11, $val_12, $val_13";
		die("Configuration parameter(s) are missing.\n");

    }

    return ( $val_1, $val_2, $val_3, $val_4, $val_5, $val_6, $val_7, $val_8,$val_9 ,$val_10, $val_11, $val_12, $val_13 );
}

########################################################################################
# Funcation Name: read_audit_conf
# Description   : 
# Arguments		: 
# Return Values : 
#########################################################################################

sub read_audit_conf
{
	my $file_name = $_[0];
    my @file_data;
    my $line;
    my ( $val_1, $val_2, $val_3, $val_4 );
	my $os=$^O;
	
	#Converting file into Linux format. Its required if file is edited on Windows and run on Linux. 
	system ("dos2unix $file_name") if ( $os =~ m/lin/i ); 

    open( FP, "$file_name" )
      || die("\nCould not open $file_name file.\nError: $!");
    @file_data = <FP>;
    close(FP1);

    foreach $line (@file_data) {
        chomp($line);
        if ( $line =~ /^(Audit.User.Id=)/g ) {
            $val_1 = $';
        }
        elsif ( $line =~ /^(Audit.Event.Summary=)/g ) {
            $val_2 = $';
        }
        elsif ( $line =~ /^(Audit.Event.Object=)/g ) {
            $val_3 = $';
        }
        elsif ( $line =~ /^(Audit.Event.Detail=)/g ) {
            $val_4 = $';
        }
      
    
    }
    if (   $val_1 eq ""
        || $val_2 eq ""
        || $val_3 eq ""
        || $val_4 eq "")
    {
        die("Audit even properties are  missing.\n");
    }

    return ( $val_1, $val_2, $val_3, $val_4);

}




#####################################################################################################
# Funcation Name: Read_catissue_prop_file
# Description   : Reads Application's intall.property file to get server url and database credentials	
# Arguments     : Property file name & Application name
# Return Values : $jboss_home_dir,$database_type,$database_host,$database_port,$oracle_tns_name
#				  $database_name,$database_username,$database_password,$jboss_server_port,$jboss_server_host,
#				  $jboss_container_secure
#####################################################################################################

sub read_catissue_prop_file {

    my $prop_file = $_[0];
	my $app_name =  $_[1];
    my $line;
	my $os=$^O;
    my (
        $database_type, $database_server,     $database_port,
        $database_name, $database_user, $database_password,
        $oracle_tns_name
    );
    my (
        $jboss_server_port,      $jboss_server_host,
        $jboss_container_secure, $jboss_home_dir
    );

	
	#Converting file into Linux format. Its required if file is edited on Windows and run on Linux. 
	system ("dos2unix $prop_file") if ( $os =~ m/lin/i ); 

    open( FP, "$prop_file" )
      || die("\nCould not open $prop_file file.\nError: $!");
    my @file_data = <FP>;
    close(FP);

    foreach $line (@file_data) {

        #print "$line";
        chomp($line);

        if ( $line =~ /^(jboss.home.dir=)/g ) {
            $jboss_home_dir = $';
        }
        elsif ( $line =~ /^(database.type=)/g ) {
            $database_type = $';
        }
        elsif ( $line =~ /^(database.server=)/g ) {
            $database_server = $';
        }
        elsif ( $line =~ /^(database.port=)/g ) {
            $database_port = $';
        }
        elsif ( $line =~ /^(oracle.tns.name=)/g ) {
            $oracle_tns_name = $';
        }
        elsif ( $line =~ /^(database.name=)/g ) {
            $database_name = $';
        }
        elsif ( $line =~ /^(database.user=)/g ) {
            $database_user = $';
        }
        elsif ( $line =~ /^(database.password=)/g ) {
            $database_password = $';
        }
        elsif ( $line =~ /^(jboss.server.port=)/g ) {
            $jboss_server_port = $';
        }
        elsif ( $line =~ /^(jboss.server.host=)/g ) {
            $jboss_server_host = $';
        }
        elsif ( $line =~ /^(jboss.container.secure=)/g ) {
            $jboss_container_secure = $';
        }

    }

    if (   $database_type eq ""
        || $database_server     eq ""
        || $database_port     eq ""
        || $database_name     eq ""
        || $database_user eq ""
        || $database_password eq ""
        || $jboss_server_host eq ""
)        
    {
        die("\nCould not read necessary caTissue properties.\n");
    }

	if ($app_name =~ m/clinportal/i)
	{
	
	$jboss_container_secure='yes';
	}

    return (
        $jboss_home_dir,    $database_type,     $database_server,
        $database_port,     $oracle_tns_name,   $database_name,
        $database_user, $database_password, $jboss_server_port,
        $jboss_server_host, $jboss_container_secure
    );
}

##########################################################################################
# Funcation Name : read_ant_cmd_log
# Description    : Reads and extracts useful values from console logs of bulk operation
#			       ANT target
# Arguments      : Log file name
# Return Values  : Report Name,Command execution status, Build success flag,execution time
###########################################################################################

sub read_ant_cmd_log {

    my $log_file = $_[0];
    my ( $line, $val_1, $val_2, $val_3, $val_4 ) = "";

    open( FP, "$log_file" )
      || die("\nCould not open $log_file file.\nError: $!");
    my @file_data = <FP>;
    close(FP);

    foreach $line (@file_data) {
        chomp($line);

        #print "\n$line";
        if ( $line =~ m/Report :/g ) {
            $val_1 = $';
        }
        elsif ( $line =~ m/Status :/g ) {
            $val_2 = $';
        }

        elsif ( $line =~ m/BUILD SUCCESSFUL/ ) {
            $val_3 = 'Sucess';
        }
        elsif ( $line =~ m/Total time:/ ) {
            $val_4 = $';
        }
    }

    return ( $val_1, $val_2, $val_3, $val_4 );
}

########################################################################################
# Funcation Name : unzip_report
# Description	 : Function is used to extract zip file 
# Arguments		 : ZIP file name,directory name where it the zip gets extracted. it is 
#				   assumed that zip file contains single csv file
# Return Values  : Extracted file name  
#########################################################################################

sub unzip_report {

    my $zip_file = $_[0];
    my $dir_name = $_[1];
    my $csv_file;

    system("unzip $zip_file -d $dir_name");

    #print "\n\n\n ZIP File:$api_report_zip";

    $zip_file =~ m/(\w+)(.)(\w+)$/;    #extracting file name from path
    $csv_file = $1 . "." . "csv";

    #print "\nCSV File: $csv_file";
    return ($csv_file);

}

########################################################################################
# Funcation Name : report_verification
# Description	 : This function compares data of input CSV data to the CSV file generated 
#				   after running bulkoperation ANT target.
# Arguments		 : Original CSV file, newly generated CSV file, Expected result,expected 
#				   message (in the case of failure) 
# Return Values  : Test case result (Pass/Fail) and Message in the case failure
#########################################################################################

sub report_verification {

    my $base_csv_file   = $_[0];
    my $result_csv_file = $_[1];
    my $tc_exp_result   = $_[2];
    my $tc_exp_msg      = $_[3];
    my $app_name        = $_[4];
    my $tc_actual_msg   = " ";
    my $csv_file;
    my ( @result_csv_column, @base_csv_column, @result_csv_row, @base_csv_row,
        $line );
    my ( $rpt_check_status, $rpt_check_detail ) = ( "", "" );
    my ( $i, $total_element, $length, $success_col_index );

    #Opening Original CSV file
    open( FP1, "$base_csv_file" )
      or die("\nCould not open $base_csv_file file.\nError: $!");

    $line            = <FP1>;
	chomp($line);
    @base_csv_column = split( ',', $line );
    $line            = <FP1>;
	chomp($line);
    @base_csv_row    = split( ',', $line );
    close(FP1);

    #Opening Report CSV file
    open( FP1, $result_csv_file )
      or die("\nCould not open $result_csv_file.\nError: $!");
    $line              = <FP1>;
	chomp($line);
    @result_csv_column = split( ',', $line );

	my $search_for="Message";
       my ( $index )= grep { $result_csv_column[$_] eq $search_for } 0..$#result_csv_column;

    $line              = <FP1>;
	chomp($line);
    @result_csv_row    = split( ',', $line );
    close(FP1);

    $rpt_check_status = "Pass";          # Setting up Default status as "Pass";
    $total_element    = @base_csv_row;

    #Comparing Elements

    print "\nTotal Element in Org CSV:$total_element";
    for ( $i = 0 ; $i < $total_element ; $i++ ) {

        print "\nItreation $i: $base_csv_row[$i] and $result_csv_row[$i]";
        if ( trim($base_csv_row[$i]) ne trim($result_csv_row[$i]) ) {

            #print "Found Mismatch";
            $rpt_check_detail = $rpt_check_detail . " is not matching with \n";
            $rpt_check_status = "Fail";
        }
    }

	#get the index of column of "Success" message. It is assumed "Success" message
	#is going to append immediately after original CSV columns
	
	$success_col_index=@base_csv_column; #getting lenght of base CSV column array

	#Comparing Expected Result
    print "\n\nEXP: $tc_exp_result AND RESULT: $result_csv_row[$success_col_index]";

    trim($tc_exp_result);
    trim( $result_csv_row[$success_col_index] );

    if ( uc($tc_exp_result) ne uc( $result_csv_row[$success_col_index] ) ) {
        $rpt_check_detail =
          $rpt_check_detail . "Expected status doesn't match.\n";
        $rpt_check_status = "Fail";
    }

    #Comparing Expected Message in the case of Failure
	
    if ( uc($tc_exp_result) eq 'FAILURE' ) {
   #     $length = @base_csv_column + 1;    # No. of elements to be removed from the array 

#print "\nlength: $length";
#To get the Expected message pop() can be used but if Message itself contains ","
#then it wont give expected result hence "splice" removes all the elements uptill "Status" rest of he elements
#can be joined and treated as single expected result.

      #  splice( @result_csv_row, 0, $length );
	#	print ("\n\n####No. of elements to be removed from the array: $length");
	#	print ("\n\n#### RESULT ARRAY: @result_csv_row");
       # $tc_actual_msg = join( '', @result_csv_row );

		if(uc($app_name) eq "CLINPORTAL")
		{
			$tc_actual_msg = join( ",", @result_csv_row[$index..$#result_csv_row-1]);
		}
		if(uc($app_name) eq "CATISSUE")
		{
			$tc_actual_msg = join( "", @result_csv_row[$index..$#result_csv_row]);
		}
        print "\ntc_exp_msg:$tc_exp_msg";
        print "\nActual Mesage:$tc_actual_msg";

        if ( trim($tc_exp_msg) ne trim($tc_actual_msg) ) {
            $rpt_check_detail =
              $rpt_check_detail . "Expected message doesn't match\n";
			print ("\nExpected message doesn't match\n");
            $rpt_check_status = "Fail";
        }

    }

    return ( $rpt_check_status, $rpt_check_detail );
}

########################################################################################
# Funcation Name : write_detail_report
# Description    :
# Arguments		 : $detail_report,$test_scenario,$test_id,$test_summary,$cmd_status,$cmd_time_taken,
#				   $rpt_check_status,$db_check_status,$rpt_check_detail)
# Return Values	 : -
#########################################################################################

sub write_detail_report {
    my $file_name = shift;    #it will assign 1st argument
    my $csv_row =
      join( ',', @_ );    # it will create single row of coma seperated values
    open( FP, ">>$file_name" );
    print FP "$csv_row\n";
    close(FP);
}

########################################################################################
# Funcation Name : write_summry_report
# Description    :
# Arguments      : $summary_report,$test_scenario,$total_tc,$total_tc_pass,$total_tc_fail
# Return Values  :  -
#########################################################################################

sub write_summry_report {
    my $file_name = shift;    #it will assign 1st argument
    my $csv_row =
      join( ',', @_ );    # it will create single row of coma seperated values
    open( FP, ">>$file_name" );
    print FP "$csv_row\n";
    close(FP);
}

########################################################################################
# Funcation Name : generate_html_report
# Description    :
# Arguments      : $html_report,$summary_report,$detail_report
# Return Values  : -
#########################################################################################

sub generate_html_report {
    my $html_file    = $_[0];
    my $summary_file = $_[1];
    my $detail_file  = $_[2];
    my ( $line, @a, $header );
    my $tm = localtime;
    my $dt_today =
      sprintf( "%02d-%02d-%04d", $tm->mday, $tm->mon + 1, $tm->year + 1900 );

    my $html_header =
"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\"><HTML xmlns:lxslt = http://xml.apache.org/xslt xmlns:stringutils = \"xalan://org.apache.tools.ant.util.StringUtils\">"
      . "<HEAD><TITLE>Bulk Operation API Test Summary Report </TITLE><META http-equiv=Content-Type content=text/html; charset=US-ASCII><LINK title=Style href=stylesheet.css type=text/css rel=stylesheet>"
      . "<META content=MSHTML 6.00.6000.16825 name=GENERATOR></HEAD>";

    my $html_body =
      "<BODY><H1>Bulk Operation API Test Summary Report</H1><TABLE width=100%>"
      . "<TBODY><TR><TD align=Right>Date:$dt_today</TD>"
      . "<TD align=right></TD></TR></TBODY></TABLE><HR SIZE=1>";

    open( HTML_FP,    ">$html_file" );
    open( SUMMARY_FP, "$summary_file" );
    open( DETAIL_FP,  "$detail_file" );

    print HTML_FP "$html_header\n";
    print HTML_FP "$html_body\n";

    #Writing Summary in HTML file

    print HTML_FP "<H2>Summary</H2>\n";
    print HTML_FP
      "<TABLE class=details cellSpacing=2 cellPadding=5 width=95% border=0>\n";
    print HTML_FP "<TBODY>\n";

    $header = "true";
    while ( $line = <SUMMARY_FP> ) {
        chomp($line);
        @a = split( ',', $line );
        if ( $header eq 'true' ) {
            $header = "false";
            print HTML_FP "<TR vAlign=top>\n";
            foreach (@a) {
                print HTML_FP "<TH>$_</TH>\n";
            }
        }
        else {
            print HTML_FP "<TR vAlign=top class=Pass>\n";
            foreach (@a) {
                print HTML_FP "<TD>$_</TD>\n";
            }
        }
        print HTML_FP "</TR>\n";
    }
    print HTML_FP "</TBODY></TABLE>\n";

    #Writing Summary in HTML file

    print HTML_FP "<BR><BR><HR SIZE=1><H2>Detail</H2>\n";
    print HTML_FP
"<TABLE class=details cellSpacing=2 cellPadding=5 width=95% border=0><TBODY>\n";

    $header = "true";
    while ( $line = <DETAIL_FP> ) {
        chomp($line);
        @a = split( ',', $line );
        if ( $header eq 'true' ) {
            $header = "false";
            print HTML_FP "<TR vAlign=top>\n";
            foreach (@a) {
                print HTML_FP "<TH>$_</TH>\n";
            }
        }
        else {
            print HTML_FP "<TR vAlign=top class=Pass>\n";
            foreach (@a) {
                print HTML_FP "<TD>$_</TD>\n";
            }
        }

        print HTML_FP "</TR>\n";
    }
    print HTML_FP "</TBODY></TABLE>\n";

    print HTML_FP "</TBODY></TABLE></BODY></HTML>\n";

    close(HTML_FP);
    close(SUMMARY_FP);
    close(DETAIL_FP);
}


########################################################################################
# Funcation Name : generate_emailable_report
# Description    :
# Arguments      : $emailable_report,$summary_report
# Return Values  : -
#########################################################################################
sub generate_emailable_report
{
 my $prop_file    = $_[0];
 my $summary_file = $_[1];
 my $app_name = $_[2];
 my ($line, @row);
	open( FP,    ">$prop_file" );
	open( SUMMARY_FP, "$summary_file" );
	$line = <SUMMARY_FP>; #skipping header line
	$line = <SUMMARY_FP>;
	chomp ($line);
	@row = split(',',$line); 
	if ( $app_name =~ m/clinportal/i)
	{
		    print FP "CP.Scenario=$row[0]\n";
			print FP "CP.TotalTestCase=$row[1]\n";
			print FP "CP.TestCase.Passed=$row[2]\n";
			print FP "CP.TestCase.Failed=$row[3]\n";
			print FP "CP.TestCase.Percent=$row[4]\n";
    }
	else 
	{
			print FP "Scenario=$row[0]\n";
			print FP "TotalTestCase=$row[1]\n";
			print FP "TestCase.Passed=$row[2]\n";
			print FP "TestCase.Failed=$row[3]\n";
			print FP "TestCase.Percent=$row[4]\n";
	}

close (FP);
close(SUMMARY_FP);
}


########################################################################################
# Funcation Name	: cleaning_old_artifacts
# Description		:
# Arguments			: bo_api_report_dir, detail_report, summary_report, emailable_report
# Return Values		: -
########################################################################################

sub cleaning_old_artifacts {

    my $dir_name = $_[0];

    #deleting Report folder
    rmtree($dir_name);
      #or warn "Could not delete file: $!";

    #deleting Old BO_Automation_reports
    unlink( $_[1] );
      #or warn "Could not delete file: $!";
    unlink( $_[2] );
      #or warn "Could not delete file: $!";
    unlink( $_[3] );
}

########################################################################################
# Funcation Name	: initial_setup
# Description		:
# Arguments			:  bo_api_report_dir, detail_report, summary_report
# Return Values		: -
#########################################################################################

sub initial_setup {
    my $dir_name = $_[0];
    mkdir $dir_name or die "Could not create directory: $!";

    #Writing initial Headers in Report (csv) file
    write_detail_report(
        $_[1],
        "Test Id",
        "Test Summary",
        "Test Execution Status",
        "Time Taken (sec)",
        "Report Verification",
        "Database Verification",
		"Audit Event Verification",
        "Logs"
    );
    write_summry_report( $_[2], "Scenario", "Total Test cases Executed",
        "Passed", "Failed", "Percent Passed(%)" );

}

########################################################################################
# Funcation Name	: get_csv_data
# Description		: extracting CSV data
# Arguments			: csv_file_name
# Return Values		: CSV data
#########################################################################################

sub get_csv_data {
    my $file_name = $_[0];
    my ( @csv_data, $line );
    open( FP, "$file_name" ) or die("\nCould not open file:$file_name $!");
    $line = <FP>;    # skipping Header
    $line = <FP>;
    chomp($line);
    @csv_data = split( ",", $line );
    return (@csv_data);
}

########################################################################################
# Funcation Name	: get_tc_percentage
# Description		: Calculating percentage 
# Arguments			: $total_tc,$total_tc_pass,$total_tc_fail
# Return Values		: Percentage value
#########################################################################################
sub get_tc_percentage {

    my ( $total, $pass, $fail ) = ( $_[0], $_[1], $_[2] );
    my $result = ( 100 * $pass ) / $total;
	$result=sprintf("%.2f", $result); # Rounding to 2 digits
    return $result;
}

########################################################################################
# Funcation Name	: get_path_separator
# Description		: setting up correct slash "/" or "\" by detecting OS
# Arguments			: OS Name
# Return Values		: Path seperator (for linux: "/" and for Windows "\" )
#########################################################################################
sub get_path_separator {
    my $os        = $_[0];
    my $separator = "";
    $separator = "\\" if ( $os =~ m/win/i );
    $separator = "\/" if ( $os =~ m/lin/i );
    return ($separator);
}

########################################################################################
# Funcation Name	: get_app_url
# Description		: Forming application URL
# Arguments			: jboss_container_secure, jboss_server_host, jboss_server_port, app_name	
# Return Values		: Application URL
#########################################################################################
sub get_app_url {
    my $secure = $_[0];
    my $host   = $_[1];
my $app_name=$_[3];
    my $app_url;

    if ( $secure eq 'yes' ) {
        $app_url = "https://" . $host .  "/";
    }
    else {
        $app_url = "http://" . $host .  "/";
    }
	
	if ( $app_name =~ m/clinportal/i) {
         $app_url = $app_url . "clinportal";
    }
    else {
        $app_url = $app_url . "catissuecore";
    }

    return ($app_url);
}

########################################################################################
# Funcation Name	: get_working_dir
# Description		: gettig current working directory
# Arguments			: OS Name
# Return Values		: absolute path of current working directory
#########################################################################################
sub get_working_dir {
    my $os   = $_[0];
    my $path = "";
    $path = `cd`  if ( $os =~ m/win/i );    # Executing "cd" command for windows
    $path = `pwd` if ( $os =~ m/lin/i );    # Executing "pwd" command for Linux
    chomp($path);                           #Removing '\n' from the end
    return ($path);
}

########################################################################################
# Funcation Name	: get_test_scenario
# Description		: Detecting scenario(OS + Database) on which application has been deployed
# Arguments			: OS Name,Database Name
# Return Values		: Deployment scenario
#########################################################################################
sub get_test_scenario {
    my $os       = $_[0];
    my $database = $_[1];
    my $scenario;

    $os = "Windows" if ( $os =~ m/win/i );  # Executing "cd" command for windows
    $os = "Linux"   if ( $os =~ m/lin/i );  # Executing "pwd" command for Linux

    $scenario = $os . "_" . uc($database) . "_" . "Upgrade";

    return ($scenario);
}

########################################################################################
# Funcation Name	: trim
# Description		: Removing left and right white spaces
# Arguments			: String
# Return Values		: String 
#########################################################################################

sub trim {
    my $str = $_[0];
    $str =~ s/^\s+//;
    $str =~ s/\s+$//;
    return ($str);
}

########################################################################################
# Funcation Name	: get_id_Column_order
# Description		: getting column index from CSV file
# Arguments			: $csv_file_name,column_header
# Return Values		: index number of the column
#########################################################################################

sub get_id_Column_order {
    my $file_name = $_[0];
    my $header    = $_[1];
    my ( @a, $i, $line, $length );
    open( FP, $file_name ) or die("could not open file $file_name $!");
    $line = <FP>;
    close(FP);

    @a = split( ',', $line );
    $length = @a;

    for ( $i = 0 ; $i < $length ; $i++ ) {
        if ( $header eq $a[$i] ) {
            return $i;
        }
    }

    return "-1";
}

########################################################################################
# Funcation Name	: check_app_status
# Description		: To check whether the application server is up or not
# Arguments			: app_url
# Return Values		: app_status ('up' or 'down')
#########################################################################################

sub check_app_status {
    $ENV{HTTP_PROXY} = 'http://ptproxy.persistent.co.in:8080';
	my $app_url = $_[0];
	#print "\nAPPLICATION URL: $app_url";
    my $app_status;
    my $ua = LWP::UserAgent->new( keep_alive => 1 );
    $ua->timeout(1000);
    $ua->env_proxy;
    $ua->cookie_jar( { file => 'tempCookie.txt', autosave => 1 } );

    my $response =
      $ua->get($app_url);

    #print $response->content;

    if ( $response->is_success ) {
        $app_status = "up";
    }
    else {
        $app_status = "down";
    }
    return $app_status;
}


########################################################################################
# Funcation Name	: get_csv_row
# Description		: 
# Arguments			: 
# Return Values		: 
#########################################################################################

sub get_csv_row
{
	my $test_case_id = $_[0];
	my $csv_file	=	$_[1];
	my @audit_objects;
	my $line;
	open (FP,$csv_file);
	while ($line=<FP>)
	{
		chomp($line);
		
		next if ($line eq "");
		
		@audit_objects=split(",",$line);
		
		# Ignore Test case if it starts with '#'.'#' symbol can used to commentout test cases from suite
		next if ( $audit_objects[0] =~ m/^\s*#/); 
		
		if ($test_case_id eq $audit_objects[0])
		{
		 close (FP);
		 return @audit_objects;
		}
	}
close (FP);
return 0;
}


########################################################################################
# Funcation Name	: read_ant_cmd_log
# Description		: script execution logger
# Arguments			: Logging string
# Return Values		: - 
#########################################################################################

=heah
sub logger
{
	my $log_file="BO_Test_Suite.log";
	my $log_str=$_[0];
	my $tm = localtime;
	my $time_stamp=sprintf("[%02d-%02d-%04d]",$tm->mday, $tm->mon+1,$tm->year+1900);
	open (LOG_FILE, ">>$log_file");
	print LOG_FILE "$time_stamp \t $log_str\n";
	close (LOG_FILE);
}

=cut

1;
