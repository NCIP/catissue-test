#
#####################################################
#
#		Bulk Operation API test Suite 1.0
# Dependecies : caTissueinstall.Properties file
# Perl DBD moduels for mySQL and Oracle
#####################################################

use strict;
use warnings;
use POSIX;
use BO_Common_Utilities;
use BO_DB_Utilities;

###########################################################################################################
# Variable declararions
############################################################################################################

my @test_case;
my $working_dir;
my $slash;
my ( $line,          $tmp );
my ( $caTissue_home, $caTissue_prop_file, $app_name, $prop_file_name, $csv_dir, $xml_dir );
my (
    $database_type, $database_host,     $database_port,
    $database_name, $database_username, $database_password,
    $oracle_tns_name
);
my (
    $jboss_server_port,      $jboss_server_host,
    $jboss_container_secure, $jboss_home_dir
);
my ( $ant_cmd, $ant_cmd_final, $ant_opt_template_file );
my ( $ant_opt_operation_name, $ant_opt_csv_file, $ant_opt_app_url,
    $ant_opt_app_user, $ant_opt_app_pwd, $ant_opt_keystore_location );
my ( $test_id, $test_scenario, $test_summary, $test_exp_result, $test_exp_msg );
my ( $rpt_check_status, $rpt_check_detail, $db_check_status, $audit_check_status );
my ( $csv_file_name, $csv_report_file );
my (
    $api_report_zip,   $api_report_csv, $cmd_time_taken,
    $cmd_build_status, $cmd_status
);
my ( $detail_report, $summary_report, $html_report, $emailable_report );
my $bo_api_report_dir;
my ( $total_tc, $total_tc_pass, $total_tc_fail, $tc_pass_perc );
my ( $conf_file, $test_case_file, $csv_file_location, $template_file_location,
    $ant_cmd_log );
my ( $db_handle, @sql_query, $sql, $total_sql, $sql_file, @query_result );
my @csv_data = "";
my $index;
my $app_status;
my ( @pre_exe_rcd_cnt, @post_exe_rcd_cnt, $count, $sql_query,@sql, $sql_count);
my $rpt_id_label;
my ( $audit_sql_file, $audit_csv_file);

$| = 1;    # If set to nonzero, forces a flush after every write or print

###########################################################################################################
# Initializing variables
###########################################################################################################

#Selecting Path Separator "/" for windows and "\" for linux

$slash       = get_path_separator($^O); # $^O gives the Name of Operating system
$working_dir = get_working_dir($^O);

$bo_api_report_dir = "BO_Logs";
( $total_tc, $total_tc_pass, $total_tc_fail, $tc_pass_perc ) = ( 0, 0, 0, 0 );
$test_scenario          = " ";
$conf_file              = "Conf" . $slash . "BO_TestSuite.conf";
$db_check_status        = " - ";
$test_exp_msg           = " ";
$rpt_id_label			= "Main Object Id";
$audit_check_status		= "-";

print
  "\n*******************************************************************\n\n";
print "\t\tBulk Operation API Test Suite\n";
print
  "\n*******************************************************************\n\n";

###########################################################################################################
# Reading conf file which contains location of caTissueHome
###########################################################################################################

print "\nReading Configuraion file...";

(
    $caTissue_home,  $test_case_file, $sql_file,
    $summary_report, $detail_report,  $html_report, $app_name,
	$prop_file_name, $csv_dir, $xml_dir, $audit_sql_file, $audit_csv_file, $emailable_report
) = read_bo_conf_file($conf_file);

$csv_file_location      = $working_dir . $slash . $csv_dir;
$template_file_location = $working_dir . $slash . $xml_dir;
$caTissue_prop_file = $caTissue_home . $slash . $prop_file_name;

###########################################################################################################
# Cleaning up old API reports
###########################################################################################################

cleaning_old_artifacts( $bo_api_report_dir, $detail_report, $summary_report, $emailable_report );

###########################################################################################################
# Initializing...
###########################################################################################################

initial_setup( $bo_api_report_dir, $detail_report, $summary_report );

$ant_cmd =
  "ant -f " . $caTissue_home . $slash . "build.xml" . " runBulkOperation";

#print "Prop File Path: $caTissue_prop_file";

###########################################################################################################
# Reading Application Install.properties file
###########################################################################################################

print "\nReading caTissue Install.properties file...";

(
    $jboss_home_dir,    $database_type,     $database_host,
    $database_port,     $oracle_tns_name,   $database_name,
    $database_username, $database_password, $jboss_server_port,
    $jboss_server_host, $jboss_container_secure
) = read_catissue_prop_file($caTissue_prop_file,$app_name);

###########################################################################################################
# Getting Test Scenario (e.g OS+Database+Fresh/Upgrade) on which application is deployed
###########################################################################################################

$test_scenario = get_test_scenario( $^O, $database_type );

###########################################################################################################
# Getting Application URL and Application Status
###########################################################################################################

 $ant_opt_app_url = get_app_url( $jboss_container_secure, $jboss_server_host,
        $app_name);

 #Check whether the apllication in running or not
 $app_status = check_app_status($ant_opt_app_url);

 #print "\nAPPLICATION Status: $app_status";
 if ( $app_status eq 'down' ) {
        die("\nApplication server is down!");
 }

###########################################################################################################
# Reading Test cases from Test Suite file (e.g. BO_TestSuite.csv) and execute them sequentially
###########################################################################################################

print "\n\nRunning Bulk operation Test Cases";
print
  "\n-----------------------------------------------------------------------\n";

###########################################################################################################
# Test Suite (BO_Testcases.csv) file format:
# TMTId,Test Summary UserName,pwd, CSV file name, Template name, Operation Name,
# Expected Result(Success/Failure),Expected Message
###########################################################################################################

open( TEST_FP, "$test_case_file" ) || die("\nCould not open $test_case_file.\nError: $!");
$test_exp_result="";
#skipping Heading Line
$line = <TEST_FP>;
while ( $line = <TEST_FP> ) {

    #print "\n$line";
    chomp($line);

	# Ignore Null lines 
	next if ($line eq "");

	# Ignore Test case if it starts with '#'.'#' symbol can used to commentout test cases from suite
	next if ( $line =~ m/^\s*\#/); 

	# Ignore Blank line 
	next if ( $line =~ m/^$/);

	$line =~ s/\\\,/\\/g; # replacing \, with \

	print "$line\n";

	@test_case = split( ',', $line );
    (
        $test_id,                $test_summary,
        $ant_opt_app_user,       $ant_opt_app_pwd,
        $ant_opt_csv_file,       $ant_opt_template_file,
        $ant_opt_operation_name, $test_exp_result,
        $test_exp_msg
    ) = @test_case;
	
	if($test_exp_msg ne "")
	{
		$test_exp_msg =~ s/\\/\,/g; # replacing \ with ,
	}

    ###########################################################################################################
    # Generating ANT Target for Bulk Operation
    ###########################################################################################################

    $ant_cmd_log   = $bo_api_report_dir . $slash . "ant_cmd_console";
    $csv_file_name = $csv_file_location . $slash . $ant_opt_csv_file;
    @csv_data      = get_csv_data($csv_file_name);

    
    $ant_opt_keystore_location =
        $jboss_home_dir 
      . $slash 
      . "server" 
      . $slash
      . "default"
      . $slash . "conf"
      . $slash
      . "chap8.keystore";

    if ( $jboss_container_secure eq 'yes' ) {
        $ant_cmd_final =
            $ant_cmd
          . " -DoperationName="
          . $ant_opt_operation_name
          . " -DapplicationUserName="
          . $ant_opt_app_user
          . " -DapplicationUserPassword="
          . $ant_opt_app_pwd
          . " -Durl="
          . $ant_opt_app_url
          . " -DcsvFile="
          . $csv_file_name
          . " -DtemplateFile="
          . $template_file_location
          . $slash
          . $ant_opt_template_file
          . " -DbulkArtifactsLocation="
          . $working_dir
          . $slash
          . $bo_api_report_dir;
        
    }
    else {
        $ant_cmd_final =
            $ant_cmd
          . " -DoperationName="
          . $ant_opt_operation_name
          . " -DapplicationUserName="
          . $ant_opt_app_user
          . " -DapplicationUserPassword="
          . $ant_opt_app_pwd
          . " -Durl="
          . $ant_opt_app_url
          . " -DcsvFile="
          . $csv_file_name
          . " -DtemplateFile="
          . $template_file_location
          . $slash
          . $ant_opt_template_file
          . " -DbulkArtifactsLocation="
          . $working_dir
          . $slash
          . $bo_api_report_dir;
    }

    $ant_cmd_log   = $ant_cmd_log . "_" . $test_id . "." . "log";
    $ant_cmd_final = $ant_cmd_final . " 1>" . $ant_cmd_log . " 2>&1";

    if ( uc($test_exp_result) eq 'FAILURE' ) {
        $db_handle = db_connect(
            $database_type, $database_host,     $database_name,
            $database_port, $database_username, $database_password,
            $oracle_tns_name
        );
		
		@sql = get_sql_query($db_handle,$sql_file);
		$sql_count=@sql;

		if ($sql_count ne '0') 
		{
			#$sql="select count(*) from catissue_institution";
	
			# "db_get_record_count" function retruns list if multiple SQL queries 
			# can be mapped to single Test case
			
			foreach $sql_query (@sql) {
				print "\n\nExtracted SQL Query:$sql";
				$count = db_get_record_count( $db_handle, $sql_query);
				push(@pre_exe_rcd_cnt,$count);
			}
	
			#@pre_exe_rcd_cnt = db_get_record_count( $db_handle, $sql) if ($sql ne "");
			db_disconnect($db_handle);
	       print "\nBefore Runnning ANT,record count:@pre_exe_rcd_cnt";
		}
		
        
    }

    #print "\n Final ANT Command: $ant_cmd_final";
    #print "\nRunning OS: $^O";

    print "\n\nTest Case Id: $test_id - $test_summary";

    system ($ant_cmd_final);

    #print "\n\nVerifying ANT Command Execution Logs...";

    ###########################################################################################################
    # Reading console logs of ANT target
    ###########################################################################################################

    #print "\nLOG File path:$ant_cmd_log";
    ( $api_report_zip, $cmd_status, $cmd_build_status, $cmd_time_taken ) =
      read_ant_cmd_log($ant_cmd_log);

    if ( $api_report_zip eq '' ) {
        warn "\n\nANT Command Failed!\n";
		$cmd_status="Failed";
    }
	if ($cmd_status eq 'Failed')
	{
		$rpt_check_status= "N/A";
		$db_check_status = "N/A";
		$rpt_check_detail = "<a href=".$ant_opt_app_url."/$ant_cmd_log>logs</a>";
		$cmd_time_taken = "N/A";
	}
	else {
			if ( $cmd_status eq 'Completed' && $cmd_build_status eq 'Sucess' ) {

				print "\n\nTest Case: $test_id successfully executed\n";
			}

			#print "\n\nVerifying Generated Report File...\n";
			#print "\n\n\nReport ZIP: $api_report_zip";

    ###########################################################################################################
    # Verifying generated Report
    ###########################################################################################################

			$csv_report_file=unzip_report($api_report_zip,$bo_api_report_dir);
		    $csv_report_file=$bo_api_report_dir.$slash.$csv_report_file;
		    #$csv_report_file = "BO_Logs\\addinstitution69.csv";

			( $rpt_check_status, $rpt_check_detail ) =
			      report_verification( $csv_file_name, $csv_report_file, $test_exp_result,
								        $test_exp_msg ,$app_name );
		      $rpt_check_detail = "<a href=".$ant_opt_app_url."/$ant_cmd_log>logs</a>";

    ###########################################################################################################
    # Verifying Data in database
    ###########################################################################################################

		  $index=get_main_object_id("$csv_report_file",$rpt_id_label);
   
	    $db_handle = db_connect(
		    $database_type, $database_host,     $database_name,
			$database_port, $database_username, $database_password,
	        $oracle_tns_name
		 );

	    if ( uc($test_exp_result) eq 'SUCCESS' ) {
		    
			# Comment out following database verification logic as Main Object ID
			# is not implemented in BO code of caTissue v1.2.Main Object ID is required by script
			# for database verification 

			#$db_check_status =  db_verfication( $test_id, $index, $db_handle, $csv_file_name,$sql_file );

			$db_check_status='N/A';  #Setting up default value as N/A
		}

	    elsif ( uc($test_exp_result) eq 'FAILURE' ) {

			if ($sql_count ne '0') 
			{

				foreach $sql_query (@sql) {
				$count = db_get_record_count( $db_handle, $sql_query);
				push(@post_exe_rcd_cnt,$count);
				
				}	
				
		        #db_disconnect($db_handle);
				print "\nAfter Runnning ANT,record count:@post_exe_rcd_cnt";

				# Passing array reference of pre-count and post-count
				$db_check_status=query_count_comparison([@pre_exe_rcd_cnt],[@post_exe_rcd_cnt]);
			}
			else
			{	
				$db_check_status="N/A";
			
			}
		}
	    else {
		    print(
			    "\nTest case - $test_id:Invalid string in expected result column");
	    }

	###########################################################################################################
    # Verifying Aduit Event data 
    ###########################################################################################################
	
	#$audit_check_status=audit_event_verification($test_id,$db_handle, $audit_sql_file, $audit_csv_file, $csv_file_name);	
	#print "\n\nAudit Check Status: $audit_check_status";
		
		db_disconnect($db_handle);
	    print "\nCSV Report Verification Status:$rpt_check_status";
		print "\nDatabase Verification Status:$db_check_status";
    }

    $total_tc++;
   
    if (   $rpt_check_status eq 'Pass'
        && ($db_check_status eq 'Pass' || $db_check_status eq 'N/A') && ($audit_check_status eq 'Pass' || $audit_check_status eq "-"))
    {
        $total_tc_pass++;
    }
    else {
        $total_tc_fail++;
    }

	

    ###########################################################################################################
    # Updating detail report
    ###########################################################################################################
    write_detail_report(
        $detail_report,    $test_id,	$test_summary,
        $cmd_status,      $cmd_time_taken, $rpt_check_status,
		$db_check_status, $audit_check_status, $rpt_check_detail
    );

}
close(TEST_FP);

###########################################################################################################
# Creating Summary report (csv file)
###########################################################################################################

if ($total_tc == 0)
{
	print ("\nNo Test case has been executed.");
}
$tc_pass_perc = get_tc_percentage( $total_tc, $total_tc_pass, $total_tc_fail ) if ($total_tc != 0);

write_summry_report(
    $summary_report, $test_scenario, $total_tc,
    $total_tc_pass,  $total_tc_fail, $tc_pass_perc
);

###########################################################################################################
# Generating HTML Report
###########################################################################################################

print "\n\nGenerating HTML Report\n";
generate_html_report( $html_report, $summary_report, $detail_report );
generate_emailable_report( $emailable_report, $summary_report,$app_name);
