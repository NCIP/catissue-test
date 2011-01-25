#####################################################
# Perl DBD moduels for mySQL and Oracle
#####################################################

use strict;
use POSIX;
use BO_Common_Utilities;
use BO_DB_Utilities;

###########################################################################################################
# Variable declararions
############################################################################################################

my $working_dir;
my $slash;
my ($caTissue_home, $ppm_prop_file, $app_name, $prop_file_name);

my ( $ant_cmd, $ant_cmd_final, $ant_cmd_log );
my (
    $api_report_zip,   $cmd_time_taken,
    $cmd_build_status, $cmd_status
);
my ( $detail_report, $summary_report );
my ( $conf_file, $Logs_dir, $sql_file );

my ($input_dir, $drop_sql_dir, $output_dir);

my (%private_table_count, %public_table_count, $TableName, $TableRowCount, $private_tables_count, $public_tables_count);

my ($databaseType, $privateDBName, $privateDBHost, $privateDBUserName, $privateDBPassword,
    $privateDBPort, $privateDBTablespace, $privateDBIndexTablespace, $publicDBName,
    $publicDBHost, $publicDBUserName, $publicDBPassword, $publicDBPort, $publicSystemUserName,
	$publicSystemPassword, $publicDBTNSName);
my ($PHI_Check, $AddMask_Check);
my $tc_total=6;
my $tc_pass=0;
my $tc_fail=0;
my $tc_aborted=0;
#my ($drop_pub_diff, $drop_stg_diff, $diff_cmd, $copy_cmd);

$| = 1;    # If set to nonzero, forces a flush after every write or print
my $j = 1;

###########################################################################################################
# Initializing variables
###########################################################################################################

#Selecting Path Separator "/" for windows and "\" for linux

$slash = get_path_separator($^O); # $^O gives the Name of Operating system
$working_dir = get_working_dir($^O);

$Logs_dir = "Logs";
$conf_file = "Conf" . $slash . "PPM_Conf.conf";

print "\n*******************************************************************\n";
print "\nPPM Test Suite Execution started...\n";
print "\n*******************************************************************\n";

###########################################################################################################
# Reading conf file which contains location of all paths of directories and files required
###########################################################################################################
$input_dir ="input";
print "\nReading Configuraion file...\n";

(
    $caTissue_home,  $sql_file, $detail_report, $app_name, $prop_file_name, 
	$input_dir, $drop_sql_dir, $output_dir, $summary_report
) = read_ppm_conf_file($conf_file);

$ppm_prop_file = $caTissue_home . $slash . $prop_file_name;

###########################################################################################################
# Reading privatePublic.properties file used for database related functions
###########################################################################################################

print "\nReading properties file...\n";

(
    $databaseType, $privateDBName, $privateDBHost, $privateDBUserName, $privateDBPassword,
    $privateDBPort, $privateDBTablespace, $privateDBIndexTablespace, $publicDBName,
    $publicDBHost, $publicDBUserName, $publicDBPassword, $publicDBPort, $publicSystemUserName,
	$publicSystemPassword, $publicDBTNSName
) = read_ppm_prop_file($ppm_prop_file);

###########################################################################################################
# Initalise the set up for test execution report 
###########################################################################################################
cleaning_old_artifacts_ppm( $detail_report, $summary_report);
initial_setup_ppm( $detail_report, $summary_report );

eval
{
###########################################################################################################
# Generating ANT Target for generate_command_file and executing it
###########################################################################################################

	$ant_cmd = "ant -f " . $caTissue_home . $slash . "/privatePublic.xml" . " generate_command_file";
	$ant_cmd_log   = $Logs_dir . $slash . "ant_generate_cmd_file.log";
    $ant_cmd_final = $ant_cmd;
	$ant_cmd_final = $ant_cmd_final . " 1>" . $ant_cmd_log . " 2>&1";
	system ($ant_cmd_final);

####################################################################################################################
# Reading console logs of ANT target generate_command_file to check whether the ant has successfulyy executed or not
####################################################################################################################

	( $api_report_zip, $cmd_status, $cmd_build_status, $cmd_time_taken ) = read_ant_cmd_log($ant_cmd_log);

	if ( $cmd_build_status eq 'Sucess' ) 
	{
		print "\nTest Case 001: Generate Command File successfully executed\n";
		write_detail_report($detail_report, "001", "Generate Command File", "Pass");
		$tc_pass++;
	}
	else
	{
		print "\nTest Case 001: Generate Command File failed.\n";
		write_detail_report($detail_report, "001", "Generate Command File", "Fail");
		$tc_fail++;
	}
};
if ($@)
{
	write_detail_report($detail_report, "001", "Generate Command File", "Aborted");
	print "\nTest Case 001: Generate Command File aborted due to exception.\n";
	$tc_aborted++;
}
###########################################################################################################
# Comparing the sql files generated thruogh generate_command_file target against base files
###########################################################################################################
#$copy_cmd = "cp " . $drop_sql_dir . "/drop_public_db_oracle.sql " . $output_dir . "/drop_public_db_oracle.sql";
#system($copy_cmd);
#$copy_cmd = "cp " . $drop_sql_dir . "/drop_staging_db_oracle.sql " . $output_dir . "/drop_staging_db_oracle.sql";
#system($copy_cmd);

#$diff_cmd = "diff -bis " . $output_dir . "/drop_public_db_oracle.sql " . $input_dir . "/drop_public_db_oracle.sql";
#$drop_pub_diff = system ($diff_cmd);
#print "\n\nDrop Public SQL : $drop_pub_diff successfully executed\n";

#$diff_cmd = "diff -bis " . $output_dir ."/drop_staging_db_oracle.sql " . $input_dir ."/drop_staging_db_oracle.sql";
#$drop_stg_diff = system ($diff_cmd);
#print "\n\nDrop Stageing SQL : $drop_stg_diff successfully executed\n";

eval
{
###########################################################################################################
# Generating ANT Target for migrate and executing it
###########################################################################################################

	$ant_cmd = "ant -f " . $caTissue_home . $slash . "/privatePublic.xml" . " migrate";
	$ant_cmd_log   = $Logs_dir . $slash . "ant_migrate.log";
    	$ant_cmd_final = $ant_cmd;
    	$ant_cmd_final = $ant_cmd_final . " 1>" . $ant_cmd_log . " 2>&1";
	system ($ant_cmd_final);


#############################################################################################################
# Reading console logs of ANT target migrate to check whether the ant execution completed successfully or not
#############################################################################################################

	( $api_report_zip, $cmd_status, $cmd_build_status, $cmd_time_taken ) = read_ant_cmd_log($ant_cmd_log);

	if ( $cmd_build_status eq 'Sucess' ) 
	{
		print "\nTest Case 002: Migration successfully executed.\n";
		write_detail_report($detail_report, "002", "Migrate ant target", "Pass");
		$tc_pass++;
	}
	else
	{
		print "\nTest Case 002: Migration failed.\n";
		write_detail_report($detail_report, "002", "Migrate ant target", "Fail");
		$tc_fail++;
	}
};
if ($@)
{
	write_detail_report($detail_report, "002", "Migrate ant target", "Aborted");
	print "\nTest Case 002: Migration aborted due to exception.\n";
	$tc_aborted++;
}

eval
{
###########################################################################################################
# Getting count of Tables in the private database schema
###########################################################################################################
	$private_tables_count = getTablesCount($databaseType, $privateDBHost, $privateDBName, $privateDBPort, 
		$privateDBUserName, $privateDBPassword, $publicDBTNSName);

###########################################################################################################
# Getting count of Tables in the public database schema
###########################################################################################################
	$public_tables_count = getTablesCount($databaseType, $privateDBHost, $privateDBName, $privateDBPort, 
		$privateDBUserName, $privateDBPassword, $publicDBTNSName);

###########################################################################################################
# Comparing the counts of Tables in the private and public database schema
###########################################################################################################
	if ($private_tables_count eq $public_tables_count)
	{
		print "\nTest Case 003: No. of tables in Private and Public database matches.\n";
		write_detail_report($detail_report, "003", "No. of Table comparison between private and public database", "Pass");
		$tc_pass++;
###########################################################################################################
# Reading the Private/Public Tables and it's row count against it and storing it in to hashmap
###########################################################################################################
		%private_table_count = getTableMap($databaseType, $privateDBHost, $privateDBName, $privateDBPort, 
			$privateDBUserName, $privateDBPassword, $publicDBTNSName);
	
		%public_table_count = getTableMap($databaseType, $publicDBHost, $publicDBName, $publicDBPort, 
			$publicDBUserName, $publicDBPassword, $publicDBTNSName);
		$j = 0;
		while ( ($TableName,$TableRowCount) = each %public_table_count) 
		{     
			if($TableName =~ m/^(CATISSUE_AUDIT_EVENT|CATISSUE_AUDIT_EVENT_DETAILS|CATISSUE_AUDIT_EVENT_LOG|CATISSUE_DATA_AUDIT_EVENT_LOG|CATISSUE_AUDIT_EVENT_QUERY_LOG|CATISSUE_BULK_OPERATION|CATISSUE_REPORT_PARTICIP_REL|CATISSUE_PART_MEDICAL_ID|JOB_DETAILS)/)
			{
				#These table are truncated in public database as they contain the PHI data
				#hence the row count of these tables will not match across private and public databases
			}
			else
			{
				if ($TableRowCount ne $private_table_count{$TableName})
				{
					print "\n $j $TableName - Public = $TableRowCount - Private = $private_table_count{$TableName}";
					$j++;
				}
			}
		}
	
		if ($j eq 0)
		{
			print "\nTest Case 004: No. of rows in each table in private database schema matches with No. of rows in same table in public database schema.\n";
			write_detail_report($detail_report, "004", "No. of rows comparison between private and public database tables", "Pass");		
			$tc_pass++;
		}
		else
		{
			print "\nTest Case 004: No. of rows in each table in private database schema do not matche with No. of rows in same table in public database schema.\n";
			write_detail_report($detail_report, "004", "No. of rows comparison between private and public database tables", "Fail");
			$tc_fail++;
		}
	}
	else
	{
		print "\nTest Case 003: No. of tables in Private and Public database do not match.\n";
		write_detail_report($detail_report, "003", "No. of Table comparison between private and public database", "Fail");
		$tc_fail++;
	}
};
if ($@)
{
	write_detail_report($detail_report, "003", "No. of Table comparison between private and public database", "Aborted");
	print "\nTest Case 003: No. of tables in Private and Public database matching aborted due to exception.\n";
	$tc_aborted++;
	write_detail_report($detail_report, "004", "No. of rows comparison between private and public database tables", "Aborted");
	print "\nTest Case 004: No. of rows matching for each table in private database schema with No. of rows for same table in public database schema aborted due to exception.\n";
	$tc_aborted++;
}

###########################################################################################################
# Verify that additional masking of PHI data in Public database schema is done correctly
###########################################################################################################
eval
{
	$AddMask_Check = verifyAdditionalMasking($databaseType, $publicDBHost, $publicDBName, $publicDBPort, 
			$publicDBUserName, $publicDBPassword, $publicDBTNSName);		
			
	if($AddMask_Check eq "true")
	{
		print "\nTest Case 005: The additional masking of PHI Data in the Public database schema is done correctly.\n";
		write_detail_report($detail_report, "005", "Additional masking of PHI data in public database", "Pass");
		$tc_pass++;
	}
	else
	{
		print "\nTest Case 005: The additional masking of PHI Data in the Public database schema is failed.\n";
		write_detail_report($detail_report, "005", "Additional masking of PHI data in public database", "Fail");
		$tc_fail++;
	}
};
if ($@)
{
	write_detail_report($detail_report, "005", "Additional masking of PHI data in public database", "Aborted");
	print "\nTest Case 005: The additional masking of PHI Data in the Public database schema is aborted due to exception.\n";
	$tc_aborted++;
}

###########################################################################################################
# Verify that the PHI data in the various tables get nullified in Public database Schema
###########################################################################################################
eval
{
	$PHI_Check = verify_PHI($databaseType, $publicDBHost, $publicDBName, $publicDBPort, 
			$publicDBUserName, $publicDBPassword, $publicDBTNSName);		
	#print "\n Part_PHI_Check : $PHI_Check";		
	if($PHI_Check eq "true")
	{
		print "\nTest Case 006: The PHI Data in the Public database schema is nullified correctly.\n";
		write_detail_report($detail_report, "006", "Masking of PHI data in public database", "Pass");
		$tc_pass++;
	}
	else
	{
		print "\nTest Case 006: The PHI Data in the Public database schema is not nullified correctly.\n";
		write_detail_report($detail_report, "006", "Masking of PHI data in public database", "Fail");
		$tc_fail++;
	}
};
if ($@)
{
	write_detail_report($detail_report, "006", "Masking of PHI data in public database", "Aborted");
	print "\nTest Case 006: The PHI Data in the Public database schema is aborted due to exception.\n";
	$tc_aborted++;
}

write_summry_report_ppm($summary_report, $tc_total, $tc_pass, $tc_fail, $tc_aborted);
#print "\nPass : $tc_pass Fail : $tc_fail Aborted : $tc_aborted";

###########################################################################################################
# Function to verify that the additional masking of PHI data in Public Database schema is done correctly
###########################################################################################################

sub verifyAdditionalMasking 
{
	my $fndatabaseType = $_[0];
	my $fnprivateDBHost = $_[1];
	my $fnprivateDBName = $_[2];
	my $fnprivateDBPort = $_[3];
	my $fnprivateDBUserName = $_[4];
	my $fnprivateDBPassword = $_[5];
	my $fnpublicDBTNSName = $_[6];
	my ($db_handle, $sql_TablesCount, $count_tables, $SQL_LastName, $SQL_FirstName, $SQL_MiddleName, $SQL_SSN, @TablesList, $tablename,
		$i, $sql_TableRowCount, %Table_Count_Map, $rowCount);
	my ($NotNull_LastName_Count, $NotNull_FirstName_Count, $NotNull_MiddleName_Count, $NotNull_SSN_Count);
	my (@sql, $sql_count, $count, $sql_query, );
	my $PHINullify = "true";
	
	$db_handle = db_connect($fndatabaseType, $fnprivateDBHost, $fnprivateDBName, $fnprivateDBPort, 
		$fnprivateDBUserName, $fnprivateDBPassword, $fnpublicDBTNSName
        );
		
	@sql = get_sql_query("#001",$sql_file);
	$sql_count=@sql;

	if ($sql_count ne '0') 
	{
		foreach $sql_query (@sql) 
		{
			$count = db_get_record_count( $db_handle, $sql_query);
			if ($count ne 0)
			{
				$PHINullify = "false";
			}
		}
	}
###########################################################################################################
# Creating a hashmap containing table name and row count in that table
###########################################################################################################
	db_disconnect($db_handle);

	return ($PHINullify);
}

###########################################################################################################
# Function to verify that the PHI data in the public database schema tables got nullified
###########################################################################################################

sub verify_PHI 
{
	my $fndatabaseType = $_[0];
	my $fnprivateDBHost = $_[1];
	my $fnprivateDBName = $_[2];
	my $fnprivateDBPort = $_[3];
	my $fnprivateDBUserName = $_[4];
	my $fnprivateDBPassword = $_[5];
	my $fnpublicDBTNSName = $_[6];
	my ($db_handle, $sql_TablesCount, $count_tables, $SQL_LastName, $SQL_FirstName, $SQL_MiddleName, $SQL_SSN, @TablesList, $tablename,
		$i, $sql_TableRowCount, %Table_Count_Map, $rowCount);
	my ($NotNull_LastName_Count, $NotNull_FirstName_Count, $NotNull_MiddleName_Count, $NotNull_SSN_Count);
	my (@sql, $sql_count, $count, $sql_query, );
	my $PHINullify = "true";
	my ($SQL_PHI_Attri, @PHI_Attr_List, $PHI_Attr, $sql_ColumnName, @Column_Name, $sql_TableName,
	    @Table_Name, $sql_RowCount, $rowCount_PHI);
	
	$db_handle = db_connect($fndatabaseType, $fnprivateDBHost, $fnprivateDBName, $fnprivateDBPort, 
		$fnprivateDBUserName, $fnprivateDBPassword, $fnpublicDBTNSName
        );
		
	$SQL_PHI_Attri = "select identifier from dyextn_primitive_attribute where is_identified =1";
	@PHI_Attr_List = db_execute_sql( $db_handle, $SQL_PHI_Attri);
	my $k=1;
	my ($tblName, $colName);
	foreach $PHI_Attr(@PHI_Attr_List)
	{
		#print "\n $PHI_Attr";
		#Fire second query to get the Column name for the attribute
		#select name from dyextn_database_properties where identifier = (select identifier from dyextn_column_properties where primitive_attribute_id = ?)
		$sql_ColumnName = "select name from dyextn_database_properties where identifier = (select identifier from dyextn_column_properties where primitive_attribute_id = " . $PHI_Attr . ")";
		@Column_Name = db_execute_sql( $db_handle, $sql_ColumnName);
		($colName) = @Column_Name;
		
		#Fire third query to get the Table name for the attribute
		#select name from dyextn_database_properties where identifier = (select identifier from dyextn_table_properties where ABSTRACT_ENTITY_ID = (select entiy_id from dyextn_attribute where identifier = ?))
		$sql_TableName = "select name from dyextn_database_properties where identifier = (select identifier from dyextn_table_properties where ABSTRACT_ENTITY_ID = (select entiy_id from dyextn_attribute where identifier = " . $PHI_Attr ."))";
		@Table_Name = db_execute_sql( $db_handle, $sql_TableName);
		
		($tblName) = @Table_Name;

		if($tblName =~ m/^(CATISSUE_PASSWORD|DE_E_411|DE_E_584|DE_E_618|DE_E_915)/)
		{
			#These tables are excluded from the verification as their names are masked 
			#in caTissue Metadata for security reason.
		}
		else
		{
			#Form a query dynamically to find whether data in $Column_Name of $Table_Name is nullified in Public Database Schema
			$sql_RowCount = "select count(*) from " . $tblName . " where " . $colName . " is not null";
			$rowCount_PHI = db_get_record_count( $db_handle, $sql_RowCount);
			$k++;
		}

		if($rowCount_PHI ne 0)
		{
			$PHINullify = "false";
			#print "\n Table Name : $tblName \t Column Name : $colName \t Rows : $rowCount_PHI";
		}
	}

###########################################################################################################
# Creating a hashmap containing table name and row count in that table
###########################################################################################################
	db_disconnect($db_handle);

	return ($PHINullify);
}

###########################################################################################################
# Function to get the map of table name and the row count of that table
###########################################################################################################
sub getTableMap 
{
	my $fndatabaseType = $_[0];
	my $fnprivateDBHost = $_[1];
	my $fnprivateDBName = $_[2];
	my $fnprivateDBPort = $_[3];
	my $fnprivateDBUserName = $_[4];
	my $fnprivateDBPassword = $_[5];
	my $fnpublicDBTNSName = $_[6];
	my ($db_handle, $sql_TablesCount, $count_tables, $sql_TableNames, @TablesList, $tablename,
		$i, $sql_TableRowCount, %Table_Count_Map, $rowCount);
	
	$db_handle = db_connect($fndatabaseType, $fnprivateDBHost, $fnprivateDBName, $fnprivateDBPort, 
		$fnprivateDBUserName, $fnprivateDBPassword, $fnpublicDBTNSName
        );
		
	$sql_TableNames = "select tname from tab order by tname";
	@TablesList = db_execute_sql( $db_handle, $sql_TableNames);
				
###########################################################################################################
# Creating a hashmap containing table name and row count in that table
###########################################################################################################
	$i = 1;
	foreach $tablename(@TablesList)
	{
		chomp($tablename);
	#	print "Table [$i] : $tablename \t";
		$sql_TableRowCount = "select count(*) from " . $tablename;
		$rowCount=db_get_record_count( $db_handle, $sql_TableRowCount);
		$Table_Count_Map{$tablename}=$rowCount;
		$i++;
	}
	db_disconnect($db_handle);

	return (%Table_Count_Map);
}

###########################################################################################################
# Function to get the count of tables in a particular schema
###########################################################################################################

sub getTablesCount 
{
	my $fndatabaseType = $_[0];
	my $fnprivateDBHost = $_[1];
	my $fnprivateDBName = $_[2];
	my $fnprivateDBPort = $_[3];
	my $fnprivateDBUserName = $_[4];
	my $fnprivateDBPassword = $_[5];
	my $fnpublicDBTNSName = $_[6];
	my ($db_handle, $sql_TablesCount, $count_tables, $sql_TableNames, @TablesList, $tablename,
		$i, $sql_TableRowCount, %Table_Count_Map, $rowCount);
	
	$db_handle = db_connect($fndatabaseType, $fnprivateDBHost, $fnprivateDBName, $fnprivateDBPort, 
		$fnprivateDBUserName, $fnprivateDBPassword, $fnpublicDBTNSName
        );
		
	$sql_TablesCount = "select count(*) from tab";

	$count_tables = db_get_record_count( $db_handle, $sql_TablesCount);
		
	db_disconnect($db_handle);
	return($count_tables);	
}