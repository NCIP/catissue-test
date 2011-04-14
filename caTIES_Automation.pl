#####################################################
# Perl DBD moduels for mySQL and Oracle
#####################################################

use strict;
use POSIX;
use caTIES_Common_Utilities;
use caTIES_DB_Utilities;
use Proc::Background;
use File::Spec;

###########################################################################################################
# Variable declararions
############################################################################################################

my $slash;
my ($ReportLoader_home, $Deidentifier_home, $ConceptCode_home, $input_dir, $bad_dir, $process_dir, $caTissue_home, $property_file_name, $detail_report);
my ( $database_type, $database_host, $database_port, $database_user, $database_password, $database_name, $database_tnsname, $db_connect );
my ( $ant_cmd, $ant_cmd_final, $ant_cmd_log );
my ($conf_file, $Logs_dir);
my ($query, $count);
my $sth;
my @result_row;

###########################################################################################################
# Initializing variables
###########################################################################################################

$slash = get_path_separator($^O); # $^O gives the Name of Operating system

$Logs_dir = "Logs";
$conf_file = "Conf" . $slash . "caTIES_Conf.conf";

print "\n*******************************************************************\n";
print "\ncaTIES Test Suite Execution started...\n";
print "\n*******************************************************************\n";

###########################################################################################################
# Initalise the set up for test execution report 
###########################################################################################################
cleaning_old_artifacts_ppm( $detail_report );
initial_setup_ppm( $detail_report );

###########################################################################################################
# Reading conf file 
###########################################################################################################

print "\nReading Configuraion file...\n";

(
    $ReportLoader_home,  $Deidentifier_home, $ConceptCode_home, $input_dir, $bad_dir, $process_dir, $caTissue_home, $property_file_name, $detail_report
) = read_caTIES_conf_file($conf_file);

###########################################################################################################
# Reading caTissue property file
###########################################################################################################

print "\nReading caTissue Properties file...\n";

$property_file_name = $caTissue_home . $slash . $property_file_name;
(
	$database_type, $database_host, $database_port, $database_name, $database_user, $database_password, $database_tnsname
) = read_caTissue_property_file($property_file_name);

eval
{
###########################################################################################################
# Calling another PERL file for executing Report Loader target
###########################################################################################################


	Proc::Background->new('perl', 'Report_Loader.pl'); #Strat report loader in Background.
	print "\nReport Loader Server started...\n";
	
};

eval
{
###########################################################################################################
# Verifying DB for Report Loading
###########################################################################################################

my $s;
my $status;
my $spr;
my $rcount;
my $count;


$db_connect = db_connect($database_type, $database_host, $database_port, $database_name, $database_user, $database_password, $database_tnsname);

#Verifying status of each report.

$query = "SELECT STATUS,SURGICAL_PATHOLOGY_NUMBER FROM CATISSUE_REPORT_QUEUE WHERE SURGICAL_PATHOLOGY_NUMBER IN('PHS06-24', 'HHS05-8', 'CHS05-9', 'BDS05-10', 'BDS05-28')";

$count = 0;

for ($s=0;$count == 0;$s=$s+1)
{
$sth = $db_connect->prepare($query);
$sth->execute or die("Could not execute Query to verify Db details for Report Loader");
@result_row=$sth->fetchrow_array();
$count=@result_row;
$sth->finish;
}
	
$sth = $db_connect->prepare($query);
$sth->execute or die("Could not execute Query to verify Db details for Report Loader");

$sth->bind_columns(undef,\$status,\$spr); #bind table columns to variables

$count = 0;
	
while($sth->fetch()) #Fetch each row of the query result.
{
	
	if($spr eq 'PHS06-24' || $spr eq 'HHS05-8' || $spr eq 'BDS05-10' || $spr eq 'CHS05-9' || $spr eq 'BDS05-28')
	{
		$count = $count + 1;
		#Below If-elsif-else block compares the report status
		
		if ($spr eq 'PHS06-24' && $status eq 'SITE_NOT_FOUND')
		{
			print "\nSPR $spr STATUS $status success\n";
		}
		elsif($spr eq 'BDS05-10' && $status eq 'PARTICIPANT_CONFLICT')
		{
			print "\nSPR $spr STATUS $status success\n";
		}
		elsif($spr eq 'HHS05-8' && $status eq 'ADDED_TO_QUEUE')
		{
			print "\nSPR $spr STATUS $status success\n";
		}
		elsif($spr eq 'CHS05-9' && $status eq 'ADDED_TO_QUEUE')
		{
			print "\nSPR $spr STATUS $status success\n";
		}
		elsif($spr eq 'BDS05-28' && $status eq 'ADDED_TO_QUEUE')
		{
			print "\nSPR $spr STATUS $status success\n";
		}
		else
		{
			print "\nSTATUS for $spr is not correct\n";
			print "\nREPORT LOADER Failed !\n";
			$sth->finish;
			$ant_cmd = "ant -f " . $ReportLoader_home . $slash . "build.xml" . " stop_report_loader_server";
			$ant_cmd_log   = $Logs_dir . "\/" . "ant_stop_report_loader.log";
			$ant_cmd_final = $ant_cmd_final . " 1>" . $ant_cmd_log . " 2>&1";
			system ($ant_cmd_final);
			$db_connect->disconnect or die("Could not disconnect database!");
			write_detail_report($detail_report,"1","Report Loader Failed since report status is not same","FAIL");
			exit 1;
		}
	}

}

$sth->finish;

#Verifies whether reports are added to CATISSUE_REPORT_QUEUE table after it is read from the input directory.

if($count < 5)
{
	print "\nAll Reports not loaded to CATISSUE_REPORT_QUEUE table\n";
	print "\nREPORT LOADER Failed !\n";
	$ant_cmd = "ant -f " . $ReportLoader_home . $slash . "build.xml" . " stop_report_loader_server";
	$ant_cmd_log   = $Logs_dir . "\/" . "ant_stop_report_loader.log";
	$ant_cmd_final = $ant_cmd;
	$ant_cmd_final = $ant_cmd_final . " 1>" . $ant_cmd_log . " 2>&1";
	system ($ant_cmd_final);
	$db_connect->disconnect or die("Could not disconnect database!");
	write_detail_report($detail_report,"1","Report Loader failed since all reports not loaded to from input file to CATISSUE_QUEUE_REPORT table","FAIL");
	exit 1;
}
else
{
	print "\nReports added to CATISSUE_REPORT_QUEUE table successfully.\n";
}
	
$count=1;
$rcount=0;

#Counting number of reports already with status PENDING_FOR_DEID in CATISSUE_PATHOLOGY_REPORT table.

$query = "SELECT * FROM CATISSUE_PATHOLOGY_REPORT WHERE REPORT_STATUS = 'PENDING_FOR_DEID'";
$sth = $db_connect->prepare($query);
$sth->execute or die("Could not execute query to verify DB details for Report loader");

while ($sth->fetch())
{
	$rcount = $rcount + 1;
}

$sth->finish;

#Verifying whether reports moved from CATISSUE_REPORT_QUEUE table to CATISSUE_PATHOLOGY_REPORT table.

$query = "SELECT PARTICIPANT_NAME FROM CATISSUE_REPORT_QUEUE WHERE STATUS = 'ADDED_TO_QUEUE' and SURGICAL_PATHOLOGY_NUMBER IN ('PHS06-24', 'HHS05-8', 'CHS05-9', 'BDS05-10', 'BDS05-28')";

for($s = 0; $count != 0; $s = $s + 1)
{
	$sth = $db_connect->prepare($query);
	$sth->execute or die("Could not execute query to verify DB details for Report loader");
	@result_row = $sth->fetchrow_array();
	$sth->finish;

	$count = @result_row;
	
}

$query = "SELECT * FROM CATISSUE_PATHOLOGY_REPORT WHERE REPORT_STATUS = 'PENDING_FOR_DEID'";
$sth = $db_connect->prepare($query);
$sth->execute or die("Could not execute query to verify DB deatils for Report loader");

$count = 0;

while ($sth->fetch())
{
	$count = $count + 1;
}

$sth->finish;

print "\n$count $rcount\n";

if (($count-$rcount) > 0)
{
	print "\nReport added to CATISSUE_PATHOLOGY_REPORT table successfully.\n";
}
else
{
	print "\nReports from CATISSUE_REPORT_QUEUE table not added to CATISSUE_PATHOLOGY_REPORT.\n";
	print "\nREPORT LOADER Failed !\n";
	$ant_cmd = "ant -f " . $ReportLoader_home . $slash . "build.xml" . " stop_report_loader_server";
	$ant_cmd_log   = $Logs_dir . "\/" . "ant_stop_report_loader.log";
	$ant_cmd_final = $ant_cmd;
	$ant_cmd_final = $ant_cmd_final . " 1>" . $ant_cmd_log . " 2>&1";
	system ($ant_cmd_final);
	$db_connect->disconnect or die("Could not disconnect database!");
	write_detail_report($detail_report,"1","Report Loader failed since report did not move from QUEUE table to PATHOLOGY_REPORT table","FAIL");
	exit 1;
}

$db_connect->disconnect or die("Could not disconnect database!");

print "\nReport Loader Success\n";

write_detail_report($detail_report,"1","Report Loader Success","SUCCESS");

};

eval
{
###########################################################################################################
# Generating ANT Target for stopping report loader server
###########################################################################################################

	$ant_cmd = "ant -f " . $ReportLoader_home . $slash . "build.xml" . " stop_report_loader_server";
	$ant_cmd_log   = $Logs_dir . "\/" . "ant_stop_report_loader.log";
    $ant_cmd_final = $ant_cmd;
    $ant_cmd_final = $ant_cmd_final . " 1>" . $ant_cmd_log . " 2>&1";
	system ($ant_cmd_final);
	print "\nReport Loader Server Stopped\n";

};

eval
{
##########################################################################################################
#Calling another perl file to start de-id identifier
##########################################################################################################

	Proc::Background->new('perl', 'Deidentifier.pl'); 
	print "\nDe-identifier Server started...\n";


};

eval
{
##########################################################################################################
#Verifying Db for De-identified Reports
#########################################################################################################
my $s;

$db_connect = db_connect($database_type, $database_host, $database_port, $database_name, $database_user, $database_password, $database_tnsname);

$query = "SELECT * FROM catissue_pathology_report WHERE report_status = 'PENDING_FOR_DEID'";

$count = 1;

for($s=0;$count != 0;$s=$s+1)
{

	$sth = $db_connect->prepare($query);
	$sth->execute or die("Could not execute query to verify DB deatils for Report loader");
	@result_row = $sth->fetchrow_array();
	$sth->finish;

	$count = @result_row;

}
	
$query = "SELECT identifier FROM catissue_pathology_report WHERE report_status = 'DEID_PROCESS_FAILED'";

	$sth = $db_connect->prepare($query);
	$sth->execute or die("Could not execute query to verify DB deatils for Report loader");
	@result_row = $sth->fetchrow_array();
	$sth->finish;

	$count = @result_row;

if ($count > 0)
{
	print "\nDe-identifier failed\n";
	write_detail_report($detail_report,"2","De-identifier failed","FAIL");
}
else
{
	print "\nReports de-identified successfully...\n";
	write_detail_report($detail_report,"2","De-identifier Success","SUCCESS");
}

$db_connect->disconnect or die("Could not disconnect database!");

};


eval
{
##########################################################################################################
#Generating Ant target for stopping de-ientifier server
##########################################################################################################

	$ant_cmd = "ant -f " . $Deidentifier_home . $slash . "build.xml" . " stop_deidentifier_server";
	$ant_cmd_log   = $Logs_dir . "\/" . "ant_stop_deidentifier.log";
    $ant_cmd_final = $ant_cmd;
	$ant_cmd_final = $ant_cmd_final . " 1>" . $ant_cmd_log . " 2>&1";
	system ($ant_cmd_final);
	print "\nDe-identifier Server Stopped\n";

};

eval
{
##########################################################################################################
#Calling another perl file to start concept code server
##########################################################################################################

	Proc::Background->new('perl', 'Concept_Code.pl'); 
	print "\nConcept Code Server started...\n";


};

eval
{
##########################################################################################################
#Verifying Db for Concept Code Reports
#########################################################################################################
my $s;

$count = 1;

$db_connect = db_connect($database_type, $database_host, $database_port, $database_name, $database_user, $database_password, $database_tnsname);

$query = "SELECT identifier FROM catissue_pathology_report WHERE report_status = 'PENDING_FOR_XML'";

for($s=0;$count != 0;$s=$s+1)
{

	$sth = $db_connect->prepare($query);
	$sth->execute or die("Could not execute query to verify DB deatils for Report loader");
	@result_row = $sth->fetchrow_array();
	$sth->finish;

	$count = @result_row;

}

$query = "SELECT identifier FROM catissue_pathology_report WHERE report_status = 'CC_PROCESS_FAILED'";


	$sth = $db_connect->prepare($query);
	$sth->execute or die("Could not execute query to verify DB deatils for Report loader");
	@result_row = $sth->fetchrow_array();
	$sth->finish;

	$count = @result_row;

if ($count > 0)
{
	print "\nConcept Coder failed\n";
	write_detail_report($detail_report,"3","Concept Code Failed","FAIL");
}
else
{
	print "\nReports Concept Coded Successfully...\n";
	write_detail_report($detail_report,"3","Concept Code Success","SUCCESS");
}

$db_connect->disconnect or die("Could not disconnect database!");

};


eval
{
##########################################################################################################
#Generating Ant target for stopping concept_code server
##########################################################################################################

	$ant_cmd = "ant -f " . $ConceptCode_home . $slash . "build.xml" . " stop_concept_code_server";
	$ant_cmd_log   = $Logs_dir . "\/" . "ant_stop_concept_code.log";
    $ant_cmd_final = $ant_cmd;
	$ant_cmd_final = $ant_cmd_final . " 1>" . $ant_cmd_log . " 2>&1";
	system ($ant_cmd_final);
	print "\nConcept Code Server Stopped\n";
	
};