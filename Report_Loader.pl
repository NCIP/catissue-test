#####################################################
# Perl DBD moduels for mySQL and Oracle
#####################################################

use strict;
use POSIX;
use caTIES_Common_Utilities;
use caTIES_DB_Utilities;
use Proc::Background;

###########################################################################################################
# Variable declararions
############################################################################################################

my $slash;
my ($ReportLoader_home, $Deidentifier_home, $ConceptCode_home, $input_dir, $bad_dir, $process_dir, $caTissue_home, $property_file_name, $detail_report);
my ( $database_type, $database_host, $database_port, $database_user, $database_password, $database_name, $database_tnsname, $db_connect );
my ( $ant_cmd, $ant_cmd_final, $ant_cmd_log );
my ($conf_file, $Logs_dir);


###########################################################################################################
# Initializing variables
###########################################################################################################

#$slash = get_path_separator($^O); # $^O gives the Name of Operating system
$slash = "\/";

$Logs_dir = "Logs";
$conf_file = "Conf" . $slash . "caTIES_Conf.conf";



###########################################################################################################
# Reading conf file 
###########################################################################################################


(
    $ReportLoader_home,  $Deidentifier_home, $ConceptCode_home, $input_dir, $bad_dir, $process_dir, $caTissue_home, $property_file_name, $detail_report
) = read_caTIES_conf_file($conf_file);

eval
{
###########################################################################################################
# Generating ANT Target for running report loader server
###########################################################################################################

	
	$ant_cmd = "ant -f " . $ReportLoader_home . $slash . "build.xml" . " run_report_loader_server";
	$ant_cmd_log   = $Logs_dir . "\/" . "ant_start_report_loader.log";
    $ant_cmd_final = $ant_cmd;
	$ant_cmd_final = $ant_cmd_final . " 1>" . $ant_cmd_log . " 2>&1";
	system($ant_cmd_final);
};