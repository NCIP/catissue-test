#!/usr/bin/perl
#package caTIES_Common_Utilities;

use strict;
use warnings;
use File::Copy;
#use Time::localtime;
use File::Path;        # used to delete non-empty folder
use LWP::UserAgent;    #used to fire HTTP request

########################################################################################
# Funcation Name	: get_path_separator
# Description		: setting up correct slash "/" or "\" by detecting OS
# Arguments		: OS Name
# Return Values		: Path seperator (for linux: "/" and for Windows "\" )
#########################################################################################
sub get_path_separator {
    my $os        = $_[0];
    my $separator = "";
    $separator = "\\" if ( $os =~ m/win/i );
    $separator = "\/" if ( $os =~ m/lin/i );
   # if ($os =~ m/win/i )
   # {
   # 	$ENV { 'PATH' } = 'D:/ANT/apache-ant-1.7.0';
   # }
    return ($separator);
}

########################################################################################
# Funcation Name: Read_caTIES_conf_file
# Description   : Reads Configuration paramters from config file
# Arguments	: Config file name
# Return Values : ReportLoader_home,Deidentifier_home, ConceptCode_home, Input Dir, Bad dir, Process Dir, caTissue_home, PropertFile_Name, Detail Report location
#########################################################################################

sub read_caTIES_conf_file {
    my $file_name = $_[0];
    my @file_data;
    my $line;
    my ( $val_1, $val_2, $val_3, $val_4, $val_5, $val_6, $val_7, $val_8, $val_9);
    my $os=$^O;
	
	#Converting file into Linux format. Its required if file is edited on Windows and run on Linux. 
	system ("dos2unix $file_name") if ( $os =~ m/lin/i ); 

    open( FP, "$file_name" )
      || die("\nCould not open $file_name file.\nError: $!");
    @file_data = <FP>;
    close(FP);

    foreach $line (@file_data) {
        chomp($line);
        if ( $line =~ /^(ReportLoader.Home=)/g ) {
            $val_1 = $';
        }
        elsif ( $line =~ /^(Deidentifier.Home=)/g ) {
            $val_2 = $';
        }
        elsif ( $line =~ /^(ConceptCode.Home=)/g ) {
            $val_3 = $';
			}
		elsif ( $line =~ /^(input_dir=)/g ) {
            $val_4 = $';
			}
		elsif ( $line =~ /^(bad_dir=)/g ) {
            $val_5 = $';
			}
		elsif ( $line =~ /^(process_dir=)/g ) {
            $val_6 = $';
			}
		elsif ( $line =~ /^(caTissue.Home=)/g ) {
            $val_7 = $';
			}
		elsif ( $line =~ /^(PropertyFile.Name=)/g ) {
            $val_8 = $';
			}
		elsif ( $line =~ /^(Detail.Report=)/g ) {
			$val_9 = $';
			}
        
    }
	
    if (   $val_1 eq "") 
		{die("ReportLoader.Home missing.\n");
		}
    elsif ($val_2 eq "")
		{die("Deidentifier.Home missing.\n");
		}
	elsif ($val_3 eq "")
		{die("ConceptCode.Home missing.\n");
		}
	elsif ($val_4 eq "")
		{die("input_dir missing.\n");
		}
	elsif ($val_5 eq "")
		{die("bad_dir missing.\n");
		}
	elsif ($val_6 eq "")
		{die("process_dir missing.\n");
		}
	elsif ($val_7 eq "")
		{die("caTissue.Home missing.\n");
		}
	elsif ($val_8 eq "")
		{die("PropertyFile.Name missing.\n");
		}
	elsif ($val_9 eq "")
		{die("Detail.Report missing.\n");
		}	
		
    return ( $val_1, $val_2, $val_3, $val_4, $val_5, $val_6, $val_7, $val_8, $val_9);
}

########################################################################################
# Funcation Name: Read_caTissue_property_file
# Description   : Reads Database properties from caTissue property file
# Arguments	: caTissue Property file name
# Return Values : Database Type, database Host, Database Port, Database Name, Database user, Database Password, database TNS name
#########################################################################################

sub read_caTissue_property_file {
    my $file_name = $_[0];
    my @file_data;
    my $line;
    my ( $val_1, $val_2, $val_3, $val_4, $val_5, $val_6, $val_7);
    my $os=$^O;
	
	#Converting file into Linux format. Its required if file is edited on Windows and run on Linux. 
	system ("dos2unix $file_name") if ( $os =~ m/lin/i ); 

    open( FP, "$file_name" )
      || die("\nCould not open $file_name file.\nError: $!");
    @file_data = <FP>;
    close(FP);

    foreach $line (@file_data) {
        chomp($line);
        if ( $line =~ /^(database.type=)/g ) {
            $val_1 = $';
        }
        elsif (( $line =~ /^(database.host=)/g) ) {
            $val_2 = $';
        }
        elsif ( $line =~ /^(database.port=)/g ) {
            $val_3 = $';
			}
		elsif ( $line =~ /^(database.name=)/g ) {
            $val_4 = $';
			}
		elsif (( $line =~ /^(database.username=)/g) ) {
            $val_5 = $';
			}
		elsif ( $line =~ /^(database.password=)/g ) {
            $val_6 = $';
			}
		elsif ( $line =~ /^(oracle.tns.name=)/g ) {
            $val_7 = $';
			}
        
    }
	
    if (   $val_1 eq "") 
		{die("Database Type missing.\n");
		}
    elsif ($val_2 eq "")
		{die("Database Host missing.\n");
		}
	elsif ($val_3 eq "")
		{die("Database Port missing.\n");
		}
	elsif ($val_4 eq "")
		{die("Database Name missing.\n");
		}
	elsif ($val_5 eq "")
		{die("Database User missing.\n");
		}
	elsif ($val_6 eq "")
		{die("Database Password missing.\n");
		}
		
    return ( $val_1, $val_2, $val_3, $val_4, $val_5, $val_6, $val_7);
}

########################################################################################
# Funcation Name : write_detail_report
# Description    :
# Arguments		 : $detail_report,$test_id,$test_summary,$status
# Return Values	 : -
########################################################################################
sub write_detail_report {
    my $file_name = shift;    #it will assign 1st argument
	my $csv_row = join( ',', @_ );    # it will create single row of coma seperated values
    open( FP, ">>$file_name" );
    print FP "$csv_row\n";
    close(FP);
}

########################################################################################
# Funcation Name	: cleaning_old_artifacts
# Description		:
# Arguments			: detail_report
# Return Values		: -
########################################################################################

sub cleaning_old_artifacts {

       unlink( $_[0] );
      #or warn "Could not delete file: $!";
    
}

########################################################################################
# Funcation Name	: initial_setup_ppm
# Description		:
# Arguments			:  detail_report
# Return Values		: -
#########################################################################################

sub initial_setup_ppm {
    #Writing initial Headers in Report (csv) file
    write_detail_report(
        $_[0],
        "Test Id",
        "Test Summary",
        "Test Execution Status"
    );
	
	
}

1;