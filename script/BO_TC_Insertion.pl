################################################################
#
#		Script to insert BO Test case into TMT under
#		specified Test Area. 
#
################################################################

use strict;
use warnings;
use DBI;

#Production DB credentials
my $database; #Database name is extracted from BO_Testcase.properties
my $hostname="vtest11.wustl.edu";
my $port="3306";
my $user="tmt_user";
my $password="tmt~us3r";

#my $database;
#my $hostname="{REPLCE HERE}";
#my $port="{REPLCE HERE}";
#my $user="{REPLCE HERE}";
#my $password="{REPLCE HERE}";

my $file_name = "BO_Testcase.properties";
my  (@file_data,$line);
my ($tc_file, $tmt_prod, $tmt_ver, $tmt_comp, $tmt_testarea, $test_req_name,
	 $tc_date, $login_name);

my ($prod_id, $ver_id, $comp_id, $ta_id, $tc_id, $auth_id, $req_id, $max_tc_id, @tc_list);
my ($dbh, $sth,$sql, @result, @tc_data); 
my ($tc_short_title, $tc_title, $tc_summary, $is_tc_available, $tc_db);
my ($tc_id_db, $tc_id_csv);
my $execution_type='BOTH';
my $test_type=1; # 2 is for Manual and 1 is for Automation
my $os=$^O;
	
#Converting file into Linux format. Its required if file is edited on Windows and run on Linux. 

system ("dos2unix $file_name") if ( $os =~ m/lin/i ); 

############## Reading BO_Testcase.properties file #################################

open (FP1,"$file_name")  ||  die ("\nCould not open $file_name file. Error:$!");
@file_data=<FP1>;

foreach $line (@file_data)
{
chomp ($line);

if ($line =~ /(testcase_file=)/g)
{	$tc_file= $';

}
elsif ($line =~ /(tmt_product=)/g)
{	$tmt_prod= $';

}
elsif ($line =~ /(tmt_version=)/g)
{
	$tmt_ver= $';
}

elsif ($line =~ /(tmt_component=)/g)
{
	$tmt_comp= $';
}

elsif ($line =~ /(tmt_testarea=)/g)
{
	$tmt_testarea= $';
}

elsif ($line =~ /(tmt_req_name=)/g)
{
	$test_req_name= $';
}

elsif ($line =~ /(tc_date=)/g)
{
	$tc_date= $';
}

elsif ($line =~ /(login_name=)/g)
{
	$login_name= $';
}

elsif ($line =~ /(tmt_database=)/g)
{
	$database= $';
}

}
close (FP1);
if ( $tc_file eq  "" || $tmt_prod eq  "" || $tmt_ver eq "" || $tmt_comp eq "" || $tmt_testarea eq "" ||
	 $test_req_name eq "" || $tc_date eq ""  || $login_name eq "" || $database eq "")
{
  die ("Configuration parameter(s) are missing.\n");
}
#print ("\nConfig parameters: Test Case File: $tc_file, Test Product: $test_prod Test Component:"
#		"$test_comp Test Date: $test_date Login Name: $test_user_name DB name: $database\n");

######## Database settings ############################################

my $dsn = "DBI:mysql:database=$database;host=$hostname;port=$port";

print "\nConnecting to mySQL...";

$dbh=DBI->connect($dsn, $user, $password) or 
	die "Could not Connect to database:!", DBI->errstr;


############## Getting Product Id #####################################

$sql="select prod_id from product_info where prod_name=\'$tmt_prod\'"; 
$sth = $dbh->prepare($sql);
$sth->execute or die ("\ncould not execute product_info query.");
@result=$sth->fetchrow_array();
$prod_id=$result[0];
$sth->finish;
print "\nProduct Id:$prod_id";

die ("\nProduct name not found!") if ($prod_id eq "");

############## Getting Version Id #####################################

$sql="select ver_id from version_info where ver_name=\'$tmt_ver\' and  prod_id=$prod_id"; 
$sth = $dbh->prepare($sql);
$sth->execute or die ("\ncould not execute version_info query.");
@result=$sth->fetchrow_array();
$sth->finish;
$ver_id=$result[0];
print "\nVersion Id:$ver_id";

die ("\nVersion name not found!") if ($ver_id eq "");

############## Getting Component Id #####################################

$sql="select comp_id from component_info where comp_name=\'$tmt_comp\' and  ver_id=$ver_id"; 
$sth = $dbh->prepare($sql);
$sth->execute or die ("\ncould not execute component_info query.");
@result=$sth->fetchrow_array();
$sth->finish;
$comp_id=$result[0];
print "\nComponent Id:$comp_id";

die ("\nComponent name not found!") if ($comp_id eq "");

############## Getting Test Area Id #####################################

$sql="select ta_id from testarea_info where ta_name=\'$tmt_testarea\' and comp_id=$comp_id"; 
$sth = $dbh->prepare($sql);
$sth->execute or die ("\ncould not execute testarea_info query.");
@result=$sth->fetchrow_array();
$sth->finish;
$ta_id=$result[0];
print "\nTest Area Id: $ta_id";

die ("\nTest area name not found!") if ($ta_id eq "");

############## Getting Requirement Id ###################################

$sql="select req_auto_id from requirementlist  where req_id = \'$test_req_name\' and  prod_id=$prod_id"; 
$sth = $dbh->prepare($sql);
$sth->execute or die ("\ncould not execute requirementlist query.");
@result=$sth->fetchrow_array();
$sth->finish;
$req_id=$result[0];
print "\nTest Requirement Id: $req_id";

die ("\nRequirement name not found!") if ($req_id eq "");

############## Getting Author Id #####################################

$sql="select auth_id from author_info where auth_name=\'$login_name\'"; 
$sth = $dbh->prepare($sql);
$sth->execute or die ("\ncould not execute author_info query.");
@result=$sth->fetchrow_array();
$sth->finish;
$auth_id=$result[0];
print "\nTest Author Id: $auth_id";

die ("\nAuthor name not found!") if ($auth_id eq "");

############## Max Testcase ID #############################################

$sql="select max(auto_id) from testcase_info"; 
$sth = $dbh->prepare($sql);
$sth->execute or die ("\ncould not execute testcase_info query.");
@result=$sth->fetchrow_array();
$sth->finish;
$max_tc_id=$result[0];
print "\nMax Test Case Id: $max_tc_id";

die ("\nUnable to fetch maximum Test Case Id!") if ($max_tc_id eq "");


############## Get Existing Test Case List from database #############################################

$sql="select tc_id from testcase_info where auto_id in (select auto_id from component where ta_id = $ta_id ) order by tc_id"; 
$sth = $dbh->prepare($sql);
$sth->execute or die ("\ncould not execute testcase_info query.");
while (@result=$sth->fetchrow_array())
{
	push (@tc_list,$result[0]);
}
$sth->finish;
#print "\nTest Case List: @tc_list";

############## Inserting New TCs #########################################
print "\n\nTest Suite File: $tc_file";

open (FP,"$tc_file") or die ("\nCouldn't not open File. Error: $!");

$line = <FP>; # skipping header

while ($line = <FP>)
{
	chomp ($line);
	
	# Ignore Null lines 
	next if ($line eq "");

	# Ignore Test case if it starts with '#'.'#' symbol can used to commentout test cases
	next if ( $line =~ m/^\s*#/); 

	@tc_data=split (',', $line); 

	#$line contains data in following sequence
	#TestId, TestSummary, username, password, csvname, templateName,o peration, Expected Result, Expected Message 

	# $tc_data[0] contains test ID and $tc_data[1] contains Test Summary
	$tc_short_title=get_tc_short_title($tc_data[0],$tc_data[1]);
	$tc_title=$tc_data[1];
	#print "\nTest case Short Title:$tc_short_title";# Test case Title:$tc_title";

	$is_tc_available = 0;
	$tc_short_title =~ m/^(\d+)_.+/;
	$tc_id_csv = $1;
	#print "\nCSV ID:$tc_id_csv";
	foreach $tc_db (@tc_list)
	{
			#Extracting initial Test case number from Test Short title
			$tc_db =~ m/^(\d+)_.+/; 
			$tc_id_db = $1;

			if ($tc_id_csv eq $tc_id_db)
			{
					$is_tc_available = 1;
					#print "\nCSV ID:$tc_id_csv & DB ID:$tc_id_db";

					# Breaking loop on getting correct match
					next; 
			}

	}

	#print "\nThe value of flag is_tc_avilable: $is_tc_available";
	#Skipping test case insertion if TC is already available in TMT
	next if ( $is_tc_available == 1);
	
	############################# Test Case Insertion code ############################

	$max_tc_id++;
	$sql="insert into testcase_info values ($max_tc_id,\'$tc_short_title\',\'$tc_title\',$auth_id,\'Purpose:\',1,\'$tc_date\',\'$tc_date\',$test_type,\'$execution_type\')";
	$sth = $dbh->prepare($sql);
	$sth->execute or die ("\ncould not execute insertion query on testcase_info.");
	$sth->finish;

	$sql="insert into component values ($ta_id,$max_tc_id);";
	$sth = $dbh->prepare($sql);
	$sth->execute or die ("\ncould not execute insertion query on component.");
	$sth->finish;

	$sql="insert into tcinfo_req value ($max_tc_id,$req_id); ";
	$sth = $dbh->prepare($sql);
	$sth->execute or die ("\ncould not execute insertion query on component.");
	$sth->finish;

}
close (FP);

print "\n Test cases successfully inserted in TMT.\n";
$dbh->disconnect;

########################################################################################
# Funcation Name: get_tc_short_title
# Description   : 
# Arguments		: 
# Return Values : 
#########################################################################################

sub get_tc_short_title
{
	my $tc_id = $_[0];
	my $tc_summary  = $_[1];
	my $tc_short_title;
	#testcase_info table has constraint of max 50 chars as Short Title.
	
	if (length($tc_summary) > 44)
	{
		#print ("\nTest case summary is long enough hence truncating title.");
		$tc_summary = substr ($tc_summary, 0, 44);
		

	}

	$tc_short_title=$tc_id."_".$tc_summary;
	return $tc_short_title;
}